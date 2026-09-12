import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {
    JADWAL_REMINDER_INTERVAL_MS,
    processScheduleReminders,
} from "../src/services/jadwalReminderService.js";

const schema = fs.readFileSync(
    new URL("../src/database/schema.sql", import.meta.url),
    "utf8",
);

const jadwal = (overrides = {}) => ({
    id: 7,
    tanggal: "2026-09-13",
    waktu_mulai: "08:00:00",
    waktu_selesai: "11:00:00",
    lokasi: "Balai Desa",
    reminder_h1_sent_at: null,
    reminder_h_sent_at: null,
    ...overrides,
});

test("schema menyimpan penanda reminder H-1 dan Hari-H", () => {
    assert.match(schema, /reminder_h1_sent_at DATETIME DEFAULT NULL/);
    assert.match(schema, /reminder_h_sent_at DATETIME DEFAULT NULL/);
});

test("worker reminder berjalan setiap 15 menit", () => {
    assert.equal(JADWAL_REMINDER_INTERVAL_MS, 15 * 60 * 1_000);
});

test("H-1 pukul 08.00 WIB mengirim reminder satu kali", async () => {
    const calls = [];
    const result = await processScheduleReminders({
        now: new Date("2026-09-12T01:00:00.000Z"),
        findPendingReminders: async (today, tomorrow) => {
            assert.equal(today, "2026-09-12");
            assert.equal(tomorrow, "2026-09-13");
            return [jadwal()];
        },
        findRecipients: async () => [{ id: "orang-tua-1" }],
        sendBulk: async (recipients, createPayload) => {
            calls.push({ recipients, payload: createPayload(recipients[0]) });
        },
        markSent: async (id, type) => calls.push({ id, type }),
    });

    assert.deepEqual(result, { processed: 1, recipients: 1 });
    assert.equal(calls[0].payload[0], "Pengingat Posyandu Besok");
    assert.match(calls[0].payload[1], /13 September 2026/);
    assert.deepEqual(calls[0].payload.slice(2), ["jadwal", 7]);
    assert.deepEqual(calls[1], { id: 7, type: "h1" });
});

test("Hari-H pukul 06.00 WIB mengirim reminder jadwal hari ini", async () => {
    const calls = [];
    const result = await processScheduleReminders({
        now: new Date("2026-09-12T23:00:00.000Z"),
        findPendingReminders: async () => [jadwal({
            reminder_h1_sent_at: "2026-09-12 08:00:00",
        })],
        findRecipients: async () => [{ id: "orang-tua-1" }],
        sendBulk: async (recipients, createPayload) => {
            calls.push(createPayload(recipients[0]));
        },
        markSent: async (id, type) => calls.push({ id, type }),
    });

    assert.deepEqual(result, { processed: 1, recipients: 1 });
    assert.equal(calls[0][0], "Posyandu Hari Ini");
    assert.deepEqual(calls[0].slice(2), ["jadwal", 7]);
    assert.deepEqual(calls[1], { id: 7, type: "h" });
});

test("reminder tidak dikirim sebelum jam yang ditentukan", async () => {
    let recipientsQueried = false;
    const result = await processScheduleReminders({
        now: new Date("2026-09-12T00:59:00.000Z"),
        findPendingReminders: async () => [jadwal()],
        findRecipients: async () => {
            recipientsQueried = true;
            return [];
        },
    });

    assert.deepEqual(result, { processed: 0, recipients: 0 });
    assert.equal(recipientsQueried, false);
});

test("penanda tidak diperbarui ketika pembuatan notifikasi gagal", async () => {
    let marked = false;
    await assert.rejects(
        processScheduleReminders({
            now: new Date("2026-09-12T01:00:00.000Z"),
            findPendingReminders: async () => [jadwal()],
            findRecipients: async () => [{ id: "orang-tua-1" }],
            sendBulk: async () => {
                throw new Error("database unavailable");
            },
            markSent: async () => {
                marked = true;
            },
        }),
        /database unavailable/,
    );
    assert.equal(marked, false);
});
