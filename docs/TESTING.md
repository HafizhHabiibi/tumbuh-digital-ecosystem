# Pengujian

Dokumen ini adalah sumber utama command, cakupan, dan batas pengujian Tumbuh Posyandu. Angka hasil test selalu disertai tanggal/evidence agar snapshot lama tidak dianggap status terbaru.

## 1. Quality gate per komponen

### Backend

```powershell
Set-Location backend-express
npm ci
npm test
```

Test Node mencakup auth/platform, middleware, konfigurasi, rate limit, kontrak data, pengukuran, WHO/SAW/prioritas, pemberian, rujukan, laporan, notifikasi/FCM, insight/chat AI, health check, dan regresi risiko.

### Dashboard Web

```powershell
Set-Location web-dashboard
npm ci
npm run check
```

`check` menjalankan ESLint, Vitest, dan production build. Test mencakup service/store, routing/session, query list, pencarian, validasi pengukuran/password, kontrak domain, helper UI, serta tampilan rujukan.

### Flutter Android

```powershell
Set-Location tumbuhapp
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=config/development-emulator.json
```

Test mencakup konfigurasi, auth lifecycle/service, kontrak model/API, navigasi notifikasi, jadwal, laporan, pemberian, pengukuran/insight, pemisahan data teknis, rujukan, serta chat AI.

### WHO converter

```powershell
Set-Location who-converter
npm ci
npm run generate
npm test
```

Test memeriksa tepat 10 tabel, jumlah/granularitas data usia, jumlah file sumber, dan checksum tabel pengukuran fisik. Output generator tidak otomatis disalin ke backend.

## 2. Evidence terakhir

Final rerun pada **12 September 2026** mencatat:

| Komponen | Hasil |
|---|---|
| Backend | 262 pass, 0 fail |
| Web | ESLint pass, 68 test pass, build pass |
| Flutter | Format pass, analyzer 0 issue, 126 test pass |
| Live lokal | Backend dan Vite HTTP 200 dengan header security yang diperiksa |

Sumber: [Evidence Workstream C](./release/evidence/C_SECURITY_EVIDENCE.md). Dependency/clean-install evidence berada di [Evidence Workstream B](./release/evidence/B_DEPENDENCY_EVIDENCE.md). Angka di atas adalah snapshot bertanggal, bukan jaminan untuk perubahan sesudahnya.

Quality gate yang sama dijalankan kembali pada Tahap 6 dokumentasi dan tetap lulus, termasuk debug APK build serta 4 test WHO converter. Lihat [Documentation Final Review Evidence](./release/evidence/DOCUMENTATION_FINAL_REVIEW.md) sebagai evidence teknis terbaru.

Pada Tahap 3 dokumentasi, `npm run generate` dan `npm test` WHO converter dijalankan kembali: 4/4 test lulus dan output tidak berubah.

## 3. Manual smoke test lokal

Jalankan setelah automated gate dan setup database fresh.

### Infrastruktur

- [ ] `/api/health/live` mengembalikan HTTP 200.
- [ ] `/api/health/ready` sesuai layanan yang sengaja dikonfigurasi.
- [ ] Dashboard terbuka pada port `5173` dan Android dapat mencapai API.

### Kader Web

- [ ] Login dengan fixture kader dan Turnstile valid.
- [ ] Buka dashboard serta daftar orang tua/anak.
- [ ] Tambahkan pengukuran sintetis dan periksa hasil antropometri/prioritas.
- [ ] Tambahkan pemberian, buat rujukan, dan kelola jadwal.
- [ ] Unduh laporan individual/rekap.

### Puskesmas Web

- [ ] Login dengan fixture puskesmas.
- [ ] Periksa dashboard, prioritas, dan detail anak.
- [ ] Ubah rujukan dari `diajukan` menjadi `ditangani`, lalu `selesai`.
- [ ] Pastikan menu pengelolaan khusus kader tidak tersedia.

### Orang tua Android

- [ ] Login dengan fixture orang tua; akun petugas ditolak.
- [ ] Hanya anak milik akun yang tampil.
- [ ] Riwayat tidak membocorkan Z-score/detail SAW internal.
- [ ] Jadwal, pemberian, rujukan, notifikasi, dan laporan dapat dibuka.
- [ ] Insight/chat menampilkan batas edukatif bila Gemini dikonfigurasi.

Gunakan hanya fixture sintetis dan hapus file laporan setelah pengujian.

## 4. Yang belum dibuktikan

- staging E2E terpadu dengan MySQL, SMTP, Turnstile, Gemini, dan FCM nyata;
- HTTPS/HSTS serta header dari hosting publik;
- backup/restore dan migrasi database existing;
- Android release signing/distribusi;
- Firebase Console restriction;
- iOS build dan pengujian;
- operasi multi-instance, observability, dan load/performance target formal;
- UAT final tiga role dengan sign-off.

Item tersebut tidak memblokir demo lokal, tetapi harus dipenuhi sesuai [Known Issues](./release/KNOWN_ISSUES.md) sebelum scope diperluas.

## 5. CI saat ini

Workflow `Integration Quality` menjalankan backend test serta Flutter format/analyze/test/debug build pada pull request dengan perubahan terkait dan push ke `main`. Web dan WHO converter belum menjadi gate CI. Karena finalisasi berlangsung pada branch release lokal, jalankan command seluruh komponen secara manual sebelum freeze.
