import test from "node:test";
import assert from "node:assert/strict";
import {
    enrichPengukuranDenganPrioritas,
    enrichPengukuranList,
} from "../src/services/pengukuranService.js";

test("enrichment rujukan menyertakan SAW, antropometri, dan prioritas pemantauan", () => {
    const result = enrichPengukuranDenganPrioritas(
        {
            id: 17,
            tanggal_ukur: "2026-08-26",
            berat_badan: "11.00",
            tinggi_badan: "85.00",
        },
        {
            tanggal_lahir: "2024-08-26",
            jenis_kelamin: "L",
        },
    );

    assert.equal(result.id, 17);
    assert.equal(result.berat_badan, 11);
    assert.equal(result.tinggi_badan, 85);
    assert.ok(Number.isFinite(result.skor_saw));
    assert.ok(["rendah", "sedang", "tinggi"].includes(result.kategori_prioritas));
    assert.ok(
        ["rendah", "sedang", "tinggi"].includes(
            result.prioritas_pemantauan.kategori,
        ),
    );
    assert.ok(
        ["saw", "antropometri", "gabungan"].includes(
            result.prioritas_pemantauan.sumber_utama,
        ),
    );
    assert.ok(Array.isArray(result.prioritas_pemantauan.alasan));

    for (const field of [
        "status_bbu",
        "status_tbu",
        "status_bbtb",
        "status_imtu",
    ]) {
        assert.equal(typeof result[field], "string");
        assert.ok(result[field].length > 0);
    }
});

test("enrichment menaikkan pemantauan obesitas tanpa mengubah hasil SAW", () => {
    const result = enrichPengukuranDenganPrioritas(
        {
            id: 18,
            tanggal_ukur: "2026-08-26",
            berat_badan: "20.00",
            tinggi_badan: "85.00",
        },
        {
            tanggal_lahir: "2024-08-26",
            jenis_kelamin: "L",
        },
    );

    assert.equal(result.status_bbtb, "obesitas");
    assert.equal(result.status_imtu, "obesitas");
    assert.equal(result.kategori_prioritas, "rendah");
    assert.equal(result.prioritas_pemantauan.kategori, "tinggi");
    assert.equal(
        result.prioritas_pemantauan.sumber_utama,
        "antropometri",
    );
    assert.deepEqual(result.prioritas_pemantauan.alasan, [
        "bbtb_obesitas",
        "imtu_obesitas",
    ]);
});

test("enrichment riwayat konsisten dengan enrichment detail", () => {
    const raw = {
        id: 19,
        tanggal_ukur: "2026-07-26",
        berat_badan: "11.00",
        tinggi_badan: "84.00",
    };
    const anak = {
        tanggal_lahir: "2024-08-26",
        jenis_kelamin: "L",
    };

    assert.deepEqual(
        enrichPengukuranList([raw], anak),
        [enrichPengukuranDenganPrioritas(raw, anak)],
    );
});
