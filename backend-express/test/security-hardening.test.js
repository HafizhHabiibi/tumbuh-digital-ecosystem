import test from "node:test";
import assert from "node:assert/strict";

import { validateBody } from "../src/middlewares/validate.js";
import { resetPasswordSchema } from "../src/validation/schemas.js";
import {
    getAllowedTurnstileHostnames,
    isTurnstileResultAccepted,
} from "../src/utils/turnstile.js";

const validate = (schema, body) => {
    const req = { body };
    const res = {
        statusCode: 200,
        body: null,
        status(code) {
            this.statusCode = code;
            return this;
        },
        json(payload) {
            this.body = payload;
            return this;
        },
    };
    let nextCalled = false;
    validateBody(schema)(req, res, () => {
        nextCalled = true;
    });
    return { res, nextCalled };
};

test("password baru minimal 8 karakter dan maksimal 72 byte UTF-8", () => {
    const short = validate(resetPasswordSchema, {
        token: "t".repeat(20),
        password_baru: "1234567",
    });
    assert.equal(short.nextCalled, false);
    assert.equal(short.res.statusCode, 400);
    assert.match(short.res.body.message, /8-72/);

    const accepted = validate(resetPasswordSchema, {
        token: "t".repeat(20),
        password_baru: "12345678",
    });
    assert.equal(accepted.nextCalled, true);

    const exceedsBcryptBytes = validate(resetPasswordSchema, {
        token: "t".repeat(20),
        password_baru: "🔐".repeat(20),
    });
    assert.equal(exceedsBcryptBytes.nextCalled, false);
    assert.match(exceedsBcryptBytes.res.body.message, /72 byte UTF-8/);
});

test("Turnstile wajib cocok success, action, dan hostname allowlist", () => {
    const allowed = ["localhost", "dashboard.example.test"];
    assert.equal(isTurnstileResultAccepted({
        success: true,
        action: "login",
        hostname: "dashboard.example.test",
    }, "login", allowed), true);

    for (const result of [
        { success: false, action: "login", hostname: "dashboard.example.test" },
        { success: true, action: "forgot-password", hostname: "dashboard.example.test" },
        { success: true, action: "login", hostname: "attacker.example" },
        { success: true, action: "login", hostname: null },
    ]) {
        assert.equal(isTurnstileResultAccepted(result, "login", allowed), false);
    }
});

test("hostname Turnstile dari environment dinormalisasi", () => {
    assert.deepEqual(getAllowedTurnstileHostnames({
        TURNSTILE_ALLOWED_HOSTNAMES: " LOCALHOST,Dashboard.Example.Test ",
    }), ["localhost", "dashboard.example.test"]);
});
