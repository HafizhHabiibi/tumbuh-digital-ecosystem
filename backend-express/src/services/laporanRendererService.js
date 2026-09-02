import {
    buatDokumenPdf,
    finalisasiPdf,
    pastikanRuang,
    tulisCatatan,
    tulisHeaderLaporan,
    tulisJudulBagian,
    tulisKeyValue,
    tulisPieChart,
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
    if (Number.isFinite(Number(bulan))) return `${Number(bulan)} Bulan`;
    if (Number.isFinite(Number(hari))) return `${Number(hari)} Hari`;
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

const formatSumberPrioritas = (value) => ({
    saw: "SAW",
    antropometri: "Antropometri",
    gabungan: "SAW dan Antropometri",
})[value] || kapital(value);

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

const tulisIdentitasAnak = (doc, anak, saatHalamanBaru) => {
    tulisJudulBagian(doc, "Identitas Anak", { saatHalamanBaru });
    tulisKeyValue(doc, [
        { label: "Nama anak", nilai: anak.nama },
        { label: "NIK", nilai: anak.nik || "Tidak dicantumkan" },
        { label: "Jenis kelamin", nilai: formatJenisKelamin(anak.jenis_kelamin) },
        { label: "Tanggal lahir", nilai: formatTanggal(anak.tanggal_lahir) },
        { label: "Orang tua", nilai: anak.nama_orang_tua },
    ], saatHalamanBaru);
};

const tulisMetadataPembuatan = (doc, laporan, saatHalamanBaru) => {
    pastikanRuang(doc, 30, saatHalamanBaru);
    doc.font("Helvetica")
        .fontSize(7.5)
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

const tulisAntropometriTerakhir = (
    doc,
    pengukuran,
    usia,
    saatHalamanBaru,
) => tulisTabel(doc, {
    columns: [
        { key: "parameter", label: "Parameter", width: 249 },
        { key: "hasil", label: "Hasil", width: 250 },
    ],
    rows: [
        {
            parameter: "Berat badan",
            hasil: `${formatAngka(pengukuran.berat_badan)} KG`,
        },
        {
            parameter: "Tinggi badan",
            hasil: `${formatAngka(pengukuran.tinggi_badan)} CM`,
        },
        {
            parameter: "IMT",
            hasil: `${formatAngka(pengukuran.nilai_imt)} KG/m²`,
        },
        { parameter: "Usia saat diukur", hasil: usia },
    ],
    saatHalamanBaru,
});

const tulisRiwayatRujukan = (doc, rujukan, saatHalamanBaru) => {
    tulisTabel(doc, {
        columns: [
            { key: "nomor", label: "No.", width: 35, align: "center" },
            { key: "tanggal", label: "Tanggal Diajukan", width: 125 },
            { key: "status", label: "Status", width: 100 },
            { key: "petugas", label: "Ditangani Oleh", width: 239 },
        ],
        rows: rujukan.map((item, index) => ({
            nomor: index + 1,
            tanggal: formatTanggal(item.tanggal),
            status: kapital(item.status),
            petugas: item.ditangani_oleh || "Belum ditangani",
        })),
        saatHalamanBaru,
        teksKosong: "Belum ada riwayat rujukan.",
    });

    const memilikiCatatan = rujukan.some((item) =>
        item.catatan_kader || item.catatan_puskesmas,
    );
    if (!memilikiCatatan) return;

    pastikanRuang(doc, 30, saatHalamanBaru);
    doc.font("Helvetica-Bold")
        .fontSize(9.5)
        .fillColor(WARNA_LAPORAN.teks)
        .text("Catatan Rujukan", doc.page.margins.left, doc.y);
    doc.y += 6;

    rujukan.forEach((item, index) => {
        if (item.catatan_kader) {
            tulisCatatan(doc, {
                judul: `Rujukan ${index + 1} Catatan Kader`,
                isi: item.catatan_kader,
            }, saatHalamanBaru);
        }
        if (item.catatan_puskesmas) {
            tulisCatatan(doc, {
                judul: `Rujukan ${index + 1} Catatan Puskesmas`,
                isi: item.catatan_puskesmas,
            }, saatHalamanBaru);
        }
    });
};

// ─────────────────────────────────────────────────────────────────────────────
// LAPORAN INDIVIDUAL ORANG TUA
// ─────────────────────────────────────────────────────────────────────────────

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

    // Identitas anak
    tulisIdentitasAnak(doc, laporan.anak, header);

    // Antropometri terakhir
    const terakhir = laporan.pengukuran_terakhir;
    tulisJudulBagian(doc, "Antropometri Terakhir", { saatHalamanBaru: header });
    tulisAntropometriTerakhir(
        doc,
        terakhir,
        formatUsia(terakhir.usia_bulan, terakhir.usia_hari),
        header,
    );

    // Status antropometri
    tulisJudulBagian(doc, "Status Antropometri", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "indeks", label: "Indeks", width: 100 },
            { key: "status", label: "Hasil Pemantauan", width: 399 },
        ],
        rows: statusIndividualKeBaris(terakhir.status),
        saatHalamanBaru: header,
    });

    // Prioritas pemantauan
    const prioritas = laporan.prioritas_pemantauan;
    tulisJudulBagian(doc, "Status Pemantauan", { saatHalamanBaru: header });
    tulisKeyValue(doc, [
        { label: "Status", nilai: prioritas.label },
    ], header);
    tulisCatatan(doc, {
        judul: "Saran pemantauan",
        isi: prioritas.narasi,
    }, header);

    // Riwayat pertumbuhan
    tulisJudulBagian(doc, "Riwayat Pertumbuhan", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "tanggal", label: "Tanggal", width: 68 },
            { key: "usia", label: "Usia", width: 54 },
            { key: "bb", label: "BB", width: 46, align: "center" },
            { key: "tb", label: "TB", width: 46, align: "center" },
            { key: "bbu", label: "BB/U", width: 76 },
            { key: "tbu", label: "TB/U", width: 60 },
            { key: "bbtb", label: "BB/TB", width: 75 },
            { key: "imtu", label: "IMT/U", width: 74 },
        ],
        rows: laporan.riwayat_pengukuran.map((item) => ({
            tanggal: formatTanggal(item.tanggal_ukur),
            usia: `${item.usia_bulan} Bulan`,
            bb: `${formatAngka(item.berat_badan)} KG`,
            tb: `${formatAngka(item.tinggi_badan)} CM`,
            bbu: item.status.bbu.label,
            tbu: item.status.tbu.label,
            bbtb: item.status.bbtb.label,
            imtu: item.status.imtu.label,
        })),
        saatHalamanBaru: header,
    });

    // Catatan
    tulisCatatan(doc, {
        judul: "Catatan penting",
        isi: `${prioritas.catatan} Hasil pada dokumen ini bukan diagnosis medis.`,
    }, header);
    tulisMetadataPembuatan(doc, laporan, header);

    return finalisasiPdf(doc, {
        teksFooter: "Ringkasan pemantauan pertumbuhan bukan diagnosis medis",
    });
};

