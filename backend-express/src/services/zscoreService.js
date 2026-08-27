import { fileURLToPath } from "url";
import { dirname, join } from "path";
import fs from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const WHO = JSON.parse(
    fs.readFileSync(join(__dirname, "../constants/whoTables.json"), "utf8"),
);

export class ZScoreValidationError extends Error {
    constructor(message) {
        super(message);
        this.name = "ZScoreValidationError";
    }
}

const parseTanggal = (value, fieldName) => {
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
        return new Date(Date.UTC(
            value.getFullYear(),
            value.getMonth(),
            value.getDate(),
        ));
    }

    if (typeof value !== "string") {
        throw new ZScoreValidationError(`${fieldName} tidak valid`);
    }

    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
    if (!match) {
        throw new ZScoreValidationError(
            `${fieldName} harus berformat YYYY-MM-DD`,
        );
    }

    const [, yearText, monthText, dayText] = match;
    const year = Number(yearText);
    const month = Number(monthText);
    const day = Number(dayText);
    const date = new Date(Date.UTC(year, month - 1, day));
    if (
        date.getUTCFullYear() !== year ||
        date.getUTCMonth() !== month - 1 ||
        date.getUTCDate() !== day
    ) {
        throw new ZScoreValidationError(`${fieldName} bukan tanggal kalender yang valid`);
    }
    return date;
};

const startOfTodayUtc = () => {
    const now = new Date();
    return new Date(Date.UTC(
        now.getFullYear(),
        now.getMonth(),
        now.getDate(),
    ));
};

const nilaiPadaZScore = (z, L, M, S) => {
    if (L === 0) {
        return M * Math.exp(S * z);
    }
    return M * Math.pow(1 + L * S * z, 1 / L);
};

// WHO menggunakan LMS langsung pada rentang -3 sampai +3 SD. Untuk nilai
// ekstrem, z-score diekstrapolasi secara linear dari jarak antara SD2 dan SD3.
const hitungZScore = (nilai, L, M, S) => {
    const zLms = L === 0
        ? Math.log(nilai / M) / S
        : (Math.pow(nilai / M, L) - 1) / (L * S);

    if (zLms > 3) {
        const sd2 = nilaiPadaZScore(2, L, M, S);
        const sd3 = nilaiPadaZScore(3, L, M, S);
        return 3 + (nilai - sd3) / (sd3 - sd2);
    }
    if (zLms < -3) {
        const sdNeg2 = nilaiPadaZScore(-2, L, M, S);
        const sdNeg3 = nilaiPadaZScore(-3, L, M, S);
        return -3 + (nilai - sdNeg3) / (sdNeg2 - sdNeg3);
    }
    return zLms;
};

export const hitungUsiaBulan = (tanggal_lahir, tanggal_ukur) => {
    const lahir = parseTanggal(tanggal_lahir, "tanggal_lahir");
    const ukur = parseTanggal(tanggal_ukur, "tanggal_ukur");

    let bulan =
        (ukur.getUTCFullYear() - lahir.getUTCFullYear()) * 12 +
        (ukur.getUTCMonth() - lahir.getUTCMonth());
    if (ukur.getUTCDate() < lahir.getUTCDate()) {
        bulan--;
    }
    return Math.max(0, bulan);
};

export const hitungUsiaHari = (tanggal_lahir, tanggal_ukur) => {
    const lahir = parseTanggal(tanggal_lahir, "tanggal_lahir");
    const ukur = parseTanggal(tanggal_ukur, "tanggal_ukur");
    return Math.floor((ukur - lahir) / (1000 * 60 * 60 * 24));
};

const genderKey = (jenisKelamin) => jenisKelamin === "L" ? "boys" : "girls";

// WHO Expanded Tables berurutan dari day 0, sehingga akses indeks memberi
// lookup O(1). Pemeriksaan day tetap dipertahankan agar format data tervalidasi.
const cariLMSHarian = (table, usiaHari) => {
    const candidate = table[usiaHari];
    if (candidate?.day === usiaHari) return candidate;
    return table.find((row) => row.day === usiaHari) || null;
};

const hitungZScoreBBU = (berat_badan, usia_hari, gender) => {
    const table = WHO[`wfa_${gender}`];
    if (!table) throw new ZScoreValidationError("Referensi BB/U tidak tersedia");

    const lms = cariLMSHarian(table, usia_hari);
    if (!lms) throw new ZScoreValidationError("Usia di luar referensi BB/U WHO");

    return hitungZScore(berat_badan, lms.L, lms.M, lms.S);
};

const hitungZScoreTBU = (tinggi_badan, usia_hari, gender) => {
    const table = WHO[`lhfa_${gender}`];
    if (!table) throw new ZScoreValidationError("Referensi TB/U tidak tersedia");

    const lms = cariLMSHarian(table, usia_hari);
    if (!lms) throw new ZScoreValidationError("Usia di luar referensi TB/U WHO");

    return hitungZScore(tinggi_badan, lms.L, lms.M, lms.S);
};

const hitungZScoreIMTU = (imt, usia_hari, gender) => {
    const table = WHO[`bfa_${gender}`];
    if (!table) throw new ZScoreValidationError("Referensi IMT/U tidak tersedia");

    const lms = cariLMSHarian(table, usia_hari);
    if (!lms) throw new ZScoreValidationError("Usia di luar referensi IMT/U WHO");

    return hitungZScore(imt, lms.L, lms.M, lms.S);
};

