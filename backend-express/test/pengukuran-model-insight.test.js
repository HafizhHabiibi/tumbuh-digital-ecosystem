import test from "node:test";
import assert from "node:assert/strict";

import { buatCreatePengukuran } from "../src/models/pengukuranModel.js";

const measurement = {
    anak_id: "anak-1",
    kader_id: "kader-1",
    tanggal_ukur: "2026-09-03",
    berat_badan: 11,
    tinggi_badan: 85,
    lingkar_kepala: null,
    lingkar_lengan: null,
};

test("pengukuran baru menandai insight lama yang belum selesai secara atomik", async () => {
    const calls = [];
    const transaction = {
        beginTransaction: async () => calls.push("begin"),
        query: async (sql, params) => {
            calls.push({ sql, params });
            return sql.includes("INSERT INTO")
                ? [{ insertId: 91 }]
                : [{ affectedRows: 1 }];
        },
        commit: async () => calls.push("commit"),
        rollback: async () => calls.push("rollback"),
        release: () => calls.push("release"),
    };
    const create = buatCreatePengukuran({
        getConnection: async () => transaction,
    });

    assert.equal(await create(measurement), 91);

    const update = calls.find(
        (call) => typeof call === "object" && call.sql.includes("UPDATE pengukuran"),
    );
    assert.match(update.sql, /insight_status = 'superseded'/);
    assert.match(update.sql, /insight_teks IS NULL/);
    assert.match(update.sql, /insight_status IN \('pending', 'processing'\)/);
    assert.deepEqual(update.params, ["anak-1", 91, "2026-09-03", "2026-09-03", 91]);
    assert.deepEqual(calls.filter((call) => typeof call === "string"), [
        "begin",
        "commit",
        "release",
    ]);
});

test("kegagalan insert atau supersede me-rollback transaksi", async () => {
    const calls = [];
    const expected = new Error("database gagal");
    const create = buatCreatePengukuran({
        getConnection: async () => ({
            beginTransaction: async () => calls.push("begin"),
            query: async () => {
                throw expected;
            },
            commit: async () => calls.push("commit"),
            rollback: async () => calls.push("rollback"),
            release: () => calls.push("release"),
        }),
    });

    await assert.rejects(create(measurement), expected);
    assert.deepEqual(calls, ["begin", "rollback", "release"]);
});
