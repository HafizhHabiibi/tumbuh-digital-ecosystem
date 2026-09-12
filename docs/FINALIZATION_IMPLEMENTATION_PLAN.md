# Implementation Plan — Feature Freeze, Finalisasi, dan Release

Status dokumen: **Release record — baseline plan finalisasi**  
Baseline audit: branch `development`, commit `9893d91`  
Tanggal baseline: 12 September 2026  
Ruang lingkup: `backend-express`, `web-dashboard`, `tumbuhapp`, `who-converter`, database, CI/CD, dokumentasi, dan proses rilis

Profil finalisasi saat ini: **single maintainer, local-first, Web + Android, fresh database**. iOS dan public production deployment adalah kesiapan masa depan dan bukan blocker final review lokal. Branch finalisasi menggunakan `release/final-review` tanpa nomor versi.

> Dokumen ini dipertahankan sebagai baseline rencana lengkap. Untuk penggunaan harian gunakan [indeks dokumentasi](./README.md); keputusan freeze dan status issue berada di [release records](./release/README.md).

## 1. Tujuan

Dokumen ini menjadi sumber utama untuk membawa Project PUI/Tumbuh Posyandu dari kondisi feature-complete menuju release candidate yang dapat dipertanggungjawabkan. Plan ini mengatur:

- feature freeze dan kontrol perubahan;
- penyelesaian blocker keamanan dan dependency;
- kesiapan database, migrasi, deployment, dan rollback;
- finalisasi web, Android, dan bila masuk scope, iOS;
- pengujian otomatis, integrasi, dan UAT lintas peran;
- dokumentasi teknis, operasional, dan pengguna;
- keputusan go/no-go dan prosedur release.

Plan ini tidak menambah fitur produk baru. Perubahan setelah freeze hanya boleh berupa perbaikan defect, keamanan, konfigurasi rilis, observability minimum, dokumentasi, dan pekerjaan yang dibutuhkan untuk memenuhi release gate.

## 2. Baseline dan kondisi awal

### 2.1 Komponen

| Komponen | Teknologi | Fungsi utama |
|---|---|---|
| `backend-express` | Node.js, Express, MySQL | API, autentikasi, antropometri, SAW, AI, PDF, notifikasi |
| `web-dashboard` | Vue 3, Pinia, PrimeVue, Vite | Dashboard kader dan puskesmas |
| `tumbuhapp` | Flutter, Riverpod, Dio | Aplikasi orang tua |
| `who-converter` | Node.js, ExcelJS | Konversi dan verifikasi tabel WHO |

### 2.2 Bukti quality gate baseline

| Pemeriksaan | Hasil baseline |
|---|---:|
| Backend test | 250 lulus |
| Web test | 66 lulus dalam 19 test file |
| Flutter test | 126 lulus |
| WHO converter test | 4 lulus |
| Total test | 446 lulus |
| ESLint web | Lulus |
| Flutter analyzer | Tidak ada issue |
| Dart format | 85 file, 0 perubahan |
| Web production build | Berhasil |
| Android debug APK | Berhasil |
| Git worktree setelah audit | Bersih |

### 2.3 Temuan yang memblokir release final

1. Audit dependency backend menemukan 1 vulnerability high dan 8 moderate.
2. Audit dependency WHO converter menemukan 2 vulnerability high dan 2 moderate.
3. Android `release` masih menggunakan debug signing key.
4. CI belum menjalankan quality gate web dan WHO converter.
5. CI push hanya aktif pada `main`, sementara integrasi aktif berada di `development`.
6. Belum ada migration runner, pencatatan versi schema, rollback, serta runbook backup/restore production.
7. Readiness lokal gagal dengan `ECONNREFUSED`; integrasi database nyata belum terbukti pada baseline.
8. Checklist manual/UAT yang ada masih memiliki 21 item belum ditutup.
9. Konfigurasi production mobile belum disiapkan; Firebase iOS belum tersedia.
10. Dokumentasi root dan web tidak lagi mencerminkan struktur serta fungsi project saat ini.

Temuan dependency harus divalidasi ulang ketika pekerjaan dimulai karena advisory dan versi package dapat berubah.

## 3. Prinsip pelaksanaan

1. **Satu perubahan, satu tujuan.** Pisahkan dependency, migrasi, keamanan, dokumentasi, dan release configuration dalam commit/PR yang dapat direview.
2. **Tidak ada fix tanpa verifikasi.** Setiap perubahan harus menjalankan quality gate komponen yang terdampak dan kontrak lintas-komponen jika relevan.
3. **Database didahului backup.** Tidak ada migrasi staging/production tanpa backup, dry run, dan rollback atau forward-fix yang terdokumentasi.
4. **Secret tidak masuk Git.** Gunakan environment/secret manager dan simpan hanya file contoh tanpa credential.
5. **Staging menyerupai production.** HTTPS, proxy, database engine, environment variable, worker, dan integrasi eksternal harus sedekat mungkin dengan production.
6. **Release berbasis bukti.** Checklist dianggap selesai hanya jika ada command output, artefak build, screenshot/UAT record, atau log deployment.
7. **No-go mengalahkan target tanggal.** Release tidak dilanjutkan ketika gate P0 gagal.

## 4. Prioritas

| Prioritas | Definisi | Aturan |
|---|---|---|
| P0 | Blocker keamanan, integritas data, build/signing, migrasi, atau fungsi inti | Wajib selesai sebelum release candidate |
| P1 | Hardening production, operasional, observability, dan kelengkapan dokumentasi wajib | Wajib selesai sebelum go-live publik, kecuali ada risk acceptance tertulis |
| P2 | Maintainability dan optimasi yang tidak mengubah kelayakan rilis | Boleh masuk backlog pascarilis |

## 5. Release gates

