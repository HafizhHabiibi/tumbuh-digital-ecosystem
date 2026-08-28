export const LABEL_STATUS_ANTROPOMETRI = Object.freeze({
    berat_badan_sangat_kurang: "Berat badan sangat kurang",
    berat_badan_kurang: "Berat badan kurang",
    berat_badan_normal: "Berat badan normal",
    risiko_berat_badan_lebih: "Risiko berat badan lebih",
    sangat_pendek: "Sangat pendek",
    pendek: "Pendek",
    normal: "Normal",
    tinggi: "Tinggi",
    gizi_buruk: "Gizi buruk",
    gizi_kurang: "Gizi kurang",
    gizi_baik: "Gizi baik",
    risiko_gizi_lebih: "Risiko gizi lebih",
    gizi_lebih: "Gizi lebih",
    obesitas: "Obesitas",
});

export const VARIANT_STATUS_ANTROPOMETRI = Object.freeze({
    berat_badan_sangat_kurang: "red",
    berat_badan_kurang: "yellow",
    berat_badan_normal: "green",
    risiko_berat_badan_lebih: "blue",
    sangat_pendek: "red",
    pendek: "yellow",
    normal: "green",
    tinggi: "blue",
    gizi_buruk: "red",
    gizi_kurang: "yellow",
    gizi_baik: "green",
    risiko_gizi_lebih: "yellow",
    gizi_lebih: "blue",
    obesitas: "red",
});

export const formatStatusAntropometri = (status) =>
    LABEL_STATUS_ANTROPOMETRI[status] ?? status?.replaceAll("_", " ") ?? "—";
