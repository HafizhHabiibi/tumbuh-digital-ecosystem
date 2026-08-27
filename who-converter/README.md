<div align="center">

# WHO Growth Standards Converter

### Excel → JSON Conversion Tool

[![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![ExcelJS](https://img.shields.io/badge/ExcelJS-4.4-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)](https://www.npmjs.com/package/exceljs)
[![WHO](https://img.shields.io/badge/WHO-Child%20Growth%20Standards-009CDE?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0tMSAxNy45M2MtMy45NS0uNDktNy0zLjg1LTctNy45MyAwLS42Mi4wOC0xLjIxLjIxLTEuNzlMOSAxNXY1Ljkzek0xMyAxOS45M1YxNGg1bDMuMjQtMy4yNGMuMzQuNTguNTQgMS4yMy42MyAxLjkxIDAgMy4yLTIuMDYgNS45OC01LjA3IDcuMjZ6Ii8+PC9zdmc+)](https://www.who.int/tools/child-growth-standards/standards)
[![License](https://img.shields.io/badge/License-Academic-F5A623?style=for-the-badge)](#lisensi)

<br/>

**Konversi data [WHO Child Growth Standards](https://www.who.int/tools/child-growth-standards/standards) dari format Excel (.xlsx) menjadi satu file JSON yang siap digunakan oleh aplikasi backend untuk menghitung Z-Score pertumbuhan anak usia 0–60 bulan.**

<br/>

```
┌──────────────────────┐       ┌──────────────┐       ┌──────────────────────┐
│  📁 10 File Excel    │──────▶│  🔄 convert  │──────▶│  📄 whoTables.json   │
│  (WHO Z-Score Tables)│       │     .js      │       │  (L, M, S per index) │
└──────────────────────┘       └──────────────┘       └──────────────────────┘
```

</div>


---

## Daftar Isi

- [Prasyarat](#prasyarat)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [Sumber Data](#sumber-data)
- [Indikator yang Diproses](#indikator-yang-diproses)
- [Format Output](#format-output)
- [Parameter L, M, S](#parameter-l-m-s)
- [Rumus Z-Score](#rumus-z-score)
- [Struktur Project](#struktur-project)
- [Utility](#utility)
- [Lisensi](#lisensi)

---

## Prasyarat

- [Node.js](https://nodejs.org/) versi 18 atau lebih baru
- npm (bawaan Node.js)

## Instalasi

```bash
git clone <repository-url>
cd who-converter
npm install
```

## Penggunaan

Jalankan script converter:

```bash
node convert.js
```

Output file `whoTables.json` akan dibuat di root directory. Copy file ini ke project backend Anda, misalnya:

```bash
cp whoTables.json ../backend/src/constants/
```

---

## Sumber Data

Seluruh file Excel sumber berada di direktori `who-data/` dan diunduh langsung dari:

> **WHO Child Growth Standards**
> https://www.who.int/tools/child-growth-standards/standards

File-file tersebut merupakan **Z-Score Expanded Tables** resmi yang dipublikasikan oleh WHO.

| File | Deskripsi |
|------|-----------|
| `wfa-boys-zscore-expanded-tables.xlsx` | Weight-for-Age — Laki-laki |
| `wfa-girls-zscore-expanded-tables.xlsx` | Weight-for-Age — Perempuan |
| `lhfa-boys-zscore-expanded-tables.xlsx` | Length/Height-for-Age — Laki-laki |
| `lhfa-girls-zscore-expanded-tables.xlsx` | Length/Height-for-Age — Perempuan |
| `wfl-boys-zscore-expanded-tables.xlsx` | Weight-for-Length — Laki-laki |
| `wfl-girls-zscore-expanded-tables.xlsx` | Weight-for-Length — Perempuan |
| `wfh-boys-zscore-expanded-tables.xlsx` | Weight-for-Height — Laki-laki |
| `wfh-girls-zscore-expanded-tables.xlsx` | Weight-for-Height — Perempuan |
| `bfa-boys-zscore-expanded-tables.xlsx` | BMI-for-Age — Laki-laki |
| `bfa-girls-zscore-expanded-tables.xlsx` | BMI-for-Age — Perempuan |

---

## Indikator yang Diproses

| # | Singkatan WHO | Indikator | Referensi | Keterangan |
|---|---------------|-----------|-----------|------------|
| 1 | **wfa** | Weight-for-Age | Umur (bulan) | Berat badan menurut umur |
| 2 | **lhfa** | Length/Height-for-Age | Umur (bulan) | Panjang/tinggi badan menurut umur |
| 3 | **wfl** | Weight-for-Length | Panjang badan (cm) | BB menurut PB — anak berbaring (0–24 bulan) |
| 4 | **wfh** | Weight-for-Height | Tinggi badan (cm) | BB menurut TB — anak berdiri (24–60 bulan) |
| 5 | **bfa** | BMI-for-Age | Umur (bulan) | Indeks Massa Tubuh menurut umur |

Setiap indikator dipisah berdasarkan jenis kelamin: `_boys` (laki-laki) dan `_girls` (perempuan).

---

## Format Output

File `whoTables.json` berisi **10 dataset** dengan struktur sebagai berikut:

### Indikator berbasis umur (`wfa`, `lhfa`, `bfa`)

```json
{
  "wfa_boys": [
    { "month": 0, "L": 0.3487, "M": 3.3464, "S": 0.14602 },
    { "month": 1, "L": 0.2303, "M": 4.4525, "S": 0.13413 },
    ...
    { "month": 60, "L": ..., "M": ..., "S": ... }
  ]
}
```

> Data asli WHO disimpan **per hari** (0–1856 hari). Converter ini mengambil representasi **per bulan** (0–60) menggunakan konversi _nearest neighbor_ dengan rumus: `hari = bulan × 30.4375` (rata-rata hari/bulan dalam setahun).

### Indikator berbasis pengukuran fisik (`wfl`, `wfh`)

```json
{
  "wfl_boys": [
    { "length": 45.0, "L": ..., "M": ..., "S": ... },
    { "length": 45.1, "L": ..., "M": ..., "S": ... },
    ...
  ],
  "wfh_boys": [
    { "height": 65.0, "L": ..., "M": ..., "S": ... },
    { "height": 65.1, "L": ..., "M": ..., "S": ... },
    ...
  ]
}
```

### Ringkasan Data

| Key | Jumlah Data | Satuan |
|-----|-------------|--------|
| `wfa_boys` / `wfa_girls` | 61 | Bulan (0–60) |
| `lhfa_boys` / `lhfa_girls` | 61 | Bulan (0–60) |
| `bfa_boys` / `bfa_girls` | 61 | Bulan (0–60) |
| `wfl_boys` / `wfl_girls` | 651 | Per 0.1 cm |
| `wfh_boys` / `wfh_girls` | 551 | Per 0.1 cm |

---

## Parameter L, M, S

Setiap baris data mengandung tiga parameter dari **transformasi Box-Cox**:

| Parameter | Nama | Arti |
|-----------|------|------|
| **L** | Lambda | Power dalam transformasi Box-Cox (mengontrol skewness) |
| **M** | Mu | Median — nilai tengah distribusi |
| **S** | Sigma | Koefisien variasi generalized |

---

## Rumus Z-Score

Gunakan parameter L, M, S untuk menghitung Z-Score dari hasil pengukuran anak:

```
Z-Score = ((pengukuran / M)^L − 1) / (L × S)
```

> **Kasus khusus**: Jika `L = 0`, gunakan rumus logaritmik:
> ```
> Z-Score = ln(pengukuran / M) / S
> ```

### Interpretasi Z-Score

| Z-Score | Status Gizi (BB/U) | Status (TB/U) | Status (BB/TB & IMT/U) |
|---------|---------------------|---------------|------------------------|
| < −3 SD | Gizi buruk | Sangat pendek | Gizi buruk |
| −3 s/d < −2 SD | Gizi kurang | Pendek (stunting) | Gizi kurang (wasting) |
| −2 s/d +1 SD | Gizi baik | Normal | Normal |
| > +1 s/d +2 SD | — | Tinggi | Berisiko gizi lebih |
| > +2 SD | Gizi lebih | — | Gizi lebih (overweight) |
| > +3 SD | — | — | Obesitas |

---

## Struktur Project

```
who-converter/
├── README.md               ← Dokumentasi ini
├── package.json             ← Metadata & dependency (exceljs)
├── convert.js               ← Script utama: konversi Excel → JSON
├── cekKolom.js              ← Utility: inspeksi struktur file Excel
├── who-data/                ← Folder berisi file Excel sumber dari WHO
│   ├── wfa-boys-*.xlsx
│   ├── wfa-girls-*.xlsx
│   ├── lhfa-boys-*.xlsx
│   ├── lhfa-girls-*.xlsx
│   ├── wfl-boys-*.xlsx
│   ├── wfl-girls-*.xlsx
│   ├── wfh-boys-*.xlsx
│   ├── wfh-girls-*.xlsx
│   ├── bfa-boys-*.xlsx
│   └── bfa-girls-*.xlsx
└── whoTables.json           ← Output: data JSON siap pakai
```

---

## Utility

### `cekKolom.js`

Script pembantu untuk menginspeksi struktur setiap file Excel — menampilkan nama sheet, kolom header, dan contoh baris data. Berguna untuk debugging:

```bash
node cekKolom.js
```

---

## Lisensi

Data standar pertumbuhan anak © [World Health Organization](https://www.who.int/). Digunakan untuk keperluan akademik dan pengembangan aplikasi kesehatan anak.