| Gate | Nama | Syarat keluar |
|---|---|---|
| G0 | Scope Freeze | Scope, platform, owner, dan aturan perubahan disetujui |
| G1 | Secure Build | Dependency blocker bersih, build berhasil, signing benar |
| G2 | Data & Operations | Migrasi, backup, restore, konfigurasi, health check, dan rollback terbukti |
| G3 | Integration | Staging dan seluruh integrasi eksternal lolos smoke/E2E |
| G4 | UAT | Alur kritis tiga peran diterima dan seluruh defect P0/P1 ditutup |
| G5 | Release Candidate | Dokumentasi, versioning, release notes, artefak, dan approval lengkap |
| G6 | Production Release | Deployment, post-deploy smoke test, dan monitoring stabil |

## 6. Workstream A — Governance dan feature freeze

Prioritas: **P0**  
Gate: **G0**

### Pekerjaan

- [x] Tetapkan tanggal mulai freeze: 12 September 2026.
- [x] Tetapkan target platform: Web + Android; iOS menjadi roadmap dan bukan scope final review saat ini.
- [x] Tetapkan model deployment saat ini: lokal pada perangkat pengembang dengan fresh MySQL database; public hosting/provider belum masuk scope.
- [x] Tetapkan Project Author sebagai single maintainer dan pemegang seluruh tanggung jawab owner/approver.
- [x] Sepakati bahwa fitur baru ditunda ke backlog pascarilis.
- [x] Klasifikasikan perubahan yang diizinkan: P0, P1, test, dokumentasi, dan konfigurasi release pada `docs/release/GOVERNANCE.md`.
- [x] Gunakan branch tanpa versi `release/final-review` yang dibuat dari baseline `development` commit `9893d91`.
- [x] Tetapkan kebijakan PR/review untuk seluruh perubahan branch release pada `docs/release/GOVERNANCE.md`.
- [x] Tetapkan kebijakan hotfix/freeze exception pada `docs/release/GOVERNANCE.md`; approval dipegang Project Author.
- [x] Simpan ringkasan quality gate baseline pada `docs/release/evidence/G0_BASELINE.md`.

### Acceptance criteria

- Scope platform dan environment tidak ambigu.
- Semua area memiliki owner dan approver.
- Branch release menunjuk commit baseline yang disepakati.
- Tidak ada feature PR yang ikut ke branch release.
- Daftar known issues memiliki severity dan keputusan yang jelas.

### Bukti

- Notulen final review.
- Branch release.
- Daftar owner dan known issues.
- Commit/tag baseline.

## 7. Workstream B — Dependency dan software supply chain

Prioritas: **P0**  
Gate: **G1**  
Status: **Selesai untuk final review lokal; SMTP/FCM device test berada pada Workstream I**

### B1. Backend

- [x] Jalankan `npm audit --omit=dev` dan simpan hasil terbaru.
- [x] Identifikasi versi aman minimum untuk `nodemailer`, `mysql2`, `qs`, dan rantai `firebase-admin`/`uuid`.
- [x] Perbarui dependency dan lockfile secara terkontrol tanpa force/major upgrade.
- [x] Tinjau changelog package yang berubah, terutama Firebase Admin, Nodemailer, dan MySQL2.
- [x] Jalankan clean install dan `npm test` — 250 test lulus.
- [x] Jalankan live/readiness lokal — database dan AI ready. Smoke eksternal rinci dilanjutkan pada Workstream I.
- [x] Pindahkan uji pengiriman reset-password nyata ke Workstream I karena membutuhkan alamat uji dan menimbulkan efek eksternal.
- [x] Pindahkan uji notifikasi FCM nyata ke Workstream I karena membutuhkan perangkat/token uji.

### B2. Web dashboard

- [x] Jalankan `npm audit --omit=dev` ulang — 0 vulnerability.
- [x] Jalankan clean install dan `npm run check` — lint, 66 test, dan build lulus.
- [x] Verifikasi konfigurasi build membaca `VITE_API_URL` dan Turnstile site key; fallback localhost tetap hanya untuk mode lokal.
- [x] Simpan laporan ukuran bundle sebagai baseline, tanpa menjadikannya blocker selama tidak ada regresi material.

### B3. WHO converter

- [x] Jalankan `npm audit --omit=dev` dan simpan hasil terbaru.
- [x] Perbarui dependency transitif yang aman tanpa mengubah hasil konversi.
- [x] Tolak force downgrade ExcelJS; dokumentasikan dua moderate residual pada `docs/release/WHO_CONVERTER_RISK_ACCEPTANCE.md`.
- [x] Jalankan clean install dan `npm test` — 4 test lulus.
- [x] Jalankan generator dan bandingkan checksum output — identik dengan baseline.
- [x] Pastikan source Excel tetap tepat 10 file dan berasal dari dataset yang disetujui.

### B4. Flutter

- [x] Jalankan `flutter pub outdated --no-dev-dependencies` dan dokumentasikan package major lama sebagai backlog.
- [x] Pertahankan lockfile karena tidak ada patch/minor yang diperlukan untuk blocker keamanan atau build.
- [x] Tidak melakukan migrasi besar Riverpod, Firebase, routing, chart, atau storage selama freeze.
- [x] Tinjau warning migrasi Built-in Kotlin dan kompatibilitas `file_saver`; tetap dicatat sebagai KI-019.

### Acceptance criteria

- [x] Backend dan web: `npm audit --omit=dev --audit-level=moderate` tidak memiliki vulnerability.
- [x] Converter: tidak memiliki high/critical; moderate residual memiliki risk acceptance dan hanya berlaku pada tool offline dengan trusted input.
- [x] Seluruh perubahan package/lockfile telah direview dan siap di-commit bersama perubahan final-review.
- [x] Seluruh automated test kembali lulus; external SMTP/FCM smoke test dijadwalkan pada Workstream I.
- [x] Tidak ada perubahan hasil perhitungan WHO/SAW akibat dependency update.

### Rollback

- Revert commit dependency dan lockfile sebagai satu unit.
- Jangan mencampur refactor fitur dengan dependency update.

## 8. Workstream C — Security dan privacy hardening

Prioritas: **P0/P1**  
Gate: **G1–G2**

