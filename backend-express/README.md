<div align="center">

<img src="../web-dashboard/src/assets/tumbuh.png" alt="Logo Tumbuh Posyandu" width="92" />

# Backend Tumbuh Posyandu

**REST API dan pusat aturan bisnis untuk seluruh ekosistem Tumbuh Posyandu.**

![Runtime](https://img.shields.io/badge/Node.js-22-339933?style=flat-square&logo=nodedotjs&logoColor=white)
![Framework](https://img.shields.io/badge/Express-5-111827?style=flat-square&logo=express&logoColor=white)
![Database](https://img.shields.io/badge/MySQL-8-4479A1?style=flat-square&logo=mysql&logoColor=white)
![AI](https://img.shields.io/badge/Gemini-AI-8E75B2?style=flat-square&logo=googlegemini&logoColor=white)
![DSS](https://img.shields.io/badge/DSS-SAW-0A8754?style=flat-square)

[Setup](#setup-backend) · [Route](#route-backend) · [Command](#command-backend) · [Dokumentasi](#dokumentasi-backend)

</div>

Backend menangani autentikasi, otorisasi tiga role, data Posyandu, perhitungan antropometri, DSS SAW untuk prioritas pemantauan, laporan PDF, notifikasi, serta Conversational AI Gemini. Kontrak request/response terperinci berada di [indeks dokumentasi backend](./docs/README.md).

## ✨ Tanggung jawab utama

- autentikasi access/refresh token dan pembatasan platform berdasarkan role;
- pengelolaan orang tua, anak, pengukuran, pemberian, rujukan, dan jadwal;
- perhitungan Z-score dari tabel WHO dan prioritas pemantauan dengan SAW;
- dashboard dan laporan PDF untuk role yang berwenang;
- penyajian data milik orang tua melalui response yang dibatasi;
- antrean notifikasi FCM serta insight dan chat edukatif Gemini.

Perhitungan dan AI adalah alat bantu pemantauan/edukasi, bukan diagnosis medis.

## ✅ Prasyarat

- Node.js `22` dan npm;
- MySQL lokal yang aktif;
- API key Gemini untuk fitur insight dan Conversational AI.

<a id="setup-backend"></a>

## 🚀 Setup lokal

```powershell
npm install
Copy-Item .env.example .env
```

Edit `.env` lokal. Variable minimum untuk startup:

- `DB_HOST`, `DB_USER`, `DB_NAME`, serta `DB_PASSWORD` bila diperlukan;
- `JWT_SECRET` dan `JWT_REFRESH_SECRET`, berbeda dan masing-masing minimal 32 karakter;
- `CORS_ORIGIN`, default lokal diarahkan ke dashboard `http://localhost:5173`.

Lengkapi juga `GEMINI_API_KEY` atau `GEMINI_API_KEYS`, Turnstile, SMTP, dan Firebase agar seluruh integrasi berjalan. Jangan commit `.env`, service account, atau credential aktual. Penjelasan keamanan berada di [Security dan Privacy](../docs/SECURITY_AND_PRIVACY.md).

### Inisialisasi database

Pastikan MySQL aktif dan akun pada `.env` dapat membuat database, lalu jalankan:

```powershell
npm run db:setup
```

Command tersebut membuat database bila belum tersedia, menjalankan `src/database/schema.sql`, lalu mengisi fixture dari `src/database/seeder/seeder.sql`. Seeder melakukan reset tabel terkait; jangan gunakan terhadap database berisi data penting.

Untuk menjalankan kembali seeder pada schema yang sudah tersedia:

```powershell
npm run seed:run
```

Jika fixture perlu dibuat ulang dari generator:

```powershell
npm run seed:generate
npm run seed:run
```

Seeder berisi data sintetis dengan domain email `example.test`, bukan data orang nyata.

### Menjalankan API

```powershell
npm run dev
```

Server menggunakan `http://localhost:3000` secara default. Pemeriksaan proses dan dependency:

```powershell
Invoke-RestMethod http://localhost:3000/api/health/live
Invoke-RestMethod http://localhost:3000/api/health/ready
```

- `live` memastikan proses HTTP aktif.
- `ready` memeriksa database dan kesiapan AI; HTTP `503` dapat terjadi jika Gemini atau database belum siap walaupun proses backend hidup.

<a id="route-backend"></a>

## 🧭 Route group dan role

| Prefix | Akses utama | Fungsi |
|---|---|---|
| `/api/auth` | Publik/terautentikasi | Login, forgot/reset/change password, refresh, dan logout |
| `/api/kader` | Kader | Profil serta pengelolaan orang tua dan anak |
| `/api/puskesmas` | Puskesmas | Profil dan monitoring data anak |
| `/api/pengukuran` | Kader, puskesmas; insight terbatas orang tua | Pencatatan, riwayat, Z-score, SAW, dan insight |
| `/api/pemberian` | Kader/puskesmas sesuai aksi | Riwayat vitamin, obat cacing, dan PMT |
| `/api/rujukan` | Kader/puskesmas sesuai aksi | Pembuatan, monitoring, dan tindak lanjut rujukan |
| `/api/jadwal` | Semua role sesuai aksi | Jadwal Posyandu; perubahan dibatasi untuk kader |
| `/api/orang-tua` | Orang tua | Data milik sendiri, notifikasi, FCM token, insight, dan chat |
| `/api/dashboard` | Kader dan puskesmas | Statistik, distribusi, tren, dan prioritas |
| `/api/laporan` | Semua role sesuai jenis/kepemilikan | PDF individual dan rekap |

Backend tetap memverifikasi bearer token, status akun, role terbaru, dan kepemilikan resource. UI bukan batas keamanan utama.

## ⚙️ Worker dalam proses

Saat `app.js` dijalankan langsung, proses yang sama juga menjalankan:

- pemrosesan notification outbox setiap 30 detik;
- cleanup refresh token saat startup dan setiap 6 jam;
- insight worker dengan interval dari konfigurasi service AI.

Seluruh worker tersebut berjalan bersama proses backend sehingga pemrosesan notifikasi, pembersihan token, dan pembuatan insight aktif saat API dijalankan.

<a id="command-backend"></a>

## 🧪 Command pengembangan

| Command | Fungsi |
|---|---|
| `npm run dev` | Menjalankan API dengan Nodemon |
| `npm test` | Menjalankan seluruh test Node |
| `npm run db:setup` | Membuat schema dan mengisi data demonstrasi |
| `npm run seed:run` | Menjalankan seeder yang sudah tersedia |
| `npm run seed:generate` | Menghasilkan ulang `seeder.sql` sintetis |
| `npm run report:preview` | Membuat preview laporan sintetis di temporary directory atau path argumen |
| `npm run ai:smoke` | Menguji panggilan Gemini dengan konteks sintetis |
| `npm run ai:smoke:e2e` | Menguji alur chat melalui API dan database lokal |

`ai:smoke` membutuhkan API key Gemini. `ai:smoke:e2e` juga membutuhkan database berisi akun orang tua dan pengukuran aktif; data chat sintetis pengujian dibersihkan kembali oleh script.

Script `db:migrate:*` tersedia untuk perubahan database tertentu. Untuk instalasi awal, gunakan `npm run db:setup` agar schema dan data demonstrasi siap digunakan.

<a id="dokumentasi-backend"></a>

## 📚 Dokumentasi API dan policy

- [Indeks kontrak dan policy](./docs/README.md)
- [Conversational AI API](./docs/CONVERSATIONAL_AI_API.md)
- [Conversational AI Policy](./docs/CONVERSATIONAL_AI_POLICY.md)
- [Policy data teknis orang tua](./docs/DATA_TEKNIS_UX_SECURITY_POLICY.md)
- [Kontrak laporan](./docs/LAPORAN_API.md)
- [Kontrak prioritas pemantauan](./docs/PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md)

Data yang dikirim ke AI harus tetap berupa konteks minimum yang diizinkan policy dan tidak boleh memuat identitas langsung anak/orang tua.

## 🛠️ Troubleshooting lokal

| Gejala | Pemeriksaan |
|---|---|
| Startup menolak environment | Bandingkan `.env` dengan `.env.example`; pastikan variable wajib dan dua JWT secret valid |
| Koneksi MySQL gagal | Pastikan service aktif, port/user/password benar, dan user boleh membuat database |
| `ready` mengembalikan `503` | Periksa detail response; database atau konfigurasi Gemini mungkin belum siap |
| Browser menerima error CORS | Pastikan origin dashboard persis tercantum pada `CORS_ORIGIN` tanpa path |
| Login Web gagal pada Turnstile | Cocokkan `TURNSTILE_SECRET_KEY`, hostname lokal, dan site key dashboard |
| Email/AI/notifikasi tidak berjalan | Periksa konfigurasi SMTP, Gemini, atau Firebase; integrasi tersebut bukan mock otomatis |

Untuk setup seluruh project, kembali ke [README root](../README.md). Panduan konfigurasi lengkap berada di [dokumentasi project](../docs/README.md).

---

<div align="center">
  <sub>Bagian dari <a href="../README.md">Tumbuh Posyandu</a></sub>
</div>
