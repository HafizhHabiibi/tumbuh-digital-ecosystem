import test from "node:test";
import assert from "node:assert/strict";

test("matriks platform dan role membatasi web ke petugas dan mobile ke orang tua", async () => {
    const { isRoleAllowedOnPlatform } = await import(
        "../src/utils/authAccess.js"
    );

    const cases = [
        ["web", "kader", true],
        ["web", "puskesmas", true],
        ["web", "orang_tua", false],
        ["mobile", "orang_tua", true],
        ["mobile", "kader", false],
        ["mobile", "puskesmas", false],
        [undefined, "kader", true],
        [undefined, "orang_tua", false],
        ["web", "role_tidak_dikenal", false],
    ];

    for (const [platform, role, expected] of cases) {
        assert.equal(
            isRoleAllowedOnPlatform(platform, role),
            expected,
            `${platform ?? "default"} × ${role}`,
        );
    }
});

