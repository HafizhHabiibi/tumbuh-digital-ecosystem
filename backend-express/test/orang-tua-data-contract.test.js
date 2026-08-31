import test from "node:test";
import assert from "node:assert/strict";
import express from "express";
import { toOrangTuaPengukuran } from "../src/serializers/orangTuaPengukuranSerializer.js";
import { toOrangTuaRujukan } from "../src/serializers/orangTuaRujukanSerializer.js";
import { buatOrangTuaDataController } from "../src/controllers/orangTuaController.js";
import {
    buatGetDetailPengukuran,
    buatGetDetailSAW,
} from "../src/controllers/pengukuranController.js";
import { authorizeRole } from "../src/middlewares/role.js";

const ANAK_ID = "018f0000-0000-7000-8000-000000000001";
const ORANG_TUA_ID = "018f0000-0000-7000-8000-000000000002";
const PENGUKURAN_ID = "501";

const anak = {
    id: ANAK_ID,
    orang_tua_id: ORANG_TUA_ID,
    nama: "Rizki",
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-26",
};

const pengukuranTeknis = {
    id: 501,
    anak_id: ANAK_ID,
    kader_id: 21,
    tanggal_ukur: "2026-08-26",
    berat_badan: 11,
    tinggi_badan: 85,
    lingkar_kepala: 48,
    lingkar_lengan: 15,
    usia_bulan: 24,
    usia_hari: 730,
    nilai_imt: 15.22,
    zscore_bbu: -0.73,
    zscore_tbu: -0.64,
    zscore_bbtb: -0.28,
    zscore_imtu: -0.34,
    status_bbu: "berat_badan_normal",
    status_tbu: "normal",
    status_bbtb: "gizi_baik",
    status_imtu: "gizi_baik",
    skor_saw: 0.0825,
    kategori_prioritas: "rendah",
    detail: [{ nama_kriteria: "zscore_bbu", bobot: 0.25 }],
    detail_saw: [{ nama_kriteria: "zscore_bbu", bobot: 0.25 }],
    bobot_saw: { bbu: 0.25, tbu: 0.30, bbtb: 0.25, imtu: 0.20 },
    created_at: "2026-08-26T03:00:00.000Z",
};

const rujukanTeknis = {
    id: 81,
    status: "ditangani",
    catatan_kader: "Perlu pemantauan lanjutan",
    catatan_puskesmas: "Jadwalkan pemeriksaan ulang",
    created_at: "2026-08-26T04:00:00.000Z",
    validated_at: "2026-08-27T02:00:00.000Z",
    tanggal_ukur: "2026-08-26",
    berat_badan: 11,
    tinggi_badan: 85,
    ditangani_oleh: "dr. Sari",
    skor_saw: 0.0825,
    kategori_prioritas: "rendah",
    detail_saw: [{ nama_kriteria: "zscore_bbu", bobot: 0.25 }],
};

const PENGUKURAN_ORANG_TUA_KEYS = [
    "id",
    "tanggal_ukur",
    "berat_badan",
    "tinggi_badan",
    "lingkar_kepala",
    "lingkar_lengan",
    "usia_bulan",
    "status_bbu",
    "status_tbu",
    "status_bbtb",
    "status_imtu",
    "status_pemantauan",
    "created_at",
];

const RUJUKAN_ORANG_TUA_KEYS = [
    "id",
    "status",
    "catatan_kader",
    "catatan_puskesmas",
    "created_at",
    "validated_at",
    "tanggal_ukur",
    "berat_badan",
    "tinggi_badan",
    "ditangani_oleh",
];

const assertTidakAdaDataTeknis = (value) => {
    const serialized = JSON.stringify(value);
    assert.doesNotMatch(serialized, /"zscore_[^"]*"\s*:/);
    assert.doesNotMatch(serialized, /"skor_saw"\s*:/);
    assert.doesNotMatch(
        serialized,
        /"(?:detail|bobot|detail_saw|bobot_saw)"\s*:/,
    );
    assert.doesNotMatch(serialized, /"kategori_prioritas"\s*:/);
};

const bukaServer = async (configure) => {
    const app = express();
    configure(app);
    const server = await new Promise((resolve) => {
        const instance = app.listen(0, "127.0.0.1", () => resolve(instance));
    });
    const alamat = server.address();
    return {
        baseUrl: `http://127.0.0.1:${alamat.port}`,
        tutup: () => new Promise((resolve, reject) => {
            server.close((err) => err ? reject(err) : resolve());
            server.closeAllConnections?.();
        }),
    };
};

test("serializer pengukuran orang tua mengekspos seluruh field yang diizinkan", () => {
    const result = toOrangTuaPengukuran(pengukuranTeknis);

    assert.deepEqual(Object.keys(result), PENGUKURAN_ORANG_TUA_KEYS);
    assert.equal(result.status_pemantauan, "rutin");
    assert.equal(result.tanggal_ukur, "2026-08-26");
    assert.equal(result.created_at, "2026-08-26T03:00:00.000Z");
    assertTidakAdaDataTeknis(result);
});

