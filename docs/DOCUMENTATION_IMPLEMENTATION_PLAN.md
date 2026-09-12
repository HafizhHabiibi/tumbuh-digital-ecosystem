# Implementation Plan — Finalisasi README dan Dokumentasi

Status: **siap untuk final review**  
Tanggal: **2026-09-12**  
Branch: **`release/final-review`**  
Owner: **Project Author**  
Scope: **proyek akhir lokal, Web + Android, database fresh; iOS roadmap**

## 1. Tujuan

Plan ini merapikan dokumentasi agar pembaca baru dapat memahami, menjalankan, menguji, dan mendemonstrasikan project tanpa membaca source code terlebih dahulu. Pekerjaan tidak menambah fitur, mengubah arsitektur, atau mengejar kelengkapan setingkat operasi production.

Hasil akhirnya:

- root README menjadi pintu masuk utama;
- setiap komponen memiliki README yang akurat dan ringkas;
- folder `docs/` memiliki indeks yang mudah dinavigasi;
- dokumen aktif dipisahkan dari rencana/temuan historis;
- instruksi setup dan command dibuktikan dari repository saat ini;
- tidak ada klaim iOS atau production readiness yang belum dibuktikan.

## 2. Prinsip

1. **Dokumentasikan yang benar-benar ada.** Jangan menjanjikan fitur, platform, atau deployment yang belum tersedia.
2. **Satu sumber kebenaran.** Informasi detail ditulis sekali; dokumen lain memberi ringkasan dan tautan.
3. **Local-first.** Jalur utama adalah Windows/PowerShell, MySQL lokal, Web lokal, dan Android emulator/perangkat lokal.
4. **README ringkas, docs terperinci.** README menjawab apa, cara menjalankan, dan cara menguji.
5. **Riwayat tidak langsung dihapus.** Plan lama dipindahkan ke `archive/` atau diberi label historis setelah link diperiksa.
6. **Command dapat disalin.** Nama folder, script, port, environment variable, dan urutan startup harus sesuai repository.
7. **Tidak ada secret/PII nyata.** Hanya nama variable dan contoh sintetis yang boleh ditulis.

## 3. Kondisi awal

| Area | Kondisi | Tindakan |
|---|---|---|
| Root `README.md` | Sangat singkat; masih menyebut dua nama folder legacy yang tidak ada | Tulis ulang |
| `backend-express/README.md` | Belum tersedia | Buat baru |
| `web-dashboard/README.md` | Masih template Vue/Vite | Ganti seluruhnya |
| `tumbuhapp/README.md` | Setup lokal cukup baik, tetapi iOS/IPA dan klaim workflow perlu diselaraskan | Revisi |
| `who-converter/README.md` | Sudah lengkap; perlu konsistensi command, hubungan project, dan catatan dependency | Revisi ringan |
| Root `docs/` | Berisi finalization/security/release evidence, tetapi belum memiliki indeks | Tambah indeks dan rapikan fungsi |
| `backend-express/docs/` | Kontrak aktif bercampur dengan temuan dan implementation plan selesai | Klasifikasi dan arsipkan history |

## 4. Struktur target

Struktur minimum berikut menghindari pembuatan dokumen berlebihan:

```text
README.md
docs/
├── README.md
├── LOCAL_SETUP.md
├── ARCHITECTURE.md
├── CONFIGURATION.md
├── DATABASE.md
├── TESTING.md
├── USER_GUIDE.md
├── SECURITY_AND_PRIVACY.md
├── DOCUMENTATION_IMPLEMENTATION_PLAN.md
└── release/
    ├── README.md
    ├── GOVERNANCE.md
    ├── KNOWN_ISSUES.md
    ├── risk acceptance
    └── evidence/

backend-express/
├── README.md
└── docs/
    ├── active API/contract/policy documents
    └── archive/
        └── completed plans and old findings

web-dashboard/README.md
tumbuhapp/README.md
who-converter/README.md
```

