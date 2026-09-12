<div align="center">

<img src="./assets/icon/app_icon.png" alt="Ikon Tumbuh App" width="100" />

# Tumbuh App — Android

**Kanal Mobile bagi orang tua untuk memantau pertumbuhan, menerima informasi, dan berinteraksi dengan Conversational AI.**

![Flutter](https://img.shields.io/badge/Flutter-3.44.2-02569B?style=flat-square&logo=flutter&logoColor=white)
![Android](https://img.shields.io/badge/Android-mobile-3DDC84?style=flat-square&logo=android&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-state%20management-2563EB?style=flat-square)
![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?style=flat-square&logo=firebase&logoColor=111827)
![Dio](https://img.shields.io/badge/Dio-HTTP%20client-0A8754?style=flat-square)

[Prasyarat](#prasyarat-android) · [Konfigurasi API](#konfigurasi-android) · [Menjalankan](#android-emulator) · [Quality gate](#quality-android)

</div>

Aplikasi Flutter khusus role `orang_tua`. Aplikasi menampilkan anak dan data milik wali yang sedang login, riwayat pertumbuhan, jadwal, pemberian, status rujukan, notifikasi, laporan, insight, dan percakapan edukatif.

Aplikasi saat ini dijalankan dan diuji pada Android. Struktur iOS dipertahankan sebagai persiapan pengembangan platform pada masa mendatang.

<a id="prasyarat-android"></a>

## ✅ Prasyarat

- Flutter `3.44.2` stable;
- JDK `17` dan Android SDK;
- Android emulator atau perangkat fisik;
- backend Tumbuh Posyandu yang aktif;
- Firebase Android client configuration yang sesuai untuk package aplikasi.

Periksa environment Flutter:

```powershell
flutter doctor
```

<a id="konfigurasi-android"></a>

## 🔌 Konfigurasi API

Alamat API wajib diberikan melalui `--dart-define-from-file`. Aplikasi memerlukan:

- `APP_ENV`: `development`, `staging`, atau `production`;
- `API_BASE_URL`: URL HTTP/HTTPS absolut yang berakhir dengan `/api`.

File konfigurasi lokal yang mengandung alamat environment tertentu diabaikan Git. Nilai `dart-define` ikut berada dalam binary; jangan gunakan mekanisme ini untuk menyimpan secret.

### Android emulator

`10.0.2.2` mengarah ke komputer host dari emulator Android. Config yang sudah tersedia menggunakan `http://10.0.2.2:3000/api`:

```powershell
flutter pub get
flutter run --dart-define-from-file=config/development-emulator.json
```

### Perangkat fisik

Salin template dan ganti IP contoh dengan alamat LAN komputer yang menjalankan backend:

```powershell
Copy-Item config/development-device.example.json config/development-device.json
flutter run --dart-define-from-file=config/development-device.json
```

Perangkat dan komputer harus berada pada jaringan yang sama. Firewall komputer harus mengizinkan koneksi ke port backend.

HTTP lokal hanya diizinkan oleh manifest Android debug. Build profile/release harus memakai endpoint HTTPS.

## 🔔 Firebase dan notifikasi

Android memerlukan `android/app/google-services.json` yang sesuai dengan Firebase project dan package aplikasi. File tersebut adalah konfigurasi client, bukan service-account private key. Jangan menaruh service-account JSON atau private key di aplikasi.

Aplikasi meminta permission notifikasi saat inisialisasi; Android 13+ dapat menampilkan dialog permission. Penolakan permission tidak mengubah kepemilikan data, tetapi push/local notification tidak akan tampil. Pengiriman FCM tetap membutuhkan konfigurasi Firebase Admin pada backend.

<a id="quality-android"></a>

## 🧪 Quality gate dan debug APK

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug --dart-define-from-file=config/development-emulator.json
```

APK debug dihasilkan di bawah `build/app/outputs/flutter-apk/`. Artefak ini untuk pengembangan/demonstrasi, bukan distribusi publik.

Template `config/staging.example.json` dan `config/production.example.json` tersedia untuk menyiapkan konfigurasi environment lain dengan endpoint HTTPS.

## 🛠️ Troubleshooting koneksi

| Gejala | Pemeriksaan |
|---|---|
| Layar menampilkan konfigurasi tidak valid | Pastikan command memakai `--dart-define-from-file` dan URL berakhir `/api` |
| Emulator tidak dapat mencapai `localhost` | Gunakan `10.0.2.2`, bukan `localhost`, untuk backend di komputer host |
| Perangkat fisik gagal terhubung | Gunakan IP LAN komputer, jaringan yang sama, backend listening, dan izin firewall |
| HTTP ditolak pada profile/release | Gunakan Android debug untuk lokal atau sediakan endpoint HTTPS |
| Login ditolak | Gunakan akun role orang tua; akun kader/puskesmas hanya untuk dashboard Web |
| Notifikasi tidak tampil | Periksa permission Android, Firebase client config, koneksi internet, dan Firebase Admin backend |

Lihat [README root](../README.md) untuk setup seluruh sistem, [Security dan Privacy](../docs/SECURITY_AND_PRIVACY.md) untuk batas data, dan [kontrak orang tua](../backend-express/docs/ORANG_TUA_PENGUKURAN_CONTRACT.md) untuk batas response pengukuran.

---

<div align="center">
  <sub>Bagian dari <a href="../README.md">Tumbuh Posyandu</a></sub>
</div>
