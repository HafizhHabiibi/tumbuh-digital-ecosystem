import db from "../database/connection.js";

const QUERY_ANAK = `SELECT
    a.id,
    a.orang_tua_id,
    a.nama,
    a.nik,
    a.jenis_kelamin,
    DATE_FORMAT(a.tanggal_lahir, '%Y-%m-%d') AS tanggal_lahir,
    ot.nama_lengkap AS nama_orang_tua
FROM anak a
JOIN orang_tua ot ON ot.id = a.orang_tua_id
WHERE a.id = ?`;

const QUERY_RIWAYAT_PENGUKURAN = `SELECT
    p.id,
    p.anak_id,
    DATE_FORMAT(p.tanggal_ukur, '%Y-%m-%d') AS tanggal_ukur,
    p.berat_badan,
    p.tinggi_badan,
    p.lingkar_kepala,
    p.lingkar_lengan,
    p.created_at,
    k.nama_lengkap AS nama_kader
FROM pengukuran p
JOIN kader k ON k.id = p.kader_id
WHERE p.anak_id = ?
ORDER BY p.tanggal_ukur DESC, p.id DESC`;

const QUERY_RUJUKAN_ANAK = `SELECT
    r.id,
    r.status,
    r.catatan_kader,
    r.catatan_puskesmas,
    r.created_at,
    r.validated_at,
    DATE_FORMAT(p.tanggal_ukur, '%Y-%m-%d') AS tanggal_ukur,
    k.nama_lengkap AS nama_kader,
    pu.nama_lengkap AS ditangani_oleh
FROM rujukan r
JOIN pengukuran p ON p.id = r.pengukuran_id
JOIN kader k ON k.id = r.kader_id
LEFT JOIN puskesmas pu ON pu.id = r.puskesmas_id
WHERE p.anak_id = ?
ORDER BY r.created_at DESC, r.id DESC`;

const QUERY_PENGUKURAN_TERAKHIR_PER_ANAK = `WITH pengukuran_periode AS (
    SELECT
        p.*,
        ROW_NUMBER() OVER (
            PARTITION BY p.anak_id
            ORDER BY p.tanggal_ukur DESC, p.id DESC
        ) AS urutan_terbaru
    FROM pengukuran p
    WHERE p.tanggal_ukur BETWEEN ? AND ?
)
SELECT
    pp.id,
    pp.anak_id,
    DATE_FORMAT(pp.tanggal_ukur, '%Y-%m-%d') AS tanggal_ukur,
    pp.berat_badan,
    pp.tinggi_badan,
    pp.lingkar_kepala,
    pp.lingkar_lengan,
    a.nama AS nama_anak,
    a.nik,
    a.jenis_kelamin,
    DATE_FORMAT(a.tanggal_lahir, '%Y-%m-%d') AS tanggal_lahir,
    ot.nama_lengkap AS nama_orang_tua,
    k.nama_lengkap AS nama_kader
FROM pengukuran_periode pp
JOIN anak a ON a.id = pp.anak_id
JOIN orang_tua ot ON ot.id = a.orang_tua_id
JOIN kader k ON k.id = pp.kader_id
WHERE pp.urutan_terbaru = 1
ORDER BY a.nama ASC, pp.anak_id ASC`;

const QUERY_RINGKASAN_PERIODE = `SELECT
    COUNT(DISTINCT p.anak_id) AS total_anak,
    COUNT(p.id) AS total_pengukuran
FROM pengukuran p
WHERE p.tanggal_ukur BETWEEN ? AND ?`;

const QUERY_REKAP_RUJUKAN = `SELECT
    SUM(CASE WHEN r.status = 'diajukan' THEN 1 ELSE 0 END) AS diajukan,
    SUM(CASE WHEN r.status = 'ditangani' THEN 1 ELSE 0 END) AS ditangani,
    SUM(CASE WHEN r.status = 'selesai' THEN 1 ELSE 0 END) AS selesai,
    SUM(CASE WHEN r.status != 'selesai' THEN 1 ELSE 0 END) AS total_aktif
FROM rujukan r
JOIN pengukuran p ON p.id = r.pengukuran_id
WHERE p.tanggal_ukur BETWEEN ? AND ?`;

const QUERY_KEPEMILIKAN_ANAK = `SELECT 1 AS ditemukan
FROM anak a
JOIN orang_tua ot ON ot.id = a.orang_tua_id
WHERE a.id = ? AND ot.user_id = ?
LIMIT 1`;

const angka = (nilai) => Number(nilai || 0);

/**
 * Factory sengaja menerima koneksi sebagai dependency agar query laporan dapat
 * diuji tanpa membutuhkan database sungguhan.
 */
export const buatLaporanModel = (database = db) => ({
    async isAnakMilikUserOrangTua(anakId, userId) {
        const [rows] = await database.query(QUERY_KEPEMILIKAN_ANAK, [
            anakId,
            userId,
        ]);
        return Boolean(rows[0]);
    },

    async findDataIndividual(anakId) {
        const [barisAnak] = await database.query(QUERY_ANAK, [anakId]);
        const anak = barisAnak[0] || null;

        if (!anak) return null;

        const [[riwayatPengukuran], [rujukan]] = await Promise.all([
            database.query(QUERY_RIWAYAT_PENGUKURAN, [anakId]),
            database.query(QUERY_RUJUKAN_ANAK, [anakId]),
        ]);

        return {
            anak,
            pengukuran_terakhir: riwayatPengukuran[0] || null,
            riwayat_pengukuran: riwayatPengukuran,
            rujukan,
        };
    },

    async findDataRekap(tanggalMulai, tanggalSelesai) {
        const parameterPeriode = [tanggalMulai, tanggalSelesai];
        const [hasilPengukuran, hasilRingkasan, hasilRujukan] =
            await Promise.all([
                database.query(
                    QUERY_PENGUKURAN_TERAKHIR_PER_ANAK,
                    parameterPeriode,
                ),
                database.query(QUERY_RINGKASAN_PERIODE, parameterPeriode),
                database.query(QUERY_REKAP_RUJUKAN, parameterPeriode),
            ]);

        const pengukuranTerakhir = hasilPengukuran[0];
        const ringkasan = hasilRingkasan[0][0] || {};
        const rekapRujukan = hasilRujukan[0][0] || {};

        return {
            periode: {
                tanggal_mulai: tanggalMulai,
                tanggal_selesai: tanggalSelesai,
            },
            ringkasan: {
                total_anak: angka(ringkasan.total_anak),
                total_pengukuran: angka(ringkasan.total_pengukuran),
                total_rujukan_aktif: angka(rekapRujukan.total_aktif),
            },
            pengukuran_terakhir_per_anak: pengukuranTerakhir,
            rekap_rujukan: {
                diajukan: angka(rekapRujukan.diajukan),
                ditangani: angka(rekapRujukan.ditangani),
                selesai: angka(rekapRujukan.selesai),
            },
        };
    },
});

const laporanModel = buatLaporanModel();

export const findDataIndividual = laporanModel.findDataIndividual;
export const findDataRekap = laporanModel.findDataRekap;
export const isAnakMilikUserOrangTua =
    laporanModel.isAnakMilikUserOrangTua;
