import axios from "axios";
import { createHash } from "node:crypto";

const DEFAULT_MODEL = "gemini-3.6-flash";
const DEFAULT_TIMEOUT_MS = 15000;
const DEFAULT_MAX_TOTAL_ATTEMPTS = 6;
const DEFAULT_MAX_TRANSIENT_RETRIES = 2;
const DEFAULT_INVALID_RESPONSE_RETRIES = 1;
const DEFAULT_KEY_COOLDOWN_MS = 60000;
const DEFAULT_MAX_BACKOFF_MS = 4000;
const KEY_STATUS = Object.freeze({
    AVAILABLE: "available",
    COOLDOWN: "cooldown",
    DISABLED: "disabled",
});

export const GEMINI_ERROR_CODES = Object.freeze({
    NOT_CONFIGURED: "GEMINI_NOT_CONFIGURED",
    NO_VALID_KEYS: "GEMINI_NO_VALID_KEYS",
    ALL_KEYS_RATE_LIMITED: "GEMINI_ALL_KEYS_RATE_LIMITED",
    PROVIDER_UNAVAILABLE: "GEMINI_PROVIDER_UNAVAILABLE",
    NETWORK_ERROR: "GEMINI_NETWORK_ERROR",
    TIMEOUT: "GEMINI_TIMEOUT",
    EMPTY_RESPONSE: "GEMINI_EMPTY_RESPONSE",
    INVALID_JSON: "GEMINI_INVALID_JSON",
    INVALID_SCHEMA: "GEMINI_INVALID_SCHEMA",
    ATTEMPT_LIMIT_REACHED: "GEMINI_ATTEMPT_LIMIT_REACHED",
    REQUEST_REJECTED: "GEMINI_REQUEST_REJECTED",
});

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

export const getGeminiConfig = (env = process.env) => {
    const transientRetryValue =
        env.GEMINI_MAX_TRANSIENT_RETRIES ?? env.GEMINI_MAX_RETRIES;

    return {
        apiKeys: getGeminiApiKeys(env),
        model: env.GEMINI_MODEL?.trim() || DEFAULT_MODEL,
        timeoutMs: readInteger(
            env.GEMINI_TIMEOUT_MS,
            DEFAULT_TIMEOUT_MS,
            1000,
            60000,
            "GEMINI_TIMEOUT_MS",
        ),
        maxTotalAttempts: readInteger(
            env.GEMINI_MAX_TOTAL_ATTEMPTS,
            DEFAULT_MAX_TOTAL_ATTEMPTS,
            1,
            20,
            "GEMINI_MAX_TOTAL_ATTEMPTS",
        ),
        maxTransientRetries: readInteger(
            transientRetryValue,
            DEFAULT_MAX_TRANSIENT_RETRIES,
            0,
            5,
            env.GEMINI_MAX_TRANSIENT_RETRIES === undefined
                ? "GEMINI_MAX_RETRIES"
                : "GEMINI_MAX_TRANSIENT_RETRIES",
        ),
        invalidResponseRetries: readInteger(
            env.GEMINI_INVALID_RESPONSE_RETRIES,
            DEFAULT_INVALID_RESPONSE_RETRIES,
            0,
            3,
            "GEMINI_INVALID_RESPONSE_RETRIES",
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
    };
};

export class GeminiClientError extends Error {
    constructor(message, options = {}) {
        super(message, options.cause ? { cause: options.cause } : undefined);
        this.name = "GeminiClientError";
        this.code = options.code || "GEMINI_ERROR";
        this.diagnosticCode = options.diagnosticCode || this.code;
        this.status = options.status ?? null;
        this.retryable = Boolean(options.retryable);
        this.retryAfterMs = options.retryAfterMs ?? null;
    }
}

const sanitizeLogToken = (value, fallback = "unknown") => {
    if (value === undefined || value === null || value === "") return fallback;
    return String(value).replace(/[^a-zA-Z0-9._:-]/g, "_").slice(0, 128);
};

const normalizeLogNumber = (value, { min = 0, max = 300_000 } = {}) => {
    if (value === undefined || value === null || value === "") return null;
    const parsed = Number(value);
    if (!Number.isFinite(parsed)) return null;
    return Math.max(min, Math.min(max, Math.round(parsed)));
};

const fingerprintApiKey = (apiKey) =>
    createHash("sha256").update(apiKey).digest("hex").slice(0, 8);

const getProviderStatus = (error) =>
    sanitizeLogToken(error.response?.data?.error?.status, null);

const getProviderReason = (error) => {
    const apiError = error.response?.data?.error;
    const reasons = Array.isArray(apiError?.details)
        ? apiError.details.map((detail) => detail?.reason).filter(Boolean)
        : [];
    return reasons.length > 0
        ? sanitizeLogToken(reasons.join("_"), null)
        : null;
};

const getFailureCode = (error) => {
    if (error instanceof GeminiClientError) return error.diagnosticCode;
    if (error.response?.status) return `HTTP_${error.response.status}`;
    return error.code || "GEMINI_UNKNOWN_ERROR";
};

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
    if (value) {
        const seconds = Number(value);
        if (Number.isFinite(seconds) && seconds >= 0) return seconds * 1000;

        const retryAt = Date.parse(value);
        if (!Number.isNaN(retryAt)) return Math.max(0, retryAt - Date.now());
    }

    const details = error.response?.data?.error?.details;
    const retryInfo = Array.isArray(details)
        ? details.find((detail) => detail?.retryDelay !== undefined)
        : null;
    const retryDelay = retryInfo?.retryDelay;
    if (typeof retryDelay === "string") {
        const match = retryDelay.match(/^(\d+(?:\.\d+)?)s$/);
        if (match) return Math.round(Number(match[1]) * 1000);
    }
    if (retryDelay && typeof retryDelay === "object") {
        const seconds = Number(retryDelay.seconds || 0);
        const nanos = Number(retryDelay.nanos || 0);
        if (
            Number.isFinite(seconds) &&
            seconds >= 0 &&
            Number.isFinite(nanos) &&
            nanos >= 0
        ) {
            return Math.round(seconds * 1000 + nanos / 1_000_000);
        }
    }
    return null;
};

