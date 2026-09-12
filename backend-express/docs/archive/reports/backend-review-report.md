# Laporan Analisis dan Review Backend

> **Status dokumen: HISTORIS — baseline 26 Agustus 2026.** Temuan telah ditangani melalui perubahan berikutnya atau dicatat sebagai known issue/risk acceptance. Nilai dan angka test di bawah bukan status backend saat ini; gunakan [evidence terbaru](../../../../docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md).

**Sistem:** Tumbuh Posyandu / Backend Express  
**Tanggal review:** 26 Agustus 2026  
**Cakupan:** source code, route/controller/model/service, autentikasi dan otorisasi, schema dan seeder MySQL, integrasi eksternal, dependency, serta kesiapan pengujian dan operasi.

## 1. Ringkasan Eksekutif

Backend sudah memiliki pemisahan layer yang cukup jelas, query SQL umumnya terparameterisasi, autentikasi berbasis JWT, pembatasan peran, rate limit login, transaksi saat membuat akun orang tua, dan constraint database dasar. Seluruh file JavaScript juga lolos pemeriksaan sintaks.

Namun, backend **belum layak dipublikasikan ke produksi sebelum temuan prioritas ditangani**. Risiko terbesar adalah credential Firebase yang sudah masuk riwayat Git, dua endpoint yang memungkinkan orang tua membaca data kesehatan keluarga lain, lifecycle refresh token yang tidak menghormati penonaktifan/reset akun, dependency rentan, serta algoritma risiko gizi yang dapat menghasilkan klasifikasi menyesatkan pada data di luar rentang atau interval pengukuran yang tidak bulanan.

**Penilaian keseluruhan: 48/100 — perlu perbaikan besar sebelum produksi.**

| Area | Nilai | Catatan |
|---|---:|---|
| Arsitektur dan keterbacaan | 7/10 | Layer jelas, tetapi controller masih memuat banyak orkestrasi dan validasi manual |
| Keamanan | 3/10 | Credential bocor, IDOR, token lifecycle lemah, dependency rentan |
| Integritas dan domain data | 5/10 | Constraint cukup baik, tetapi validasi tanggal/numerik dan perhitungan risiko bermasalah |
| Reliability | 4/10 | Banyak operasi fire-and-forget, error internal bocor, bulk operation tanpa transaksi |
| Performance | 5/10 | Query terparameterisasi, tetapi ada N+1 dan banyak endpoint tanpa pagination |
| Testing dan operasional | 2/10 | Tidak ada automated test, lint, start script, health check, logging terstruktur, atau CI |

## 2. Gambaran Arsitektur

Alur aplikasi saat ini:

`Route -> middleware authenticate/role/profile -> controller -> model/service -> MySQL / Firebase / Gemini / SMTP`

Komponen utama:

- Express 5 sebagai HTTP API.
- MySQL melalui `mysql2/promise` connection pool.
- JWT access token dan refresh token tersimpan di database.
- Tiga peran: `kader`, `puskesmas`, dan `orang_tua`.
- Perhitungan WHO Z-score dan SAW dilakukan on-the-fly.
- Firebase Admin/FCM untuk push notification.
- Gemini untuk insight gizi.
- Nodemailer/Gmail SMTP untuk reset password.
- Cloudflare Turnstile dan rate limit untuk melindungi login web.

## 3. Temuan Prioritas

### CR-01 — Private key Firebase tercatat di Git

**Severity: Critical**  
**Bukti:** `firebase-service-account.json` berisi `private_key` dan masih tercatat oleh `git ls-files`. Riwayat Git juga menunjukkan commit yang secara eksplisit menambahkan credential tersebut. `.gitignore:4` hanya mencegah penambahan baru dan tidak menghapus file dari index atau riwayat.

**Dampak:** siapa pun yang memperoleh repository atau salinan history dapat menyalahgunakan identitas service account sesuai izin Google Cloud/Firebase yang melekat, termasuk pengiriman push atau akses resource proyek lain bila role terlalu luas.

**Tindakan wajib:**

1. Cabut dan rotasi key dari Google Cloud IAM sekarang; anggap key sudah bocor.
2. Hapus file dari tracking dan bersihkan seluruh history menggunakan `git filter-repo` atau BFG, lalu koordinasikan force-push dan re-clone.
3. Simpan credential melalui secret manager/variabel environment atau workload identity.
4. Batasi IAM service account hanya pada izin FCM yang diperlukan.

### HI-01 — IDOR pada riwayat pemberian anak

