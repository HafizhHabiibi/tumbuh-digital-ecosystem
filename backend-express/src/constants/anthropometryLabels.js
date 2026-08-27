export const LABEL_STATUS_TBU = Object.freeze({
    sangat_pendek: "sangat pendek untuk usianya",
    pendek: "lebih pendek dari rata-rata untuk usianya",
    normal: "memiliki tinggi badan yang sesuai dengan usianya",
    tinggi: "lebih tinggi dari rata-rata untuk usianya",
});

export const LABEL_STATUS_BBU = Object.freeze({
    berat_badan_sangat_kurang: "berat badan sangat kurang",
    berat_badan_kurang: "berat badan kurang",
    berat_badan_normal: "berat badan normal",
    risiko_berat_badan_lebih: "berisiko berat badan lebih",
});

export const LABEL_STATUS_PROPORSI = Object.freeze({
    gizi_buruk: "gizi buruk",
    gizi_kurang: "gizi kurang",
    gizi_baik: "gizi baik",
    risiko_gizi_lebih: "berisiko gizi lebih",
    gizi_lebih: "gizi lebih",
    obesitas: "obesitas",
});

export const labelStatusAntropometri = (indeks, status) => {
    if (indeks === "bbu") return LABEL_STATUS_BBU[status] || status;
    if (indeks === "tbu") return LABEL_STATUS_TBU[status] || status;
    return LABEL_STATUS_PROPORSI[status] || status;
};