export const classifyGeminiError = (error) => {
    if (error instanceof GeminiClientError) {
        return {
            kind:
                error.code === "GEMINI_INVALID_RESPONSE"
                    ? "invalid_response"
                    : "fatal",
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

const getTransientTerminalCode = (error) => {
    const status = error.response?.status || null;
    const networkCode = String(error.code || "").toUpperCase();
    if (
        status === 408 ||
        ["ECONNABORTED", "ETIMEDOUT"].includes(networkCode)
    ) {
        return GEMINI_ERROR_CODES.TIMEOUT;
    }
    if ([500, 502, 503, 504].includes(status)) {
        return GEMINI_ERROR_CODES.PROVIDER_UNAVAILABLE;
    }
    return GEMINI_ERROR_CODES.NETWORK_ERROR;
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
            diagnosticCode: "GEMINI_EMPTY_RESPONSE",
            retryable: true,
        });
    }

    let parsed;
    try {
        parsed = JSON.parse(text);
    } catch (error) {
        throw new GeminiClientError("Respons Gemini bukan JSON yang valid", {
            code: "GEMINI_INVALID_RESPONSE",
            diagnosticCode: "GEMINI_INVALID_JSON",
            retryable: true,
            cause: error,
        });
    }

    try {
        return validate ? validate(parsed) : parsed;
    } catch (error) {
        throw new GeminiClientError("Struktur respons Gemini tidak valid", {
            code: "GEMINI_INVALID_RESPONSE",
            diagnosticCode: "GEMINI_INVALID_SCHEMA",
            retryable: true,
            cause: error,
        });
    }
};

