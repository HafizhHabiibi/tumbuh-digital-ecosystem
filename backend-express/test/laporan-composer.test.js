import test from "node:test";
import assert from "node:assert/strict";
import {
    buatPenyusunLaporan,
    LaporanDataError,
} from "../src/services/laporanService.js";

const tanggalTetap = () => new Date("2026-08-27T08:00:00.000Z");
const fasilitas = {
    nama_posyandu: "Posyandu Melati",
    nama_puskesmas: "Puskesmas Sehat",
};

const anak = {
    id: "anak-1",
    nama: "Rizki",
    nik: "1234567890123456",
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-27",
    nama_orang_tua: "Aminah",
};

const rawPengukuran = {
    id: 1,
    anak_id: "anak-1",
    tanggal_ukur: "2026-08-26",
    berat_badan: "11.00",
    tinggi_badan: "85.00",
    lingkar_kepala: null,
    lingkar_lengan: "14.20",
};

const buatModelIndividual = (data = {}) => ({
    findDataIndividual: async () => ({
        anak,
        pengukuran_terakhir: rawPengukuran,
        riwayat_pengukuran: [rawPengukuran],
        rujukan: [],
        ...data,
    }),
});

const kumpulkanKey = (value, hasil = []) => {
    if (!value || typeof value !== "object") return hasil;
    for (const [key, child] of Object.entries(value)) {
        hasil.push(key);
        kumpulkanKey(child, hasil);
    }
    return hasil;
};

test("composer individual orang tua menghitung indikator tetapi menyaring detail teknis", async () => {
    const penyusun = buatPenyusunLaporan({
        model: buatModelIndividual(),
        sekarang: tanggalTetap,
        identitasFasilitas: fasilitas,
    });

    const laporan = await penyusun.siapkanIndividualOrangTua(
        "anak-1",
        "Aminah",
    );
    const keys = kumpulkanKey(laporan);

    assert.equal(laporan.metadata.dibuat_pada, "2026-08-27T08:00:00.000Z");
    assert.equal(laporan.metadata.nama_posyandu, "Posyandu Melati");
    assert.equal(laporan.metadata.dibuat_oleh, "Aminah");
    assert.equal(laporan.pengukuran_terakhir.berat_badan, 11);
    assert.equal(keys.some((key) => key.includes("zscore")), false);
    assert.equal(keys.includes("skor_saw"), false);
    assert.ok(["rendah", "sedang", "tinggi"].includes(
        laporan.prioritas_pemantauan.kategori,
    ));
});

test("composer individual teknis menyertakan empat detail kriteria SAW", async () => {
    const penyusun = buatPenyusunLaporan({
        model: buatModelIndividual({
            rujukan: [{ id: 7, status: "diajukan", created_at: tanggalTetap() }],
        }),
        sekarang: tanggalTetap,
        identitasFasilitas: fasilitas,
    });

    const laporan = await penyusun.siapkanIndividualTeknis(
        "anak-1",
        "Kader Riri",
    );

    assert.equal(laporan.pengukuran_terakhir.saw.detail.length, 4);
    assert.equal(
        Number.isFinite(laporan.pengukuran_terakhir.status.imtu.zscore),
        true,
    );
    assert.equal(laporan.rujukan[0].status, "diajukan");
});

test("laporan membedakan SAW rendah dan pemantauan tinggi pada obesitas", async () => {
    const rawObesitas = {
        ...rawPengukuran,
        berat_badan: "20.00",
        tinggi_badan: "85.00",
    };
    const penyusun = buatPenyusunLaporan({
        model: buatModelIndividual({
            pengukuran_terakhir: rawObesitas,
            riwayat_pengukuran: [rawObesitas],
        }),
        sekarang: tanggalTetap,
        identitasFasilitas: fasilitas,
    });

    const orangTua = await penyusun.siapkanIndividualOrangTua(
        "anak-1",
        "Aminah",
    );
    const teknis = await penyusun.siapkanIndividualTeknis(
        "anak-1",
        "Kader Riri",
    );

    assert.equal(orangTua.prioritas_pemantauan.kategori, "tinggi");
    assert.equal(teknis.pengukuran_terakhir.saw.kategori_prioritas, "rendah");
    assert.equal(
        teknis.pengukuran_terakhir.prioritas_pemantauan.kategori,
        "tinggi",
    );
    assert.equal(
        teknis.pengukuran_terakhir.prioritas_pemantauan.sumber_utama,
        "antropometri",
    );
});