Status 2026-09-12: **implementasi lokal selesai; approval dokumen dan verifikasi provider/hosting eksternal masih menjadi gate sebelum scope publik**. Evidence: `docs/release/evidence/C_SECURITY_EVIDENCE.md`. Risk acceptance: `docs/release/C_SECURITY_RISK_ACCEPTANCE.md`.

### C1. HTTP dan browser security

- [x] Tambahkan security headers backend yang sesuai deployment: CSP, `X-Content-Type-Options`, frame protection, referrer policy, dan HSTS kondisional hanya ketika HTTPS production benar.
- [x] Tetapkan CORS pada allowlist origin web eksplisit; beberapa origin dipisahkan koma.
- [x] Tetapkan `TRUST_PROXY_HOPS=0` untuk runtime lokal tanpa proxy; perubahan wajib mengikuti jumlah hop aktual.
- [x] Pertahankan body JSON 100 KiB dan tambahkan request timeout tervalidasi 120 detik; proxy production wajib sedikit lebih besar.
- [x] Terapkan CSP web berbasis `VITE_API_URL`, kompatibel dengan asset lokal, ApexCharts, dan Turnstile; header hosting aktual tetap gate staging.
- [x] Audit rendering dinamis: tidak ditemukan `v-html`, `innerHTML`, atau `eval` pada source web.
- [x] Putuskan session web tetap bearer token di `localStorage` hanya untuk scope lokal; secure cookie/review formal wajib sebelum publik (RA-C01).

### C2. Authentication

- [x] Terapkan password baru/create/reset minimal 8 karakter dan maksimum 72 byte UTF-8 pada backend; web/Android menyelaraskan minimum dan panjang UI.
- [x] Verifikasi invalidasi access token melalui `users.updated_at` dan regression test.
- [x] Verifikasi refresh-token rotation atomik, reuse rejection, multi-device behavior, dan logout seluruh sesi dari implementasi/test yang ada.
- [x] Tambahkan scheduled cleanup refresh token expired/revoked saat startup dan setiap 6 jam.
- [x] Perbaiki key generator agar memakai `req.ip`; uji rate limit di belakang satu proxy dengan IPv4 dan subnet IPv6.
- [x] Tetapkan backend single-instance untuk scope lokal; central store wajib sebelum multi-instance (RA-C02).
- [x] Verifikasi Turnstile wajib cocok pada `success`, `action`, hostname allowlist; provider unavailable menghasilkan 503. E2E provider dilanjutkan Workstream I.

### C3. Secret dan integrasi

- [x] Inventaris seluruh secret: JWT, refresh JWT, database, SMTP, Turnstile, Gemini, Firebase Admin, dan Android keystore.
- [x] Tetapkan secret hanya pada environment/ADC/file lokal ignored; repository hanya menyimpan template dan Firebase client config.
- [ ] Rotasi credential yang pernah dipakai bersama sebelum staging/public; tidak dilakukan otomatis pada scope lokal (RA-C07).
- [x] Validasi startup memastikan JWT access/refresh berbeda dan minimal 32 karakter.
- [ ] Verifikasi restriction Firebase client/API key Android di Firebase Console sebelum APK/AAB dibagikan (RA-C05).
- [x] Audit pola log; hilangkan output identitas fixture dan isi payload notifikasi yang ditemukan.

### C4. Data kesehatan dan privasi

- [x] Dokumentasikan identitas akun, NIK, data anak, pengukuran, pemberian, rujukan, notifikasi, sesi, dan percakapan AI.
- [x] Tetapkan tujuan, akses role, retensi lokal, koreksi, ekspor, penghapusan, dan disposal.
- [x] Dokumentasikan allowlist dan larangan data untuk Gemini.
- [x] Verifikasi serializer orang tua melalui automated test tidak mengekspos Z-score, detail SAW, atau data anak lain.
- [x] Catat penundaan audit trail sebagai RA-C04; wajib sebelum data nyata.
- [x] Siapkan privacy notice minimum, disclosure AI, dan prosedur/kontak insiden lokal.

### Acceptance criteria

- [ ] Security header dan CORS terverifikasi dari environment staging; lokal sudah lulus automated test (RA-C06).
- [x] Scan current tracked tree tidak menemukan private/server secret; Firebase client config dicatat terpisah.
- [x] Matriks role/kepemilikan lulus automated test; UAT manual dilanjutkan Workstream I/J.
- [x] Kebijakan session web diputuskan eksplisit untuk scope lokal.
- [ ] Dokumen security/privacy menunggu persetujuan Project Author pada final review.
- [x] Tidak ada P0 security issue terbuka untuk scope lokal tanpa data nyata.

## 9. Workstream D — Database, migrasi, dan integritas data

Prioritas: **P0**  
Gate: **G2**

### D1. Migration framework

- [ ] Tetapkan versi MySQL production dan collation/timezone.
- [ ] Buat migration runner yang menjalankan file berdasarkan urutan nama.
- [ ] Tambahkan tabel `schema_migrations` berisi nama/versi, checksum, dan waktu eksekusi.
- [ ] Pastikan migrasi idempotent atau berhenti aman ketika sudah diterapkan.
- [ ] Masukkan tiga migrasi yang ada ke prosedur terkelola:
  - `20260829_chat_request_reservation.sql`;
  - `20260831_insight_superseded.sql`;
  - `20260901_rujukan_lifecycle.sql`.
- [ ] Pisahkan tegas setup database baru, migrasi database existing, dan seeding development.
- [ ] Pastikan `db:setup`/seeder tidak digunakan dalam deployment production.
- [ ] Buat command status migrasi dan dokumentasi troubleshooting.

### D2. Schema verification

- [ ] Bandingkan database staging dengan `schema.sql` dan seluruh migrasi.
- [ ] Verifikasi 14 tabel, foreign key, unique constraint, index, enum, dan check constraint.
- [ ] Validasi index untuk query list, ranking, laporan, antrean insight, chat, refresh token, dan notification outbox.
- [ ] Jalankan test data untuk constraint tanggal dan lifecycle rujukan.
- [ ] Pastikan timezone aplikasi, Node.js, dan MySQL menghasilkan tanggal pengukuran yang konsisten di WIB.

