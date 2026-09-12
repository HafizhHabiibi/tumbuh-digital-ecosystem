# Evidence — Documentation Final Review

Tanggal verifikasi: **12 September 2026**  
Branch: **`release/final-review`**  
Scope: **dokumentasi final proyek akhir local-first, Web + Android, database fresh**

## 1. Hasil quality gate

| Komponen | Command | Hasil |
|---|---|---|
| Backend | `npm test` | 262 pass, 0 fail |
| Web | `npm run check` | ESLint pass, 68 test pass, production build pass |
| Flutter | format check, `flutter analyze`, `flutter test`, debug APK build | 0 perubahan format, analyzer 0 issue, 126 test pass, APK berhasil dibuat |
| WHO converter | `npm run generate` dan `npm test` | 10 tabel berhasil dibuat tanpa diff output; 4 pass, 0 fail |

Build Android menghasilkan warning migrasi Built-in Kotlin untuk project/plugin `file_saver`. Build tetap berhasil dan warning tersebut tetap dicatat sebagai `KI-019`, bukan disamarkan sebagai selesai.

## 2. Audit dokumentasi

| Pemeriksaan | Hasil |
|---|---|
| File Markdown di luar dependency/build output | 44 |
| Broken local link | 0 |
| File URI absolut | 0 |
| Code fence tidak seimbang | 0 |
| Baris tabel aktif dengan jumlah kolom tidak konsisten | 0 |
| Script npm terdokumentasi tetapi tidak tersedia di manifest | 0 |
| Path komponen legacy pada panduan aktif | 0 setelah redaksi plan dinormalisasi |
| Perintah build IPA aktif | 0 |
| Istilah role/domain yang tidak konsisten | 0; `orangtua` tanpa spasi hanya muncul sebagai bagian email fixture |
| ID Known Issues duplikat | 0 setelah item maintainability/performance dinormalisasi menjadi `KI-022`/`KI-023` |
| Actual `.env` yang terlacak Git | 0 |
| Private key/pola AWS access key pada file terlacak | 0 |

Satu pola Firebase client API key berada pada `tumbuhapp/android/app/google-services.json`. File tersebut adalah client configuration, bukan service-account private key. Restriction package/SHA/API pada provider console belum diverifikasi dan tetap dicatat sebagai `KI-020`.

## 3. Struktur yang diverifikasi

- README root dan empat README komponen tersedia.
- Tujuh dokumen inti root tersedia dan tertaut dari indeks.
- Tujuh contract/policy backend aktif serta satu release checklist tetap berada di folder utama.
- Sembilan dokumen historis berlabel jelas berada di `backend-express/docs/archive/` dan tidak di-ignore Git.
- Governance, known issues, risk acceptance, dan evidence memiliki indeks release sendiri.

## 4. Batas verifikasi

`npm run db:setup` tidak dijalankan pada final review dokumentasi karena command me-reset tabel dan tidak diperlukan untuk membuktikan perubahan docs. Sebagai gantinya dijalankan seluruh quality gate tanpa mutasi database. Manual UAT tiga role serta integrasi MySQL/SMTP/Turnstile/Gemini/FCM nyata tetap mengikuti [Known Issues](../KNOWN_ISSUES.md).

Evidence ini membuktikan verifikasi teknis dokumentasi. Persetujuan isi dan struktur akhir tetap menjadi keputusan Project Author.
