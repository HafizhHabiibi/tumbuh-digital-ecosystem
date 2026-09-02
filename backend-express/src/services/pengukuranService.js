import db from "../database/connection.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as zscoreService from "./zscoreService.js";
import * as sawService from "./sawService.js";
import * as monitoringPriorityService from "./monitoringPriorityService.js";

const inputSAW = (zscores) => ({
    zscore_bbu: zscores.zscore_bbu,
    zscore_tbu: zscores.zscore_tbu,
    zscore_bbtb: zscores.zscore_bbtb,
    zscore_imtu: zscores.zscore_imtu,
});

export const hitungPrioritasPemantauan = (zscores, saw) => (
    monitoringPriorityService.gabungkanPrioritasPemantauan({
        kategori_prioritas_saw: saw.kategori_prioritas,
        status_bbu: zscores.status_bbu,
        status_tbu: zscores.status_tbu,
        status_bbtb: zscores.status_bbtb,
        status_imtu: zscores.status_imtu,
    })
);

const TINGKAT_PRIORITAS_PEMANTAUAN = Object.freeze({
    rendah: 1,
    sedang: 2,
    tinggi: 3,
});

const tingkatPrioritasPemantauan = (item) => {
    const kategori = item?.prioritas_pemantauan?.kategori;
    if (!Object.hasOwn(TINGKAT_PRIORITAS_PEMANTAUAN, kategori)) {
        throw new TypeError("Kategori prioritas pemantauan tidak valid");
    }
    return TINGKAT_PRIORITAS_PEMANTAUAN[kategori];
};

const waktuTanggalUkur = (item) => {
    const waktu = item?.tanggal_ukur instanceof Date
        ? item.tanggal_ukur.getTime()
        : Date.parse(item?.tanggal_ukur);
    if (!Number.isFinite(waktu)) {
        throw new TypeError("Tanggal ukur ranking tidak valid");
    }
    return waktu;
};

export const bandingkanRankingPrioritas = (a, b) => {
    const selisihPrioritas =
        tingkatPrioritasPemantauan(b) - tingkatPrioritasPemantauan(a);
    if (selisihPrioritas !== 0) return selisihPrioritas;

    const selisihSaw = Number(b.skor_saw) - Number(a.skor_saw);
    if (Number.isFinite(selisihSaw) && selisihSaw !== 0) return selisihSaw;

    const selisihTanggal = waktuTanggalUkur(b) - waktuTanggalUkur(a);
    if (selisihTanggal !== 0) return selisihTanggal;

    return String(a.anak_id).localeCompare(String(b.anak_id));
};

export const buatDistribusiPrioritasPemantauan = (items) => {
    if (!Array.isArray(items)) {
        throw new TypeError("Daftar prioritas pemantauan harus berupa array");
    }

    const distribusi = { rendah: 0, sedang: 0, tinggi: 0 };
    for (const item of items) {
        const kategori = item?.prioritas_pemantauan?.kategori;
        tingkatPrioritasPemantauan(item);
        distribusi[kategori]++;
    }
    return distribusi;
};

export const buatStatistikDashboard = ({
    totalAnak,
    totalRujukanAktif,
    totalPengukuranBulan,
    pengukuranTerbaru,
}) => {
    const distribusiPrioritas =
        buatDistribusiPrioritasPemantauan(pengukuranTerbaru);

    return {
        total_anak: Number.parseInt(totalAnak, 10),
        total_prioritas_tinggi: distribusiPrioritas.tinggi,
        total_rujukan_aktif: Number.parseInt(totalRujukanAktif, 10),
        total_pengukuran_bulan: Number.parseInt(totalPengukuranBulan, 10),
    };
};

const buatDistribusiAntropometri = () => ({
    bbu: {
        berat_badan_sangat_kurang: 0,
        berat_badan_kurang: 0,
        berat_badan_normal: 0,
        risiko_berat_badan_lebih: 0,
    },
    tbu: { sangat_pendek: 0, pendek: 0, normal: 0, tinggi: 0 },
    bbtb: {
        gizi_buruk: 0,
        gizi_kurang: 0,
        gizi_baik: 0,
        risiko_gizi_lebih: 0,
        gizi_lebih: 0,
        obesitas: 0,
    },
    imtu: {
        gizi_buruk: 0,
        gizi_kurang: 0,
        gizi_baik: 0,
        risiko_gizi_lebih: 0,
        gizi_lebih: 0,
        obesitas: 0,
    },
});

