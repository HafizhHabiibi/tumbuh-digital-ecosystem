import db from "../database/connection.js";

const MAX_ATTEMPTS = 5;
const LOCKOUT_DURATION_MINUTES = 15;

export const recordFailedAttempt = async (email) => {
    await db.query(
        `INSERT INTO login_attempts (email, attempted_at)
         VALUES (?, NOW())`,
        [email.toLowerCase().trim()],
    );
};

export const clearFailedAttempts = async (email) => {
    await db.query(`DELETE FROM login_attempts WHERE email = ?`, [
        email.toLowerCase().trim(),
    ]);
};

export const checkAccountLockout = async (email) => {
    const windowStart = new Date(
        Date.now() - LOCKOUT_DURATION_MINUTES * 60 * 1000,
    );

    const [rows] = await db.query(
        `SELECT COUNT(*) as attempt_count,
                MAX(attempted_at) as last_attempt
         FROM login_attempts
         WHERE email = ?
           AND attempted_at >= ?`,
        [email.toLowerCase().trim(), windowStart],
    );

    const { attempt_count, last_attempt } = rows[0];

    if (attempt_count >= MAX_ATTEMPTS && last_attempt) {
        const lockoutEnd = new Date(
            new Date(last_attempt).getTime() +
                LOCKOUT_DURATION_MINUTES * 60 * 1000,
        );
        const remainingMs = lockoutEnd - Date.now();

        if (remainingMs > 0) {
            return {
                locked: true,
                remainingMinutes: Math.ceil(remainingMs / 60000),
                attemptCount: attempt_count,
            };
        }
    }

    return {
        locked: false,
        remainingMinutes: 0,
        attemptCount: attempt_count,
    };
};

export const cleanOldAttempts = async () => {
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000); // 24 jam
    const [result] = await db.query(
        `DELETE FROM login_attempts WHERE attempted_at < ?`,
        [cutoff],
    );
    return result.affectedRows;
};
