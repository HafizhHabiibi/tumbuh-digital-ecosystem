import { mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import {
    buatLaporanIndividualOrangTua,
    buatLaporanIndividualTeknis,
    buatLaporanRekapPetugas,
} from "../src/services/laporanService.js";
import {
    renderLaporanIndividualOrangTua,
    renderLaporanIndividualTeknis,
    renderLaporanRekapPetugas,
} from "../src/services/laporanRendererService.js";

const outputDir = resolve(
    process.argv[2] || join(tmpdir(), "tumbuh-posyandu-laporan-preview"),
);

const metadata = {
    dibuat_pada: "2026-08-27T08:00:00.000Z",
    nama_posyandu: "Posyandu Melati",
    nama_puskesmas: "Puskesmas Kecamatan Sehat",
    dibuat_oleh: "Kader Riri Handayani",
};

const anak = {
    id: "018f0000-0000-7000-8000-000000000001",
    nama: "Rizki Pratama",
    nik: "3273010101240001",
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-27",
    nama_orang_tua: "Aminah Nurhayati",
};

const buatPengukuran = (index) => {
    const bulan = 8 - index;
    const kategori = index === 0 ? "sedang" : "rendah";
    const skor = index === 0 ? 0.41 : 0.18;
    return {
        id: index + 1,
        tanggal_ukur: `2026-${String(Math.max(1, bulan)).padStart(2, "0")}-20`,
        usia_bulan: 24 - index,
        usia_hari: 724 - index * 30,
        berat_badan: 10.4 - index * 0.12,
        tinggi_badan: 83.5 - index * 0.6,
        nilai_imt: 14.92,
        zscore_bbu: index === 0 ? -1.8 : -1.2,
        zscore_tbu: index === 0 ? -2.25 : -1.7,
        zscore_bbtb: -0.8,
        zscore_imtu: -0.7,
        status_bbu: "berat_badan_normal",
        status_tbu: index === 0 ? "pendek" : "normal",
        status_bbtb: "gizi_baik",
        status_imtu: "gizi_baik",
        skor_saw: skor,
        kategori_prioritas: kategori,
        detail_saw: [
            { nama_kriteria: "zscore_bbu", bobot: 0.25, nilai: 0.6, skor: 0.15 },
            { nama_kriteria: "zscore_tbu", bobot: 0.30, nilai: 0.75, skor: 0.225 },
            { nama_kriteria: "zscore_bbtb", bobot: 0.25, nilai: 0.267, skor: 0.0668 },
            { nama_kriteria: "zscore_imtu", bobot: 0.20, nilai: 0.233, skor: 0.0466 },
        ],
        prioritas_pemantauan: {
            kategori,
            sumber_utama: "saw",
            alasan: [],
        },
    };
};

const riwayat = Array.from({ length: 8 }, (_, index) => buatPengukuran(index));

const laporanOrangTua = buatLaporanIndividualOrangTua({
    metadata: { ...metadata, dibuat_oleh: anak.nama_orang_tua },
    anak,
    pengukuran_terakhir: riwayat[0],
    riwayat_pengukuran: riwayat,
});

const laporanTeknis = buatLaporanIndividualTeknis({
    metadata,
    anak,
    pengukuran_terakhir: riwayat[0],
    riwayat_pengukuran: riwayat,
    rujukan: [
        {
            id: 1,
            status: "ditangani",
            created_at: "2026-08-21T03:00:00.000Z",
            catatan_kader: "Perlu pendampingan dan pemantauan pertumbuhan lanjutan.",
            catatan_puskesmas: "Jadwalkan konsultasi gizi pada kunjungan berikutnya.",
            ditangani_oleh: "Bidan Sari Lestari",
        },
        {
            id: 2,
            status: "selesai",
            created_at: "2026-05-22T03:00:00.000Z",
            catatan_kader: "Pemantauan hasil pengukuran bulan Mei.",
            catatan_puskesmas: "Pendampingan telah diberikan kepada orang tua.",
            ditangani_oleh: "Bidan Sari Lestari",
        },
    ],
});

const daftarPrioritas = Array.from({ length: 32 }, (_, index) => ({
    anak_id: `anak-${index + 1}`,
    nama_anak: `Anak Pemantauan ${index + 1}`,
    nama_orang_tua: `Orang Tua ${index + 1}`,
    tanggal_ukur: "2026-08-20",
    kategori_prioritas: index % 4 === 0 ? "tinggi" : "sedang",
    skor_saw: index % 4 === 0 ? 0.72 : 0.48,
    status_bbu: index % 4 === 0
        ? "berat_badan_kurang"
        : "berat_badan_normal",
    status_tbu: index % 4 === 0 ? "sangat_pendek" : "pendek",
    status_bbtb: index % 4 === 0 ? "gizi_kurang" : "gizi_baik",
    status_imtu: "gizi_baik",
    prioritas_pemantauan: {
        kategori: index % 4 === 0 ? "tinggi" : "sedang",
        sumber_utama: "saw",
        alasan: [],
    },
}));

const laporanRekap = buatLaporanRekapPetugas({
    metadata,
    periode: {
        tanggal_mulai: "2026-08-01",
        tanggal_selesai: "2026-08-27",
    },
    ringkasan: {
        total_anak: 78,
        total_pengukuran: 84,
        total_rujukan_aktif: 4,
    },
    distribusi_antropometri: {
        bbu: {
            berat_badan_sangat_kurang: 3,
            berat_badan_kurang: 12,
            berat_badan_normal: 61,
            risiko_berat_badan_lebih: 2,
        },
        tbu: { sangat_pendek: 5, pendek: 20, normal: 51, tinggi: 2 },
        bbtb: {
            gizi_buruk: 2,
            gizi_kurang: 10,
            gizi_baik: 62,
            risiko_gizi_lebih: 2,
            gizi_lebih: 1,
            obesitas: 1,
        },
        imtu: {
            gizi_buruk: 2,
            gizi_kurang: 9,
            gizi_baik: 63,
            risiko_gizi_lebih: 2,
            gizi_lebih: 1,
            obesitas: 1,
        },
    },
    distribusi_prioritas: { rendah: 46, sedang: 24, tinggi: 8 },
    daftar_prioritas: daftarPrioritas,
    rekap_rujukan: { diajukan: 2, ditangani: 2, selesai: 7 },
});

await mkdir(outputDir, { recursive: true });

const hasil = [
    ["laporan-orang-tua.pdf", await renderLaporanIndividualOrangTua(laporanOrangTua)],
    ["laporan-teknis.pdf", await renderLaporanIndividualTeknis(laporanTeknis)],
    ["laporan-rekap.pdf", await renderLaporanRekapPetugas(laporanRekap)],
];

for (const [nama, buffer] of hasil) {
    await writeFile(join(outputDir, nama), buffer);
}

console.log(JSON.stringify({
    output_dir: outputDir,
    files: hasil.map(([nama, buffer]) => ({
        nama,
        bytes: buffer.length,
        pages: buffer.toString("latin1").match(/\/Type\s*\/Page\b/g)?.length || 0,
    })),
}, null, 2));