`docs/README.md` menjadi indeks. Root README tidak menduplikasi isi setup, konfigurasi, database, testing, atau security/privacy.

## 5. Tahap 1 — Inventaris dan klasifikasi

Tujuan: menentukan dokumen aktif, historis, duplikat, atau belum tersedia.

Status: **selesai pada 2026-09-12**. Tidak ada file historis yang dipindahkan atau dihapus pada tahap inventaris.

- [x] Buat `docs/README.md` sebagai indeks awal.
- [x] Catat tujuan dan status setiap dokumen utama.
- [x] Tandai API, kontrak role, kebijakan AI, dan security/privacy sebagai normatif aktif; database/testing root dicatat sebagai dokumen yang belum dibuat.
- [x] Tandai implementation plan selesai sebagai historis.
- [x] Pisahkan checklist manual yang belum selesai sebagai release/UAT evidence.
- [x] Cari folder, command, port, angka test, dan status implementasi yang usang.
- [x] Tentukan sumber kebenaran agar satu topik tidak dijelaskan berbeda di banyak file.

Klasifikasi awal `backend-express/docs/`:

| Kategori | Dokumen |
|---|---|
| Aktif/normatif | `CONVERSATIONAL_AI_API.md`, `CONVERSATIONAL_AI_POLICY.md`, `DATA_TEKNIS_UX_SECURITY_POLICY.md`, `LAPORAN_API.md`, `ORANG_TUA_PENGUKURAN_CONTRACT.md`, `ORANG_TUA_RUJUKAN_CONTRACT.md`, `PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md` |
| Checklist release | `PRIORITAS_PEMANTAUAN_RELEASE_CHECKLIST.md` |
| Historis/candidate archive | seluruh `implementation-plan-*.md`, `Implementation-plan-*.md`, dan `verifikasi_temuan_prioritas.md` |

Acceptance criteria:

- setiap file memiliki kategori jelas;
- belum ada deletion sebelum perbandingan isi dan inbound-link check;
- daftar pada indeks cocok dengan file aktual.

### Hasil inventaris Tahap 1

- Baseline menemukan 32 file Markdown di luar dependency/build output; setelah dua indeks Tahap 1 dibuat, totalnya menjadi 34 file.
- Root README memakai dua nama folder legacy yang tidak sesuai struktur repository.
- Backend belum memiliki README; web README masih template Vite.
- Mobile README masih menempatkan build IPA/iOS pada alur aktif.
- Terdapat 7 kontrak/policy backend aktif, 1 release checklist, 5 plan/temuan historis di `backend-express/docs/`, dan 4 laporan historis yang tercecer di root backend.
- Empat laporan historis di root backend tercantum di `.gitignore`; konsolidasi Tahap 5 harus sekaligus memastikan hasil arsipnya kembali terlacak Git.
- Empat laporan historis di root backend tercantum di `.gitignore`; konsolidasi Tahap 5 harus sekaligus memastikan hasil arsipnya kembali terlacak Git.
- Ditemukan 18 file URI absolut pada `verifikasi_temuan_prioritas.md`; seluruhnya telah diganti dengan tautan relatif saat file dipindahkan menjadi `archive/reports/verifikasi-temuan-prioritas.md` pada Tahap 5.
- Referensi antar dokumen historis hanya ditemukan pada pasangan baseline/fix report dan plan/source finding; mapping ini harus dipertahankan saat pemindahan.
- Evidence lama dengan angka test berbeda dipertahankan sebagai snapshot bertanggal. Status terbaru harus dirujuk dari evidence Workstream C, bukan ditimpa seolah-olah hasil lama salah.
- README aset Xcode di dalam `tumbuhapp/ios` diklasifikasikan sebagai file platform bawaan, bukan dokumentasi project aktif.
- Indeks utama dibuat di `docs/README.md`; indeks khusus kontrak backend dibuat di `backend-express/docs/README.md`.

## 6. Tahap 2 — Root README

Status: **selesai pada 2026-09-12**. Root README telah ditulis ulang berdasarkan manifest, config, schema/seeder, source, dan evidence repository saat ini.

