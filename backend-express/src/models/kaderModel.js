import db from "../database/connection.js";

export const findByUserId = async (user_id) => {
    const [rows] = await db.query(
        `SELECT
            k.id,
            k.user_id,
            k.nama_lengkap,
            k.no_hp,
            u.email,
            u.role,
            u.is_active
        FROM kader k
        JOIN users u ON u.id = k.user_id
        WHERE k.user_id = ?`,
        [user_id],
    );
    return rows[0] || null;
};
