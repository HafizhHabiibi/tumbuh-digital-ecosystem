import { use } from "react";
import db from "../database/connection.js";

export const findByUserId = async (user_id) => {
    const [rows] = await db.query(
        `SELECT * FROM puskesmas_user WHERE user_id = ?`,
        [user_id],
    );
    return rows[0] || null;
};
