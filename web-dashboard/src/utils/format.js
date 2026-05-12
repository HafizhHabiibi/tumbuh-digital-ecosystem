// Format tanggal ke bahasa Indonesia
// Input: "2025-01-15" atau Date object
// Output: "15 Januari 2025"
export const formatTanggal = (tanggal) => {
    if (!tanggal) return "-";
    return new Date(tanggal).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
    });
};

// Hitung usia dari tanggal lahir
// Output: "2 tahun 3 bulan"
export const hitungUsia = (tanggalLahir) => {
    if (!tanggalLahir) return "-";
    const lahir = new Date(tanggalLahir);
    const now = new Date();

    let tahun = now.getFullYear() - lahir.getFullYear();
    let bulan = now.getMonth() - lahir.getMonth();

    if (bulan < 0) {
        tahun--;
        bulan += 12;
    }

    if (tahun === 0) return `${bulan} bulan`;
    if (bulan === 0) return `${tahun} tahun`;
    return `${tahun} tahun ${bulan} bulan`;
};

// Hitung usia dalam bulan saja
export const hitungUsiaBulan = (tanggalLahir) => {
    if (!tanggalLahir) return 0;
    const lahir = new Date(tanggalLahir);
    const now = new Date();
    return (
        (now.getFullYear() - lahir.getFullYear()) * 12 +
        (now.getMonth() - lahir.getMonth())
    );
};

// Warna berdasarkan kategori risiko SAW
export const warnakategoriRisiko = (kategori) => {
    const map = {
        tinggi: "text-red-600 bg-red-100",
        sedang: "text-orange-600 bg-orange-100",
        rendah: "text-green-600 bg-green-100",
    };
    return map[kategori] || "text-gray-600 bg-gray-100";
};

// Warna berdasarkan status gizi
export const warnaStatusGizi = (status) => {
    const map = {
        normal: "text-green-600 bg-green-100",
        kurang: "text-yellow-600 bg-yellow-100",
        buruk: "text-red-600 bg-red-100",
        lebih: "text-orange-600 bg-orange-100",
    };
    return map[status] || "text-gray-600 bg-gray-100";
};

// Format angka desimal
export const formatAngka = (angka, desimal = 2) => {
    if (angka === null || angka === undefined) return "-";
    return parseFloat(angka).toFixed(desimal);
};
