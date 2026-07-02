import bcrypt from "bcrypt";
import { uuidv7 } from "uuidv7";
import fs from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// ─────────────────────────────────────────────────────────────────────────────
// WHO TABLES — digunakan untuk kalkulasi z-score yang akurat secara medis
// ─────────────────────────────────────────────────────────────────────────────
const WHO = JSON.parse(
    fs.readFileSync(join(__dirname, "../../constants/whoTables.json"), "utf8"),
);

const SALT_ROUNDS = 10;

// ─────────────────────────────────────────────────────────────────────────────
// SAW BOBOT KRITERIA
// ⚠️  Pastikan nilai ini sesuai dengan data di tabel saw_kriteria di database!
// ─────────────────────────────────────────────────────────────────────────────
const SAW_BOBOT = {
    zscore_bbu: 0.30,
    zscore_tbu: 0.40,
    zscore_bbtb: 0.20,
    frekuensi_hadir: 0.10,
};

// =============================================================================
// Z-SCORE CALCULATION (identik dengan src/services/zscoreService.js)
// =============================================================================

const hitungZScore = (nilai, L, M, S) => {
    if (L === 0) return Math.log(nilai / M) / S;
    return (Math.pow(nilai / M, L) - 1) / (L * S);
};

const hitungUsiaBulan = (tglLahir, tglUkur) => {
    const lahir = new Date(tglLahir);
    const ukur = new Date(tglUkur);
    let bulan =
        (ukur.getFullYear() - lahir.getFullYear()) * 12 +
        (ukur.getMonth() - lahir.getMonth());
    if (ukur.getDate() < lahir.getDate()) bulan--;
    return Math.max(0, bulan);
};

const hitungUsiaBulanDesimal = (tglLahir, tglUkur) => {
    const lahir = new Date(tglLahir);
    const ukur = new Date(tglUkur);
    const selisihHari = (ukur - lahir) / (1000 * 60 * 60 * 24);
    return Math.max(0, selisihHari / 30.4375);
};

const cariLMS = (table, desimal) => {
    const bawah = Math.floor(desimal);
    const atas = Math.ceil(desimal);
    if (bawah === atas) return table.find((r) => r.bulan === bawah) || null;
    const lmsBawah = table.find((r) => r.bulan === bawah);
    const lmsAtas = table.find((r) => r.bulan === atas);
    if (!lmsBawah) return lmsAtas || null;
    if (!lmsAtas) return lmsBawah || null;
    const f = desimal - bawah;
    return {
        L: lmsBawah.L + (lmsAtas.L - lmsBawah.L) * f,
        M: lmsBawah.M + (lmsAtas.M - lmsBawah.M) * f,
        S: lmsBawah.S + (lmsAtas.S - lmsBawah.S) * f,
    };
};

const zBBU = (bb, desimal, g) => {
    const table = WHO[`bbu_${g}`];
    if (!table) return 0;
    const lms = cariLMS(table, desimal);
    if (!lms) return 0;
    return hitungZScore(bb, lms.L, lms.M, lms.S);
};

const zTBU = (tb, desimal, g) => {
    const table = WHO[`tbu_${g}`];
    if (!table) return 0;
    const lms = cariLMS(table, desimal);
    if (!lms) return 0;
    return hitungZScore(tb, lms.L, lms.M, lms.S);
};

const zBBTB = (bb, tb, usiaBulan, g) => {
    const key = usiaBulan <= 24 ? `wfl_${g}` : `wfh_${g}`;
    const kolom = usiaBulan <= 24 ? "panjang" : "tinggi";
    const table = WHO[key];
    if (!table) return 0;
    const tbR = Math.round(tb * 10) / 10;
    let lms = table.find((r) => r[kolom] === tbR);
    if (!lms) {
        let closest = null,
            minDiff = Infinity;
        for (const row of table) {
            const diff = Math.abs(row[kolom] - tbR);
            if (diff < minDiff) {
                minDiff = diff;
                closest = row;
            }
        }
        lms = closest;
    }
    if (!lms) return 0;
    return hitungZScore(bb, lms.L, lms.M, lms.S);
};

const statusGizi = (bbu, tbu, bbtb) => {
    const burukCount = [bbu, tbu, bbtb].filter((z) => z < -3).length;
    const kurangCount = [bbu, tbu, bbtb].filter((z) => z < -2).length;
    if (burukCount >= 2 || tbu < -3) return "buruk";
    if (kurangCount >= 1) return "kurang";
    if (bbtb > 2) return "lebih";
    return "normal";
};

// =============================================================================
// SAW CALCULATION (identik dengan src/services/sawService.js)
// =============================================================================

const normZ = (z) => {
    const clipped = Math.max(-3, Math.min(2, z));
    return 1 - (clipped - -3) / (2 - -3);
};

