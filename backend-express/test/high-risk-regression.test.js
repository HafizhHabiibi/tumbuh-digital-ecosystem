import test from "node:test";
import assert from "node:assert/strict";
import {
    hitungSemuaZScore,
    hitungUsiaHari,
    ZScoreValidationError,
} from "../src/services/zscoreService.js";
import {
    hitungTrenBBPerBulan,
    normalisasiTrenBB,
} from "../src/services/sawService.js";
import {
    generateRefreshToken,
    verifyRefreshToken,
} from "../src/utils/jwt.js";

test("Z-score menghitung data valid dalam rentang WHO", () => {
    const result = hitungSemuaZScore({
        berat_badan: 11,
        tinggi_badan: 85,
        tanggal_lahir: "2024-08-26",
        tanggal_ukur: "2026-08-26",
        jenis_kelamin: "L",
    });

    assert.equal(result.usia_bulan, 24);
    assert.equal(result.usia_hari, 730);
    assert.ok(Number.isFinite(result.zscore_bbu));
    assert.ok(Number.isFinite(result.zscore_tbu));
    assert.ok(Number.isFinite(result.zscore_bbtb));
});

test("usia WHO dihitung sebagai selisih hari kalender tanpa konversi bulan", () => {
    assert.equal(hitungUsiaHari("2025-01-01", "2025-02-15"), 45);
    assert.equal(hitungUsiaHari("2024-02-28", "2024-03-01"), 2);

    const day45 = hitungSemuaZScore({
        berat_badan: 5,
        tinggi_badan: 55,
        tanggal_lahir: "2025-01-01",
        tanggal_ukur: "2025-02-15",
        jenis_kelamin: "L",
    });

    assert.equal(day45.usia_hari, 45);
    assert.ok(Number.isFinite(day45.zscore_bbu));
    assert.ok(Number.isFinite(day45.zscore_tbu));
});

test("BB/TB berpindah dari tabel panjang ke tinggi pada day 731", () => {
    const common = {
        berat_badan: 8,
        tinggi_badan: 64,
        tanggal_lahir: "2023-01-01",
        jenis_kelamin: "L",
    };

    assert.doesNotThrow(() => hitungSemuaZScore({
        ...common,
        tanggal_ukur: "2024-12-31",
    }));
    assert.throws(
        () => hitungSemuaZScore({
            ...common,
            tanggal_ukur: "2025-01-01",
        }),
        /di luar referensi WHO/,
    );
});

test("Z-score menolak usia di atas 60 bulan dan tidak fallback ke normal", () => {
    assert.throws(
        () => hitungSemuaZScore({
            berat_badan: 18,
            tinggi_badan: 110,
            tanggal_lahir: "2020-01-01",
            tanggal_ukur: "2026-01-02",
            jenis_kelamin: "P",
        }),
        ZScoreValidationError,
    );
});

test("Z-score tetap menerima anak pada bulan usia ke-60", () => {
    const result = hitungSemuaZScore({
        berat_badan: 18,
        tinggi_badan: 108,
        tanggal_lahir: "2021-08-01",
        tanggal_ukur: "2026-08-26",
        jenis_kelamin: "P",
    });

    assert.equal(result.usia_bulan, 60);
});

test("Z-score menolak tanggal ukur sebelum lahir", () => {
    assert.throws(
        () => hitungSemuaZScore({
            berat_badan: 5,
            tinggi_badan: 55,
            tanggal_lahir: "2025-02-01",
            tanggal_ukur: "2025-01-31",
            jenis_kelamin: "L",
        }),
        /sebelum tanggal lahir/,
    );
});

test("Z-score menolak tanggal kalender dan nilai numerik invalid", () => {
    assert.throws(
        () => hitungSemuaZScore({
            berat_badan: "bukan-angka",
            tinggi_badan: 55,
            tanggal_lahir: "2025-02-30",
            tanggal_ukur: "2025-03-01",
            jenis_kelamin: "L",
        }),
        ZScoreValidationError,
    );
});

test("tren berat dinormalisasi berdasarkan interval hari", () => {
    const tren30Hari = hitungTrenBBPerBulan(
        10.2,
        10,
        "2026-01-31",
        "2026-01-01",
    );
    const tren60Hari = hitungTrenBBPerBulan(
        10.2,
        10,
        "2026-03-02",
        "2026-01-01",
    );

    assert.equal(tren30Hari, 0.203);
    assert.equal(tren60Hari, 0.101);
    assert.equal(normalisasiTrenBB(tren30Hari), 0);
    assert.ok(normalisasiTrenBB(tren60Hari) > 0);
});

test("refresh token selalu memiliki jti unik", () => {
    const previousSecret = process.env.JWT_REFRESH_SECRET;
    process.env.JWT_REFRESH_SECRET = "test-only-refresh-secret";
    try {
        const first = generateRefreshToken({ id: "user-1", role: "orang_tua" });
        const second = generateRefreshToken({ id: "user-1", role: "orang_tua" });

        assert.notEqual(first, second);
        assert.notEqual(
            verifyRefreshToken(first).jti,
            verifyRefreshToken(second).jti,
        );
    } finally {
        if (previousSecret === undefined) {
            delete process.env.JWT_REFRESH_SECRET;
        } else {
            process.env.JWT_REFRESH_SECRET = previousSecret;
        }
    }
});

test("ringkasan status gizi dapat mengklasifikasikan obesitas", () => {
    const result = hitungSemuaZScore({
        berat_badan: 20,
        tinggi_badan: 85,
        tanggal_lahir: "2024-08-26",
        tanggal_ukur: "2026-08-26",
        jenis_kelamin: "L",
    });

    assert.equal(result.status_bbtb, "obesitas");
    assert.equal(result.status_gizi, "obesitas");
});
