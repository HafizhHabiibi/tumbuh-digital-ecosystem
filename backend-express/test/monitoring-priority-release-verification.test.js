import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

import {
    buatDistribusiPrioritasPemantauan,
    enrichPengukuranDenganPrioritas,
} from "../src/services/pengukuranService.js";
import { toOrangTuaPengukuran } from
    "../src/serializers/orangTuaPengukuranSerializer.js";

const anak = Object.freeze({
    tanggal_lahir: "2024-08-26",
    jenis_kelamin: "L",
});

const buatPengukuran = (id, beratBadan) => ({
    id,
    anak_id: `anak-${id}`,
    tanggal_ukur: "2026-08-26",
    berat_badan: beratBadan,
    tinggi_badan: 85,
    lingkar_kepala: null,
    lingkar_lengan: null,
    created_at: "2026-08-26T08:00:00.000Z",
});

const skenario = Object.freeze([
    Object.freeze({
        nama: "normal",
        raw: buatPengukuran(1, 11),
        statusBbtb: "gizi_baik",
        saw: "rendah",
        prioritas: "rendah",
        statusOrangTua: "rutin",
    }),
    Object.freeze({
        nama: "kekurangan gizi",
        raw: buatPengukuran(2, 9),
        statusBbtb: "gizi_buruk",
        saw: "tinggi",
        prioritas: "tinggi",
        statusOrangTua: "konsultasi",
    }),
    Object.freeze({
        nama: "gizi lebih",
        raw: buatPengukuran(3, 14),
        statusBbtb: "gizi_lebih",
        saw: "rendah",
        prioritas: "sedang",
        statusOrangTua: "perlu_perhatian",
    }),
    Object.freeze({
        nama: "obesitas",
        raw: buatPengukuran(4, 15),
        statusBbtb: "obesitas",
        saw: "rendah",
        prioritas: "tinggi",
        statusOrangTua: "konsultasi",
    }),
]);

test("fixture rilis konsisten untuk normal, kekurangan, gizi lebih, dan obesitas", () => {
    for (const fixture of skenario) {
        const enriched = enrichPengukuranDenganPrioritas(fixture.raw, anak);
        const orangTua = toOrangTuaPengukuran(enriched);

        assert.equal(enriched.status_bbtb, fixture.statusBbtb, fixture.nama);
        assert.equal(
            enriched.kategori_prioritas,
            fixture.saw,
            `${fixture.nama}: kategori SAW`,
        );
        assert.equal(
            enriched.prioritas_pemantauan.kategori,
            fixture.prioritas,
            `${fixture.nama}: prioritas akhir`,
        );
        assert.equal(
            orangTua.status_pemantauan,
            fixture.statusOrangTua,
            `${fixture.nama}: kontrak orang tua`,
        );
        assert.equal("skor_saw" in orangTua, false, fixture.nama);
        assert.equal("prioritas_pemantauan" in orangTua, false, fixture.nama);
    }
});

test("perubahan distribusi dapat dijelaskan oleh lapisan antropometri", () => {
    const enriched = skenario.map(({ raw }) =>
        enrichPengukuranDenganPrioritas(raw, anak));
    const distribusiSawLama = enriched.reduce(
        (hasil, item) => {
            hasil[item.kategori_prioritas]++;
            return hasil;
        },
        { rendah: 0, sedang: 0, tinggi: 0 },
    );

    assert.deepEqual(distribusiSawLama, {
        rendah: 3,
        sedang: 0,
        tinggi: 1,
    });
    assert.deepEqual(buatDistribusiPrioritasPemantauan(enriched), {
        rendah: 1,
        sedang: 1,
        tinggi: 2,
    });
});

test("alur pencatatan pengukuran tidak memiliki dependensi pembuat rujukan", () => {
    const controller = fs.readFileSync(
        new URL("../src/controllers/pengukuranController.js", import.meta.url),
        "utf8",
    );

    assert.doesNotMatch(controller, /RujukanModel/);
    assert.doesNotMatch(controller, /createRujukan/);
    assert.doesNotMatch(controller, /INSERT\s+INTO\s+rujukan/i);
});
