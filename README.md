<div align="center">

<img src="./web-dashboard/src/assets/tumbuh.png" alt="Logo Tumbuh Posyandu" width="120" />

# Tumbuh Posyandu

**EKOSISTEM DIGITAL POSYANDU BERBASIS WEB MOBILE TERINTEGRASI SISTEM PENDUKUNG KEPUTUSAN DAN CONVERSATIONAL AI.**

![Vue.js](https://img.shields.io/badge/Vue.js-3-42B883?style=flat-square&logo=vuedotjs&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?style=flat-square&logo=flutter&logoColor=white)
![Express](https://img.shields.io/badge/Express-5-111827?style=flat-square&logo=express&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8-4479A1?style=flat-square&logo=mysql&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-Conversational%20AI-8E75B2?style=flat-square&logo=googlegemini&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?style=flat-square&logo=firebase&logoColor=111827)

[Mulai cepat](#mulai-cepat) · [Fitur](#fitur-utama) · [Arsitektur](#arsitektur) · [Database](#database-project) · [Dokumentasi](#dokumentasi-project)

</div>

Tumbuh Posyandu menghubungkan dashboard Web untuk kader dan petugas puskesmas dengan aplikasi Android untuk orang tua melalui REST API terpusat. Seluruh alur data, pemantauan pertumbuhan, rekomendasi prioritas, notifikasi, laporan, dan edukasi digital berada dalam satu ekosistem yang terintegrasi.

Project ini dikembangkan sebagai karya akademik untuk mata kuliah **Proyek Utama Informatika**, **Proyek Profesional**, dan **Tugas Akhir**.

> [!IMPORTANT]
> **Data demonstrasi sintetis — bukan rekam medis.** Jangan memasukkan identitas atau data kesehatan orang nyata ke environment ini.

| 🌐 Web Dashboard | 📱 Mobile App | 📊 DSS SAW | 💬 Conversational AI |
|---|---|---|---|
| Operasional kader dan monitoring puskesmas | Informasi pertumbuhan untuk orang tua | Prioritas pemantauan anak | Edukasi dan insight melalui Gemini |

## 🎯 Tujuan

Pencatatan Posyandu yang tersebar menyulitkan petugas melihat riwayat pertumbuhan, menentukan anak yang perlu dipantau lebih dahulu, dan menyampaikan informasi yang sesuai kepada orang tua. Project ini mendigitalisasi proses tersebut melalui pencatatan layanan, evaluasi antropometri berbasis standar WHO, prioritas pemantauan, rujukan, laporan, notifikasi, dan edukasi pendamping dalam satu sistem.

> [!TIP]
> **Nilai utama project:** integrasi operasional Posyandu berbasis Web dan Mobile, pengambilan keputusan menggunakan **DSS metode Simple Additive Weighting (SAW)**, serta layanan edukasi melalui **Conversational AI Gemini**.

Hasil perhitungan dan AI di dalam aplikasi adalah alat bantu pemantauan dan edukasi, bukan diagnosis atau pengganti keputusan tenaga kesehatan.

<a id="fitur-utama"></a>

## ✨ Pengguna dan fitur utama

| Role | Platform | Fitur utama |
|---|---|---|
| Kader | Web | Mengelola orang tua dan anak, mencatat pengukuran serta pemberian, membuat rujukan dan jadwal, melihat prioritas pemantauan, dan mengunduh laporan |
| Puskesmas | Web | Memantau dashboard, data pertumbuhan, prioritas dan rujukan, memperbarui tindak lanjut, serta mengunduh laporan teknis |
| Orang tua | Android | Melihat anak dan riwayat pertumbuhan milik sendiri, jadwal, pemberian, status rujukan, notifikasi, laporan, insight, serta percakapan edukatif berbasis AI |

Fitur lintas sistem meliputi:

- status antropometri berdasarkan referensi WHO;
- prioritas pemantauan dengan metode SAW;
- autentikasi dan pembatasan akses berdasarkan role serta kepemilikan data;
- laporan PDF individual dan rekap;
- antrean notifikasi FCM;
- insight dan percakapan edukatif melalui Gemini.

<a id="arsitektur"></a>

## 🧩 Arsitektur dan teknologi

```text
Web Vue (kader/puskesmas) ─┐
                           ├── REST API Express ── MySQL
Android Flutter (orang tua)┘          │
                                      ├── Gemini Conversational AI
                                      ├── Firebase Cloud Messaging
                                      ├── SMTP
                                      └── Cloudflare Turnstile (login Web)
```

| Bagian | Teknologi utama | Port lokal default |
|---|---|---|
| Backend | Node.js, Express 5, MySQL2 | `3000` |
| Dashboard | Vue 3, Vite, Pinia, PrimeVue | `5173` |
| Mobile | Flutter, Riverpod, Dio, Firebase | Android emulator/perangkat |
| Data WHO | Tool Node.js + ExcelJS | Offline, tanpa service port |
| Database | MySQL | `3306` |

<a id="database-project"></a>

## 🗄️ Struktur database

Tumbuh Posyandu menggunakan MySQL sebagai penyimpanan terpusat untuk akun, profil pengguna, data anak, layanan Posyandu, notifikasi, serta riwayat interaksi Conversational AI. Database terdiri dari 14 tabel utama:

| Tabel | Kelompok | Fungsi |
|---|---|---|
| `users` | Akun | Menyimpan email, hash password, role, dan status akun seluruh pengguna |
| `kader` | Profil | Menyimpan identitas dan profil kader Posyandu |
| `puskesmas` | Profil | Menyimpan identitas dan profil petugas puskesmas |
| `orang_tua` | Profil | Menyimpan profil wali, identitas keluarga, dan token notifikasi perangkat |
| `anak` | Data anak | Menyimpan identitas anak yang terhubung dengan akun orang tua |
| `pengukuran` | Pertumbuhan dan DSS | Menyimpan berat badan, tinggi badan, lingkar kepala, lingkar lengan, serta data pemrosesan insight |
| `pemberian` | Layanan Posyandu | Mencatat pemberian vitamin, obat cacing, dan makanan tambahan |
| `rujukan` | Layanan Posyandu | Menyimpan pengajuan, penanganan, dan penyelesaian rujukan anak |
| `pengaturan_jadwal` | Jadwal | Menyimpan konfigurasi jadwal default kegiatan Posyandu |
| `jadwal_posyandu` | Jadwal | Menyimpan jadwal pelaksanaan dan status pengiriman reminder H-1 serta hari-H |
| `chat_messages` | Conversational AI | Menyimpan percakapan edukatif antara orang tua dan Gemini berdasarkan konteks pengukuran |
| `notifikasi` | Informasi | Menyimpan inbox notifikasi untuk orang tua |
| `notification_outbox` | Sistem | Mengelola antrean dan percobaan pengiriman notifikasi Firebase Cloud Messaging |
| `refresh_tokens` | Keamanan | Menyimpan hash refresh token untuk menjaga sesi aplikasi Android |

Data fisik disimpan pada tabel `pengukuran`. Backend kemudian menghitung usia, IMT, Z-score antropometri berdasarkan standar WHO, skor DSS SAW, dan tingkat prioritas pemantauan. Dengan pendekatan ini, Web dan Mobile memperoleh hasil perhitungan yang konsisten dari satu sumber data.

Relasi tabel, aturan foreign key, dan proses inisialisasi dijelaskan lebih lengkap pada [Dokumentasi Database](./docs/DATABASE.md).

## 📁 Struktur repository

```text
project-kuliah-pui/
├── backend-express/   # REST API, schema, seeder, worker, dan test backend
├── web-dashboard/     # Dashboard Web untuk kader dan puskesmas
├── tumbuhapp/         # Aplikasi Flutter untuk Android
├── who-converter/     # Generator data referensi antropometri WHO
└── docs/              # Dokumentasi lintas komponen dan release records
```

## ✅ Prasyarat lokal

- Git;
- Node.js `22` dan npm;
- MySQL lokal; schema project menggunakan fitur MySQL dan charset `utf8mb4`;
- Flutter `3.44.2` stable, JDK `17`, Android SDK, serta emulator atau perangkat Android;
- konfigurasi Firebase Android untuk fitur mobile;
- API key Gemini untuk fitur Conversational AI dan insight;
- site key dan secret Cloudflare Turnstile yang cocok untuk login Web.

Siapkan konfigurasi SMTP, Gemini, Firebase, dan Turnstile agar seluruh fitur integrasi dapat digunakan. Jangan menyimpan credential aktual di repository.

<a id="mulai-cepat"></a>

## 🚀 Quick start

Contoh berikut menggunakan PowerShell. Setelah repository selesai di-clone, buka tiga terminal pada root repository untuk menjalankan backend, dashboard Web, dan aplikasi Android.

### 1. Clone repository

```powershell
git clone https://github.com/HafizhHabiibi/tumbuh-digital-ecosystem.git
Set-Location tumbuh-digital-ecosystem
```

### 2. Siapkan database dan backend

```powershell
Set-Location backend-express
npm install
Copy-Item .env.example .env
```

Edit `backend-express/.env`, terutama koneksi MySQL, `JWT_SECRET`, `JWT_REFRESH_SECRET`, `CORS_ORIGIN`, `GEMINI_API_KEY` atau `GEMINI_API_KEYS`, Firebase, SMTP, dan Turnstile. Kedua JWT secret wajib berbeda dan masing-masing minimal 32 karakter.

Pastikan service MySQL aktif, lalu buat schema dan isi data demo:

```powershell
npm run db:setup
npm run dev
```

`npm run db:setup` menjalankan schema dan seeder untuk database demo. Seeder melakukan reset isi tabel terkait; jangan arahkan command ini ke database yang berisi data penting.

Backend tersedia di `http://localhost:3000`. Pemeriksaan dasar:

```powershell
Invoke-RestMethod http://localhost:3000/api/health/live
Invoke-RestMethod http://localhost:3000/api/health/ready
```

Endpoint `live` membuktikan proses aktif. Endpoint `ready` dapat mengembalikan status belum siap ketika database atau Gemini belum dikonfigurasi lengkap.

### 3. Jalankan dashboard Web

```powershell
Set-Location web-dashboard
npm install
Copy-Item .env.example .env
npm run dev
```

Dashboard tersedia di `http://localhost:5173` dan menggunakan API `http://localhost:3000/api`. Isi `VITE_TURNSTILE_SITE_KEY` dengan site key yang cocok dengan `TURNSTILE_SECRET_KEY` backend; tanpa pasangan yang valid, login dan forgot-password Web tidak dapat diselesaikan.

### 4. Jalankan aplikasi Android

Untuk emulator Android:

```powershell
Set-Location tumbuhapp
flutter pub get
flutter run --dart-define-from-file=config/development-emulator.json
```

Konfigurasi tersebut menggunakan `http://10.0.2.2:3000/api`, yaitu alamat host komputer dari Android emulator.

Untuk perangkat fisik, salin `config/development-device.example.json` menjadi `config/development-device.json`, lalu ganti IP contoh dengan alamat LAN komputer. Perangkat dan komputer harus berada pada jaringan yang sama.

```powershell
Copy-Item config/development-device.example.json config/development-device.json
flutter run --dart-define-from-file=config/development-device.json
```

HTTP lokal hanya diizinkan pada build Android debug. Detail konfigurasi mobile berada di [README aplikasi](./tumbuhapp/README.md).

## 🔐 Akun demo

Seeder menyediakan akun sintetis berikut:

| Role | Email | Password | Platform |
|---|---|---|---|
| Kader | `riri.kader@example.test` | `password123` | Web |
| Puskesmas | `ciko.puskesmas@example.test` | `password123` | Web |
| Orang tua | `aminah.orangtua@example.test` | `password123` | Android |

Seluruh nama, email domain `example.test`, NIK, alamat, pengukuran, dan riwayat pada seeder adalah fixture demonstrasi. Password tersebut hanya untuk penggunaan lokal dan tidak boleh digunakan pada deployment nyata.

## 🧪 Quality gate

Jalankan pemeriksaan sesuai komponen yang diubah:

```powershell
# Backend
Set-Location backend-express
npm test

# Web
Set-Location ..\web-dashboard
npm run check

# Android
Set-Location ..\tumbuhapp
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Verifikasi final dokumentasi pada 12 September 2026 mencatat 262 test backend, 68 test Web, 126 test Flutter, dan 4 test WHO converter lulus; lint/build Web, format/analyzer Flutter, serta debug APK build juga lulus. Lihat [Documentation Final Review Evidence](./docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md) untuk konteks dan batas pembuktiannya.

<a id="dokumentasi-project"></a>

## 🧭 Dokumentasi

- [Indeks dokumentasi](./docs/README.md)
- [Setup lokal](./docs/LOCAL_SETUP.md)
- [Arsitektur](./docs/ARCHITECTURE.md)
- [Konfigurasi](./docs/CONFIGURATION.md)
- [Database](./docs/DATABASE.md)
- [Pengujian](./docs/TESTING.md)
- [Panduan pengguna dan demo](./docs/USER_GUIDE.md)
- [Security dan privacy](./docs/SECURITY_AND_PRIVACY.md)
- [Indeks kontrak dan policy backend](./backend-express/docs/README.md)
- [Rencana finalisasi dokumentasi](./docs/DOCUMENTATION_IMPLEMENTATION_PLAN.md)
- [Catatan finalisasi dan evidence](./docs/release/README.md)

README komponen dan dokumen inti di atas menjadi sumber panduan aktif. Dokumen dalam `docs/release/` tetap berfungsi sebagai keputusan dan evidence finalisasi, bukan petunjuk penggunaan harian.

## 📜 Konteks akademik dan lisensi

Tumbuh Posyandu dikembangkan sebagai project akademik untuk memenuhi rangkaian mata kuliah **Proyek Utama Informatika**, **Proyek Profesional**, dan **Tugas Akhir**. Project digunakan untuk pembelajaran, penelitian, demonstrasi, dan evaluasi akademik.

Hak cipta project tetap berada pada pengembang. Penggunaan, modifikasi, atau distribusi di luar kepentingan akademik memerlukan persetujuan pengembang dan harus memperhatikan ketentuan penggunaan data standar pertumbuhan WHO serta layanan pihak ketiga yang terintegrasi.

---

<div align="center">
  <sub>Proyek Utama Informatika · Proyek Profesional · Tugas Akhir</sub>
</div>