### D3. Backup dan recovery

- [ ] Tetapkan backup full sebelum migrasi dan jadwal backup berkala.
- [ ] Enkripsi backup dan batasi akses.
- [ ] Lakukan restore drill ke database terpisah.
- [ ] Catat waktu backup, waktu restore, ukuran data, dan checksum.
- [ ] Definisikan RPO/RTO minimum.
- [ ] Tentukan rollback per migrasi; bila rollback berisiko kehilangan data, gunakan forward-fix yang telah disiapkan.

### D4. Connection dan lifecycle data

- [ ] Aktifkan TLS MySQL bila koneksi melewati jaringan yang tidak dipercaya.
- [ ] Konfigurasi pool, timeout, dan maximum connection sesuai limit provider.
- [ ] Tambahkan cleanup job untuk refresh token dan data outbox terminal sesuai kebijakan retensi.
- [ ] Verifikasi cascade delete tidak menghapus riwayat yang wajib dipertahankan secara hukum/operasional.

### Acceptance criteria

- Migrasi fresh database dan existing database sama-sama lulus.
- Menjalankan migration runner dua kali tidak merusak schema/data.
- Backup berhasil dipulihkan dan diverifikasi.
- Tidak ada schema drift staging.
- Seluruh test backend lulus terhadap schema final.
- Runbook rollback/forward-fix tersedia.

## 10. Workstream E — Backend operational readiness

Prioritas: **P0/P1**  
Gate: **G2–G3**

### E1. Konfigurasi

- [ ] Klasifikasikan environment variable menjadi wajib, kondisional, dan opsional.
- [ ] Verifikasi `NODE_ENV=production`, `CORS_ORIGIN`, `FRONTEND_URL`, `TRUST_PROXY_HOPS`, database, JWT, SMTP, Turnstile, Gemini, Firebase, dan identitas laporan.
- [ ] Tambahkan validasi startup untuk environment production yang dibutuhkan oleh fitur yang diaktifkan.
- [ ] Putuskan apakah kegagalan AI harus membuat readiness seluruh service menjadi 503 atau hanya menonaktifkan fitur AI.
- [ ] Pastikan `/api/health/live` tidak memeriksa dependency dan `/api/health/ready` mencerminkan kebijakan deployment yang disepakati.

### E2. Worker

- [ ] Verifikasi recovery notification outbox ketika proses mati saat status `processing`.
- [ ] Verifikasi recovery insight queue dan lease worker.
- [ ] Uji dua instance backend untuk memastikan claim tidak menghasilkan duplikasi.
- [ ] Putuskan apakah worker tetap satu proses dengan API atau dipisah menjadi worker deployment.
- [ ] Tambahkan shutdown timeout dan log hasil drain yang cukup untuk operasi.

### E3. Observability

- [ ] Gunakan structured log dengan timestamp, level, request ID, route, status, dan latency.
- [ ] Redact token, secret, identitas pribadi, dan isi chat.
- [ ] Tambahkan monitoring untuk error rate, latency, database pool, antrean AI, outbox pending/failed, dan provider failure.
- [ ] Tetapkan alert untuk readiness gagal, lonjakan 5xx, antrean tertahan, dan kegagalan backup.
- [ ] Dokumentasikan lokasi log dan prosedur diagnosis berdasarkan request ID.

### E4. API contract

- [ ] Dokumentasikan seluruh endpoint, role, ownership, query, body, response, pagination, file download, dan kode error.
- [ ] Pertimbangkan OpenAPI sebagai kontrak utama.
- [ ] Dokumentasikan alias deprecated `/api/dashboard/risiko` dan tanggal penghapusannya.
- [ ] Bekukan kontrak response selama release branch kecuali perbaikan P0.

### Acceptance criteria

- Startup production gagal cepat untuk konfigurasi wajib yang hilang.
- Health endpoint terhubung ke probe deployment dengan benar.
- Worker dapat dipulihkan tanpa duplikasi efek bisnis.
- Request kritis dapat ditelusuri melalui request ID tanpa membocorkan PII.
- API contract final disetujui web dan mobile.

## 11. Workstream F — Web dashboard finalization

Prioritas: **P0/P1**  
Gate: **G1–G4**

### Pekerjaan

- [ ] Bekukan route dan alur role kader/puskesmas.
- [ ] Verifikasi environment production tidak fallback ke `localhost`.
- [ ] Uji direct navigation dan refresh seluruh route pada web server dengan history fallback.
- [ ] Verifikasi login, forgot password, reset password, change password, logout, dan expired session.
- [ ] Verifikasi seluruh list: search, filter, pagination, empty state, loading, retry, dan error.
- [ ] Uji CRUD orang tua/anak beserta constraint delete.
- [ ] Uji pencatatan pengukuran, pemberian, pembuatan rujukan, update lifecycle rujukan, jadwal, ranking, dashboard, dan download laporan.
- [ ] Uji keyboard navigation, focus state, label form, contrast, dan responsive layout minimum.
- [ ] Uji browser target yang disepakati, minimal Chrome/Edge versi stabil dan satu mobile viewport untuk fallback.
- [ ] Catat ukuran bundle dan pastikan tidak ada source map production yang mengekspos informasi sensitif jika tidak diperlukan.
- [ ] Pecah file UI besar hanya bila dibutuhkan untuk memperbaiki defect; refactor umum masuk P2.

### Acceptance criteria

- `npm run check` lulus pada clean install.
- Seluruh route dapat dibuka dan di-refresh dari deployment staging.
- Tidak ada P0/P1 visual atau functional defect.
- Semua aksi berbahaya mempunyai konfirmasi dan feedback hasil.
- Role kader tidak dapat membuka halaman puskesmas dan sebaliknya, termasuk melalui request API langsung.

## 12. Workstream G — Mobile Android dan iOS

Prioritas: **P0/P1**  
Gate: **G1–G4**

