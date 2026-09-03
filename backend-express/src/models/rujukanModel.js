import db from "../database/connection.js";
import { toLikePattern } from "../utils/sqlFilter.js";

export const create = async (data) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        await conn.query("SELECT id FROM anak WHERE id = ? FOR UPDATE", [
            data.anak_id,
        ]);
        const [active] = await conn.query(
            `SELECT r.id FROM rujukan r
            JOIN pengukuran p ON p.id = r.pengukuran_id
            WHERE p.anak_id = ? AND r.status != 'selesai'
            LIMIT 1`,
            [data.anak_id],
        );
        if (active[0]) {
            await conn.rollback();
            return null;
        }

        const [result] = await conn.query(
            `INSERT INTO rujukan
            (kader_id, puskesmas_id, pengukuran_id, status, catatan_kader)
            VALUES (?, NULL, ?, 'diajukan', ?)`,
            [data.kader_id, data.pengukuran_id, data.catatan_kader],
        );
        await conn.commit();
        return result.insertId;
    } catch (err) {
        await conn.rollback();
        throw err;
    } finally {
        conn.release();
    }
};

const buildListFilter = ({ search, status } = {}, { includeStatus = true } = {}) => {
    const clauses = [];
    const params = [];
    if (search) {
        clauses.push(
            "(a.nama LIKE ? ESCAPE '!' OR ot.nama_lengkap LIKE ? ESCAPE '!')",
        );
        const pattern = toLikePattern(search);
        params.push(pattern, pattern);
    }
    if (includeStatus && status === "aktif") {
        clauses.push("r.status != 'selesai'");
    } else if (includeStatus && status) {
        clauses.push("r.status = ?");
        params.push(status);
    }
    return {
        sql: clauses.length ? `WHERE ${clauses.join(" AND ")}` : "",
        params,
    };
};

const listJoins = `
    FROM rujukan r
    JOIN pengukuran p ON p.id = r.pengukuran_id
    JOIN anak a ON a.id = p.anak_id
    JOIN orang_tua ot ON ot.id = a.orang_tua_id`;

export const buatFindAll = (database = db) => async ({
    page = 1,
    limit = 20,
    search,
    status,
} = {}) => {
    const offset = (page - 1) * limit;
    const filter = buildListFilter({ search, status });
    const summaryFilter = buildListFilter(
        { search },
        { includeStatus: false },
    );
    const [rows] = await database.query(
        `SELECT
            r.id,
            r.pengukuran_id,
            r.status,
            r.catatan_kader,
            r.catatan_puskesmas,
            r.created_at,
            r.validated_at,
            r.completed_at,
            a.nama AS nama_anak,
            a.tanggal_lahir,
            a.jenis_kelamin,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua,
            k.nama_lengkap AS nama_kader,
            p.berat_badan,
            p.tinggi_badan,
            DATE_FORMAT(p.tanggal_ukur, '%Y-%m-%d') AS tanggal_ukur,
            pu.nama_lengkap AS ditangani_oleh
        FROM rujukan r
        JOIN pengukuran p ON p.id = r.pengukuran_id
        JOIN anak a ON a.id = p.anak_id
        JOIN orang_tua ot ON ot.id = a.orang_tua_id
        JOIN kader k ON k.id = r.kader_id
        LEFT JOIN puskesmas pu ON pu.id = r.puskesmas_id
        ${filter.sql}
        ORDER BY r.created_at DESC
        LIMIT ? OFFSET ?`,
        [...filter.params, limit, offset],
    );
    const [[{ total }]] = await database.query(
        `SELECT COUNT(*) AS total ${listJoins} ${filter.sql}`,
        filter.params,
    );
    const [[summary = {}]] = await database.query(
        `SELECT
            SUM(r.status = 'diajukan') AS diajukan,
            SUM(r.status = 'ditangani') AS ditangani,
            SUM(r.status = 'selesai') AS selesai
         ${listJoins}
         ${summaryFilter.sql}`,
        summaryFilter.params,
    );
    return {
        items: rows,
        total: Number(total),
        summary: {
            diajukan: Number(summary.diajukan || 0),
            ditangani: Number(summary.ditangani || 0),
            selesai: Number(summary.selesai || 0),
        },
    };
};

export const findAll = buatFindAll();

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            r.*,
            a.nama                                   AS nama_anak,
            DATE_FORMAT(a.tanggal_lahir, '%Y-%m-%d') AS tanggal_lahir,
            a.jenis_kelamin,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp        AS no_hp_orang_tua,
            k.nama_lengkap  AS nama_kader,
            DATE_FORMAT(p.tanggal_ukur, '%Y-%m-%d')  AS tanggal_ukur,
            CAST(p.berat_badan  AS DECIMAL(5,2))     AS berat_badan,
            CAST(p.tinggi_badan AS DECIMAL(5,2))     AS tinggi_badan,
            p.anak_id,
            pu.nama_lengkap AS ditangani_oleh
        FROM rujukan r
        JOIN pengukuran p        ON p.id  = r.pengukuran_id
        JOIN anak a              ON a.id  = p.anak_id
        JOIN orang_tua ot        ON ot.id = a.orang_tua_id
        JOIN kader k             ON k.id  = r.kader_id
        LEFT JOIN puskesmas pu   ON pu.id = r.puskesmas_id
        WHERE r.id = ?`,
        [id],
    );

    if (!rows[0]) return null;

    return {
        ...rows[0],
        berat_badan: parseFloat(rows[0].berat_badan),
        tinggi_badan: parseFloat(rows[0].tinggi_badan),
    };
};

export const findByAnak = async (anak_id) => {
    const [rows] = await db.query(
        `SELECT
            r.id,
            r.pengukuran_id,
            r.status,
            r.catatan_kader,
            r.catatan_puskesmas,
            r.created_at,
            r.validated_at,
            r.completed_at,
            DATE_FORMAT(p.tanggal_ukur, '%Y-%m-%d') AS tanggal_ukur,
            CAST(p.berat_badan AS DECIMAL(5,2)) AS berat_badan,
            CAST(p.tinggi_badan AS DECIMAL(5,2)) AS tinggi_badan,
            pu.nama_lengkap AS ditangani_oleh
        FROM rujukan r
        JOIN pengukuran p ON p.id = r.pengukuran_id
        LEFT JOIN puskesmas pu ON pu.id = r.puskesmas_id
        WHERE p.anak_id = ?
        ORDER BY r.created_at DESC`,
        [anak_id],
    );
    return rows;
};

export const findAktifByAnak = async (anak_id) => {
    const [rows] = await db.query(
        `SELECT r.id FROM rujukan r
        JOIN pengukuran p ON p.id = r.pengukuran_id
        WHERE p.anak_id = ?
        AND r.status != 'selesai'`,
        [anak_id],
    );
    return rows[0] || null;
};

export const updateStatus = async (id, data) => {
    const [result] = await db.query(
        `UPDATE rujukan
        SET status = ?,
        catatan_puskesmas = COALESCE(?, catatan_puskesmas),
        puskesmas_id = ?,
        validated_at = CASE
            WHEN ? = 'ditangani' AND validated_at IS NULL THEN NOW()
            ELSE validated_at END,
        completed_at = CASE
            WHEN ? = 'selesai' AND completed_at IS NULL THEN NOW()
            ELSE completed_at END
        WHERE id = ? AND status = ?`,
        [
            data.status,
            data.catatan_puskesmas || null,
            data.puskesmas_id,
            data.status,
            data.status,
            id,
            data.current_status,
        ],
    );
    return result.affectedRows === 1;
};
