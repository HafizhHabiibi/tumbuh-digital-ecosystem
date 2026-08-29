import rateLimit, { ipKeyGenerator } from "express-rate-limit";
import { error } from "../utils/response.js";

export const ipRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: true,
    // Gunakan ipKeyGenerator untuk normalisasi IPv6 agar user tidak bisa bypass limit
    keyGenerator: (req) => ipKeyGenerator(req),

    handler: (req, res) => {
        const retryAfter = Math.ceil(
            req.rateLimit.resetTime / 1000 - Date.now() / 1000,
        );
        return error(
            res,
            `Terlalu banyak percobaan login. Coba lagi dalam ${Math.ceil(retryAfter / 60)} menit.`,
            429,
        );
    },
});

export const emailRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: true,
    // Key berdasarkan email — fallback ke IP (dengan normalisasi IPv6) jika email tidak ada di body
    keyGenerator: (req) => {
        const email = req.body?.email?.toLowerCase()?.trim();
        return email ? `email:${email}` : ipKeyGenerator(req);
    },

    handler: (req, res) => {
        return error(
            res,
            "Akun ini sementara dikunci karena terlalu banyak percobaan login gagal. Coba lagi dalam 15 menit atau reset password Anda.",
            429,
        );
    },
});

export const forgotPasswordIpRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => ipKeyGenerator(req),
    handler: (req, res) => {
        return error(
            res,
            "Terlalu banyak permintaan reset password. Coba lagi dalam 15 menit.",
            429,
        );
    },
});

export const forgotPasswordEmailRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 3,
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => {
        const email = req.body?.email?.toLowerCase()?.trim();
        return email ? `forgot:${email}` : ipKeyGenerator(req);
    },
    handler: (req, res) => {
        return error(
            res,
            "Terlalu banyak permintaan reset untuk email ini. Coba lagi dalam 15 menit.",
            429,
        );
    },
});