const hitungSAW = (zbbu, ztbu, zbbtb, totalUkurSetahun) => {
    const kehadiran = 1 - Math.min(totalUkurSetahun / 12, 1.0);
    const nilai = {
        zscore_bbu: normZ(zbbu),
        zscore_tbu: normZ(ztbu),
        zscore_bbtb: normZ(zbbtb),
        frekuensi_hadir: kehadiran,
    };
    let skor = 0;
    for (const [k, b] of Object.entries(SAW_BOBOT)) skor += b * nilai[k];
    skor = parseFloat(skor.toFixed(4));
    const kategori =
        skor > 0.6667 ? "tinggi" : skor > 0.3334 ? "sedang" : "rendah";
    return { skor, kategori, nilai };
};

// =============================================================================
// HELPERS
// =============================================================================

/** Hitung lingkar kepala & lengan (hanya untuk anak < 24 bulan) */
const hitungLingkar = (usiaBulan) => {
    if (usiaBulan >= 24) return { lk: null, ll: null };
    const lk =
        usiaBulan < 6
            ? parseFloat((34.0 + usiaBulan * 1.5).toFixed(1))
            : parseFloat((43.0 + (usiaBulan - 6) * 0.33).toFixed(1));
    const ll =
        usiaBulan < 6
            ? parseFloat((11.0 + usiaBulan * 0.42).toFixed(1))
            : parseFloat((13.5 + (usiaBulan - 6) * 0.14).toFixed(1));
    return { lk, ll };
};

/** SQL-safe string wrapper */
const sq = (val) =>
    val === null || val === undefined
        ? "NULL"
        : `'${String(val).replace(/'/g, "''")}'`;

/** Riwayat pemberian berdasarkan usia anak saat ini */
const getRiwayatItems = (usiaSaatIni) => {
    if (usiaSaatIni < 6) {
        return [];
    } else if (usiaSaatIni < 12) {
        return [
            { jenis: "vitamin_a", nama: "Vitamin A Biru 100.000 IU", dosis: "1 Kapsul Biru", tgl: "2026-02-03", kaderIdx: 0 },
            { jenis: "pmt", nama: "Biskuit PMT Balita", dosis: "1 Kotak", tgl: "2026-05-03", kaderIdx: 1 },
        ];
    } else if (usiaSaatIni < 24) {
        return [
            { jenis: "vitamin_a", nama: "Vitamin A Merah 200.000 IU", dosis: "1 Kapsul Merah", tgl: "2026-02-03", kaderIdx: 0 },
            { jenis: "obat_cacing", nama: "Albendazole 400mg", dosis: "1 Tablet", tgl: "2026-03-03", kaderIdx: 1 },
            { jenis: "pmt", nama: "Biskuit PMT Balita", dosis: "1 Kotak", tgl: "2026-05-03", kaderIdx: 2 },
        ];
    } else {
        return [
            { jenis: "vitamin_a", nama: "Vitamin A Merah 200.000 IU", dosis: "1 Kapsul Merah", tgl: "2026-01-03", kaderIdx: 0 },
            { jenis: "obat_cacing", nama: "Albendazole 400mg", dosis: "1 Tablet", tgl: "2026-03-03", kaderIdx: 1 },
            { jenis: "pmt", nama: "Biskuit PMT Balita", dosis: "2 Kotak", tgl: "2026-05-03", kaderIdx: 2 },
        ];
    }
};

// =============================================================================
// AI INSIGHT TEMPLATES (teks statis — tidak membutuhkan Gemini API)
// =============================================================================
const INSIGHT = {
    normal: `**Kondisi Saat Ini**\nKabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.\n\n**Yang Bisa Dilakukan**\n1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.\n2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.\n3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.\n\n**Kapan Perlu ke Dokter**\nSegera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.`,

    kurang: `**Kondisi Saat Ini**\nBerat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.\n\n**Yang Bisa Dilakukan**\n1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.\n2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.\n3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.\n\n**Kapan Perlu ke Dokter**\nSegera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.`,

    buruk: `**Kondisi Saat Ini**\nBerdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.\n\n**Yang Bisa Dilakukan**\n1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.\n2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.\n3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.\n\n**Kapan Perlu ke Dokter**\nSi kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.`,
};

// =============================================================================
// SEED DATA DEFINITIONS
// =============================================================================

/** Tanggal pengukuran — 6 bulan ke belakang, interval bulanan, tepat tanggal 3 */
const MEASUREMENT_DATES = [
    "2026-01-03",
    "2026-02-03",
    "2026-03-03",
    "2026-04-03",
    "2026-05-03",
    "2026-06-03",
];

const KADER_LIST = [
    { nama: "Riri Andayani", email: "meongterbang22@gmail.com", password: "password123", no_hp: "081234567890" },
    { nama: "Budi Santoso", email: "budi.kader@gmail.com", password: "password123", no_hp: "082345678901" },
    { nama: "Sari Dewi", email: "sari.kader@gmail.com", password: "password123", no_hp: "083456789012" },
];

