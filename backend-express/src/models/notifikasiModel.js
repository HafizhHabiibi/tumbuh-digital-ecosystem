import db from "../database/connection.js";

export const findByOrangTua = async (orang_tua_id) => {
    const [rows] = await db.query(
        `SELECT
            n.id,
            n.judul,
            n.pesan,
            n.tipe,
            n.sudah_dibaca,
            n.sent_at,
            n.rujukan_id,
            n.jadwal_id
        FROM notifikasi n
        WHERE n.orang_tua_id = ?
        ORDER BY n.sent_at DESC`,
        [orang_tua_id],
    );
    return rows;
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
        WHERE id =? AND orang_tua_id = ?`,
        [id, orang_tua_id],
    );
    return rows[0] || null;
};
