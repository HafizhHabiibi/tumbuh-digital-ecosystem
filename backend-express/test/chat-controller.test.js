import test from "node:test";
import assert from "node:assert/strict";

import { GeminiClientError } from "../src/integrations/geminiClient.js";
import { buatChatController } from "../src/controllers/chatController.js";
import { ChatInputValidationError } from "../src/services/aiGuardrailService.js";
import { ChatServiceError } from "../src/services/chatService.js";

const buatResponse = () => ({
    statusCode: 200,
    headers: {},
    body: null,
    setHeader(name, value) {
        this.headers[name.toLowerCase()] = value;
    },
    status(code) {
        this.statusCode = code;
        return this;
    },
    json(body) {
        this.body = body;
        return this;
    },
});

test("controller history meneruskan identitas orang tua dan cursor tervalidasi", async () => {
    let input;
    const controller = buatChatController({
        getConversation: async (value) => {
            input = value;
            return { messages: [], is_active: false };
        },
    });
    const res = buatResponse();

    await controller.getHistory({
        validatedParams: { id: 12 },
        validatedQuery: { limit: 25, before_id: 100 },
        orangTua: { id: "orang-tua-1" },
    }, res);

    assert.deepEqual(input, {
        pengukuranId: 12,
        orangTuaId: "orang-tua-1",
        limit: 25,
        beforeId: 100,
    });
    assert.equal(res.statusCode, 200);
    assert.equal(res.headers["cache-control"], "private, no-store");
});

test("controller pesan membedakan hasil baru dan retry idempotent", async () => {
    for (const [idempotent, expectedStatus] of [[false, 201], [true, 200]]) {
        const controller = buatChatController({
            sendMessage: async () => ({ idempotent }),
        });
        const res = buatResponse();

        await controller.postMessage({
            validatedParams: { id: 12 },
            body: {
                client_message_id: "018f0000-0000-7000-8000-000000000001",
                message: "Bagaimana pola makannya?",
            },
            id: "request-1",
            orangTua: { id: "orang-tua-1" },
        }, res);

        assert.equal(res.statusCode, expectedStatus);
        assert.equal(res.body.success, true);
        assert.equal(res.headers["cache-control"], "private, no-store");
    }
});

test("controller memetakan error domain dan provider tanpa membocorkan detail", async () => {
    const notFound = buatChatController({
        getConversation: async () => {
            throw new ChatServiceError("Percakapan tidak ditemukan", "NOT_FOUND", 404);
        },
    });
    const unavailable = buatChatController({
        sendMessage: async () => {
            throw new GeminiClientError("API key rahasia gagal", {
                code: "GEMINI_KEYS_EXHAUSTED",
            });
        },
    });
    const resNotFound = buatResponse();
    const resUnavailable = buatResponse();

    await notFound.getHistory({
        validatedParams: { id: 1 },
        validatedQuery: {},
        orangTua: { id: "orang-tua-1" },
    }, resNotFound);
    await unavailable.postMessage({
        validatedParams: { id: 1 },
        body: { client_message_id: "uuid", message: "pesan" },
        orangTua: { id: "orang-tua-1" },
    }, resUnavailable);

    assert.equal(resNotFound.statusCode, 404);
    assert.equal(resUnavailable.statusCode, 503);
    assert.doesNotMatch(resUnavailable.body.message, /key|rahasia/i);
});

test("controller mengembalikan kode aman untuk penolakan data pribadi", async () => {
    const controller = buatChatController({
        sendMessage: async () => {
            throw new ChatInputValidationError(
                "Hapus data pribadi dari pertanyaan",
                "CHAT_PII_DETECTED",
            );
        },
    });
    const res = buatResponse();

    await controller.postMessage({
        validatedParams: { id: 1 },
        body: { client_message_id: "uuid", message: "pesan" },
        orangTua: { id: "orang-tua-1" },
    }, res);

    assert.equal(res.statusCode, 400);
    assert.deepEqual(res.body, {
        success: false,
        message: "Hapus data pribadi dari pertanyaan",
        data: { code: "CHAT_PII_DETECTED" },
    });
});
