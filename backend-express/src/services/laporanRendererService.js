import {
    buatDokumenPdf,
    finalisasiPdf,
    pastikanRuang,
    tulisBadge,
    tulisHeaderLaporan,
    tulisJudulBagian,
    tulisKartuRingkasan,
    tulisTabel,
    WARNA_LAPORAN,
} from "./laporanPdfService.js";
import { JENIS_LAPORAN } from "./laporanService.js";

const BULAN = [
    "Januari", "Februari", "Maret", "April", "Mei", "Juni",
    "Juli", "Agustus", "September", "Oktober", "November", "Desember",
];

const LABEL_STATUS = Object.freeze({
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

const LABEL_KRITERIA = Object.freeze({
    zscore_bbu: "BB/U",
    zscore_tbu: "TB/U",
    zscore_bbtb: "BB/TB",
    zscore_imtu: "IMT/U",
});

const LABEL_INDEKS = Object.freeze({
    bbu: "BB/U",
    tbu: "TB/U",
    bbtb: "BB/TB",
    imtu: "IMT/U",
});

export class LaporanRendererError extends Error {
    constructor(message) {
        super(message);
        this.name = "LaporanRendererError";
    }
}

const teksAman = (value) => String(value ?? "-")
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
    .trim() || "-";

const formatTanggal = (value, denganWaktu = false) => {
    if (typeof value === "string") {
        const tanggalSaja = /^(\d{4})-(\d{2})-(\d{2})/.exec(value);
        if (tanggalSaja && !denganWaktu) {
            const [, tahun, bulan, tanggal] = tanggalSaja;
            return `${Number(tanggal)} ${BULAN[Number(bulan) - 1]} ${tahun}`;
        }
    }

    const date = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(date.getTime())) return "-";
    return new Intl.DateTimeFormat("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
        ...(denganWaktu ? { hour: "2-digit", minute: "2-digit" } : {}),
        timeZone: "Asia/Jakarta",
    }).format(date);
};

const formatAngka = (value, maksimumDesimal = 2) => {
    const angka = Number(value);
    if (!Number.isFinite(angka)) return "-";
    return new Intl.NumberFormat("id-ID", {
        maximumFractionDigits: maksimumDesimal,
    }).format(angka);
};

const formatUsia = (bulan, hari) => {
    if (Number.isFinite(Number(bulan))) return `${Number(bulan)} bulan`;
    if (Number.isFinite(Number(hari))) return `${Number(hari)} hari`;
    return "-";
};

const formatJenisKelamin = (value) => value === "L"
    ? "Laki-laki"
    : value === "P" ? "Perempuan" : "-";

const labelStatus = (kode) => LABEL_STATUS[kode] || teksAman(kode);
const kapital = (value) => {
    const text = teksAman(value);
    return text === "-" ? text : text.charAt(0).toUpperCase() + text.slice(1);
};

const pastikanJenis = (laporan, jenis) => {
    if (laporan?.metadata?.jenis_laporan !== jenis) {
        throw new LaporanRendererError(
            `Kontrak laporan tidak sesuai untuk renderer ${jenis}`,
        );
    }
};

const buatHeader = (laporan, subjudul) => (doc) => tulisHeaderLaporan(doc, {
    nama_posyandu: laporan.metadata.nama_posyandu,
    nama_puskesmas: laporan.metadata.nama_puskesmas,
    judul: laporan.metadata.judul,
    subjudul,
});

const tulisInformasi = (doc, items, saatHalamanBaru) => {
    tulisTabel(doc, {
        columns: [
            { key: "label", label: "Informasi", width: 120 },
            { key: "nilai", label: "Keterangan", width: 379 },
        ],
        rows: items.map(({ label, nilai }) => ({
            label,
            nilai: teksAman(nilai),
        })),
        saatHalamanBaru,
    });
};

