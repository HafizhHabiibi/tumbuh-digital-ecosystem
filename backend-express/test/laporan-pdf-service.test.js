import test from "node:test";
import assert from "node:assert/strict";
import {
    buatDokumenPdf,
    finalisasiPdf,
    tulisBadge,
    tulisHeaderLaporan,
    tulisJudulBagian,
    tulisKartuRingkasan,
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
    tulisKartuRingkasan(doc, [
        { label: "Total Anak", nilai: 75 },
        { label: "Prioritas Rendah", nilai: 50 },
        { label: "Prioritas Sedang", nilai: 20 },
        { label: "Prioritas Tinggi", nilai: 5 },
    ]);
    tulisJudulBagian(doc, "Daftar Prioritas", { saatHalamanBaru: tulisHeader });
    tulisBadge(doc, {
        x: doc.page.margins.left,
        y: doc.y,
        teks: "Prioritas Tinggi",
        kategori: "tinggi",
    });
    doc.y += 32;

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
    assert.ok(buffer.length > 10_000);

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

test("kartu ringkasan membatasi maksimal empat item", () => {
    const doc = buatDokumenPdf({ judul: "Test kartu invalid" });
    assert.throws(
        () => tulisKartuRingkasan(doc, Array.from({ length: 5 }, () => ({
            label: "Item",
            nilai: 1,
        }))),
        /1 sampai 4 item/,
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