export const createGeminiClient = (options = {}) => {
    const normalizedOptions = { ...options };
    if (
        options.maxTransientRetries === undefined &&
        options.maxRetries !== undefined
    ) {
        normalizedOptions.maxTransientRetries = options.maxRetries;
    }
    const config = {
        ...getGeminiConfig({}),
        ...normalizedOptions,
    };
    const apiKeys = [...new Set(config.apiKeys || [])];
    const httpClient = config.httpClient || axios;
    const sleepFn = config.sleepFn || sleep;
    const nowFn = config.nowFn || Date.now;
    const randomFn = config.randomFn || Math.random;
    const logger = config.logger || console;
    const attemptFailureHandler = config.onAttemptFailure || ((payload) => {
        const method = typeof logger.warn === "function" ? "warn" : "log";
        logger[method](`[AI_AUDIT] ${JSON.stringify(payload)}`);
    });
    const states = apiKeys.map((apiKey) => ({
        apiKey,
        fingerprint: fingerprintApiKey(apiKey),
        status: KEY_STATUS.AVAILABLE,
        cooldownUntil: 0,
        lastStateReason: null,
        lastStateChangedAt: null,
    }));
    let cursor = 0;

    const emitAttemptFailure = (payload) => {
        try {
            attemptFailureHandler(payload);
        } catch {
            // Gangguan logger tidak boleh mengubah hasil panggilan provider.
        }
    };

    const backoffMs = (round) => {
        const base = Math.min(1000 * 2 ** round, config.maxBackoffMs);
        return Math.min(base + Math.floor(randomFn() * 250), config.maxBackoffMs);
    };

    const transitionState = (state, status, reason, cooldownUntil = 0) => {
        state.status = status;
        state.cooldownUntil = cooldownUntil;
        state.lastStateReason = reason;
        state.lastStateChangedAt = nowFn();
    };

    const refreshExpiredCooldowns = () => {
        const now = nowFn();
        for (const state of states) {
            if (
                state.status === KEY_STATUS.COOLDOWN &&
                state.cooldownUntil <= now
            ) {
                transitionState(
                    state,
                    KEY_STATUS.AVAILABLE,
                    "cooldown_expired",
                );
            }
        }
    };

    const orderedAvailableStates = () => {
        refreshExpiredCooldowns();
        const ordered = states
            .slice(cursor)
            .concat(states.slice(0, cursor));
        return ordered.filter((state) => state.status === KEY_STATUS.AVAILABLE);
    };

    const earliestCooldown = () => {
        refreshExpiredCooldowns();
        const coolingDown = states.filter(
            (state) => state.status === KEY_STATUS.COOLDOWN,
        );
        if (coolingDown.length === 0) return null;
        return Math.min(...coolingDown.map((state) => state.cooldownUntil));
    };

    const generateStructuredContent = async ({
        requestId,
        prompt,
        systemInstruction,
        responseSchema,
        validate,
        maxOutputTokens = 1024,
    }) => {
        if (states.length === 0) {
            throw new GeminiClientError("API key Gemini belum dikonfigurasi", {
                code: GEMINI_ERROR_CODES.NOT_CONFIGURED,
            });
        }

        let lastError = null;
        let lastClassification = null;
        let attempt = 0;
        const recordAttemptFailure = ({
            error,
            classification,
            state,
            stateIndex,
        }) => {
            emitAttemptFailure({
                event: "gemini_attempt_failed",
                request_id: sanitizeLogToken(requestId),
                key_index: stateIndex + 1,
                key_fingerprint: state.fingerprint,
                attempt,
                round: attempt,
                http_status: normalizeLogNumber(
                    error.response?.status || error.status,
                    { max: 599 },
                ),
                provider_status: getProviderStatus(error),
                provider_reason: getProviderReason(error),
                failure_code: sanitizeLogToken(getFailureCode(error)),
                classification: sanitizeLogToken(classification.kind),
                retryable: Boolean(classification.retryable),
                retry_after_ms: normalizeLogNumber(
                    classification.retryAfterMs,
                ),
                key_state: state.status,
                state_reason: sanitizeLogToken(state.lastStateReason, null),
                cooldown_remaining_ms:
                    state.status === KEY_STATUS.COOLDOWN
                        ? Math.max(0, state.cooldownUntil - nowFn())
                        : null,
            });
        };

        let state = null;
        let transientRetries = 0;
        let invalidResponseRetries = 0;

        while (attempt < config.maxTotalAttempts) {
            if (!state) {
                const available = orderedAvailableStates();
                state = available[0] || null;
            }

            if (!state) {
                const nextAvailableAt = earliestCooldown();
                if (nextAvailableAt === null) break;

                const waitMs = Math.max(0, nextAvailableAt - nowFn());
                if (waitMs > config.maxBackoffMs) {
                    break;
                }
                await sleepFn(waitMs);
                continue;
            }

            const stateIndex = states.indexOf(state);
            cursor = (stateIndex + 1) % states.length;
            attempt += 1;

            let response;
            try {
                response = await httpClient.post(
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
            } catch (error) {
                const classification = classifyGeminiError(error);
                lastError = error;
                lastClassification = classification;

                if (classification.kind === "credential") {
                    transitionState(
                        state,
                        KEY_STATUS.DISABLED,
                        "credential",
                    );
                } else if (classification.kind === "rate_limit") {
                    transitionState(
                        state,
                        KEY_STATUS.COOLDOWN,
                        "rate_limit",
                        nowFn() +
                            (classification.retryAfterMs ??
                                config.keyCooldownMs),
                    );
                }

                recordAttemptFailure({
                    error,
                    classification,
                    state,
                    stateIndex,
                });

                if (!classification.retryable) {
                    throw new GeminiClientError("Permintaan Gemini ditolak", {
                        code: GEMINI_ERROR_CODES.REQUEST_REJECTED,
                        status: classification.status,
                        cause: error,
                    });
                }

                if (
                    classification.kind === "credential" ||
                    classification.kind === "rate_limit"
                ) {
                    state = null;
                    continue;
                }

                if (
                    classification.kind === "transient" &&
                    transientRetries < config.maxTransientRetries &&
                    attempt < config.maxTotalAttempts
                ) {
                    const delayMs = backoffMs(transientRetries);
                    transientRetries += 1;
                    await sleepFn(delayMs);
                    continue;
                }

                break;
            }

            try {
                return {
                    data: parseStructuredResponse(response, validate),
                    model: config.model,
                };
            } catch (error) {
                const classification = classifyGeminiError(error);
                lastError = error;
                lastClassification = classification;
                recordAttemptFailure({
                    error,
                    classification,
                    state,
                    stateIndex,
                });

                if (
                    invalidResponseRetries < config.invalidResponseRetries &&
                    attempt < config.maxTotalAttempts
                ) {
                    invalidResponseRetries += 1;
                    continue;
                }

                break;
            }
        }

        if (states.every((state) => state.status === KEY_STATUS.DISABLED)) {
            throw new GeminiClientError("Tidak ada API key Gemini yang valid", {
                code: GEMINI_ERROR_CODES.NO_VALID_KEYS,
                retryable: false,
                cause: lastError,
            });
        }

        refreshExpiredCooldowns();
        const activeStates = states.filter(
            (state) => state.status !== KEY_STATUS.DISABLED,
        );
        const allActiveKeysRateLimited =
            activeStates.length > 0 &&
            activeStates.every(
                (state) => state.status === KEY_STATUS.COOLDOWN,
            );
        const retryAt = earliestCooldown();
        if (allActiveKeysRateLimited) {
            throw new GeminiClientError(
                "Semua API key Gemini sedang terkena rate limit",
                {
                    code: GEMINI_ERROR_CODES.ALL_KEYS_RATE_LIMITED,
                    retryable: true,
                    retryAfterMs:
                        retryAt === null
                            ? null
                            : Math.max(0, retryAt - nowFn()),
                    cause: lastError,
                },
            );
        }

        if (lastClassification?.kind === "invalid_response") {
            throw new GeminiClientError("Structured output Gemini tidak valid", {
                code:
                    lastError?.diagnosticCode ||
                    GEMINI_ERROR_CODES.INVALID_SCHEMA,
                retryable: true,
                cause: lastError,
            });
        }

        if (lastClassification?.kind === "transient") {
            throw new GeminiClientError("Provider Gemini sementara tidak tersedia", {
                code: getTransientTerminalCode(lastError),
                status: lastClassification.status,
                retryable: true,
                cause: lastError,
            });
        }

        throw new GeminiClientError("Batas percobaan Gemini telah tercapai", {
            code: GEMINI_ERROR_CODES.ATTEMPT_LIMIT_REACHED,
            status: lastClassification?.status,
            retryable: true,
            cause: lastError,
        });
    };

    const getHealth = () => {
        refreshExpiredCooldowns();
        const availableKeys = states.filter(
            (state) => state.status === KEY_STATUS.AVAILABLE,
        ).length;
        const cooldownStates = states.filter(
            (state) => state.status === KEY_STATUS.COOLDOWN,
        );
        const disabledKeys = states.filter(
            (state) => state.status === KEY_STATUS.DISABLED,
        ).length;
        const nextAvailableAt =
            cooldownStates.length > 0
                ? Math.min(
                      ...cooldownStates.map((state) => state.cooldownUntil),
                  )
                : null;

        return {
            model: config.model,
            totalKeys: states.length,
            availableKeys,
            cooldownKeys: cooldownStates.length,
            disabledKeys,
            nextAvailableInMs:
                nextAvailableAt === null
                    ? null
                    : Math.max(0, nextAvailableAt - nowFn()),
        };
    };

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
