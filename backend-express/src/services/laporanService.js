import * as laporanModel from "../models/laporanModel.js";
import { hitungSemuaZScore } from "./zscoreService.js";
import { hitungSAW } from "./sawService.js";

export const VERSI_KONTRAK_LAPORAN = "1.0";

export const JENIS_LAPORAN = Object.freeze({
    INDIVIDUAL_ORANG_TUA: "individual_orang_tua",
    INDIVIDUAL_TEKNIS: "individual_teknis",
    REKAP_PETUGAS: "rekap_petugas",
});

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

const NARASI_PRIORITAS = Object.freeze({
    rendah: "Hasil pertumbuhan anak saat ini tidak menunjukkan kebutuhan pemantauan khusus berdasarkan sistem. Tetap ikuti kegiatan Posyandu dan pemantauan pertumbuhan secara rutin.",
    sedang: "Hasil pertumbuhan anak memerlukan perhatian lebih. Silakan mengikuti pemantauan rutin dan berkonsultasi dengan kader atau petugas Puskesmas untuk mendapatkan saran pendampingan yang sesuai.",
    tinggi: "Hasil pertumbuhan anak memerlukan tindak lanjut lebih awal. Silakan menghubungi kader atau petugas Puskesmas untuk memperoleh arahan dan pendampingan lebih lanjut.",
});

export class LaporanContractError extends Error {
    constructor(message) {
        super(message);
        this.name = "LaporanContractError";
    }
}

export class LaporanDataError extends Error {
    constructor(message, kode) {
        super(message);
        this.name = "LaporanDataError";
        this.kode = kode;
    }
}

const wajibObject = (value, nama) => {
    if (!value || typeof value !== "object" || Array.isArray(value)) {
        throw new LaporanContractError(`${nama} wajib berupa object`);
    }
    return value;
};

const wajibArray = (value, nama) => {
    if (!Array.isArray(value)) {
        throw new LaporanContractError(`${nama} wajib berupa array`);
    }
    return value;
};

const labelStatus = (kode) => LABEL_STATUS[kode] || kode || "Tidak tersedia";

const buatMetadata = (metadata, jenisLaporan, judul) => {
    wajibObject(metadata, "metadata");
    return {
        versi_kontrak: VERSI_KONTRAK_LAPORAN,
        jenis_laporan: jenisLaporan,
        judul,
        dibuat_pada: metadata.dibuat_pada,
        nama_posyandu: metadata.nama_posyandu || "Posyandu",
        nama_puskesmas: metadata.nama_puskesmas || "Puskesmas",
        dibuat_oleh: metadata.dibuat_oleh || "Sistem",
    };
};

const buatIdentitasAnak = (anak) => {
    wajibObject(anak, "anak");
    return {
        id: anak.id,
        nama: anak.nama,
        nik: anak.nik || null,
        jenis_kelamin: anak.jenis_kelamin,
        tanggal_lahir: anak.tanggal_lahir,
        nama_orang_tua: anak.nama_orang_tua,
    };
};

const buatStatusOrangTua = (pengukuran) => ({
    bbu: {
        kode: pengukuran.status_bbu,
        label: labelStatus(pengukuran.status_bbu),
    },
    tbu: {
        kode: pengukuran.status_tbu,
        label: labelStatus(pengukuran.status_tbu),
    },
    bbtb: {
        kode: pengukuran.status_bbtb,
        label: labelStatus(pengukuran.status_bbtb),
    },
    imtu: {
        kode: pengukuran.status_imtu,
        label: labelStatus(pengukuran.status_imtu),
    },
});

const buatStatusTeknis = (pengukuran) => ({
    bbu: {
        kode: pengukuran.status_bbu,
        label: labelStatus(pengukuran.status_bbu),
        zscore: pengukuran.zscore_bbu,
    },
    tbu: {
        kode: pengukuran.status_tbu,
        label: labelStatus(pengukuran.status_tbu),
        zscore: pengukuran.zscore_tbu,
    },
    bbtb: {
        kode: pengukuran.status_bbtb,
        label: labelStatus(pengukuran.status_bbtb),
        zscore: pengukuran.zscore_bbtb,
    },
    imtu: {
        kode: pengukuran.status_imtu,
        label: labelStatus(pengukuran.status_imtu),
        zscore: pengukuran.zscore_imtu,
    },
});

