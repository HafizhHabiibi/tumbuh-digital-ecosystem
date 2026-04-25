import db from "../database/connection.js";
import { uuidv7 } from "uuidv7";

export const findAll = async () => {
    const [rows] = await db.query(
        `SELECT
            ot.id,
            ot.nama_lengkap,
            ot.no_hp,
            ot.alamat,
            ot.created_at,
            u.email,
            k.nama_lengkap AS dibuat_oleh
        FROM orang_tua ot
        JOIN users u ON u.id = ot.user_id
        JOIN kader k ON k.id = ot.dibuat_oleh_kader_id
        ORDER BY ot.created_at DESC`,
    );
    return rows;
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
        JOIN kader k ON k.id = ot.dibuat_oleh_kader_id
        WHERE ot.id = ?`,
        [id],
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

    await db.query(
        `INSERT INTO users (id, email, password_hash, role, is_active)
        VALUES (?, ?, ?, 'orang_tua', TRUE)`,
        [userId, data.email, data.password_hash],
    );

    await db.query(
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
    return { id: orangTuaId, userId: userId };
};
