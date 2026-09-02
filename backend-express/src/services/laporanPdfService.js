import PDFDocument from "pdfkit";

export const WARNA_LAPORAN = Object.freeze({
    teks: "#1A1A1A",
    teksSekunder: "#555555",
    garis: "#333333",
    garisRingan: "#CCCCCC",
    latarHeader: "#E8E8E8",
    latarBaris: "#F7F7F7",
    latarCatatan: "#F5F5F5",
    putih: "#FFFFFF",
    rendah: "#2E7D32",
    sedang: "#1565C0",
    tinggi: "#C62828",
});

const FONT = Object.freeze({
    regular: "Helvetica",
    bold: "Helvetica-Bold",
});

const UKURAN = Object.freeze({
    margin: 48,
    footer: 28,
    paddingCell: 6,
});

const teksAman = (value) => String(value ?? "-")
    .replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "")
    .trim() || "-";

const formatAngkaPdf = (value) => new Intl.NumberFormat("id-ID", {
    maximumFractionDigits: 2,
}).format(Number(value));

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

/**
 * Kop surat: Nama Posyandu centered bold, Puskesmas di bawah, garis tebal,
 * lalu judul dan subjudul centered.
 */
export const tulisHeaderLaporan = (doc, {
    nama_posyandu = "Posyandu",
    nama_puskesmas = "Puskesmas",
    judul,
    subjudul = null,
} = {}) => {
    const kiri = doc.page.margins.left;
    const lebar = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const atas = doc.page.margins.top;

    // Nama posyandu centered
    doc.font(FONT.bold)
        .fontSize(14)
        .fillColor(WARNA_LAPORAN.teks)
        .text(teksAman(nama_posyandu).toUpperCase(), kiri, atas, {
            width: lebar,
            align: "center",
        });

    // Nama puskesmas centered
    doc.font(FONT.regular)
        .fontSize(10)
        .fillColor(WARNA_LAPORAN.teksSekunder)
        .text(teksAman(nama_puskesmas), kiri, doc.y + 2, {
            width: lebar,
            align: "center",
        });

    // Garis separator tebal
    const garisY = doc.y + 8;
    doc.strokeColor(WARNA_LAPORAN.garis)
        .lineWidth(1.5)
        .moveTo(kiri, garisY)
        .lineTo(kiri + lebar, garisY)
        .stroke();

    // Judul laporan
    if (judul) {
        doc.font(FONT.bold)
            .fontSize(12)
            .fillColor(WARNA_LAPORAN.teks)
            .text(teksAman(judul), kiri, garisY + 10, {
                width: lebar,
                align: "center",
            });
    }

    // Subjudul (tanggal, periode, dll.)
    if (subjudul) {
        doc.font(FONT.regular)
            .fontSize(9)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(subjudul), kiri, doc.y + 2, {
                width: lebar,
                align: "center",
            });
    }

    doc.x = kiri;
    doc.y = doc.y + 16;
};

/**
 * Judul bagian: teks bold saja dengan spasi atas yang cukup.
 */
export const tulisJudulBagian = (doc, judul, opsi = {}) => {
    pastikanRuang(doc, 36, opsi.saatHalamanBaru);
    const kiri = doc.page.margins.left;

    const y = doc.y + 6;
    doc.font(FONT.bold)
        .fontSize(11)
        .fillColor(WARNA_LAPORAN.teks)
        .text(teksAman(judul), kiri, y, {
            width: doc.page.width - doc.page.margins.right - kiri,
        });
    doc.x = kiri;
    doc.y = doc.y + 8;
};

/**
 * Key-value list: format "Label : Nilai" rata kiri, tanpa border.
 */