// ─────────────────────────────────────────────────────────────────────────────
// LAPORAN INDIVIDUAL TEKNIS
// ─────────────────────────────────────────────────────────────────────────────

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

    // Identitas anak
    tulisIdentitasAnak(doc, laporan.anak, header);

    // Antropometri terakhir
    const terakhir = laporan.pengukuran_terakhir;
    tulisJudulBagian(doc, "Antropometri Terakhir", { saatHalamanBaru: header });
    tulisAntropometriTerakhir(
        doc,
        terakhir,
        `${terakhir.usia_hari} Hari`,
        header,
    );

    // Status + Z-Score
    tulisJudulBagian(doc, "Status Antropometri dan Z-Score", { saatHalamanBaru: header });
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

    // Prioritas pemantauan
    tulisJudulBagian(doc, "Prioritas Pemantauan", { saatHalamanBaru: header });
    tulisKeyValue(doc, [
        { label: "Kategori", nilai: kapital(terakhir.prioritas_pemantauan.kategori) },
        {
            label: "Sumber utama",
            nilai: formatSumberPrioritas(
                terakhir.prioritas_pemantauan.sumber_utama,
            ),
        },
    ], header);

    // SAW risiko kekurangan gizi
    tulisJudulBagian(doc, "SAW Risiko Kekurangan Gizi", { saatHalamanBaru: header });
    tulisKeyValue(doc, [
        { label: "Kategori SAW", nilai: kapital(terakhir.saw.kategori_prioritas) },
        { label: "Skor akhir", nilai: formatAngka(terakhir.saw.skor, 4) },
    ], header);
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

    // Riwayat teknis
    tulisJudulBagian(doc, "Riwayat Teknis", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "tanggal", label: "Tanggal", width: 60 },
            { key: "usia", label: "Usia", width: 52 },
            { key: "bb", label: "BB", width: 42 },
            { key: "tb", label: "TB", width: 42 },
            { key: "bbu", label: "Z BB/U", width: 44 },
            { key: "tbu", label: "Z TB/U", width: 44 },
            { key: "bbtb", label: "Z BB/TB", width: 46 },
            { key: "imtu", label: "Z IMT/U", width: 46 },
            { key: "saw", label: "SAW", width: 52 },
            { key: "prioritas", label: "Prioritas", width: 71 },
        ],
        rows: laporan.riwayat_pengukuran.map((item) => ({
            tanggal: formatTanggal(item.tanggal_ukur),
            usia: `${item.usia_bulan} Bulan`,
            bb: `${formatAngka(item.berat_badan)} KG`,
            tb: `${formatAngka(item.tinggi_badan)} CM`,
            bbu: formatAngka(item.status.bbu.zscore, 3),
            tbu: formatAngka(item.status.tbu.zscore, 3),
            bbtb: formatAngka(item.status.bbtb.zscore, 3),
            imtu: formatAngka(item.status.imtu.zscore, 3),
            saw: formatAngka(item.saw.skor, 4),
            prioritas: kapital(item.prioritas_pemantauan.kategori),
        })),
        saatHalamanBaru: header,
    });

    // Riwayat rujukan
    tulisJudulBagian(doc, "Riwayat Rujukan", { saatHalamanBaru: header });
    tulisRiwayatRujukan(doc, laporan.rujukan, header);

    // Catatan interpretasi
    tulisCatatan(doc, {
        judul: "Interpretasi",
        isi: "Z-Score mengikuti referensi pertumbuhan WHO dan kategori antropometri mengikuti ambang Permenkes. SAW hanya digunakan untuk membantu pengurutan prioritas pemantauan, bukan menentukan diagnosis.",
    }, header);
    tulisMetadataPembuatan(doc, laporan, header);

    return finalisasiPdf(doc, {
        teksFooter: "Laporan teknis antropometri anak",
    });
};

