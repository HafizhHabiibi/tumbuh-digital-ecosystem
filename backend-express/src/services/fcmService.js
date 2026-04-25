import admin from "firebase-admin";
import { read, readFile, readFileSync } from "fs";
import { success } from "../utils/response";

let initialized = false;

const initFirebase = () => {
    if (initialized) return;

    try {
        const serviceAccount = JSON.parse(
            readFileSync("./firebase-service-account.json", "utf-8"),
        );
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
        initialized = true;
        console.log("[FCM] firebase admin berhasil diinisialisasi");
    } catch (err) {
        console.warn("[FCM WARNING] Firebase tidak dikonfigurasi", err.message);
    }
};

export const kirimNotifikasi = async (fcm_token, judul, pesan, data = {}) => {
    if (!fcm_token) {
        console.log(`[FCM SKIP] Tidak ada token - "${judul}"`);
        return { success: false, reason: "no_token" };
    }

    if (!initialized) {
        console.log(`[FCM SKIP] Firebase belum dikonfigurasi - "${judul}"`);
        return { success: false, reason: "firebase_not_initialized" };
    }

    try {
        await admin.messaging().send({
            token: fcm_token,
            notification: { title: judul, body: pesan },
            data: data,
        });
        console.log(`[FCM OK] "${judul}" terkirim`);
        return { success: true };
    } catch (err) {
        if (err.code === "messaging/registration-token-not-registered") {
            console.warn("[FCM] Token tidak valid, perlu dihapus dari DB");
            return { success: false, reason: "invalid_token" };
        }
        console.error(`[FCM ERROR] ${err.message}`);
        return { success: false, reason: err.message };
    }
};
