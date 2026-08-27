import test from "node:test";
import assert from "node:assert/strict";
import { hashRefreshToken } from "../src/models/refreshTokenModel.js";
import { parsePagination, paginationMeta } from "../src/utils/pagination.js";
import { buildMonthlyScheduleDates } from "../src/utils/schedule.js";
import {
    validateBody,
    validateQuery,
    rules,
} from "../src/middlewares/validate.js";
import { laporanRekapQuerySchema } from "../src/validation/schemas.js";
import { error } from "../src/utils/response.js";

test("refresh token diubah menjadi hash SHA-256 sebelum disimpan", () => {
    const raw = "refresh-token-sangat-rahasia";
    const hash = hashRefreshToken(raw);
    assert.equal(hash.length, 64);
    assert.notEqual(hash, raw);
    assert.equal(hash, hashRefreshToken(raw));
});

test("pagination memiliki default dan membatasi limit maksimum", () => {
    assert.deepEqual(parsePagination({}), { page: 1, limit: 20, offset: 0 });
    assert.deepEqual(
        parsePagination({ page: "3", limit: "999" }),
        { page: 3, limit: 100, offset: 200 },
    );
    assert.deepEqual(paginationMeta(2, 10, 21), {
        page: 2,
        limit: 10,
        total: 21,
        total_pages: 3,
    });
});

test("generator jadwal tidak menduplikasi bulan ketika hari tetap sudah lewat", () => {
    const dates = buildMonthlyScheduleDates(new Date(2026, 7, 26), 5, 3);
    assert.deepEqual(dates, ["2026-09-05", "2026-10-05", "2026-11-05"]);
    assert.equal(new Set(dates).size, dates.length);
});

test("middleware validasi menormalisasi input dan menolak tanggal invalid", () => {
    const middleware = validateBody({
        fields: {
            email: rules.string({ lowercase: true, max: 255 }),
            tanggal: rules.date(),
        },
    });
    const response = {
        statusCode: 200,
        status(code) { this.statusCode = code; return this; },
        json(body) { this.body = body; return this; },
    };
    const validRequest = {
        body: { email: "  USER@EXAMPLE.COM ", tanggal: "2026-08-26" },
    };
    let nextCalled = false;
    middleware(validRequest, response, () => { nextCalled = true; });
    assert.equal(nextCalled, true);
    assert.equal(validRequest.body.email, "user@example.com");

    const invalidRequest = {
        body: { email: "user@example.com", tanggal: "2026-02-30" },
    };
    middleware(invalidRequest, response, () => {});
    assert.equal(response.statusCode, 400);
});

test("response 500 tidak membocorkan pesan internal", () => {
    const response = {
        statusCode: 200,
        status(code) { this.statusCode = code; return this; },
        json(body) { this.body = body; return this; },
    };
    error(response, "ER_BAD_FIELD_ERROR: kolom_rahasia", 500);
    assert.equal(response.statusCode, 500);
    assert.equal(response.body.message, "Terjadi kesalahan server");
});

test("validasi query laporan menolak periode terbalik dan terlalu panjang", () => {
    const middleware = validateQuery(laporanRekapQuerySchema);
    const response = {
        statusCode: 200,
        status(code) { this.statusCode = code; return this; },
        json(body) { this.body = body; return this; },
    };

    middleware({
        query: { tanggal_mulai: "2026-08-20", tanggal_selesai: "2026-08-01" },
    }, response, () => {});
    assert.equal(response.statusCode, 400);
    assert.match(response.body.message, /tidak boleh sebelum/);

    middleware({
        query: { tanggal_mulai: "2025-01-01", tanggal_selesai: "2026-08-01" },
    }, response, () => {});
    assert.equal(response.statusCode, 400);
    assert.match(response.body.message, /maksimal 366 hari/);
});

test("validasi query laporan menyimpan periode yang sudah dinormalisasi", () => {
    const middleware = validateQuery(laporanRekapQuerySchema);
    const req = {
        query: { tanggal_mulai: "2026-08-01", tanggal_selesai: "2026-08-27" },
    };
    const response = {
        status(code) { this.statusCode = code; return this; },
        json(body) { this.body = body; return this; },
    };
    let nextDipanggil = false;

    middleware(req, response, () => { nextDipanggil = true; });

    assert.equal(nextDipanggil, true);
    assert.deepEqual(req.validatedQuery, req.query);
});
