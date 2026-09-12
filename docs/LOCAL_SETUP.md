# Setup Lokal

Panduan ini adalah sumber utama untuk menjalankan seluruh Tumbuh Posyandu pada satu komputer dengan database MySQL fresh, dashboard Web, dan aplikasi Android. iOS serta deployment publik tidak termasuk alur ini.

> **Data demonstrasi sintetis — bukan rekam medis.** Jangan menggunakan data orang nyata pada environment lokal ini.

## 1. Prasyarat

| Tool | Acuan project | Keterangan |
|---|---|---|
| Git | Versi aktif | Mengambil dan mengelola source |
| Node.js | `22` | Digunakan CI backend dan sesuai toolchain Web saat ini |
| npm | Bawaan Node.js | Gunakan `npm ci` agar mengikuti lockfile |
| MySQL | Service lokal | Harus dapat membuat database dan memakai `utf8mb4` |
| Flutter | `3.44.2` stable | Versi pada workflow integrasi |
| JDK | `17` | Build Android |
| Android SDK | Sesuai Flutter | Emulator atau perangkat fisik |

Periksa tool utama:

```powershell
node --version
npm --version
mysql --version
flutter doctor
```

## 2. Urutan startup

Urutan yang didukung adalah:

```text
MySQL → database/seeder → backend → dashboard Web → Android
```

Gunakan terminal terpisah untuk backend, Web, dan Flutter.

## 3. Database dan backend

Dari root repository:

```powershell
Set-Location backend-express
npm ci
Copy-Item .env.example .env
```

Edit `.env` dan pastikan minimal `DB_HOST`, `DB_USER`, `DB_NAME`, `JWT_SECRET`, `JWT_REFRESH_SECRET`, dan `CORS_ORIGIN` valid. Kedua JWT secret wajib berbeda dan minimal 32 karakter. Jangan commit `.env`.

Dengan service MySQL aktif, jalankan:

```powershell
npm run db:setup
npm run dev
```

`db:setup` membuat database bila perlu, menerapkan schema, dan menjalankan seeder sintetis. Seeder me-reset isi tabel project; jangan arahkan ke database penting.

Periksa backend:

```powershell
Invoke-RestMethod http://localhost:3000/api/health/live
Invoke-RestMethod http://localhost:3000/api/health/ready
```

`live` seharusnya berhasil ketika server aktif. `ready` juga memeriksa database dan AI, sehingga dapat menghasilkan HTTP `503` bila Gemini belum dikonfigurasi.

## 4. Dashboard Web

Pada terminal baru dari root repository:

```powershell
Set-Location web-dashboard
npm ci
Copy-Item .env.example .env
npm run dev
```

Buka `http://localhost:5173`. Pastikan:

- `VITE_API_URL=http://localhost:3000/api`;
- origin tersebut diizinkan oleh `CORS_ORIGIN` backend;
- `VITE_TURNSTILE_SITE_KEY` cocok dengan `TURNSTILE_SECRET_KEY` backend.

Web login dan forgot-password membutuhkan Turnstile. Backend dapat hidup tanpa Turnstile pada mode development, tetapi kedua alur Web tersebut tidak dapat diselesaikan tanpa pasangan key yang valid.

## 5. Android

Pada terminal baru:

```powershell
Set-Location tumbuhapp
flutter pub get
flutter run --dart-define-from-file=config/development-emulator.json
```

Config emulator memakai `http://10.0.2.2:3000/api`; `10.0.2.2` menunjuk ke komputer host dari Android emulator.

Untuk perangkat fisik:

```powershell
Copy-Item config/development-device.example.json config/development-device.json
flutter run --dart-define-from-file=config/development-device.json
```

Ganti IP contoh di `development-device.json` dengan IP LAN komputer. Pastikan perangkat berada pada jaringan yang sama dan firewall mengizinkan port `3000`. HTTP lokal hanya didukung pada build Android debug.

## 6. Akun fixture

| Role | Email | Password | Aplikasi |
|---|---|---|---|
| Kader | `riri.kader@example.test` | `password123` | Web |
| Puskesmas | `ciko.puskesmas@example.test` | `password123` | Web |
| Orang tua | `aminah.orangtua@example.test` | `password123` | Android |

Semua identitas, alamat, NIK, dan pengukuran dari seeder adalah sintetis. Password fixture tidak boleh digunakan di environment nyata.

## 7. Layanan eksternal

| Layanan | Dampak bila belum dikonfigurasi |
|---|---|
| Gemini | Insight/chat tidak tersedia dan readiness AI gagal |
| SMTP | Forgot-password tidak dapat mengirim email |
| Turnstile | Login dan forgot-password Web tidak dapat diselesaikan |
| Firebase Admin/FCM | Push notification tidak terkirim; inbox database tetap bergantung pada alur aplikasi |

Lihat [Configuration](./CONFIGURATION.md) untuk variable yang dibutuhkan.

## 8. Troubleshooting

| Masalah | Tindakan |
|---|---|
| Backend gagal saat startup | Baca pesan validasi dan bandingkan `.env` dengan `.env.example` |
| MySQL menolak koneksi | Periksa service, host, port, user, password, dan izin membuat database |
| Web terkena CORS | Gunakan origin persis tanpa path pada `CORS_ORIGIN` |
| Web tidak bisa login | Periksa pasangan Turnstile dan gunakan akun kader/puskesmas |
| Emulator gagal mengakses API | Gunakan `10.0.2.2`, bukan `localhost` |
| Perangkat fisik gagal mengakses API | Periksa IP LAN, jaringan, port, dan firewall |
| Mobile menampilkan konfigurasi invalid | Pastikan config dipass dengan `--dart-define-from-file` dan URL berakhir `/api` |
| Notifikasi tidak muncul | Periksa permission Android, Firebase client, Firebase Admin backend, dan koneksi internet |

Untuk menghentikan aplikasi gunakan `Ctrl+C` pada masing-masing terminal. Hapus laporan/download demo setelah digunakan dan hapus database demo sesuai kebijakan pada [Security dan Privacy](./SECURITY_AND_PRIVACY.md).

