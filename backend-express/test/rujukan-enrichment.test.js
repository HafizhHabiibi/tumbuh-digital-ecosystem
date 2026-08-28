import test from "node:test";
import assert from "node:assert/strict";
import { enrichPengukuranDenganPrioritas } from "../src/services/pengukuranService.js";

test("enrichment rujukan menyertakan prioritas SAW dan empat status antropometri", () => {
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
