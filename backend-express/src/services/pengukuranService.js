import db from "../database/connection.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as zscoreService from "./zscoreService.js";
import * as sawService from "./sawService.js";

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
        zscore_bbu: zscores.zscore_bbu,
        zscore_tbu: zscores.zscore_tbu,
        zscore_bbtb: zscores.zscore_bbtb,
        status_bbu: zscores.status_bbu,
        status_tbu: zscores.status_tbu,
        status_bbtb: zscores.status_bbtb,
        status_gizi: zscores.status_gizi,
    };
};

/**
 * Enrich daftar pengukuran (riwayat) dengan z-score, tren BB, dan SAW.
 * List harus sudah diurutkan dari terbaru ke terlama (DESC tanggal_ukur).
 * @param {Array} rawList - Daftar pengukuran dari DB (DESC order)
 * @param {object} anak - Data anak { tanggal_lahir, jenis_kelamin }
 * @returns {Array} Enriched list
 */
export const enrichPengukuranList = (rawList, anak) => {
    // Balik ke ASC untuk hitung tren BB secara kronologis
    const ascending = [...rawList].reverse();

    const enriched = ascending.map((raw, idx) => {
        const item = enrichPengukuran(raw, anak);

        // Hitung tren BB: selisih dengan pengukuran sebelumnya
        const tren_bb = idx === 0
            ? null
            : sawService.hitungTrenBBPerBulan(
                raw.berat_badan,
                ascending[idx - 1].berat_badan,
                raw.tanggal_ukur,
                ascending[idx - 1].tanggal_ukur,
            );

        // Hitung SAW
        const saw = sawService.hitungSAW(
            { zscore_bbu: item.zscore_bbu, zscore_tbu: item.zscore_tbu, zscore_bbtb: item.zscore_bbtb },
            tren_bb,
        );

        return {
            ...item,
            tren_bb,
            skor_saw: saw.skor_akhir,
            kategori_risiko: saw.kategori_risiko,
        };
    });

    // Kembalikan ke DESC order (terbaru di atas)
    return enriched.reverse();
};

// =============================================================================
// RANKING — Semua anak diurutkan dari risiko tertinggi
// =============================================================================

