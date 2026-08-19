// =============================================================================
// SAW SERVICE — Pure Functions (3NF: tidak menulis ke database)
// Semua fungsi bersifat stateless, menerima input dan mengembalikan output.
// =============================================================================

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
export const normalisasiZScore = (zscore) => {
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
export const normalisasiTrenBB = (delta_kg) => {
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

export const tentukanKategoriRisiko = (skor_akhir) => {
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
export const KRITERIA = [
    { nama_kriteria: "zscore_tbu",  bobot: 0.40 },
    { nama_kriteria: "zscore_bbu",  bobot: 0.25 },
    { nama_kriteria: "zscore_bbtb", bobot: 0.20 },
    { nama_kriteria: "tren_bb",     bobot: 0.15 },
];

// =============================================================================
// HITUNG SAW — Pure function, tidak menulis ke database
// =============================================================================

/**
 * Menghitung skor SAW dari z-scores dan tren BB.
 * Pure function: input → output, tanpa side effect.
 *
 * @param {object} zscores    - { zscore_bbu, zscore_tbu, zscore_bbtb }
 * @param {number|null} tren_bb_kg - Selisih BB dalam kg (null jika pengukuran pertama)
 * @returns {{ skor_akhir: number, kategori_risiko: string, detail: Array }}
 */
export const hitungSAW = (zscores, tren_bb_kg) => {
    const nilaiNormalisasi = {
        zscore_tbu:  normalisasiZScore(zscores.zscore_tbu),
        zscore_bbu:  normalisasiZScore(zscores.zscore_bbu),
        zscore_bbtb: normalisasiZScore(zscores.zscore_bbtb),
        tren_bb:     normalisasiTrenBB(tren_bb_kg),
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

    return { skor_akhir, kategori_risiko, detail };
};
