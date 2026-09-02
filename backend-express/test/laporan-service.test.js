import test from "node:test";
import assert from "node:assert/strict";
import {
    buatLaporanIndividualOrangTua,
    buatLaporanIndividualTeknis,
    buatLaporanRekapPetugas,
    JENIS_LAPORAN,
    LaporanContractError,
} from "../src/services/laporanService.js";

const metadata = {
    dibuat_pada: "2026-08-27T10:00:00.000Z",
    nama_posyandu: "Posyandu Melati",
    nama_puskesmas: "Puskesmas Sehat",
    dibuat_oleh: "Sistem",
};

const anak = {
    id: "anak-1",
    nama: "Rizki",
    nik: "1234567890",
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-27",
    nama_orang_tua: "Aminah",
    no_hp_orang_tua: "08123456789",
    alamat_orang_tua: "Alamat rahasia",
};

const pengukuran = {
    id: 1,
    tanggal_ukur: "2026-08-27",
    usia_bulan: 24,
    usia_hari: 730,
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
    prioritas_pemantauan: {
        kategori: "rendah",
        sumber_utama: "saw",
        alasan: [],
    },
    detail_saw: [
        { nama_kriteria: "zscore_bbu", bobot: 0.25, nilai: 0.1333, skor: 0.0333 },
    ],
};

const dataIndividual = {
    metadata,
    anak,
    pengukuran_terakhir: pengukuran,
    riwayat_pengukuran: [pengukuran],
    rujukan: [],
};

const kumpulkanKey = (value, hasil = []) => {
    if (!value || typeof value !== "object") return hasil;
    for (const [key, child] of Object.entries(value)) {
        hasil.push(key);
        kumpulkanKey(child, hasil);
    }
    return hasil;
};

test("kontrak orang tua hanya memuat informasi yang mudah dipahami", () => {
    const laporan = buatLaporanIndividualOrangTua(dataIndividual);
    const keys = kumpulkanKey(laporan);

    assert.equal(
        laporan.metadata.jenis_laporan,
        JENIS_LAPORAN.INDIVIDUAL_ORANG_TUA,
    );
    assert.equal(laporan.pengukuran_terakhir.status.bbu.label, "Berat badan normal");
    assert.equal(laporan.prioritas_pemantauan.kategori, "rendah");
    assert.equal(keys.some((key) => key.includes("zscore")), false);
    assert.equal(keys.includes("skor_saw"), false);
    assert.equal(keys.includes("detail_saw"), false);
    assert.equal(keys.includes("no_hp_orang_tua"), false);
    assert.equal(keys.includes("alamat_orang_tua"), false);
});

test("kontrak teknis memuat Z-score, SAW, dan rujukan", () => {
    const laporan = buatLaporanIndividualTeknis({
        ...dataIndividual,
        rujukan: [{
            id: 7,
            status: "diajukan",
            created_at: "2026-08-27T10:00:00.000Z",
            catatan_kader: "Perlu peninjauan",
        }],
    });

    assert.equal(
        laporan.metadata.jenis_laporan,
        JENIS_LAPORAN.INDIVIDUAL_TEKNIS,
    );
    assert.equal(laporan.pengukuran_terakhir.status.tbu.zscore, -1.2);
    assert.equal(laporan.pengukuran_terakhir.saw.skor, 0.1533);
    assert.equal(
        laporan.pengukuran_terakhir.prioritas_pemantauan.kategori,
        "rendah",
    );
    assert.equal(laporan.pengukuran_terakhir.saw.detail.length, 1);
    assert.equal(laporan.rujukan[0].status, "diajukan");
});

test("kontrak rekap hanya memuat data operasional petugas", () => {
    const laporan = buatLaporanRekapPetugas({
        metadata: { ...metadata, dibuat_oleh: "Kader Riri" },
        periode: {
            tanggal_mulai: "2026-08-01",
            tanggal_selesai: "2026-08-31",
        },
        ringkasan: {
            total_anak: 15,
            total_pengukuran: 15,
            total_rujukan_aktif: 1,
        },
        distribusi_antropometri: {
            bbu: { berat_badan_normal: 12 },
            tbu: { normal: 11, pendek: 4 },
            bbtb: { gizi_baik: 13 },
            imtu: { gizi_baik: 13 },
        },
        distribusi_prioritas: { rendah: 10, sedang: 4, tinggi: 1 },
        daftar_prioritas: [{
            anak_id: "anak-1",
            nama_anak: "Rizki",
            nama_orang_tua: "Aminah",
            tanggal_ukur: "2026-08-27",
            kategori_prioritas: "tinggi",
            prioritas_pemantauan: {
                kategori: "tinggi",
                sumber_utama: "saw",
                alasan: [],
            },
            skor_saw: 0.8,
            status_bbu: "berat_badan_kurang",
            status_tbu: "pendek",
            status_bbtb: "gizi_kurang",
            status_imtu: "gizi_kurang",
        }],
        rekap_rujukan: { diajukan: 1, ditangani: 0, selesai: 0 },
    });

    assert.equal(laporan.metadata.jenis_laporan, JENIS_LAPORAN.REKAP_PETUGAS);
    assert.equal(laporan.ringkasan.total_anak, 15);
    assert.equal(laporan.distribusi_prioritas.tinggi, 1);
    assert.equal(laporan.daftar_prioritas[0].nama_anak, "Rizki");
});

test("kontrak laporan menolak kategori prioritas tidak valid", () => {
    assert.throws(
        () => buatLaporanIndividualOrangTua({
            ...dataIndividual,
            pengukuran_terakhir: {
                ...pengukuran,
                prioritas_pemantauan: {
                    kategori: "darurat",
                    sumber_utama: "antropometri",
                    alasan: [],
                },
            },
        }),
        LaporanContractError,
    );
});
