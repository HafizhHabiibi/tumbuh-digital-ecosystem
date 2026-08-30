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
