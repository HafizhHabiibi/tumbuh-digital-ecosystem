import test from "node:test";
import assert from "node:assert/strict";

import { buatChatModel } from "../src/models/chatModel.js";

const fakeDatabase = (handler) => ({
    query: async (sql, params) => handler(sql, params),
});

test("context chat hanya menerima pengukuran terbaru milik orang tua", async () => {
    let captured;
    const model = buatChatModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [[{ id: 12, insight_status: "completed" }]];
    }));

    const result = await model.findLatestMeasurementForOrangTua(
        12,
        "orang-tua-1",
    );

    assert.equal(result.id, 12);
    assert.match(captured.sql, /JOIN anak/);
    assert.match(captured.sql, /a\.orang_tua_id = \?/);
    assert.match(captured.sql, /NOT EXISTS/);
    assert.match(captured.sql, /terbaru\.anak_id = p\.anak_id/);
    assert.deepEqual(captured.params, [12, "orang-tua-1"]);
});

test("riwayat chat dapat membaca pengukuran lama selama masih milik orang tua", async () => {
    let captured;
    const model = buatChatModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [[{
            id: 11,
            insight_teks: "Insight lama",
            insight_status: "completed",
            is_latest: 0,
        }]];
    }));

    const result = await model.findMeasurementForOrangTua(
        11,
        "orang-tua-1",
    );

    assert.equal(result.is_latest, 0);
    assert.match(captured.sql, /a\.orang_tua_id = \?/);
    assert.match(captured.sql, /AS is_latest/);
    assert.deepEqual(captured.params, [11, "orang-tua-1"]);
});

test("context chat tidak ditemukan untuk pengukuran lama atau bukan miliknya", async () => {
    const model = buatChatModel(fakeDatabase(() => [[]]));
    assert.equal(
        await model.findLatestMeasurementForOrangTua(4, "orang-tua-lain"),
        null,
    );
});

test("history mengambil maksimal 20 pesan terakhir lalu mengurutkan kronologis", async () => {
    let captured;
    const rows = [
        { id: 8, role: "orang_tua", content: "Pertanyaan" },
        { id: 9, role: "assistant", content: "Jawaban" },
    ];
    const model = buatChatModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [rows];
    }));

    assert.deepEqual(await model.findRecentMessages(12, 999), rows);
    assert.match(captured.sql, /ORDER BY created_at DESC, id DESC/);
    assert.match(captured.sql, /ORDER BY created_at ASC, id ASC/);
    assert.deepEqual(captured.params, [12, 20]);
});

test("halaman history memakai cursor id dan dikembalikan kronologis", async () => {
    let captured;
    const rows = [
        { id: 9, content: "Pesan 9" },
        { id: 8, content: "Pesan 8" },
        { id: 7, content: "Pesan 7" },
    ];
    const model = buatChatModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [rows];
    }));

    const result = await model.findMessagesPage(12, {
        limit: 2,
        beforeId: 10,
    });

    assert.deepEqual(result.items.map((item) => item.id), [8, 9]);
    assert.equal(result.hasMore, true);
    assert.equal(result.nextBeforeId, 8);
    assert.match(captured.sql, /id < \?/);
    assert.deepEqual(captured.params, [12, 10, 10, 3]);
});

test("exchange ditemukan berdasarkan pengukuran dan idempotency key", async () => {
    let captured;
    const model = buatChatModel(fakeDatabase((sql, params) => {
        captured = { sql, params };
        return [[{
            user_message_id: 20,
            client_message_id: "018f0000-0000-7000-8000-000000000001",
            user_content: "Bagaimana pola makannya?",
            assistant_message_id: 21,
            assistant_content: "Variasikan sumber protein.",
            response_type: "answered",
        }]];
    }));

    const result = await model.findExchangeByClientMessageId(
        12,
        "018f0000-0000-7000-8000-000000000001",
    );

    assert.equal(result.user_message.id, 20);
    assert.equal(result.assistant_message.id, 21);
    assert.match(captured.sql, /assistant\.reply_to_message_id = pengguna\.id/);
    assert.deepEqual(captured.params, [
        12,
        "018f0000-0000-7000-8000-000000000001",
    ]);
});

test("penyimpanan exchange dilakukan atomik dalam satu transaksi", async () => {
    const calls = [];
    let insertNumber = 0;
    const connection = {
        beginTransaction: async () => calls.push("begin"),
        query: async (sql, params) => {
            calls.push({ sql, params });
            insertNumber += 1;
            return [{ insertId: insertNumber === 1 ? 30 : 31 }];
        },
        commit: async () => calls.push("commit"),
        rollback: async () => calls.push("rollback"),
        release: () => calls.push("release"),
    };
    const model = buatChatModel({ getConnection: async () => connection });

    const result = await model.saveExchange({
        pengukuranId: 12,
        clientMessageId: "018f0000-0000-7000-8000-000000000001",
        userContent: "Apa variasi makanannya?",
        assistantContent: "Coba variasikan lauk setiap hari.",
        responseType: "answered",
    });

    assert.equal(result.user_message.id, 30);
    assert.equal(result.assistant_message.id, 31);
    assert.equal(result.reused, false);
    assert.equal(calls[0], "begin");
    assert.match(calls[1].sql, /INSERT INTO chat_messages/);
    assert.match(calls[2].sql, /reply_to_message_id/);
    assert.equal(calls[3], "commit");
    assert.equal(calls[4], "release");
    assert.equal(calls.includes("rollback"), false);
});
