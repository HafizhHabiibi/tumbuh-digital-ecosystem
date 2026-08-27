import db from "../database/connection.js";

const mapExchange = (row) => {
    if (!row) return null;
    return {
        user_message: {
            id: row.user_message_id,
            client_message_id: row.client_message_id,
            role: "orang_tua",
            content: row.user_content,
            created_at: row.user_created_at,
        },
        assistant_message: row.assistant_message_id
            ? {
                  id: row.assistant_message_id,
                  role: "assistant",
                  content: row.assistant_content,
                  response_type: row.response_type,
                  created_at: row.assistant_created_at,
              }
            : null,
    };
};

const exchangeQuery = `SELECT
        pengguna.id AS user_message_id,
        pengguna.client_message_id,
        pengguna.content AS user_content,
        pengguna.created_at AS user_created_at,
        assistant.id AS assistant_message_id,
        assistant.content AS assistant_content,
        assistant.response_type,
        assistant.created_at AS assistant_created_at
     FROM chat_messages pengguna
     LEFT JOIN chat_messages assistant
       ON assistant.reply_to_message_id = pengguna.id
     WHERE pengguna.pengukuran_id = ?
       AND pengguna.client_message_id = ?
       AND pengguna.role = 'orang_tua'`;

export const buatChatModel = (database = db) => ({
    async findMeasurementForOrangTua(pengukuranId, orangTuaId) {
        const [rows] = await database.query(
            `SELECT
                p.id,
                p.insight_teks,
                p.insight_status,
                NOT EXISTS (
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
                ) AS is_latest
             FROM pengukuran p
             JOIN anak a ON a.id = p.anak_id
             WHERE p.id = ? AND a.orang_tua_id = ?`,
            [pengukuranId, orangTuaId],
        );
        return rows[0] || null;
    },

    async findLatestMeasurementForOrangTua(pengukuranId, orangTuaId) {
        const [rows] = await database.query(
            `SELECT
                p.id,
                p.tanggal_ukur,
                p.berat_badan,
                p.tinggi_badan,
                p.insight_teks,
                p.insight_status,
                a.jenis_kelamin,
                a.tanggal_lahir
             FROM pengukuran p
             JOIN anak a ON a.id = p.anak_id
             WHERE p.id = ?
               AND a.orang_tua_id = ?
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
               )`,
            [pengukuranId, orangTuaId],
        );
        return rows[0] || null;
    },

    async findRecentMessages(pengukuranId, limit) {
        const safeLimit = Math.min(20, Math.max(1, Number(limit) || 10));
        const [rows] = await database.query(
            `SELECT id, role, content, response_type, created_at
             FROM (
                 SELECT id, role, content, response_type, created_at
                 FROM chat_messages
                 WHERE pengukuran_id = ?
                 ORDER BY created_at DESC, id DESC
                 LIMIT ?
             ) pesan_terbaru
             ORDER BY created_at ASC, id ASC`,
            [pengukuranId, safeLimit],
        );
        return rows;
    },

    async findMessagesPage(pengukuranId, { limit = 50, beforeId = null } = {}) {
        const safeLimit = Math.min(100, Math.max(1, Number(limit) || 50));
        const normalizedBeforeId = beforeId ? Number(beforeId) : null;
        const [rows] = await database.query(
            `SELECT
                id,
                client_message_id,
                reply_to_message_id,
                role,
                content,
                response_type,
                created_at
             FROM chat_messages
             WHERE pengukuran_id = ?
               AND (? IS NULL OR id < ?)
             ORDER BY id DESC
             LIMIT ?`,
            [
                pengukuranId,
                normalizedBeforeId,
                normalizedBeforeId,
                safeLimit + 1,
            ],
        );
        const hasMore = rows.length > safeLimit;
        const items = rows.slice(0, safeLimit).reverse();
        return {
            items,
            hasMore,
            nextBeforeId: hasMore ? items[0]?.id || null : null,
        };
    },

    async findExchangeByClientMessageId(pengukuranId, clientMessageId) {
        const [rows] = await database.query(exchangeQuery, [
            pengukuranId,
            clientMessageId,
        ]);
        return mapExchange(rows[0]);
    },

    async saveExchange({
        pengukuranId,
        clientMessageId,
        userContent,
        assistantContent,
        responseType,
    }) {
        const connection = await database.getConnection();
        try {
            await connection.beginTransaction();
            const [userResult] = await connection.query(
                `INSERT INTO chat_messages
                    (pengukuran_id, client_message_id, role, content)
                 VALUES (?, ?, 'orang_tua', ?)`,
                [pengukuranId, clientMessageId, userContent],
            );
            const [assistantResult] = await connection.query(
                `INSERT INTO chat_messages
                    (pengukuran_id, reply_to_message_id, role, content, response_type)
                 VALUES (?, ?, 'assistant', ?, ?)`,
                [
                    pengukuranId,
                    userResult.insertId,
                    assistantContent,
                    responseType,
                ],
            );
            await connection.commit();

            return {
                reused: false,
                user_message: {
                    id: userResult.insertId,
                    client_message_id: clientMessageId,
                    role: "orang_tua",
                    content: userContent,
                },
                assistant_message: {
                    id: assistantResult.insertId,
                    role: "assistant",
                    content: assistantContent,
                    response_type: responseType,
                },
            };
        } catch (error) {
            await connection.rollback();
            if (error?.code === "ER_DUP_ENTRY") {
                const [rows] = await connection.query(exchangeQuery, [
                    pengukuranId,
                    clientMessageId,
                ]);
                const existing = mapExchange(rows[0]);
                if (existing?.assistant_message) {
                    return { ...existing, reused: true };
                }
                error.code = "CHAT_CLIENT_MESSAGE_ID_CONFLICT";
            }
            throw error;
        } finally {
            connection.release();
        }
    },
});

const chatModel = buatChatModel();
export default chatModel;
