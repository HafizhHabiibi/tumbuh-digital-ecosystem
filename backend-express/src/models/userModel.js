import db from "../database/connection.js";

export const findByEmail = async (email) => {
    const [rows] = await db.query(
        `SELECT * FROM users WHERE email = ? AND is_active = TRUE`,
        [email],
    );
    return rows[0] || null;
};

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT id, email, role, is_active, password_hash, created_at FROM users WHERE id = ?`,
        [id],
    );
    return rows[0] || null;
};

export const updateResetPasswordAt = async (id) => {
    await db.query(`UPDATE users SET reset_password_at = NOW() WHERE id = ?`, [
        id,
    ]);
};

export const updatePassword = async (id, password_hash) => {
    await db.query(
        `UPDATE users SET password_hash = ?, updated_at = NOW() WHERE id = ?`,
        [password_hash, id],
    );
};

export const findByIdWithResetCheck = async (id) => {
    const [rows] = await db.query(
        `SELECT id, email, role, reset_password_at FROM users WHERE id = ? AND is_active = TRUE`,
        [id],
    );
    return rows[0] || null;
};

