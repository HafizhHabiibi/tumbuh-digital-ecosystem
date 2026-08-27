import test from "node:test";
import assert from "node:assert/strict";

import {
    GeminiClientError,
    classifyGeminiError,
    createGeminiClient,
    getGeminiApiKeys,
    getGeminiConfig,
} from "../src/integrations/geminiClient.js";

const structuredResponse = (data) => ({
    data: {
        candidates: [
            {
                content: {
                    parts: [{ text: JSON.stringify(data) }],
                },
            },
        ],
    },
});

const createClient = (overrides = {}) =>
    createGeminiClient({
        apiKeys: ["key-one"],
        model: "gemini-3.6-flash",
        timeoutMs: 15000,
        maxRetries: 0,
        keyCooldownMs: 60000,
        maxBackoffMs: 4000,
        randomFn: () => 0,
        ...overrides,
    });

test("konfigurasi Gemini menggabungkan dan menghapus duplikasi API key", () => {
    const env = {
        GEMINI_API_KEYS: " key-one, key-two, key-one ",
        GEMINI_API_KEY: "key-three",
        GEMINI_MODEL: "gemini-3.6-flash",
    };

    assert.deepEqual(getGeminiApiKeys(env), [
        "key-one",
        "key-two",
        "key-three",
    ]);
    assert.equal(getGeminiConfig(env).model, "gemini-3.6-flash");
});

test("konfigurasi numerik Gemini menolak nilai di luar batas", () => {
    assert.throws(
        () => getGeminiConfig({ GEMINI_TIMEOUT_MS: "0" }),
        /GEMINI_TIMEOUT_MS/,
    );
    assert.throws(
        () => getGeminiConfig({ GEMINI_MAX_RETRIES: "99" }),
        /GEMINI_MAX_RETRIES/,
    );
});

test("client mengirim key melalui header dan meminta structured output", async () => {
    const calls = [];
    const httpClient = {
        post: async (...args) => {
            calls.push(args);
            return structuredResponse({ answer: "Edukasi singkat" });
        },
    };
    const client = createClient({ httpClient });

    const result = await client.generateStructuredContent({
        systemInstruction: "Beri edukasi.",
        prompt: "Jelaskan hasil.",
        responseSchema: {
            type: "OBJECT",
            properties: { answer: { type: "STRING" } },
            required: ["answer"],
        },
        validate: (value) => value,
    });

    assert.equal(result.data.answer, "Edukasi singkat");
    assert.equal(result.model, "gemini-3.6-flash");
    assert.equal(calls.length, 1);

    const [url, body, requestConfig] = calls[0];
    assert.match(url, /gemini-3\.6-flash:generateContent$/);
    assert.ok(!url.includes("key-one"));
    assert.equal(requestConfig.headers["x-goog-api-key"], "key-one");
    assert.equal(body.generationConfig.responseMimeType, "application/json");
    assert.equal(body.generationConfig.thinkingConfig.thinkingLevel, "low");
    assert.equal(body.generationConfig.temperature, undefined);
});

test("client mematikan key kredensial bermasalah lalu memakai key berikutnya", async () => {
    const usedKeys = [];
    const httpClient = {
        post: async (_url, _body, config) => {
            usedKeys.push(config.headers["x-goog-api-key"]);
            if (usedKeys.length === 1) {
                const error = new Error("forbidden");
                error.response = {
                    status: 403,
                    data: { error: { status: "PERMISSION_DENIED" } },
                };
                throw error;
            }
            return structuredResponse({ ok: true });
        },
    };
    const client = createClient({
        apiKeys: ["invalid-key", "valid-key"],
        httpClient,
    });

    const result = await client.generateStructuredContent({
        systemInstruction: "Sistem",
        prompt: "Prompt",
        responseSchema: { type: "OBJECT" },
    });

    assert.equal(result.data.ok, true);
    assert.deepEqual(usedKeys, ["invalid-key", "valid-key"]);
    assert.equal(client.getHealth().disabledKeys, 1);
});

