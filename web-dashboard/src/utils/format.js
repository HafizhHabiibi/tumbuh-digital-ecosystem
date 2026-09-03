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
// Output: "8 bulan" | "1 tahun 3 bulan" | "2 tahun"
// Ambang batas: < 12 bulan → tampil "X bulan", >= 12 bulan → tampil "X tahun Y bulan"
export const hitungUsia = (tanggalLahir) => {
    if (!tanggalLahir) return "-";
    const lahir = new Date(tanggalLahir);
    const now = new Date();

    let tahun = now.getFullYear() - lahir.getFullYear();
    let bulan = now.getMonth() - lahir.getMonth();

    // Koreksi hari: jika hari ini belum sampai hari lahir di bulan ini
    if (now.getDate() < lahir.getDate()) {
        bulan--;
    }

    if (bulan < 0) {
        tahun--;
        bulan += 12;
    }

    const totalBulan = tahun * 12 + bulan;
    if (totalBulan < 12) return `${totalBulan} bulan`;
    if (bulan === 0) return `${tahun} tahun`;
    return `${tahun} tahun ${bulan} bulan`;
};

// Hitung usia dalam bulan saja (day-corrected)
export const hitungUsiaBulan = (tanggalLahir) => {
    if (!tanggalLahir) return 0;
    const lahir = new Date(tanggalLahir);
    const now = new Date();

    let tahun = now.getFullYear() - lahir.getFullYear();
    let bulan = now.getMonth() - lahir.getMonth();

    if (now.getDate() < lahir.getDate()) {
        bulan--;
    }
    if (bulan < 0) {
        tahun--;
        bulan += 12;
    }

    return tahun * 12 + bulan;
};

// Konversi Date object → "YYYY-MM-DD" menggunakan LOCAL timezone (bukan UTC)
// Gunakan ini sebagai pengganti .toISOString().split("T")[0] yang menghasilkan
// tanggal UTC dan bisa off-by-one di WIB (UTC+7) saat tengah malam.
export const toLocalDateStr = (date) => {
    if (!date) return "";
    const d = date instanceof Date ? date : new Date(date);
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${y}-${m}-${day}`;
};

// Format angka desimal
export const formatAngka = (angka, desimal = 2) => {
    if (angka === null || angka === undefined) return "-";
    return parseFloat(angka).toFixed(desimal);
};

const measurementNumberFormatter = new Intl.NumberFormat("id-ID", {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
    useGrouping: false,
});

export const formatUkuran = (angka) => {
    if (angka === null || angka === undefined || angka === "") return "—";
    const numeric = Number(angka);
    return Number.isFinite(numeric)
        ? measurementNumberFormatter.format(numeric)
        : "—";
};

const measurementUnits = Object.freeze({
    berat: "kg",
    panjang: "cm",
    imt: "kg/m²",
});

export const formatUkuranDenganSatuan = (angka, jenis) => {
    const unit = measurementUnits[jenis];
    if (!unit) throw new TypeError("Jenis satuan ukuran tidak valid");
    const formatted = formatUkuran(angka);
    return formatted === "—" ? formatted : `${formatted} ${unit}`;
};
