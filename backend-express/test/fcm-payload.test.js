import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

import {
    buildNotificationData,
    normalizeNotificationData,
} from "../src/services/fcmService.js";

test("payload FCM membawa tipe, referensi, dan anak sebagai string", () => {
    assert.deepEqual(
        buildNotificationData("pengukuran", 12, { anak_id: "anak-1" }),
        {
            tipe: "pengukuran",
            pengukuran_id: "12",
            anak_id: "anak-1",
        },
    );
    assert.deepEqual(
        buildNotificationData("rujukan", 8, { anak_id: "anak-1" }),
        {
            tipe: "rujukan",
            rujukan_id: "8",
            anak_id: "anak-1",
        },
    );
    assert.deepEqual(buildNotificationData("jadwal", 4), {
        tipe: "jadwal",
        jadwal_id: "4",
    });
});

test("payload outbox dinormalisasi menjadi data Firebase string", () => {
    assert.deepEqual(
        normalizeNotificationData(JSON.stringify({
            tipe: "jadwal",
            jadwal_id: 4,
        })),
        { tipe: "jadwal", jadwal_id: "4" },
    );
    assert.deepEqual(normalizeNotificationData(null), {});
    assert.deepEqual(normalizeNotificationData("bukan-json"), {});
});

test("schema menyimpan data_payload pada notification_outbox", () => {
    const schema = fs.readFileSync(
        new URL("../src/database/schema.sql", import.meta.url),
        "utf8",
    );
    const outbox = schema.slice(schema.indexOf("CREATE TABLE IF NOT EXISTS notification_outbox"));

    assert.match(outbox, /data_payload JSON DEFAULT NULL/);
    assert.doesNotMatch(outbox, /ALTER TABLE notification_outbox/);
});