const tambahKeDistribusi = (distribusi, zscores) => {
    distribusi.bbu[zscores.status_bbu]++;
    distribusi.tbu[zscores.status_tbu]++;
    distribusi.bbtb[zscores.status_bbtb]++;
    distribusi.imtu[zscores.status_imtu]++;
};

// =============================================================================
// ENRICHMENT HELPERS
// Mengambil raw data dan menambahkan computed fields (z-score, SAW) on-the-fly.
// =============================================================================

/**
 * Enrich satu pengukuran dengan z-score dan status gizi.
 * @param {object} raw - Raw pengukuran dari DB
 * @param {object} anak - Data anak { tanggal_lahir, jenis_kelamin }
 * @returns {object} Pengukuran + z-scores + status
 */
export const enrichPengukuran = (raw, anak) => {
    const zscores = zscoreService.hitungSemuaZScore({
        berat_badan: parseFloat(raw.berat_badan),
        tinggi_badan: parseFloat(raw.tinggi_badan),
        tanggal_lahir: anak.tanggal_lahir,
        tanggal_ukur: raw.tanggal_ukur,
        jenis_kelamin: anak.jenis_kelamin,
    });

    return {
        ...raw,
        berat_badan: parseFloat(raw.berat_badan),
        tinggi_badan: parseFloat(raw.tinggi_badan),
        lingkar_kepala: raw.lingkar_kepala ? parseFloat(raw.lingkar_kepala) : null,
        lingkar_lengan: raw.lingkar_lengan ? parseFloat(raw.lingkar_lengan) : null,
        usia_bulan: zscores.usia_bulan,
        usia_hari: zscores.usia_hari,
        nilai_imt: zscores.nilai_imt,
        zscore_bbu: zscores.zscore_bbu,
        zscore_tbu: zscores.zscore_tbu,
        zscore_bbtb: zscores.zscore_bbtb,
        zscore_imtu: zscores.zscore_imtu,
        status_bbu: zscores.status_bbu,
        status_tbu: zscores.status_tbu,
        status_bbtb: zscores.status_bbtb,
        status_imtu: zscores.status_imtu,
    };
};

/**
 * Enrich satu pengukuran dengan z-score, status antropometri, prioritas SAW,
 * dan prioritas pemantauan akhir.
 * Helper ini juga dipakai rujukan agar enrichment dilakukan dari data yang sudah
 * diambil model, tanpa query detail SAW per baris.
 */
export const enrichPengukuranDenganPrioritas = (raw, anak) => {
    const item = enrichPengukuran(raw, anak);
    const saw = sawService.hitungSAW(inputSAW(item));
    const prioritasPemantauan = hitungPrioritasPemantauan(item, saw);

    return {
        ...item,
        skor_saw: saw.skor_akhir,
        kategori_prioritas: saw.kategori_prioritas,
        prioritas_pemantauan: prioritasPemantauan,
    };
};

/**
 * Enrich daftar pengukuran (riwayat) dengan z-score, SAW, dan prioritas
 * pemantauan akhir.
 * List harus sudah diurutkan dari terbaru ke terlama (DESC tanggal_ukur).
 * @param {Array} rawList - Daftar pengukuran dari DB (DESC order)
 * @param {object} anak - Data anak { tanggal_lahir, jenis_kelamin }
 * @returns {Array} Enriched list
 */
export const enrichPengukuranList = (rawList, anak) => {
    return rawList.map((raw) => enrichPengukuranDenganPrioritas(raw, anak));
};

// =============================================================================
// RANKING — Semua anak diurutkan dari prioritas pemantauan tertinggi
// =============================================================================

