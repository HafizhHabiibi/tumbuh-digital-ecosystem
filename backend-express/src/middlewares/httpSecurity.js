const REQUEST_ID_PATTERN = /^[A-Za-z0-9][A-Za-z0-9._:-]{0,99}$/;

export const normalizeRequestId = (value, fallback) => {
    if (typeof value === "string" && REQUEST_ID_PATTERN.test(value)) {
        return value;
    }
    return fallback();
};

export const createCorsOptions = (allowedOrigins) => ({
    origin(origin, callback) {
        // Native/mobile clients and command-line health checks do not send Origin.
        if (!origin || allowedOrigins.includes(origin)) {
            return callback(null, true);
        }
        const corsError = new Error("Origin tidak diizinkan oleh CORS");
        corsError.status = 403;
        corsError.code = "CORS_ORIGIN_DENIED";
        return callback(corsError);
    },
    methods: ["GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Authorization", "Content-Type", "X-Request-Id"],
    exposedHeaders: ["Content-Disposition", "X-Request-Id"],
    maxAge: 600,
});

export const securityHeaders = ({ hstsEnabled = false } = {}) =>
    (req, res, next) => {
        // Backend hanya menyajikan API/PDF, bukan dokumen web executable.
        res.setHeader(
            "Content-Security-Policy",
            "default-src 'none'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
        );
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("X-Frame-Options", "DENY");
        res.setHeader("Referrer-Policy", "no-referrer");
        res.setHeader(
            "Permissions-Policy",
            "camera=(), geolocation=(), microphone=(), payment=(), usb=()",
        );
        res.setHeader("Cross-Origin-Opener-Policy", "same-origin");
        if (hstsEnabled) {
            res.setHeader(
                "Strict-Transport-Security",
                "max-age=31536000; includeSubDomains",
            );
        }
        next();
    };