### G1. Android release

- [ ] Buat production upload/release keystore di luar repository.
- [ ] Simpan alias/password melalui secret CI atau file lokal yang di-ignore.
- [ ] Ubah release build agar tidak memakai debug signing.
- [ ] Tetapkan `applicationId`, nama aplikasi, version name, dan version code final.
- [ ] Verifikasi Firebase Android sesuai package production.
- [ ] Build AAB release dengan `config/production.json`.
- [ ] Verifikasi signature artefak.
- [ ] Uji release build pada minimal satu perangkat Android nyata.
- [ ] Uji notification permission Android 13+, foreground/background/terminated notification, dan deep link tujuan.
- [ ] Uji install baru, upgrade dari build sebelumnya, logout, dan reinstall.

### G2. iOS, bila termasuk scope

- [ ] Tetapkan bundle identifier dan signing team.
- [ ] Sediakan `GoogleService-Info.plist` melalui mekanisme aman.
- [ ] Konfigurasi APNs dan capability push notification/background mode.
- [ ] Build archive/IPA release di macOS/Xcode yang disetujui.
- [ ] Uji push notification dan seluruh alur inti pada perangkat iOS nyata.
- [ ] Jika iOS tidak termasuk release, hapus klaim release iOS dari dokumentasi versi ini dan catat sebagai roadmap.

### G3. Runtime dan UX

- [ ] Pastikan production/staging hanya menerima HTTPS.
- [ ] Uji access-token refresh bersamaan, refresh rotation, offline state, timeout, dan session expired.
- [ ] Uji secure storage setelah upgrade/reinstall sesuai perilaku platform.
- [ ] Uji dashboard, detail anak, pengukuran, grafik, insight, chat, pemberian, rujukan, jadwal, laporan, notifikasi, dan profil.
- [ ] Uji font scaling, layar kecil, loading, empty state, serta jaringan lambat.
- [ ] Verifikasi disclosure AI dan larangan memasukkan data pribadi terlihat jelas.

### Acceptance criteria

- `dart format --output=none --set-exit-if-changed lib test` lulus.
- `flutter analyze` lulus.
- `flutter test` lulus.
- AAB release menggunakan release key dan konfigurasi production.
- Tidak ada HTTP cleartext pada release.
- Push notification dan navigasi bekerja pada perangkat nyata.
- Keputusan iOS ditutup dan sesuai dokumentasi.

## 13. Workstream H — CI/CD dan reproducible build

Prioritas: **P0/P1**  
Gate: **G1–G5**

### Pekerjaan

- [ ] Pertahankan job backend: `npm ci` dan `npm test`.
- [ ] Tambahkan job web: `npm ci` dan `npm run check`.
- [ ] Pertahankan job Flutter: pub get, format check, analyze, test, dan debug build.
- [ ] Tambahkan job WHO converter: `npm ci` dan `npm test`.
- [ ] Jalankan workflow untuk PR yang menyentuh setiap komponen terkait.
- [ ] Jalankan workflow pada push `development`, release branch, dan `main` sesuai kebijakan branch.
- [ ] Tambahkan dependency audit sebagai gate high/critical; tentukan kebijakan moderate secara eksplisit.
- [ ] Pin versi Node.js, Flutter, Java, dan action CI.
- [ ] Tambahkan cache berdasarkan lockfile tanpa menyimpan secret atau artefak sensitif.
- [ ] Simpan artefak build release hanya dari tag/approval yang benar.
- [ ] Tambahkan branch protection: required checks, review, dan larangan force push untuk release/main.
- [ ] Dokumentasikan reproduksi build secara lokal.

### Acceptance criteria

- Semua komponen diperiksa CI dari clean checkout.
- Branch release tidak dapat merge bila required check gagal.
- Build memakai lockfile committed.
- Artefak dapat ditelusuri ke commit dan versi tertentu.
- Secret tidak pernah tampil di log CI.

## 14. Workstream I — Staging dan integration verification

Prioritas: **P0**  
Gate: **G3**

### Environment staging minimum

- [ ] Domain/API HTTPS.
- [ ] Web dashboard HTTPS.
- [ ] MySQL dengan schema final dan data uji non-production.
- [ ] SMTP sandbox/akun staging.
- [ ] Turnstile staging/test configuration.
- [ ] Gemini key dengan quota terkontrol.
- [ ] Firebase project/device staging.
- [ ] Log dan monitoring dapat diakses owner.

### Smoke test backend

- [ ] Liveness mengembalikan 200.
- [ ] Readiness mengembalikan status sesuai kebijakan final.
- [ ] Login web kader dan puskesmas berhasil tanpa refresh token.
- [ ] Login mobile orang tua menghasilkan access dan refresh token.
- [ ] Role yang salah ditolak pada platform yang salah.
- [ ] Forgot/reset password mengirim link yang benar dan token hanya sekali pakai.
- [ ] CRUD data inti mematuhi ownership dan constraint.
- [ ] Pengukuran menghasilkan nilai antropometri, SAW, dan prioritas yang konsisten.
- [ ] Insight diproses dan chat aman berhasil.
- [ ] Input PII/prompt injection chat ditolak sebelum provider.
- [ ] Notifikasi tersimpan dan push diterima perangkat.
- [ ] Laporan PDF individual dan rekap dapat diunduh.

### Integration contract

- [ ] Web memakai schema response dan error final.
- [ ] Mobile memakai schema response dan error final.
- [ ] Pagination/search/filter konsisten.
- [ ] Semua tanggal konsisten di WIB dan tidak bergeser karena UTC.
- [ ] Request ID terlihat di response dan log.
- [ ] Tidak ada data lintas orang tua/puskesmas yang bocor.

### Acceptance criteria

- Seluruh smoke test lulus dua kali dari deployment bersih.
- Tidak ada error 5xx yang belum dijelaskan.
- Tidak ada message/outbox/insight job tertahan di luar SLA yang disepakati.
- Evidence test disimpan bersama release candidate.

## 15. Workstream J — UAT lintas peran

