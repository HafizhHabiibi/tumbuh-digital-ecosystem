import db from "../database/connection.js";
import { randomUUID } from "node:crypto";

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

const exchangeSelect = `SELECT
        pengguna.id AS user_message_id,
        pengguna.pengukuran_id,
        pengguna.client_message_id,
        pengguna.content AS user_content,
        pengguna.created_at AS user_created_at,
        pengguna.request_status,
        (pengguna.request_token IS NOT NULL
         AND pengguna.request_expires_at > UTC_TIMESTAMP()) AS request_in_flight,
        assistant.id AS assistant_message_id,
        assistant.content AS assistant_content,
        assistant.response_type,
        assistant.created_at AS assistant_created_at
     FROM chat_messages pengguna
     LEFT JOIN chat_messages assistant
       ON assistant.reply_to_message_id = pengguna.id`;

const exchangeQuery = `${exchangeSelect}
     WHERE pengguna.pengukuran_id = ?
       AND pengguna.client_message_id = ?
       AND pengguna.role = 'orang_tua'`;

const reservationQuery = `${exchangeSelect}
     WHERE pengguna.client_message_id = ?
       AND pengguna.role = 'orang_tua'
     FOR UPDATE`;

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
                   AND (role = 'assistant' OR request_status = 'completed' OR request_status IS NULL)
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
               AND (role = 'assistant' OR request_status = 'completed' OR request_status IS NULL)
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

    async reserveExchange({
        pengukuranId,
        clientMessageId,
        userContent,
        leaseSeconds = 120,
    }) {
        const safeLeaseSeconds = Math.min(
            300,
            Math.max(10, Number(leaseSeconds) || 120),
        );

        for (let attempt = 0; attempt < 2; attempt += 1) {
            const connection = await database.getConnection();
            try {
                await connection.beginTransaction();
                const [rows] = await connection.query(reservationQuery, [
                    clientMessageId,
                ]);
                const row = rows[0];
                if (row) {
                    if (
                        Number(row.pengukuran_id) !== Number(pengukuranId) ||
                        row.user_content !== userContent
                    ) {
                        const conflict = new Error(
                            "client_message_id sudah digunakan untuk pesan lain",
                        );
                        conflict.code = "CHAT_CLIENT_MESSAGE_ID_CONFLICT";
                        throw conflict;
                    }

                    const existing = mapExchange(row);
                    if (existing.assistant_message) {
                        await connection.commit();
                        return { status: "completed", exchange: existing };
                    }
                    if (row.request_in_flight) {
                        await connection.commit();
                        return { status: "processing" };
                    }

                    const requestToken = randomUUID();
                    await connection.query(
                        `UPDATE chat_messages
                         SET request_status = 'processing',
                             request_token = ?,
                             request_expires_at = DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? SECOND)
                         WHERE id = ?`,
                        [requestToken, safeLeaseSeconds, row.user_message_id],
                    );
                    await connection.commit();
                    return {
                        status: "reserved",
                        requestToken,
                        userMessage: existing.user_message,
                    };
                }

                const requestToken = randomUUID();
                const [result] = await connection.query(
                    `INSERT INTO chat_messages
                        (pengukuran_id, client_message_id, role, content,
                         request_status, request_token, request_expires_at)
                     VALUES (?, ?, 'orang_tua', ?, 'processing', ?,
                             DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? SECOND))`,
                    [
                        pengukuranId,
                        clientMessageId,
                        userContent,
                        requestToken,
                        safeLeaseSeconds,
                    ],
                );
                await connection.commit();
                return {
                    status: "reserved",
                    requestToken,
                    userMessage: {
                        id: result.insertId,
                        client_message_id: clientMessageId,
                        role: "orang_tua",
                        content: userContent,
                    },
                };
            } catch (error) {
                await connection.rollback();
                if (error?.code === "ER_DUP_ENTRY" && attempt === 0) {
                    continue;
                }
                throw error;
            } finally {
                connection.release();
            }
        }
        throw new Error("Reservasi chat gagal");
    },

    async completeExchange({
        userMessage,
        requestToken,
        assistantContent,
        responseType,
    }) {
        const connection = await database.getConnection();
        try {
            await connection.beginTransaction();
            const [owned] = await connection.query(
                `SELECT id FROM chat_messages
                 WHERE id = ? AND role = 'orang_tua'
                   AND request_status = 'processing' AND request_token = ?
                 FOR UPDATE`,
                [userMessage.id, requestToken],
            );
            if (!owned[0]) {
                const error = new Error("Lease reservasi chat tidak lagi aktif");
                error.code = "CHAT_RESERVATION_LOST";
                throw error;
            }

            const [assistantResult] = await connection.query(
                `INSERT INTO chat_messages
                    (pengukuran_id, reply_to_message_id, role, content, response_type)
                 SELECT pengukuran_id, id, 'assistant', ?, ?
                 FROM chat_messages WHERE id = ?`,
                [assistantContent, responseType, userMessage.id],
            );
            await connection.query(
                `UPDATE chat_messages
                 SET request_status = 'completed', request_token = NULL,
                     request_expires_at = NULL
                 WHERE id = ? AND request_token = ?`,
                [userMessage.id, requestToken],
            );
            await connection.commit();
            return {
                user_message: userMessage,
                assistant_message: {
                    id: assistantResult.insertId,
                    role: "assistant",
                    content: assistantContent,
                    response_type: responseType,
                },
            };
        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }
    },

    async releaseReservation({ userMessageId, requestToken }) {
        await database.query(
            `UPDATE chat_messages
             SET request_token = NULL, request_expires_at = UTC_TIMESTAMP()
             WHERE id = ? AND request_status = 'processing'
               AND request_token = ?`,
            [userMessageId, requestToken],
        );
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
                    (pengukuran_id, client_message_id, role, content, request_status)
                 VALUES (?, ?, 'orang_tua', ?, 'completed')`,
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
