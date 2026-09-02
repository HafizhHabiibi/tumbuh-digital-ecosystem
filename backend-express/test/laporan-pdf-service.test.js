import test from "node:test";
import assert from "node:assert/strict";
import {
    buatDokumenPdf,
    finalisasiPdf,
    tulisHeaderLaporan,
    tulisJudulBagian,
    tulisKeyValue,
    tulisPieChart,
    tulisTabel,
} from "../src/services/laporanPdfService.js";

const tulisHeader = (doc) => tulisHeaderLaporan(doc, {
    nama_posyandu: "Posyandu Melati",
    nama_puskesmas: "Puskesmas Sehat",
    judul: "Laporan Rekap Pemantauan Pertumbuhan Balita",
    subjudul: "Periode Agustus 2026",
});

test("komponen layout menghasilkan PDF A4 multi-halaman yang valid", async () => {
    const doc = buatDokumenPdf({ judul: "Laporan Test" });
    tulisHeader(doc);
    tulisKeyValue(doc, [
        { label: "Total Anak", nilai: "75" },
        { label: "Prioritas Rendah", nilai: "50" },
        { label: "Prioritas Sedang", nilai: "20" },
        { label: "Prioritas Tinggi", nilai: "5" },
    ]);
    tulisJudulBagian(doc, "Daftar Prioritas", { saatHalamanBaru: tulisHeader });

    const rows = Array.from({ length: 75 }, (_, index) => ({
        nomor: index + 1,
        nama: `Anak ${index + 1}`,
        orang_tua: `Orang Tua ${index + 1}`,
        prioritas: index % 3 === 0 ? "Tinggi" : "Sedang",
    }));
    tulisTabel(doc, {
        columns: [
            { key: "nomor", label: "No.", width: 38, align: "center" },
            { key: "nama", label: "Nama Anak", width: 150 },
            { key: "orang_tua", label: "Orang Tua", width: 190 },
            { key: "prioritas", label: "Prioritas", width: 121, align: "center" },
        ],
        rows,
        saatHalamanBaru: tulisHeader,
    });

    const buffer = await finalisasiPdf(doc);
    assert.equal(buffer.subarray(0, 5).toString("ascii"), "%PDF-");
    assert.ok(buffer.length > 4_000);

    const raw = buffer.toString("latin1");
    const jumlahPageObject = raw.match(/\/Type\s*\/Page\b/g)?.length || 0;
    assert.ok(jumlahPageObject >= 2);
});

test("layout menolak definisi tabel yang melampaui area A4", () => {
    const doc = buatDokumenPdf({ judul: "Test tabel invalid" });
    assert.throws(
        () => tulisTabel(doc, {
            columns: [
                { key: "a", label: "A", width: 400 },
                { key: "b", label: "B", width: 400 },
            ],
            rows: [],
        }),
        /melebihi area konten/,
    );
    doc.end();
});

test("tulisKeyValue menampilkan item tanpa error", async () => {
    const doc = buatDokumenPdf({ judul: "Test key-value" });
    tulisHeader(doc);
    tulisKeyValue(doc, [
        { label: "Nama", nilai: "Rizki" },
        { label: "Usia", nilai: "24 bulan" },
    ]);
    const buffer = await finalisasiPdf(doc);
    assert.equal(buffer.subarray(0, 5).toString("ascii"), "%PDF-");
    assert.ok(buffer.length > 1_000);
});

test("tulisKeyValue membungkus nilai panjang dan melanjutkan halaman", async () => {
    const doc = buatDokumenPdf({ judul: "Test key-value panjang" });
    tulisHeader(doc);
    tulisKeyValue(
        doc,
        Array.from({ length: 30 }, (_, index) => ({
            label: `Keterangan ${index + 1}`,
            nilai: "Informasi pertumbuhan anak yang panjang tetap ditampilkan secara utuh dan membungkus ke baris berikutnya tanpa melewati batas dokumen.",
        })),
        tulisHeader,
    );
    const buffer = await finalisasiPdf(doc);
    const jumlahHalaman = buffer.toString("latin1")
        .match(/\/Type\s*\/Page\b/g)?.length || 0;

    assert.ok(jumlahHalaman >= 2);
});

test("tulisPieChart menghasilkan output yang valid", async () => {
    const doc = buatDokumenPdf({ judul: "Test pie chart" });
    tulisHeader(doc);
    tulisPieChart(doc, {
        judul: "Distribusi Prioritas",
        data: [
            { label: "Rendah", nilai: 46, warna: "#2E7D32" },
            { label: "Sedang", nilai: 24, warna: "#EF6C00" },
            { label: "Tinggi", nilai: 8, warna: "#C62828" },
        ],
    });
    const buffer = await finalisasiPdf(doc);
    assert.equal(buffer.subarray(0, 5).toString("ascii"), "%PDF-");
    assert.ok(buffer.length > 2_000);
});

test("tulisPieChart menangani data kosong (total nol)", async () => {
    const doc = buatDokumenPdf({ judul: "Test pie chart kosong" });
    tulisHeader(doc);
    tulisPieChart(doc, {
        data: [
            { label: "Rendah", nilai: 0, warna: "#2E7D32" },
            { label: "Sedang", nilai: 0, warna: "#EF6C00" },
        ],
    });
    const buffer = await finalisasiPdf(doc);
    assert.equal(buffer.subarray(0, 5).toString("ascii"), "%PDF-");
});

test("tulisPieChart menolak nilai negatif", () => {
    const doc = buatDokumenPdf({ judul: "Test pie chart invalid" });
    assert.throws(
        () => tulisPieChart(doc, {
            data: [{ label: "Tidak valid", nilai: -1, warna: "#000000" }],
        }),
        /non-negatif/,
    );
    doc.end();
});

test("footer tidak menambahkan halaman kosong saat finalisasi", async () => {
    const doc = buatDokumenPdf({ judul: "Test footer" });
    tulisHeader(doc);
    doc.text("Konten satu halaman");

    const buffer = await finalisasiPdf(doc);
    const jumlahHalaman = buffer.toString("latin1")
        .match(/\/Type\s*\/Page\b/g)?.length || 0;

    assert.equal(jumlahHalaman, 1);
});
