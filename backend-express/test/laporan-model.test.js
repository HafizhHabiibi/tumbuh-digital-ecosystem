import test from "node:test";
import assert from "node:assert/strict";
import { buatLaporanModel } from "../src/models/laporanModel.js";

const buatDatabasePalsu = (handler) => ({
    query: async (sql, params) => handler(sql, params),
});

test("query individual mengembalikan identitas, riwayat terbaru, dan rujukan", async () => {
    const panggilan = [];
    const database = buatDatabasePalsu((sql, params) => {
        panggilan.push({ sql, params });

        if (sql.includes("FROM anak a")) {
            return [[{
                id: "anak-1",
                orang_tua_id: "orang-tua-1",
                nama: "Rizki",
                nama_orang_tua: "Aminah",
            }]];
        }
        if (sql.includes("FROM pengukuran p") && sql.includes("JOIN kader")) {
            return [[
                { id: 2, tanggal_ukur: "2026-08-27" },
                { id: 1, tanggal_ukur: "2026-07-27" },
            ]];
        }
        if (sql.includes("FROM rujukan r")) {
            return [[{ id: 9, status: "diajukan" }]];
        }
        throw new Error("Query tidak dikenali");
    });

    const hasil = await buatLaporanModel(database).findDataIndividual("anak-1");

    assert.equal(hasil.anak.nama, "Rizki");
    assert.equal(hasil.pengukuran_terakhir.id, 2);
    assert.equal(hasil.riwayat_pengukuran.length, 2);
    assert.equal(hasil.rujukan[0].status, "diajukan");
    assert.equal(panggilan.length, 3);
    assert.deepEqual(panggilan.map(({ params }) => params), [
        ["anak-1"],
        ["anak-1"],
        ["anak-1"],
    ]);
});

test("query kepemilikan anak memeriksa anak dan user orang tua sekaligus", async () => {
    const panggilan = [];
    const database = buatDatabasePalsu((sql, params) => {
        panggilan.push({ sql, params });
        return [[{ ditemukan: 1 }]];
    });

    const hasil = await buatLaporanModel(database).isAnakMilikUserOrangTua(
        "anak-1",
        "user-orang-tua-1",
    );

    assert.equal(hasil, true);
    assert.match(panggilan[0].sql, /JOIN orang_tua/);
    assert.match(panggilan[0].sql, /a\.id = \? AND ot\.user_id = \?/);
    assert.deepEqual(panggilan[0].params, ["anak-1", "user-orang-tua-1"]);
});

test("query kepemilikan mengembalikan false ketika relasi tidak ditemukan", async () => {
    const database = buatDatabasePalsu(() => [[]]);
    const hasil = await buatLaporanModel(database).isAnakMilikUserOrangTua(
        "anak-lain",
        "user-orang-tua-1",
    );
    assert.equal(hasil, false);
});

test("query individual berhenti ketika anak tidak ditemukan", async () => {
    let jumlahQuery = 0;
    const database = buatDatabasePalsu(() => {
        jumlahQuery += 1;
        return [[]];
    });

    const hasil = await buatLaporanModel(database).findDataIndividual("tidak-ada");

    assert.equal(hasil, null);
    assert.equal(jumlahQuery, 1);
});

test("query rekap memakai pengukuran terakhir per anak dan periode terparameterisasi", async () => {
    const panggilan = [];
    const database = buatDatabasePalsu((sql, params) => {
        panggilan.push({ sql, params });

        if (sql.includes("WITH pengukuran_periode")) {
            return [[{ anak_id: "anak-1", id: 4 }]];
        }
        if (sql.includes("COUNT(DISTINCT p.anak_id)")) {
            return [[{ total_anak: "1", total_pengukuran: "3" }]];
        }
        if (sql.includes("SUM(CASE WHEN r.status")) {
            return [[{
                diajukan: "1",
                ditangani: "0",
                selesai: "2",
                total_aktif: "1",
            }]];
        }
        throw new Error("Query tidak dikenali");
    });

    const hasil = await buatLaporanModel(database).findDataRekap(
        "2026-08-01",
        "2026-08-31",
    );

    assert.match(panggilan[0].sql, /ROW_NUMBER\(\) OVER/);
    assert.match(panggilan[0].sql, /PARTITION BY p\.anak_id/);
    assert.equal(panggilan.every(({ sql }) => sql.includes("BETWEEN ? AND ?")), true);
    assert.deepEqual(
        panggilan.map(({ params }) => params),
        Array(3).fill(["2026-08-01", "2026-08-31"]),
    );
    assert.deepEqual(hasil.ringkasan, {
        total_anak: 1,
        total_pengukuran: 3,
        total_rujukan_aktif: 1,
    });
    assert.deepEqual(hasil.rekap_rujukan, {
        diajukan: 1,
        ditangani: 0,
        selesai: 2,
    });
    assert.equal(hasil.pengukuran_terakhir_per_anak.length, 1);
});

test("query rekap menormalkan hasil agregasi kosong menjadi nol", async () => {
    const database = buatDatabasePalsu((sql) => {
        if (sql.includes("WITH pengukuran_periode")) return [[]];
        return [[{}]];
    });

    const hasil = await buatLaporanModel(database).findDataRekap(
        "2026-08-01",
        "2026-08-31",
    );

    assert.deepEqual(hasil.ringkasan, {
        total_anak: 0,
        total_pengukuran: 0,
        total_rujukan_aktif: 0,
    });
    assert.deepEqual(hasil.rekap_rujukan, {
        diajukan: 0,
        ditangani: 0,
        selesai: 0,
    });
});