Prioritas: **P0**  
Gate: **G4**

### Dataset UAT

Sediakan data sintetis, bukan data anak nyata, minimal untuk:

- anak tanpa pengukuran;
- pertumbuhan normal;
- kekurangan gizi;
- risiko gizi lebih/gizi lebih;
- obesitas;
- rujukan diajukan, ditangani, dan selesai;
- jadwal mendatang dan lampau;
- akun dan sesi yang kedaluwarsa.

### Skenario kader

- [ ] Login dan profil.
- [ ] Membuat/mengubah/mencari orang tua dan anak.
- [ ] Mencatat pengukuran dan memeriksa hasil.
- [ ] Mencatat pemberian PMT/vitamin.
- [ ] Membuat rujukan dan melihat statusnya.
- [ ] Membuat, generate, mengubah, dan menghapus jadwal sesuai constraint.
- [ ] Memeriksa dashboard dan ranking prioritas.
- [ ] Mengunduh laporan individual teknis dan rekap.
- [ ] Mengganti password dan memastikan sesi lama invalid.

### Skenario puskesmas

- [ ] Login dan profil.
- [ ] Melihat anak/pengukuran sesuai cakupan.
- [ ] Memeriksa dashboard dan ranking.
- [ ] Memproses lifecycle rujukan secara berurutan.
- [ ] Mengisi hasil penanganan saat menyelesaikan rujukan.
- [ ] Melihat jadwal.
- [ ] Mengunduh laporan.
- [ ] Memastikan aksi khusus kader ditolak.

### Skenario orang tua

- [ ] Login mobile, pemulihan sesi, refresh token, dan logout.
- [ ] Melihat hanya anak miliknya.
- [ ] Melihat riwayat/detail/grafik pengukuran tanpa data teknis terlarang.
- [ ] Melihat insight dan menggunakan chat untuk pengukuran terbaru.
- [ ] Melihat chat lama dalam mode read-only.
- [ ] Memperbaiki pesan setelah penolakan PII.
- [ ] Melihat pemberian, rujukan, jadwal, notifikasi, laporan, dan profil.
- [ ] Membuka tujuan notifikasi pada foreground/background/terminated state.
- [ ] Menguji offline, timeout, retry, dan sesi kedaluwarsa.

### Kriteria defect

| Severity | Contoh | Keputusan |
|---|---|---|
| P0 | Kebocoran data, salah perhitungan, kehilangan data, auth bypass, crash alur inti | Release no-go |
| P1 | Alur inti tidak selesai, laporan salah, notifikasi kritis gagal | Wajib diperbaiki sebelum go-live |
| P2 | Visual minor/workaround jelas | Boleh diterima dengan known issue |

### Acceptance criteria

- Seluruh skenario P0/P1 lulus.
- Approver kader, puskesmas, dan orang tua menandatangani hasil UAT.
- Evidence memuat versi build, environment, waktu, tester, hasil, dan defect ID.
- Checklist lama diperbarui agar sesuai bukti aktual, bukan sekadar dicentang.

## 16. Workstream K — Dokumentasi

Prioritas: **P0/P1**  
Gate: **G5**

Rencana eksekusi yang disederhanakan untuk proyek akhir lokal tersedia di `docs/DOCUMENTATION_IMPLEMENTATION_PLAN.md`. Dokumen tersebut menjadi sumber utama pembaruan README dan reorganisasi docs; bagian ini dipertahankan sebagai record release plan awal.

### K1. Dokumentasi utama

- [ ] Perbarui root `README.md`: nama produk, tujuan, folder aktual, arsitektur ringkas, fitur, prasyarat, quick start, test, dan tautan dokumen.
- [ ] Buat `backend-express/README.md`: konfigurasi, setup, migrasi, run, test, worker, health endpoint, dan troubleshooting.
- [ ] Ganti template `web-dashboard/README.md`: environment, run, test, build, routing fallback, dan deployment.
- [ ] Perbarui `tumbuhapp/README.md`: scope platform final, konfigurasi, signing, Firebase, build, test, dan distribusi.
- [ ] Pertahankan `who-converter/README.md` dan tambahkan prosedur verifikasi checksum bila perlu.

### K2. Dokumen teknis root

- [ ] `docs/ARCHITECTURE.md`: konteks sistem, komponen, data flow, worker, integrasi eksternal.
- [ ] `docs/API.md` atau OpenAPI: endpoint, role, ownership, request/response/error.
- [ ] `docs/DATABASE.md`: ERD, 14 tabel, constraint, index, migrasi, backup, restore.
- [ ] `docs/CONFIGURATION.md`: environment variable per development/staging/production.
- [ ] `docs/SECURITY_AND_PRIVACY.md`: auth, PII, AI, retensi, secret, logging, incident response.
- [ ] `docs/DEPLOYMENT.md`: web, backend, database, Android/iOS, health probes, rollback.
- [ ] `docs/TESTING.md`: automated test, integration, UAT, dataset, command, evidence.
- [ ] `docs/OPERATIONS_RUNBOOK.md`: monitoring, worker queue, backup, recovery, provider outage.

### K3. Dokumen pengguna dan governance

- [ ] `docs/USER_GUIDE_KADER.md`.
- [ ] `docs/USER_GUIDE_PUSKESMAS.md`.
- [ ] `docs/USER_GUIDE_ORANG_TUA.md`.
- [ ] `CHANGELOG.md`.
- [ ] `SECURITY.md`.
- [ ] `LICENSE` sesuai keputusan pemilik project.
- [ ] Release notes versi pertama dan known issues.

### K4. Sinkronisasi dokumen lama

- [ ] Tandai implementation plan lama sebagai completed, superseded, atau historical.
- [ ] Perbarui checklist conversational AI berdasarkan automated test dan UAT aktual.
- [ ] Perbarui checklist prioritas pemantauan berdasarkan evidence staging.
- [ ] Pastikan istilah `prioritas pemantauan`, `SAW`, `rujukan`, dan status antropometri konsisten di seluruh dokumen/UI.

