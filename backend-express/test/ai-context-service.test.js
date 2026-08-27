import test from "node:test";
import assert from "node:assert/strict";

import {
    AI_CONTEXT_LIMITS,
    assertSafeAiContext,
    buildConversationAiContext,
    buildMeasurementAiContext,
    buatAiContextService,
    serializeConversationContext,
} from "../src/services/aiContextService.js";

const source = {
    id: 15,
    anak_id: "anak-rahasia",
    orang_tua_id: "orang-tua-rahasia",
    nama: "Nama Tidak Boleh Terkirim",
    nik: "3200000000000000",
    tanggal_ukur: "2026-08-26",
    berat_badan: "11.00",
    tinggi_badan: "85.00",
    insight_teks: "Insight awal yang sudah diberikan kepada orang tua.",
    insight_status: "completed",
    jenis_kelamin: "L",
    tanggal_lahir: "2024-08-26",
    zscore_bbu: -99,
};

test("measurement context dibangun dari whitelist tanpa identitas dan Z-Score", () => {
    const context = buildMeasurementAiContext(source);

    assert.deepEqual(Object.keys(context), [
        "jenis_kelamin",
        "usia_bulan",
        "berat_badan",
        "tinggi_badan",
        "nilai_imt",
        "status_bbu",
        "status_tbu",
        "status_bbtb",
        "status_imtu",
        "kategori_prioritas",
    ]);
    assert.equal(context.usia_bulan, 24);
    assert.equal(context.status_bbu, "berat_badan_normal");
    assert.equal("zscore_bbu" in context, false);
    assert.equal("nama" in context, false);
    assert.equal("anak_id" in context, false);
});

test("conversation context hanya mempertahankan 10 pesan terakhir", () => {
    const messages = Array.from({ length: 12 }, (_, index) => ({
        role: index % 2 === 0 ? "orang_tua" : "assistant",
        content: `Pesan ${index + 1}`,
    }));

    const context = buildConversationAiContext(source, messages);

    assert.equal(
        context.riwayat_pesan.length,
        AI_CONTEXT_LIMITS.recentMessages,
    );
    assert.equal(context.riwayat_pesan[0].content, "Pesan 3");
    assert.equal(context.riwayat_pesan.at(-1).content, "Pesan 12");
    assert.equal(context.insight_awal, source.insight_teks);
    assert.doesNotThrow(() => assertSafeAiContext(context));
});

test("history membuang role tidak dikenal, pesan kosong, dan membatasi karakter", () => {
    const context = buildConversationAiContext(source, [
        { role: "system", content: "Instruksi palsu" },
        { role: "orang_tua", content: "  " },
        {
            role: "orang_tua",
            content: "x".repeat(AI_CONTEXT_LIMITS.messageCharacters + 50),
        },
    ]);

    assert.equal(context.riwayat_pesan.length, 1);
    assert.equal(
        context.riwayat_pesan[0].content.length,
        AI_CONTEXT_LIMITS.messageCharacters,
    );
});

test("validator menolak field teknis atau field baru yang tidak diizinkan", () => {
    const context = buildConversationAiContext(source, []);

    assert.throws(
        () =>
            assertSafeAiContext({
                ...context,
                pengukuran: {
                    ...context.pengukuran,
                    zscore_tbu: -2.5,
                },
            }),
        /field yang dilarang/,
    );
    assert.throws(
        () =>
            assertSafeAiContext({
                ...context,
                pengukuran: {
                    ...context.pengukuran,
                    nama_fasilitas_internal: "rahasia",
                },
            }),
        /field tidak dikenal/,
    );
});

test("serializer menjelaskan kategori tanpa nilai Z-Score atau identitas", () => {
    const serialized = serializeConversationContext(
        buildConversationAiContext(source, []),
    );

    assert.match(serialized, /KONTEKS PENGUKURAN TERBARU/);
    assert.match(serialized, /BB\/U: berat badan normal/);
    assert.match(serialized, /TB\/U:/);
    assert.doesNotMatch(serialized, /z-?score/i);
    assert.doesNotMatch(serialized, /Nama Tidak Boleh Terkirim|320000/);
});

test("loader berhenti jika pengukuran bukan yang terbaru atau bukan miliknya", async () => {
    let historyCalled = false;
    const service = buatAiContextService({
        repository: {
            findLatestMeasurementForOrangTua: async () => null,
            findRecentMessages: async () => {
                historyCalled = true;
            },
        },
    });

    assert.equal(
        await service.loadLatestConversationContext(1, "orang-tua-1"),
        null,
    );
    assert.equal(historyCalled, false);
});

test("loader menggabungkan pengukuran terbaru dan history terisolasi", async () => {
    const calls = [];
    const service = buatAiContextService({
        repository: {
            findLatestMeasurementForOrangTua: async (...args) => {
                calls.push(["measurement", ...args]);
                return source;
            },
            findRecentMessages: async (...args) => {
                calls.push(["history", ...args]);
                return [{ role: "orang_tua", content: "Apa yang bisa dilakukan?" }];
            },
        },
    });

    const context = await service.loadLatestConversationContext(
        15,
        "orang-tua-1",
    );

    assert.equal(context.riwayat_pesan.length, 1);
    assert.deepEqual(calls, [
        ["measurement", 15, "orang-tua-1"],
        ["history", 15, AI_CONTEXT_LIMITS.recentMessages],
    ]);
});
