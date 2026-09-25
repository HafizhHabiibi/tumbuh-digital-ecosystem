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
        maxTotalAttempts: 6,
        maxTransientRetries: 0,
        invalidResponseRetries: 1,
        keyCooldownMs: 60000,
        maxBackoffMs: 4000,
        randomFn: () => 0,
        logger: { warn: () => {} },
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
    assert.throws(
        () => getGeminiConfig({ GEMINI_MAX_TOTAL_ATTEMPTS: "0" }),
        /GEMINI_MAX_TOTAL_ATTEMPTS/,
    );
    assert.throws(
        () => getGeminiConfig({ GEMINI_MAX_TRANSIENT_RETRIES: "6" }),
        /GEMINI_MAX_TRANSIENT_RETRIES/,
    );
    assert.throws(
        () => getGeminiConfig({ GEMINI_INVALID_RESPONSE_RETRIES: "4" }),
        /GEMINI_INVALID_RESPONSE_RETRIES/,
    );
});

test("konfigurasi retry baru mendukung fallback GEMINI_MAX_RETRIES lama", () => {
    const legacy = getGeminiConfig({ GEMINI_MAX_RETRIES: "1" });
    assert.equal(legacy.maxTransientRetries, 1);
    assert.equal(legacy.maxTotalAttempts, 6);
    assert.equal(legacy.invalidResponseRetries, 1);

    const current = getGeminiConfig({
        GEMINI_MAX_RETRIES: "1",
        GEMINI_MAX_TRANSIENT_RETRIES: "3",
        GEMINI_MAX_TOTAL_ATTEMPTS: "8",
        GEMINI_INVALID_RESPONSE_RETRIES: "2",
    });
    assert.equal(current.maxTransientRetries, 3);
    assert.equal(current.maxTotalAttempts, 8);
    assert.equal(current.invalidResponseRetries, 2);
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
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 1,
        cooldownKeys: 0,
        disabledKeys: 1,
        nextAvailableInMs: null,
    });
    assert.doesNotMatch(JSON.stringify(client.getHealth()), /invalid-key|valid-key/);
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
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 0,
        cooldownKeys: 0,
        disabledKeys: 2,
        nextAvailableInMs: null,
    });
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
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 1,
        cooldownKeys: 1,
        disabledKeys: 0,
        nextAvailableInMs: 30000,
    });
    now += 30000;
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 2,
        cooldownKeys: 0,
        disabledKeys: 0,
        nextAvailableInMs: null,
    });
});

test("client mencatat kegagalan attempt secara aman sebelum merotasi key", async () => {
    const auditLines = [];
    const secretKeys = ["secret-key-one", "secret-key-two"];
    const secretPrompt = "prompt-rahasia-pengguna";
    const httpClient = {
        post: async (_url, _body, config) => {
            if (config.headers["x-goog-api-key"] === secretKeys[0]) {
                const error = new Error(
                    `provider message ${secretKeys[0]} ${secretPrompt}`,
                );
                error.code = "ERR_BAD_REQUEST";
                error.response = {
                    status: 429,
                    headers: { "retry-after": "30" },
                    data: {
                        error: {
                            status: "RESOURCE_EXHAUSTED",
                            message: `jangan-log ${secretKeys[0]} ${secretPrompt}`,
                            details: [{ reason: "RATE_LIMIT_EXCEEDED" }],
                        },
                    },
                };
                throw error;
            }
            return structuredResponse({ ok: true });
        },
    };
    const client = createClient({
        apiKeys: secretKeys,
        httpClient,
        logger: { warn: (line) => auditLines.push(line) },
    });

    const result = await client.generateStructuredContent({
        requestId: "request aman/1",
        systemInstruction: "Sistem rahasia",
        prompt: secretPrompt,
        responseSchema: { type: "OBJECT" },
    });

    assert.equal(result.data.ok, true);
    assert.equal(auditLines.length, 1);
    assert.match(auditLines[0], /^\[AI_AUDIT\] /);

    const event = JSON.parse(auditLines[0].replace(/^\[AI_AUDIT\] /, ""));
    assert.deepEqual(event, {
        event: "gemini_attempt_failed",
        request_id: "request_aman_1",
        key_index: 1,
        key_fingerprint: event.key_fingerprint,
        attempt: 1,
        round: 1,
        http_status: 429,
        provider_status: "RESOURCE_EXHAUSTED",
        provider_reason: "RATE_LIMIT_EXCEEDED",
        failure_code: "HTTP_429",
        classification: "rate_limit",
        retryable: true,
        retry_after_ms: 30000,
        key_state: "cooldown",
        state_reason: "rate_limit",
        cooldown_remaining_ms: 30000,
    });
    assert.match(event.key_fingerprint, /^[a-f0-9]{8}$/);

    const serialized = JSON.stringify(auditLines);
    assert.doesNotMatch(serialized, /secret-key-one|secret-key-two/);
    assert.doesNotMatch(serialized, /prompt-rahasia|Sistem rahasia|jangan-log/);
});