Root `README.md` wajib memuat:

1. nama project dan ringkasan;
2. status proyek akhir dan scope Web + Android lokal;
3. tujuan dan masalah yang diselesaikan;
4. fitur utama per role;
5. arsitektur dan tech stack ringkas;
6. struktur folder dengan nama aktual;
7. prasyarat;
8. quick start database → backend → web → Android;
9. akun demo dan label data sintetis;
10. quality gate ringkas;
11. hasil pengujian terakhir melalui tautan evidence;
12. batasan yang diketahui;
13. indeks dokumentasi;
14. catatan penggunaan akademik/lisensi.

Checklist implementasi:

- [x] Gunakan nama dan struktur folder aktual.
- [x] Nyatakan scope Web + Android lokal, database fresh, dan iOS sebagai roadmap.
- [x] Jelaskan fitur per role dan batas fungsi WHO/SAW/AI.
- [x] Dokumentasikan urutan database → backend → Web → Android.
- [x] Cantumkan akun demo dengan label data sintetis.
- [x] Tautkan quality gate, evidence terakhir, known issues, dan indeks dokumentasi.
- [x] Nyatakan batasan serta status lisensi secara eksplisit.

Aturan:

- jangan menyalin seluruh daftar endpoint;
- jangan menaruh nilai `.env` aktual;
- jangan menyebut project siap production;
- iOS hanya disebut sebagai roadmap.

Acceptance criteria:

- seluruh path dan command benar;
- quick start dapat diikuti dari database fresh;
- perbedaan Web petugas dan Android orang tua jelas;
- semua tautan lokal valid.

## 7. Tahap 3 — README komponen

Status: **selesai pada 2026-09-12**. README backend dibuat; README Web dan Android ditulis ulang; README WHO converter diselaraskan dengan instalasi reproducible, scope mandiri, serta status lisensi repository.

### 3.1 Backend Express

Buat `backend-express/README.md` berisi:

- tanggung jawab backend dan fitur inti;
- prasyarat Node.js/npm/MySQL;
- setup `.env` dari `.env.example`;
- `npm ci`, `npm run db:setup`, `npm run seed:run`, `npm run dev`;
- `/api/health/live` dan `/api/health/ready`;
- ringkasan route group dan matriks role;
- worker FCM, insight, serta cleanup refresh token;
- test, seeder, report preview, dan AI smoke script;
- batas data AI dan tautan API/policy;
- troubleshooting lokal minimum.

Kontrak request/response terperinci tetap berada di `backend-express/docs/`.

### 3.2 Web dashboard

Ganti template Vite dengan:

- fungsi dashboard bagi kader dan puskesmas;
- fitur serta route UI utama;
- konfigurasi `VITE_API_URL` dan Turnstile;
- `npm ci`, `npm run dev`, `npm run check`, `npm run preview`;
- port lokal dan kebutuhan backend;
- ringkasan session lokal/CSP;
- batasan bahwa orang tua tidak login melalui web.

### 3.3 Flutter Android

Revisi README dengan:

- aplikasi khusus role orang tua;
- Android target aktif, iOS roadmap;
- URL emulator `10.0.2.2` dan perangkat fisik/LAN;
- `--dart-define-from-file` yang benar;
- setup Firebase lokal tanpa private credential;
- command run, format, analyze, test, dan debug APK;
- permission/notifikasi dan troubleshooting koneksi;
- hapus IPA dari alur aktif.

### 3.4 WHO converter

Pertahankan materi teknis yang sudah baik, kemudian:

- gunakan `npm ci` untuk install reproducible;
- jelaskan tool berdiri sendiri dan output tidak otomatis disalin;
- verifikasi `npm run generate` dan `npm test`;

Checklist implementasi:

- [x] Buat README backend berdasarkan config, route, worker, script, dan kontrak aktif.
- [x] Ganti README template Web dengan panduan dashboard petugas.
- [x] Fokuskan README Flutter pada Android/orang tua dan pindahkan iOS menjadi roadmap.
- [x] Perjelas instalasi, output mandiri, integritas, dan penggunaan akademik WHO converter.
- [x] Tautkan setiap README ke dokumentasi root yang relevan.
- tautkan dependency risk acceptance;
- cocokkan sumber WHO, jumlah dataset, checksum/evidence;
- sederhanakan dekorasi bila mengganggu pembacaan.

Acceptance criteria tahap 3:

- keempat README memakai istilah/scope yang sama;
- command berasal dari script/config aktual;
- tidak ada klaim CI, release build, iOS, atau provider yang belum terbukti;
- setiap README dapat dibaca mandiri dan tertaut ke root docs.

## 8. Tahap 4 — Dokumen inti root

Status: **selesai pada 2026-09-12**. Enam dokumen inti baru dibuat dan `SECURITY_AND_PRIVACY.md` dipertahankan sebagai sumber utama dengan navigasi yang diperjelas.

### `docs/LOCAL_SETUP.md`

Tool prerequisites, fresh MySQL setup, urutan startup, fixture sintetis, health check, dan troubleshooting koneksi.

### `docs/ARCHITECTURE.md`

Konteks Web/Android/backend/MySQL/Gemini/FCM/SMTP/WHO; data flow pengukuran, prioritas, insight/chat, rujukan, notifikasi, laporan; worker; batas local-first.

### `docs/CONFIGURATION.md`

Variable backend/web/mobile yang wajib, kondisional, dan opsional; contoh aman; emulator/perangkat; perbedaan development dan roadmap production.

### `docs/DATABASE.md`

MySQL, schema fresh, tabel/relasi utama, setup/seeder sintetis, constraint delete, serta migration script yang ada tanpa mengklaim framework lengkap.

### `docs/TESTING.md`

Command per komponen, cakupan otomatis, hal yang belum diuji, manual smoke checklist, dan lokasi evidence.

### `docs/USER_GUIDE.md`

Alur kader, puskesmas, dan orang tua Android; arti status pemantauan; batas AI; urutan demo proyek akhir.

### `docs/SECURITY_AND_PRIVACY.md`

Pertahankan sebagai sumber utama; sederhanakan bagian production yang tidak membantu setup lokal, sementara risk acceptance tetap terpisah.

Acceptance criteria:

- setiap topik hanya punya satu dokumen utama;
- isi sesuai source/config/schema aktual;
- root README menautkan seluruh dokumen inti;
- data sintetis dan larangan data nyata dinyatakan jelas.

Checklist implementasi:

- [x] Buat `LOCAL_SETUP.md` berdasarkan alur database fresh dan config aktual.
- [x] Buat `ARCHITECTURE.md` dengan batas komponen, data flow, integrasi, dan worker.
- [x] Buat `CONFIGURATION.md` untuk backend, Web, Android, dan profil environment.
- [x] Buat `DATABASE.md` berdasarkan schema, seeder, constraint, serta migration script aktual.
- [x] Buat `TESTING.md` dengan automated gate, evidence, manual smoke, CI, dan gap.
- [x] Buat `USER_GUIDE.md` untuk tiga role serta urutan demo akademik.
- [x] Pertahankan `SECURITY_AND_PRIVACY.md` sebagai sumber utama dan pisahkan risk acceptance.
- [x] Tautkan seluruh dokumen inti dari root README dan indeks docs.

## 9. Tahap 5 — Arsip dan release records

Status: **selesai pada 2026-09-12**. Dokumen historis dipisahkan dari kontrak aktif, nama dinormalisasi, tautan diperbarui, dan release records memperoleh indeks khusus.

