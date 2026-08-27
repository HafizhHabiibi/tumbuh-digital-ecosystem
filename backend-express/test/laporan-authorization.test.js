import test from "node:test";
import assert from "node:assert/strict";
import {
    buatOtorisasiLaporan,
} from "../src/middlewares/laporanAuthorization.js";

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

const jalankan = async (middleware, req) => {
    const res = buatResponse();
    let nextDipanggil = false;
    await middleware(req, res, () => {
        nextDipanggil = true;
    });
    return { res, nextDipanggil };
};

test("kader dan Puskesmas boleh mengakses laporan individual", async () => {
    let jumlahCekKepemilikan = 0;
    const otorisasi = buatOtorisasiLaporan({
        cekKepemilikan: async () => {
            jumlahCekKepemilikan++;
            return false;
        },
    });

    for (const role of ["kader", "puskesmas"]) {
        const hasil = await jalankan(otorisasi.individual, {
            user: { id: `user-${role}`, role },
            params: { anak_id: "anak-1" },
        });
        assert.equal(hasil.nextDipanggil, true);
    }
    assert.equal(jumlahCekKepemilikan, 0);
});

test("orang tua hanya boleh mengakses laporan anak miliknya", async () => {
    const permintaan = [];
    const otorisasi = buatOtorisasiLaporan({
        cekKepemilikan: async (anakId, userId) => {
            permintaan.push({ anakId, userId });
            return anakId === "anak-sendiri";
        },
    });

    const milikSendiri = await jalankan(otorisasi.individual, {
        user: { id: "user-orang-tua", role: "orang_tua" },
        params: { anak_id: "anak-sendiri" },
    });
    const milikOrangLain = await jalankan(otorisasi.individual, {
        user: { id: "user-orang-tua", role: "orang_tua" },
        params: { anak_id: "anak-lain" },
    });

    assert.equal(milikSendiri.nextDipanggil, true);
    assert.equal(milikOrangLain.nextDipanggil, false);
    assert.equal(milikOrangLain.res.statusCode, 404);
    assert.equal(milikOrangLain.res.body.message, "Laporan anak tidak ditemukan");
    assert.deepEqual(permintaan, [
        { anakId: "anak-sendiri", userId: "user-orang-tua" },
        { anakId: "anak-lain", userId: "user-orang-tua" },
    ]);
});

test("laporan rekap hanya dapat diakses kader dan Puskesmas", async () => {
    const otorisasi = buatOtorisasiLaporan();

    for (const role of ["kader", "puskesmas"]) {
        const hasil = await jalankan(otorisasi.rekap, {
            user: { id: `user-${role}`, role },
        });
        assert.equal(hasil.nextDipanggil, true);
    }

    const orangTua = await jalankan(otorisasi.rekap, {
        user: { id: "user-orang-tua", role: "orang_tua" },
    });
    assert.equal(orangTua.nextDipanggil, false);
    assert.equal(orangTua.res.statusCode, 403);
});

test("middleware laporan menolak request tanpa autentikasi", async () => {
    const otorisasi = buatOtorisasiLaporan();

    const individual = await jalankan(otorisasi.individual, {
        params: { anak_id: "anak-1" },
    });
    const rekap = await jalankan(otorisasi.rekap, {});

    assert.equal(individual.res.statusCode, 401);
    assert.equal(rekap.res.statusCode, 401);
});

test("kegagalan pemeriksaan kepemilikan tidak membocorkan detail internal", async () => {
    const otorisasi = buatOtorisasiLaporan({
        cekKepemilikan: async () => {
            throw new Error("ER_BAD_FIELD_ERROR: rahasia");
        },
    });
    const hasil = await jalankan(otorisasi.individual, {
        user: { id: "user-orang-tua", role: "orang_tua" },
        params: { anak_id: "anak-1" },
    });

    assert.equal(hasil.res.statusCode, 500);
    assert.equal(hasil.res.body.message, "Terjadi kesalahan server");
});