export const tulisKeyValue = (doc, items, saatHalamanBaru) => {
    if (!Array.isArray(items) || items.length === 0) return;

    const kiri = doc.page.margins.left;
    const lebarKonten = doc.page.width - doc.page.margins.right - kiri;
    const lebarLabel = Math.min(132, lebarKonten * 0.3);
    const jarak = 10;
    const lebarNilai = lebarKonten - lebarLabel - jarak;

    for (const item of items) {
        const label = `${teksAman(item.label)}:`;
        const nilai = teksAman(item.nilai);
        doc.font(FONT.bold).fontSize(8.5);
        const tinggiLabel = doc.heightOfString(label, { width: lebarLabel });
        doc.font(FONT.regular).fontSize(9);
        const tinggiNilai = doc.heightOfString(nilai, { width: lebarNilai });
        const tinggiBaris = Math.max(14, tinggiLabel, tinggiNilai) + 5;

        pastikanRuang(doc, tinggiBaris, saatHalamanBaru);
        const y = doc.y;

        doc.font(FONT.bold)
            .fontSize(8.5)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(label, kiri, y, {
                width: lebarLabel,
            });
        doc.font(FONT.regular)
            .fontSize(9)
            .fillColor(WARNA_LAPORAN.teks)
            .text(nilai, kiri + lebarLabel + jarak, y, {
                width: lebarNilai,
            });

        doc.x = kiri;
        doc.y = y + tinggiBaris;
    }

    doc.y += 4;
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
    return teksAman(raw);
};

/**
 * Tabel formal: header beraksen lembut, garis horizontal antar baris, dan isi
 * membungkus tanpa pemotongan karakter.
 */
export const tulisTabel = (doc, {
    columns,
    rows,
    saatHalamanBaru,
    teksKosong = "Tidak ada data.",
} = {}) => {
    if (!Array.isArray(rows)) throw new TypeError("Baris tabel wajib berupa array");
    const totalLebar = validasiKolom(doc, columns);
    const kiri = doc.page.margins.left;
    const padding = UKURAN.paddingCell;
    doc.font(FONT.bold).fontSize(8);
    const tinggiHeader = Math.max(
        24,
        ...columns.map((column) => doc.heightOfString(teksAman(column.label), {
            width: column.width - padding * 2,
            align: column.align || "left",
        }) + padding * 2),
    );

    const gambarHeader = () => {
        pastikanRuang(doc, tinggiHeader + 24, saatHalamanBaru);
        let x = kiri;
        const y = doc.y;

        // Header background dengan aksen merek yang lembut.
        doc.save()
            .fillColor(WARNA_LAPORAN.latarHeader)
            .rect(kiri, y, totalLebar, tinggiHeader)
            .fill()
            .restore();

        // Garis atas dan bawah header
        doc.save()
            .strokeColor(WARNA_LAPORAN.garisRingan)
            .lineWidth(0.5)
            .moveTo(kiri, y)
            .lineTo(kiri + totalLebar, y)
            .moveTo(kiri, y + tinggiHeader)
            .lineTo(kiri + totalLebar, y + tinggiHeader)
            .stroke()
            .restore();

        for (const column of columns) {
            doc.font(FONT.bold)
                .fontSize(8)
                .fillColor(WARNA_LAPORAN.teks)
                .text(teksAman(column.label), x + padding, y + 7, {
                    width: column.width - padding * 2,
                    align: column.align || "left",
                });
            x += column.width;
        }
        doc.x = kiri;
        doc.y = y + tinggiHeader;
    };

    gambarHeader();

    rows.forEach((row, rowIndex) => {
        const values = columns.map((column) => teksCell(column, row));
        doc.font(FONT.regular).fontSize(8);
        const tinggiTeks = Math.max(...values.map((value, index) =>
            doc.heightOfString(value, {
                width: columns[index].width - padding * 2,
                align: columns[index].align || "left",
            }),
        ));
        const tinggiBaris = Math.max(22, tinggiTeks + padding * 2);

        if (doc.y + tinggiBaris > batasBawahKonten(doc)) {
            doc.addPage();
            if (typeof saatHalamanBaru === "function") saatHalamanBaru(doc);
            gambarHeader();
        }

        let x = kiri;
        const y = doc.y;

        // Background baris genap
        if (rowIndex % 2 === 1) {
            doc.save()
                .fillColor(WARNA_LAPORAN.latarBaris)
                .rect(kiri, y, totalLebar, tinggiBaris)
                .fill()
                .restore();
        }

        columns.forEach((column, columnIndex) => {
            doc.font(FONT.regular)
                .fontSize(8)
                .fillColor(WARNA_LAPORAN.teks)
                .text(values[columnIndex], x + padding, y + padding, {
                    width: column.width - padding * 2,
                    height: tinggiBaris - padding * 2,
                    align: column.align || "left",
                });
            x += column.width;
        });

        // Garis bawah baris
        doc.save()
            .strokeColor(WARNA_LAPORAN.garisRingan)
            .lineWidth(0.25)
            .moveTo(kiri, y + tinggiBaris)
            .lineTo(kiri + totalLebar, y + tinggiBaris)
            .stroke()
            .restore();

        doc.x = kiri;
        doc.y = y + tinggiBaris;
    });

    if (rows.length === 0) {
        doc.font(FONT.regular)
            .fontSize(9)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(teksKosong), kiri, doc.y + 8, {
                width: totalLebar,
                align: "center",
            });
    }

    doc.x = kiri;
    doc.y += 10;
};

