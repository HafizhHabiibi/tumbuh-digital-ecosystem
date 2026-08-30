import { uuidv7 } from "uuidv7";

import app from "../app.js";
import db from "../src/database/connection.js";
import { generateToken } from "../src/utils/jwt.js";

const syntheticClientId = uuidv7();
let server;

const requestJson = async (url, options = {}) => {
    const response = await fetch(url, options);
    const body = await response.json();
    return { response, body };
};

const cleanupSyntheticExchange = async () => {
    const connection = await db.getConnection();
    try {
        await connection.beginTransaction();
        const [rows] = await connection.query(
            `SELECT id FROM chat_messages WHERE client_message_id = ?`,
            [syntheticClientId],
        );
        if (rows[0]) {
            await connection.query(
                `DELETE FROM chat_messages WHERE reply_to_message_id = ?`,
                [rows[0].id],
            );
            await connection.query(`DELETE FROM chat_messages WHERE id = ?`, [
                rows[0].id,
            ]);
        }
        await connection.commit();
    } catch (error) {
        await connection.rollback();
        throw error;
    } finally {
        connection.release();
    }
};

try {
    const [[user]] = await db.query(
        `SELECT id, role FROM users
         WHERE role = 'orang_tua' AND is_active = TRUE
         ORDER BY created_at ASC LIMIT 1`,
    );
    if (!user) throw new Error("Smoke test membutuhkan akun orang tua aktif");

    const token = generateToken({ id: user.id, role: user.role });
    server = await new Promise((resolve, reject) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
        instance.once("error", reject);
    });
    const baseUrl = `http://127.0.0.1:${server.address().port}/api`;
    const headers = {
        authorization: `Bearer ${token}`,
        "content-type": "application/json",
    };

    const children = await requestJson(`${baseUrl}/orang-tua/anak`, { headers });
    if (!children.response.ok || !children.body.data?.[0]) {
        throw new Error("Smoke test tidak menemukan anak milik orang tua");
    }
    const measurements = await requestJson(
        `${baseUrl}/orang-tua/anak/${children.body.data[0].id}/pengukuran`,
        { headers },
    );
    const measurementId = measurements.body.data?.riwayat?.[0]?.id;
    if (!measurements.response.ok || !measurementId) {
        throw new Error("Smoke test tidak menemukan pengukuran terbaru");
    }

    const [[before]] = await db.query(
        `SELECT COUNT(*) AS total FROM chat_messages`,
    );
    const payload = {
        client_message_id: syntheticClientId,
        message: "Apa contoh sumber protein sederhana untuk anak?",
    };
    const chatUrl = `${baseUrl}/orang-tua/pengukuran/${measurementId}/chat`;
    const [candidateA, candidateB] = await Promise.all([
        requestJson(chatUrl, {
            method: "POST",
            headers,
            body: JSON.stringify(payload),
        }),
        requestJson(chatUrl, {
            method: "POST",
            headers,
            body: JSON.stringify(payload),
        }),
    ]);
    const first = [candidateA, candidateB].find(
        (candidate) => candidate.response.status === 201,
    );
    const concurrent = [candidateA, candidateB].find(
        (candidate) => candidate.response.status === 409,
    );
    if (!first) {
        throw new Error(
            `POST chat concurrent gagal: HTTP ${candidateA.response.status}/${candidateB.response.status}`,
        );
    }
    if (concurrent?.body.data?.code !== "CHAT_REQUEST_PROCESSING") {
        throw new Error("Request concurrent tidak menerima status processing");
    }
    if (first.body.data?.assistant_message?.response_type !== "answered") {
        throw new Error("POST chat tidak menghasilkan structured response answered");
    }

    const retry = await requestJson(
        chatUrl,
        { method: "POST", headers, body: JSON.stringify(payload) },
    );
    if (retry.response.status !== 200 || retry.body.data?.idempotent !== true) {
        throw new Error("Retry chat tidak mengembalikan exchange idempotent");
    }
    const [[after]] = await db.query(
        `SELECT COUNT(*) AS total FROM chat_messages`,
    );
    if (Number(after.total) - Number(before.total) !== 2) {
        throw new Error("Exchange chat tidak tersimpan tepat dua pesan");
    }

    console.log(
        JSON.stringify({
            success: true,
            post_status: first.response.status,
            concurrent_status: concurrent.response.status,
            concurrent_code: concurrent.body.data.code,
            retry_status: retry.response.status,
            response_type: first.body.data.assistant_message.response_type,
            persisted_rows: 2,
            idempotent_retry: true,
        }),
    );
} finally {
    await cleanupSyntheticExchange();
    if (server) {
        await new Promise((resolve) => server.close(resolve));
        server.closeAllConnections?.();
    }
    await db.end();
}
