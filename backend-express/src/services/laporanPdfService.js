import PDFDocument from "pdfkit";

export const WARNA_LAPORAN = Object.freeze({
    utama: "#176B5B",
    utamaGelap: "#0F4D42",
    aksen: "#DCEFEA",
    teks: "#263238",
    teksSekunder: "#607D8B",
    garis: "#D9E2E1",
    latarBaris: "#F7FAF9",
    putih: "#FFFFFF",
    rendah: "#2E7D32",
    sedang: "#EF6C00",
    tinggi: "#C62828",
});

const FONT = Object.freeze({
    regular: "Helvetica",
    bold: "Helvetica-Bold",
});

const UKURAN = Object.freeze({
    margin: 48,
    footer: 28,
    paddingCell: 7,
});

const teksAman = (value) => String(value ?? "-")
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
    .trim();

const batasBawahKonten = (doc) =>
    doc.page.height - doc.page.margins.bottom - UKURAN.footer;

export const buatDokumenPdf = ({ judul, pembuat = "Tumbuh Posyandu" } = {}) => {
    const doc = new PDFDocument({
        size: "A4",
        margins: {
            top: UKURAN.margin,
            right: UKURAN.margin,
            bottom: UKURAN.margin + UKURAN.footer,
            left: UKURAN.margin,
        },
        bufferPages: true,
        info: {
            Title: teksAman(judul || "Laporan Pemantauan Pertumbuhan"),
            Author: teksAman(pembuat),
            Creator: "Tumbuh Posyandu Backend",
            Producer: "PDFKit",
        },
    });

    doc.font(FONT.regular).fillColor(WARNA_LAPORAN.teks);
    return doc;
};

export const pastikanRuang = (doc, tinggiDibutuhkan, saatHalamanBaru) => {
    if (doc.y + tinggiDibutuhkan <= batasBawahKonten(doc)) return false;
    doc.addPage();
    if (typeof saatHalamanBaru === "function") saatHalamanBaru(doc);
    return true;
};

export const tulisHeaderLaporan = (doc, {
    nama_posyandu = "Posyandu",
    nama_puskesmas = "Puskesmas",
    judul,
    subjudul = null,
} = {}) => {
    const kiri = doc.page.margins.left;
    const lebar = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const atas = doc.page.margins.top;

    doc.save()
        .fillColor(WARNA_LAPORAN.utama)
        .rect(0, 0, doc.page.width, 8)
        .fill()
        .restore();

    doc.font(FONT.bold)
        .fontSize(15)
        .fillColor(WARNA_LAPORAN.utamaGelap)
        .text(teksAman(nama_posyandu), kiri, atas, {
            width: lebar * 0.42,
            lineBreak: false,
        });
    doc.font(FONT.regular)
        .fontSize(9)
        .fillColor(WARNA_LAPORAN.teksSekunder)
        .text(teksAman(nama_puskesmas), kiri, atas + 20, {
            width: lebar * 0.42,
            lineBreak: false,
        });

    doc.font(FONT.bold)
        .fontSize(13)
        .fillColor(WARNA_LAPORAN.teks)
        .text(teksAman(judul), kiri + lebar * 0.45, atas, {
            width: lebar * 0.55,
            align: "right",
        });
    if (subjudul) {
        doc.font(FONT.regular)
            .fontSize(9)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(subjudul), kiri + lebar * 0.45, atas + 22, {
                width: lebar * 0.55,
                align: "right",
            });
    }

    const garisY = atas + 54;
    doc.strokeColor(WARNA_LAPORAN.garis)
        .lineWidth(1)
        .moveTo(kiri, garisY)
        .lineTo(kiri + lebar, garisY)
        .stroke();
    doc.x = kiri;
    doc.y = garisY + 18;
};

export const tulisJudulBagian = (doc, judul, opsi = {}) => {
    pastikanRuang(doc, 38, opsi.saatHalamanBaru);
    const kiri = doc.page.margins.left;
    const y = doc.y;

    doc.save()
        .fillColor(WARNA_LAPORAN.utama)
        .roundedRect(kiri, y + 1, 4, 17, 2)
        .fill()
        .restore();
    doc.font(FONT.bold)
        .fontSize(12)
        .fillColor(WARNA_LAPORAN.teks)
        .text(teksAman(judul), kiri + 12, y, { lineBreak: false });
    doc.x = kiri;
    doc.y = y + 29;
};