const hitungZScoreBBTB = (berat_badan, tinggi_badan, usia_hari, gender) => {
    // WHO menggunakan panjang badan telentang sebelum usia 24 bulan dan tinggi
    // badan berdiri mulai usia 24 bulan. Day 731 adalah batas tabel expanded.
    const gunakanPanjang = usia_hari < 731;
    const key = gunakanPanjang ? `wfl_${gender}` : `wfh_${gender}`;
    const kolomRef = gunakanPanjang ? "length" : "height";
    const table = WHO[key];
    if (!table) throw new ZScoreValidationError("Referensi BB/TB tidak tersedia");

    const nilaiReferensi = table.map((row) => row[kolomRef]);
    const minTinggi = nilaiReferensi[0];
    const maxTinggi = nilaiReferensi[nilaiReferensi.length - 1];
    if (tinggi_badan < minTinggi || tinggi_badan > maxTinggi) {
        throw new ZScoreValidationError(
            `Tinggi/panjang badan di luar referensi WHO (${minTinggi}-${maxTinggi} cm)`,
        );
    }

    const tinggiRounded = Math.round(tinggi_badan * 10) / 10;

    let lms = table.find((row) => row[kolomRef] === tinggiRounded);

    if (!lms) {
        let closest = null;
        let minDiff = Infinity;
        for (const row of table) {
            const diff = Math.abs(row[kolomRef] - tinggiRounded);
            if (diff < minDiff) {
                minDiff = diff;
                closest = row;
            }
        }
        lms = closest;
    }
    if (!lms) throw new ZScoreValidationError("Referensi BB/TB tidak ditemukan");
    return hitungZScore(berat_badan, lms.L, lms.M, lms.S);
};

export const statusBBU = (z) => {
    if (z < -3) return "berat_badan_sangat_kurang";
    if (z < -2) return "berat_badan_kurang";
    if (z <= 1) return "berat_badan_normal";
    return "risiko_berat_badan_lebih";
};

export const statusTBU = (z) => {
    if (z < -3) return "sangat_pendek";
    if (z < -2) return "pendek";
    if (z <= 3) return "normal";
    return "tinggi";
};

export const statusBBTBdanIMTU = (z) => {
    if (z < -3) return "gizi_buruk";
    if (z < -2) return "gizi_kurang";
    if (z <= 1) return "gizi_baik";
    if (z <= 2) return "risiko_gizi_lebih";
    if (z <= 3) return "gizi_lebih";
    return "obesitas";
};

export const hitungSemuaZScore = (data) => {
    const {
        berat_badan,
        tinggi_badan,
        tanggal_lahir,
        tanggal_ukur,
        jenis_kelamin,
    } = data;

    const berat = Number(berat_badan);
    const tinggi = Number(tinggi_badan);
    if (!Number.isFinite(berat) || berat <= 0) {
        throw new ZScoreValidationError("Berat badan harus berupa angka positif");
    }
    if (!Number.isFinite(tinggi) || tinggi <= 0) {
        throw new ZScoreValidationError("Tinggi badan harus berupa angka positif");
    }
    if (!["L", "P"].includes(jenis_kelamin)) {
        throw new ZScoreValidationError("Jenis kelamin harus L atau P");
    }

    const lahir = parseTanggal(tanggal_lahir, "tanggal_lahir");
    const ukur = parseTanggal(tanggal_ukur, "tanggal_ukur");
    if (ukur < lahir) {
        throw new ZScoreValidationError("Tanggal ukur tidak boleh sebelum tanggal lahir");
    }
    if (ukur > startOfTodayUtc()) {
        throw new ZScoreValidationError("Tanggal ukur tidak boleh di masa depan");
    }

    const gender = genderKey(jenis_kelamin);
    const usia_bulan = hitungUsiaBulan(tanggal_lahir, tanggal_ukur);
    const usia_hari = hitungUsiaHari(tanggal_lahir, tanggal_ukur);

    const maxUsiaHari = WHO[`wfa_${gender}`]?.at(-1)?.day;
    if (!Number.isInteger(maxUsiaHari) || usia_hari > maxUsiaHari) {
        throw new ZScoreValidationError(
            "Usia anak di luar rentang WHO yang didukung (0-1856 hari)",
        );
    }

    const zscore_bbu = hitungZScoreBBU(berat, usia_hari, gender);
    const zscore_tbu = hitungZScoreTBU(tinggi, usia_hari, gender);
    const zscore_bbtb = hitungZScoreBBTB(
        berat,
        tinggi,
        usia_hari,
        gender,
    );
    const nilai_imt = berat / Math.pow(tinggi / 100, 2);
    const zscore_imtu = hitungZScoreIMTU(nilai_imt, usia_hari, gender);

    return {
        usia_bulan,
        usia_hari,
        nilai_imt: parseFloat(nilai_imt.toFixed(2)),
        zscore_bbu: parseFloat(zscore_bbu.toFixed(3)),
        zscore_tbu: parseFloat(zscore_tbu.toFixed(3)),
        zscore_bbtb: parseFloat(zscore_bbtb.toFixed(3)),
        zscore_imtu: parseFloat(zscore_imtu.toFixed(3)),

        status_bbu: statusBBU(zscore_bbu),
        status_tbu: statusTBU(zscore_tbu),
        status_bbtb: statusBBTBdanIMTU(zscore_bbtb),
        status_imtu: statusBBTBdanIMTU(zscore_imtu),
    };
};