export const getRankingAllAnak = async (page = 1, limit = 20) => {
    const latestList = await PengukuranModel.findLatestPerAnak();

    const ranked = latestList.map((row) => {
        const item = enrichPengukuranDenganPrioritas(row, row);

        return {
            anak_id: row.anak_id,
            nama_anak: row.nama_anak,
            tanggal_lahir: row.tanggal_lahir,
            jenis_kelamin: row.jenis_kelamin,
            nama_orang_tua: row.nama_orang_tua,
            no_hp_orang_tua: row.no_hp_orang_tua,
            skor_saw: item.skor_saw,
            calculated_at: row.created_at,
            tanggal_ukur: row.tanggal_ukur,
            berat_badan: item.berat_badan,
            tinggi_badan: item.tinggi_badan,
            nilai_imt: item.nilai_imt,
            status_bbu: item.status_bbu,
            status_tbu: item.status_tbu,
            status_bbtb: item.status_bbtb,
            status_imtu: item.status_imtu,
            kategori_prioritas: item.kategori_prioritas,
            prioritas_pemantauan: item.prioritas_pemantauan,
        };
    });

    ranked.sort(bandingkanRankingPrioritas);
    const offset = (page - 1) * limit;
    return {
        items: ranked.slice(offset, offset + limit),
        total: ranked.length,
    };
};

// =============================================================================
// DETAIL SAW — Breakdown lengkap per pengukuran
// =============================================================================

export const getDetailSAW = async (pengukuran_id) => {
    const pengukuran = await PengukuranModel.findById(pengukuran_id);
    if (!pengukuran) return null;

    const zscores = zscoreService.hitungSemuaZScore({
        berat_badan: parseFloat(pengukuran.berat_badan),
        tinggi_badan: parseFloat(pengukuran.tinggi_badan),
        tanggal_lahir: pengukuran.tanggal_lahir,
        tanggal_ukur: pengukuran.tanggal_ukur,
        jenis_kelamin: pengukuran.jenis_kelamin,
    });

    const saw = sawService.hitungSAW(inputSAW(zscores));

    return {
        pengukuran_id: pengukuran.id,
        anak_id: pengukuran.anak_id,
        skor_saw: saw.skor_akhir,
        kategori_prioritas: saw.kategori_prioritas,
        detail: saw.detail,
    };
};

// =============================================================================
// DASHBOARD — Statistik & distribusi (dihitung on-the-fly)
// =============================================================================

export const getStatistik = async () => {
    const [[{ total: totalAnak }]] = await db.query("SELECT COUNT(*) AS total FROM anak");
    const [[{ total: totalRujukanAktif }]] = await db.query(
        "SELECT COUNT(*) AS total FROM rujukan WHERE status != 'selesai'",
    );
    const [[{ total: totalPengukuranBulan }]] = await db.query(
        `SELECT COUNT(*) AS total FROM pengukuran
        WHERE MONTH(tanggal_ukur) = MONTH(NOW())
        AND YEAR(tanggal_ukur) = YEAR(NOW())`,
    );

    const latestList = await PengukuranModel.findLatestPerAnak();
    const enriched = latestList.map((row) =>
        enrichPengukuranDenganPrioritas(row, row));
    return buatStatistikDashboard({
        totalAnak,
        totalRujukanAktif,
        totalPengukuranBulan,
        pengukuranTerbaru: enriched,
    });
};

export const getDistribusiGizi = async () => {
    const latestList = await PengukuranModel.findLatestPerAnak();

    const distribusi = buatDistribusiAntropometri();

    for (const row of latestList) {
        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan: parseFloat(row.berat_badan),
            tinggi_badan: parseFloat(row.tinggi_badan),
            tanggal_lahir: row.tanggal_lahir,
            tanggal_ukur: row.tanggal_ukur,
            jenis_kelamin: row.jenis_kelamin,
        });
        tambahKeDistribusi(distribusi, zscores);
    }

    return distribusi;
};

export const getDistribusiRisiko = async () => {
    const latestList = await PengukuranModel.findLatestPerAnak();
    const enriched = latestList.map((row) =>
        enrichPengukuranDenganPrioritas(row, row));
    return buatDistribusiPrioritasPemantauan(enriched);
};

export const getTrenGizi = async (bulan) => {
    const rows = await PengukuranModel.findByPeriode(bulan);

    const tren = {};
    for (const row of rows) {
        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan: parseFloat(row.berat_badan),
            tinggi_badan: parseFloat(row.tinggi_badan),
            tanggal_lahir: row.tanggal_lahir,
            tanggal_ukur: row.tanggal_ukur,
            jenis_kelamin: row.jenis_kelamin,
        });

        const periode = row.tanggal_ukur.toISOString().slice(0, 7);
        if (!tren[periode]) {
            tren[periode] = {
                periode,
                ...buatDistribusiAntropometri(),
            };
        }
        tambahKeDistribusi(tren[periode], zscores);
    }

    return Object.values(tren);
};