export const tulisKartuRingkasan = (doc, items, opsi = {}) => {
    if (!Array.isArray(items) || items.length === 0 || items.length > 4) {
        throw new TypeError("Kartu ringkasan harus berisi 1 sampai 4 item");
    }

    const tinggi = 64;
    pastikanRuang(doc, tinggi + 16, opsi.saatHalamanBaru);
    const kiri = doc.page.margins.left;
    const lebarKonten = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const jarak = 10;
    const lebarKartu = (lebarKonten - jarak * (items.length - 1)) / items.length;
    const y = doc.y;

    items.forEach((item, index) => {
        const x = kiri + index * (lebarKartu + jarak);
        doc.save()
            .fillColor(WARNA_LAPORAN.aksen)
            .strokeColor(WARNA_LAPORAN.garis)
            .roundedRect(x, y, lebarKartu, tinggi, 6)
            .fillAndStroke()
            .restore();
        doc.font(FONT.bold)
            .fontSize(17)
            .fillColor(WARNA_LAPORAN.utamaGelap)
            .text(teksAman(item.nilai), x + 10, y + 12, {
                width: lebarKartu - 20,
                align: "center",
                lineBreak: false,
            });
        doc.font(FONT.regular)
            .fontSize(8.5)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(item.label), x + 8, y + 39, {
                width: lebarKartu - 16,
                align: "center",
                lineBreak: false,
            });
    });

    doc.x = kiri;
    doc.y = y + tinggi + 16;
};

export const tulisBadge = (doc, { x, y, teks, kategori = "rendah" }) => {
    const warna = WARNA_LAPORAN[kategori] || WARNA_LAPORAN.utama;
    const label = teksAman(teks);
    doc.font(FONT.bold).fontSize(8.5);
    const lebar = Math.max(58, doc.widthOfString(label) + 18);
    const tinggi = 20;

    doc.save()
        .fillColor(warna)
        .roundedRect(x, y, lebar, tinggi, 10)
        .fill()
        .restore();
    doc.font(FONT.bold)
        .fontSize(8.5)
        .fillColor(WARNA_LAPORAN.putih)
        .text(label, x + 9, y + 6, {
            width: lebar - 18,
            align: "center",
            lineBreak: false,
        });
    return { lebar, tinggi };
};

const validasiKolom = (doc, columns) => {
    if (!Array.isArray(columns) || columns.length === 0) {
        throw new TypeError("Kolom tabel wajib tersedia");
    }
    for (const column of columns) {
        if (!column.key || !column.label || !Number.isFinite(column.width) || column.width <= 0) {
            throw new TypeError("Definisi kolom tabel tidak valid");
        }
    }
    const totalLebar = columns.reduce((total, column) => total + column.width, 0);
    const lebarKonten = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    if (totalLebar > lebarKonten + 0.01) {
        throw new RangeError("Lebar kolom tabel melebihi area konten PDF");
    }
    return totalLebar;
};

const teksCell = (column, row) => {
    const raw = typeof column.format === "function"
        ? column.format(row[column.key], row)
        : row[column.key];
    const hasil = teksAman(raw);
    return hasil.length > 220 ? `${hasil.slice(0, 217)}...` : hasil;
};

