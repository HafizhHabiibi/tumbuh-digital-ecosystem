import test from "node:test";
import assert from "node:assert/strict";

import * as schemas from "../src/validation/schemas.js";
import { validateQuery } from "../src/middlewares/validate.js";

const runValidation = (schema, query) => {
    const req = { query };
    const res = {
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
    };
    let nextCalled = false;

    validateQuery(schema)(req, res, () => {
        nextCalled = true;
    });

    return { req, res, nextCalled };
};

test("schema query list menormalisasi search dan filter setiap endpoint", () => {
    const cases = [
        [
            schemas.orangTuaListQuerySchema,
            { search: "  SITI  ", page: "1", limit: "20" },
            { search: "SITI", page: 1, limit: 20 },
        ],
        [
            schemas.anakListQuerySchema,
            { search: "  Budi ", jenis_kelamin: "L", page: "2" },
            { search: "Budi", jenis_kelamin: "L", page: 2 },
        ],
        [
            schemas.rankingListQuerySchema,
            { search: " Ana ", prioritas: "tinggi" },
            { search: "Ana", prioritas: "tinggi" },
        ],
        [
            schemas.rujukanListQuerySchema,
            { search: " Dewi ", status: "ditangani" },
            { search: "Dewi", status: "ditangani" },
        ],
    ];

    for (const [schema, input, expected] of cases) {
        assert.ok(schema, "schema query list harus diekspor");
        const result = runValidation(schema, input);
        assert.equal(result.nextCalled, true);
        assert.deepEqual(result.req.validatedQuery, expected);
    }
});

test("search lebih dari 100 karakter dan enum invalid ditolak", () => {
    assert.ok(schemas.anakListQuerySchema, "schema query anak harus tersedia");

    const longSearch = runValidation(schemas.anakListQuerySchema, {
        search: "x".repeat(101),
    });
    const invalidGender = runValidation(schemas.anakListQuerySchema, {
        jenis_kelamin: "X",
    });

    assert.equal(longSearch.res.statusCode, 400);
    assert.equal(invalidGender.res.statusCode, 400);
});

test("model anak menerapkan search sebelum pagination dan count", async () => {
    const AnakModel = await import("../src/models/anakModel.js");
    assert.equal(typeof AnakModel.buatFindAll, "function");

    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            if (/COUNT\(/i.test(sql)) return [[{ total: 1 }]];
            return [[{ id: "anak-page-3", nama: "Target Halaman Tiga" }]];
        },
    };
    const findAll = AnakModel.buatFindAll(database);

    const result = await findAll({
        page: 1,
        limit: 20,
        search: "Target Halaman Tiga",
    });

    assert.deepEqual(result.items.map(({ id }) => id), ["anak-page-3"]);
    assert.equal(result.total, 1);
    assert.equal(calls.length, 2);
    for (const call of calls) {
        assert.match(call.sql, /LIKE/i);
        assert.match(call.sql, /a\.nik LIKE/i);
        assert.ok(call.params.some((value) =>
            String(value).includes("Target Halaman Tiga")
        ));
    }
});

test("model anak mencari NIK dan dapat menggabungkan filter jenis kelamin", async () => {
    const AnakModel = await import("../src/models/anakModel.js");
    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            if (/COUNT\(/i.test(sql)) return [[{ total: 1 }]];
            return [[{ id: "anak-nik", nik: "3273010101010001" }]];
        },
    };

    const result = await AnakModel.buatFindAll(database)({
        search: "3273%_!",
        jenis_kelamin: "P",
    });

    assert.equal(result.total, 1);
    assert.equal(calls.length, 2);
    for (const call of calls) {
        assert.match(call.sql, /a\.nama LIKE/i);
        assert.match(call.sql, /a\.nik LIKE/i);
        assert.match(call.sql, /ot\.nama_lengkap LIKE/i);
        assert.match(call.sql, /a\.jenis_kelamin = \?/i);
        assert.deepEqual(call.params.slice(0, 4), [
            "%3273!%!_!!%",
            "%3273!%!_!!%",
            "%3273!%!_!!%",
            "P",
        ]);
    }
});

test("model orang tua mencari nomor telepon pada list dan count", async () => {
    const OrangTuaModel = await import("../src/models/orangTuaModel.js");
    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            if (/COUNT\(/i.test(sql)) return [[{ total: 1 }]];
            return [[{ id: "orang-tua-hp", no_hp: "+628123456789" }]];
        },
    };

    const result = await OrangTuaModel.buatFindAll(database)({
        search: "+62812",
    });

    assert.equal(result.total, 1);
    assert.equal(calls.length, 2);
    for (const call of calls) {
        assert.match(call.sql, /ot\.no_hp LIKE/i);
        assert.deepEqual(call.params.slice(0, 5), Array(5).fill("%+62812%"));
    }
});

test("karakter wildcard search di-escape dan tetap dikirim sebagai parameter", async () => {
    const { toLikePattern } = await import("../src/utils/sqlFilter.js");

    assert.equal(
        toLikePattern("100%_O'Brien!"),
        "%100!%!_O'Brien!!%",
    );
});

test("model rujukan memfilter list dan count, tetapi summary tetap global", async () => {
    const RujukanModel = await import("../src/models/rujukanModel.js");
    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            if (/COUNT\(\*\) AS total/i.test(sql)) return [[{ total: 1 }]];
            if (/SUM\(r\.status/i.test(sql)) {
                return [[{ diajukan: 2, ditangani: 1, selesai: 4 }]];
            }
            return [[{ id: 7, nama_anak: "Dewi" }]];
        },
    };
    const findAll = RujukanModel.buatFindAll(database);

    const result = await findAll({
        page: 1,
        limit: 20,
        search: "Dewi",
        status: "ditangani",
    });

    assert.equal(result.total, 1);
    assert.deepEqual(result.summary, {
        diajukan: 2,
        ditangani: 1,
        selesai: 4,
    });
    assert.equal(calls.length, 3);
    assert.match(calls[0].sql, /r\.status = \?/);
    assert.match(calls[0].sql, /WHEN 'diajukan' THEN 0/);
    assert.match(calls[0].sql, /r\.created_at END ASC/);
    assert.match(calls[1].sql, /r\.status = \?/);
    assert.doesNotMatch(calls[2].sql, /WHERE[\s\S]*r\.status = \?/);
    assert.ok(calls[2].params.includes("%Dewi%"));
});

test("ranking mencari seluruh data sebelum pagination", async () => {
    const { buatGetRankingAllAnak } = await import(
        "../src/services/pengukuranService.js"
    );
    const rows = Array.from({ length: 21 }, (_, index) => ({
        anak_id: `anak-${index + 1}`,
        nama_anak: index === 20 ? "Target Halaman Berikutnya" : `Anak ${index + 1}`,
        nama_orang_tua: `Orang Tua ${index + 1}`,
        tanggal_lahir: "2024-08-26",
        jenis_kelamin: "L",
        tanggal_ukur: "2026-08-26",
        berat_badan: "11.00",
        tinggi_badan: "85.00",
        created_at: "2026-08-26T00:00:00.000Z",
    }));
    const getRanking = buatGetRankingAllAnak({
        findLatestPerAnak: async () => rows,
    });

    const result = await getRanking({
        page: 1,
        limit: 20,
        search: "target halaman berikutnya",
    });

    assert.equal(result.total, 1);
    assert.deepEqual(
        result.items.map(({ anak_id }) => anak_id),
        ["anak-21"],
    );
});
