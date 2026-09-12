import "dotenv/config";
import { getGeminiConfig } from "./integrations/geminiClient.js";

const REQUIRED_ENV = [
    "DB_HOST",
    "DB_USER",
    "DB_NAME",
    "JWT_SECRET",
    "JWT_REFRESH_SECRET",
    "CORS_ORIGIN",
];

const parseCommaSeparated = (value) => (value || "")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);

const parseCorsOrigins = (value) => {
    const origins = parseCommaSeparated(value);
    for (const origin of origins) {
        let parsed;
        try {
            parsed = new URL(origin);
        } catch {
            throw new Error(`CORS_ORIGIN tidak valid: ${origin}`);
        }
        if (
            !["http:", "https:"].includes(parsed.protocol) ||
            parsed.origin !== origin ||
            parsed.username ||
            parsed.password
        ) {
            throw new Error(`CORS_ORIGIN harus berupa origin HTTP(S): ${origin}`);
        }
    }
    return origins;
};

const parseTurnstileHostnames = (value) => {
    const hostnames = parseCommaSeparated(value).map((item) => item.toLowerCase());
    for (const hostname of hostnames) {
        if (
            hostname.length > 253 ||
            !/^(localhost|(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)*[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)$/.test(hostname)
        ) {
            throw new Error(`TURNSTILE_ALLOWED_HOSTNAMES tidak valid: ${hostname}`);
        }
    }
    return [...new Set(hostnames)];
};

export const validateEnvironment = (env = process.env) => {
    const missing = REQUIRED_ENV.filter((name) => !env[name]?.trim());
    if (missing.length > 0) {
        throw new Error(
            `Environment wajib belum dikonfigurasi: ${missing.join(", ")}`,
        );
    }

    if (env.JWT_SECRET.length < 32) {
        throw new Error("JWT_SECRET harus memiliki minimal 32 karakter");
    }
    if (env.JWT_REFRESH_SECRET.length < 32) {
        throw new Error("JWT_REFRESH_SECRET harus memiliki minimal 32 karakter");
    }
    if (env.JWT_SECRET === env.JWT_REFRESH_SECRET) {
        throw new Error("JWT_SECRET dan JWT_REFRESH_SECRET harus berbeda");
    }

    const nodeEnv = env.NODE_ENV || "development";
    if (!["development", "test", "production"].includes(nodeEnv)) {
        throw new Error("NODE_ENV harus development, test, atau production");
    }

    const corsOrigins = parseCorsOrigins(env.CORS_ORIGIN);
    const turnstileAllowedHostnames = parseTurnstileHostnames(
        env.TURNSTILE_ALLOWED_HOSTNAMES,
    );
    if (nodeEnv === "production" && !env.TURNSTILE_SECRET_KEY?.trim()) {
        throw new Error("TURNSTILE_SECRET_KEY wajib pada NODE_ENV=production");
    }
    if (nodeEnv === "production" && turnstileAllowedHostnames.length === 0) {
        throw new Error(
            "TURNSTILE_ALLOWED_HOSTNAMES wajib pada NODE_ENV=production",
        );
    }

    if (env.ENABLE_HSTS && !["true", "false"].includes(env.ENABLE_HSTS)) {
        throw new Error("ENABLE_HSTS harus bernilai true atau false");
    }
    const hstsEnabled = env.ENABLE_HSTS === "true";
    if (hstsEnabled && nodeEnv !== "production") {
        throw new Error("ENABLE_HSTS hanya boleh aktif pada NODE_ENV=production");
    }

    const port = Number(env.PORT || 3000);
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
        throw new Error("PORT harus berupa angka antara 1-65535");
    }

    const trustProxyHops = Number(env.TRUST_PROXY_HOPS || 0);
    if (!Number.isInteger(trustProxyHops) || trustProxyHops < 0 || trustProxyHops > 10) {
        throw new Error("TRUST_PROXY_HOPS harus berupa angka antara 0-10");
    }

    const requestTimeoutMs = Number(env.REQUEST_TIMEOUT_MS || 120_000);
    if (
        !Number.isInteger(requestTimeoutMs) ||
        requestTimeoutMs < 1_000 ||
        requestTimeoutMs > 300_000
    ) {
        throw new Error("REQUEST_TIMEOUT_MS harus berupa angka antara 1000-300000");
    }

    // Memvalidasi seluruh batas numerik Gemini saat startup. API key tidak
    // diwajibkan untuk menyalakan proses agar endpoint live tetap berguna,
    // tetapi readiness akan menandai fitur AI sebagai belum siap.
    const gemini = getGeminiConfig(env);

    return {
        port,
        trustProxyHops,
        requestTimeoutMs,
        nodeEnv,
        hstsEnabled,
        corsOrigins,
        turnstileAllowedHostnames,
        ai: {
            configured: gemini.apiKeys.length > 0,
            model: gemini.model,
        },
    };
};