const buatPengukuranDasar = (pengukuran) => {
    wajibObject(pengukuran, "pengukuran");
    return {
        id: pengukuran.id,
        tanggal_ukur: pengukuran.tanggal_ukur,
        usia_bulan: pengukuran.usia_bulan,
        usia_hari: pengukuran.usia_hari,
        berat_badan: pengukuran.berat_badan,
        tinggi_badan: pengukuran.tinggi_badan,
        nilai_imt: pengukuran.nilai_imt,
    };
};

const buatPrioritasOrangTua = (kategori) => {
    if (!NARASI_PRIORITAS[kategori]) {
        throw new LaporanContractError("Kategori prioritas tidak valid");
    }
    return {
        kategori,
        label: `Prioritas ${kategori}`,
        narasi: NARASI_PRIORITAS[kategori],
        catatan: "Prioritas pemantauan merupakan alat bantu kader dan petugas Puskesmas dalam menentukan urutan tindak lanjut, bukan diagnosis medis.",
    };
};

const buatBarisRiwayatOrangTua = (pengukuran) => ({
    ...buatPengukuranDasar(pengukuran),
    status: buatStatusOrangTua(pengukuran),
    prioritas: pengukuran.kategori_prioritas || null,
});

const buatBarisRiwayatTeknis = (pengukuran) => ({
    ...buatPengukuranDasar(pengukuran),
    status: buatStatusTeknis(pengukuran),
    saw: {
        skor: pengukuran.skor_saw,
        kategori_prioritas: pengukuran.kategori_prioritas,
        detail: Array.isArray(pengukuran.detail_saw)
            ? pengukuran.detail_saw.map((item) => ({
                nama_kriteria: item.nama_kriteria,
                bobot: item.bobot,
                nilai: item.nilai,
                skor: item.skor,
            }))
            : [],
    },
});

export const buatLaporanIndividualOrangTua = (data) => {
    wajibObject(data, "data laporan");
    const riwayat = wajibArray(data.riwayat_pengukuran, "riwayat_pengukuran");
    const terakhir = wajibObject(data.pengukuran_terakhir, "pengukuran_terakhir");

    return {
        metadata: buatMetadata(
            data.metadata,
            JENIS_LAPORAN.INDIVIDUAL_ORANG_TUA,
            "Ringkasan Hasil Pemantauan Pertumbuhan Anak",
        ),
        anak: buatIdentitasAnak(data.anak),
        pengukuran_terakhir: {
            ...buatPengukuranDasar(terakhir),
            status: buatStatusOrangTua(terakhir),
        },
        prioritas_pemantauan: buatPrioritasOrangTua(
            terakhir.kategori_prioritas,
        ),
        riwayat_pengukuran: riwayat.map(buatBarisRiwayatOrangTua),
    };
};

export const buatLaporanIndividualTeknis = (data) => {
    wajibObject(data, "data laporan");
    const riwayat = wajibArray(data.riwayat_pengukuran, "riwayat_pengukuran");
    const rujukan = wajibArray(data.rujukan || [], "rujukan");
    const terakhir = wajibObject(data.pengukuran_terakhir, "pengukuran_terakhir");

    return {
        metadata: buatMetadata(
            data.metadata,
            JENIS_LAPORAN.INDIVIDUAL_TEKNIS,
            "Laporan Teknis Pemantauan Antropometri Anak",
        ),
        anak: buatIdentitasAnak(data.anak),
        pengukuran_terakhir: buatBarisRiwayatTeknis(terakhir),
        riwayat_pengukuran: riwayat.map(buatBarisRiwayatTeknis),
        rujukan: rujukan.map((item) => ({
            id: item.id,
            status: item.status,
            tanggal: item.created_at,
            catatan_kader: item.catatan_kader || null,
            catatan_puskesmas: item.catatan_puskesmas || null,
            ditangani_oleh: item.ditangani_oleh || null,
        })),
    };
};

