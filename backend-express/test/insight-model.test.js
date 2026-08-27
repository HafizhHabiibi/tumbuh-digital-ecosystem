import test from "node:test";
import assert from "node:assert/strict";

import { buatInsightModel } from "../src/models/insightModel.js";

const fakeDatabase = (handler) => ({
    query: async (sql, params) => handler(sql, params),
});

test("claim insight dilakukan atomik dan mengembalikan sumber pengukuran", async () => {
    const calls = [];
    const source = {
        id: 7,
        anak_id: "anak-1",
        insight_attempts: 1,
        berat_badan: "10.50",
        tinggi_badan: "82.30",
    };
    const model = buatInsightModel(fakeDatabase((sql, params) => {
        calls.push({ sql, params });
        if (sql.includes("UPDATE pengukuran")) {
            return [{ affectedRows: 1 }];
        }
        return [[source]];
    }));

    const result = await model.claim(7, 3, 300);

    assert.deepEqual(result, source);
    assert.match(calls[0].sql, /insight_status = 'processing'/);
    assert.match(calls[0].sql, /insight_attempts = insight_attempts \+ 1/);
    assert.match(calls[0].sql, /insight_status IN \('pending', 'processing'\)/);
    assert.deepEqual(calls[0].params, [300, 7, 3]);
    assert.deepEqual(calls[1].params, [7]);
});

test("claim yang sudah diambil worker lain berhenti tanpa SELECT lanjutan", async () => {
    let calls = 0;
    const model = buatInsightModel(fakeDatabase(() => {
        calls++;
        return [{ affectedRows: 0 }];
    }));

    assert.equal(await model.claim(9, 3, 300), null);
    assert.equal(calls, 1);
});

test("complete hanya menerima worker dengan nomor attempt yang sama", async () => {
    let captured;
    const model = buatInsightModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [{ affectedRows: 1 }];
    }));

    assert.equal(
        await model.complete(4, 2, "Insight aman", "gemini-3.6-flash"),
        true,
    );
    assert.match(captured.sql, /insight_status = 'completed'/);
    assert.match(captured.sql, /insight_attempts = \?/);
    assert.deepEqual(captured.params, [
        "Insight aman",
        "gemini-3.6-flash",
        4,
        2,
    ]);
});

test("kegagalan retryable dijadwalkan kembali tanpa menghapus jumlah attempt", async () => {
    let captured;
    const model = buatInsightModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [{ affectedRows: 1 }];
    }));

    await model.recordFailure({
        pengukuranId: 4,
        attempt: 1,
        willRetry: true,
        retryDelaySeconds: 120,
        errorMessage: "GEMINI_KEYS_EXHAUSTED",
    });

    assert.match(captured.sql, /DATE_ADD\(NOW\(\), INTERVAL \? SECOND\)/);
    assert.deepEqual(captured.params, [
        "pending",
        1,
        120,
        "GEMINI_KEYS_EXHAUSTED",
        4,
        1,
    ]);
});

test("antrean recovery hanya mengambil pengukuran terbaru setiap anak", async () => {
    let captured;
    const model = buatInsightModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [[{ id: 8 }, { id: 10 }]];
    }));

    assert.deepEqual(await model.findDueIds(10, 3), [8, 10]);
    assert.match(captured.sql, /NOT EXISTS/);
    assert.match(captured.sql, /terbaru\.anak_id = p\.anak_id/);
    assert.match(captured.sql, /p\.insight_status IN \('pending', 'processing'\)/);
    assert.deepEqual(captured.params, [3, 10]);
});

test("query insight orang tua memverifikasi kepemilikan melalui anak", async () => {
    let captured;
    const model = buatInsightModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [[{ insight_status: "completed" }]];
    }));

    await model.findForOrangTua(5, "orang-tua-1");
    assert.match(captured.sql, /JOIN anak/);
    assert.match(captured.sql, /a\.orang_tua_id = \?/);
    assert.deepEqual(captured.params, [5, "orang-tua-1"]);
});
