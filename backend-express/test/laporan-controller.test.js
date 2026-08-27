import test from "node:test";
import assert from "node:assert/strict";
import { buatLaporanController } from "../src/controllers/laporanController.js";
import { LaporanDataError } from "../src/services/laporanService.js";

const PDF = Buffer.from("%PDF-test");

const buatResponse = () => ({
    statusCode: 200,
    headers: {},
    body: null,
    setHeader(name, value) {
        this.headers[name.toLowerCase()] = value;
    },
    status(code) {
        this.statusCode = code;
        return this;
    },
    send(body) {
        this.body = body;
        return this;
    },
    json(body) {
        this.body = body;
        return this;
    },
});

const laporanIndividual = {
    anak: { nama: "Áni / Uji Header" },
};

test("controller memilih laporan sederhana untuk orang tua", async () => {
    let teknisDipanggil = false;
    const controller = buatLaporanController({
        ambilProfil: async () => ({ nama_lengkap: "Aminah" }),
        siapkanOrangTua: async (anakId, pembuat) => {
            assert.equal(anakId, "anak-1");
            assert.equal(pembuat, "Aminah");
            return laporanIndividual;
        },
        siapkanTeknis: async () => {
            teknisDipanggil = true;
        },
        renderOrangTua: async () => PDF,
    });
    const res = buatResponse();

    await controller.downloadIndividual({
        user: { id: "user-1", role: "orang_tua" },
        params: { anak_id: "anak-1" },
        validatedParams: { anak_id: "anak-1" },
    }, res);

    assert.equal(teknisDipanggil, false);
    assert.equal(res.statusCode, 200);
    assert.equal(res.headers["content-type"], "application/pdf");
    assert.equal(
        res.headers["content-disposition"],
        'attachment; filename="laporan-ringkasan-ani-uji-header.pdf"',
    );
    assert.equal(res.headers["cache-control"], "private, no-store");
    assert.equal(res.body, PDF);
});

test("controller memilih laporan teknis untuk kader", async () => {
    let orangTuaDipanggil = false;
    const controller = buatLaporanController({
        ambilProfil: async () => ({ nama_lengkap: "Kader Riri" }),
        siapkanOrangTua: async () => {
            orangTuaDipanggil = true;
        },
        siapkanTeknis: async () => laporanIndividual,
        renderTeknis: async () => PDF,
    });
    const res = buatResponse();

    await controller.downloadIndividual({
        user: { id: "user-kader", role: "kader" },
        params: { anak_id: "anak-1" },
        validatedParams: { anak_id: "anak-1" },
    }, res);

    assert.equal(orangTuaDipanggil, false);
    assert.equal(
        res.headers["content-disposition"],
        'attachment; filename="laporan-teknis-ani-uji-header.pdf"',
    );
});

test("controller rekap meneruskan periode tervalidasi", async () => {
    const controller = buatLaporanController({
        ambilProfil: async () => ({ nama_lengkap: "Bidan Sari" }),
        siapkanRekap: async (mulai, selesai, pembuat) => {
            assert.deepEqual(
                [mulai, selesai, pembuat],
                ["2026-08-01", "2026-08-27", "Bidan Sari"],
            );
            return { metadata: {} };
        },
        renderRekap: async () => PDF,
    });
    const res = buatResponse();

    await controller.downloadRekap({
        user: { id: "user-puskesmas", role: "puskesmas" },
        validatedQuery: {
            tanggal_mulai: "2026-08-01",
            tanggal_selesai: "2026-08-27",
        },
    }, res);

    assert.equal(res.statusCode, 200);
    assert.equal(
        res.headers["content-disposition"],
        'attachment; filename="laporan-rekap-2026-08-01-2026-08-27.pdf"',
    );
});

test("controller memetakan kondisi laporan kosong ke response yang tepat", async () => {
    const profil = async () => ({ nama_lengkap: "Kader" });
    const tidakAda = buatLaporanController({
        ambilProfil: profil,
        siapkanTeknis: async () => null,
    });
    const belumDiukur = buatLaporanController({
        ambilProfil: profil,
        siapkanTeknis: async () => {
            throw new LaporanDataError("Belum ada pengukuran", "PENGUKURAN_KOSONG");
        },
    });
    const req = {
        user: { id: "user-kader", role: "kader" },
        params: { anak_id: "anak-1" },
    };
    const resTidakAda = buatResponse();
    const resBelumDiukur = buatResponse();

    await tidakAda.downloadIndividual(req, resTidakAda);
    await belumDiukur.downloadIndividual(req, resBelumDiukur);

    assert.equal(resTidakAda.statusCode, 404);
    assert.equal(resBelumDiukur.statusCode, 422);
});