const tulisCatatan = (doc, { judul, isi, kategori = "rendah" }, saatHalamanBaru) => {
    doc.font("Helvetica").fontSize(9);
    const lebar = 499;
    const tinggiIsi = doc.heightOfString(teksAman(isi), { width: lebar - 28 });
    const tinggi = Math.max(68, tinggiIsi + 42);
    pastikanRuang(doc, tinggi + 10, saatHalamanBaru);
    const x = doc.page.margins.left;
    const y = doc.y;
    const warna = WARNA_LAPORAN[kategori] || WARNA_LAPORAN.utama;

    doc.save()
        .fillColor(WARNA_LAPORAN.latarBaris)
        .strokeColor(warna)
        .lineWidth(1)
        .roundedRect(x, y, lebar, tinggi, 6)
        .fillAndStroke()
        .restore();
    doc.font("Helvetica-Bold")
        .fontSize(10)
        .fillColor(warna)
        .text(teksAman(judul), x + 14, y + 12, { width: lebar - 28 });
    doc.font("Helvetica")
        .fontSize(9)
        .fillColor(WARNA_LAPORAN.teks)
        .text(teksAman(isi), x + 14, y + 31, { width: lebar - 28 });
    doc.x = x;
    doc.y = y + tinggi + 12;
};

const tulisMetadataPembuatan = (doc, laporan, saatHalamanBaru) => {
    pastikanRuang(doc, 34, saatHalamanBaru);
    doc.font("Helvetica")
        .fontSize(8)
        .fillColor(WARNA_LAPORAN.teksSekunder)
        .text(
            `Dibuat ${formatTanggal(laporan.metadata.dibuat_pada, true)} oleh ${teksAman(laporan.metadata.dibuat_oleh)}.`,
            { align: "right" },
        );
};

const statusIndividualKeBaris = (status) => [
    { indeks: "BB/U", status: status.bbu.label, zscore: status.bbu.zscore },
    { indeks: "TB/U", status: status.tbu.label, zscore: status.tbu.zscore },
    { indeks: "BB/TB", status: status.bbtb.label, zscore: status.bbtb.zscore },
    { indeks: "IMT/U", status: status.imtu.label, zscore: status.imtu.zscore },
];

export const renderLaporanIndividualOrangTua = async (laporan) => {
    pastikanJenis(laporan, JENIS_LAPORAN.INDIVIDUAL_ORANG_TUA);
    const doc = buatDokumenPdf({
        judul: laporan.metadata.judul,
        pembuat: laporan.metadata.dibuat_oleh,
    });
    const header = buatHeader(
        laporan,
        `Hasil terakhir ${formatTanggal(laporan.pengukuran_terakhir.tanggal_ukur)}`,
    );
    header(doc);

    tulisJudulBagian(doc, "Identitas Anak", { saatHalamanBaru: header });
    tulisInformasi(doc, [
        { label: "Nama anak", nilai: laporan.anak.nama },
        { label: "NIK", nilai: laporan.anak.nik || "Tidak dicantumkan" },
        { label: "Jenis kelamin", nilai: formatJenisKelamin(laporan.anak.jenis_kelamin) },
        { label: "Tanggal lahir", nilai: formatTanggal(laporan.anak.tanggal_lahir) },
        { label: "Orang tua", nilai: laporan.anak.nama_orang_tua },
    ], header);

    const terakhir = laporan.pengukuran_terakhir;
    tulisJudulBagian(doc, "Ringkasan Pengukuran Terakhir", { saatHalamanBaru: header });
    tulisKartuRingkasan(doc, [
        { label: "Berat Badan", nilai: `${formatAngka(terakhir.berat_badan)} kg` },
        { label: "Tinggi Badan", nilai: `${formatAngka(terakhir.tinggi_badan)} cm` },
        { label: "IMT", nilai: formatAngka(terakhir.nilai_imt) },
        { label: "Usia Saat Diukur", nilai: formatUsia(terakhir.usia_bulan, terakhir.usia_hari) },
    ], { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "indeks", label: "Indeks", width: 100 },
            { key: "status", label: "Hasil Pemantauan", width: 399 },
        ],
        rows: statusIndividualKeBaris(terakhir.status),
        saatHalamanBaru: header,
    });

    const prioritas = laporan.prioritas_pemantauan;
    tulisJudulBagian(doc, "Prioritas Pemantauan", { saatHalamanBaru: header });
    pastikanRuang(doc, 34, header);
    tulisBadge(doc, {
        x: doc.page.margins.left,
        y: doc.y,
        teks: prioritas.label,
        kategori: prioritas.kategori,
    });
    doc.y += 32;
    tulisCatatan(doc, {
        judul: "Saran pemantauan",
        isi: prioritas.narasi,
        kategori: prioritas.kategori,
    }, header);

    tulisJudulBagian(doc, "Riwayat Pertumbuhan", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "tanggal", label: "Tanggal", width: 72 },
            { key: "usia", label: "Usia", width: 42 },
            { key: "bb", label: "BB", width: 42, align: "center" },
            { key: "tb", label: "TB", width: 42, align: "center" },
            { key: "bbu", label: "BB/U", width: 80 },
            { key: "tbu", label: "TB/U", width: 60 },
            { key: "bbtb", label: "BB/TB", width: 80 },
            { key: "imtu", label: "IMT/U", width: 80 },
        ],
        rows: laporan.riwayat_pengukuran.map((item) => ({
            tanggal: formatTanggal(item.tanggal_ukur),
            usia: `${item.usia_bulan} bln`,
            bb: `${formatAngka(item.berat_badan)} kg`,
            tb: `${formatAngka(item.tinggi_badan)} cm`,
            bbu: item.status.bbu.label,
            tbu: item.status.tbu.label,
            bbtb: item.status.bbtb.label,
            imtu: item.status.imtu.label,
        })),
        saatHalamanBaru: header,
    });
    tulisCatatan(doc, {
        judul: "Catatan penting",
        isi: `${prioritas.catatan} Hasil pada dokumen ini bukan diagnosis medis.`,
    }, header);
    tulisMetadataPembuatan(doc, laporan, header);

    return finalisasiPdf(doc, {
        teksFooter: "Ringkasan pemantauan pertumbuhan — bukan diagnosis medis",
    });
};

