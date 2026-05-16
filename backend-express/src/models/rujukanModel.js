import db from "../database/connection.js";

export const create = async (data) => {
    const [result] = await db.query(
        `INSERT INTO rujukan
        (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader)
        VALUES (?, ?, NULL, ?, 'diajukan', ?)`,
        [data.anak_id, data.kader_id, data.saw_result_id, data.catatan_kader],
    );
    return result.insertId;
};

export const findAll = async () => {
    const [rows] = await db.query(
        `SELECT
            r.id,
            r.status,
            r.catatan_kader,
            r.catatan_puskesmas,
            r.validated_at,
            a.nama AS nama_anak,
            a.tanggal_lahir,
            a.jenis_kelamin,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp AS no_hp_orang_tua,
            k.nama_lengkap AS nama_kader,
            sr.skor_akhir,
            sr.kategori_risiko,
            pu.nama_lengkap AS ditangani_oleh
        FROM rujukan r
        JOIN anak a ON a.id = r.anak_id
        JOIN orang_tua ot ON ot.id = a.orang_tua_id
        JOIN kader k ON k.id = r.kader_id
        JOIN saw_result sr ON sr.id = r.saw_result_id
        LEFT JOIN puskesmas_user pu ON pu.id = r.puskesmas_user_id
        ORDER BY r.created_at DESC`,
    );
    return rows;
};

export const findById = async (id) => {
    const [rows] = await db.query(
        `SELECT
            r.*,
            a.nama                                   AS nama_anak,
            DATE_FORMAT(a.tanggal_lahir, '%Y-%m-%d') AS tanggal_lahir,
            a.jenis_kelamin,
            ot.nama_lengkap AS nama_orang_tua,
            ot.no_hp        AS no_hp_orang_tua,
            k.nama_lengkap  AS nama_kader,
            CAST(sr.skor_akhir AS DECIMAL(5,4))      AS skor_akhir,
            sr.kategori_risiko,
            DATE_FORMAT(p.tanggal_ukur, '%Y-%m-%d')  AS tanggal_ukur,
            CAST(p.berat_badan  AS DECIMAL(5,2))     AS berat_badan,
            CAST(p.tinggi_badan AS DECIMAL(5,2))     AS tinggi_badan,
            CAST(p.zscore_bbu   AS DECIMAL(6,3))     AS zscore_bbu,
            CAST(p.zscore_tbu   AS DECIMAL(6,3))     AS zscore_tbu,
            CAST(p.zscore_bbtb  AS DECIMAL(6,3))     AS zscore_bbtb,
            p.status_gizi,
            pu.nama_lengkap AS ditangani_oleh
        FROM rujukan r
        JOIN anak a              ON a.id  = r.anak_id
        JOIN orang_tua ot        ON ot.id = a.orang_tua_id
        JOIN kader k             ON k.id  = r.kader_id
        JOIN saw_result sr       ON sr.id = r.saw_result_id
        JOIN pengukuran p        ON p.id  = sr.pengukuran_id
        LEFT JOIN puskesmas_user pu ON pu.id = r.puskesmas_user_id
        WHERE r.id = ?`,
        [id],
    );

    if (!rows[0]) return null;

    return {
        ...rows[0],
        skor_akhir: parseFloat(rows[0].skor_akhir),
        berat_badan: parseFloat(rows[0].berat_badan),
        tinggi_badan: parseFloat(rows[0].tinggi_badan),
        zscore_bbu: parseFloat(rows[0].zscore_bbu),
        zscore_tbu: parseFloat(rows[0].zscore_tbu),
        zscore_bbtb: parseFloat(rows[0].zscore_bbtb),
    };
};

export const findByAnak = async (anak_id) => {
    const [rows] = await db.query(
        `SELECT
            r.id,
            r.status,
            r.catatan_kader,
            r.catatan_puskesmas,
            r.created_at,
            r.validated_at,
            sr.skor_akhir,
            sr.kategori_risiko,
            pu.nama_lengkap AS ditangani_oleh
        FROM rujukan r
        JOIN saw_result sr ON sr.id = r.saw_result_id
        LEFT JOIN puskesmas_user pu ON pu.id = r.puskesmas_user_id
        WHERE r.anak_id = ?
        ORDER BY r.created_at DESC`,
        [anak_id],
    );
    return rows.map((row) => ({
        ...row,
        skor_akhir: row.skor_akhir !== null ? parseFloat(row.skor_akhir) : null,
    }));
};

export const findAktifByAnak = async (anak_id) => {
    const [rows] = await db.query(
        `SELECT id FROM rujukan
        WHERE anak_id =?
        AND status NOT IN ('selesai', 'ditolak')`,
        [anak_id],
    );
    return rows[0] || null;
};

export const updateStatus = async (id, data) => {
    await db.query(
        `UPDATE rujukan
        SET status = ?,
        catatan_puskesmas = ?,
        puskesmas_user_id = ?,
        validated_at = CASE 
            WHEN validated_at IS NULL THEN NOW()
            ELSE validated_at END
        WHERE id = ?`,
        [
            data.status,
            data.catatan_puskesmas || null,
            data.puskesmas_user_id,
            id,
        ],
    );
};
