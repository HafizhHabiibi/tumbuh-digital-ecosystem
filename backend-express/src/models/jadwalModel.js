import db from "../database/db,js";

export const create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO jadwal_posyandu
        (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES (?, ?, ?, ?, ?, ?)`,
        [
            data.kader_id,
            data.tanggal,
            data.waktu_mulai,
            data.waktu_selesai,
            data.lokasi,
            data.keterangan || null,
        ],
    );
    return result.insertId;
};

export const findAll = async () => {
    const [rows] = await db.query(
        `SELECT
            j.id,
            DATE_FORMAT(j.tanggal, '%Y-%m-%d') AS tanggal,
            j.waktu_mulai,
            j.waktu_selesai,
            j.lokasi,
            j.keterangan,
            j.created_at,
            k.nama_lengkap AS dibuat_oleh
        FROM jadwal_posyandu j
        JOIN kader k ON k.id = j.kader_id
        ORDER BY j.tanggal DESC`,
    );
    return rows;
};

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            j.id,
            DATE_FORMAT(j.tanggal, '%Y-%m-%d') AS tanggal,
            j.waktu_mulai,
            j.waktu_selesai,
            j.lokasi,
            j.keterangan,
            j.created_at,
            k.nama_lengkap AS dibuat_oleh
        FROM jadwal_posyandu j
        JOIN kader k ON k.id = j.kader_id
        WHERE j.id = ?`,
        [id],
    );
    return rows[0] || null;
};

export const findAllOrangTua = async () => {
    const [rows] = await db.query("SELECT id, nama_lengkap FROM orang_tua");
    return rows;
};
