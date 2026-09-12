import test from "node:test";
import assert from "node:assert/strict";

const TEST_ENV_DEFAULTS = {
    DB_HOST: "127.0.0.1",
    DB_USER: "smoke-test",
    DB_NAME: "smoke-test",
    JWT_SECRET: "smoke-test-access-secret-minimum-32-chars",
    JWT_REFRESH_SECRET: "smoke-test-refresh-secret-minimum-32-chars",
    CORS_ORIGIN: "http://localhost",
};

for (const [name, value] of Object.entries(TEST_ENV_DEFAULTS)) {
    if (!process.env[name]) process.env[name] = value;
}

test("entry point Express memasang middleware dan route produksi", async (t) => {
    const { default: app } = await import("../app.js");
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    const baseUrl = `http://127.0.0.1:${server.address().port}`;

    try {
        await t.test("health live tersedia dengan kontrak standar", async () => {
            const response = await fetch(`${baseUrl}/api/health/live`);
            const body = await response.json();

            assert.equal(response.status, 200);
            assert.deepEqual(body, {
                success: true,
                message: "Service aktif",
                data: null,
            });
            assert.ok(response.headers.get("x-request-id"));
            assert.equal(response.headers.get("x-content-type-options"), "nosniff");
            assert.equal(response.headers.get("x-frame-options"), "DENY");
            assert.equal(response.headers.get("referrer-policy"), "no-referrer");
            assert.match(
                response.headers.get("content-security-policy"),
                /frame-ancestors 'none'/,
            );
            assert.equal(response.headers.get("x-powered-by"), null);
            assert.equal(response.headers.get("strict-transport-security"), null);
        });

        await t.test("CORS hanya mengizinkan origin yang dikonfigurasi", async () => {
            const allowed = await fetch(`${baseUrl}/api/health/live`, {
                headers: { origin: "http://localhost" },
            });
            assert.equal(allowed.status, 200);
            assert.equal(
                allowed.headers.get("access-control-allow-origin"),
                "http://localhost",
            );

            const denied = await fetch(`${baseUrl}/api/health/live`, {
                headers: { origin: "https://evil.example" },
            });
            assert.equal(denied.status, 403);
            assert.equal((await denied.json()).message, "Origin tidak diizinkan");
        });

        await t.test("request ID hanya menerima karakter aman", async () => {
            const accepted = await fetch(`${baseUrl}/api/health/live`, {
                headers: { "x-request-id": "client-request_123" },
            });
            assert.equal(
                accepted.headers.get("x-request-id"),
                "client-request_123",
            );

            const replaced = await fetch(`${baseUrl}/api/health/live`, {
                headers: { "x-request-id": "id dengan spasi" },
            });
            assert.notEqual(
                replaced.headers.get("x-request-id"),
                "id dengan spasi",
            );
            assert.match(
                replaced.headers.get("x-request-id"),
                /^[0-9a-f-]{36}$/,
            );
        });

        await t.test("prefix route utama terpasang dan terlindungi", async () => {
            const protectedRoutes = [
                "/api/kader/profile",
                "/api/puskesmas/profile",
                "/api/pengukuran/ranking",
                "/api/orang-tua/profile",
                "/api/laporan/rekap",
            ];

            for (const path of protectedRoutes) {
                const response = await fetch(`${baseUrl}${path}`);
                assert.equal(response.status, 401, path);
                assert.notEqual(response.status, 404, path);
            }

            const authResponse = await fetch(`${baseUrl}/api/auth/login`, {
                method: "POST",
                headers: { "content-type": "application/json" },
                body: JSON.stringify({}),
            });
            assert.equal(authResponse.status, 400);
        });

        await t.test("endpoint tidak dikenal memakai kontrak 404", async () => {
            const response = await fetch(`${baseUrl}/api/tidak-ada`);
            const body = await response.json();

            assert.equal(response.status, 404);
            assert.deepEqual(body, {
                success: false,
                message: "Endpoint tidak ditemukan",
                data: null,
            });
        });

        await t.test("JSON invalid ditangani sebagai response 400", async () => {
            const response = await fetch(`${baseUrl}/api/auth/login`, {
                method: "POST",
                headers: { "content-type": "application/json" },
                body: "{",
            });
            const body = await response.json();

            assert.equal(response.status, 400);
            assert.equal(body.success, false);
            assert.match(body.message, /JSON/i);
        });
    } finally {
        server.closeAllConnections?.();
        await new Promise((resolve, reject) => {
            server.close((error) => error ? reject(error) : resolve());
        });
    }
});
