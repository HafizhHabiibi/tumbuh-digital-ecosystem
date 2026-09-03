import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

import {
    hitungSemuaZScore,
    PENGUKURAN_USIA_DI_LUAR_REFERENSI,
    validasiRentangUsiaPengukuran,
    ZScoreValidationError,
} from "../src/services/zscoreService.js";

test("ukuran dinormalisasi dua desimal sebelum menjadi input perhitungan dan penyimpanan", async () => {
    const { normalizeMeasurement, MeasurementValidationError } = await import(
        "../src/utils/measurement.js"
    );

    assert.equal(normalizeMeasurement(10.123), 10.12);
    assert.equal(normalizeMeasurement("85.678"), 85.68);
    assert.equal(normalizeMeasurement(1), 1);
    assert.equal(normalizeMeasurement(null, { required: false }), null);
    assert.throws(
        () => normalizeMeasurement(0.005, { min: 0.01, max: 30 }),
        MeasurementValidationError,
    );
    assert.equal(
        normalizeMeasurement(0.01, { min: 0.01, max: 30 }),
        0.01,
    );
    assert.equal(normalizeMeasurement(30, { min: 0.01, max: 30 }), 30);
    assert.throws(
        () => normalizeMeasurement(30.01, { min: 0.01, max: 30 }),
        MeasurementValidationError,
    );
    assert.equal(normalizeMeasurement(120, { min: 0.01, max: 120 }), 120);
    assert.equal(normalizeMeasurement(80, { min: 1, max: 80 }), 80);
    assert.equal(normalizeMeasurement(60, { min: 1, max: 60 }), 60);
});

test("referensi WHO menerima hari ke-0 dan ke-1856", () => {
    const newborn = hitungSemuaZScore({
        berat_badan: 3.3,
        tinggi_badan: 50,
        tanggal_lahir: "2026-09-03",
        tanggal_ukur: "2026-09-03",
        jenis_kelamin: "L",
    });
    const upperBoundary = hitungSemuaZScore({
        berat_badan: 18,
        tinggi_badan: 105,
        tanggal_lahir: "2021-08-04",
        tanggal_ukur: "2026-09-03",
        jenis_kelamin: "P",
    });

    assert.equal(newborn.usia_hari, 0);
    assert.equal(upperBoundary.usia_hari, 1856);
});

test("referensi WHO menolak hari ke-1857", () => {
    assert.throws(
        () => hitungSemuaZScore({
            berat_badan: 18,
            tinggi_badan: 105,
            tanggal_lahir: "2021-08-03",
            tanggal_ukur: "2026-09-03",
            jenis_kelamin: "P",
        }),
        (error) =>
            error instanceof ZScoreValidationError &&
            /0-1856 hari/.test(error.message) &&
            error.code === PENGUKURAN_USIA_DI_LUAR_REFERENSI,
    );
});

test("validasi hari kalender konsisten melewati tahun kabisat", () => {
    assert.equal(
        validasiRentangUsiaPengukuran("2024-02-28", "2024-03-01", {
            hariIni: "2026-09-03",
        }),
        2,
    );
});

test("Date lokal dini hari WIB tidak bergeser ke hari UTC sebelumnya", () => {
    const waktuWibDiniHari = new Date(2026, 8, 3, 0, 30);
    assert.equal(
        validasiRentangUsiaPengukuran(
            "2026-09-02",
            waktuWibDiniHari,
            { hariIni: waktuWibDiniHari },
        ),
        1,
    );
});

test("notifikasi dan PDF menggunakan simbol SI dengan kapitalisasi benar", () => {
    const sources = [
        "../src/controllers/pengukuranController.js",
        "../src/services/laporanRendererService.js",
    ].map((relativePath) => fs.readFileSync(
        new URL(relativePath, import.meta.url),
        "utf8",
    ));

    for (const source of sources) {
        assert.doesNotMatch(source, /\bKG\b|\bCM\b|KG\/m²/);
    }
});
