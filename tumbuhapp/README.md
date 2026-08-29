# Tumbuh App

Aplikasi Flutter untuk orang tua yang terhubung ke REST API `backend-express`.
Alamat API tidak ditanam langsung di source code dan wajib diberikan saat
menjalankan atau membangun aplikasi.

## Menjalankan aplikasi

Pastikan backend berjalan pada port `3000`, lalu pilih konfigurasi sesuai target.

### Android emulator

`10.0.2.2` mengarah ke komputer host dari emulator Android:

```powershell
flutter run --dart-define-from-file=config/development-emulator.json
```

### Perangkat fisik

Salin `config/development-device.example.json` menjadi
`config/development-device.json`, lalu ubah IP contoh menjadi alamat LAN komputer
yang menjalankan backend. Perangkat dan komputer harus berada pada jaringan yang
sama.

```powershell
flutter run --dart-define-from-file=config/development-device.json
```

HTTP lokal hanya diizinkan oleh build Android debug. iOS dan build Android
profile/release harus memakai endpoint HTTPS.

## Staging dan production

Salin file contoh, lalu ganti domain dengan endpoint HTTPS yang sebenarnya:

```powershell
Copy-Item config/staging.example.json config/staging.json
Copy-Item config/production.example.json config/production.json
```

Jalankan staging:

```powershell
flutter run --release --dart-define-from-file=config/staging.json
```

Buat artefak production:

```powershell
flutter build appbundle --release --dart-define-from-file=config/production.json
flutter build ipa --release --dart-define-from-file=config/production.json
```

File lokal `development-device.json`, `staging.json`, dan `production.json`
diabaikan Git. Jangan menaruh secret di dalam `--dart-define`, karena nilainya
tetap dapat ditemukan di binary aplikasi.

## Kontrak konfigurasi

- `APP_ENV`: `development`, `staging`, atau `production`.
- `API_BASE_URL`: URL absolut HTTP/HTTPS yang berakhir dengan `/api`.
- `staging` dan `production` wajib menggunakan HTTPS.
- Tanpa konfigurasi yang valid, aplikasi berhenti sebelum inisialisasi Firebase
  dan menampilkan pesan kesalahan konfigurasi.

## Verifikasi

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=config/development-emulator.json
```

Workflow `Integration Quality` menjalankan pemeriksaan format, analyzer, seluruh
test Flutter, build APK debug dengan JDK 17, dan seluruh test backend pada pull
request maupun push ke branch `main`.