- [x] Buat `docs/release/README.md` untuk governance, known issues, risk acceptance, dan evidence.
- [x] Pertahankan `FINALIZATION_IMPLEMENTATION_PLAN.md` sebagai record, bukan panduan setup.
- [x] Pindahkan plan backend selesai ke `backend-express/docs/archive/` setelah link diperbarui.
- [x] Arsipkan laporan temuan lama dan beri label “historis—temuan sudah ditangani” bila sesuai.
- [x] Pertahankan contract/policy aktif di lokasi yang mudah ditemukan.
- [x] Gabungkan/hapus hanya dokumen yang benar-benar duplikat setelah review isi.
- [x] Ganti angka test yang mudah usang dengan tautan evidence bila memungkinkan.
- [x] Normalisasi nama file tanpa memutus link.

Hasil konsolidasi:

- empat implementation plan berada di `backend-express/docs/archive/plans/`;
- lima baseline/change/finding report berada di `backend-express/docs/archive/reports/`;
- empat laporan yang sebelumnya di-ignore telah dinormalisasi sehingga lokasi barunya dapat dilacak Git;
- angka test historis dipertahankan sebagai snapshot, sementara header menunjuk ke evidence terbaru;
- tidak ada contract/policy aktif yang dipindahkan dan tidak ada dokumen duplikat yang perlu dihapus.

Acceptance criteria:

- folder aktif tidak didominasi plan lama;
- file yang dipindah tetap tersedia lewat indeks;
- tidak ada broken link;
- Git history menyimpan detail yang tidak perlu muncul di README aktif.

## 10. Tahap 6 — Verifikasi dan final review

Status: **verifikasi teknis selesai pada 2026-09-12; menunggu persetujuan akhir Project Author**. Hasil lengkap berada pada [Documentation Final Review Evidence](./release/evidence/DOCUMENTATION_FINAL_REVIEW.md).

### Verifikasi

- [x] Periksa seluruh link Markdown lokal.
- [x] Cari path folder legacy hasil inventaris.
- [x] Cocokkan command dengan `package.json`, `pubspec.yaml`, config, dan workflow.
- [x] Pastikan contoh environment bebas credential nyata.
- [x] Validasi code fence dan tabel Markdown.
- [x] Samakan istilah orang tua, kader, puskesmas, pengukuran, prioritas, rujukan, dan AI.
- [x] Jalankan quality gate yang dirujuk tanpa me-reset database lokal.
- [x] Jalankan `git diff --check` dan review daftar file pindah.

### Final review owner

- [x] Scope lokal Web + Android konsisten.
- [x] iOS hanya roadmap.
- [x] Akun/data demo dikonfirmasi sintetis.
- [x] Known limitations jujur dan proporsional untuk proyek akhir.
- [x] Tidak ada tuntutan infrastruktur production untuk local setup.
- [ ] Project Author menyetujui README dan struktur docs final.

## 11. Urutan pengerjaan

| Urutan | Tahap | Output |
|---:|---|---|
| 1 | Inventaris/klasifikasi | Indeks dan mapping dokumen |
| 2 | Root README | Pintu masuk dan quick start |
| 3 | README komponen | Backend, web, mobile, WHO |
| 4 | Dokumen inti | Setup, architecture, config, database, testing, user guide |
| 5 | Arsip/release docs | Folder aktif bersih, history terjaga |
| 6 | Verification | Link, command, scope, dan approval lulus |

## 12. Di luar scope

- perubahan fitur atau refactor source;
- deployment production, CI baru, monitoring, atau migration framework;
- iOS signing/build;
- OpenAPI lengkap dari nol jika kontrak aktif sudah cukup;
- diagram/dekorasi berlebihan;
- version/tag release yang belum diputuskan.

Jika dokumentasi menemukan bug nyata, catat di `docs/release/KNOWN_ISSUES.md`. Perubahan kode harus dipisahkan dan disetujui terlebih dahulu.

## 13. Definition of Done

- Root, backend, web, mobile, dan WHO README akurat.
- Struktur serta indeks `docs/` jelas.
- Dokumen aktif dan historis terpisah.
- Fresh local setup dapat diikuti pembaca baru.
- Command dan link sudah diverifikasi.
- Scope Web + Android lokal dan iOS roadmap konsisten.
- Tidak ada secret, PII nyata, atau klaim production readiness.
- Project Author menyelesaikan final review.