**Severity: High**  
**Bukti:** `src/routes/pemberian.js:17-20` mengizinkan peran `orang_tua` mengakses `GET /api/pemberian/anak/:anak_id`, sementara `src/controllers/pemberianController.js:102-114` mengambil anak berdasarkan ID tanpa memverifikasi `anak.orang_tua_id` terhadap akun yang login.

**Dampak:** orang tua dapat mengganti UUID anak dan membaca riwayat vitamin/obat/PMT anak lain. Response `AnakModel.findById` juga membawa nama orang tua, nomor telepon, dan alamat sehingga memperluas kebocoran PII keluarga dan data kesehatan anak.

**Rekomendasi:** hapus akses `orang_tua` dari route generik ini atau tambahkan `requireOrangTua` dan pemeriksaan ownership di query/model. Gunakan query scoped seperti `WHERE a.id = ? AND a.orang_tua_id = ?` agar pemeriksaan tidak terpisah dari pengambilan data.

### HI-02 — IDOR pada insight AI pengukuran

**Severity: High**  
**Bukti:** `src/routes/pengukuran.js:31` memberi akses orang tua ke `GET /api/pengukuran/:id/insight`; `src/controllers/pengukuranController.js:239-247` dan `src/services/geminiService.js:142-153` hanya mencari `pengukuran.id` tanpa memeriksa pemilik anak.

**Dampak:** orang tua dapat membaca insight kondisi gizi anak lain dengan enumerasi ID pengukuran yang berupa integer auto-increment, sehingga eksploitasi sangat mudah.

**Rekomendasi:** inject profil orang tua dan lakukan satu query join `pengukuran -> anak` dengan syarat `orang_tua_id`. Untuk resource yang tidak dimiliki, konsisten kembalikan 404 agar tidak membantu enumerasi.

### HI-03 — Refresh token tetap valid untuk akun nonaktif dan setelah reset password

**Severity: High**  
**Bukti:** `src/controllers/refreshTokenController.js:25-42` memvalidasi signature dan row token saja, lalu memakai `role` dari token tanpa mengambil status/role terbaru user. `src/controllers/authController.js:257-259` mengganti password saat reset tetapi tidak memanggil `RefreshTokenModel.revokeAllByUser`, berbeda dari alur change-password.

**Dampak:** akun yang dinonaktifkan masih dapat membuat access token baru hingga 30 hari. Refresh token yang dicuri juga tetap bisa dipakai setelah pemilik melakukan reset password.

**Rekomendasi:** saat refresh, join ke `users`, wajibkan `is_active = TRUE`, dan gunakan role terbaru dari database. Cabut seluruh refresh token setelah reset password. Terapkan rotation: setiap refresh mencabut token lama dan menerbitkan refresh token baru.

### HI-04 — Dependency produksi memiliki advisory critical/high

**Severity: High**  
**Bukti pemeriksaan 26 Agustus 2026:** `npm audit --omit=dev` menemukan **22 vulnerability: 2 critical, 6 high, 12 moderate, 2 low**. Temuan mencakup `protobufjs` dan `websocket-driver` (critical), serta direct dependency `axios` dan `nodemailer` beserta dependency transitif Firebase.

**Dampak:** potensi code execution, denial of service, prototype pollution, header/credential leak, dan masalah parsing. Sebagian dependency transitif mungkin tidak berada pada execution path aplikasi saat ini, tetapi tetap perlu ditriage dan diperbarui.

**Rekomendasi:** upgrade direct dependency ke versi patched terbaru, uji upgrade major `firebase-admin`, jalankan ulang audit, dan tambahkan dependency scanning pada CI. Jangan menjalankan `npm audit fix --force` tanpa regression test.

### HI-05 — Risiko gizi dapat salah pada usia di luar tabel WHO

**Severity: High (domain/clinical correctness)**  
**Bukti:** tabel BBU/TBU hanya mencakup 0–60 bulan. `src/services/zscoreService.js:64-67` dan `74-77` mengembalikan Z-score `0` jika referensi tidak ditemukan. Endpoint pembuatan anak tidak membatasi usia maksimal, dan pembuatan pengukuran tidak menolak tanggal ukur sebelum lahir/di masa depan atau usia di luar 0–60 bulan.

**Dampak:** anak di atas 60 bulan atau data tanggal salah dapat diklasifikasikan seolah-olah normal. Dalam sistem stunting, silent fallback ke nilai normal lebih berbahaya daripada menolak perhitungan.

**Rekomendasi:** jangan pernah fallback ke `0`; throw domain error yang eksplisit. Validasi tanggal kalender, `tanggal_ukur >= tanggal_lahir`, `tanggal_ukur <= hari ini`, dan rentang usia yang didukung. Tambahkan golden test menggunakan sampel resmi WHO.

