import db from '../database/connection.js';
import crypto from 'crypto';

export const create = async (user_id) => {
    await db.query(
        `DELETE FROM password_reset_token WHERE user_id =?`, [user_id]
    )

    const token = crypto.randomBytes(32).toString('hex');

    await db.query(
        `INSERT INTO password_reset_token (user_id, token, expired_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))`, [user_id, token] 
    )

    return token;
}

export const findValidToken = async (token) => {
    const [rows] = await db.query(
        `SELECT * FROM password_reset_token WHERE token = ? AND expired_at > NOW() AND used_at IS NULL`, [token]
    )
    return rows[0] || null;
}

export const markAsUsed = async (token) => {
    await db.query(
        `UPDATE password_reset_token SET used_at = NOW() WHERE token = ?`, [token]
    )
}


