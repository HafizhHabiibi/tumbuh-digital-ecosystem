import test from "node:test";
import assert from "node:assert/strict";
import express from "express";
import { buatLaporanController } from "../src/controllers/laporanController.js";
import { buatOtorisasiLaporan } from "../src/middlewares/laporanAuthorization.js";
import { buatLaporanRouter } from "../src/routes/laporan.js";

const ANAK_SENDIRI = "018f0000-0000-7000-8000-000000000001";
const ANAK_LAIN = "018f0000-0000-7000-8000-000000000002";
const PDF_ORANG_TUA = Buffer.from("%PDF-ORANG-TUA");
const PDF_TEKNIS = Buffer.from("%PDF-TEKNIS");
const PDF_REKAP = Buffer.from("%PDF-REKAP");

const autentikasiTest = (req, res, next) => {
    const role = req.headers["x-test-role"];
    if (!role) {
        return res.status(401).json({
            success: false,
            message: "Token tidak ditemukan",
            data: null,
        });
    }
    req.user = {
        id: req.headers["x-test-user"] || `user-${role}`,
        role,
    };
    return next();
};

const bukaServer = async (router) => {
    const app = express();
    app.use("/api/laporan", router);
    app.use((req, res) => res.status(404).json({
        success: false,
        message: "Endpoint tidak ditemukan",
        data: null,
    }));
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

test("integrasi endpoint laporan menerapkan kontrak akses dan download PDF", async (t) => {
    const panggilan = [];
    const controller = buatLaporanController({
        ambilProfil: async (user) => ({
            nama_lengkap: user.role === "orang_tua" ? "Aminah" : "Petugas",
        }),
        siapkanOrangTua: async (anakId) => {
            panggilan.push({ jenis: "orang_tua", anakId });
            return { anak: { nama: "Rizki" } };
        },
        siapkanTeknis: async (anakId) => {
            panggilan.push({ jenis: "teknis", anakId });
            return { anak: { nama: "Rizki" } };
        },
        siapkanRekap: async (mulai, selesai) => {
            panggilan.push({ jenis: "rekap", mulai, selesai });
            return {};
        },
        renderOrangTua: async () => PDF_ORANG_TUA,
        renderTeknis: async () => PDF_TEKNIS,
        renderRekap: async () => PDF_REKAP,
    });
    const otorisasi = buatOtorisasiLaporan({
        cekKepemilikan: async (anakId, userId) =>
            anakId === ANAK_SENDIRI && userId === "user-orang-tua",
    });
    const router = buatLaporanRouter({
        authenticateMiddleware: autentikasiTest,
        authorizeIndividual: otorisasi.individual,
        authorizeRekap: otorisasi.rekap,
        downloadIndividual: controller.downloadIndividual,
        downloadRekap: controller.downloadRekap,
    });
    const server = await bukaServer(router);

    try {
        await t.test("request tanpa autentikasi ditolak", async () => {
            const response = await fetch(
                `${server.baseUrl}/api/laporan/anak/${ANAK_SENDIRI}`,
            );
            assert.equal(response.status, 401);
            assert.equal(response.headers.get("content-type")?.includes("json"), true);
        });

        await t.test("orang tua menerima varian sederhana meski meminta jenis teknis", async () => {
            const sebelum = panggilan.length;
            const response = await fetch(
                `${server.baseUrl}/api/laporan/anak/${ANAK_SENDIRI}?jenis=teknis`,
                {
                    headers: {
                        "x-test-role": "orang_tua",
                        "x-test-user": "user-orang-tua",
                    },
                },
            );
            const buffer = Buffer.from(await response.arrayBuffer());

            assert.equal(response.status, 200);
            assert.equal(response.headers.get("content-type"), "application/pdf");
            assert.equal(response.headers.get("cache-control"), "private, no-store");
            assert.equal(
                response.headers.get("content-disposition"),
                'attachment; filename="laporan-ringkasan-rizki.pdf"',
            );
            assert.deepEqual(buffer, PDF_ORANG_TUA);
            assert.deepEqual(panggilan.slice(sebelum), [{
                jenis: "orang_tua",
                anakId: ANAK_SENDIRI,
            }]);
        });

        await t.test("orang tua tidak dapat menebak laporan anak lain", async () => {
            const sebelum = panggilan.length;
            const response = await fetch(
                `${server.baseUrl}/api/laporan/anak/${ANAK_LAIN}`,
                {
                    headers: {
                        "x-test-role": "orang_tua",
                        "x-test-user": "user-orang-tua",
                    },
                },
            );
            const body = await response.json();

            assert.equal(response.status, 404);
            assert.equal(body.message, "Laporan anak tidak ditemukan");
            assert.equal(panggilan.length, sebelum);
        });

        await t.test("kader menerima varian teknis", async () => {
            const sebelum = panggilan.length;
            const response = await fetch(
                `${server.baseUrl}/api/laporan/anak/${ANAK_LAIN}`,
                { headers: { "x-test-role": "kader" } },
            );
            const buffer = Buffer.from(await response.arrayBuffer());

            assert.equal(response.status, 200);
            assert.deepEqual(buffer, PDF_TEKNIS);
            assert.deepEqual(panggilan.slice(sebelum), [{
                jenis: "teknis",
                anakId: ANAK_LAIN,
            }]);
        });

        await t.test("orang tua ditolak dari laporan rekap", async () => {
            const response = await fetch(
                `${server.baseUrl}/api/laporan/rekap?tanggal_mulai=2026-08-01&tanggal_selesai=2026-08-27`,
                { headers: { "x-test-role": "orang_tua" } },
            );
            assert.equal(response.status, 403);
        });

        await t.test("Puskesmas dapat mengunduh rekap tervalidasi", async () => {
            const sebelum = panggilan.length;
            const response = await fetch(
                `${server.baseUrl}/api/laporan/rekap?tanggal_mulai=2026-08-01&tanggal_selesai=2026-08-27`,
                { headers: { "x-test-role": "puskesmas" } },
            );
            const buffer = Buffer.from(await response.arrayBuffer());

            assert.equal(response.status, 200);
            assert.deepEqual(buffer, PDF_REKAP);
            assert.deepEqual(panggilan.slice(sebelum), [{
                jenis: "rekap",
                mulai: "2026-08-01",
                selesai: "2026-08-27",
            }]);
        });

        await t.test("UUID dan periode berbahaya ditolak sebelum controller", async () => {
            const sebelum = panggilan.length;
            const uuidInvalid = await fetch(
                `${server.baseUrl}/api/laporan/anak/%27%20OR%201%3D1`,
                { headers: { "x-test-role": "kader" } },
            );
            const periodeInvalid = await fetch(
                `${server.baseUrl}/api/laporan/rekap?tanggal_mulai=2026-08-27&tanggal_selesai=2026-08-01`,
                { headers: { "x-test-role": "puskesmas" } },
            );

            assert.equal(uuidInvalid.status, 400);
            assert.equal(periodeInvalid.status, 400);
            assert.equal(panggilan.length, sebelum);
        });
    } finally {
        await server.tutup();
    }
});
