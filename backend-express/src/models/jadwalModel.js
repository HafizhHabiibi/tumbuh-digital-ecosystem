import db from "../database/connection.js";

// =============================================================================
// PENGATURAN JADWAL (Template/Config — singleton)
// =============================================================================

export const getPengaturan = async () => {
    const [rows] = await db.query("SELECT * FROM pengaturan_jadwal LIMIT 1");
    return rows[0] || null;
};

export const upsertPengaturan = async (data) => {
    const [result] = await db.query(
        `INSERT INTO pengaturan_jadwal
        (singleton_key, hari_tetap, waktu_mulai, waktu_selesai, lokasi_default, updated_by)
        VALUES (1, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            id = LAST_INSERT_ID(id),
            hari_tetap = VALUES(hari_tetap),
            waktu_mulai = VALUES(waktu_mulai),
            waktu_selesai = VALUES(waktu_selesai),
            lokasi_default = VALUES(lokasi_default),
            updated_by = VALUES(updated_by)`,
        [
            data.hari_tetap,
            data.waktu_mulai,
            data.waktu_selesai,
            data.lokasi_default,
            data.updated_by,
        ],
    );
    return { id: result.insertId, created: result.affectedRows === 1 };
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

export const createMany = async (items) => {
    const conn = await db.getConnection();
    try {
        await conn.beginTransaction();
        const generated = [];
        const skipped = [];

        for (const item of items) {
            const [result] = await conn.query(
                `INSERT IGNORE INTO jadwal_posyandu
                (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan)
                VALUES (?, ?, ?, ?, ?, ?)`,
                [
                    item.kader_id,
                    item.tanggal,
                    item.waktu_mulai,
                    item.waktu_selesai,
                    item.lokasi,
                    item.keterangan || null,
                ],
            );
            if (result.affectedRows === 0) {
                skipped.push(item.tanggal);
                continue;
            }
            generated.push({ id: result.insertId, tanggal: item.tanggal });
        }

        await conn.commit();
        return { generated, skipped };
    } catch (err) {
        await conn.rollback();
        throw err;
    } finally {
        conn.release();
    }
};

export const findAll = async (page = 1, limit = 20) => {
    const offset = (page - 1) * limit;
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
        ORDER BY j.tanggal DESC
        LIMIT ? OFFSET ?`,
        [limit, offset],
    );
    const [[{ total }]] = await db.query(
        "SELECT COUNT(*) AS total FROM jadwal_posyandu",
    );
    return { items: rows, total: Number(total) };
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