/** Paragraf catatan dengan aksen ringan dan isi yang membungkus penuh. */
export const tulisCatatan = (doc, { judul, isi }, saatHalamanBaru) => {
    const isiAman = teksAman(isi);
    const judulAman = judul ? teksAman(judul) : null;
    const lebar = doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const kiri = doc.page.margins.left;
    const paddingX = 12;
    const lebarIsi = lebar - paddingX * 2 - 3;

    doc.font(FONT.regular).fontSize(8.5);
    const tinggiIsi = doc.heightOfString(isiAman, { width: lebarIsi });
    doc.font(FONT.bold).fontSize(9);
    const tinggiJudul = judulAman
        ? doc.heightOfString(judulAman, { width: lebarIsi }) + 5
        : 0;
    const tinggi = tinggiIsi + tinggiJudul + 18;

    pastikanRuang(doc, tinggi + 8, saatHalamanBaru);
    const y = doc.y;

    doc.save()
        .fillColor(WARNA_LAPORAN.latarCatatan)
        .roundedRect(kiri, y, lebar, tinggi, 4)
        .fill()
        .restore();

    let posisiY = y + 9;

    if (judulAman) {
        doc.font(FONT.bold)
            .fontSize(9)
            .fillColor(WARNA_LAPORAN.teks)
            .text(judulAman, kiri + paddingX, posisiY, { width: lebarIsi });
        posisiY = doc.y + 4;
    }
    doc.font(FONT.regular)
        .fontSize(8.5)
        .fillColor(WARNA_LAPORAN.teksSekunder)
        .text(isiAman, kiri + paddingX, posisiY, { width: lebarIsi });

    doc.x = kiri;
    doc.y = y + tinggi + 8;
};

/**
 * Donut chart sederhana menggunakan path vektor.
 * @param {object} doc - Dokumen PDFKit
 * @param {object} opsi
 * @param {Array<{label: string, nilai: number, warna: string}>} opsi.data
 * @param {string} [opsi.judul] - Judul di atas chart
 * @param {function} [opsi.saatHalamanBaru]
 */
