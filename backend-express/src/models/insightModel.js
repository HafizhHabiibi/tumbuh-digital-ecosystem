import db from "../database/connection.js";

export const buatInsightModel = (database = db) => ({
    async claim(pengukuranId, maxAttempts, leaseSeconds) {
        const [claimResult] = await database.query(
            `UPDATE pengukuran
             SET insight_status = 'processing',
                 insight_attempts = insight_attempts + 1,
                 insight_available_at = DATE_ADD(NOW(), INTERVAL ? SECOND),
                 insight_last_error = NULL
             WHERE id = ?
               AND insight_teks IS NULL
               AND insight_attempts < ?
               AND insight_available_at <= NOW()
               AND insight_status IN ('pending', 'processing')`,
            [leaseSeconds, pengukuranId, maxAttempts],
        );
        if (claimResult.affectedRows === 0) return null;

        const [rows] = await database.query(
            `SELECT
                p.id,
                p.anak_id,
                p.tanggal_ukur,
                p.berat_badan,
                p.tinggi_badan,
                p.insight_attempts,
                a.jenis_kelamin,
                a.tanggal_lahir
             FROM pengukuran p
             JOIN anak a ON a.id = p.anak_id
             WHERE p.id = ?`,
            [pengukuranId],
        );
        return rows[0] || null;
    },

    async complete(pengukuranId, attempt, insightTeks, model) {
        const [result] = await database.query(
            `UPDATE pengukuran
             SET insight_teks = ?,
                 insight_status = 'completed',
                 insight_available_at = NULL,
                 insight_generated_at = NOW(),
                 insight_model = ?,
                 insight_last_error = NULL
             WHERE id = ?
               AND insight_status = 'processing'
               AND insight_attempts = ?`,
            [insightTeks, model, pengukuranId, attempt],
        );
        return result.affectedRows === 1;
    },

    async recordFailure({
        pengukuranId,
        attempt,
        willRetry,
        retryDelaySeconds,
        errorMessage,
    }) {
        const status = willRetry ? "pending" : "failed";
        const [result] = await database.query(
            `UPDATE pengukuran
             SET insight_status = ?,
                 insight_available_at = CASE
                     WHEN ? = 1 THEN DATE_ADD(NOW(), INTERVAL ? SECOND)
                     ELSE NULL
                 END,
                 insight_last_error = ?
             WHERE id = ?
               AND insight_status = 'processing'
               AND insight_attempts = ?`,
            [
                status,
                willRetry ? 1 : 0,
                retryDelaySeconds,
                errorMessage,
                pengukuranId,
                attempt,
            ],
        );
        return result.affectedRows === 1;
    },

    async findDueIds(limit, maxAttempts) {
        const safeLimit = Math.min(50, Math.max(1, Number(limit) || 10));
        const [rows] = await database.query(
            `SELECT p.id
             FROM pengukuran p
             WHERE p.insight_teks IS NULL
               AND p.insight_attempts < ?
               AND p.insight_available_at <= NOW()
               AND p.insight_status IN ('pending', 'processing')
               AND NOT EXISTS (
                   SELECT 1
                   FROM pengukuran terbaru
                   WHERE terbaru.anak_id = p.anak_id
                     AND (
                         terbaru.tanggal_ukur > p.tanggal_ukur
                         OR (
                             terbaru.tanggal_ukur = p.tanggal_ukur
                             AND terbaru.id > p.id
                         )
                     )
               )
             ORDER BY p.insight_available_at ASC, p.id ASC
             LIMIT ?`,
            [maxAttempts, safeLimit],
        );
        return rows.map((row) => row.id);
    },

    async findForOrangTua(pengukuranId, orangTuaId) {
        const [rows] = await database.query(
            `SELECT
                p.insight_teks,
                p.insight_status,
                p.insight_generated_at,
                p.created_at
             FROM pengukuran p
             JOIN anak a ON a.id = p.anak_id
             WHERE p.id = ? AND a.orang_tua_id = ?`,
            [pengukuranId, orangTuaId],
        );
        return rows[0] || null;
    },
});

const insightModel = buatInsightModel();
export default insightModel;
