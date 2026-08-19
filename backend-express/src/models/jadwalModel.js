import db from "../database/connection.js";

// =============================================================================
// PENGATURAN JADWAL (Template/Config — singleton)
// =============================================================================

export const getPengaturan = async () => {
    const [rows] = await db.query("SELECT * FROM pengaturan_jadwal LIMIT 1");
    return rows[0] || null;
};

export const upsertPengaturan = async (data) => {
    const existing = await getPengaturan();

    if (existing) {
        await db.query(
            `UPDATE pengaturan_jadwal
            SET hari_tetap = ?, waktu_mulai = ?, waktu_selesai = ?,
                lokasi_default = ?, updated_by = ?
            WHERE id = ?`,
            [
                data.hari_tetap,
                data.waktu_mulai,
                data.waktu_selesai,
                data.lokasi_default,
                data.updated_by,
                existing.id,
            ],
        );
        return { id: existing.id, created: false };
    }

    const [result] = await db.query(
        `INSERT INTO pengaturan_jadwal
        (hari_tetap, waktu_mulai, waktu_selesai, lokasi_default, updated_by)
        VALUES (?, ?, ?, ?, ?)`,
        [
            data.hari_tetap,
            data.waktu_mulai,
            data.waktu_selesai,
            data.lokasi_default,
            data.updated_by,
        ],
    );
    return { id: result.insertId, created: true };
};

// =============================================================================
// JADWAL POSYANDU (Instance per bulan)
// =============================================================================

export const create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO jadwal_posyandu
        (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan)
        VALUES (?, ?, ?, ?, ?, ?)`,
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

export const findByTanggal = async (tanggal) => {
    const [rows] = await db.query(
        `SELECT id FROM jadwal_posyandu WHERE tanggal = ? LIMIT 1`,
        [tanggal],
    );
    return rows[0] || null;
};

export const update = async (id, data) => {
    await db.query(
        `UPDATE jadwal_posyandu
        SET tanggal = ?, waktu_mulai = ?, waktu_selesai = ?,
            lokasi = ?, keterangan = ?
        WHERE id = ?`,
        [
            data.tanggal,
            data.waktu_mulai,
            data.waktu_selesai,
            data.lokasi,
            data.keterangan || null,
            id,
        ],
    );
};

export const deleteById = async (id) => {
    await db.query("DELETE FROM jadwal_posyandu WHERE id = ?", [id]);
};

/**
 * Cek apakah tanggal sudah dipakai jadwal lain (exclude jadwal tertentu).
 * Digunakan saat edit jadwal untuk menghindari duplikasi tanggal.
 */
export const findByTanggalExcluding = async (tanggal, excludeId) => {
    const [rows] = await db.query(
        `SELECT id FROM jadwal_posyandu
        WHERE tanggal = ? AND id != ?
        LIMIT 1`,
        [tanggal, excludeId],
    );
    return rows[0] || null;
};

export const findAllOrangTua = async () => {
    const [rows] = await db.query("SELECT id, nama_lengkap FROM orang_tua");
    return rows;
};
