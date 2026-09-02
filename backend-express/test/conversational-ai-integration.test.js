import test from "node:test";
import assert from "node:assert/strict";
import express from "express";

import { buatChatController } from "../src/controllers/chatController.js";
import { buatChatRouter } from "../src/routes/chat.js";
import { buatChatService } from "../src/services/chatService.js";

const IDS = {
    answered: "018f0000-0000-7000-8000-000000000001",
    medical: "018f0000-0000-7000-8000-000000000002",
    pii: "018f0000-0000-7000-8000-000000000004",
};

test("alur HTTP menjalankan guardrail, Gemini, persistence, idempotensi, dan history", async () => {
    const exchanges = new Map();
    let nextId = 1;
    let geminiCalls = 0;
    const repository = {
        findMeasurementForOrangTua: async (id, owner) =>
            [11, 12].includes(id) && owner === "orang-tua-1"
                ? {
                      id,
                      is_latest: id === 12 ? 1 : 0,
                      insight_status: "completed",
                      insight_teks:
                          id === 12
                              ? "Insight awal aman."
                              : "Insight pengukuran lama.",
                  }
                : null,
        findMessagesPage: async (id) => ({
            items: id === 12
                ? [...exchanges.values()].flatMap((item) => [
                      item.user_message,
                      item.assistant_message,
                  ])
                : [],
            hasMore: false,
            nextBeforeId: null,
        }),
        reserveExchange: async (data) => {
            const existing = exchanges.get(data.clientMessageId);
            if (existing) {
                return { status: "completed", exchange: existing };
            }
            return {
                status: "reserved",
                requestToken: `lease-${data.clientMessageId}`,
                userMessage: {
                    id: nextId++,
                    client_message_id: data.clientMessageId,
                    role: "orang_tua",
                    content: data.userContent,
                },
            };
        },
        completeExchange: async (data) => {
            const exchange = {
                user_message: data.userMessage,
                assistant_message: {
                    id: nextId++,
                    role: "assistant",
                    content: data.assistantContent,
                    response_type: data.responseType,
                },
            };
            exchanges.set(data.userMessage.client_message_id, exchange);
            return exchange;
        },
        releaseReservation: async () => {},
    };
    const contextLoader = async (id, owner) =>
        id === 12 && owner === "orang-tua-1"
            ? {
                  pengukuran: { prioritas_pemantauan: "sedang" },
                  insight_awal: "Insight awal aman.",
                  riwayat_pesan: [],
              }
            : null;
    const service = buatChatService({
        repository,
        contextLoader,
        generate: async () => {
            geminiCalls += 1;
            return {
                response_type: "answered",
                answer: "Variasikan lauk sumber protein setiap hari.",
            };
        },
        observability: {
            recordChatSuccess: () => {},
            recordChatFailure: () => {},
        },
    });
    const controller = buatChatController({
        getConversation: service.getConversation,
        sendMessage: service.sendMessage,
    });
    const router = buatChatRouter({
        getHistory: controller.getHistory,
        postMessage: controller.postMessage,
        rateLimit: (req, res, next) => next(),
    });
    const app = express();
    app.use(express.json());
    app.use((req, res, next) => {
        req.id = "integration-request";
        req.orangTua = { id: "orang-tua-1" };
        next();
    });
    app.use("/api/orang-tua/pengukuran", router);
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    const base = `http://127.0.0.1:${server.address().port}/api/orang-tua/pengukuran`;
    const post = (id, message) => fetch(`${base}/12/chat`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ client_message_id: id, message }),
    });

    try {
        const answered = await post(IDS.answered, "Apa variasi makanannya?");
        assert.equal(answered.status, 201);
        assert.equal((await answered.json()).data.assistant_message.response_type, "answered");
        assert.equal(geminiCalls, 1);

        const retried = await post(IDS.answered, "Apa variasi makanannya?");
        assert.equal(retried.status, 200);
        assert.equal((await retried.json()).data.idempotent, true);
        assert.equal(geminiCalls, 1);

        const refused = await post(IDS.medical, "Obat apa yang harus diberikan?");
        assert.equal(refused.status, 201);
        assert.equal(
            (await refused.json()).data.assistant_message.response_type,
            "medical_advice_refused",
        );
        assert.equal(geminiCalls, 1);

        const pii = await post(
            IDS.pii,
            "Email saya ibu@example.com, bagaimana hasilnya?",
        );
        const piiBody = await pii.json();
        assert.equal(pii.status, 400);
        assert.equal(piiBody.data.code, "CHAT_PII_DETECTED");
        assert.equal(geminiCalls, 1);
        assert.equal(exchanges.has(IDS.pii), false);

        const history = await fetch(`${base}/12/chat`);
        const historyBody = await history.json();
        assert.equal(history.status, 200);
        assert.equal(historyBody.data.messages.length, 4);
        assert.equal(historyBody.data.insight_teks, "Insight awal aman.");

        const historical = await fetch(`${base}/11/chat`);
        const historicalBody = await historical.json();
        assert.equal(historical.status, 200);
        assert.equal(historicalBody.data.is_active, false);
        assert.equal(historicalBody.data.insight_teks, "Insight pengukuran lama.");

        const inactivePost = await fetch(`${base}/11/chat`, {
            method: "POST",
            headers: { "content-type": "application/json" },
            body: JSON.stringify({
                client_message_id: "018f0000-0000-7000-8000-000000000003",
                message: "Apa variasi makanannya?",
            }),
        });
        assert.equal(inactivePost.status, 404);
    } finally {
        await new Promise((resolve) => server.close(resolve));
        server.closeAllConnections?.();
    }
});
