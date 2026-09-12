# Laporan Perbaikan Temuan Menengah Backend

> **Status dokumen: HISTORIS — perubahan utama telah diterapkan.** Dokumen ini merekam perbaikan temuan Agustus 2026. Angka test di bawah adalah snapshot; gunakan [evidence terbaru](../../../../docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md).

**Sistem:** Tumbuh Posyandu / Backend Express  
**Tanggal:** 26 Agustus 2026  
**Cakupan:** seluruh temuan severity menengah pada [baseline review](./backend-review-report.md).

## Ringkasan

Seluruh sepuluh kelompok temuan menengah telah ditangani pada source code. Perubahan mencakup konsistensi schema/seeder, error handling aman, perbaikan jadwal dan notifikasi, validasi request terpusat, klasifikasi obesitas, pagination dan optimasi query, hashing refresh token, validasi environment, transaksi, dan notification outbox.

Proyek menggunakan strategi **fresh database setup** karena seluruh data masih berupa data testing. Tidak ada migration atau kompatibilitas dengan schema lama yang perlu dipertahankan.

## ME-01 — Schema dan seeder tidak konsisten

Status: **Diperbaiki**

- Seeder diregenerasi dari generator terbaru dan hanya menyimpan raw measurement serta insight.
- Insert legacy untuk kolom Z-score/SAW dan `rujukan.anak_id` sudah tidak ada.
- Nama database tidak lagi di-hardcode pada script `seed:run`.
- `seed:run` sekarang memakai konfigurasi `DB_*` melalui `mysql2`.
- Urutan truncate mencakup `notification_outbox` sebelum tabel induknya.
- Generator tidak lagi mencetak password seed ke console.

Perintah:

```text
npm run seed:generate
npm run db:setup
```

`db:setup` membuat database jika belum ada, menjalankan schema terbaru, lalu menjalankan seeder. Data lama akan dihapus oleh generated seeder.

## ME-02 — Error internal bocor ke client

Status: **Diperbaiki**

- Response dengan status 500 selalu memakai pesan generik `Terjadi kesalahan server`.
- Detail error tetap dicatat pada log server.
- Global error handler sekarang menangani seluruh uncaught error, bukan hanya malformed JSON.
- Ditambahkan JSON 404 handler dan request ID melalui header `X-Request-Id`.
- Batas JSON body ditetapkan 100 KB.

## ME-03 — Notifikasi pembatalan jadwal gagal

Status: **Diperbaiki**

- Notifikasi pembatalan tidak lagi menyimpan foreign key ke jadwal yang sudah dihapus.
- Notifikasi tetap tercatat sebagai pesan jadwal dengan `jadwal_id = NULL`.
- Broadcast sekarang ditunggu sampai minimal pencatatan database/outbox selesai.

## ME-04 — Generate jadwal menghasilkan bulan duplikat

Status: **Diperbaiki**

- Bulan awal dihitung satu kali.
- Jika hari tetap bulan berjalan sudah lewat, seluruh sequence dimulai dari bulan berikutnya.
- Format tanggal memakai kalender lokal dan tidak lagi bergantung pada `toISOString()` yang dapat bergeser karena timezone.
- Bulk insert jadwal memakai satu transaksi dan `INSERT IGNORE` terhadap unique date.
- Ditambahkan regression test untuk kasus tanggal 26 dengan hari tetap tanggal 5.

## ME-05 — Validasi input tidak konsisten

Status: **Diperbaiki**

- Ditambahkan middleware validasi dependency-free dan schema request terpusat.
- Validasi diterapkan pada autentikasi, kader/orang tua, anak, pengukuran, pemberian, rujukan, jadwal, dan FCM token.
- Email dinormalisasi menjadi lowercase dan trim.
- Password dibatasi 6–72 karakter.
- Tanggal diverifikasi sebagai tanggal kalender nyata.
- Waktu diverifikasi pada rentang `00:00–23:59` dan waktu selesai harus setelah waktu mulai.
- Panjang teks diselaraskan dengan batas schema.
- Numeric input dinormalisasi dan dibatasi.

## ME-06 — Bucket obesitas tidak pernah terisi

Status: **Diperbaiki**

- Ringkasan gizi sekarang mengembalikan `obesitas` ketika Z-score BB/TB lebih dari +3.
- Nilai +2 sampai +3 tetap dipetakan ke `lebih`.
- Ditambahkan regression test yang memastikan `status_bbtb` dan `status_gizi` sama-sama dapat menghasilkan `obesitas`.

## ME-07 — Endpoint tanpa pagination dan query N+1

Status: **Diperbaiki**

Pagination ditambahkan pada:

- daftar orang tua;
- daftar anak untuk kader dan puskesmas;
- daftar rujukan;
- daftar jadwal;
- ranking risiko anak.

Parameter query:

```text
?page=1&limit=20
```

Limit maksimum adalah 100. Response sekarang berbentuk:

```json
{
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 0,
      "total_pages": 0
    }
  }
}
```

Pengukuran terbaru dan pengukuran sebelumnya diambil dalam satu query menggunakan window function. Ranking dan distribusi risiko tidak lagi menjalankan `findPrevious` satu kali per anak.

## ME-08 — Refresh token disimpan plaintext

Status: **Diperbaiki**

- Refresh token diubah menjadi SHA-256 sebelum disimpan atau dicocokkan.
- Kolom database diganti dari `token` menjadi `token_hash CHAR(64)`.
- Schema fresh menggunakan kolom `token_hash` sejak awal.
- Token mentah hanya diberikan kepada client dan tidak disimpan server.

## ME-09 — Proxy dan environment tidak divalidasi

Status: **Diperbaiki**

- Startup memvalidasi konfigurasi database, JWT secret, CORS, port, dan jumlah proxy hop.
- JWT secret wajib memiliki minimal 32 karakter.
- `TRUST_PROXY_HOPS=0` menjadi default aman untuk akses langsung.
- Deployment di belakang tepat satu reverse proxy harus mengatur `TRUST_PROXY_HOPS=1`.
- Pool database menetapkan `utf8mb4`, UTC timezone, dan TCP keepalive.
- Ditambahkan liveness, readiness, graceful shutdown, dan export Express app untuk testing.

Health endpoints:

```text
GET /api/health/live
GET /api/health/ready
```

## ME-10 — Bulk operation dan side effect tidak atomik

Status: **Diperbaiki**

- Generate jadwal memakai transaksi database.
- Pembuatan rujukan mengunci row anak sehingga dua request paralel tidak dapat membuat dua rujukan aktif.
- Pengaturan jadwal menggunakan singleton key unik dan atomic upsert.
- Penyimpanan notifikasi dan outbox dilakukan dalam satu transaksi.
- Push FCM gagal disimpan untuk retry dengan exponential backoff, maksimal lima percobaan.
- Worker memproses outbox setiap 30 detik dengan concurrency lima.
- Item `processing` yang terhenti lebih dari lima menit dikembalikan ke status `pending`.
- Broadcast jadwal memakai concurrency terkontrol, bukan `Promise.all` tanpa batas.

## Fresh Database Setup

Pastikan konfigurasi `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_PORT`, dan `DB_NAME` sudah benar. Nama database hanya boleh berisi huruf, angka, dan underscore.

Jalankan:

```text
npm run seed:generate
npm run db:setup
```

`db:setup` akan:

- membuat database dengan charset `utf8mb4` jika belum tersedia;
- menjalankan seluruh `schema.sql`, termasuk singleton jadwal, `token_hash`, dan notification outbox;
- menghapus data testing lama melalui seeder;
- mengisi ulang akun, anak, pengukuran, pemberian, rujukan, jadwal, dan notifikasi testing.

Jika hanya ingin mengisi ulang database yang schemanya sudah benar, gunakan:

```text
npm run seed:run
```

## Perubahan Kontrak API

Frontend perlu menyesuaikan response endpoint daftar dan ranking dari array langsung menjadi `{ items, pagination }`.

Input yang sebelumnya diterima secara longgar sekarang dapat menghasilkan HTTP 400, terutama:

- email tidak valid;
- password lebih dari 72 karakter;
- tanggal kalender invalid atau jadwal masa lalu;
- waktu di luar format 24 jam;
- teks melebihi batas schema;
- angka di luar rentang yang diizinkan.

## Verifikasi

| Pemeriksaan | Hasil |
|---|---|
| Regression test | 13 lulus, 0 gagal |
| Syntax check seluruh JavaScript | 0 kegagalan |
| Import aplikasi | Berhasil |
| Diff whitespace | Bersih |
| Seeder legacy columns | Tidak ditemukan |
| Private key working tree | Tidak ditemukan pada pemeriksaan sebelumnya |

## Batasan

- Fresh database setup belum dijalankan karena service MySQL lokal tidak aktif (`ECONNREFUSED`).
- Integration test dengan MySQL dan Firebase emulator belum tersedia; transaksi dan SQL telah diperiksa statis serta melalui syntax/import test.
- Window function pada query pengukuran memerlukan MySQL 8 atau versi kompatibel.
- Enam advisory dependency moderate transitif Firebase/Google Cloud dari audit sebelumnya masih menunggu patch upstream yang tidak memerlukan downgrade Firebase.