test("fingerprint key konsisten antar attempt tanpa mengungkap credential", async () => {
    const events = [];
    const secretKeys = ["credential-rahasia-satu", "credential-rahasia-dua"];
    const client = createClient({
        apiKeys: secretKeys,
        httpClient: {
            post: async (_url, _body, config) => {
                if (config.headers["x-goog-api-key"] === secretKeys[0]) {
                    const error = new Error("rate limited");
                    error.response = {
                        status: 429,
                        headers: { "retry-after": "30" },
                        data: { error: { status: "RESOURCE_EXHAUSTED" } },
                    };
                    throw error;
                }
                return {
                    data: {
                        candidates: [
                            {
                                content: {
                                    parts: [{ text: "bukan-json" }],
                                },
                            },
                        ],
                    },
                };
            },
        },
        onAttemptFailure: (event) => events.push(event),
    });

    await assert.rejects(
        client.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
        }),
        (error) => error.code === "GEMINI_INVALID_JSON",
    );

    assert.equal(events.length, 3);
    assert.notEqual(events[0].key_fingerprint, events[1].key_fingerprint);
    assert.equal(events[1].key_fingerprint, events[2].key_fingerprint);
    assert.ok(
        events.every((event) => /^[a-f0-9]{8}$/.test(event.key_fingerprint)),
    );
    assert.doesNotMatch(
        JSON.stringify(events),
        /credential-rahasia-satu|credential-rahasia-dua/,
    );
});

test("kegagalan audit logger tidak menggagalkan rotasi key", async () => {
    const usedKeys = [];
    const client = createClient({
        apiKeys: ["limited-key", "healthy-key"],
        httpClient: {
            post: async (_url, _body, config) => {
                const key = config.headers["x-goog-api-key"];
                usedKeys.push(key);
                if (key === "limited-key") {
                    const error = new Error("rate limited");
                    error.response = {
                        status: 429,
                        headers: {},
                        data: { error: { status: "RESOURCE_EXHAUSTED" } },
                    };
                    throw error;
                }
                return structuredResponse({ ok: true });
            },
        },
        onAttemptFailure: () => {
            throw new Error("audit sink unavailable");
        },
    });

    const result = await client.generateStructuredContent({
        systemInstruction: "Sistem",
        prompt: "Prompt",
        responseSchema: { type: "OBJECT" },
    });

    assert.equal(result.data.ok, true);
    assert.deepEqual(usedKeys, ["limited-key", "healthy-key"]);
});

test("client mencatat jenis structured output invalid tanpa membocorkan output", async () => {
    const cases = [
        {
            diagnosticCode: "GEMINI_EMPTY_RESPONSE",
            response: { data: { candidates: [] } },
        },
        {
            diagnosticCode: "GEMINI_INVALID_JSON",
            response: {
                data: {
                    candidates: [
                        {
                            content: {
                                parts: [
                                    { text: "output-rahasia-bukan-json" },
                                ],
                            },
                        },
                    ],
                },
            },
        },
        {
            diagnosticCode: "GEMINI_INVALID_SCHEMA",
            response: structuredResponse({ secret: "struktur-rahasia" }),
            validate: () => {
                throw new Error("detail-validasi-rahasia");
            },
        },
    ];

    for (const testCase of cases) {
        const events = [];
        const client = createClient({
            httpClient: { post: async () => testCase.response },
            onAttemptFailure: (event) => events.push(event),
        });

        await assert.rejects(
            client.generateStructuredContent({
                requestId: "req-invalid-output",
                systemInstruction: "Sistem",
                prompt: "Prompt",
                responseSchema: { type: "OBJECT" },
                validate: testCase.validate,
            }),
            (error) => error.code === testCase.diagnosticCode,
        );

        assert.equal(events.length, 2);
        assert.deepEqual(events.map((event) => event.attempt), [1, 2]);
        assert.ok(
            events.every(
                (event) => event.failure_code === testCase.diagnosticCode,
            ),
        );
        assert.ok(
            events.every(
                (event) => event.classification === "invalid_response",
            ),
        );
        assert.ok(events.every((event) => event.http_status === null));
        assert.ok(events.every((event) => event.retry_after_ms === null));
        assert.ok(events.every((event) => event.key_state === "available"));
        assert.ok(events.every((event) => event.state_reason === null));
        assert.ok(
            events.every((event) => event.cooldown_remaining_ms === null),
        );
        assert.equal(client.getHealth().availableKeys, 1);
        assert.equal(client.getHealth().disabledKeys, 0);
        assert.doesNotMatch(
            JSON.stringify(events),
            /output-rahasia|struktur-rahasia|detail-validasi-rahasia/,
        );
    }
});

