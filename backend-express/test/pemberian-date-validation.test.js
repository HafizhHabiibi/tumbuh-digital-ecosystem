import test from "node:test";
import assert from "node:assert/strict";

import { isTanggalPemberianSebelumLahir } from "../src/controllers/pemberianController.js";

test("pemberian menolak tanggal sebelum anak lahir", () => {
    assert.equal(
        isTanggalPemberianSebelumLahir("2024-02-20", "2024-02-19"),
        true,
    );
});

test("pemberian menerima tanggal lahir dan tanggal setelahnya", () => {
    assert.equal(
        isTanggalPemberianSebelumLahir("2024-02-20", "2024-02-20"),
        false,
    );
    assert.equal(
        isTanggalPemberianSebelumLahir("2024-02-20", "2025-01-01"),
        false,
    );
});

test("validasi tanggal lahir konsisten untuk nilai Date dari database", () => {
    const tanggalLahir = new Date(2024, 1, 20);
    assert.equal(
        isTanggalPemberianSebelumLahir(tanggalLahir, "2024-02-19"),
        true,
    );
});
