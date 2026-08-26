import db from "../database/connection.js";
import { createHash } from "node:crypto";

export const hashRefreshToken = (token) =>
    createHash("sha256").update(token).digest("hex");

export const save = async (userId, token, expiresAt) => {
    // INSERT biasa — setiap login menghasilkan row baru (multi-device support)
    await db.query(
        `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
         VALUES (?, ?, ?)`,
        [userId, hashRefreshToken(token), expiresAt],
    );
};


export const findValid = async (userId, token) => {
    const [rows] = await db.query(
        `SELECT rt.*, u.role
         FROM refresh_tokens rt
         JOIN users u ON u.id = rt.user_id
         WHERE rt.user_id = ? AND rt.token_hash = ?
         AND rt.expires_at > NOW() AND rt.revoked = 0
         AND u.is_active = TRUE`,
        [userId, hashRefreshToken(token)],
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
            WHERE rt.user_id = ? AND rt.token_hash = ?
            AND rt.expires_at > NOW() AND rt.revoked = 0
            AND u.is_active = TRUE
            FOR UPDATE`,
            [userId, hashRefreshToken(oldToken)],
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
            `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
            VALUES (?, ?, ?)`,
            [userId, hashRefreshToken(newToken), expiresAt],
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
    await db.query(`UPDATE refresh_tokens SET revoked = 1 WHERE token_hash = ?`, [
        hashRefreshToken(token),
    ]);
};

export const revokeAllByUser = async (userId) => {
    await db.query(`UPDATE refresh_tokens SET revoked = 1 WHERE user_id = ?`, [
        userId,
    ]);
};
