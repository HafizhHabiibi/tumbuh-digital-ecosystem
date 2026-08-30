import fs from "node:fs/promises";
import mysql from "mysql2/promise";
import "dotenv/config";

const required = ["DB_HOST", "DB_USER", "DB_NAME"];
const missing = required.filter((key) => !process.env[key]?.trim());
if (missing.length > 0) {
    throw new Error(`Environment database belum lengkap: ${missing.join(", ")}`);
}

const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: Number(process.env.DB_PORT || 3306),
    charset: "utf8mb4",
    multipleStatements: true,
});

try {
    const [columns] = await connection.query(
        `SELECT COLUMN_NAME
         FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'chat_messages'
           AND COLUMN_NAME IN (
             'request_status', 'request_token', 'request_expires_at'
           )`,
        [process.env.DB_NAME],
    );
    if (columns.length === 3) {
        console.log("Migration reservasi chat sudah diterapkan");
    } else if (columns.length > 0) {
        throw new Error(
            "Schema reservasi chat hanya terpasang sebagian; periksa database secara manual",
        );
    } else {
        const sql = await fs.readFile(
            new URL(
                "../src/database/migrations/20260829_chat_request_reservation.sql",
                import.meta.url,
            ),
            "utf8",
        );
        await connection.query(sql);
        console.log("Migration reservasi chat berhasil diterapkan");
    }
} finally {
    await connection.end();
}
