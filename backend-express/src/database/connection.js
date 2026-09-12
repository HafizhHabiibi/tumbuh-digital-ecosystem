import mysql from "mysql2/promise";
import "dotenv/config";

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    charset: "utf8mb4",
    // Kolom DATETIME MySQL memakai waktu operasional Posyandu (WIB).
    // Membacanya sebagai UTC akan menambahkan offset +7 lagi di client.
    timezone: "+07:00",
    enableKeepAlive: true,
    keepAliveInitialDelay: 0,
});

export default db;