### Acceptance criteria

- Developer baru dapat menjalankan sistem dari dokumentasi tanpa pengetahuan lisan.
- Operator dapat deploy, migrate, backup, restore, rollback, dan diagnosis insiden.
- Pengguna setiap role memiliki panduan alur inti.
- Tidak ada nama folder, endpoint, command, atau klaim platform yang sudah usang.
- Setiap dokumen memiliki owner dan tanggal review.

## 17. Workstream L — Versioning dan release candidate

Prioritas: **P0**  
Gate: **G5**

### Pekerjaan

- [ ] Tetapkan skema versi; rekomendasi Semantic Versioning untuk sistem dan build number mobile yang selalu naik.
- [ ] Selaraskan versi backend, web, mobile, dan release notes sesuai kebijakan produk.
- [ ] Ubah web dari versi placeholder `0.0.0`.
- [ ] Tentukan nomor release candidate, misalnya `1.0.0-rc.1`.
- [ ] Build semua artefak dari commit CI yang sama.
- [ ] Catat checksum artefak web dan mobile.
- [ ] Buat Software Bill of Materials bila tooling tersedia.
- [ ] Buat release notes berisi fitur, migrasi, konfigurasi, known issues, dan rollback.
- [ ] Tag hanya setelah seluruh G0–G5 lulus.

### Acceptance criteria

- Versi pada aplikasi, artefak, tag, dan release notes konsisten.
- Commit release tidak memiliki perubahan lokal.
- Artefak dapat direproduksi dari tag.
- Tidak ada migration/configuration step tersembunyi.

## 18. Workstream M — Production deployment dan rollback

Prioritas: **P0**  
Gate: **G6**

### Pre-deploy

- [ ] Approval go-live tercatat.
- [ ] Backup production selesai dan dapat dibaca.
- [ ] Maintenance window/komunikasi pengguna ditetapkan jika diperlukan.
- [ ] Secret dan environment tervalidasi tanpa mencetak nilainya.
- [ ] Database connection capacity dan disk space cukup.
- [ ] Artefak/tag/checksum sesuai release candidate.
- [ ] Rollback owner siaga.

### Urutan deployment

1. Aktifkan maintenance/read-only bila perubahan schema membutuhkannya.
2. Ambil backup final.
3. Jalankan migration runner dan verifikasi status.
4. Deploy backend dan verifikasi live/ready.
5. Deploy web dan verifikasi asset serta routing fallback.
6. Distribusikan mobile sesuai channel yang disepakati.
7. Jalankan post-deploy smoke test.
8. Pantau error, latency, database, queue, dan provider.
9. Tutup maintenance setelah acceptance criteria terpenuhi.

### Rollback trigger

Rollback atau hentikan rollout jika terjadi salah satu kondisi:

- auth bypass atau kebocoran data;
- kesalahan hasil antropometri/prioritas;
- migration gagal atau data tidak konsisten;
- error 5xx berulang pada alur inti;
- login mayoritas pengguna gagal;
- worker menghasilkan duplikasi masif;
- laporan salah atau tidak dapat dibuat untuk skenario utama;
- crash release mobile pada startup/alur login.

### Rollback procedure minimum

- Hentikan traffic ke versi bermasalah.
- Rollback artefak aplikasi ke versi terakhir yang diketahui baik.
- Jalankan rollback schema hanya jika aman; jika tidak, gunakan forward-fix.
- Pulihkan backup hanya dengan approval karena dapat membuang transaksi setelah backup.
- Verifikasi health, login, dan query data inti.
- Catat timeline, dampak, keputusan, dan tindakan lanjutan.

### Acceptance criteria

- Post-deploy smoke test lulus.
- Monitoring stabil selama observation window yang disepakati.
- Tidak ada P0/P1 incident baru.
- Release record berisi tag, waktu, operator, migrasi, artefak, dan hasil smoke test.

## 19. Workstream N — Post-release

Prioritas: **P1/P2**

- [ ] Pantau error dan antrean intensif selama 24 jam pertama.
- [ ] Review metrik dan feedback pada hari ke-1, ke-3, dan ke-7.
- [ ] Tutup atau jadwalkan known issues P2.
- [ ] Lakukan retrospective release.
- [ ] Perbarui runbook berdasarkan masalah aktual.
- [ ] Rencanakan refactor file UI besar tanpa mencampurnya dengan hotfix.
- [ ] Rencanakan major upgrade Flutter dependency secara terpisah.
- [ ] Rencanakan migrasi Built-in Kotlin dan kompatibilitas plugin.
- [ ] Evaluasi optimasi bundle web dan code splitting tambahan.
- [ ] Jadwalkan restore drill serta dependency audit berkala.

## 20. Test matrix final

| Area | Automated | Integration/UAT | Wajib sebelum release |
|---|---|---|---|
| Auth/role/ownership | Backend, web, mobile test | Tiga role dan request langsung | Ya |
| Antropometri WHO | Backend + converter test | Dataset skenario UAT | Ya |
| SAW/prioritas | Backend regression | Dashboard, mobile, PDF | Ya |
| CRUD orang tua/anak | Backend/web test parsial | Kader UAT | Ya |
| Pemberian | Backend/mobile/web test | Kader dan orang tua | Ya |
| Rujukan | Backend/web/mobile test | Kader-puskesmas-orang tua | Ya |
| Jadwal | Backend/web/mobile test | Generate/update/delete + notifikasi | Ya |
| AI insight/chat | Backend/mobile test | Gemini staging, PII, retry, quota | Ya |
| Notifikasi | Backend/mobile test | FCM perangkat nyata | Ya |
| Laporan PDF | Backend/web/mobile test | Download dan inspeksi isi | Ya |
| Migrasi/backup | Belum menjadi gate baseline | Fresh/existing/restore drill | Ya |
| Web accessibility | Lint tidak mencakup penuh | Keyboard/contrast/responsive | P1 |
| Mobile release | Debug build baseline | Signed AAB/perangkat nyata | Ya |

## 21. Risk register

