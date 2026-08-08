import db from "../database/connection.js";

export const findDuplicate = async (anak_id, jenis, tanggal_pemberian) => {
    const [rows] = await db.query(
        `SELECT id FROM pemberian
        WHERE anak_id = ? AND jenis = ? AND tanggal_pemberian = ?`,
        [anak_id, jenis, tanggal_pemberian],
    );
    return rows[0] || null;
};

export const create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO pemberian
        (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan
        ) VALUES (?, ?, ?, ?, ?, ?)`,
        [
            data.anak_id,
            data.kader_id,
            data.jenis,
            data.dosis || null,
            data.tanggal_pemberian,
            data.keterangan || null,
        ],
    );
    return result.insertId;
};

export const findByAnak = async (anak_id, jenis = null) => {
    let query = `
        SELECT
            p.id,
            p.jenis,
            p.dosis,
            p.tanggal_pemberian,
            p.keterangan,
            p.created_at,
            k.nama_lengkap AS dicatat_oleh
        FROM pemberian p
        JOIN kader k ON k.id = p.kader_id
        WHERE p.anak_id = ?`;

    const params = [anak_id];

    if (jenis) {
        query += ` AND p.jenis = ?`;
        params.push(jenis);
    }

    query += ` ORDER BY p.tanggal_pemberian DESC`;

    const [rows] = await db.query(query, params);
    return rows;
};