// ─────────────────────────────────────────────────────────────────────────────
// LAPORAN REKAP PETUGAS
// ─────────────────────────────────────────────────────────────────────────────

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

    // Ringkasan periode
    tulisJudulBagian(doc, "Ringkasan Periode", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "indikator", label: "Ringkasan", width: 399 },
            { key: "jumlah", label: "Jumlah", width: 100, align: "center" },
        ],
        rows: [
            { indikator: "Anak diukur", jumlah: laporan.ringkasan.total_anak },
            { indikator: "Total pengukuran", jumlah: laporan.ringkasan.total_pengukuran },
            { indikator: "Rujukan aktif", jumlah: laporan.ringkasan.total_rujukan_aktif },
        ],
        saatHalamanBaru: header,
    });

    // Distribusi prioritas + pie chart
    tulisJudulBagian(doc, "Distribusi Prioritas Pemantauan", { saatHalamanBaru: header });
    tulisPieChart(doc, {
        data: [
            { label: "Rendah", nilai: laporan.distribusi_prioritas.rendah, warna: WARNA_LAPORAN.rendah },
            { label: "Sedang", nilai: laporan.distribusi_prioritas.sedang, warna: WARNA_LAPORAN.sedang },
            { label: "Tinggi", nilai: laporan.distribusi_prioritas.tinggi, warna: WARNA_LAPORAN.tinggi },
        ],
        saatHalamanBaru: header,
    });

    // Distribusi antropometri
    tulisJudulBagian(doc, "Distribusi Antropometri", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "indeks", label: "Indeks", width: 70 },
            { key: "kategori", label: "Kategori", width: 329 },
            { key: "jumlah", label: "Jumlah Anak", width: 100, align: "center" },
        ],
        rows: barisDistribusi(laporan.distribusi_antropometri),
        saatHalamanBaru: header,
    });

    // Daftar tindak lanjut
    tulisJudulBagian(doc, "Daftar Tindak Lanjut", { saatHalamanBaru: header });
    tulisTabel(doc, {
        columns: [
            { key: "nomor", label: "No.", width: 28, align: "center" },
            { key: "anak", label: "Nama Anak", width: 108 },
            { key: "orang_tua", label: "Orang Tua", width: 115 },
            { key: "tanggal", label: "Tanggal Ukur", width: 78 },
            { key: "prioritas", label: "Prioritas Pantau", width: 90 },
            { key: "skor", label: "SAW Kurang Gizi", width: 80, align: "center" },
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

    // Rekap rujukan
    tulisJudulBagian(doc, "Rekap Rujukan", { saatHalamanBaru: header });
    tulisKeyValue(doc, [
        { label: "Diajukan", nilai: laporan.rekap_rujukan.diajukan || 0 },
        { label: "Ditangani", nilai: laporan.rekap_rujukan.ditangani || 0 },
        { label: "Selesai", nilai: laporan.rekap_rujukan.selesai || 0 },
    ], header);

    // Catatan keterangan
    tulisCatatan(doc, {
        judul: "Keterangan penggunaan",
        isi: "Rekap menggunakan satu pengukuran terakhir setiap anak dalam periode untuk distribusi dan daftar prioritas. Total pengukuran tetap menghitung seluruh kunjungan. Hasil ini merupakan alat bantu pemantauan dan bukan diagnosis medis.",
    }, header);
    tulisMetadataPembuatan(doc, laporan, header);

    return finalisasiPdf(doc, {
        teksFooter: "Rekap pemantauan pertumbuhan bukan diagnosis medis",
    });
};
