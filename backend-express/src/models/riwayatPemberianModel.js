import db from "../database/connection.js";

export const create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO riwayat_pemberian
        (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
            data.anak_id,
            data.kader_id,
            data.jenis,
            data.nama_item,
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
            rp.id,
            rp.jenis,
            rp.nama_item,
            rp.dosis,
            rp.tanggal_pemberian,
            rp.keterangan,
            rp.created_at,
            k.nama_lengkap AS dicatat_oleh
        FROM riwayat_pemberian rp
        JOIN kader k ON k.id = rp.kader_id
        WHERE rp.anak_id = ?`;

    const params = [anak_id];

    if (jenis) {
        query += `AND rp.jenis = ?`;
        params.push(jenis);
    }

    query += `ORDER BY rp.tanggal_pemberian DESC`;

    const [rows] = await db.query(query, params);
    return rows;
};
