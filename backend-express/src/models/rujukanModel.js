import db from "../database/connection.js";

export const create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO rujukan
        (kader_id, puskesmas_id, pengukuran_id, status, catatan_kader)
        VALUES (?, NULL, ?, 'diajukan', ?)`,
        [data.kader_id, data.pengukuran_id, data.catatan_kader],
    );
    return result.insertId;
};

export const findAll = async () => {
    const [rows] = await db.query(
        `SELECT
            r.id,
            r.status,
            r.catatan_kader,
            r.catatan_puskesmas,
            r.created_at,
            r.validated_at,
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
        ORDER BY r.created_at DESC`,
    );
    return rows;
};

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
            r.status,
            r.catatan_kader,
            r.catatan_puskesmas,
            r.created_at,
            r.validated_at,
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
    await db.query(
        `UPDATE rujukan
        SET status = ?,
        catatan_puskesmas = ?,
        puskesmas_id = ?,
        validated_at = CASE 
            WHEN validated_at IS NULL THEN NOW()
            ELSE validated_at END
        WHERE id = ?`,
        [
            data.status,
            data.catatan_puskesmas || null,
            data.puskesmas_id,
            id,
        ],
    );
};