const PUSKE_LIST = [
    { nama: "Ciko Wijaya", email: "bullmini123@gmail.com", password: "password123", no_hp: "081234567891", jabatan: "Bidan" },
    { nama: "dr. Hana Pertiwi", email: "hana.pertiwi@gmail.com", password: "password123", no_hp: "084567890123", jabatan: "Dokter" },
];

const OT_LIST = [
    { nama: "Aminah Kusuma", no_hp: "081111111101", alamat: "Jl. Mawar No. 12 RT 01 RW 05", nik: "3201010101870001", email: "aminah.kusuma@gmail.com", password: "password123" },
    { nama: "Dewi Susanti", no_hp: "081111111102", alamat: "Jl. Melati No. 5 RT 02 RW 05", nik: "3201010201890002", email: "dewi.susanti@gmail.com", password: "password123" },
    { nama: "Fatimah Rahman", no_hp: "081111111103", alamat: "Jl. Anggrek No. 8 RT 03 RW 05", nik: "3201010301850003", email: "fatimah.rahman@gmail.com", password: "password123" },
    { nama: "Siti Rahayu", no_hp: "081111111104", alamat: "Jl. Dahlia No. 3 RT 01 RW 05", nik: "3201010401900004", email: "siti.rahayu@gmail.com", password: "password123" },
    { nama: "Kartini Wulandari", no_hp: "081111111105", alamat: "Jl. Kenanga No. 7 RT 04 RW 05", nik: "3201010501880005", email: "kartini.wulandari@gmail.com", password: "password123" },
    { nama: "Rahayu Lestari", no_hp: "081111111106", alamat: "Jl. Bougenville No. 15 RT 02 RW 05", nik: "3201010601910006", email: "rahayu.lestari@gmail.com", password: "password123" },
    { nama: "Wulan Sari", no_hp: "081111111107", alamat: "Jl. Cempaka No. 4 RT 03 RW 05", nik: "3201010701920007", email: "wulan.sari@gmail.com", password: "password123" },
    { nama: "Lestari Handayani", no_hp: "081111111108", alamat: "Jl. Flamboyan No. 9 RT 05 RW 05", nik: "3201010801860008", email: "lestari.handayani@gmail.com", password: "password123" },
    { nama: "Nuraini Putri", no_hp: "081111111109", alamat: "Jl. Kamboja No. 2 RT 01 RW 05", nik: "3201010901930009", email: "nuraini.putri@gmail.com", password: "password123" },
    { nama: "Sumiati Wahyu", no_hp: "081111111110", alamat: "Jl. Teratai No. 6 RT 04 RW 05", nik: "3201011001870010", email: "sumiati.wahyu@gmail.com", password: "password123" },
];

/**
 * Data anak beserta scenario pertumbuhan:
 *  - normal : z-score mendekati 0 (tumbuh kembang baik)
 *  - kurang : z-score ~ -1.5 s/d -2.5 (berisiko)
 *  - buruk  : z-score < -2.5 (risiko stunting tinggi)
 *
 * baseWeight / baseHeight = nilai pada pengukuran pertama (2026-01-03)
 * wInc / hInc = kenaikan per bulan (6 titik total)
 */
