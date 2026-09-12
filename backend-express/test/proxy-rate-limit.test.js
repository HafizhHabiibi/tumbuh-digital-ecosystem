import test from "node:test";
import assert from "node:assert/strict";
import express from "express";

import { ipRateLimit } from "../src/middlewares/loginRateLimit.js";

test("rate limit memakai IP proxy dan menormalisasi subnet IPv6", async () => {
    const app = express();
    app.set("trust proxy", 1);
    app.post("/login", ipRateLimit, (req, res) => res.sendStatus(401));
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    const url = `http://127.0.0.1:${server.address().port}/login`;
    const send = (forwardedFor) => fetch(url, {
        method: "POST",
        headers: { "x-forwarded-for": forwardedFor },
    });

    try {
        for (let attempt = 0; attempt < 10; attempt++) {
            assert.equal(
                (await send("2001:db8:85a3:1200::1")).status,
                401,
            );
        }
        assert.equal(
            (await send("2001:db8:85a3:12ff::99")).status,
            429,
        );
        assert.equal((await send("198.51.100.22")).status, 401);
    } finally {
        server.closeAllConnections?.();
        await new Promise((resolve, reject) => {
            server.close((error) => error ? reject(error) : resolve());
        });
    }
});