test("composer individual membedakan anak tidak ditemukan dan belum diukur", async () => {
    const tidakAda = buatPenyusunLaporan({
        model: { findDataIndividual: async () => null },
    });
    const belumDiukur = buatPenyusunLaporan({
        model: buatModelIndividual({
            pengukuran_terakhir: null,
            riwayat_pengukuran: [],
        }),
    });

    assert.equal(
        await tidakAda.siapkanIndividualOrangTua("tidak-ada"),
        null,
    );
    await assert.rejects(
        belumDiukur.siapkanIndividualTeknis("anak-1"),
        (error) => error instanceof LaporanDataError &&
            error.kode === "PENGUKURAN_KOSONG",
    );
});

test("composer rekap menghitung distribusi dan mengurutkan daftar tindak lanjut", async () => {
    const model = {
        findDataRekap: async () => ({
            periode: {
                tanggal_mulai: "2026-08-01",
                tanggal_selesai: "2026-08-31",
            },
            ringkasan: {
                total_anak: 3,
                total_pengukuran: 5,
                total_rujukan_aktif: 1,
            },
            pengukuran_terakhir_per_anak: [
                { ...rawPengukuran, anak_id: "a", nama_anak: "Ani", mode: "rendah" },
                { ...rawPengukuran, anak_id: "b", nama_anak: "Budi", mode: "sedang" },
                { ...rawPengukuran, anak_id: "c", nama_anak: "Citra", mode: "tinggi" },
            ].map((item) => ({
                ...item,
                nama_orang_tua: `Orang tua ${item.nama_anak}`,
                tanggal_lahir: anak.tanggal_lahir,
                jenis_kelamin: anak.jenis_kelamin,
            })),
            rekap_rujukan: { diajukan: 1, ditangani: 0, selesai: 2 },
        }),
    };
    const skor = { rendah: 0.1, sedang: 0.5, tinggi: 0.9 };
    // Stub SAW bergantung pada urutan pemanggilan agar fokus test tetap pada
    // agregasi composer, bukan rumus SAW yang telah diuji terpisah.
    let indeks = 0;
    const mode = ["rendah", "sedang", "tinggi"];
    const penyusunTeruji = buatPenyusunLaporan({
        model,
        sekarang: tanggalTetap,
        identitasFasilitas: fasilitas,
        hitungZScoreFn: () => ({
            usia_bulan: 24,
            usia_hari: 730,
            nilai_imt: 15,
            zscore_bbu: 0,
            zscore_tbu: 0,
            zscore_bbtb: 0,
            zscore_imtu: 0,
            status_bbu: "berat_badan_normal",
            status_tbu: "normal",
            status_bbtb: "gizi_baik",
            status_imtu: "gizi_baik",
        }),
        hitungSAWFn: () => {
            const kategori = mode[indeks++];
            return {
                skor_akhir: skor[kategori],
                kategori_prioritas: kategori,
                detail: [],
            };
        },
    });

    const laporan = await penyusunTeruji.siapkanRekap(
        "2026-08-01",
        "2026-08-31",
        "Petugas",
    );

    assert.deepEqual(laporan.distribusi_prioritas, {
        rendah: 1,
        sedang: 1,
        tinggi: 1,
    });
    assert.equal(laporan.distribusi_antropometri.tbu.normal, 3);
    assert.deepEqual(
        laporan.daftar_prioritas.map(({ nama_anak }) => nama_anak),
        ["Citra", "Budi"],
    );
    assert.equal(laporan.daftar_prioritas.some(
        ({ nama_anak }) => nama_anak === "Ani"), false);
});