test("client menandai kegagalan permanen jika seluruh key tidak valid", async () => {
    const httpClient = {
        post: async () => {
            const error = new Error("invalid key");
            error.response = {
                status: 400,
                data: {
                    error: {
                        details: [{ reason: "API_KEY_INVALID" }],
                    },
                },
            };
            throw error;
        },
    };
    const client = createClient({
        apiKeys: ["invalid-one", "invalid-two"],
        httpClient,
    });

    await assert.rejects(
        client.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
        }),
        (error) =>
            error.code === "GEMINI_NO_VALID_KEYS" && error.retryable === false,
    );
    assert.equal(client.getHealth().disabledKeys, 2);
});

test("client memberi cooldown pada key 429 lalu mencoba key berikutnya", async () => {
    const usedKeys = [];
    let now = 1000;
    const httpClient = {
        post: async (_url, _body, config) => {
            usedKeys.push(config.headers["x-goog-api-key"]);
            if (usedKeys.length === 1) {
                const error = new Error("rate limited");
                error.response = {
                    status: 429,
                    headers: { "retry-after": "30" },
                    data: { error: { status: "RESOURCE_EXHAUSTED" } },
                };
                throw error;
            }
            return structuredResponse({ ok: true });
        },
    };
    const client = createClient({
        apiKeys: ["limited-key", "backup-key"],
        httpClient,
        nowFn: () => now,
    });

    await client.generateStructuredContent({
        systemInstruction: "Sistem",
        prompt: "Prompt",
        responseSchema: { type: "OBJECT" },
    });

    assert.deepEqual(usedKeys, ["limited-key", "backup-key"]);
    assert.equal(client.getHealth().availableKeys, 1);
    now += 30000;
    assert.equal(client.getHealth().availableKeys, 2);
});

test("client melakukan backoff sebelum retry error sementara", async () => {
    let now = 0;
    let requests = 0;
    const waits = [];
    const httpClient = {
        post: async () => {
            requests++;
            if (requests === 1) {
                const error = new Error("unavailable");
                error.response = { status: 503 };
                throw error;
            }
            return structuredResponse({ ok: true });
        },
    };
    const client = createClient({
        httpClient,
        maxRetries: 1,
        nowFn: () => now,
        sleepFn: async (delayMs) => {
            waits.push(delayMs);
            now += delayMs;
        },
    });

    const result = await client.generateStructuredContent({
        systemInstruction: "Sistem",
        prompt: "Prompt",
        responseSchema: { type: "OBJECT" },
    });

    assert.equal(result.data.ok, true);
    assert.equal(requests, 2);
    assert.deepEqual(waits, [1000]);
});

test("client tidak merotasi key untuk request yang salah", async () => {
    let requests = 0;
    const httpClient = {
        post: async () => {
            requests++;
            const error = new Error("invalid argument");
            error.response = { status: 400 };
            throw error;
        },
    };
    const client = createClient({
        apiKeys: ["key-one", "key-two"],
        httpClient,
    });

    await assert.rejects(
        client.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
        }),
        (error) =>
            error instanceof GeminiClientError &&
            error.code === "GEMINI_REQUEST_REJECTED",
    );
    assert.equal(requests, 1);
});

test("client menolak JSON atau struktur keluaran yang tidak valid", async () => {
    const invalidJsonClient = createClient({
        httpClient: {
            post: async () => ({
                data: {
                    candidates: [{ content: { parts: [{ text: "bukan-json" }] } }],
                },
            }),
        },
    });

    await assert.rejects(
        invalidJsonClient.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
        }),
        (error) => error.code === "GEMINI_KEYS_EXHAUSTED",
    );

    const invalidStructureClient = createClient({
        httpClient: {
            post: async () => structuredResponse({ answer: "" }),
        },
    });

    await assert.rejects(
        invalidStructureClient.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
            validate: () => {
                throw new Error("answer kosong");
            },
        }),
        (error) => error.code === "GEMINI_KEYS_EXHAUSTED",
    );
});

test("classifier membedakan rate limit dan error fatal", () => {
    const rateLimit = new Error("limited");
    rateLimit.response = { status: 429, headers: {} };
    assert.equal(classifyGeminiError(rateLimit).kind, "rate_limit");

    const badRequest = new Error("bad request");
    badRequest.response = { status: 400 };
    assert.equal(classifyGeminiError(badRequest).retryable, false);
});
