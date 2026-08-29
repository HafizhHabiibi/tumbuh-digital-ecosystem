import test from "node:test";
import assert from "node:assert/strict";
import express from "express";

import { buatForgotPassword } from "../src/controllers/authController.js";
import { forgotPasswordEmailRateLimit } from "../src/middlewares/loginRateLimit.js";

const createResponse = () => ({
    statusCode: 200,
    body: null,
    status(code) {
        this.statusCode = code;
        return this;
    },
    json(body) {
        this.body = body;
        return this;
    },
});

test("forgot password mobile production tidak memerlukan Turnstile", async () => {
    let turnstileCalled = false;
    const handler = buatForgotPassword({
        findByEmail: async () => null,
        verifyTurnstileFn: async () => {
            turnstileCalled = true;
            return { success: true };
        },
        getNodeEnv: () => "production",
    });
    const req = {
        body: { email: "parent@example.com", platform: "mobile" },
        ip: "127.0.0.1",
    };
    const res = createResponse();

    await handler(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(turnstileCalled, false);
    assert.equal(
        res.body.message,
        "Jika email terdaftar, link reset password akan dikirimkan",
    );
});

test("forgot password web production tetap memerlukan Turnstile", async () => {
    let findUserCalled = false;
    const handler = buatForgotPassword({
        findByEmail: async () => {
            findUserCalled = true;
            return null;
        },
        getNodeEnv: () => "production",
    });
    const req = {
        body: { email: "parent@example.com", platform: "web" },
        ip: "127.0.0.1",
    };
    const res = createResponse();

    await handler(req, res);

    assert.equal(res.statusCode, 400);
    assert.equal(res.body.message, "turnstileToken wajib disertakan");
    assert.equal(findUserCalled, false);
});

test("respons mobile tetap generik dan email dikirim untuk akun terdaftar", async () => {
    const sent = [];
    const handler = buatForgotPassword({
        findByEmail: async () => ({ id: "user-1", email: "parent@example.com" }),
        generateResetTokenFn: (id) => `token-${id}`,
        sendResetEmail: async (email, token) => sent.push({ email, token }),
        getNodeEnv: () => "production",
    });
    const req = {
        body: { email: "parent@example.com", platform: "mobile" },
        ip: "127.0.0.1",
    };
    const res = createResponse();

    await handler(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(
        res.body.message,
        "Jika email terdaftar, link reset password akan dikirimkan",
    );
    assert.deepEqual(sent, [{
        email: "parent@example.com",
        token: "token-user-1",
    }]);
});

test("rate limit forgot password menghitung response sukses per email", async () => {
    const app = express();
    app.use(express.json());
    app.post(
        "/forgot-password",
        forgotPasswordEmailRateLimit,
        (req, res) => res.sendStatus(204),
    );
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    const url = `http://127.0.0.1:${server.address().port}/forgot-password`;
    const send = () => fetch(url, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ email: "limited@example.com" }),
    });

    try {
        assert.equal((await send()).status, 204);
        assert.equal((await send()).status, 204);
        assert.equal((await send()).status, 204);
        const blocked = await send();
        assert.equal(blocked.status, 429);
        assert.match((await blocked.json()).message, /terlalu banyak/i);
    } finally {
        await new Promise((resolve) => server.close(resolve));
        server.closeAllConnections?.();
    }
});
