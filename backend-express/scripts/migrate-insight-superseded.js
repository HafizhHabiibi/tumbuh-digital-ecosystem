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
    const sql = await fs.readFile(
        new URL(
            "../src/database/migrations/20260831_insight_superseded.sql",
            import.meta.url,
        ),
        "utf8",
    );
    const [results] = await connection.query(sql);
    const updateResult = Array.isArray(results) ? results.at(-1) : results;
    console.log(
        `Migration insight superseded berhasil diterapkan; ${updateResult.affectedRows} pengukuran historis diperbarui`,
    );
} finally {
    await connection.end();
}