export const tulisPieChart = (doc, {
    data,
    judul,
    saatHalamanBaru,
} = {}) => {
    if (!Array.isArray(data) || data.length === 0) return;

    const dataValid = data.map((item) => {
        const nilai = Number(item.nilai);
        if (!Number.isFinite(nilai) || nilai < 0) {
            throw new TypeError("Nilai pie chart harus berupa angka non-negatif");
        }
        return {
            label: teksAman(item.label),
            nilai,
            warna: item.warna || WARNA_LAPORAN.garisRingan,
        };
    });

    const tinggiChart = 150;
    const radius = 60;
    pastikanRuang(doc, tinggiChart + 40, saatHalamanBaru);

    const kiri = doc.page.margins.left;
    const lebar = doc.page.width - doc.page.margins.left - doc.page.margins.right;

    if (judul) {
        doc.font(FONT.bold)
            .fontSize(10)
            .fillColor(WARNA_LAPORAN.teks)
            .text(teksAman(judul), kiri, doc.y, { width: lebar });
        doc.y += 4;
    }

    const cx = kiri + radius + 20;
    const cy = doc.y + radius + 10;
    const total = dataValid.reduce((sum, item) => sum + item.nilai, 0);

    if (total === 0) {
        // Lingkaran kosong
        doc.save()
            .strokeColor(WARNA_LAPORAN.garisRingan)
            .lineWidth(1)
            .circle(cx, cy, radius)
            .stroke()
            .restore();
        doc.font(FONT.regular)
            .fontSize(8)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text("Tidak ada data", cx - 30, cy - 4);
    } else {
        let sudutMulai = -Math.PI / 2; // mulai dari atas (jam 12)

        for (const item of dataValid) {
            const proporsi = item.nilai / total;
            if (proporsi <= 0) continue;

            const sudutAkhir = sudutMulai + proporsi * 2 * Math.PI;

            // Gambar sector menggunakan moveTo + lineTo + arc
            doc.save();
            doc.fillColor(item.warna);

            doc.moveTo(cx, cy);
            doc.lineTo(
                cx + radius * Math.cos(sudutMulai),
                cy + radius * Math.sin(sudutMulai),
            );

            // Arc: gambar titik-titik sepanjang busur
            const steps = Math.max(20, Math.ceil(proporsi * 100));
            for (let i = 1; i <= steps; i++) {
                const sudut = sudutMulai + (sudutAkhir - sudutMulai) * (i / steps);
                doc.lineTo(
                    cx + radius * Math.cos(sudut),
                    cy + radius * Math.sin(sudut),
                );
            }

            doc.lineTo(cx, cy);
            doc.fill();
            doc.restore();

            sudutMulai = sudutAkhir;
        }

        // Lubang tengah membentuk donut dan menampilkan total data.
        doc.save()
            .fillColor(WARNA_LAPORAN.putih)
            .circle(cx, cy, radius * 0.54)
            .fill()
            .restore();
        doc.font(FONT.bold)
            .fontSize(14)
            .fillColor(WARNA_LAPORAN.teks)
            .text(formatAngkaPdf(total), cx - 30, cy - 9, {
                width: 60,
                align: "center",
                lineBreak: false,
            });
        doc.font(FONT.regular)
            .fontSize(7)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text("Total", cx - 30, cy + 8, {
                width: 60,
                align: "center",
                lineBreak: false,
            });
    }

    // Legenda di sebelah kanan
    const legendaX = cx + radius + 40;
    let legendaY = cy - (dataValid.length * 18) / 2;
    const lebarLegenda = lebar - (legendaX - kiri);

    for (const item of dataValid) {
        // Kotak warna
        doc.save()
            .fillColor(item.warna)
            .rect(legendaX, legendaY + 2, 10, 10)
            .fill()
            .restore();

        const proporsi = total > 0
            ? (item.nilai / total * 100).toFixed(1)
            : "0.0";

        doc.font(FONT.regular)
            .fontSize(8.5)
            .fillColor(WARNA_LAPORAN.teks)
            .text(
                `${item.label}: ${formatAngkaPdf(item.nilai)} (${proporsi}%)`,
                legendaX + 16,
                legendaY + 1,
                { width: lebarLegenda - 16, lineBreak: false },
            );

        legendaY += 18;
    }

    doc.x = kiri;
    doc.y = cy + radius + 20;
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

        // Garis separator footer
        doc.save()
            .strokeColor(WARNA_LAPORAN.garisRingan)
            .lineWidth(0.5)
            .moveTo(kiri, y - 6)
            .lineTo(kiri + lebar, y - 6)
            .stroke()
            .restore();

        // Disclaimer di kiri
        doc.font(FONT.regular)
            .fontSize(7)
            .fillColor(WARNA_LAPORAN.teksSekunder)
            .text(teksAman(teksFooter), kiri, y, {
                width: lebar * 0.7,
                lineBreak: false,
            });

        // Halaman di kanan
        doc.text(
            `Halaman ${index - range.start + 1} dari ${totalHalaman}`,
            kiri,
            y,
            {
                width: lebar,
                align: "right",
                lineBreak: false,
            },
        );
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