### HI-06 — Skor tren berat badan mengabaikan interval waktu

**Severity: High (domain/clinical correctness)**  
**Bukti:** `src/services/sawService.js:27-58` mendeskripsikan threshold 200 gram per bulan, tetapi `src/services/pengukuranService.js:58-66` hanya mengurangi berat pengukuran sekarang dengan sebelumnya tanpa membagi/menormalisasi terhadap jumlah hari atau bulan antar pengukuran.

**Dampak:** kenaikan 200 gram dalam 2 hari dan 3 bulan dianggap identik. Ranking risiko dan keputusan apakah anak boleh dirujuk dapat berubah berdasarkan interval pencatatan, bukan kondisi klinis sebenarnya.

**Rekomendasi:** normalisasi delta menjadi gram per bulan menggunakan selisih tanggal, tetapkan kebijakan untuk interval terlalu pendek/panjang, dan validasi metode SAW bersama ahli gizi sebelum dipakai untuk keputusan rujukan.

### HI-07 — Tidak ada automated test untuk sistem yang memproses data kesehatan

**Severity: High**  
**Bukti:** `package.json:9-13` hanya memiliki script `dev`, `seed:generate`, dan `seed:run`; tidak ada file test, test runner, lint, coverage, atau CI.

**Dampak:** regresi otorisasi, formula Z-score/SAW, transaksi, dan perubahan schema tidak terdeteksi. Temuan IDOR dan drift seeder sangat mungkin lolos karena tidak ada integration test.

**Rekomendasi minimum:** unit test Z-score/SAW; integration test auth/role/ownership; test reset-refresh lifecycle; test constraint dan transaksi; contract test response; serta smoke test schema bersih + seeder.

## 4. Temuan Menengah

### ME-01 — Seeder tidak kompatibel dengan schema aktif

`src/database/schema.sql:84-100` tidak lagi memiliki kolom derived Z-score/SAW, tetapi `src/database/seeder/seeder.sql:163` dan banyak baris berikutnya masih menginsert kolom tersebut. Seeder juga menginsert `rujukan.anak_id`, padahal kolom itu sudah dihapus dari schema. Script `seed:run` menarget database `posyandu_pui`, sedangkan schema membuat `tumbuh_pp`. Akibatnya setup database baru tidak reproducible.

Selain itu, pola `.gitignore:3` adalah `database/seeder/seeder.sql`, sementara file sebenarnya berada di `src/database/seeder/seeder.sql`, sehingga file tetap tercatat Git.

### ME-02 — Error internal dibocorkan ke client

Terdapat sekitar **55** pemakaian `return error(res, err.message)` pada controller/middleware. Pesan driver MySQL atau integrasi eksternal dapat mengungkap nama tabel/kolom, constraint, dan detail internal. Gunakan error taxonomy, logger internal, correlation ID, dan pesan generik 500 kepada client. Global error handler saat ini hanya menangani malformed JSON dan meneruskan error lainnya ke handler default Express.

### ME-03 — Notifikasi pembatalan jadwal gagal secara desain

`src/controllers/jadwalController.js:369` menghapus jadwal lebih dahulu. Baris 371–384 kemudian memanggil FCM service dengan ID jadwal yang sudah tidak ada. `src/services/fcmService.js:44-57` mencoba menginsert `notifikasi.jadwal_id` tersebut, sehingga foreign key gagal sebelum push dikirim. Karena error ditelan oleh service/fire-and-forget, API tetap melaporkan sukses.

Solusi: catat/kirim notifikasi sebelum delete agar `ON DELETE SET NULL` bekerja, atau kirim notifikasi pembatalan tanpa foreign key jadwal. Gunakan outbox/job queue agar hasil dapat dipantau dan di-retry.

### ME-04 — Generate jadwal dapat menghasilkan bulan duplikat dan jumlah kurang

Pada `src/controllers/jadwalController.js:99-105`, iterasi pertama yang tanggal tetapnya sudah lewat digeser ke bulan berikutnya. Iterasi kedua juga menunjuk bulan berikutnya sehingga terjadi duplikasi dan salah satunya di-skip. Hitung bulan awal satu kali, kemudian tambah offset dari bulan awal tersebut.

### ME-05 — Validasi input tidak konsisten dan mudah menghasilkan 500