| Risiko | Dampak | Kemungkinan | Mitigasi | Gate |
|---|---|---|---|---|
| Dependency vulnerable | Kompromi/DoS | Sedang | Upgrade terkontrol + audit + test | G1 |
| Debug signing release | Artefak tidak layak distribusi | Tinggi | Production keystore dan verifikasi signature | G1 |
| Schema drift | Gagal runtime/kehilangan data | Sedang | Migration runner + schema verification | G2 |
| Backup tidak dapat direstore | Kehilangan data | Sedang | Restore drill | G2 |
| AI/FCM/SMTP belum diuji nyata | Fitur gagal di production | Tinggi | Staging integration test | G3 |
| Rate limit memory pada multi-instance | Abuse tidak tertahan konsisten | Sedang | Central store atau single-instance decision | G2 |
| Token web + XSS | Pengambilalihan sesi | Sedang | CSP, security headers, session decision | G1/G2 |
| Worker satu proses dengan API | Queue berhenti saat deploy/crash | Sedang | Recovery test, monitoring, optional split worker | G2/G3 |
| UAT belum lengkap | Defect alur bisnis lolos | Tinggi | Dataset dan sign-off tiga role | G4 |
| Dokumentasi usang | Deployment/operasi salah | Tinggi | Documentation workstream | G5 |
| iOS tidak terkonfigurasi | Klaim platform tidak terpenuhi | Tinggi jika iOS in-scope | Putuskan scope atau lengkapi signing/Firebase | G0/G1 |

## 22. Estimasi urutan kerja

Estimasi ini adalah effort relatif, bukan komitmen tanggal. Pekerjaan dapat paralel setelah G0.

| Gelombang | Fokus | Dependensi | Estimasi |
|---|---|---|---:|
| 0 | Scope, owner, branch release | Tidak ada | 0,5–1 hari |
| 1 | Dependency, signing, CI | G0 | 2–4 hari |
| 2 | Security, migrasi, backup, observability minimum | G0 | 3–6 hari |
| 3 | Dokumentasi teknis dan environment staging | G0, sebagian G1 | 3–5 hari |
| 4 | Integration test dan defect fixing | G1–G3 | 2–4 hari |
| 5 | UAT tiga role | G3 | 2–3 hari |
| 6 | RC, release notes, deployment rehearsal | G4 | 1–2 hari |
| 7 | Production rollout dan observation | G5 | 1 hari + monitoring |

Perkiraan total kalender untuk tim kecil: sekitar 2–4 minggu, tergantung kesiapan infrastructure, credential, perangkat uji, dan cakupan iOS.

## 23. Keputusan yang wajib ditutup pada final review

| ID | Keputusan | Opsi utama | Rekomendasi awal |
|---|---|---|---|
| D-01 | Platform release | Web+Android / Web+Android+iOS | Web+Android dahulu jika fasilitas build/signing iOS belum siap |
| D-02 | Target deployment | VM/container/PaaS | Pilih satu dan dokumentasikan health, secret, TLS, log |
| D-03 | Database | Fresh setup / migrasi existing | Migrasi existing dengan backup dan restore drill |
| D-04 | Session web | Local storage / secure cookie | Secure cookie untuk hardening jangka panjang; CSP wajib bila tetap local storage |
| D-05 | Readiness AI | AI memblokir seluruh readiness / degrade gracefully | Putuskan berdasarkan apakah AI dianggap fungsi wajib |
| D-06 | Worker | Menyatu dengan API / service terpisah | Menyatu cukup untuk single instance; pisahkan jika skala/availability menuntut |
| D-07 | Rate limit | Memory / central store | Central store untuk multi-instance |
| D-08 | Password policy | Tetap 6 / minimum lebih kuat | Minimum 8–12 karakter |
| D-09 | Privacy retention | Belum ditetapkan / periode eksplisit | Tetapkan sebelum data nyata masuk production |
| D-10 | Version | 1.0.0 / versi lain | Gunakan `1.0.0-rc.1`, lalu `1.0.0` setelah sign-off |

## 24. Checklist go/no-go ringkas

Release berstatus **GO** hanya bila seluruh pernyataan berikut benar:

- [ ] Tidak ada vulnerability high/critical yang belum diterima secara tertulis.
- [ ] Seluruh automated quality gate lulus dari clean checkout.
- [ ] Android release ditandatangani production key; iOS sesuai keputusan scope.
- [ ] Migrasi fresh dan existing lulus; backup telah berhasil direstore.
- [ ] Staging HTTPS lengkap dan seluruh integrasi eksternal lulus.
- [ ] Seluruh skenario UAT P0/P1 lulus serta ditandatangani.
- [ ] Tidak ada defect P0/P1 terbuka.
- [ ] Dokumentasi deploy, konfigurasi, migrasi, rollback, security, dan user guide tersedia.
- [ ] Versi, tag, checksum, artefak, dan release notes konsisten.
- [ ] Monitoring dan rollback owner siap saat deployment.

Jika satu saja item di atas tidak terpenuhi, keputusan default adalah **NO-GO** atau penundaan release. Pengecualian hanya boleh diberikan melalui risk acceptance tertulis yang mencantumkan risiko, dampak, mitigasi sementara, owner, dan tenggat penyelesaian.

## 25. Template bukti penyelesaian

Gunakan format berikut pada PR, issue, atau release record:

```text
Item plan:
Owner:
Commit/PR:
Environment:
Command atau skenario:
Hasil:
Artefak/log/screenshot:
Risiko tersisa:
Reviewer:
Tanggal:
```

## 26. Definition of Done release

Release dinyatakan selesai ketika:

1. seluruh gate G0–G6 lulus;
2. sistem production sehat dan smoke test berhasil;
3. monitoring tidak menunjukkan insiden P0/P1 pada observation window;
4. release record dan dokumentasi telah dipublikasikan ke lokasi yang disepakati;
5. backlog pascarilis memiliki owner dan prioritas;
6. branch/tag final terlindungi dan dapat digunakan untuk reproduksi artefak.
