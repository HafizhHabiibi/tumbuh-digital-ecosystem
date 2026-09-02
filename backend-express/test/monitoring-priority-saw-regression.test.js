import test from "node:test";
import assert from "node:assert/strict";
import { hitungSAW } from "../src/services/sawService.js";
import { gabungkanPrioritasPemantauan } from "../src/services/monitoringPriorityService.js";

const fixtureSAW = Object.freeze([
    Object.freeze({
        nama: "seluruh z-score nol",
        input: Object.freeze({
            zscore_bbu: 0,
            zscore_tbu: 0,
            zscore_bbtb: 0,
            zscore_imtu: 0,
        }),
        hasil: Object.freeze({ skor: 0, kategori: "rendah" }),
    }),
    Object.freeze({
        nama: "kombinasi risiko kekurangan gizi",
        input: Object.freeze({
            zscore_bbu: -1,
            zscore_tbu: -2,
            zscore_bbtb: -3,
            zscore_imtu: 1,
        }),
        hasil: Object.freeze({ skor: 0.5333, kategori: "sedang" }),
    }),
    Object.freeze({
        nama: "seluruh z-score positif",
        input: Object.freeze({
            zscore_bbu: 2,
            zscore_tbu: 3,
            zscore_bbtb: 4,
            zscore_imtu: 5,
        }),
        hasil: Object.freeze({ skor: 0, kategori: "rendah" }),
    }),
    Object.freeze({
        nama: "normalisasi negatif tetap dibatasi dan dibobot",
        input: Object.freeze({
            zscore_bbu: -4,
            zscore_tbu: -1.5,
            zscore_bbtb: 0,
            zscore_imtu: -0.75,
        }),
        hasil: Object.freeze({ skor: 0.45, kategori: "sedang" }),
    }),
]);

test("hasil SAW lama tetap identik setelah prioritas pemantauan ditambahkan", () => {
    for (const fixture of fixtureSAW) {
        const hasil = hitungSAW(fixture.input);
        assert.equal(hasil.skor_akhir, fixture.hasil.skor, fixture.nama);
        assert.equal(
            hasil.kategori_prioritas,
            fixture.hasil.kategori,
            fixture.nama,
        );
        assert.equal(hasil.detail.length, 4, fixture.nama);
    }
});

test("penggabungan prioritas tidak mengubah objek maupun hasil SAW", () => {
    const zscores = {
        zscore_bbu: 2,
        zscore_tbu: 1,
        zscore_bbtb: 4,
        zscore_imtu: 4,
    };
    const saw = hitungSAW(zscores);
    const snapshot = structuredClone(saw);

    const prioritas = gabungkanPrioritasPemantauan({
        kategori_prioritas_saw: saw.kategori_prioritas,
        status_bbu: "risiko_berat_badan_lebih",
        status_tbu: "normal",
        status_bbtb: "obesitas",
        status_imtu: "obesitas",
    });

    assert.deepEqual(saw, snapshot);
    assert.equal(saw.kategori_prioritas, "rendah");
    assert.equal(prioritas.kategori, "tinggi");
});
