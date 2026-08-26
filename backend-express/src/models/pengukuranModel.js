import db from "../database/connection.js";

export const createPengukuran = async (data) => {
    const [result] = await db.query(
        `INSERT INTO pengukuran
        (anak_id, kader_id, tanggal_ukur, berat_badan,
        tinggi_badan, lingkar_kepala, lingkar_lengan)
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
            data.anak_id,
            data.kader_id,
            data.tanggal_ukur,
            data.berat_badan,
            data.tinggi_badan,
            data.lingkar_kepala || null,
            data.lingkar_lengan || null,
        ],
    );
    return result.insertId;
};

export const findDuplicate = async (anak_id, tanggal_ukur) => {
    const [rows] = await db.query(
        `SELECT id FROM pengukuran
        WHERE anak_id = ? AND tanggal_ukur = ?`,
        [anak_id, tanggal_ukur],
    );
    return rows[0] || null;
};

export const findByAnak = async (anak_id) => {
    const [rows] = await db.query(
        `SELECT
            p.id,
            p.tanggal_ukur,
            p.berat_badan,
            p.tinggi_badan,
            p.lingkar_kepala,
            p.lingkar_lengan,
            p.created_at
        FROM pengukuran p
        WHERE p.anak_id = ?
        ORDER BY p.tanggal_ukur DESC`,
        [anak_id],
    );
    return rows;
};

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            p.id,
            p.anak_id,
            p.kader_id,
            p.tanggal_ukur,
            p.berat_badan,
            p.tinggi_badan,
            p.lingkar_kepala,
            p.lingkar_lengan,
            p.created_at,
            a.nama AS nama_anak,
            a.jenis_kelamin,
            a.tanggal_lahir,
            ot.nama_lengkap AS nama_orang_tua
        FROM pengukuran p
        JOIN anak a ON a.id = p.anak_id
        JOIN orang_tua ot ON ot.id = a.orang_tua_id
        WHERE p.id = ?`,
        [id],
    );
    return rows[0] || null;
};

export const updateInsight = async (pengukuran_id, insight_teks) => {
    await db.query(
        `UPDATE pengukuran SET insight_teks = ? WHERE id = ?`,
        [insight_teks, pengukuran_id],
    );
};

/**
 * Ambil pengukuran terakhir setiap anak (untuk ranking & dashboard).
 * Mengembalikan raw data + info anak untuk dihitung on-the-fly.
 */
export const findLatestPerAnak = async () => {
    const [rows] = await db.query(
        `SELECT
            p.id,
            p.anak_id,
            p.tanggal_ukur,
            p.berat_badan,
            p.tinggi_badan,
            p.created_at,
            a.nama AS nama_anak,
            a.jenis_kelamin,
            a.tanggal_lahir,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua
        FROM pengukuran p
        JOIN anak a ON a.id = p.anak_id
        JOIN orang_tua ot ON ot.id = a.orang_tua_id
        WHERE p.id = (
            SELECT p2.id FROM pengukuran p2
            WHERE p2.anak_id = p.anak_id
            ORDER BY p2.tanggal_ukur DESC
            LIMIT 1
        )`,
    );
    return rows;
};

/**
 * Ambil BB pengukuran sebelumnya untuk hitung tren BB.
 */
export const findPrevious = async (anak_id, tanggal_ukur) => {
    const [rows] = await db.query(
        `SELECT berat_badan, tanggal_ukur FROM pengukuran
        WHERE anak_id = ? AND tanggal_ukur < ?
        ORDER BY tanggal_ukur DESC
        LIMIT 1`,
        [anak_id, tanggal_ukur],
    );
    return rows[0] || null;
};

/**
 * Ambil semua pengukuran dalam rentang bulan tertentu (untuk tren dashboard).
 */
export const findByPeriode = async (bulan) => {
    const [rows] = await db.query(
        `SELECT
            p.id,
            p.anak_id,
            p.tanggal_ukur,
            p.berat_badan,
            p.tinggi_badan,
            a.jenis_kelamin,
            a.tanggal_lahir
        FROM pengukuran p
        JOIN anak a ON a.id = p.anak_id
        WHERE p.tanggal_ukur >= DATE_SUB(NOW(), INTERVAL ? MONTH)
        ORDER BY p.tanggal_ukur ASC`,
        [bulan],
    );
    return rows;
};