export const buatLaporanRekapPetugas = (data) => {
    wajibObject(data, "data laporan");
    const periode = wajibObject(data.periode, "periode");
    const ringkasan = wajibObject(data.ringkasan, "ringkasan");

    return {
        metadata: buatMetadata(
            data.metadata,
            JENIS_LAPORAN.REKAP_PETUGAS,
            "Laporan Rekap Pemantauan Pertumbuhan Balita",
        ),
        periode: {
            tanggal_mulai: periode.tanggal_mulai,
            tanggal_selesai: periode.tanggal_selesai,
        },
        ringkasan: {
            total_anak: Number(ringkasan.total_anak || 0),
            total_pengukuran: Number(ringkasan.total_pengukuran || 0),
            total_rujukan_aktif: Number(ringkasan.total_rujukan_aktif || 0),
        },
        distribusi_antropometri: structuredClone(
            wajibObject(data.distribusi_antropometri, "distribusi_antropometri"),
        ),
        distribusi_prioritas: {
            rendah: Number(data.distribusi_prioritas?.rendah || 0),
            sedang: Number(data.distribusi_prioritas?.sedang || 0),
            tinggi: Number(data.distribusi_prioritas?.tinggi || 0),
        },
        daftar_prioritas: wajibArray(
            data.daftar_prioritas,
            "daftar_prioritas",
        ).map((item) => ({
            anak_id: item.anak_id,
            nama_anak: item.nama_anak,
            nama_orang_tua: item.nama_orang_tua,
            tanggal_ukur: item.tanggal_ukur,
            kategori_prioritas: item.kategori_prioritas,
            skor_saw: item.skor_saw,
            status_bbu: item.status_bbu,
            status_tbu: item.status_tbu,
            status_bbtb: item.status_bbtb,
            status_imtu: item.status_imtu,
        })),
        rekap_rujukan: structuredClone(
            wajibObject(data.rekap_rujukan || {}, "rekap_rujukan"),
        ),
    };
};

const DISTRIBUSI_ANTROPOMETRI_AWAL = Object.freeze({
    bbu: Object.freeze({
        berat_badan_sangat_kurang: 0,
        berat_badan_kurang: 0,
        berat_badan_normal: 0,
        risiko_berat_badan_lebih: 0,
    }),
    tbu: Object.freeze({ sangat_pendek: 0, pendek: 0, normal: 0, tinggi: 0 }),
    bbtb: Object.freeze({
        gizi_buruk: 0,
        gizi_kurang: 0,
        gizi_baik: 0,
        risiko_gizi_lebih: 0,
        gizi_lebih: 0,
        obesitas: 0,
    }),
    imtu: Object.freeze({
        gizi_buruk: 0,
        gizi_kurang: 0,
        gizi_baik: 0,
        risiko_gizi_lebih: 0,
        gizi_lebih: 0,
        obesitas: 0,
    }),
});

const buatDistribusiAntropometriKosong = () =>
    structuredClone(DISTRIBUSI_ANTROPOMETRI_AWAL);

const inputSAW = (zscores) => ({
    zscore_bbu: zscores.zscore_bbu,
    zscore_tbu: zscores.zscore_tbu,
    zscore_bbtb: zscores.zscore_bbtb,
    zscore_imtu: zscores.zscore_imtu,
});

const tambahPerhitungan = (raw, anak, hitungZScoreFn, hitungSAWFn) => {
    const beratBadan = Number(raw.berat_badan);
    const tinggiBadan = Number(raw.tinggi_badan);
    const zscores = hitungZScoreFn({
        berat_badan: beratBadan,
        tinggi_badan: tinggiBadan,
        tanggal_lahir: anak.tanggal_lahir,
        tanggal_ukur: raw.tanggal_ukur,
        jenis_kelamin: anak.jenis_kelamin,
    });
    const saw = hitungSAWFn(inputSAW(zscores));

    return {
        ...raw,
        berat_badan: beratBadan,
        tinggi_badan: tinggiBadan,
        lingkar_kepala: raw.lingkar_kepala == null
            ? null
            : Number(raw.lingkar_kepala),
        lingkar_lengan: raw.lingkar_lengan == null
            ? null
            : Number(raw.lingkar_lengan),
        ...zscores,
        skor_saw: saw.skor_akhir,
        kategori_prioritas: saw.kategori_prioritas,
        detail_saw: saw.detail,
    };
};

const tambahDistribusi = (distribusi, pengukuran) => {
    distribusi.bbu[pengukuran.status_bbu]++;
    distribusi.tbu[pengukuran.status_tbu]++;
    distribusi.bbtb[pengukuran.status_bbtb]++;
    distribusi.imtu[pengukuran.status_imtu]++;
};

