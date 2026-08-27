import test from "node:test";
import assert from "node:assert/strict";
import {
    hitungSemuaZScore,
    hitungUsiaHari,
    statusBBU,
    statusTBU,
    statusBBTBdanIMTU,
    ZScoreValidationError,
} from "../src/services/zscoreService.js";
import {
    hitungSAW,
    KRITERIA,
    normalisasiPrioritasZScore,
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
    assert.ok(Number.isFinite(result.zscore_imtu));
    assert.equal(result.nilai_imt, 15.22);
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

test("kategori antropometri mengikuti ambang Permenkes", () => {
    assert.equal(statusBBU(-3.01), "berat_badan_sangat_kurang");
    assert.equal(statusBBU(-3), "berat_badan_kurang");
    assert.equal(statusBBU(-2), "berat_badan_normal");
    assert.equal(statusBBU(1), "berat_badan_normal");
    assert.equal(statusBBU(1.01), "risiko_berat_badan_lebih");

    assert.equal(statusTBU(-3.01), "sangat_pendek");
    assert.equal(statusTBU(-3), "pendek");
    assert.equal(statusTBU(3), "normal");
    assert.equal(statusTBU(3.01), "tinggi");

    assert.equal(statusBBTBdanIMTU(-3.01), "gizi_buruk");
    assert.equal(statusBBTBdanIMTU(-3), "gizi_kurang");
    assert.equal(statusBBTBdanIMTU(-2), "gizi_baik");
    assert.equal(statusBBTBdanIMTU(1), "gizi_baik");
    assert.equal(statusBBTBdanIMTU(1.01), "risiko_gizi_lebih");
    assert.equal(statusBBTBdanIMTU(2.01), "gizi_lebih");
    assert.equal(statusBBTBdanIMTU(3.01), "obesitas");
});

test("SAW memakai empat kriteria literatur tanpa tren berat", () => {
    assert.equal(KRITERIA.reduce((total, item) => total + item.bobot, 0), 1);
    assert.deepEqual(
        KRITERIA.map(({ nama_kriteria, bobot }) => [nama_kriteria, bobot]),
        [
            ["zscore_bbu", 0.25],
            ["zscore_tbu", 0.30],
            ["zscore_bbtb", 0.25],
            ["zscore_imtu", 0.20],
        ],
    );

    const normal = hitungSAW({
        zscore_bbu: 0,
        zscore_tbu: 0,
        zscore_bbtb: 0,
        zscore_imtu: 0,
    });
    const perluPerhatian = hitungSAW({
        zscore_bbu: -3,
        zscore_tbu: -3,
        zscore_bbtb: -3,
        zscore_imtu: -3,
    });

    assert.equal(normal.skor_akhir, 0);
    assert.equal(normal.kategori_prioritas, "rendah");
    assert.equal(perluPerhatian.skor_akhir, 1);
    assert.equal(perluPerhatian.kategori_prioritas, "tinggi");
    assert.equal(normalisasiPrioritasZScore(-1.5), 0.5);
    assert.equal(normal.detail.some((item) => item.nama_kriteria === "tren_bb"), false);
    assert.throws(
        () => hitungSAW({
            zscore_bbu: 0,
            zscore_tbu: 0,
            zscore_bbtb: 0,
        }),
        /Z-score SAW harus berupa angka/,
    );
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

test("BB/TB dan IMT/U dapat mengklasifikasikan obesitas secara independen", () => {
    const result = hitungSemuaZScore({
        berat_badan: 20,
        tinggi_badan: 85,
        tanggal_lahir: "2024-08-26",
        tanggal_ukur: "2026-08-26",
        jenis_kelamin: "L",
    });

    assert.equal(result.status_bbtb, "obesitas");
    assert.equal(result.status_imtu, "obesitas");
    assert.equal("status_gizi" in result, false);
});
