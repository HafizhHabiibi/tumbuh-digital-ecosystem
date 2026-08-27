import rateLimit, { ipKeyGenerator } from "express-rate-limit";
import aiObservability from "../services/aiObservabilityService.js";
import { error } from "../utils/response.js";

const readPositiveInteger = (value, fallback, name) => {
    if (value === undefined || value === null || value === "") return fallback;
    const parsed = Number(value);
    if (!Number.isInteger(parsed) || parsed < 1) {
        throw new Error(`${name} harus berupa bilangan bulat positif`);
    }
    return parsed;
};

export const getChatRateLimitConfig = (env = process.env) => ({
    windowMs: readPositiveInteger(
        env.CHAT_RATE_LIMIT_WINDOW_MS,
        5 * 60 * 1000,
        "CHAT_RATE_LIMIT_WINDOW_MS",
    ),
    max: readPositiveInteger(
        env.CHAT_RATE_LIMIT_MAX,
        10,
        "CHAT_RATE_LIMIT_MAX",
    ),
});

export const createChatRateLimit = (options = {}) => {
    const config = options.config || getChatRateLimitConfig();
    const observability = options.observability || aiObservability;

    return rateLimit({
        windowMs: config.windowMs,
        max: config.max,
        standardHeaders: true,
        legacyHeaders: false,
        keyGenerator: (req) =>
            req.orangTua?.id
                ? `orang-tua:${req.orangTua.id}`
                : ipKeyGenerator(req),
        handler: (req, res) => {
            observability.recordRateLimited({ requestId: req.id });
            return error(
                res,
                "Terlalu banyak pesan dalam waktu singkat. Silakan tunggu sebelum mencoba kembali.",
                429,
            );
        },
    });
};

export const chatRateLimit = createChatRateLimit();
