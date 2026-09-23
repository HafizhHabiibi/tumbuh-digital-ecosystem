import mysql from "mysql2/promise";
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import "dotenv/config";

const required = ["DB_HOST", "DB_USER", "DB_NAME"];
const missing = required.filter((key) => !process.env[key]?.trim());
if (missing.length > 0) {
    throw new Error(`Environment database belum lengkap: ${missing.join(", ")}`);
}

const defaultSeederPath = fileURLToPath(new URL("./seeder.sql", import.meta.url));
const seederPath = process.argv[2]
    ? path.resolve(process.cwd(), process.argv[2])
    : defaultSeederPath;
const sql = await fs.readFile(seederPath, "utf8");

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
    await connection.query(sql);
    console.log(
        `Seeder ${path.basename(seederPath)} berhasil dijalankan pada database ${process.env.DB_NAME}`,
    );
} finally {
    await connection.end();
}
