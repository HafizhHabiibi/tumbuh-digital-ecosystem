# Risk Acceptance — Residual UUID pada WHO Converter

Issue: `KI-002`  
Tanggal: **12 September 2026**  
Owner/approver: **Project Author**  
Status: **Accepted untuk final review lokal**

## Risiko

`npm audit` melaporkan dua moderate vulnerability karena `exceljs@4.4.0` bergantung pada `uuid@8.3.2`. Advisory berkaitan dengan missing buffer bounds check pada API UUID v3/v5/v6.

Perbaikan otomatis penuh menawarkan `npm audit fix --force` yang akan menurunkan ExcelJS ke 3.4.0. Perubahan tersebut bersifat breaking dan meningkatkan risiko perubahan parser spreadsheet serta output antropometri pada masa feature freeze.

## Exposure analysis

- WHO converter bukan bagian dari backend, web, atau mobile runtime.
- Tool dijalankan manual/offline oleh Project Author.
- Input dibatasi pada 10 file Excel WHO yang telah disimpan dan diverifikasi di repository.
- Source Excel tidak berasal dari upload pengguna atau jaringan pada saat converter berjalan.
- Pencarian pada ExcelJS menunjukkan penggunaan runtime di jalur terkait memakai `uuid.v4()`, bukan API v3/v5/v6 dengan caller-provided buffer yang terdampak advisory.
- Output yang dihasilkan setelah update memiliki checksum Git yang identik dengan baseline.

## Keputusan

Residual moderate diterima untuk scope final review lokal. Downgrade/force fix tidak diterapkan.

## Mitigasi wajib

- Jangan gunakan converter untuk file Excel tidak tepercaya.
- Jangan mengekspos converter sebagai endpoint, upload service, atau automated public worker.
- Pertahankan `whoTables.json` yang telah diverifikasi sebagai source runtime backend.
- Jalankan `npm audit` ulang sebelum memakai converter pada workflow publik.
- Evaluasi pengganti/upgrade ExcelJS ketika versi upstream yang kompatibel telah menghapus dependency UUID lama.

## Masa berlaku

Acceptance berakhir ketika salah satu kondisi berikut terjadi:

- converter menerima input dari pengguna/pihak ketiga;
- converter dijalankan sebagai service atau CI pada data dinamis;
- advisory berubah menjadi high/critical;
- tersedia upgrade ExcelJS kompatibel yang menghapus dependency terdampak;
- project dipersiapkan untuk public production release.
