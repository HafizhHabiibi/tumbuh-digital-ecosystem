import assert from "node:assert/strict";
import test from "node:test";

import { validateEnvironment } from "../src/config.js";

const validEnvironment = (overrides = {}) => ({
    DB_HOST: "localhost",
    DB_USER: "root",
    DB_NAME: "posyandu_test",
    JWT_SECRET: "a".repeat(32),
    JWT_REFRESH_SECRET: "b".repeat(32),
    CORS_ORIGIN: "http://localhost:5173",
    ...overrides,
});

test("startup memvalidasi konfigurasi Gemini tanpa mengekspos API key", () => {
    const result = validateEnvironment(validEnvironment({
        GEMINI_API_KEYS: "secret-key-one,secret-key-two",
        GEMINI_MODEL: "gemini-3.6-flash",
    }));

    assert.deepEqual(result.ai, {
        configured: true,
        model: "gemini-3.6-flash",
    });
    assert.equal(JSON.stringify(result).includes("secret-key"), false);
});

test("startup tetap hidup tanpa key agar health live dapat digunakan", () => {
    const result = validateEnvironment(validEnvironment());

    assert.deepEqual(result.ai, {
        configured: false,
        model: "gemini-3.6-flash",
    });
});

test("startup menolak batas numerik Gemini yang tidak valid", () => {
    assert.throws(
        () => validateEnvironment(validEnvironment({
            GEMINI_TIMEOUT_MS: "0",
        })),
        /GEMINI_TIMEOUT_MS/,
    );
});

test("startup menormalisasi allowlist CORS dan hostname Turnstile", () => {
    const result = validateEnvironment(validEnvironment({
        CORS_ORIGIN: "http://localhost:5173,https://dashboard.example.test",
        TURNSTILE_ALLOWED_HOSTNAMES: "LOCALHOST, dashboard.example.test",
    }));

    assert.deepEqual(result.corsOrigins, [
        "http://localhost:5173",
        "https://dashboard.example.test",
    ]);
    assert.deepEqual(result.turnstileAllowedHostnames, [
        "localhost",
        "dashboard.example.test",
    ]);
});

test("startup menolak origin CORS yang bukan origin HTTP(S)", () => {
    assert.throws(
        () => validateEnvironment(validEnvironment({
            CORS_ORIGIN: "http://localhost:5173/path",
        })),
        /CORS_ORIGIN/,
    );
});

test("startup mewajibkan secret access dan refresh yang berbeda", () => {
    assert.throws(
        () => validateEnvironment(validEnvironment({
            JWT_REFRESH_SECRET: "a".repeat(32),
        })),
        /harus berbeda/,
    );
});

test("HSTS hanya dapat diaktifkan untuk production", () => {
    assert.throws(
        () => validateEnvironment(validEnvironment({
            ENABLE_HSTS: "true",
        })),
        /NODE_ENV=production/,
    );

    const result = validateEnvironment(validEnvironment({
        ENABLE_HSTS: "true",
        NODE_ENV: "production",
        TURNSTILE_SECRET_KEY: "turnstile-test-secret",
        TURNSTILE_ALLOWED_HOSTNAMES: "dashboard.example.test",
    }));
    assert.equal(result.hstsEnabled, true);
});

test("production mewajibkan secret dan hostname Turnstile", () => {
    assert.throws(
        () => validateEnvironment(validEnvironment({ NODE_ENV: "production" })),
        /TURNSTILE_SECRET_KEY/,
    );
    assert.throws(
        () => validateEnvironment(validEnvironment({
            NODE_ENV: "production",
            TURNSTILE_SECRET_KEY: "turnstile-test-secret",
        })),
        /TURNSTILE_ALLOWED_HOSTNAMES/,
    );
});
