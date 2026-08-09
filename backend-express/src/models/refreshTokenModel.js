import db from "../database/connection.js";

export const save = async (userId, token, expiresAt) => {
    // INSERT biasa — setiap login menghasilkan row baru (multi-device support)
    await db.query(
        `INSERT INTO refresh_tokens (user_id, token, expires_at)
         VALUES (?, ?, ?)`,
        [userId, token, expiresAt],
    );
};


export const findValid = async (userId, token) => {
    const [rows] = await db.query(
        `SELECT * FROM refresh_tokens
         WHERE user_id = ? AND token = ? AND expires_at > NOW() AND revoked = 0`,
        [userId, token],
    );
    return rows[0] || null;
};

export const revoke = async (token) => {
    await db.query(`UPDATE refresh_tokens SET revoked = 1 WHERE token = ?`, [
        token,
    ]);
};

export const revokeAllByUser = async (userId) => {
    await db.query(`UPDATE refresh_tokens SET revoked = 1 WHERE user_id = ?`, [
        userId,
    ]);
};