export const tulisTabel = (doc, {
    columns,
    rows,
    saatHalamanBaru,
    teksKosong = "Tidak ada data.",
} = {}) => {
    if (!Array.isArray(rows)) throw new TypeError("Baris tabel wajib berupa array");
    const totalLebar = validasiKolom(doc, columns);
    const kiri = doc.page.margins.left;
    const tinggiHeader = 28;
    const padding = UKURAN.paddingCell;

    const gambarHeader = () => {
        pastikanRuang(doc, tinggiHeader + 28, saatHalamanBaru);
        let x = kiri;
        const y = doc.y;
        for (const column of columns) {
            doc.save()
                .fillColor(WARNA_LAPORAN.utama)
                .rect(x, y, column.width, tinggiHeader)
                .fill()
                .restore();
            doc.font(FONT.bold)
                .fontSize(8.5)
                .fillColor(WARNA_LAPORAN.putih)
                .text(teksAman(column.label), x + padding, y + 9, {
                    width: column.width - padding * 2,
                    align: column.align || "left",
                    lineBreak: false,
                });
            x += column.width;
        }
        doc.x = kiri;
        doc.y = y + tinggiHeader;
    };

    gambarHeader();

    rows.forEach((row, rowIndex) => {
        const values = columns.map((column) => teksCell(column, row));
        doc.font(FONT.regular).fontSize(8.5);
        const tinggiTeks = Math.max(...values.map((value, index) =>
            doc.heightOfString(value, {
                width: columns[index].width - padding * 2,
                align: columns[index].align || "left",
            }),
        ));
        const tinggiBaris = Math.max(27, tinggiTeks + padding * 2);

        if (doc.y + tinggiBaris > batasBawahKonten(doc)) {
            doc.addPage();
            if (typeof saatHalamanBaru === "function") saatHalamanBaru(doc);
            gambarHeader();
        }

        let x = kiri;
        const y = doc.y;
        const warnaLatar = rowIndex % 2 === 0
            ? WARNA_LAPORAN.putih
            : WARNA_LAPORAN.latarBaris;

        columns.forEach((column, columnIndex) => {
            doc.save()
                .fillColor(warnaLatar)
                .strokeColor(WARNA_LAPORAN.garis)
                .lineWidth(0.5)
                .rect(x, y, column.width, tinggiBaris)
                .fillAndStroke()
                .restore();
            doc.font(FONT.regular)
                .fontSize(8.5)
                .fillColor(WARNA_LAPORAN.teks)
                .text(values[columnIndex], x + padding, y + padding, {
                    width: column.width - padding * 2,
                    height: tinggiBaris - padding * 2,
                    align: column.align || "left",
                    ellipsis: true,
                });
            x += column.width;
        });

        doc.x = kiri;
        doc.y = y + tinggiBaris;
    });

    if (rows.length === 0) {
        doc.font(FONT.regular)
            .fontSize(9)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(teksKosong), kiri, doc.y + 10, {
                width: totalLebar,
                align: "center",
            });
    }

    doc.x = kiri;
    doc.y += 14;
};

const tulisFooterSemuaHalaman = (doc, teksFooter) => {
    const range = doc.bufferedPageRange();
    const totalHalaman = range.count;

    for (let index = range.start; index < range.start + range.count; index++) {
        doc.switchToPage(index);
        const kiri = doc.page.margins.left;
        const lebar = doc.page.width - doc.page.margins.left - doc.page.margins.right;
        // Footer ditempatkan pada ruang yang telah dicadangkan, tetapi tetap di
        // atas batas bottom margin PDFKit agar penulisan teks tidak memicu
        // penambahan halaman kosong saat finalisasi.
        const y = doc.page.height - doc.page.margins.bottom - 16;

        doc.save()
            .strokeColor(WARNA_LAPORAN.garis)
            .lineWidth(0.5)
            .moveTo(kiri, y - 9)
            .lineTo(kiri + lebar, y - 9)
            .stroke()
            .restore();
        doc.font(FONT.regular)
            .fontSize(7.5)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(teksFooter), kiri, y, {
                width: lebar * 0.72,
                lineBreak: false,
            });
        doc.text(`Halaman ${index - range.start + 1} dari ${totalHalaman}`, kiri, y, {
            width: lebar,
            align: "right",
            lineBreak: false,
        });
    }
};

export const finalisasiPdf = (doc, {
    teksFooter = "Dokumen dibuat secara otomatis oleh Tumbuh Posyandu",
} = {}) => new Promise((resolve, reject) => {
    const chunks = [];
    doc.on("data", (chunk) => chunks.push(chunk));
    doc.once("end", () => resolve(Buffer.concat(chunks)));
    doc.once("error", reject);

    tulisFooterSemuaHalaman(doc, teksFooter);
    doc.end();
});