const ANAK_LIST = [
    // ── OT 0: Aminah Kusuma (2 anak) ──────────────────────────────
    { nama: "Rizki",  gender: "L", tglLahir: "2025-06-17", noKk: "3201011234560001", otIdx: 0, baseWeight: 8.8,  baseHeight: 71.5, wInc: 0.28, hInc: 1.25, scenario: "normal" }, // ~6-11 bln
    { nama: "Rafi",   gender: "L", tglLahir: "2023-10-15", noKk: "3201011234560002", otIdx: 0, baseWeight: 14.2, baseHeight: 93.5, wInc: 0.20, hInc: 0.68, scenario: "normal" }, // ~26-31 bln
    // ── OT 1: Dewi Susanti (1 anak) ──────────────────────────────
    { nama: "Nayla",  gender: "P", tglLahir: "2025-10-22", noKk: "3201011234560003", otIdx: 1, baseWeight: 6.6,  baseHeight: 62.5, wInc: 0.40, hInc: 1.90, scenario: "normal" }, // ~2-7 bln
    // ── OT 2: Fatimah Rahman (2 anak) ────────────────────────────
    { nama: "Hasan",  gender: "L", tglLahir: "2024-06-03", noKk: "3201011234560004", otIdx: 2, baseWeight: 8.8,  baseHeight: 80.5, wInc: 0.22, hInc: 0.72, scenario: "kurang" }, // 19-24 bln (tglLahir ≤ tgl ukur agar bracket tepat)
    { nama: "Husein", gender: "L", tglLahir: "2025-12-03", noKk: "3201011234560005", otIdx: 2, baseWeight: 5.2,  baseHeight: 57.5, wInc: 0.72, hInc: 2.70, scenario: "normal" }, // 1-6 bln (tglLahir ≤ tgl ukur agar bracket tepat)
    // ── OT 3: Siti Rahayu (1 anak) ───────────────────────────────
    { nama: "Zahra",  gender: "P", tglLahir: "2024-12-08", noKk: "3201011234560006", otIdx: 3, baseWeight: 7.3,  baseHeight: 71.0, wInc: 0.18, hInc: 1.10, scenario: "kurang" }, // ~12-17 bln
    // ── OT 4: Kartini Wulandari (2 anak) ─────────────────────────
    { nama: "Dani",   gender: "L", tglLahir: "2023-12-19", noKk: "3201011234560007", otIdx: 4, baseWeight: 9.3,  baseHeight: 82.5, wInc: 0.18, hInc: 0.90, scenario: "buruk"  }, // ~24-29 bln
    { nama: "Dina",   gender: "P", tglLahir: "2025-03-14", noKk: "3201011234560008", otIdx: 4, baseWeight: 9.3,  baseHeight: 74.0, wInc: 0.24, hInc: 1.20, scenario: "normal" }, // ~9-14 bln
    // ── OT 5: Rahayu Lestari (1 anak) ────────────────────────────
    { nama: "Bagas",  gender: "L", tglLahir: "2024-10-25", noKk: "3201011234560009", otIdx: 5, baseWeight: 8.5,  baseHeight: 76.0, wInc: 0.19, hInc: 0.82, scenario: "kurang" }, // ~14-19 bln
    // ── OT 6: Wulan Sari (1 anak) ────────────────────────────────
    { nama: "Putri",  gender: "P", tglLahir: "2025-08-07", noKk: "3201011234560010", otIdx: 6, baseWeight: 7.6,  baseHeight: 66.5, wInc: 0.28, hInc: 1.50, scenario: "normal" }, // ~4-9 bln
    // ── OT 7: Lestari Handayani (2 anak) ─────────────────────────
    { nama: "Adi",    gender: "L", tglLahir: "2023-06-20", noKk: "3201011234560011", otIdx: 7, baseWeight: 10.0, baseHeight: 84.5, wInc: 0.15, hInc: 0.80, scenario: "buruk"  }, // ~30-35 bln
    { nama: "Ayu",    gender: "P", tglLahir: "2024-08-16", noKk: "3201011234560012", otIdx: 7, baseWeight: 8.4,  baseHeight: 77.0, wInc: 0.19, hInc: 1.00, scenario: "kurang" }, // ~16-21 bln
    // ── OT 8: Nuraini Putri (1 anak) ─────────────────────────────
    { nama: "Fauzi",  gender: "L", tglLahir: "2025-04-09", noKk: "3201011234560013", otIdx: 8, baseWeight: 9.8,  baseHeight: 75.0, wInc: 0.22, hInc: 1.35, scenario: "normal" }, // ~8-13 bln
    // ── OT 9: Sumiati Wahyu (2 anak) ─────────────────────────────
    { nama: "Bella",  gender: "P", tglLahir: "2024-02-13", noKk: "3201011234560014", otIdx: 9, baseWeight: 9.5,  baseHeight: 83.0, wInc: 0.19, hInc: 0.60, scenario: "kurang" }, // ~22-27 bln
    { nama: "Bimo",   gender: "L", tglLahir: "2025-09-21", noKk: "3201011234560015", otIdx: 9, baseWeight: 5.5,  baseHeight: 60.5, wInc: 0.22, hInc: 1.30, scenario: "buruk"  }, // ~3-8 bln
];

/** 7 jadwal posyandu: 6 lampau + 1 mendatang (hari demo) */
const JADWAL_LIST = [
    { tanggal: "2026-01-03", mulai: "08:00", selesai: "11:00", lokasi: "Balai RW 05 Kelurahan Cempaka", ket: "Posyandu Rutin Januari 2026", kaderIdx: 0 },
    { tanggal: "2026-02-03", mulai: "08:00", selesai: "11:00", lokasi: "Balai RW 05 Kelurahan Cempaka", ket: "Posyandu Rutin Februari 2026", kaderIdx: 0 },
    { tanggal: "2026-03-03", mulai: "08:30", selesai: "11:30", lokasi: "Balai RW 05 Kelurahan Cempaka", ket: "Posyandu Rutin Maret 2026", kaderIdx: 1 },
    { tanggal: "2026-04-03", mulai: "08:00", selesai: "12:00", lokasi: "Puskesmas Pembantu Cempaka", ket: "Posyandu + Pemberian Vitamin A Massal", kaderIdx: 1 },
    { tanggal: "2026-05-03", mulai: "08:00", selesai: "11:00", lokasi: "Balai RW 05 Kelurahan Cempaka", ket: "Posyandu Rutin Mei 2026", kaderIdx: 2 },
    { tanggal: "2026-06-03", mulai: "08:30", selesai: "12:00", lokasi: "Balai RW 05 Kelurahan Cempaka", ket: "Posyandu Rutin Juni 2026 - Pembagian PMT", kaderIdx: 0 },
    { tanggal: "2026-07-03", mulai: "08:00", selesai: "11:00", lokasi: "Balai RW 05 Kelurahan Cempaka", ket: "Posyandu Rutin Juli 2026", kaderIdx: 1 },
];