const buatMetadataLaporan = ({
    dibuatOleh,
    sekarang,
    identitasFasilitas,
}) => ({
    dibuat_pada: sekarang().toISOString(),
    nama_posyandu: identitasFasilitas.nama_posyandu,
    nama_puskesmas: identitasFasilitas.nama_puskesmas,
    dibuat_oleh: dibuatOleh || "Sistem",
});

/**
 * Menyusun data mentah menjadi kontrak laporan siap dirender. Otorisasi tidak
 * dilakukan di sini karena akan diterapkan pada lapisan controller/middleware.
 */
export const buatPenyusunLaporan = ({
    model = laporanModel,
    hitungZScoreFn = hitungSemuaZScore,
    hitungSAWFn = hitungSAW,
    sekarang = () => new Date(),
    identitasFasilitas = {
        nama_posyandu: process.env.NAMA_POSYANDU || "Posyandu",
        nama_puskesmas: process.env.NAMA_PUSKESMAS || "Puskesmas",
    },
} = {}) => {
    const metadata = (dibuatOleh) => buatMetadataLaporan({
        dibuatOleh,
        sekarang,
        identitasFasilitas,
    });

    const ambilIndividual = async (anakId) => {
        const data = await model.findDataIndividual(anakId);
        if (!data) return null;
        if (!data.pengukuran_terakhir) {
            throw new LaporanDataError(
                "Laporan belum dapat dibuat karena anak belum memiliki pengukuran",
                "PENGUKURAN_KOSONG",
            );
        }

        const riwayat = data.riwayat_pengukuran.map((pengukuran) =>
            tambahPerhitungan(
                pengukuran,
                data.anak,
                hitungZScoreFn,
                hitungSAWFn,
            ));

        return {
            ...data,
            pengukuran_terakhir: riwayat[0],
            riwayat_pengukuran: riwayat,
        };
    };

    return {
        async siapkanIndividualOrangTua(anakId, dibuatOleh) {
            const data = await ambilIndividual(anakId);
            if (!data) return null;
            return buatLaporanIndividualOrangTua({
                ...data,
                metadata: metadata(dibuatOleh),
            });
        },

        async siapkanIndividualTeknis(anakId, dibuatOleh) {
            const data = await ambilIndividual(anakId);
            if (!data) return null;
            return buatLaporanIndividualTeknis({
                ...data,
                metadata: metadata(dibuatOleh),
            });
        },

        async siapkanRekap(tanggalMulai, tanggalSelesai, dibuatOleh) {
            const data = await model.findDataRekap(tanggalMulai, tanggalSelesai);
            const distribusiAntropometri = buatDistribusiAntropometriKosong();
            const distribusiPrioritas = { rendah: 0, sedang: 0, tinggi: 0 };

            const hasilPerAnak = data.pengukuran_terakhir_per_anak.map((raw) => {
                const pengukuran = tambahPerhitungan(
                    raw,
                    raw,
                    hitungZScoreFn,
                    hitungSAWFn,
                );
                tambahDistribusi(distribusiAntropometri, pengukuran);
                distribusiPrioritas[pengukuran.kategori_prioritas]++;
                return pengukuran;
            });

            const daftarPrioritas = hasilPerAnak
                .filter(({ kategori_prioritas }) =>
                    kategori_prioritas === "tinggi" ||
                    kategori_prioritas === "sedang")
                .sort((a, b) =>
                    b.skor_saw - a.skor_saw ||
                    a.nama_anak.localeCompare(b.nama_anak, "id"));

            return buatLaporanRekapPetugas({
                ...data,
                metadata: metadata(dibuatOleh),
                distribusi_antropometri: distribusiAntropometri,
                distribusi_prioritas: distribusiPrioritas,
                daftar_prioritas: daftarPrioritas,
            });
        },
    };
};

const penyusunLaporan = buatPenyusunLaporan();

export const siapkanLaporanIndividualOrangTua =
    penyusunLaporan.siapkanIndividualOrangTua;
export const siapkanLaporanIndividualTeknis =
    penyusunLaporan.siapkanIndividualTeknis;
export const siapkanLaporanRekap = penyusunLaporan.siapkanRekap;