test("structured output invalid diretry sekali pada key yang sama tanpa cooldown", async () => {
    const usedKeys = [];
    const events = [];
    const client = createClient({
        apiKeys: ["key-invalid-output", "key-valid-output"],
        httpClient: {
            post: async (_url, _body, config) => {
                usedKeys.push(config.headers["x-goog-api-key"]);
                if (usedKeys.length === 1) {
                    return {
                        data: {
                            candidates: [
                                {
                                    content: {
                                        parts: [{ text: "bukan-json" }],
                                    },
                                },
                            ],
                        },
                    };
                }
                return structuredResponse({ ok: true });
            },
        },
        onAttemptFailure: (event) => events.push(event),
    });

    const result = await client.generateStructuredContent({
        systemInstruction: "Sistem",
        prompt: "Prompt",
        responseSchema: { type: "OBJECT" },
    });

    assert.equal(result.data.ok, true);
    assert.deepEqual(usedKeys, ["key-invalid-output", "key-invalid-output"]);
    assert.equal(events[0].classification, "invalid_response");
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 2,
        cooldownKeys: 0,
        disabledKeys: 0,
        nextAvailableInMs: null,
    });
});

test("client melakukan backoff sebelum retry error sementara tanpa mengubah state key", async () => {
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
        maxTransientRetries: 1,
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
    assert.equal(client.getHealth().availableKeys, 1);
    assert.equal(client.getHealth().disabledKeys, 0);
});

test("retry transient memakai exponential backoff dan batas retry", async () => {
    let requests = 0;
    let now = 0;
    const waits = [];
    const client = createClient({
        maxTransientRetries: 2,
        maxTotalAttempts: 6,
        nowFn: () => now,
        sleepFn: async (delayMs) => {
            waits.push(delayMs);
            now += delayMs;
        },
        httpClient: {
            post: async () => {
                requests += 1;
                if (requests === 1) {
                    const error = new Error("unavailable");
                    error.response = { status: 503 };
                    throw error;
                }
                if (requests === 2) {
                    const error = new Error("timeout");
                    error.code = "ETIMEDOUT";
                    throw error;
                }
                return structuredResponse({ ok: true });
            },
        },
    });

    const result = await client.generateStructuredContent({
        systemInstruction: "Sistem",
        prompt: "Prompt",
        responseSchema: { type: "OBJECT" },
    });

    assert.equal(result.data.ok, true);
    assert.equal(requests, 3);
    assert.deepEqual(waits, [1000, 2000]);
    assert.equal(client.getHealth().availableKeys, 1);
});

test("error 5xx dan network tidak mengubah state key", async () => {
    const cases = [
        {
            name: "provider unavailable",
            expectedCode: "GEMINI_PROVIDER_UNAVAILABLE",
            createError: () => {
                const error = new Error("unavailable");
                error.response = { status: 503 };
                return error;
            },
        },
        {
            name: "network timeout",
            expectedCode: "GEMINI_TIMEOUT",
            createError: () => {
                const error = new Error("timeout");
                error.code = "ETIMEDOUT";
                return error;
            },
        },
        {
            name: "network reset",
            expectedCode: "GEMINI_NETWORK_ERROR",
            createError: () => {
                const error = new Error("connection reset");
                error.code = "ECONNRESET";
                return error;
            },
        },
    ];

    for (const testCase of cases) {
        const events = [];
        const client = createClient({
            httpClient: {
                post: async () => {
                    throw testCase.createError();
                },
            },
            onAttemptFailure: (event) => events.push(event),
        });

        await assert.rejects(
            client.generateStructuredContent({
                systemInstruction: "Sistem",
                prompt: "Prompt",
                responseSchema: { type: "OBJECT" },
            }),
            (error) => error.code === testCase.expectedCode,
            testCase.name,
        );

        assert.equal(events[0].key_state, "available", testCase.name);
        assert.equal(events[0].state_reason, null, testCase.name);
        assert.equal(client.getHealth().availableKeys, 1, testCase.name);
        assert.equal(client.getHealth().disabledKeys, 0, testCase.name);
    }
});