export const getRankingAllAnak = async () => {
    const latestList = await PengukuranModel.findLatestPerAnak();

    const ranked = await Promise.all(
        latestList.map(async (row) => {
            const zscores = zscoreService.hitungSemuaZScore({
                berat_badan: parseFloat(row.berat_badan),
                tinggi_badan: parseFloat(row.tinggi_badan),
                tanggal_lahir: row.tanggal_lahir,
                tanggal_ukur: row.tanggal_ukur,
                jenis_kelamin: row.jenis_kelamin,
            });

            const previous = await PengukuranModel.findPrevious(row.anak_id, row.tanggal_ukur);
            const tren_bb = previous
                ? sawService.hitungTrenBBPerBulan(
                    row.berat_badan,
                    previous.berat_badan,
                    row.tanggal_ukur,
                    previous.tanggal_ukur,
                )
                : null;

            const saw = sawService.hitungSAW(
                { zscore_bbu: zscores.zscore_bbu, zscore_tbu: zscores.zscore_tbu, zscore_bbtb: zscores.zscore_bbtb },
                tren_bb,
            );

            return {
                anak_id: row.anak_id,
                nama_anak: row.nama_anak,
                tanggal_lahir: row.tanggal_lahir,
                jenis_kelamin: row.jenis_kelamin,
                nama_orang_tua: row.nama_orang_tua,
                no_hp_orang_tua: row.no_hp_orang_tua,
                skor_akhir: saw.skor_akhir,
                kategori_risiko: saw.kategori_risiko,
                calculated_at: row.created_at,
                tanggal_ukur: row.tanggal_ukur,
                berat_badan: parseFloat(row.berat_badan),
                tinggi_badan: parseFloat(row.tinggi_badan),
                status_gizi: zscores.status_gizi,
            };
        }),
    );

    // Sort dari risiko tertinggi
    ranked.sort((a, b) => b.skor_akhir - a.skor_akhir);
    return ranked;
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

    const previous = await PengukuranModel.findPrevious(pengukuran.anak_id, pengukuran.tanggal_ukur);
    const tren_bb = previous
        ? sawService.hitungTrenBBPerBulan(
            pengukuran.berat_badan,
            previous.berat_badan,
            pengukuran.tanggal_ukur,
            previous.tanggal_ukur,
        )
        : null;

    const saw = sawService.hitungSAW(
        { zscore_bbu: zscores.zscore_bbu, zscore_tbu: zscores.zscore_tbu, zscore_bbtb: zscores.zscore_bbtb },
        tren_bb,
    );

    return {
        pengukuran_id: pengukuran.id,
        anak_id: pengukuran.anak_id,
        skor_akhir: saw.skor_akhir,
        kategori_risiko: saw.kategori_risiko,
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

    // Hitung stunting dari pengukuran terakhir setiap anak
    const latestList = await PengukuranModel.findLatestPerAnak();
    let totalStunting = 0;
    for (const row of latestList) {
        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan: parseFloat(row.berat_badan),
            tinggi_badan: parseFloat(row.tinggi_badan),
            tanggal_lahir: row.tanggal_lahir,
            tanggal_ukur: row.tanggal_ukur,
            jenis_kelamin: row.jenis_kelamin,
        });
        if (zscores.zscore_tbu < -2) totalStunting++;
    }

    return {
        total_anak: parseInt(totalAnak),
        total_stunting: totalStunting,
        total_rujukan_aktif: parseInt(totalRujukanAktif),
        total_pengukuran_bulan: parseInt(totalPengukuranBulan),
    };
};

export const getDistribusiGizi = async () => {
    const latestList = await PengukuranModel.findLatestPerAnak();

    const distribusi = { normal: 0, kurang: 0, buruk: 0, lebih: 0, obesitas: 0 };

    for (const row of latestList) {
        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan: parseFloat(row.berat_badan),
            tinggi_badan: parseFloat(row.tinggi_badan),
            tanggal_lahir: row.tanggal_lahir,
            tanggal_ukur: row.tanggal_ukur,
            jenis_kelamin: row.jenis_kelamin,
        });
        if (distribusi[zscores.status_gizi] !== undefined) {
            distribusi[zscores.status_gizi]++;
        }
    }

    return distribusi;
};

export const getDistribusiRisiko = async () => {
    const latestList = await PengukuranModel.findLatestPerAnak();

    const distribusi = { rendah: 0, sedang: 0, tinggi: 0 };

    for (const row of latestList) {
        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan: parseFloat(row.berat_badan),
            tinggi_badan: parseFloat(row.tinggi_badan),
            tanggal_lahir: row.tanggal_lahir,
            tanggal_ukur: row.tanggal_ukur,
            jenis_kelamin: row.jenis_kelamin,
        });

        const previous = await PengukuranModel.findPrevious(row.anak_id, row.tanggal_ukur);
        const tren_bb = previous
            ? sawService.hitungTrenBBPerBulan(
                row.berat_badan,
                previous.berat_badan,
                row.tanggal_ukur,
                previous.tanggal_ukur,
            )
            : null;

        const saw = sawService.hitungSAW(
            { zscore_bbu: zscores.zscore_bbu, zscore_tbu: zscores.zscore_tbu, zscore_bbtb: zscores.zscore_bbtb },
            tren_bb,
        );
        distribusi[saw.kategori_risiko]++;
    }

    return distribusi;
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
            tren[periode] = { periode, normal: 0, kurang: 0, buruk: 0, lebih: 0, obesitas: 0 };
        }
        if (tren[periode][zscores.status_gizi] !== undefined) {
            tren[periode][zscores.status_gizi]++;
        }
    }

    return Object.values(tren);
};
