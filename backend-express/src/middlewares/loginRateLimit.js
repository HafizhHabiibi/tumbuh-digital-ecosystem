import rateLimit from "express-rate-limit";
import { error } from "../utils/response.js";

export const ipRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: true,
    // req.ip sudah terpercaya karena trust proxy dikonfigurasi di app.js
    keyGenerator: (req) => req.ip,

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
    // Key berdasarkan email — fallback ke IP jika email tidak ada di body
    keyGenerator: (req) => {
        const email = req.body?.email?.toLowerCase()?.trim();
        return email ? `email:${email}` : req.ip;
    },

    handler: (req, res) => {
        return error(
            res,
            "Akun ini sementara dikunci karena terlalu banyak percobaan login gagal. Coba lagi dalam 15 menit atau reset password Anda.",
            429,
        );
    },
});
