import axios from "axios";

const DEFAULT_MODEL = "gemini-3.6-flash";
const DEFAULT_TIMEOUT_MS = 15000;
const DEFAULT_MAX_RETRIES = 2;
const DEFAULT_KEY_COOLDOWN_MS = 60000;
const DEFAULT_MAX_BACKOFF_MS = 4000;

const sleep = (delayMs) =>
    new Promise((resolve) => setTimeout(resolve, delayMs));

const readInteger = (value, fallback, min, max, name) => {
    if (value === undefined || value === null || value === "") return fallback;

    const parsed = Number(value);
    if (!Number.isInteger(parsed) || parsed < min || parsed > max) {
        throw new Error(`${name} harus berupa angka antara ${min}-${max}`);
    }
    return parsed;
};

export const getGeminiApiKeys = (env = process.env) => {
    const combined = [env.GEMINI_API_KEYS, env.GEMINI_API_KEY]
        .filter(Boolean)
        .flatMap((value) => value.split(","))
        .map((value) => value.trim())
        .filter(Boolean);

    return [...new Set(combined)];
};

export const getGeminiConfig = (env = process.env) => ({
    apiKeys: getGeminiApiKeys(env),
    model: env.GEMINI_MODEL?.trim() || DEFAULT_MODEL,
    timeoutMs: readInteger(
        env.GEMINI_TIMEOUT_MS,
        DEFAULT_TIMEOUT_MS,
        1000,
        60000,
        "GEMINI_TIMEOUT_MS",
    ),
    maxRetries: readInteger(
        env.GEMINI_MAX_RETRIES,
        DEFAULT_MAX_RETRIES,
        0,
        5,
        "GEMINI_MAX_RETRIES",
    ),
    keyCooldownMs: readInteger(
        env.GEMINI_KEY_COOLDOWN_MS,
        DEFAULT_KEY_COOLDOWN_MS,
        1000,
        3600000,
        "GEMINI_KEY_COOLDOWN_MS",
    ),
    maxBackoffMs: readInteger(
        env.GEMINI_MAX_BACKOFF_MS,
        DEFAULT_MAX_BACKOFF_MS,
        100,
        30000,
        "GEMINI_MAX_BACKOFF_MS",
    ),
});

export class GeminiClientError extends Error {
    constructor(message, options = {}) {
        super(message, options.cause ? { cause: options.cause } : undefined);
        this.name = "GeminiClientError";
        this.code = options.code || "GEMINI_ERROR";
        this.status = options.status || null;
        this.retryable = Boolean(options.retryable);
        this.retryAfterMs = options.retryAfterMs || null;
    }
}

const getErrorReason = (error) => {
    const apiError = error.response?.data?.error;
    const detailReasons = Array.isArray(apiError?.details)
        ? apiError.details.map((detail) => detail?.reason).filter(Boolean)
        : [];

    return [apiError?.status, apiError?.code, ...detailReasons]
        .filter(Boolean)
        .join(" ")
        .toUpperCase();
};

const parseRetryAfterMs = (error) => {
    const value = error.response?.headers?.["retry-after"];
    if (!value) return null;

    const seconds = Number(value);
    if (Number.isFinite(seconds) && seconds >= 0) return seconds * 1000;

    const retryAt = Date.parse(value);
    if (!Number.isNaN(retryAt)) return Math.max(0, retryAt - Date.now());
    return null;
};

export const classifyGeminiError = (error) => {
    if (error instanceof GeminiClientError) {
        return {
            kind: error.code === "GEMINI_INVALID_RESPONSE" ? "transient" : "fatal",
            retryable: error.retryable,
            status: error.status,
            retryAfterMs: error.retryAfterMs,
        };
    }

    const status = error.response?.status || null;
    const reason = getErrorReason(error);
    const networkCode = String(error.code || "").toUpperCase();
    const isInvalidCredential =
        status === 401 ||
        status === 403 ||
        reason.includes("API_KEY_INVALID") ||
        reason.includes("UNAUTHENTICATED") ||
        reason.includes("PERMISSION_DENIED");

    if (isInvalidCredential) {
        return { kind: "credential", retryable: true, status };
    }

    if (status === 429) {
        return {
            kind: "rate_limit",
            retryable: true,
            status,
            retryAfterMs: parseRetryAfterMs(error),
        };
    }

    const isTransient =
        status === 408 ||
        status === 500 ||
        status === 502 ||
        status === 503 ||
        status === 504 ||
        ["ECONNABORTED", "ECONNRESET", "ETIMEDOUT", "ENETUNREACH"].includes(
            networkCode,
        );

    if (isTransient) {
        return { kind: "transient", retryable: true, status };
    }

    return { kind: "fatal", retryable: false, status };
};

const extractResponseText = (response) => {
    const parts = response.data?.candidates?.[0]?.content?.parts;
    if (!Array.isArray(parts)) return null;

    return parts.find(
        (part) => typeof part?.text === "string" && part.text.trim() && !part.thought,
    )?.text;
};

