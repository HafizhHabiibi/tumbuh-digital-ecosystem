import test from "node:test";
import assert from "node:assert/strict";

import { buatLogin } from "../src/controllers/authController.js";

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

const executeLogin = async ({ role, platform, passwordMatches = true }) => {
    const calls = {
        accessToken: 0,
        refreshToken: 0,
        saveRefreshToken: 0,
        profile: 0,
        fcm: 0,
    };
    const profile = { id: `profile-${role}` };
    const findProfile = async () => {
        calls.profile++;
        return profile;
    };
    const handler = buatLogin({
        findByEmail: async () => ({
            id: "user-1",
            email: "user@example.com",
            role,
            password_hash: "hash",
        }),
        comparePassword: async () => passwordMatches,
        findKaderByUserId: findProfile,
        findPuskesmasByUserId: findProfile,
        findOrangTuaByUserId: findProfile,
        updateOrangTuaFcmToken: async () => {
            calls.fcm++;
        },
        generateTokenFn: () => {
            calls.accessToken++;
            return "access-token";
        },
        generateRefreshTokenFn: () => {
            calls.refreshToken++;
            return "refresh-token";
        },
        saveRefreshToken: async () => {
            calls.saveRefreshToken++;
        },
        getNodeEnv: () => "development",
        now: () => Date.UTC(2026, 8, 3),
    });
    const body = {
        email: "user@example.com",
        password: "benar",
        fcm_token: "fcm-token",
    };
    if (platform !== undefined) body.platform = platform;
    const req = { body, ip: "127.0.0.1" };
    const res = createResponse();

    await handler(req, res);
    return { res, calls, profile };
};

for (const role of ["kader", "puskesmas"]) {
    test(`login web ${role} berhasil tanpa refresh token`, async () => {
        const { res, calls, profile } = await executeLogin({
            role,
            platform: "web",
        });

        assert.equal(res.statusCode, 200);
        assert.equal(res.body.data.user.role, role);
        assert.deepEqual(res.body.data.user.profil, profile);
        assert.equal(res.body.data.refresh_token, undefined);
        assert.equal(calls.accessToken, 1);
        assert.equal(calls.refreshToken, 0);
        assert.equal(calls.saveRefreshToken, 0);
    });
}

test("login mobile orang tua berhasil dengan refresh token dan FCM", async () => {
    const { res, calls } = await executeLogin({
        role: "orang_tua",
        platform: "mobile",
    });

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.data.user.role, "orang_tua");
    assert.equal(res.body.data.refresh_token, "refresh-token");
    assert.equal(calls.accessToken, 1);
    assert.equal(calls.refreshToken, 1);
    assert.equal(calls.saveRefreshToken, 1);
    assert.equal(calls.fcm, 1);
});

for (const [platform, role] of [
    ["web", "orang_tua"],
    ["mobile", "kader"],
    ["mobile", "puskesmas"],
]) {
    test(`login ${platform} menolak role ${role} sebelum membuat token`, async () => {
        const { res, calls } = await executeLogin({ role, platform });

        assert.equal(res.statusCode, 403);
        assert.equal(res.body.data, null);
        assert.equal(calls.accessToken, 0);
        assert.equal(calls.refreshToken, 0);
        assert.equal(calls.saveRefreshToken, 0);
        assert.equal(calls.profile, 0);
        assert.equal(calls.fcm, 0);
    });
}

test("platform kosong diperlakukan sebagai web", async () => {
    const petugas = await executeLogin({ role: "kader" });
    const orangTua = await executeLogin({ role: "orang_tua" });

    assert.equal(petugas.res.statusCode, 200);
    assert.equal(orangTua.res.statusCode, 403);
});

test("password salah tidak membocorkan pembatasan role", async () => {
    const { res, calls } = await executeLogin({
        role: "orang_tua",
        platform: "web",
        passwordMatches: false,
    });

    assert.equal(res.statusCode, 400);
    assert.equal(res.body.message, "Email atau password salah");
    assert.equal(calls.accessToken, 0);
    assert.equal(calls.profile, 0);
});

