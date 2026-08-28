import test from "node:test";
import assert from "node:assert/strict";
import { buatDeleteIfEmpty } from "../src/models/anakModel.js";
import { buatDeleteIfNoChildren } from "../src/models/orangTuaModel.js";
import { buatDeleteDataMasterHandlers } from "../src/controllers/kaderController.js";

const buatPool = (responses) => {
    const calls = [];
    const conn = {
        beginTransaction: async () => calls.push(["begin"]),
        commit: async () => calls.push(["commit"]),
        rollback: async () => calls.push(["rollback"]),
        release: () => calls.push(["release"]),
        query: async (sql, params) => {
            calls.push([sql, params]);
            return responses.shift();
        },
    };
    return {
        calls,
        pool: { getConnection: async () => conn },
    };
};

const buatResponse = () => ({
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
});

test("anak hanya dihapus ketika belum memiliki data klinis", async () => {
    const { pool, calls } = buatPool([
        [[{ id: "anak-1" }]],
        [[{ pengukuran: 0, pemberian: 0 }]],
        [{ affectedRows: 1 }],
    ]);
    const result = await buatDeleteIfEmpty(pool)("anak-1");

    assert.deepEqual(result, { status: "deleted" });
    assert.ok(calls.some(([sql]) => String(sql).startsWith("DELETE FROM anak")));
    assert.ok(calls.some(([name]) => name === "commit"));
});

test("anak dengan riwayat ditolak tanpa menjalankan DELETE", async () => {
    const { pool, calls } = buatPool([
        [[{ id: "anak-1" }]],
        [[{ pengukuran: 2, pemberian: 1 }]],
    ]);
    const result = await buatDeleteIfEmpty(pool)("anak-1");

    assert.equal(result.status, "conflict");
    assert.equal(result.relations.pengukuran, 2);
    assert.equal(calls.some(([sql]) => String(sql).startsWith("DELETE")), false);
    assert.ok(calls.some(([name]) => name === "rollback"));
});

test("orang tua tanpa anak dihapus melalui akun user secara atomik", async () => {
    const { pool, calls } = buatPool([
        [[{ user_id: "user-1" }]],
        [[{ total: 0 }]],
        [{ affectedRows: 1 }],
    ]);
    const result = await buatDeleteIfNoChildren(pool)("ortu-1");

    assert.deepEqual(result, { status: "deleted" });
    assert.ok(calls.some(([sql, params]) =>
        String(sql).startsWith("DELETE FROM users") && params[0] === "user-1",
    ));
});

test("controller memetakan konflik delete menjadi HTTP 409", async () => {
    const handlers = buatDeleteDataMasterHandlers({
        deleteOrangTuaModel: async () => ({ status: "conflict", total_anak: 2 }),
        deleteAnakModel: async () => ({
            status: "conflict",
            relations: { pengukuran: 1, pemberian: 0 },
        }),
    });

    const orangTuaRes = buatResponse();
    await handlers.deleteOrangTua({ params: { id: "ortu-1" } }, orangTuaRes);
    assert.equal(orangTuaRes.statusCode, 409);
    assert.match(orangTuaRes.body.message, /2 anak/);

    const anakRes = buatResponse();
    await handlers.deleteAnak({ params: { id: "anak-1" } }, anakRes);
    assert.equal(anakRes.statusCode, 409);
    assert.match(anakRes.body.message, /riwayat/);
});