export const renderLaporanIndividualTeknis = async (laporan) => {
    pastikanJenis(laporan, JENIS_LAPORAN.INDIVIDUAL_TEKNIS);
    const doc = buatDokumenPdf({
        judul: laporan.metadata.judul,
        pembuat: laporan.metadata.dibuat_oleh,
    });
    const header = buatHeader(
        laporan,
        `Pengukuran terakhir ${formatTanggal(laporan.pengukuran_terakhir.tanggal_ukur)}`,
    );
    header(doc);

    tulisJudulBagian(doc, "Identitas Anak", { saatHalamanBaru: header });
    tulisInformasi(doc, [
        { label: "Nama anak", nilai: laporan.anak.nama },
        { label: "NIK", nilai: laporan.anak.nik || "Tidak dicantumkan" },
        { label: "Jenis kelamin", nilai: formatJenisKelamin(laporan.anak.jenis_kelamin) },
        { label: "Tanggal lahir", nilai: formatTanggal(laporan.anak.tanggal_lahir) },
        { label: "Orang tua", nilai: laporan.anak.nama_orang_tua },
    ], header);

    const terakhir = laporan.pengukuran_terakhir;
    tulisJudulBagian(doc, "Antropometri Terakhir", { saatHalamanBaru: header });
    tulisKartuRingkasan(doc, [
        { label: "Berat Badan", nilai: `${formatAngka(terakhir.berat_badan)} kg` },
        { label: "Tinggi Badan", nilai: `${formatAngka(terakhir.tinggi_badan)} cm` },
        { label: "IMT", nilai: formatAngka(terakhir.nilai_imt) },
        { label: "Usia", nilai: `${terakhir.usia_hari} hari` },
    ], { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "indeks", label: "Indeks", width: 100 },
            { key: "status", label: "Kategori", width: 299 },
            {
                key: "zscore",
                label: "Z-Score",
                width: 100,
                align: "center",
                format: (value) => formatAngka(value, 3),
            },
        ],
        rows: statusIndividualKeBaris(terakhir.status),
        saatHalamanBaru: header,
    });

    tulisJudulBagian(doc, "Prioritas Pemantauan", {
        saatHalamanBaru: header,
    });
    pastikanRuang(doc, 34, header);
    tulisBadge(doc, {
        x: doc.page.margins.left,
        y: doc.y,
        teks: `Prioritas ${kapital(terakhir.prioritas_pemantauan.kategori)}`,
        kategori: terakhir.prioritas_pemantauan.kategori,
    });
    doc.font("Helvetica-Bold")
        .fontSize(10)
        .fillColor(WARNA_LAPORAN.teks)
        .text(
            `Sumber: ${kapital(terakhir.prioritas_pemantauan.sumber_utama)}`,
            230,
            doc.y + 5,
        );
    doc.y += 34;

    tulisJudulBagian(doc, "SAW Risiko Kekurangan Gizi", {
        saatHalamanBaru: header,
    });
    doc.font("Helvetica-Bold")
        .fontSize(10)
        .fillColor(WARNA_LAPORAN.teks)
        .text(
            `Kategori SAW: ${kapital(terakhir.saw.kategori_prioritas)}  |  ` +
            `Skor: ${formatAngka(terakhir.saw.skor, 4)}`,
        );
    doc.moveDown(0.5);
    tulisTabel(doc, {
        columns: [
            { key: "kriteria", label: "Kriteria", width: 199 },
            { key: "bobot", label: "Bobot", width: 100, align: "center" },
            { key: "nilai", label: "Nilai Normalisasi", width: 100, align: "center" },
            { key: "skor", label: "Kontribusi", width: 100, align: "center" },
        ],
        rows: terakhir.saw.detail.map((item) => ({
            kriteria: LABEL_KRITERIA[item.nama_kriteria] || item.nama_kriteria,
            bobot: formatAngka(item.bobot, 4),
            nilai: formatAngka(item.nilai, 4),
            skor: formatAngka(item.skor, 4),
        })),
        saatHalamanBaru: header,
    });

    tulisJudulBagian(doc, "Riwayat Teknis", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "tanggal", label: "Tanggal", width: 62 },
            { key: "usia", label: "Usia", width: 38 },
            { key: "bb", label: "BB", width: 38 },
            { key: "tb", label: "TB", width: 38 },
            { key: "bbu", label: "Z BB/U", width: 46 },
            { key: "tbu", label: "Z TB/U", width: 46 },
            { key: "bbtb", label: "Z BB/TB", width: 48 },
            { key: "imtu", label: "Z IMT/U", width: 48 },
            { key: "saw", label: "SAW", width: 55 },
            { key: "prioritas", label: "Prioritas", width: 80 },
        ],
        rows: laporan.riwayat_pengukuran.map((item) => ({
            tanggal: formatTanggal(item.tanggal_ukur),
            usia: `${item.usia_bulan} bln`,
            bb: formatAngka(item.berat_badan),
            tb: formatAngka(item.tinggi_badan),
            bbu: formatAngka(item.status.bbu.zscore, 3),
            tbu: formatAngka(item.status.tbu.zscore, 3),
            bbtb: formatAngka(item.status.bbtb.zscore, 3),
            imtu: formatAngka(item.status.imtu.zscore, 3),
            saw: formatAngka(item.saw.skor, 4),
            prioritas: kapital(item.prioritas_pemantauan.kategori),
        })),
        saatHalamanBaru: header,
    });

    tulisJudulBagian(doc, "Riwayat Rujukan", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "tanggal", label: "Tanggal", width: 70 },
            { key: "status", label: "Status", width: 60 },
            { key: "kader", label: "Catatan Kader", width: 115 },
            { key: "puskesmas", label: "Catatan Puskesmas", width: 115 },
            { key: "petugas", label: "Ditangani Oleh", width: 139 },
        ],
        rows: laporan.rujukan.map((item) => ({
            tanggal: formatTanggal(item.tanggal),
            status: kapital(item.status),
            kader: item.catatan_kader,
            puskesmas: item.catatan_puskesmas,
            petugas: item.ditangani_oleh,
        })),
        saatHalamanBaru: header,
        teksKosong: "Belum ada riwayat rujukan.",
    });
    tulisCatatan(doc, {
        judul: "Interpretasi",
        isi: "Z-Score mengikuti referensi pertumbuhan WHO dan kategori antropometri mengikuti ambang Permenkes. SAW hanya digunakan untuk membantu pengurutan prioritas pemantauan, bukan menentukan diagnosis.",
    }, header);
    tulisMetadataPembuatan(doc, laporan, header);

    return finalisasiPdf(doc, {
        teksFooter: "Laporan teknis antropometri — SAW untuk prioritas, bukan diagnosis",
    });
};

