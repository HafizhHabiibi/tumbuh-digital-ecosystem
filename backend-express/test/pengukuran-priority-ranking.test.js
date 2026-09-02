import test from "node:test";
import assert from "node:assert/strict";
import {
    bandingkanRankingPrioritas,
    buatDistribusiPrioritasPemantauan,
    buatStatistikDashboard,
    enrichPengukuranDenganPrioritas,
} from "../src/services/pengukuranService.js";

const item = ({
    anak_id,
    kategori,
    skor_saw,
    tanggal_ukur = "2026-08-26",
}) => ({
    anak_id,
    skor_saw,
    tanggal_ukur,
    prioritas_pemantauan: { kategori },
});

test("ranking mendahulukan prioritas pemantauan sebelum skor SAW", () => {
    const daftar = [
        item({ anak_id: "b", kategori: "sedang", skor_saw: 0.6 }),
        item({ anak_id: "a", kategori: "tinggi", skor_saw: 0 }),
        item({ anak_id: "c", kategori: "rendah", skor_saw: 0.2 }),
    ];

    daftar.sort(bandingkanRankingPrioritas);

    assert.deepEqual(daftar.map(({ anak_id }) => anak_id), ["a", "b", "c"]);
});

test("ranking memakai skor, tanggal, lalu ID sebagai tie-breaker", () => {
    const daftar = [
        item({
            anak_id: "c",
            kategori: "tinggi",
            skor_saw: 0.7,
            tanggal_ukur: "2026-08-27",
        }),
        item({
            anak_id: "b",
            kategori: "tinggi",
            skor_saw: 0.8,
            tanggal_ukur: "2026-08-25",
        }),
        item({
            anak_id: "a",
            kategori: "tinggi",
            skor_saw: 0.7,
            tanggal_ukur: "2026-08-27",
        }),
    ];

    daftar.sort(bandingkanRankingPrioritas);

    assert.deepEqual(daftar.map(({ anak_id }) => anak_id), ["b", "a", "c"]);
});

test("distribusi menghitung kategori prioritas pemantauan akhir", () => {
    const distribusi = buatDistribusiPrioritasPemantauan([
        item({ anak_id: "a", kategori: "tinggi", skor_saw: 0 }),
        item({ anak_id: "b", kategori: "tinggi", skor_saw: 0.8 }),
        item({ anak_id: "c", kategori: "sedang", skor_saw: 0.5 }),
        item({ anak_id: "d", kategori: "rendah", skor_saw: 0.1 }),
    ]);

    assert.deepEqual(distribusi, { rendah: 1, sedang: 1, tinggi: 2 });
});

test("statistik dashboard menghitung obesitas sebagai prioritas tinggi", () => {
    const anak = {
        tanggal_lahir: "2024-08-26",
        jenis_kelamin: "L",
    };
    const obesitas = enrichPengukuranDenganPrioritas({
        id: 1,
        anak_id: "anak-obesitas",
        tanggal_ukur: "2026-08-26",
        berat_badan: "20.00",
        tinggi_badan: "85.00",
    }, anak);
    const normal = enrichPengukuranDenganPrioritas({
        id: 2,
        anak_id: "anak-normal",
        tanggal_ukur: "2026-08-26",
        berat_badan: "11.00",
        tinggi_badan: "85.00",
    }, anak);

    assert.equal(obesitas.kategori_prioritas, "rendah");
    assert.equal(obesitas.prioritas_pemantauan.kategori, "tinggi");
    assert.deepEqual(buatStatistikDashboard({
        totalAnak: "2",
        totalRujukanAktif: "0",
        totalPengukuranBulan: "2",
        pengukuranTerbaru: [normal, obesitas],
    }), {
        total_anak: 2,
        total_prioritas_tinggi: 1,
        total_rujukan_aktif: 0,
        total_pengukuran_bulan: 2,
    });
});

test("ranking dan distribusi menolak prioritas pemantauan tidak valid", () => {
    const valid = item({ anak_id: "a", kategori: "rendah", skor_saw: 0 });
    const invalid = item({ anak_id: "b", kategori: "darurat", skor_saw: 0 });

    assert.throws(
        () => bandingkanRankingPrioritas(valid, invalid),
        /Kategori prioritas pemantauan tidak valid/,
    );
    assert.throws(
        () => buatDistribusiPrioritasPemantauan([invalid]),
        /Kategori prioritas pemantauan tidak valid/,
    );
});
