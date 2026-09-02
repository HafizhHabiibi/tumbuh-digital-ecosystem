// Prioritas pemantauan melengkapi prioritas SAW dengan batas minimum dari
// kategori antropometri. Layanan ini bukan diagnosis dan tidak membuat
// keputusan rujukan otomatis.

const TINGKAT_PRIORITAS = Object.freeze({
    rendah: 1,
    sedang: 2,
    tinggi: 3,
});

const ATURAN_BBU = Object.freeze({
    berat_badan_sangat_kurang: Object.freeze({
        kategori: "tinggi",
        alasan: "bbu_berat_badan_sangat_kurang",
    }),
    berat_badan_kurang: Object.freeze({
        kategori: "sedang",
        alasan: "bbu_berat_badan_kurang",
    }),
    berat_badan_normal: null,
    // BB/U tidak dapat mengklasifikasikan kelebihan berat badan secara mandiri.
    risiko_berat_badan_lebih: null,
});

const ATURAN_TBU = Object.freeze({
    sangat_pendek: Object.freeze({
        kategori: "tinggi",
        alasan: "tbu_sangat_pendek",
    }),
    pendek: Object.freeze({
        kategori: "sedang",
        alasan: "tbu_pendek",
    }),
    normal: null,
    // TB/U tinggi bukan indikator obesitas.
    tinggi: null,
});

const buatAturanProporsi = (prefix) => Object.freeze({
    gizi_buruk: Object.freeze({
        kategori: "tinggi",
        alasan: `${prefix}_gizi_buruk`,
    }),
    gizi_kurang: Object.freeze({
        kategori: "sedang",
        alasan: `${prefix}_gizi_kurang`,
    }),
    gizi_baik: null,
    risiko_gizi_lebih: Object.freeze({
        kategori: "sedang",
        alasan: `${prefix}_risiko_gizi_lebih`,
    }),
    gizi_lebih: Object.freeze({
        kategori: "sedang",
        alasan: `${prefix}_gizi_lebih`,
    }),
    obesitas: Object.freeze({
        kategori: "tinggi",
        alasan: `${prefix}_obesitas`,
    }),
});

const ATURAN_PER_INDEKS = Object.freeze([
    Object.freeze({ field: "status_bbu", aturan: ATURAN_BBU }),
    Object.freeze({ field: "status_tbu", aturan: ATURAN_TBU }),
    Object.freeze({ field: "status_bbtb", aturan: buatAturanProporsi("bbtb") }),
    Object.freeze({ field: "status_imtu", aturan: buatAturanProporsi("imtu") }),
]);

const requiredObject = (value) => {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
        throw new TypeError("Input prioritas pemantauan harus berupa object");
    }
    return value;
};

const requiredPrioritas = (value, field) => {
    if (!Object.hasOwn(TINGKAT_PRIORITAS, value)) {
        throw new TypeError(`${field} tidak valid`);
    }
    return value;
};

const requiredStatus = (value, field, aturan) => {
    if (!Object.hasOwn(aturan, value)) {
        throw new TypeError(`${field} tidak valid`);
    }
    return value;
};

export const tentukanPrioritasMinimumAntropometri = (input) => {
    const data = requiredObject(input);
    let kategori = null;
    const alasan = [];

    for (const { field, aturan } of ATURAN_PER_INDEKS) {
        const status = requiredStatus(data[field], field, aturan);
        const hasil = aturan[status];
        if (!hasil) continue;

        alasan.push(hasil.alasan);
        if (
            kategori === null ||
            TINGKAT_PRIORITAS[hasil.kategori] > TINGKAT_PRIORITAS[kategori]
        ) {
            kategori = hasil.kategori;
        }
    }

    return { kategori, alasan };
};

export const gabungkanPrioritasPemantauan = (input) => {
    const data = requiredObject(input);
    const kategoriSaw = requiredPrioritas(
        data.kategori_prioritas_saw,
        "kategori_prioritas_saw",
    );
    const antropometri = tentukanPrioritasMinimumAntropometri(data);

    if (antropometri.kategori === null) {
        return {
            kategori: kategoriSaw,
            sumber_utama: "saw",
            alasan: antropometri.alasan,
        };
    }

    const tingkatSaw = TINGKAT_PRIORITAS[kategoriSaw];
    const tingkatAntropometri = TINGKAT_PRIORITAS[antropometri.kategori];

    if (tingkatAntropometri > tingkatSaw) {
        return {
            kategori: antropometri.kategori,
            sumber_utama: "antropometri",
            alasan: antropometri.alasan,
        };
    }

    if (tingkatAntropometri === tingkatSaw) {
        return {
            kategori: kategoriSaw,
            sumber_utama: "gabungan",
            alasan: antropometri.alasan,
        };
    }

    return {
        kategori: kategoriSaw,
        sumber_utama: "saw",
        alasan: antropometri.alasan,
    };
};
