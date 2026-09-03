import test from "node:test";
import assert from "node:assert/strict";

import { buatCreatePengukuran } from "../src/controllers/pengukuranController.js";
import { enrichPengukuranDenganPrioritas } from "../src/services/pengukuranService.js";

const createResponse = () => ({
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

test("create menghitung, menyimpan, dan merespons nilai kanonis yang sama dengan read", async () => {
    const anak = {
        id: "018f0000-0000-7000-8000-000000000001",
        orang_tua_id: "018f0000-0000-7000-8000-000000000002",
        nama: "Rizki",
        tanggal_lahir: "2024-08-26",
        jenis_kelamin: "L",
    };
    let saved = null;
    let notificationBody = null;
    const handler = buatCreatePengukuran({
        findAnakById: async () => anak,
        findDuplicate: async () => null,
        savePengukuran: async (data) => {
            saved = data;
            return 901;
        },
        sendNotification: async (_orangTuaId, _title, body) => {
            notificationBody = body;
        },
        processInsight: async () => {},
    });
    const req = {
        body: {
            anak_id: anak.id,
            tanggal_ukur: "2026-08-26",
            berat_badan: 10.123,
            tinggi_badan: 85.678,
            lingkar_kepala: 48.126,
            lingkar_lengan: 14.555,
        },
        kader: { id: "kader-1" },
    };
    const res = createResponse();

    await handler(req, res);

    assert.equal(res.statusCode, 201);
    assert.deepEqual({
        berat_badan: saved.berat_badan,
        tinggi_badan: saved.tinggi_badan,
        lingkar_kepala: saved.lingkar_kepala,
        lingkar_lengan: saved.lingkar_lengan,
    }, {
        berat_badan: 10.12,
        tinggi_badan: 85.68,
        lingkar_kepala: 48.13,
        lingkar_lengan: 14.56,
    });
    assert.deepEqual({
        berat_badan: res.body.data.berat_badan,
        tinggi_badan: res.body.data.tinggi_badan,
        lingkar_kepala: res.body.data.lingkar_kepala,
        lingkar_lengan: res.body.data.lingkar_lengan,
    }, {
        berat_badan: saved.berat_badan,
        tinggi_badan: saved.tinggi_badan,
        lingkar_kepala: saved.lingkar_kepala,
        lingkar_lengan: saved.lingkar_lengan,
    });

    const read = enrichPengukuranDenganPrioritas({
        ...saved,
        id: 901,
        berat_badan: saved.berat_badan.toFixed(2),
        tinggi_badan: saved.tinggi_badan.toFixed(2),
        lingkar_kepala: saved.lingkar_kepala.toFixed(2),
        lingkar_lengan: saved.lingkar_lengan.toFixed(2),
    }, anak);
    for (const key of [
        "berat_badan",
        "tinggi_badan",
        "lingkar_kepala",
        "lingkar_lengan",
        "usia_bulan",
        "usia_hari",
        "nilai_imt",
        "zscore_bbu",
        "zscore_tbu",
        "zscore_bbtb",
        "zscore_imtu",
        "status_bbu",
        "status_tbu",
        "status_bbtb",
        "status_imtu",
        "skor_saw",
        "kategori_prioritas",
        "prioritas_pemantauan",
    ]) {
        assert.deepEqual(read[key], res.body.data[key], key);
    }
    assert.match(notificationBody, /BB: 10\.12 kg, TB: 85\.68 cm/);
});

test("field lingkar kosong tetap null pada penyimpanan dan response", async () => {
    let saved = null;
    const handler = buatCreatePengukuran({
        findAnakById: async () => ({
            id: "anak-1",
            orang_tua_id: "orang-tua-1",
            nama: "Ayu",
            tanggal_lahir: "2024-08-26",
            jenis_kelamin: "P",
        }),
        findDuplicate: async () => null,
        savePengukuran: async (data) => {
            saved = data;
            return 902;
        },
        sendNotification: async () => {},
        processInsight: async () => {},
    });
    const res = createResponse();

    await handler({
        body: {
            anak_id: "anak-1",
            tanggal_ukur: "2026-08-26",
            berat_badan: 11,
            tinggi_badan: 85,
            lingkar_kepala: "",
        },
        kader: { id: "kader-1" },
    }, res);

    assert.equal(res.statusCode, 201);
    assert.equal(saved.lingkar_kepala, null);
    assert.equal(saved.lingkar_lengan, null);
    assert.equal(res.body.data.lingkar_kepala, null);
    assert.equal(res.body.data.lingkar_lengan, null);
});

test("create mengembalikan kode stabil ketika usia di luar referensi WHO", async () => {
    const handler = buatCreatePengukuran({
        findAnakById: async () => ({
            id: "anak-lama",
            orang_tua_id: "orang-tua-1",
            nama: "Ayu",
            tanggal_lahir: "2021-08-03",
            jenis_kelamin: "P",
        }),
        findDuplicate: async () => null,
        savePengukuran: async () => {
            throw new Error("tidak boleh menyimpan");
        },
        sendNotification: async () => {},
        processInsight: async () => {},
    });
    const res = createResponse();

    await handler({
        body: {
            anak_id: "anak-lama",
            tanggal_ukur: "2026-09-03",
            berat_badan: 18,
            tinggi_badan: 105,
        },
        kader: { id: "kader-1" },
    }, res);

    assert.equal(res.statusCode, 400);
    assert.deepEqual(res.body.data, {
        code: "PENGUKURAN_USIA_DI_LUAR_REFERENSI",
    });
});
