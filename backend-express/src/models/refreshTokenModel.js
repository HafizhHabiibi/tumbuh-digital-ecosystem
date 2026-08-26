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
        `SELECT rt.*, u.role
         FROM refresh_tokens rt
         JOIN users u ON u.id = rt.user_id
         WHERE rt.user_id = ? AND rt.token = ?
         AND rt.expires_at > NOW() AND rt.revoked = 0
         AND u.is_active = TRUE`,
        [userId, token],
    );
    return rows[0] || null;
};

export const rotate = async (
    userId,
    oldToken,
    newToken,
    expiresAt,
) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();

        const [validRows] = await conn.query(
            `SELECT rt.id
            FROM refresh_tokens rt
            JOIN users u ON u.id = rt.user_id
            WHERE rt.user_id = ? AND rt.token = ?
            AND rt.expires_at > NOW() AND rt.revoked = 0
            AND u.is_active = TRUE
            FOR UPDATE`,
            [userId, oldToken],
        );

        if (!validRows[0]) {
            await conn.rollback();
            return false;
        }

        await conn.query(
            "UPDATE refresh_tokens SET revoked = 1 WHERE id = ?",
            [validRows[0].id],
        );
        await conn.query(
            `INSERT INTO refresh_tokens (user_id, token, expires_at)
            VALUES (?, ?, ?)`,
            [userId, newToken, expiresAt],
        );
        await conn.commit();
        return true;
    } catch (err) {
        await conn.rollback();
        throw err;
    } finally {
        conn.release();
    }
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
