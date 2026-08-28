import db from "../database/connection.js";
import { uuidv7 } from "uuidv7";

export const findAll = async (page = 1, limit = 20) => {
    const offset = (page - 1) * limit;
    const [rows] = await db.query(
        `SELECT
            ot.id,
            ot.nama_lengkap,
            ot.no_hp,
            ot.alamat,
            ot.nik,
            ot.created_at,
            u.email,
            k.nama_lengkap AS dibuat_oleh
        FROM orang_tua ot
        JOIN users u ON u.id = ot.user_id
        LEFT JOIN kader k ON k.id = ot.dibuat_oleh_kader_id
        ORDER BY ot.created_at DESC
        LIMIT ? OFFSET ?`,
        [limit, offset],
    );
    const [[{ total }]] = await db.query(
        "SELECT COUNT(*) AS total FROM orang_tua",
    );
    return { items: rows, total: Number(total) };
};

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            ot.id,
            ot.nama_lengkap,
            ot.no_hp,
            ot.alamat,
            ot.nik,
            ot.created_at,
            u.email,
            k.nama_lengkap AS dibuat_oleh
        FROM orang_tua ot
        JOIN users u ON u.id = ot.user_id
        LEFT JOIN kader k ON k.id = ot.dibuat_oleh_kader_id
        WHERE ot.id = ?`,
        [id],
    );
    return rows[0] || null;
};

export const findByUserId = async (user_id) => {
    const [rows] = await db.query(
        `SELECT ot.*, u.email 
         FROM orang_tua ot
         JOIN users u ON u.id = ot.user_id
         WHERE ot.user_id = ?`,
        [user_id],
    );
    return rows[0] || null;
};

export const findByEmail = async (email) => {
    const [rows] = await db.query(
        `SELECT u.email FROM users u WHERE u.email =?`,
        [email],
    );
    return rows[0] || null;
};

export const findByNik = async (nik) => {
    const [rows] = await db.query(`SELECT id FROM orang_tua WHERE nik =?`, [
        nik,
    ]);
    return rows[0] || null;
};

export const create = async (data, kader_id) => {
    const userId = uuidv7();
    const orangTuaId = uuidv7();

    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        await conn.query(
            `INSERT INTO users (id, email, password_hash, role, is_active)
            VALUES (?, ?, ?, 'orang_tua', TRUE)`,
            [userId, data.email, data.password_hash],
        );

        await conn.query(
            `INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik)
            VALUES (?,?,?,?,?,?,?)`,
            [
                orangTuaId,
                userId,
                kader_id,
                data.nama_lengkap,
                data.no_hp,
                data.alamat,
                data.nik,
            ],
        );

        await conn.commit();
        return { id: orangTuaId, userId: userId };
    } catch (err) {
        await conn.rollback();
        throw err;
    } finally {
        conn.release();
    }
};

export const updateFcmToken = async (user_id, fcm_token) => {
    await db.query(
        `UPDATE orang_tua SET fcm_token = ? WHERE user_id = ?`,
        [fcm_token, user_id],
    );
};

export const update = async (id, data) => {
    await db.query(
        `UPDATE orang_tua
        SET nama_lengkap = ?, no_hp = ?, alamat = ?, nik = ?
        WHERE id = ?`,
        [data.nama_lengkap, data.no_hp, data.alamat, data.nik, id],
    );
};

export const findByNikExcluding = async (nik, excludeId) => {
    const [rows] = await db.query(
        `SELECT id FROM orang_tua WHERE nik = ? AND id != ?`,
        [nik, excludeId],
    );
    return rows[0] || null;
};

export const buatDeleteIfNoChildren = (pool = db) => async (id) => {
    const conn = await pool.getConnection();
    try {
        await conn.beginTransaction();

        const [orangTuaRows] = await conn.query(
            "SELECT user_id FROM orang_tua WHERE id = ? FOR UPDATE",
            [id],
        );
        const orangTua = orangTuaRows[0];
        if (!orangTua) {
            await conn.rollback();
            return { status: "not_found" };
        }

        const [countRows] = await conn.query(
            "SELECT COUNT(*) AS total FROM anak WHERE orang_tua_id = ?",
            [id],
        );
        const totalAnak = Number(countRows[0]?.total || 0);
        if (totalAnak > 0) {
            await conn.rollback();
            return { status: "conflict", total_anak: totalAnak };
        }

        // Menghapus user agar akun, profil orang tua, token, dan notifikasi
        // dibersihkan atomik melalui foreign key yang sudah didefinisikan.
        await conn.query("DELETE FROM users WHERE id = ?", [orangTua.user_id]);
        await conn.commit();
        return { status: "deleted" };
    } catch (error) {
        await conn.rollback();
        throw error;
    } finally {
        conn.release();
    }
};

export const deleteIfNoChildren = buatDeleteIfNoChildren();