- Berat/tinggi menerima string nonnumerik karena perbandingan JavaScript terhadap `NaN` tidak masuk cabang invalid.
- Format regex `YYYY-MM-DD` tidak menjamin tanggal kalender valid.
- `tanggal_ukur` dan `tanggal_pemberian` tidak dicegah berada di masa depan.
- Panjang email, nama, catatan, lokasi, nomor HP, FCM token update, dan teks lain tidak konsisten dengan batas schema.
- Pembuatan akun orang tua membatasi password minimum tetapi tidak maksimum 72 byte seperti alur password lain.
- Duplicate-check dilakukan sebelum insert; race tetap mungkin terjadi dan DB error kemudian dikirim sebagai 500/internal message.

Gunakan schema validator terpusat (misalnya Zod/Joi/Valibot), normalisasi email, dan mapping error constraint MySQL menjadi 409.

### ME-06 — Status obesitas dashboard tidak pernah terisi

`ringkasanStatusGizi` di `src/services/zscoreService.js:130-150` mengembalikan hanya `buruk`, `kurang`, `lebih`, atau `normal`. Dashboard menyediakan bucket `obesitas`, tetapi hasil ringkasan tidak pernah menghasilkan nilai itu. Definisikan secara eksplisit apakah dashboard memakai BB/TB, BB/U, atau status gabungan; hindari status gabungan nonstandar yang tampak seperti diagnosis WHO.

### ME-07 — Query tanpa pagination dan pola N+1

Daftar orang tua, anak, rujukan, jadwal, dan ranking mengambil seluruh data. Ranking/distribusi memanggil `findPreviousBB` per anak, sehingga menghasilkan N+1 query. Broadcast jadwal menjalankan satu rangkaian DB+FCM per orang tua melalui `Promise.all` tanpa concurrency limit. Ini akan menurunkan latency, menghabiskan pool, atau terkena rate limit saat data bertambah.

Tambahkan pagination/filter/index yang sesuai, ambil previous measurement dengan window function/CTE, dan pindahkan broadcast ke queue dengan concurrency terkontrol.

### ME-08 — Refresh token disimpan dalam bentuk plaintext

`src/models/refreshTokenModel.js:6-17` menyimpan dan mencocokkan JWT refresh token mentah. Bila database bocor, token dapat langsung digunakan. Simpan hash SHA-256 token, tambahkan `jti`, metadata device, rotation/reuse detection, dan cleanup token expired.

### ME-09 — Konfigurasi proxy dan environment tidak divalidasi

`app.js:19` selalu mengatur `trust proxy = 1`. Jika aplikasi dapat diakses langsung tanpa tepat satu trusted proxy, client dapat memengaruhi IP yang dipakai rate limiter. Tidak ada startup validation untuk JWT secret, DB config, origin, mail, Gemini, dan Firebase. Konfigurasi salah baru gagal saat request berjalan.

Gunakan konfigurasi berdasarkan environment/topologi, validasi semua env saat boot, dan fail fast untuk secret wajib.

### ME-10 — Operasi bulk dan side effect tidak atomik

Generate jadwal melakukan insert satu per satu tanpa transaksi. Kegagalan di tengah loop meninggalkan sebagian data walaupun API berakhir 500. Notifikasi dan insight AI berjalan fire-and-forget di proses web; restart dapat menghilangkan job, dan caller tidak memiliki status job yang andal. Terapkan transaksi untuk perubahan database dan transactional outbox/queue untuk side effect eksternal.

## 5. Temuan Rendah dan Maintainability

- Tidak ada route 404 JSON, health/readiness endpoint, graceful shutdown, atau tes koneksi database saat startup.
- Tidak ada script `start`; deployment harus mengetahui langsung bahwa entry point adalah `app.js`.
- Logging masih memakai `console.*`, tidak terstruktur, tidak memiliki request/correlation ID, redaction, level, atau sink terpusat.
- API belum memiliki versioning (`/api/v1`) dan dokumentasi OpenAPI/README.
- Pengaturan jadwal disebut singleton tetapi database tidak memaksakan maksimum satu row; dua request paralel dapat membuat dua row.
- Pool database belum mengatur timezone, charset secara eksplisit, SSL produksi, atau observability.
- Tidak ada cleanup terjadwal untuk refresh token expired walaupun schema menyebutkannya.
- Reset URL membawa JWT pada query string; token dapat masuk browser history/log/referrer. Pertimbangkan fragment/one-time opaque token dan kebijakan referrer yang ketat di frontend.

## 6. Hal yang Sudah Baik

