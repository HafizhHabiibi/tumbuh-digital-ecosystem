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

export const sendNotification = async (
    orang_tua_id,
    judul,
    pesan,
    tipe,
    referensi_id = null,
) => {
    try {
        const [rows] = await db.query(
            `SELECT fcm_token FROM orang_tua WHERE id = ?`,
            [orang_tua_id],
        );
        const fcm_token = rows[0]?.fcm_token;

        await db.query(
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

        if (!fcm_token) {
            console.log(`[FCM SKIP] Token tidak ada - "${judul}"`);
            return { success: false, reason: "no_token" };
        }

        if (!initialized) {
            console.log(`[FCM SKIP] Firebase belum dikonfigurasi - "${judul}"`);
            return { success: false, reason: "not_configured" };
        }

        await admin.messaging().send({
            token: fcm_token,
            notification: { title: judul, body: pesan },
        });

        console.log(
            `[FCM OK] "${judul}" terkirim ke orang_tua_id: ${orang_tua_id}`,
        );
        return { success: true };
    } catch (err) {
        if (err.code === "messaging/registration-token-not-registered") {
            console.warn("[FCM] Token tidak valid, menghapus dari DB");
            await db.query(
                `UPDATE orang_tua SET fcm_token = NULL WHERE id = ?`,
                [orang_tua_id],
            );
            return { success: false, reason: "invalid_token" };
        }
        console.error(`[FCM ERROR] ${err.message}`);
        return { success: false, reason: err.message };
    }
};
