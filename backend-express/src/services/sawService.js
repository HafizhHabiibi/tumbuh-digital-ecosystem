import db from "../database/connection.js";

const normalisasiZScore = (zscore) => {
    const MIN = -3;
    const MAX = 2;
    const clipped = Math.max(MIN, Math.min(MAX, zscore));
    return 1 - (clipped - MIN) / (MAX - MIN);
};

const normalisasiKehadiran = async (anak_id) => {
    const [rows] = await db.query(
        `SELECT COUNT(*) AS total
        FROM pengukuran
        WHERE anak_id = ?
        AND tanggal_ukur >= DATE_SUB(NOW(), INTERVAL 12 MONTH)`,
        [anak_id],
    );
    const total = parseInt(rows[0].total) || 0;
    return 1 - Math.min(total / 12, 1.0);
};

const tentukanKategoriRisiko = (skor_akhir) => {
    if (skor_akhir > 0.6667) return "tinggi";
    if (skor_akhir > 0.3334) return "sedang";
    return "rendah";
};

export const hitungSAW = async (anak_id, pengukuran_id, zscores) => {
    const [kriteria] = await db.query(
        `SELECT nama_kriteria, bobot FROM saw_kriteria ORDER BY id ASC`,
    );

    if (!kriteria || kriteria.length === 0) {
        throw new Error("Data saw_kriteria tidak ditemukan di database");
    }

    const kehadiran = await normalisasiKehadiran(anak_id);
    const nilaiNormalisasi = {
        zscore_bbu: normalisasiZScore(zscores.zscore_bbu),
        zscore_tbu: normalisasiZScore(zscores.zscore_tbu),
        zscore_bbtb: normalisasiZScore(zscores.zscore_bbtb),
        frekuensi_hadir: kehadiran,
    };

    let skor_akhir = 0;
    const detail = [];

    for (const k of kriteria) {
        const nilai = nilaiNormalisasi[k.nama_kriteria] ?? 0;
        const bobot = parseFloat(k.bobot);
        const skor = parseFloat((bobot * nilai).toFixed(4));

        skor_akhir += skor;

        detail.push({
            nama_kriteria: k.nama_kriteria,
            bobot,
            nilai: parseFloat(nilai.toFixed(4)),
            skor,
        });
    }

    skor_akhir = parseFloat(skor_akhir.toFixed(4));
    const kategori_risiko = tentukanKategoriRisiko(skor_akhir);

    const [result] = await db.query(
        `INSERT INTO saw_result
        (anak_id, pengukuran_id, skor_akhir, kategori_risiko)
        VALUES (?, ?, ?, ?)`,
        [anak_id, pengukuran_id, skor_akhir, kategori_risiko],
    );
    const saw_result_id = result.insertId;

    for (const d of detail) {
        await db.query(
            `INSERT INTO saw_result_detail
            (saw_result_id, nama_kriteria, bobot, nilai, skor)
            VALUES (?, ?, ?, ?, ?)`,
            [saw_result_id, d.nama_kriteria, d.bobot, d.nilai, d.skor],
        );
    }

    return {
        saw_result_id,
        skor_akhir,
        kategori_risiko,
        detail,
    };
};

export const getRankingSAW = async () => {
    const [rows] = await db.query(
        `SELECT
        a.id AS anak_id,
        a.nama AS nama_anak,
        DATE_FORMAT(a.tanggal_lahir,'%Y-%m-%d') AS tanggal_lahir,
        a.jenis_kelamin,
        ot.nama_lengkap AS nama_orang_tua,
        ot.no_hp AS no_hp_orang_tua,
        sr.skor_akhir,
        sr.kategori_risiko,
        sr.calculated_at,
        DATE_FORMAT(p.tanggal_ukur,'%Y-%m-%d') AS tanggal_ukur,
        p.berat_badan,
        p.tinggi_badan,
        p.status_gizi
        FROM anak a
        JOIN orang_tua ot ON ot.id = a.orang_tua_id
        JOIN saw_result sr ON sr.id = (
            SELECT sr2.id FROM saw_result sr2
            JOIN pengukuran p2 ON p2.id = sr2.pengukuran_id
            WHERE sr2.anak_id = a.id
            ORDER BY p2.tanggal_ukur DESC
            LIMIT 1
        )
        JOIN pengukuran p ON p.id = sr.pengukuran_id
        ORDER BY sr.skor_akhir DESC`,
    );
    return rows.map((row) => ({
        ...row,
        skor_akhir: parseFloat(row.skor_akhir),
        berat_badan: parseFloat(row.berat_badan),
        tinggi_badan: parseFloat(row.tinggi_badan),
    }));
};

export const getDetailSAW = async (pengukuran_id) => {
    const [resultRows] = await db.query(
        `SELECT * FROM saw_result WHERE pengukuran_id = ?`,
        [pengukuran_id],
    );

    if (!resultRows[0]) return null;

    const sawResult = resultRows[0];

    const [detailRows] = await db.query(
        `SELECT * FROM saw_result_detail WHERE saw_result_id = ?`,
        [sawResult.id],
    );

    return {
        ...sawResult,
        detail: detailRows,
    };
};
