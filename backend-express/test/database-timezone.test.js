import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const connectionSource = fs.readFileSync(
    new URL("../src/database/connection.js", import.meta.url),
    "utf8",
);

test("koneksi MySQL membaca DATETIME sebagai waktu WIB", () => {
    assert.match(connectionSource, /timezone:\s*["']\+07:00["']/);

    const timestamp = new Date("2026-09-12T22:45:36+07:00");
    assert.equal(timestamp.toISOString(), "2026-09-12T15:45:36.000Z");
    assert.equal(
        timestamp.toLocaleDateString("id-ID", { timeZone: "Asia/Jakarta" }),
        "12/9/2026",
    );
});

test("koneksi MySQL mempertahankan DATE sebagai tanggal kalender", () => {
    assert.match(connectionSource, /dateStrings:\s*\[["']DATE["']\]/);
});