// =============================================================================
// MAIN SEEDER
// =============================================================================
async function generateSeeder() {
    console.log("🌱 Generating comprehensive seeder...\n");
    const lines = [];

    lines.push("USE posyandu_pui;");
    lines.push("");

    // ── Full Reset ──────────────────────────────────────────────────────────────
    lines.push("-- ==========================================================");
    lines.push("-- FULL RESET — Hapus semua data lama (urutan FK terbalik)");
    lines.push("-- ==========================================================");
    lines.push("SET FOREIGN_KEY_CHECKS = 0;");
    for (const t of [
        "notifikasi", "ai_insight", "rujukan",
        "saw_result_detail", "saw_result",
        "riwayat_pemberian", "pengukuran",
        "anak", "jadwal_posyandu",
        "orang_tua", "kader", "puskesmas_user",
        "refresh_tokens", "login_attempts", "password_reset_token",
        "users", "saw_kriteria"
    ]) {
        lines.push(`TRUNCATE TABLE ${t};`);
    }
    lines.push("SET FOREIGN_KEY_CHECKS = 1;");
    lines.push("");

    lines.push("-- ==========================================================");
    lines.push("-- SAW KRITERIA SETUP");
    lines.push("-- ==========================================================");
    lines.push("INSERT INTO saw_kriteria (nama_kriteria, bobot, keterangan) VALUES");
    lines.push("    ('zscore_tbu',      0.4000, 'Tinggi Badan per Umur'),");
    lines.push("    ('zscore_bbu',      0.3000, 'Berat Badan per Umur'),");
    lines.push("    ('zscore_bbtb',     0.2000, 'Berat Badan per Tinggi Badan'),");
    lines.push("    ('frekuensi_hadir', 0.1000, 'Kehadiran rutin ke posyandu');");
    lines.push("");

    // ── Generate UUIDs ──────────────────────────────────────────────────────────
    const kaderIds = KADER_LIST.map(() => ({ uId: uuidv7(), kId: uuidv7() }));
    const puskeIds = PUSKE_LIST.map(() => ({ uId: uuidv7(), pId: uuidv7() }));
    const otIds = OT_LIST.map(() => ({ uId: uuidv7(), oId: uuidv7() }));
    const anakIds = ANAK_LIST.map(() => uuidv7());

    // ── Hash passwords ──────────────────────────────────────────────────────────
    console.log("⏳ Hashing passwords (harap tunggu)...");
    const kaderHashes = await Promise.all(
        KADER_LIST.map((k) => bcrypt.hash(k.password, SALT_ROUNDS)),
    );
    const puskeHashes = await Promise.all(
        PUSKE_LIST.map((p) => bcrypt.hash(p.password, SALT_ROUNDS)),
    );
    const otHashes = await Promise.all(
        OT_LIST.map((o) => bcrypt.hash(o.password, SALT_ROUNDS)),
    );
    console.log("✅ Password selesai di-hash\n");

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 1 — users + kader + puskesmas_user
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 1: Users, Kader, Puskesmas");
    lines.push("-- ==========================================================");
    lines.push("");

    for (let i = 0; i < KADER_LIST.length; i++) {
        const k = KADER_LIST[i];
        const ids = kaderIds[i];
        console.log(`[Kader ${i + 1}] ${k.nama} | ${k.email} | password: ${k.password}`);
        lines.push(`INSERT INTO users (id, email, password_hash, role, is_active) VALUES`);
        lines.push(`    (${sq(ids.uId)}, ${sq(k.email)}, ${sq(kaderHashes[i])}, 'kader', TRUE);`);
        lines.push(`INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES`);
        lines.push(`    (${sq(ids.kId)}, ${sq(ids.uId)}, ${sq(k.nama)}, ${sq(k.no_hp)});`);
        lines.push("");
    }

    for (let i = 0; i < PUSKE_LIST.length; i++) {
        const p = PUSKE_LIST[i];
        const ids = puskeIds[i];
        console.log(`[Puskesmas ${i + 1}] ${p.nama} | ${p.email} | password: ${p.password}`);
        lines.push(`INSERT INTO users (id, email, password_hash, role, is_active) VALUES`);
        lines.push(`    (${sq(ids.uId)}, ${sq(p.email)}, ${sq(puskeHashes[i])}, 'puskesmas', TRUE);`);
        lines.push(`INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES`);
        lines.push(`    (${sq(ids.pId)}, ${sq(ids.uId)}, ${sq(p.nama)}, ${sq(p.jabatan)}, ${sq(p.no_hp)});`);
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 2 — orang_tua
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 2: Orang Tua");
    lines.push("-- ==========================================================");
    lines.push("");

    for (let i = 0; i < OT_LIST.length; i++) {
        const ot = OT_LIST[i];
        const ids = otIds[i];
        const kaderAssign = kaderIds[i % KADER_LIST.length].kId;
        console.log(`[OT ${i + 1}] ${ot.nama} | ${ot.email}`);
        lines.push(`INSERT INTO users (id, email, password_hash, role, is_active) VALUES`);
        lines.push(`    (${sq(ids.uId)}, ${sq(ot.email)}, ${sq(otHashes[i])}, 'orang_tua', TRUE);`);
        lines.push(`INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES`);
        lines.push(`    (${sq(ids.oId)}, ${sq(ids.uId)}, ${sq(kaderAssign)}, ${sq(ot.nama)}, ${sq(ot.no_hp)}, ${sq(ot.alamat)}, ${sq(ot.nik)});`);
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 2 — jadwal_posyandu
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)");
    lines.push("-- ==========================================================");
    lines.push("");

    for (const j of JADWAL_LIST) {
        const kId = kaderIds[j.kaderIdx].kId;
        lines.push(`INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES`);
        lines.push(`    (${sq(kId)}, ${sq(j.tanggal)}, ${sq(j.mulai)}, ${sq(j.selesai)}, ${sq(j.lokasi)}, ${sq(j.ket)});`);
    }
    lines.push("");

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 3 — anak
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 3: Anak (15 anak)");
    lines.push("-- ==========================================================");
    lines.push("");

    for (let i = 0; i < ANAK_LIST.length; i++) {
        const a = ANAK_LIST[i];
        const oId = otIds[a.otIdx].oId;
        console.log(`[Anak ${i + 1}] ${a.nama} | ${a.gender} | ${a.tglLahir} | scenario: ${a.scenario}`);
        lines.push(`INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES`);
        lines.push(`    (${sq(anakIds[i])}, ${sq(oId)}, ${sq(a.nama)}, ${sq(a.gender)}, ${sq(a.tglLahir)}, ${sq(a.noKk)});`);
    }
    lines.push("");

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 4 — pengukuran (6 titik historis per anak)
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)");
    lines.push("-- Z-score dihitung otomatis menggunakan WHO tables");
    lines.push("-- ==========================================================");
    lines.push("");

    let pengCount = 0;
    const pengMeta = []; // untuk referensi SAW & rujukan

    for (let aIdx = 0; aIdx < ANAK_LIST.length; aIdx++) {
        const a = ANAK_LIST[aIdx];
        const anakId = anakIds[aIdx];
        const kId = kaderIds[aIdx % KADER_LIST.length].kId;

        lines.push(`-- Anak: ${a.nama} (${a.gender}, lahir ${a.tglLahir}, scenario: ${a.scenario})`);

        for (let dIdx = 0; dIdx < MEASUREMENT_DATES.length; dIdx++) {
            const date = MEASUREMENT_DATES[dIdx];
            const w = parseFloat((a.baseWeight + dIdx * a.wInc).toFixed(1));
            const h = parseFloat((a.baseHeight + dIdx * a.hInc).toFixed(1));
            const desimal = hitungUsiaBulanDesimal(a.tglLahir, date);
            const bulan = hitungUsiaBulan(a.tglLahir, date);
            const zbbu = parseFloat(zBBU(w, desimal, a.gender).toFixed(3));
            const ztbu = parseFloat(zTBU(h, desimal, a.gender).toFixed(3));
            const zbbtb = parseFloat(zBBTB(w, h, bulan, a.gender).toFixed(3));
            const sg = statusGizi(zbbu, ztbu, zbbtb);
            const { lk, ll } = hitungLingkar(bulan);

            pengCount++;
            pengMeta.push({
                aIdx, dIdx, anakId,
                w, h, zbbu, ztbu, zbbtb, sg,
                pengId: pengCount, date,
            });

            lines.push(`INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES`);
            lines.push(`    (${sq(anakId)}, ${sq(kId)}, ${sq(date)}, ${w}, ${h}, ${lk ?? "NULL"}, ${ll ?? "NULL"}, ${zbbu}, ${ztbu}, ${zbbtb}, ${sq(sg)});`);
        }
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 4 — riwayat_pemberian
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 4: Riwayat Pemberian Vitamin A, Obat Cacing & PMT");
    lines.push("-- ==========================================================");
    lines.push("");

    let pemberianCount = 0;
    for (let aIdx = 0; aIdx < ANAK_LIST.length; aIdx++) {
        const a = ANAK_LIST[aIdx];
        const anakId = anakIds[aIdx];
        const usiaSaatIni = hitungUsiaBulan(a.tglLahir, "2026-06-03");
        const items = getRiwayatItems(usiaSaatIni);

        lines.push(`-- ${a.nama} (usia: ${usiaSaatIni} bulan)`);
        for (const item of items) {
            const kId = kaderIds[item.kaderIdx % KADER_LIST.length].kId;
            lines.push(`INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES`);
            lines.push(`    (${sq(anakId)}, ${sq(kId)}, ${sq(item.jenis)}, ${sq(item.nama)}, ${sq(item.dosis)}, ${sq(item.tgl)}, NULL);`);
            pemberianCount++;
        }
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 5 — saw_result + saw_result_detail
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 5: SAW Result + Detail (1 per pengukuran = 90 total)");
    lines.push("-- ==========================================================");
    lines.push("");

    let sawCount = 0;
    const sawMeta = [];

    for (const m of pengMeta) {
        const saw = hitungSAW(m.zbbu, m.ztbu, m.zbbtb, MEASUREMENT_DATES.length);
        sawCount++;
        sawMeta.push({ ...m, sawId: sawCount, skor: saw.skor, kategori: saw.kategori, nilai: saw.nilai });

        lines.push(`INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES`);
        lines.push(`    (${sq(m.anakId)}, ${m.pengId}, ${saw.skor}, ${sq(saw.kategori)});`);

        const kriteriaKeys = ["zscore_bbu", "zscore_tbu", "zscore_bbtb", "frekuensi_hadir"];
        const nilaiArr = [saw.nilai.zscore_bbu, saw.nilai.zscore_tbu, saw.nilai.zscore_bbtb, saw.nilai.frekuensi_hadir];

        for (let ki = 0; ki < kriteriaKeys.length; ki++) {
            const bobot = SAW_BOBOT[kriteriaKeys[ki]];
            const nilai = parseFloat(nilaiArr[ki].toFixed(4));
            const skor = parseFloat((bobot * nilai).toFixed(4));
            lines.push(`INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES`);
            lines.push(`    (${sawCount}, ${sq(kriteriaKeys[ki])}, ${bobot}, ${nilai}, ${skor});`);
        }
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 6 — rujukan (untuk anak dengan kategori_risiko 'tinggi')
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 6: Rujukan (anak kategori risiko tinggi)");
    lines.push("-- ==========================================================");
    lines.push("");

    // Ambil pengukuran terakhir (dIdx=5) dengan kategori 'tinggi', max 6 rujukan
    const candidatesForRujukan = sawMeta.filter(
        (r) => r.dIdx === 5 && r.kategori === "tinggi",
    );
    const rujukanTargets = candidatesForRujukan.slice(0, 6);
    const rujukanStatuses = ["selesai", "diterima", "diajukan", "diajukan", "ditolak", "selesai"];

    let rujukanCount = 0;
    const rujukanMeta = [];

    for (let ri = 0; ri < rujukanTargets.length; ri++) {
        const target = rujukanTargets[ri];
        const status = rujukanStatuses[ri] || "diajukan";
        const kId = kaderIds[target.aIdx % KADER_LIST.length].kId;
        const puskesId = status !== "diajukan" ? puskeIds[0].pId : null;
        const catatanKader = `Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko ${target.kategori} dengan skor ${target.skor}.`;
        const catatanPusk =
            ["selesai", "diterima"].includes(status)
                ? "Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan."
                : status === "ditolak"
                ? "Kondisi anak tidak memenuhi kriteria rujukan saat ini. Disarankan kontrol rutin di posyandu setiap bulan."
                : null;
        const validatedAt =
            status !== "diajukan"
                ? sq(`2026-05-${String(15 + ri).padStart(2, "0")}`)
                : "NULL";

        rujukanCount++;
        rujukanMeta.push({
            rujId: rujukanCount,
            otIdx: ANAK_LIST[target.aIdx].otIdx,
            status,
        });

        lines.push(`-- Rujukan untuk: ${ANAK_LIST[target.aIdx].nama} | Status: ${status}`);
        lines.push(`INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES`);
        lines.push(`    (${sq(target.anakId)}, ${sq(kId)}, ${puskesId ? sq(puskesId) : "NULL"}, ${target.sawId}, ${sq(status)}, ${sq(catatanKader)}, ${catatanPusk ? sq(catatanPusk) : "NULL"}, ${validatedAt});`);
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 6 — ai_insight (1 per anak, untuk pengukuran terakhir)
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 6: AI Insight — teks statis (1 per anak)");
    lines.push("-- ==========================================================");
    lines.push("");

    for (let aIdx = 0; aIdx < ANAK_LIST.length; aIdx++) {
        const a = ANAK_LIST[aIdx];
        const anakId = anakIds[aIdx];
        const lastSaw = sawMeta.find((s) => s.aIdx === aIdx && s.dIdx === 5);
        if (!lastSaw) continue;

        const teks = INSIGHT[a.scenario] || INSIGHT.normal;
        const prompt = `[Seeder] Anak: ${a.nama}, JK: ${a.gender}, Scenario: ${a.scenario}, Status Gizi: ${lastSaw.sg}`;

        lines.push(`-- ${a.nama} (${a.scenario})`);
        lines.push(`INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES`);
        lines.push(`    (${sq(anakId)}, ${lastSaw.pengId}, ${sq(prompt)}, ${sq(teks)});`);
        lines.push("");
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // TIER 7 — notifikasi
    // ══════════════════════════════════════════════════════════════════════════════
    lines.push("-- ==========================================================");
    lines.push("-- TIER 7: Notifikasi");
    lines.push("-- Jadwal ID 7 = Posyandu Juli 2026 (jadwal mendatang = hari demo)");
    lines.push("-- ==========================================================");
    lines.push("");

    // Notifikasi jadwal posyandu untuk semua orang tua
    lines.push("-- Notifikasi jadwal posyandu Juli 2026");
    for (let oi = 0; oi < OT_LIST.length; oi++) {
        const oId = otIds[oi].oId;
        lines.push(`INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES`);
        lines.push(`    (${sq(oId)}, 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);`);
    }
    lines.push("");

    // Notifikasi rujukan untuk orang tua yang anaknya dirujuk
    lines.push("-- Notifikasi status rujukan");
    for (const r of rujukanMeta) {
        const oId = otIds[r.otIdx].oId;
        let judul, pesan;
        switch (r.status) {
            case "diajukan":
                judul = "Rujukan Baru Telah Diajukan";
                pesan = "Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.";
                break;
            case "diterima":
                judul = "Rujukan Diterima Puskesmas";
                pesan = "Rujukan anak Anda telah diterima oleh puskesmas. Silakan datang untuk menjalani pemeriksaan dan program intervensi gizi yang telah disiapkan.";
                break;
            case "selesai":
                judul = "Rujukan Selesai Ditangani";
                pesan = "Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.";
                break;
            default:
                judul = "Update Status Rujukan";
                pesan = "Status rujukan anak Anda telah diperbarui. Silakan hubungi kader atau puskesmas untuk informasi lebih lanjut.";
        }
        const sudahDibaca = r.status === "selesai" ? "TRUE" : "FALSE";
        lines.push(`INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES`);
        lines.push(`    (${sq(oId)}, ${sq(judul)}, ${sq(pesan)}, 'rujukan', ${sudahDibaca}, '2026-06-01 10:00:00', NULL, ${r.rujId});`);
    }
    lines.push("");

    // ── Write seeder.sql ────────────────────────────────────────────────────────
    fs.writeFileSync(
        "./src/database/seeder/seeder.sql",
        lines.join("\n"),
        "utf8",
    );

    const totalNotif = OT_LIST.length + rujukanCount;
    console.log("\n✅ seeder.sql berhasil dibuat!");
    console.log("\n📊 Ringkasan data yang di-seed:");
    console.log(`   Kader             : ${KADER_LIST.length}`);
    console.log(`   Puskesmas User    : ${PUSKE_LIST.length}`);
    console.log(`   Orang Tua         : ${OT_LIST.length}`);
    console.log(`   Anak              : ${ANAK_LIST.length}`);
    console.log(`   Jadwal Posyandu   : ${JADWAL_LIST.length} (6 lampau, 1 mendatang = hari demo)`);    
    console.log(`   Pengukuran        : ${pengCount} (6 titik/anak × ${ANAK_LIST.length} anak)`);
    console.log(`   Riwayat Pemberian : ${pemberianCount}`);
    console.log(`   SAW Result        : ${sawCount}`);
    console.log(`   SAW Detail        : ${sawCount * 4} (4 kriteria/result)`);
    console.log(`   Rujukan           : ${rujukanCount}`);
    console.log(`   AI Insight        : ${ANAK_LIST.length} (1 per anak)`);
    console.log(`   Notifikasi        : ${totalNotif} (${OT_LIST.length} jadwal + ${rujukanCount} rujukan)`);
    console.log("\n🚀 Cara menjalankan seeder:");
    console.log("   npm run seed:run");
    console.log("   — atau buka seeder.sql di DataGrip dan jalankan secara manual.");
}

generateSeeder().catch(console.error);
