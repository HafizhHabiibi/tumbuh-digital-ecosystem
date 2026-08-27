import test from "node:test";
import assert from "node:assert/strict";
import {
    buatLaporanIndividualOrangTua,
    buatLaporanIndividualTeknis,
    buatLaporanRekapPetugas,
} from "../src/services/laporanService.js";
import {
    LaporanRendererError,
    renderLaporanIndividualOrangTua,
    renderLaporanIndividualTeknis,
    renderLaporanRekapPetugas,
} from "../src/services/laporanRendererService.js";

const metadata = {
    dibuat_pada: "2026-08-27T08:00:00.000Z",
    nama_posyandu: "Posyandu Melati",
    nama_puskesmas: "Puskesmas Sehat",
    dibuat_oleh: "Kader Riri",
};

const anak = {
    id: "anak-1",
    nama: "Rizki",
    nik: "1234567890123456",
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-27",
    nama_orang_tua: "Aminah",
};

const pengukuran = (id = 1) => ({
    id,
    tanggal_ukur: `2026-${String(Math.max(1, 9 - id)).padStart(2, "0")}-26`,
    usia_bulan: 24 - id,
    usia_hari: 730 - id * 30,
    berat_badan: 11,
    tinggi_badan: 85,
    nilai_imt: 15.22,
    zscore_bbu: -0.4,
    zscore_tbu: -1.2,
    zscore_bbtb: 0.1,
    zscore_imtu: 0.15,
    status_bbu: "berat_badan_normal",
    status_tbu: "normal",
    status_bbtb: "gizi_baik",
    status_imtu: "gizi_baik",
    skor_saw: 0.1533,
    kategori_prioritas: "rendah",
    detail_saw: [
        { nama_kriteria: "zscore_bbu", bobot: 0.25, nilai: 0.1333, skor: 0.0333 },
        { nama_kriteria: "zscore_tbu", bobot: 0.30, nilai: 0.4, skor: 0.12 },
        { nama_kriteria: "zscore_bbtb", bobot: 0.25, nilai: 0, skor: 0 },
        { nama_kriteria: "zscore_imtu", bobot: 0.20, nilai: 0, skor: 0 },
    ],
});

const validasiPdf = (buffer) => {
    assert.equal(Buffer.isBuffer(buffer), true);
    assert.equal(buffer.subarray(0, 5).toString("ascii"), "%PDF-");
    assert.ok(buffer.length > 4_000);
};

test("renderer membuat PDF individual orang tua yang valid", async () => {
    const riwayat = Array.from({ length: 8 }, (_, index) => pengukuran(index + 1));
    const laporan = buatLaporanIndividualOrangTua({
        metadata,
        anak,
        pengukuran_terakhir: riwayat[0],
        riwayat_pengukuran: riwayat,
    });

    validasiPdf(await renderLaporanIndividualOrangTua(laporan));
});

test("renderer membuat PDF individual teknis beserta rujukan", async () => {
    const riwayat = Array.from({ length: 8 }, (_, index) => pengukuran(index + 1));
    const laporan = buatLaporanIndividualTeknis({
        metadata,
        anak,
        pengukuran_terakhir: riwayat[0],
        riwayat_pengukuran: riwayat,
        rujukan: [{
            id: 1,
            status: "ditangani",
            created_at: "2026-08-27T08:00:00.000Z",
            catatan_kader: "Mohon ditinjau",
            catatan_puskesmas: "Pemantauan lanjutan",
            ditangani_oleh: "Bidan Sari",
        }],
    });

    validasiPdf(await renderLaporanIndividualTeknis(laporan));
});

test("renderer rekap menangani tabel prioritas multi-halaman", async () => {
    const daftar = Array.from({ length: 50 }, (_, index) => ({
        anak_id: `anak-${index}`,
        nama_anak: `Anak ${index + 1}`,
        nama_orang_tua: `Orang Tua ${index + 1}`,
        tanggal_ukur: "2026-08-26",
        kategori_prioritas: index % 3 === 0 ? "tinggi" : "sedang",
        skor_saw: index % 3 === 0 ? 0.8 : 0.5,
        status_bbu: "berat_badan_kurang",
        status_tbu: "pendek",
        status_bbtb: "gizi_kurang",
        status_imtu: "gizi_kurang",
    }));
    const laporan = buatLaporanRekapPetugas({
        metadata,
        periode: { tanggal_mulai: "2026-08-01", tanggal_selesai: "2026-08-31" },
        ringkasan: { total_anak: 50, total_pengukuran: 55, total_rujukan_aktif: 2 },
        distribusi_antropometri: {
            bbu: { berat_badan_normal: 10, berat_badan_kurang: 40 },
            tbu: { normal: 10, pendek: 40 },
            bbtb: { gizi_baik: 10, gizi_kurang: 40 },
            imtu: { gizi_baik: 10, gizi_kurang: 40 },
        },
        distribusi_prioritas: { rendah: 0, sedang: 33, tinggi: 17 },
        daftar_prioritas: daftar,
        rekap_rujukan: { diajukan: 1, ditangani: 1, selesai: 4 },
    });

    const buffer = await renderLaporanRekapPetugas(laporan);
    validasiPdf(buffer);
    const jumlahHalaman = buffer.toString("latin1")
        .match(/\/Type\s*\/Page\b/g)?.length || 0;
    assert.ok(jumlahHalaman >= 4);
});

test("renderer menolak kontrak laporan dengan jenis yang salah", async () => {
    const laporanTeknis = buatLaporanIndividualTeknis({
        metadata,
        anak,
        pengukuran_terakhir: pengukuran(),
        riwayat_pengukuran: [pengukuran()],
        rujukan: [],
    });

    await assert.rejects(
        renderLaporanIndividualOrangTua(laporanTeknis),
        LaporanRendererError,
    );
});
