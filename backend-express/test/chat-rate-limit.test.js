import test from "node:test";
import assert from "node:assert/strict";
import express from "express";

import {
    createChatRateLimit,
    getChatRateLimitConfig,
} from "../src/middlewares/chatRateLimit.js";

test("konfigurasi rate limit memiliki default dan menolak nilai invalid", () => {
    assert.deepEqual(getChatRateLimitConfig({}), {
        windowMs: 300000,
        max: 10,
    });
    assert.throws(
        () => getChatRateLimitConfig({ CHAT_RATE_LIMIT_MAX: "0" }),
        /bilangan bulat positif/,
    );
});

test("rate limit dihitung per orang tua dan mencatat request yang dibatasi", async () => {
    const limited = [];
    const limiter = createChatRateLimit({
        config: { windowMs: 60_000, max: 2 },
        observability: {
            recordRateLimited: (event) => limited.push(event),
        },
    });
    const app = express();
    app.use((req, res, next) => {
        req.id = req.headers["x-request-id"];
        req.orangTua = { id: req.headers["x-parent-id"] };
        next();
    });
    app.post("/chat", limiter, (req, res) => res.sendStatus(204));
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    const url = `http://127.0.0.1:${server.address().port}/chat`;
    const send = (parent, requestId) => fetch(url, {
        method: "POST",
        headers: { "x-parent-id": parent, "x-request-id": requestId },
    });

    try {
        assert.equal((await send("parent-1", "req-1")).status, 204);
        assert.equal((await send("parent-1", "req-2")).status, 204);
        const blocked = await send("parent-1", "req-3");
        assert.equal(blocked.status, 429);
        assert.match((await blocked.json()).message, /terlalu banyak pesan/i);
        assert.equal((await send("parent-2", "req-4")).status, 204);
        assert.deepEqual(limited, [{ requestId: "req-3" }]);
    } finally {
        await new Promise((resolve) => server.close(resolve));
        server.closeAllConnections?.();
    }
});