const barisDistribusi = (distribusi) => {
    const hasil = [];
    for (const [indeks, kategori] of Object.entries(distribusi)) {
        for (const [kode, jumlah] of Object.entries(kategori)) {
            hasil.push({
                indeks: LABEL_INDEKS[indeks] || indeks.toUpperCase(),
                kategori: labelStatus(kode),
                jumlah,
            });
        }
    }
    return hasil;
};

export const renderLaporanRekapPetugas = async (laporan) => {
    pastikanJenis(laporan, JENIS_LAPORAN.REKAP_PETUGAS);
    const doc = buatDokumenPdf({
        judul: laporan.metadata.judul,
        pembuat: laporan.metadata.dibuat_oleh,
    });
    const periode = `${formatTanggal(laporan.periode.tanggal_mulai)} – ${formatTanggal(laporan.periode.tanggal_selesai)}`;
    const header = buatHeader(laporan, `Periode ${periode}`);
    header(doc);

    tulisJudulBagian(doc, "Ringkasan Periode", { saatHalamanBaru: header });
    tulisKartuRingkasan(doc, [
        { label: "Anak Diukur", nilai: laporan.ringkasan.total_anak },
        { label: "Total Pengukuran", nilai: laporan.ringkasan.total_pengukuran },
        { label: "Rujukan Aktif", nilai: laporan.ringkasan.total_rujukan_aktif },
    ], { saatHalamanBaru: header });
    tulisKartuRingkasan(doc, [
        { label: "Prioritas Rendah", nilai: laporan.distribusi_prioritas.rendah },
        { label: "Prioritas Sedang", nilai: laporan.distribusi_prioritas.sedang },
        { label: "Prioritas Tinggi", nilai: laporan.distribusi_prioritas.tinggi },
    ], { saatHalamanBaru: header });

    tulisJudulBagian(doc, "Distribusi Antropometri", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "indeks", label: "Indeks", width: 70 },
            { key: "kategori", label: "Kategori", width: 300 },
            { key: "jumlah", label: "Jumlah Anak", width: 100, align: "center" },
        ],
        rows: barisDistribusi(laporan.distribusi_antropometri),
        saatHalamanBaru: header,
    });

    tulisJudulBagian(doc, "Daftar Tindak Lanjut", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "nomor", label: "No.", width: 28, align: "center" },
            { key: "anak", label: "Nama Anak", width: 95 },
            { key: "orang_tua", label: "Orang Tua", width: 105 },
            { key: "tanggal", label: "Tanggal Ukur", width: 70 },
            { key: "prioritas", label: "Prioritas Pantau", width: 80 },
            { key: "skor", label: "SAW Kurang Gizi", width: 60, align: "center" },
        ],
        rows: laporan.daftar_prioritas.map((item, index) => ({
            nomor: index + 1,
            anak: item.nama_anak,
            orang_tua: item.nama_orang_tua,
            tanggal: formatTanggal(item.tanggal_ukur),
            prioritas: kapital(item.kategori_prioritas),
            skor: formatAngka(item.skor_saw, 4),
        })),
        saatHalamanBaru: header,
        teksKosong: "Tidak ada anak dengan prioritas sedang atau tinggi pada periode ini.",
    });
    if (laporan.daftar_prioritas.length > 0) {
        tulisTabel(doc, {
            columns: [
                { key: "anak", label: "Nama Anak", width: 110 },
                { key: "bbu", label: "BB/U", width: 100 },
                { key: "tbu", label: "TB/U", width: 85 },
                { key: "bbtb", label: "BB/TB", width: 102 },
                { key: "imtu", label: "IMT/U", width: 102 },
            ],
            rows: laporan.daftar_prioritas.map((item) => ({
                anak: item.nama_anak,
                bbu: labelStatus(item.status_bbu),
                tbu: labelStatus(item.status_tbu),
                bbtb: labelStatus(item.status_bbtb),
                imtu: labelStatus(item.status_imtu),
            })),
            saatHalamanBaru: header,
        });
    }

    tulisJudulBagian(doc, "Rekap Rujukan", { saatHalamanBaru: header });
    tulisKartuRingkasan(doc, [
        { label: "Diajukan", nilai: laporan.rekap_rujukan.diajukan || 0 },
        { label: "Ditangani", nilai: laporan.rekap_rujukan.ditangani || 0 },
        { label: "Selesai", nilai: laporan.rekap_rujukan.selesai || 0 },
    ], { saatHalamanBaru: header });
    tulisCatatan(doc, {
        judul: "Keterangan penggunaan",
        isi: "Rekap menggunakan satu pengukuran terakhir setiap anak dalam periode untuk distribusi dan daftar prioritas. Total pengukuran tetap menghitung seluruh kunjungan. Hasil ini merupakan alat bantu pemantauan dan bukan diagnosis medis.",
    }, header);
    tulisMetadataPembuatan(doc, laporan, header);

    return finalisasiPdf(doc, {
        teksFooter: "Rekap pemantauan pertumbuhan — bukan diagnosis medis",
    });
};
