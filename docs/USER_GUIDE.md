# Panduan Pengguna dan Demo

Panduan ini menjelaskan alur utama tiga role untuk demonstrasi proyek akhir. Gunakan database fixture dan tampilkan label berikut selama demo:

> **Data demonstrasi sintetis — bukan rekam medis.**

Sistem membantu pencatatan dan prioritas pemantauan. Sistem tidak membuat diagnosis, resep, atau keputusan rujukan otomatis.

## 1. Akses aplikasi

| Role | Aplikasi | Akun fixture |
|---|---|---|
| Kader | Dashboard Web `http://localhost:5173` | `riri.kader@example.test` |
| Puskesmas | Dashboard Web `http://localhost:5173` | `ciko.puskesmas@example.test` |
| Orang tua | Flutter Android | `aminah.orangtua@example.test` |

Password seluruh akun contoh: `password123`. Web memerlukan Turnstile yang sudah dikonfigurasi.

## 2. Alur kader

1. Login melalui dashboard Web.
2. Periksa ringkasan dashboard dan daftar prioritas pemantauan.
3. Buat atau cari orang tua, lalu kelola data anak di bawah wali yang benar.
4. Catat pengukuran fisik anak pada tanggal pemeriksaan.
5. Tinjau kategori antropometri, skor SAW risiko kekurangan gizi, dan prioritas pemantauan sebagai hasil yang berbeda.
6. Catat pemberian vitamin, obat cacing, atau PMT bila ada.
7. Buat rujukan secara manual bila penilaian petugas memerlukannya.
8. Kelola jadwal Posyandu dan unduh laporan sesuai kebutuhan demo.

Pengukuran anak pada tanggal yang sama tidak boleh diduplikasi. Data master dengan riwayat terkait dapat ditolak saat dihapus untuk melindungi konsistensi.

## 3. Alur puskesmas

1. Login melalui dashboard Web menggunakan akun puskesmas.
2. Tinjau statistik, tren, distribusi, serta daftar prioritas.
3. Buka detail anak dan riwayat pengukuran teknis.
4. Buka rujukan berstatus `diajukan`.
5. Ubah menjadi `ditangani` ketika tindak lanjut dimulai dan tambahkan catatan.
6. Ubah menjadi `selesai` setelah proses selesai.
7. Gunakan laporan teknis untuk demonstrasi monitoring.

Puskesmas bersifat monitoring/tindak lanjut dan tidak memperoleh menu pembuatan data yang khusus kader.

## 4. Alur orang tua Android

1. Jalankan Android dengan config API yang sesuai, lalu login menggunakan akun orang tua.
2. Pilih anak milik akun.
3. Tinjau ringkasan dan riwayat pertumbuhan.
4. Buka jadwal, riwayat pemberian, status rujukan, notifikasi, atau laporan.
5. Buka insight pengukuran dan chat edukatif bila Gemini tersedia.

Orang tua hanya menerima data miliknya dan versi informasi yang aman. Detail Z-score, skor/bobot SAW, peringkat, serta kode alasan internal tidak ditampilkan.

## 5. Arti hasil pemantauan

| Label orang tua | Makna operasional |
|---|---|
| Pemantauan rutin | Lanjutkan pemantauan terjadwal; bukan pernyataan bahwa tidak ada masalah kesehatan |
| Perlu perhatian | Petugas perlu memberi perhatian lebih pada pemantauan dan komunikasi tindak lanjut |
| Disarankan konsultasi | Tingkat perhatian tertinggi aplikasi; konsultasikan kepada kader/petugas kesehatan |

Prioritas akhir mengambil tingkat tertinggi antara kategori SAW dan minimum berdasarkan kategori antropometri. Prioritas tinggi tidak otomatis membuat rujukan dan tidak membuktikan diagnosis tertentu.

Status rujukan:

| Status | Arti |
|---|---|
| `diajukan` | Kader telah mengajukan tindak lanjut |
| `ditangani` | Puskesmas mulai menangani dan dapat memberi catatan |
| `selesai` | Proses tindak lanjut ditandai selesai |

## 6. Batas AI

Insight dan chat memberikan edukasi umum berdasarkan konteks yang dibatasi backend. Jangan memasukkan nama, NIK, alamat, telepon, email, credential, atau data sensitif lain ke chat.

AI tidak boleh:

- menentukan diagnosis;
- memberi resep atau dosis individual;
- menggantikan pemeriksaan tenaga kesehatan;
- menentukan atau membuat rujukan otomatis.

Jika jawaban tampak tidak sesuai, hentikan penggunaannya dan konsultasikan kepada tenaga kesehatan.

## 7. Urutan demo yang disarankan

1. Tampilkan label data sintetis dan jelaskan scope lokal.
2. Login sebagai kader, tunjukkan data master dan buat pengukuran fixture.
3. Jelaskan perbedaan antropometri, SAW, dan prioritas pemantauan.
4. Buat rujukan serta tampilkan laporan.
5. Login sebagai puskesmas dan demonstrasikan tindak lanjut rujukan.
6. Buka Android sebagai orang tua dan tunjukkan pemisahan data teknis.
7. Tampilkan jadwal/notifikasi dan AI hanya bila integrasi siap.
8. Tutup dengan batasan: bukan diagnosis, data sintetis, local-first, iOS roadmap.

Untuk persiapan teknis lihat [Setup Lokal](./LOCAL_SETUP.md). Aturan kontrak lengkap berada di [indeks backend](../backend-express/docs/README.md).

