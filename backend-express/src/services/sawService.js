import db from "../database/connection.js";

// =============================================================================
// NORMALISASI
// Semua kriteria bersifat COST — makin tinggi nilai normalisasi = makin berisiko
// =============================================================================

/**
 * Normalisasi Z-Score (TB/U, BB/U, BB/TB)
 * Range diklem pada [-3, +2] sesuai batas klinis WHO untuk stunting.
 * Dibalik (1 - x) karena cost criterion: z-score rendah = risiko tinggi.
 *
 * Referensi: WHO (2006). WHO Child Growth Standards. Geneva: WHO.
 */
const normalisasiZScore = (zscore) => {
    const MIN = -3;
    const MAX = 2;
    const clipped = Math.max(MIN, Math.min(MAX, zscore));
    return 1 - (clipped - MIN) / (MAX - MIN);
};

/**
 * Normalisasi Tren Berat Badan (∆BB antar dua pengukuran berurutan)
 * Menggunakan threshold 200g/bulan sebagai kenaikan minimum yang sehat
 * sesuai Buku KIA Kemenkes RI (2021).
 *
 * delta_kg : selisih BB dalam kg (positif=naik, negatif=turun, null=tidak ada data sebelumnya)
 *
 * Skema nilai:
 *   ∆BB ≥ +200g       → 0.0  (naik cukup, risiko rendah)
 *   0 < ∆BB < +200g   → 0.0–0.5 (naik tapi kurang dari threshold)
 *   ∆BB = 0            → 0.7  (stagnan, perlu waspada)
 *   ∆BB < 0            → 0.7–1.0 (turun, interpolasi hingga drop 500g = 1.0)
 *   null               → 0.5  (netral, pengukuran pertama — tidak ada penalti)
 *
 * Referensi: Kemenkes RI (2021). Buku Kesehatan Ibu dan Anak. Jakarta: Kemenkes RI.
 */
const normalisasiTrenBB = (delta_kg) => {
    if (delta_kg === null || delta_kg === undefined) return 0.5;

    const delta_gram = delta_kg * 1000;
    const THRESHOLD_CUKUP = 200;  // gram/bulan: kenaikan minimum yang sehat
    const MAX_TURUN = 500;        // gram: drop ≥500g = risiko maksimal

    if (delta_gram >= THRESHOLD_CUKUP) return 0.0;

    if (delta_gram > 0) {
        // Naik tapi di bawah threshold → interpolasi 0.0–0.5
        return 0.5 * (1 - delta_gram / THRESHOLD_CUKUP);
    }

    if (delta_gram === 0) return 0.7; // stagnan

    // Turun → interpolasi 0.7–1.0
    return Math.min(1.0, 0.7 + 0.3 * (Math.abs(delta_gram) / MAX_TURUN));
};

const tentukanKategoriRisiko = (skor_akhir) => {
    if (skor_akhir > 0.6667) return "tinggi";
    if (skor_akhir > 0.3334) return "sedang";
    return "rendah";
};

// =============================================================================
// KRITERIA & BOBOT
// Ditetapkan berdasarkan standar indikator antropometri WHO dan Kemenkes RI.
//
// Referensi penetapan bobot:
//   - TB/U (0.40): Indikator utama stunting (WHO, 2006; Kemenkes, 2020)
//   - BB/U (0.25): Status gizi keseluruhan (WHO, 2009)
//   - BB/TB (0.20): Wasting/kekurusan akut (Black et al., 2013)
//   - Tren BB (0.15): Dinamika pertumbuhan (Victora et al., 2010; Kemenkes, 2021)
// =============================================================================
const KRITERIA = [
    { nama_kriteria: "zscore_tbu",  bobot: 0.40 },
    { nama_kriteria: "zscore_bbu",  bobot: 0.25 },
    { nama_kriteria: "zscore_bbtb", bobot: 0.20 },
    { nama_kriteria: "tren_bb",     bobot: 0.15 },
];

// =============================================================================
// HELPER: Ambil BB pengukuran sebelumnya untuk hitung tren
// =============================================================================
const getPreviousBB = async (anak_id, tanggal_ukur) => {
    const [rows] = await db.query(
        `SELECT berat_badan FROM pengukuran
        WHERE anak_id = ? AND tanggal_ukur < ?
        ORDER BY tanggal_ukur DESC
        LIMIT 1`,
        [anak_id, tanggal_ukur],
    );
    return rows[0]?.berat_badan ?? null;
};

// =============================================================================
// HITUNG SAW
// =============================================================================

/**
 * Menghitung skor SAW dan menyimpan hasilnya sebagai snapshot ke DB.
 *
 * @param {string} anak_id
 * @param {number} pengukuran_id
 * @param {object} zscores        - { zscore_bbu, zscore_tbu, zscore_bbtb }
 * @param {object} context        - { berat_badan (kg), tanggal_ukur (YYYY-MM-DD) }
 */
