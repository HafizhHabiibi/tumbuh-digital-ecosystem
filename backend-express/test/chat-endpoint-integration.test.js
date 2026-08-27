import test from "node:test";
import assert from "node:assert/strict";
import express from "express";

import { buatChatRouter } from "../src/routes/chat.js";

const CLIENT_ID = "018f0000-0000-7000-8000-000000000001";

const bukaServer = async () => {
    const calls = [];
    const router = buatChatRouter({
        getHistory: (req, res) => {
            calls.push({ type: "get", params: req.validatedParams, query: req.validatedQuery });
            res.json({ success: true, data: { messages: [] } });
        },
        postMessage: (req, res) => {
            calls.push({ type: "post", params: req.validatedParams, body: req.body });
            res.status(201).json({ success: true, data: req.body });
        },
    });
    const app = express();
    app.use(express.json());
    app.use((req, res, next) => {
        const role = req.headers["x-test-role"];
        if (!role) return res.status(401).json({ success: false });
        if (role !== "orang_tua") return res.status(403).json({ success: false });
        req.orangTua = { id: "orang-tua-1" };
        return next();
    });
    app.use("/api/orang-tua/pengukuran", router);
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    return {
        calls,
        baseUrl: `http://127.0.0.1:${server.address().port}`,
        close: () => new Promise((resolve) => {
            server.close(resolve);
            server.closeAllConnections?.();
        }),
    };
};

test("endpoint chatbot memvalidasi akses, parameter, cursor, dan body", async () => {
    const server = await bukaServer();
    const url = `${server.baseUrl}/api/orang-tua/pengukuran/12/chat`;
    try {
        assert.equal((await fetch(url)).status, 401);
        assert.equal((await fetch(url, { headers: { "x-test-role": "kader" } })).status, 403);

        const history = await fetch(`${url}?limit=25&before_id=100`, {
            headers: { "x-test-role": "orang_tua" },
        });
        assert.equal(history.status, 200);
        assert.deepEqual(server.calls.at(-1), {
            type: "get",
            params: { id: 12 },
            query: { limit: 25, before_id: 100 },
        });

        const posted = await fetch(url, {
            method: "POST",
            headers: {
                "content-type": "application/json",
                "x-test-role": "orang_tua",
            },
            body: JSON.stringify({
                client_message_id: CLIENT_ID,
                message: "Bagaimana pola makannya?",
            }),
        });
        assert.equal(posted.status, 201);

        const invalidId = await fetch(
            `${server.baseUrl}/api/orang-tua/pengukuran/bukan-id/chat`,
            { headers: { "x-test-role": "orang_tua" } },
        );
        const invalidBody = await fetch(url, {
            method: "POST",
            headers: {
                "content-type": "application/json",
                "x-test-role": "orang_tua",
            },
            body: JSON.stringify({
                client_message_id: "bukan-uuid",
                message: "x",
            }),
        });
        assert.equal(invalidId.status, 400);
        assert.equal(invalidBody.status, 400);
    } finally {
        await server.close();
    }
});