test("seluruh key 429 melaporkan cooldown terdekat dan pulih otomatis", async () => {
    let now = 1000;
    const events = [];
    const client = createClient({
        apiKeys: ["limited-one", "limited-two"],
        nowFn: () => now,
        httpClient: {
            post: async () => {
                const error = new Error("rate limited");
                error.response = {
                    status: 429,
                    headers: { "retry-after": "30" },
                    data: { error: { status: "RESOURCE_EXHAUSTED" } },
                };
                throw error;
            },
        },
        onAttemptFailure: (event) => events.push(event),
    });

    await assert.rejects(
        client.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
        }),
        (error) =>
            error.code === "GEMINI_ALL_KEYS_RATE_LIMITED" &&
            error.retryAfterMs === 30000,
    );

    assert.equal(events.length, 2);
    assert.ok(events.every((event) => event.key_state === "cooldown"));
    assert.ok(events.every((event) => event.state_reason === "rate_limit"));
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 0,
        cooldownKeys: 2,
        disabledKeys: 0,
        nextAvailableInMs: 30000,
    });

    now += 30000;
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 2,
        availableKeys: 2,
        cooldownKeys: 0,
        disabledKeys: 0,
        nextAvailableInMs: null,
    });
});

test("jumlah panggilan tidak melewati batas attempt total", async () => {
    let requests = 0;
    const events = [];
    const client = createClient({
        apiKeys: Array.from({ length: 8 }, (_, index) => `key-${index + 1}`),
        maxTotalAttempts: 3,
        nowFn: () => 1000,
        httpClient: {
            post: async () => {
                requests += 1;
                const error = new Error("rate limited");
                error.response = {
                    status: 429,
                    headers: {},
                    data: { error: { status: "RESOURCE_EXHAUSTED" } },
                };
                throw error;
            },
        },
        onAttemptFailure: (event) => events.push(event),
    });

    await assert.rejects(
        client.generateStructuredContent({
            systemInstruction: "Sistem",
            prompt: "Prompt",
            responseSchema: { type: "OBJECT" },
        }),
        (error) => error.code === "GEMINI_ATTEMPT_LIMIT_REACHED",
    );

    assert.equal(requests, 3);
    assert.equal(events.length, 3);
    assert.deepEqual(events.map((event) => event.attempt), [1, 2, 3]);
    assert.ok(
        events.every((event) => event.cooldown_remaining_ms === 60000),
    );
    assert.deepEqual(client.getHealth(), {
        model: "gemini-3.6-flash",
        totalKeys: 8,
        availableKeys: 5,
        cooldownKeys: 3,
        disabledKeys: 0,
        nextAvailableInMs: 60000,
    });
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
        (error) => error.code === "GEMINI_INVALID_JSON",
    );
    assert.equal(invalidJsonClient.getHealth().availableKeys, 1);

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
        (error) => error.code === "GEMINI_INVALID_SCHEMA",
    );
    assert.equal(invalidStructureClient.getHealth().availableKeys, 1);
});

test("classifier membedakan rate limit, timeout, dan error fatal", () => {
    const rateLimit = new Error("limited");
    rateLimit.response = { status: 429, headers: {} };
    assert.equal(classifyGeminiError(rateLimit).kind, "rate_limit");

    const retryInfoRateLimit = new Error("limited with retry info");
    retryInfoRateLimit.response = {
        status: 429,
        headers: {},
        data: {
            error: {
                details: [
                    {
                        "@type": "type.googleapis.com/google.rpc.RetryInfo",
                        retryDelay: "1.5s",
                    },
                ],
            },
        },
    };
    assert.equal(
        classifyGeminiError(retryInfoRateLimit).retryAfterMs,
        1500,
    );

    const timeout = new Error("timeout");
    timeout.code = "ETIMEDOUT";
    assert.deepEqual(classifyGeminiError(timeout), {
        kind: "transient",
        retryable: true,
        status: null,
    });

    const badRequest = new Error("bad request");
    badRequest.response = { status: 400 };
    assert.equal(classifyGeminiError(badRequest).retryable, false);

    const invalidResponse = new GeminiClientError("invalid output", {
        code: "GEMINI_INVALID_RESPONSE",
        retryable: true,
    });
    assert.equal(
        classifyGeminiError(invalidResponse).kind,
        "invalid_response",
    );
});
