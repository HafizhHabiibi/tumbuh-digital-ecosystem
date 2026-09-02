import test from "node:test";
import assert from "node:assert/strict";
import {
    gabungkanPrioritasPemantauan,
    tentukanPrioritasMinimumAntropometri,
} from "../src/services/monitoringPriorityService.js";

const normal = Object.freeze({
    status_bbu: "berat_badan_normal",
    status_tbu: "normal",
    status_bbtb: "gizi_baik",
    status_imtu: "gizi_baik",
});

const hitung = (overrides = {}) => gabungkanPrioritasPemantauan({
    kategori_prioritas_saw: "rendah",
    ...normal,
    ...overrides,
});

test("kategori normal mempertahankan prioritas SAW", () => {
    assert.deepEqual(hitung(), {
        kategori: "rendah",
        sumber_utama: "saw",
        alasan: [],
    });
    assert.equal(hitung({ kategori_prioritas_saw: "sedang" }).kategori, "sedang");
    assert.equal(hitung({ kategori_prioritas_saw: "tinggi" }).kategori, "tinggi");
});

test("kategori kekurangan gizi menetapkan prioritas minimum", () => {
    assert.deepEqual(hitung({ status_bbu: "berat_badan_kurang" }), {
        kategori: "sedang",
        sumber_utama: "antropometri",
        alasan: ["bbu_berat_badan_kurang"],
    });
    assert.deepEqual(hitung({ status_tbu: "sangat_pendek" }), {
        kategori: "tinggi",
        sumber_utama: "antropometri",
        alasan: ["tbu_sangat_pendek"],
    });
});

test("risiko gizi lebih dan gizi lebih menetapkan prioritas sedang", () => {
    assert.equal(
        hitung({ status_bbtb: "risiko_gizi_lebih" }).kategori,
        "sedang",
    );
    assert.equal(hitung({ status_imtu: "gizi_lebih" }).kategori, "sedang");
});

test("obesitas BB/TB atau IMT/U menetapkan prioritas tinggi", () => {
    const bbtb = hitung({ status_bbtb: "obesitas" });
    const imtu = hitung({ status_imtu: "obesitas" });

    assert.equal(bbtb.kategori, "tinggi");
    assert.equal(bbtb.sumber_utama, "antropometri");
    assert.deepEqual(bbtb.alasan, ["bbtb_obesitas"]);
    assert.equal(imtu.kategori, "tinggi");
    assert.deepEqual(imtu.alasan, ["imtu_obesitas"]);
});

test("risiko BB lebih dan TB tinggi tidak menaikkan prioritas sendiri", () => {
    assert.deepEqual(hitung({
        status_bbu: "risiko_berat_badan_lebih",
        status_tbu: "tinggi",
    }), {
        kategori: "rendah",
        sumber_utama: "saw",
        alasan: [],
    });
});

test("prioritas SAW yang lebih tinggi tidak pernah diturunkan", () => {
    assert.deepEqual(hitung({
        kategori_prioritas_saw: "tinggi",
        status_imtu: "risiko_gizi_lebih",
    }), {
        kategori: "tinggi",
        sumber_utama: "saw",
        alasan: ["imtu_risiko_gizi_lebih"],
    });
});

test("tingkat aktif yang sama menghasilkan sumber gabungan", () => {
    assert.deepEqual(hitung({
        kategori_prioritas_saw: "sedang",
        status_bbtb: "gizi_lebih",
    }), {
        kategori: "sedang",
        sumber_utama: "gabungan",
        alasan: ["bbtb_gizi_lebih"],
    });
});

test("semua alasan dipertahankan dalam urutan indeks dan tingkat tertinggi dipakai", () => {
    assert.deepEqual(hitung({
        status_bbu: "berat_badan_kurang",
        status_tbu: "sangat_pendek",
        status_bbtb: "gizi_lebih",
        status_imtu: "obesitas",
    }), {
        kategori: "tinggi",
        sumber_utama: "antropometri",
        alasan: [
            "bbu_berat_badan_kurang",
            "tbu_sangat_pendek",
            "bbtb_gizi_lebih",
            "imtu_obesitas",
        ],
    });
});

test("prioritas minimum tanpa temuan menggunakan null", () => {
    assert.deepEqual(tentukanPrioritasMinimumAntropometri(normal), {
        kategori: null,
        alasan: [],
    });
});

test("layanan menolak input dan enum yang tidak dikenal", () => {
    assert.throws(
        () => gabungkanPrioritasPemantauan(null),
        /harus berupa object/,
    );
    assert.throws(
        () => hitung({ kategori_prioritas_saw: "darurat" }),
        /kategori_prioritas_saw tidak valid/,
    );
    assert.throws(
        () => hitung({ status_imtu: "tidak_dikenal" }),
        /status_imtu tidak valid/,
    );
});

test("layanan tidak memutasi input", () => {
    const input = {
        kategori_prioritas_saw: "rendah",
        ...normal,
        status_imtu: "obesitas",
    };
    const snapshot = structuredClone(input);

    hitung(input);

    assert.deepEqual(input, snapshot);
});