- Struktur route/controller/model/service mudah diikuti.
- Query yang ditinjau memakai placeholder, sehingga risiko SQL injection dasar rendah.
- Middleware autentikasi dan pembatasan role dipakai konsisten pada mayoritas route.
- Route khusus orang tua di `orangTuaController` sudah memeriksa ownership anak.
- Login menggunakan pesan generik untuk email/password salah dan memiliki rate limit berdasarkan IP serta email.
- Password memakai bcrypt dan perubahan password mencabut refresh token.
- Pembuatan akun `users` + `orang_tua` memakai transaksi dan release connection pada `finally`.
- Database memiliki foreign key, unique constraint, dan beberapa index yang relevan.
- Turnstile memiliki timeout dan validasi action; Gemini juga memiliki timeout dan retry terbatas.
- Data pengukuran mentah dipisahkan dari nilai turunan, sehingga perubahan formula tidak membutuhkan rewrite data historis.
- Seluruh **32 file JavaScript** yang diperiksa lolos `node --check` tanpa syntax error.

## 7. Rencana Remediasi

### containment

1. Rotate/cabut Firebase key dan audit activity service account.
2. Tutup dua IDOR: endpoint pemberian generik dan insight pengukuran.
3. Cabut seluruh refresh token setelah reset dan blok refresh untuk user nonaktif.
4. Upgrade dependency dengan advisory critical/high setelah membuat smoke test minimum.

### correctness dan stabilitas

1. Perbaiki fallback Z-score, validasi usia/tanggal/numerik, dan formula tren per bulan.
2. Perbaiki pembatalan/generate jadwal.
3. Samakan schema, generated seeder, nama database, dan path `.gitignore`.
4. Hentikan kebocoran `err.message`; buat centralized error handler.
5. Tambahkan integration test untuk ownership, token lifecycle, dan database bersih.

### production hardening

1. Tambahkan validation schema terpusat, security headers, logging terstruktur, health/readiness, graceful shutdown, dan env validation.
2. Terapkan pagination, optimasi N+1, queue/outbox, retry, dan observability.
3. Hash dan rotate refresh token, tambahkan audit event autentikasi.
4. Dokumentasikan OpenAPI, runbook deploy/backup/restore, serta kebijakan retensi dan perlindungan data kesehatan/PII.
5. Validasi formula Z-score/SAW dan wording insight AI bersama tenaga gizi; tampilkan disclaimer bahwa insight AI bukan diagnosis.

## 8. Strategi Pengujian yang Disarankan

### Unit

- Golden test LMS/Z-score untuk L/P, batas -3/-2/+2/+3, usia 0 dan 60 bulan.
- Reject usia >60 bulan, tanggal sebelum lahir, tanggal masa depan, dan nilai nonnumerik.
- SAW untuk interval 7/30/90 hari serta data pengukuran pertama.
- Transisi status rujukan dan perhitungan status dashboard.

### Integration/API

- Matriks seluruh route x tiga role x unauthenticated.
- Orang tua A tidak dapat membaca anak, pemberian, rujukan, pengukuran, insight, atau notifikasi orang tua B.
- User nonaktif tidak dapat login, memakai access token lama sesuai kebijakan, atau refresh.
- Reset/change password mencabut semua session.
- Request paralel untuk pengukuran/pemberian/rujukan/jadwal tetap menghasilkan state konsisten.
- Foreign key dan notifikasi pembatalan berjalan sesuai harapan.

### Database dan operasi

- Jalankan schema pada database kosong, jalankan seeder, lalu boot dan smoke test API.
- Uji migration forward/rollback, backup/restore, graceful shutdown, serta kegagalan Firebase/Gemini/SMTP.
- Load test ranking, dashboard, daftar data, dan broadcast pada volume target.

## 9. Hasil Pemeriksaan

| Pemeriksaan | Hasil |
|---|---|
| Inventaris source | 32 file JavaScript aplikasi, 10 route group, 11 tabel utama + pengaturan jadwal |
| `node --check` seluruh source JS | Lulus, 0 kegagalan |
| Automated test | Tidak tersedia |
| Lint/type check | Tidak tersedia |
| `npm audit --omit=dev` | Gagal karena 22 vulnerability: 2 critical, 6 high, 12 moderate, 2 low |
| Credential tracking | Firebase service account tercatat di Git dan history |
| Schema vs seeder | Tidak kompatibel |

## 10. Batasan Review

Review ini bersifat static/source review dan pemeriksaan dependency. Tidak dilakukan perubahan data, eksploitasi terhadap akun nyata, pengiriman FCM/email/Gemini, maupun pengujian end-to-end dengan database aktif karena tidak tersedia test harness dan environment terisolasi. Akurasi klinis metode SAW perlu validasi formal oleh ahli gizi; review ini hanya menunjukkan inkonsistensi implementasi terhadap asumsi yang tertulis di kode.
