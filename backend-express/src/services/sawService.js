// SAW dipakai untuk mengurutkan prioritas pemantauan, bukan untuk diagnosis.
// Z-score terlebih dahulu diubah menjadi nilai perhatian 0-1. Setelah
// transformasi, semua kriteria menjadi benefit: nilai lebih besar berarti
// prioritas pemantauan lebih tinggi.

export const normalisasiPrioritasZScore = (zscore) => {
    const nilai = Number(zscore);
    if (!Number.isFinite(nilai)) {
        throw new TypeError("Z-score SAW harus berupa angka yang valid");
    }
    return Math.max(0, Math.min(1, -nilai / 3));
};

export const tentukanKategoriPrioritas = (skorAkhir) => {
    if (skorAkhir > 0.6667) return "tinggi";
    if (skorAkhir > 0.3333) return "sedang";
    return "rendah";
};

// Bobot diadopsi dari dua penelitian SAW sejenis yang memperoleh penilaian
// kriteria melalui tenaga puskesmas/bidan. Bobot hanya dipakai untuk ranking.
export const KRITERIA = Object.freeze([
    Object.freeze({ nama_kriteria: "zscore_bbu", bobot: 0.25 }),
    Object.freeze({ nama_kriteria: "zscore_tbu", bobot: 0.30 }),
    Object.freeze({ nama_kriteria: "zscore_bbtb", bobot: 0.25 }),
    Object.freeze({ nama_kriteria: "zscore_imtu", bobot: 0.20 }),
]);

const totalBobot = KRITERIA.reduce((total, kriteria) => total + kriteria.bobot, 0);
if (Math.abs(totalBobot - 1) > Number.EPSILON) {
    throw new Error("Total bobot SAW harus sama dengan 1");
}

export const hitungSAW = (zscores) => {
    let skorAkhir = 0;
    const detail = [];

    for (const kriteria of KRITERIA) {
        const nilai = normalisasiPrioritasZScore(zscores[kriteria.nama_kriteria]);
        const skor = kriteria.bobot * nilai;
        skorAkhir += skor;

        detail.push({
            nama_kriteria: kriteria.nama_kriteria,
            bobot: kriteria.bobot,
            nilai: parseFloat(nilai.toFixed(4)),
            skor: parseFloat(skor.toFixed(4)),
        });
    }

    skorAkhir = parseFloat(skorAkhir.toFixed(4));
    return {
        skor_akhir: skorAkhir,
        kategori_prioritas: tentukanKategoriPrioritas(skorAkhir),
        detail,
    };
};
