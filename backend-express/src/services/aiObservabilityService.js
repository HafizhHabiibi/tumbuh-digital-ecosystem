import { AI_RESPONSE_TYPES } from "../constants/aiPolicy.js";

const sanitizeToken = (value, fallback = "unknown") => {
    if (value === undefined || value === null || value === "") return fallback;
    return String(value).replace(/[^a-zA-Z0-9._:-]/g, "_").slice(0, 128);
};

const normalizeDuration = (value) =>
    Math.max(0, Math.min(300_000, Math.round(Number(value) || 0)));

export const createAiObservability = (options = {}) => {
    const logger = options.logger || console;
    const nowFn = options.nowFn || Date.now;
    const startedAt = new Date(nowFn()).toISOString();
    const counters = {
        total: 0,
        answered: 0,
        out_of_scope: 0,
        medical_advice_refused: 0,
        idempotent: 0,
        provider_calls: 0,
        rate_limited: 0,
        failures: 0,
        total_duration_ms: 0,
        errors: {},
    };

    const emit = (level, payload) => {
        try {
            const method = typeof logger[level] === "function" ? level : "log";
            logger[method](`[AI_AUDIT] ${JSON.stringify(payload)}`);
        } catch {
            // Gangguan logger tidak boleh menggagalkan percakapan pengguna.
        }
    };

    const recordChatSuccess = ({
        requestId,
        responseType,
        idempotent = false,
        providerUsed = false,
        durationMs = 0,
    }) => {
        const safeResponseType = Object.values(AI_RESPONSE_TYPES).includes(
            responseType,
        )
            ? responseType
            : "unknown";
        const duration = normalizeDuration(durationMs);
        counters.total += 1;
        if (safeResponseType in counters) counters[safeResponseType] += 1;
        if (idempotent) counters.idempotent += 1;
        if (providerUsed) counters.provider_calls += 1;
        counters.total_duration_ms += duration;
        emit("info", {
            event: "chat_completed",
            request_id: sanitizeToken(requestId),
            response_type: safeResponseType,
            idempotent: Boolean(idempotent),
            provider_used: Boolean(providerUsed),
            duration_ms: duration,
        });
    };

    const recordChatFailure = ({
        requestId,
        code,
        providerUsed = false,
        durationMs = 0,
    }) => {
        const safeCode = sanitizeToken(code, "CHAT_UNKNOWN_ERROR");
        const duration = normalizeDuration(durationMs);
        counters.total += 1;
        counters.failures += 1;
        if (providerUsed) counters.provider_calls += 1;
        counters.total_duration_ms += duration;
        counters.errors[safeCode] = (counters.errors[safeCode] || 0) + 1;
        emit("warn", {
            event: "chat_failed",
            request_id: sanitizeToken(requestId),
            error_code: safeCode,
            provider_used: Boolean(providerUsed),
            duration_ms: duration,
        });
    };

    const recordRateLimited = ({ requestId }) => {
        counters.rate_limited += 1;
        emit("warn", {
            event: "chat_rate_limited",
            request_id: sanitizeToken(requestId),
        });
    };

    const getSnapshot = () => ({
        since: startedAt,
        requests: {
            total: counters.total,
            answered: counters.answered,
            out_of_scope: counters.out_of_scope,
            medical_advice_refused: counters.medical_advice_refused,
            failed: counters.failures,
            rate_limited: counters.rate_limited,
            idempotent: counters.idempotent,
            provider_calls: counters.provider_calls,
        },
        average_duration_ms:
            counters.total > 0
                ? Math.round(counters.total_duration_ms / counters.total)
                : 0,
        errors: { ...counters.errors },
    });

    return Object.freeze({
        recordChatSuccess,
        recordChatFailure,
        recordRateLimited,
        getSnapshot,
    });
};

const aiObservability = createAiObservability();
export default aiObservability;