export const hitungSAW = async (anak_id, pengukuran_id, zscores, { berat_badan, tanggal_ukur }) => {
    // Hitung delta BB dari pengukuran sebelumnya (null jika pertama kali)
    const prevBB = await getPreviousBB(anak_id, tanggal_ukur);
    const delta_kg = prevBB !== null
        ? parseFloat((berat_badan - prevBB).toFixed(3))
        : null;

    const nilaiNormalisasi = {
        zscore_tbu:  normalisasiZScore(zscores.zscore_tbu),
        zscore_bbu:  normalisasiZScore(zscores.zscore_bbu),
        zscore_bbtb: normalisasiZScore(zscores.zscore_bbtb),
        tren_bb:     normalisasiTrenBB(delta_kg),
    };

    let skor_akhir = 0;
    const detail = [];

    for (const k of KRITERIA) {
        const nilai = nilaiNormalisasi[k.nama_kriteria] ?? 0;
        const bobot = parseFloat(k.bobot);
        const skor = parseFloat((bobot * nilai).toFixed(4));

        skor_akhir += skor;

        detail.push({
            nama_kriteria: k.nama_kriteria,
            bobot,
            nilai: parseFloat(nilai.toFixed(4)),
            skor,
        });
    }

    skor_akhir = parseFloat(skor_akhir.toFixed(4));
    const kategori_risiko = tentukanKategoriRisiko(skor_akhir);

    // Simpan sebagai snapshot — tren_bb (delta_kg) juga disimpan
    // agar getDetailSAW dapat mereproduksi breakdown yang identik
    await db.query(
        `UPDATE pengukuran
        SET skor_saw = ?, kategori_risiko = ?, tren_bb = ?
        WHERE id = ?`,
        [skor_akhir, kategori_risiko, delta_kg, pengukuran_id],
    );

    return { skor_akhir, kategori_risiko, detail };
};

// =============================================================================
// RANKING SAW — Daftar semua anak diurutkan dari risiko tertinggi
// =============================================================================
export const getRankingSAW = async () => {
    const [rows] = await db.query(
        `SELECT
        a.id AS anak_id,
        a.nama AS nama_anak,
        DATE_FORMAT(a.tanggal_lahir,'%Y-%m-%d') AS tanggal_lahir,
        a.jenis_kelamin,
        ot.nama_lengkap AS nama_orang_tua,
        ot.no_hp AS no_hp_orang_tua,
        p.skor_saw AS skor_akhir,
        p.kategori_risiko,
        p.created_at AS calculated_at,
        DATE_FORMAT(p.tanggal_ukur,'%Y-%m-%d') AS tanggal_ukur,
        p.berat_badan,
        p.tinggi_badan,
        p.status_gizi
        FROM anak a
        JOIN orang_tua ot ON ot.id = a.orang_tua_id
        JOIN pengukuran p ON p.id = (
            SELECT p2.id FROM pengukuran p2
            WHERE p2.anak_id = a.id
            ORDER BY p2.tanggal_ukur DESC
            LIMIT 1
        )
        WHERE p.skor_saw IS NOT NULL
        ORDER BY p.skor_saw DESC`,
    );
    return rows.map((row) => ({
        ...row,
        skor_akhir: parseFloat(row.skor_akhir),
        berat_badan: parseFloat(row.berat_badan),
        tinggi_badan: parseFloat(row.tinggi_badan),
    }));
};

// =============================================================================
// DETAIL SAW — Breakdown lengkap per pengukuran (menggunakan snapshot tersimpan)
// =============================================================================
export const getDetailSAW = async (pengukuran_id) => {
    const [rows] = await db.query(
        `SELECT
            p.id,
            p.anak_id,
            p.zscore_bbu,
            p.zscore_tbu,
            p.zscore_bbtb,
            p.tren_bb,
            p.skor_saw,
            p.kategori_risiko
        FROM pengukuran p
        WHERE p.id = ?`,
        [pengukuran_id],
    );

    if (!rows[0]) return null;

    const p = rows[0];

    if (p.skor_saw === null || p.kategori_risiko === null) return null;

    // Gunakan nilai tersimpan (snapshot) — bukan hitung ulang
    // Menjamin detail selalu konsisten dengan skor_akhir di DB
    const nilaiNormalisasi = {
        zscore_tbu:  normalisasiZScore(parseFloat(p.zscore_tbu)),
        zscore_bbu:  normalisasiZScore(parseFloat(p.zscore_bbu)),
        zscore_bbtb: normalisasiZScore(parseFloat(p.zscore_bbtb)),
        tren_bb:     normalisasiTrenBB(p.tren_bb !== null ? parseFloat(p.tren_bb) : null),
    };

    const detail = KRITERIA.map((k) => {
        const nilai = nilaiNormalisasi[k.nama_kriteria] ?? 0;
        const bobot = parseFloat(k.bobot);
        return {
            nama_kriteria: k.nama_kriteria,
            bobot,
            nilai: parseFloat(nilai.toFixed(4)),
            skor: parseFloat((bobot * nilai).toFixed(4)),
        };
    });

    return {
        pengukuran_id: p.id,
        anak_id: p.anak_id,
        skor_akhir: parseFloat(p.skor_saw),
        kategori_risiko: p.kategori_risiko,
        detail,
    };
};