const parseStructuredResponse = (response, validate) => {
    const text = extractResponseText(response);
    if (!text) {
        throw new GeminiClientError("Respons Gemini tidak mengandung teks", {
            code: "GEMINI_INVALID_RESPONSE",
            retryable: true,
        });
    }

    let parsed;
    try {
        parsed = JSON.parse(text);
    } catch (error) {
        throw new GeminiClientError("Respons Gemini bukan JSON yang valid", {
            code: "GEMINI_INVALID_RESPONSE",
            retryable: true,
            cause: error,
        });
    }

    try {
        return validate ? validate(parsed) : parsed;
    } catch (error) {
        throw new GeminiClientError("Struktur respons Gemini tidak valid", {
            code: "GEMINI_INVALID_RESPONSE",
            retryable: true,
            cause: error,
        });
    }
};

export const createGeminiClient = (options = {}) => {
    const config = {
        ...getGeminiConfig({}),
        ...options,
    };
    const apiKeys = [...new Set(config.apiKeys || [])];
    const httpClient = config.httpClient || axios;
    const sleepFn = config.sleepFn || sleep;
    const nowFn = config.nowFn || Date.now;
    const randomFn = config.randomFn || Math.random;
    const states = apiKeys.map((apiKey) => ({
        apiKey,
        disabled: false,
        cooldownUntil: 0,
    }));
    let cursor = 0;

    const backoffMs = (round) => {
        const base = Math.min(1000 * 2 ** round, config.maxBackoffMs);
        return Math.min(base + Math.floor(randomFn() * 250), config.maxBackoffMs);
    };

    const orderedAvailableStates = () => {
        const now = nowFn();
        const ordered = states
            .slice(cursor)
            .concat(states.slice(0, cursor));
        return ordered.filter(
            (state) => !state.disabled && state.cooldownUntil <= now,
        );
    };

    const earliestCooldown = () => {
        const active = states.filter((state) => !state.disabled);
        if (active.length === 0) return null;
        return Math.min(...active.map((state) => state.cooldownUntil));
    };

    const generateStructuredContent = async ({
        prompt,
        systemInstruction,
        responseSchema,
        validate,
        maxOutputTokens = 1024,
    }) => {
        if (states.length === 0) {
            throw new GeminiClientError("API key Gemini belum dikonfigurasi", {
                code: "GEMINI_NOT_CONFIGURED",
            });
        }

        let lastError = null;

        for (let round = 0; round <= config.maxRetries; round++) {
            let available = orderedAvailableStates();
            if (available.length === 0) {
                const nextAvailableAt = earliestCooldown();
                if (nextAvailableAt === null) break;

                const waitMs = Math.max(0, nextAvailableAt - nowFn());
                if (waitMs > config.maxBackoffMs) {
                    break;
                }
                await sleepFn(waitMs);
                available = orderedAvailableStates();
            }

            for (const state of available) {
                const stateIndex = states.indexOf(state);
                cursor = (stateIndex + 1) % states.length;

                try {
                    const response = await httpClient.post(
                        `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(config.model)}:generateContent`,
                        {
                            systemInstruction: {
                                parts: [{ text: systemInstruction }],
                            },
                            contents: [
                                {
                                    role: "user",
                                    parts: [{ text: prompt }],
                                },
                            ],
                            generationConfig: {
                                responseMimeType: "application/json",
                                responseSchema,
                                maxOutputTokens,
                                thinkingConfig: { thinkingLevel: "low" },
                            },
                        },
                        {
                            headers: {
                                "Content-Type": "application/json",
                                "x-goog-api-key": state.apiKey,
                            },
                            timeout: config.timeoutMs,
                        },
                    );

                    return {
                        data: parseStructuredResponse(response, validate),
                        model: config.model,
                    };
                } catch (error) {
                    const classification = classifyGeminiError(error);
                    lastError = error;

                    if (!classification.retryable) {
                        throw new GeminiClientError("Permintaan Gemini ditolak", {
                            code: "GEMINI_REQUEST_REJECTED",
                            status: classification.status,
                            cause: error,
                        });
                    }

                    if (classification.kind === "credential") {
                        state.disabled = true;
                    } else if (classification.kind === "rate_limit") {
                        state.cooldownUntil =
                            nowFn() +
                            (classification.retryAfterMs || config.keyCooldownMs);
                    } else {
                        state.cooldownUntil = nowFn() + backoffMs(round);
                    }
                }
            }
        }

        if (states.every((state) => state.disabled)) {
            throw new GeminiClientError("Tidak ada API key Gemini yang valid", {
                code: "GEMINI_NO_VALID_KEYS",
                retryable: false,
                cause: lastError,
            });
        }

        const retryAt = earliestCooldown();
        throw new GeminiClientError("Semua API key Gemini sedang tidak tersedia", {
            code: "GEMINI_KEYS_EXHAUSTED",
            retryable: true,
            retryAfterMs:
                retryAt === null ? null : Math.max(0, retryAt - nowFn()),
            cause: lastError,
        });
    };

    const getHealth = () => ({
        model: config.model,
        totalKeys: states.length,
        availableKeys: orderedAvailableStates().length,
        disabledKeys: states.filter((state) => state.disabled).length,
    });

    return Object.freeze({ generateStructuredContent, getHealth });
};

let defaultClient = null;
let defaultClientSignature = null;

export const getDefaultGeminiClient = () => {
    const config = getGeminiConfig();
    const signature = JSON.stringify(config);

    if (!defaultClient || signature !== defaultClientSignature) {
        defaultClient = createGeminiClient(config);
        defaultClientSignature = signature;
    }
    return defaultClient;
};

export const resetDefaultGeminiClient = () => {
    defaultClient = null;
    defaultClientSignature = null;
};
