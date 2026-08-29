import db from "../database/connection.js";

export const findByOrangTua = async (orang_tua_id, page = 1, limit = 20) => {
    const offset = (page - 1) * limit;
    const [rows] = await db.query(
        `SELECT
            n.id,
            n.judul,
            n.pesan,
            n.tipe,
            n.sudah_dibaca,
            n.sent_at,
            n.rujukan_id,
            n.jadwal_id,
            n.pengukuran_id,
            COALESCE(pengukuran_notif.anak_id, pengukuran_rujukan.anak_id) AS anak_id
        FROM notifikasi n
        LEFT JOIN pengukuran pengukuran_notif
            ON pengukuran_notif.id = n.pengukuran_id
        LEFT JOIN rujukan r ON r.id = n.rujukan_id
        LEFT JOIN pengukuran pengukuran_rujukan
            ON pengukuran_rujukan.id = r.pengukuran_id
        WHERE n.orang_tua_id = ?
        ORDER BY n.sent_at DESC
        LIMIT ? OFFSET ?`,
        [orang_tua_id, limit, offset],
    );
    return rows;
};

export const countByOrangTua = async (orang_tua_id) => {
    const [rows] = await db.query(
        `SELECT COUNT(*) AS total
        FROM notifikasi
        WHERE orang_tua_id = ?`,
        [orang_tua_id],
    );
    return parseInt(rows[0].total) || 0;
};

export const countBelumDibaca = async (orang_tua_id) => {
    const [rows] = await db.query(
        `SELECT COUNT(*) AS total
        FROM notifikasi
        WHERE orang_tua_id = ?
        AND sudah_dibaca = FALSE`,
        [orang_tua_id],
    );
    return parseInt(rows[0].total) || 0;
};

export const tandaiDibaca = async (id, orang_tua_id) => {
    const [result] = await db.query(
        `UPDATE notifikasi
        SET sudah_dibaca = TRUE
        WHERE id = ?
        AND orang_tua_id = ?`,
        [id, orang_tua_id],
    );
    return result.affectedRows;
};

export const tandaiSemuaDibaca = async (orang_tua_id) => {
    const [result] = await db.query(
        `UPDATE notifikasi
        SET sudah_dibaca = TRUE
        WHERE orang_tua_id = ?
        AND sudah_dibaca = FALSE`,
        [orang_tua_id],
    );
    return result.affectedRows;
};

export const findById = async (id, orang_tua_id) => {
    const [rows] = await db.query(
        `SELECT id FROM notifikasi
        WHERE id = ? AND orang_tua_id = ?`,
        [id, orang_tua_id],
    );
    return rows[0] || null;
};

export const deleteById = async (id, orang_tua_id) => {
    const [result] = await db.query(
        `DELETE FROM notifikasi
        WHERE id = ? AND orang_tua_id = ?`,
        [id, orang_tua_id],
    );
    return result.affectedRows;
};

export const deleteSudahDibaca = async (orang_tua_id) => {
    const [result] = await db.query(
        `DELETE FROM notifikasi
        WHERE orang_tua_id = ?
        AND sudah_dibaca = TRUE`,
        [orang_tua_id],
    );
    return result.affectedRows;
};
