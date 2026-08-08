import db from "../database/connection.js";
import { success, error } from "../utils/response.js";

export const getStatistik = async (req, res) => {
    try {
        const [totalAnak] = await db.query(
            "SELECT COUNT(*) AS total FROM anak",
        );

        const [totalStunting] = await db.query(
            `SELECT COUNT (DISTINCT p.anak_id) AS total
            FROM pengukuran p
            WHERE p.id = (
                SELECT id FROM pengukuran
                WHERE anak_id = p.anak_id
                ORDER BY tanggal_ukur DESC
                LIMIT 1
            )
            AND p.zscore_tbu < -2`,
        );

        const [totalRujukanAktif] = await db.query(
            `SELECT COUNT(*) AS total
            FROM rujukan
            WHERE status != 'selesai'`,
        );

        const [totalPengukuranBulanIni] = await db.query(
            `SELECT COUNT(*) AS total
            FROM pengukuran
            WHERE MONTH(tanggal_ukur) = MONTH(NOW())
            AND YEAR(tanggal_ukur) = YEAR(NOW())`,
        );

        return success(
            res,
            {
                total_anak: parseInt(totalAnak[0].total),
                total_stunting: parseInt(totalStunting[0].total),
                total_rujukan_aktif: parseInt(totalRujukanAktif[0].total),
                total_pengukuran_bulan: parseInt(
                    totalPengukuranBulanIni[0].total,
                ),
            },
            "Statistik berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDistribusiGizi = async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT
                p.status_gizi,
                COUNT(*) AS jumlah
            FROM pengukuran p
            WHERE p.id = (
                SELECT id FROM pengukuran
                WHERE anak_id = p.anak_id
                ORDER BY tanggal_ukur DESC
                LIMIT 1
                )
                GROUP BY p.status_gizi`,
        );

        const distribusi = {
            normal: 0,
            kurang: 0,
            buruk: 0,
            lebih: 0,
        };

        rows.forEach((row) => {
            distribusi[row.status_gizi] = parseInt(row.jumlah);
        });

        return success(res, distribusi, "Distribusi gizi berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getTrenGizi = async (req, res) => {
    try {
        const bulan = parseInt(req.query.bulan) || 6;

        const [rows] = await db.query(
            `SELECT
                DATE_FORMAT(tanggal_ukur, '%Y-%m') AS periode,
                status_gizi,
                COUNT(*) AS jumlah
            FROM pengukuran
            WHERE tanggal_ukur >= DATE_SUB(NOW(), INTERVAL ? MONTH)
            GROUP BY periode, status_gizi
            ORDER BY periode ASC`,
            [bulan],
        );

        const tren = {};
        rows.forEach((row) => {
            if (!tren[row.periode]) {
                tren[row.periode] = {
                    periode: row.periode,
                    normal: 0,
                    kurang: 0,
                    buruk: 0,
                    lebih: 0,
                };
            }
            tren[row.periode][row.status_gizi] = parseInt(row.jumlah);
        });

        return success(
            res,
            Object.values(tren),
            `Tren ${bulan} bulan terakhir berhasil diambil`,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDistribusiRisiko = async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT
                p.kategori_risiko,
                COUNT(*) AS jumlah
            FROM pengukuran p
            WHERE p.id = (
                SELECT p2.id FROM pengukuran p2
                WHERE p2.anak_id = p.anak_id
                ORDER BY p2.tanggal_ukur DESC
                LIMIT 1
            )
            AND p.kategori_risiko IS NOT NULL
            GROUP BY p.kategori_risiko`,
        );

        const distribusi = {
            rendah: 0,
            sedang: 0,
            tinggi: 0,
        };

        rows.forEach((row) => {
            distribusi[row.kategori_risiko] = parseInt(row.jumlah);
        });

        return success(
            res,
            distribusi,
            "Distribusi risiko stunting berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
