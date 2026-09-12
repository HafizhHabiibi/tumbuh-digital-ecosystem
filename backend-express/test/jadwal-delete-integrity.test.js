import test from "node:test";
import assert from "node:assert/strict";

import {
    buatDeleteIfNoMeasurements,
    buatUpdateIfNoMeasurements,
} from "../src/models/jadwalModel.js";

const perubahanJadwal = {
    tanggal: "2026-09-10",
    waktu_mulai: "14:00",
    waktu_selesai: "16:00",
    lokasi: "Balai Desa",
    keterangan: null,
    reset_reminders: true,
};

test("jadwal tidak berubah jika tanggalnya sudah memiliki pengukuran", async () => {
    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            return [{ affectedRows: 0 }];
        },
    };

    const updated = await buatUpdateIfNoMeasurements(database)(
        16,
        perubahanJadwal,
    );

    assert.equal(updated, false);
    assert.equal(calls.length, 1);
    assert.match(calls[0].sql, /UPDATE jadwal_posyandu/i);
    assert.match(calls[0].sql, /NOT EXISTS/i);
    assert.match(
        calls[0].sql,
        /p\.tanggal_ukur = jadwal_posyandu\.tanggal/i,
    );
    assert.deepEqual(calls[0].params, [
        "2026-09-10",
        "14:00",
        "16:00",
        "Balai Desa",
        null,
        true,
        true,
        16,
    ]);
});

test("status reminder dipertahankan jika hanya keterangan jadwal berubah", async () => {
    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            return [{ affectedRows: 1 }];
        },
    };

    await buatUpdateIfNoMeasurements(database)(16, {
        ...perubahanJadwal,
        reset_reminders: false,
    });

    assert.match(calls[0].sql, /WHEN \? THEN NULL ELSE reminder_h1_sent_at/i);
    assert.match(calls[0].sql, /WHEN \? THEN NULL ELSE reminder_h_sent_at/i);
    assert.deepEqual(calls[0].params.slice(-3), [false, false, 16]);
});

test("jadwal berubah jika tanggalnya belum memiliki pengukuran", async () => {
    const database = {
        query: async () => [{ affectedRows: 1 }],
    };

    const updated = await buatUpdateIfNoMeasurements(database)(
        16,
        perubahanJadwal,
    );

    assert.equal(updated, true);
});

test("jadwal tidak terhapus jika tanggalnya sudah memiliki pengukuran", async () => {
    const calls = [];
    const database = {
        query: async (sql, params) => {
            calls.push({ sql, params });
            return [{ affectedRows: 0 }];
        },
    };

    const deleted = await buatDeleteIfNoMeasurements(database)(17);

    assert.equal(deleted, false);
    assert.equal(calls.length, 1);
    assert.match(calls[0].sql, /DELETE j\s+FROM jadwal_posyandu j/i);
    assert.match(calls[0].sql, /NOT EXISTS/i);
    assert.match(calls[0].sql, /p\.tanggal_ukur = j\.tanggal/i);
    assert.deepEqual(calls[0].params, [17]);
});

test("jadwal terhapus jika tanggalnya belum memiliki pengukuran", async () => {
    const database = {
        query: async () => [{ affectedRows: 1 }],
    };

    const deleted = await buatDeleteIfNoMeasurements(database)(18);

    assert.equal(deleted, true);
});
