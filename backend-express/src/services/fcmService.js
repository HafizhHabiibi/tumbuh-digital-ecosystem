import admin from "firebase-admin";
import db from "../database/connection.js";

let initialized = false;

const initFirebase = () => {
    if (initialized) return;

    try {
        const encodedCredential = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
        const useApplicationDefault =
            process.env.FIREBASE_USE_APPLICATION_DEFAULT === "true" ||
            Boolean(process.env.GOOGLE_APPLICATION_CREDENTIALS);

        if (!encodedCredential && !useApplicationDefault) {
            console.warn(
                "[FCM WARNING] Credential Firebase tidak dikonfigurasi",
            );
            return;
        }

        const credential = encodedCredential
            ? admin.credential.cert(
                JSON.parse(
                    Buffer.from(encodedCredential, "base64").toString("utf8"),
                ),
            )
            : admin.credential.applicationDefault();

        admin.initializeApp({
            credential,
        });
        initialized = true;
        console.log("[FCM] firebase admin berhasil diinisialisasi");
    } catch (err) {
        console.warn("[FCM WARNING] Firebase tidak dikonfigurasi", err.message);
    }
};

initFirebase();

const dispatchOutboxItem = async (outboxId) => {
    if (!initialized) {
        return { success: false, reason: "not_configured" };
    }

    const [claim] = await db.query(
        `UPDATE notification_outbox
        SET status = 'processing', attempts = attempts + 1
        WHERE id = ?
        AND status = 'pending'
        AND attempts < 5
        AND available_at <= NOW()`,
        [outboxId],
    );
    if (claim.affectedRows === 0) {
        return { success: false, reason: "already_processed" };
    }

    const [rows] = await db.query(
        `SELECT id, orang_tua_id, fcm_token, judul, pesan, attempts
        FROM notification_outbox WHERE id = ?`,
        [outboxId],
    );
    const item = rows[0];
    if (!item) return { success: false, reason: "not_found" };

    try {
        await admin.messaging().send({
            token: item.fcm_token,
            notification: { title: item.judul, body: item.pesan },
        });
        await db.query(
            `UPDATE notification_outbox
            SET status = 'sent', sent_at = NOW(), last_error = NULL
            WHERE id = ?`,
            [outboxId],
        );
        return { success: true };
    } catch (err) {
        const invalidToken =
            err.code === "messaging/registration-token-not-registered" ||
            err.code === "messaging/invalid-registration-token";

        if (invalidToken) {
            await db.query(
                "UPDATE orang_tua SET fcm_token = NULL WHERE id = ?",
                [item.orang_tua_id],
            );
        }

        const terminal = invalidToken || item.attempts >= 5;
        await db.query(
            `UPDATE notification_outbox
            SET status = ?, last_error = ?,
                available_at = DATE_ADD(NOW(), INTERVAL LEAST(60, POW(2, attempts)) MINUTE)
            WHERE id = ?`,
            [terminal ? "failed" : "pending", err.message.slice(0, 500), outboxId],
        );
        return { success: false, reason: err.message };
    }
};

export const sendNotification = async (
    orang_tua_id,
    judul,
    pesan,
    tipe,
    referensi_id = null,
) => {
    const conn = await db.getConnection();
    let transactionOpen = false;
    try {
        await conn.beginTransaction();
        transactionOpen = true;
        const [rows] = await conn.query(
            `SELECT fcm_token FROM orang_tua WHERE id = ?`,
            [orang_tua_id],
        );
        const fcm_token = rows[0]?.fcm_token;

        const [notificationResult] = await conn.query(
            `INSERT INTO notifikasi
            (orang_tua_id, rujukan_id, jadwal_id, pengukuran_id, judul, pesan, tipe)
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [
                orang_tua_id,
                tipe === "rujukan" ? referensi_id : null,
                tipe === "jadwal" ? referensi_id : null,
                tipe === "pengukuran" ? referensi_id : null,
                judul,
                pesan,
                tipe,
            ],
        );

        let outboxId = null;
        if (fcm_token) {
            const [outboxResult] = await conn.query(
                `INSERT INTO notification_outbox
                (notification_id, orang_tua_id, fcm_token, judul, pesan)
                VALUES (?, ?, ?, ?, ?)`,
                [
                    notificationResult.insertId,
                    orang_tua_id,
                    fcm_token,
                    judul,
                    pesan,
                ],
            );
            outboxId = outboxResult.insertId;
        }

        await conn.commit();
        transactionOpen = false;

        if (!fcm_token) {
            return { success: false, reason: "no_token" };
        }

        if (!initialized) {
            return { success: false, reason: "not_configured" };
        }

        return dispatchOutboxItem(outboxId);
    } catch (err) {
        if (transactionOpen) await conn.rollback();
        console.error(`[FCM ERROR] ${err.message}`);
        return { success: false, reason: err.message };
    } finally {
        conn.release();
    }
};

export const processPendingNotifications = async (limit = 50) => {
    if (!initialized) return { processed: 0 };

    const safeLimit = Math.min(100, Math.max(1, Number(limit) || 50));
    await db.query(
        `UPDATE notification_outbox SET status = 'pending'
        WHERE status = 'processing'
        AND updated_at < DATE_SUB(NOW(), INTERVAL 5 MINUTE)`,
    );
    const [rows] = await db.query(
        `SELECT id FROM notification_outbox
        WHERE status = 'pending'
        AND attempts < 5 AND available_at <= NOW()
        ORDER BY id ASC LIMIT ?`,
        [safeLimit],
    );

    const concurrency = 5;
    let cursor = 0;
    const workers = Array.from(
        { length: Math.min(concurrency, rows.length) },
        async () => {
            while (cursor < rows.length) {
                const item = rows[cursor++];
                await dispatchOutboxItem(item.id);
            }
        },
    );
    await Promise.all(workers);
    return { processed: rows.length };
};

export const sendBulkNotifications = async (
    recipients,
    createPayload,
    concurrency = 5,
) => {
    let cursor = 0;
    const results = [];
    const workers = Array.from(
        { length: Math.min(concurrency, recipients.length) },
        async () => {
            while (cursor < recipients.length) {
                const recipient = recipients[cursor++];
                const payload = createPayload(recipient);
                results.push(await sendNotification(recipient.id, ...payload));
            }
        },
    );
    await Promise.all(workers);
    return results;
};
