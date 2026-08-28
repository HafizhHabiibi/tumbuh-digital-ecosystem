import test from "node:test";
import assert from "node:assert/strict";
import { buatAuthenticate } from "../src/middlewares/auth.js";

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

test("token baru tetap valid ketika updated_at dikembalikan sebagai epoch", async () => {
    const req = { headers: { authorization: "Bearer token-baru" } };
    const res = createResponse();
    let nextCalled = false;
    const authenticate = buatAuthenticate({
        verifyTokenFn: () => ({ id: "user-1", role: "kader", iat: 1_800 }),
        findActiveById: async () => ({
            id: "user-1",
            role: "kader",
            updated_at_epoch: 1_700,
        }),
    });

    await authenticate(req, res, () => {
        nextCalled = true;
    });

    assert.equal(nextCalled, true);
    assert.deepEqual(req.user, { id: "user-1", role: "kader" });
    assert.equal(res.statusCode, 200);
});

test("token sebelum perubahan akun ditolak", async () => {
    const req = { headers: { authorization: "Bearer token-lama" } };
    const res = createResponse();
    let nextCalled = false;
    const authenticate = buatAuthenticate({
        verifyTokenFn: () => ({ id: "user-1", role: "kader", iat: 1_600 }),
        findActiveById: async () => ({
            id: "user-1",
            role: "kader",
            updated_at_epoch: "1700",
        }),
    });

    await authenticate(req, res, () => {
        nextCalled = true;
    });

    assert.equal(nextCalled, false);
    assert.equal(res.statusCode, 401);
    assert.equal(
        res.body.message,
        "Sesi sudah tidak berlaku, silakan login ulang",
    );
});

test("request tanpa bearer token ditolak", async () => {
    const req = { headers: {} };
    const res = createResponse();
    const authenticate = buatAuthenticate();

    await authenticate(req, res, () => assert.fail("next tidak boleh dipanggil"));

    assert.equal(res.statusCode, 401);
    assert.equal(res.body.message, "Token tidak ditemukan");
});
