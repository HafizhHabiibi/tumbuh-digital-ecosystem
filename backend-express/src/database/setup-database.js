import mysql from "mysql2/promise";
import fs from "node:fs/promises";
import "dotenv/config";

const required = ["DB_HOST", "DB_USER", "DB_NAME"];
const missing = required.filter((key) => !process.env[key]?.trim());
if (missing.length > 0) {
    throw new Error(`Environment database belum lengkap: ${missing.join(", ")}`);
}

const databaseName = process.env.DB_NAME;
if (!/^[a-zA-Z0-9_]+$/.test(databaseName)) {
    throw new Error("DB_NAME hanya boleh berisi huruf, angka, dan underscore");
}

const [schema, seeder] = await Promise.all([
    fs.readFile(new URL("./schema.sql", import.meta.url), "utf8"),
    fs.readFile(new URL("./seeder/seeder.sql", import.meta.url), "utf8"),
]);

const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    port: Number(process.env.DB_PORT || 3306),
    charset: "utf8mb4",
    multipleStatements: true,
});

try {
    await connection.query(
        `CREATE DATABASE IF NOT EXISTS \`${databaseName}\` ` +
        "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",
    );
    await connection.query(`USE \`${databaseName}\``);
    await connection.query(schema);
    await connection.query(seeder);
    console.log(`Database ${databaseName} berhasil dibuat dan diisi ulang`);
} finally {
    await connection.end();
}