test("serializer memetakan seluruh kategori internal ke status pemantauan", () => {
    assert.deepEqual(
        ["rendah", "sedang", "tinggi"].map((kategori_prioritas) =>
            toOrangTuaPengukuran({
                ...pengukuranTeknis,
                kategori_prioritas,
            }).status_pemantauan
        ),
        ["rutin", "perlu_perhatian", "konsultasi"],
    );
});

test("serializer rujukan orang tua membatasi kontrak pada informasi tindak lanjut", () => {
    const result = toOrangTuaRujukan(rujukanTeknis);

    assert.deepEqual(Object.keys(result), RUJUKAN_ORANG_TUA_KEYS);
    assertTidakAdaDataTeknis(result);
});

test("integrasi endpoint orang tua menyaring data teknis pengukuran dan rujukan", async () => {
    const controller = buatOrangTuaDataController({
        findAnakById: async () => anak,
        findPengukuranByAnak: async () => [{ id: 501 }],
        enrichPengukuranList: () => [pengukuranTeknis],
        findRujukanByAnak: async () => [rujukanTeknis],
    });
    const server = await bukaServer((app) => {
        app.use((req, res, next) => {
            req.orangTua = { id: ORANG_TUA_ID };
            next();
        });
        app.get(
            "/api/orang-tua/anak/:id/pengukuran",
            controller.getPengukuranAnak,
        );
        app.get(
            "/api/orang-tua/anak/:id/rujukan",
            controller.getRujukanAnak,
        );
    });

    try {
        const pengukuranResponse = await fetch(
            `${server.baseUrl}/api/orang-tua/anak/${ANAK_ID}/pengukuran`,
        );
        const pengukuranBody = await pengukuranResponse.json();
        const item = pengukuranBody.data.riwayat[0];

        assert.equal(pengukuranResponse.status, 200);
        assert.deepEqual(Object.keys(item), PENGUKURAN_ORANG_TUA_KEYS);
        assert.equal("zscore_bbu" in item, false);
        assert.equal("skor_saw" in item, false);
        assert.equal("status_pemantauan" in item, true);
        assertTidakAdaDataTeknis(pengukuranBody.data);

        const rujukanResponse = await fetch(
            `${server.baseUrl}/api/orang-tua/anak/${ANAK_ID}/rujukan`,
        );
        const rujukanBody = await rujukanResponse.json();

        assert.equal(rujukanResponse.status, 200);
        assert.deepEqual(
            Object.keys(rujukanBody.data.rujukan[0]),
            RUJUKAN_ORANG_TUA_KEYS,
        );
        assertTidakAdaDataTeknis(rujukanBody.data);
    } finally {
        await server.tutup();
    }
});

test("regresi endpoint teknis tetap menyediakan Z-score dan hasil SAW", async () => {
    const rawPengukuran = {
        id: 501,
        anak_id: ANAK_ID,
        kader_id: 21,
        tanggal_ukur: "2026-08-26",
        berat_badan: "11",
        tinggi_badan: "85",
        lingkar_kepala: "48",
        lingkar_lengan: "15",
        tanggal_lahir: "2024-08-26",
        jenis_kelamin: "L",
        created_at: "2026-08-26T03:00:00.000Z",
    };
    const detailSAW = {
        pengukuran_id: 501,
        anak_id: ANAK_ID,
        skor_saw: 0.0825,
        kategori_prioritas: "rendah",
        detail: [
            { nama_kriteria: "zscore_bbu", bobot: 0.25, nilai: 0.24, skor: 0.06 },
        ],
    };
    const detailController = buatGetDetailPengukuran({
        findPengukuranById: async () => rawPengukuran,
    });
    const sawController = buatGetDetailSAW({
        getDetailSAW: async () => detailSAW,
    });
    const server = await bukaServer((app) => {
        app.use((req, res, next) => {
            req.user = { role: req.headers["x-test-role"] };
            next();
        });
        app.get(
            "/api/pengukuran/:id/saw",
            authorizeRole("kader", "puskesmas"),
            sawController,
        );
        app.get(
            "/api/pengukuran/:id",
            authorizeRole("kader", "puskesmas"),
            detailController,
        );
    });

    try {
        const detailResponse = await fetch(
            `${server.baseUrl}/api/pengukuran/${PENGUKURAN_ID}`,
            { headers: { "x-test-role": "kader" } },
        );
        const detail = (await detailResponse.json()).data;

        assert.equal(detailResponse.status, 200);
        for (const key of [
            "zscore_bbu",
            "zscore_tbu",
            "zscore_bbtb",
            "zscore_imtu",
        ]) {
            assert.equal(Number.isFinite(detail[key]), true);
        }
        assert.equal(Number.isFinite(detail.skor_saw), true);
        assert.equal(typeof detail.kategori_prioritas, "string");

        const sawResponse = await fetch(
            `${server.baseUrl}/api/pengukuran/${PENGUKURAN_ID}/saw`,
            { headers: { "x-test-role": "puskesmas" } },
        );
        const saw = (await sawResponse.json()).data;

        assert.equal(sawResponse.status, 200);
        assert.equal(saw.skor_saw, detailSAW.skor_saw);
        assert.equal(saw.detail[0].bobot, 0.25);
        assert.equal(saw.detail[0].nama_kriteria, "zscore_bbu");
    } finally {
        await server.tutup();
    }
});
