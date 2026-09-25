# Konfigurasi

Dokumen ini adalah katalog konfigurasi Tumbuh Posyandu. Gunakan file example sebagai template, simpan nilai aktual hanya di file lokal yang di-ignore, dan jangan menaruh secret pada dokumentasi atau source control.

## 1. Backend

Salin template:

```powershell
Set-Location backend-express
Copy-Item .env.example .env
```

### Wajib untuk startup

| Variable | Contoh aman | Aturan |
|---|---|---|
| `DB_HOST` | `localhost` | Host MySQL |
| `DB_USER` | `root` | User database lokal |
| `DB_NAME` | `posyandu_pui` | Hanya huruf, angka, underscore untuk setup script |
| `JWT_SECRET` | placeholder minimal 32 karakter | Berbeda dari refresh secret |
| `JWT_REFRESH_SECRET` | placeholder minimal 32 karakter | Berbeda dari access secret |
| `CORS_ORIGIN` | `http://localhost:5173` | Satu/beberapa origin eksplisit dipisahkan koma; tanpa path |

`DB_PASSWORD` boleh kosong hanya bila akun MySQL lokal memang tidak memakai password. `DB_PORT` default `3306`.

### Aplikasi dan HTTP

| Variable | Default/example | Keterangan |
|---|---|---|
| `PORT` | `3000` | Angka `1–65535` |
| `NODE_ENV` | `development` | `development`, `test`, atau `production` |
| `FRONTEND_URL` | `http://localhost:5173` | Base URL untuk link/alur yang menuju frontend |
| `ENABLE_HSTS` | `false` | Hanya boleh `true` pada production HTTPS |
| `REQUEST_TIMEOUT_MS` | `120000` | Rentang `1000–300000` ms |
| `TRUST_PROXY_HOPS` | `0` | Lokal langsung `0`; ubah hanya sesuai hop proxy aktual |
| `NAMA_POSYANDU` | Nama fixture | Metadata laporan PDF |
| `NAMA_PUSKESMAS` | Nama fixture | Metadata laporan PDF |

### Integrasi kondisional

| Fitur | Variable | Kapan diperlukan |
|---|---|---|
| Turnstile | `TURNSTILE_SECRET_KEY`, `TURNSTILE_ALLOWED_HOSTNAMES` | Untuk login/forgot-password Web; wajib pada `NODE_ENV=production` |
| SMTP | `MAIL_USER`, `MAIL_PASS` | Ketika email reset password digunakan |
| Gemini | `GEMINI_API_KEYS` atau `GEMINI_API_KEY` | Agar readiness AI, insight, dan chat berfungsi |
| Gemini tuning | `GEMINI_MODEL`, `GEMINI_TIMEOUT_MS`, `GEMINI_MAX_TOTAL_ATTEMPTS`, `GEMINI_MAX_TRANSIENT_RETRIES`, `GEMINI_INVALID_RESPONSE_RETRIES`, `GEMINI_KEY_COOLDOWN_MS`, `GEMINI_MAX_BACKOFF_MS` | Opsional; `GEMINI_MAX_RETRIES` lama tetap didukung sebagai fallback transient retry |
| Chat rate limit | `CHAT_RATE_LIMIT_WINDOW_MS`, `CHAT_RATE_LIMIT_MAX` | Opsional untuk menyesuaikan limit lokal |
| Firebase Admin | `FIREBASE_SERVICE_ACCOUNT_BASE64` | Pilihan pertama credential server-side |
| Firebase ADC | `FIREBASE_USE_APPLICATION_DEFAULT=true`, `GOOGLE_APPLICATION_CREDENTIALS` | Alternatif service-account Base64 |

Pilih salah satu metode Firebase Admin. `GOOGLE_APPLICATION_CREDENTIALS` menunjuk file lokal di luar source control.

## 2. Dashboard Web

```powershell
Set-Location web-dashboard
Copy-Item .env.example .env
```

| Variable | Contoh lokal | Aturan |
|---|---|---|
| `VITE_API_URL` | `http://localhost:3000/api` | URL HTTP/HTTPS absolut; origin dipakai membentuk CSP |
| `VITE_TURNSTILE_SITE_KEY` | Site key publik | Harus cocok dengan secret dan hostname backend |

Semua variable `VITE_*` masuk ke bundle browser dan bukan tempat secret.

## 3. Flutter Android

Konfigurasi dibaca dari compile-time environment:

| Key | Nilai lokal | Aturan |
|---|---|---|
| `APP_ENV` | `development` | `development`, `staging`, atau `production` |
| `API_BASE_URL` | Emulator: `http://10.0.2.2:3000/api` | Absolut, tanpa query/fragment, dan berakhir `/api` |

File yang tersedia:

- `config/development-emulator.json` — terlacak Git dan siap untuk emulator lokal;
- `config/development-device.example.json` — template perangkat fisik;
- `config/staging.example.json` dan `config/production.example.json` — roadmap HTTPS.

`development-device.json`, `staging.json`, dan `production.json` di-ignore. Nilai `dart-define` dapat ditemukan dalam binary, jadi jangan masukkan secret.

Contoh pemakaian:

```powershell
flutter run --dart-define-from-file=config/development-emulator.json
```

Build Android debug mengizinkan HTTP lokal. Profile/release serta environment staging/production wajib HTTPS.

## 4. Firebase client Android

`tumbuhapp/android/app/google-services.json` adalah konfigurasi client, bukan Firebase Admin credential. Sebelum APK dibagikan, verifikasi pembatasan API key berdasarkan package, SHA, dan API yang diperlukan di Firebase/Google Cloud Console. Service-account private key tidak boleh berada di aplikasi.

## 5. Profil environment

| Area | Development lokal | Roadmap staging/production |
|---|---|---|
| Transport | HTTP lokal diperbolehkan pada Android debug | HTTPS end-to-end |
| CORS | Origin Vite lokal | Origin hosting eksplisit |
| Proxy | `TRUST_PROXY_HOPS=0` | Jumlah hop aktual yang telah diuji |
| HSTS | `false` | Aktif setelah HTTPS tervalidasi |
| Data | Fixture sintetis | Data nyata hanya setelah governance/privacy approval |
| Secret | `.env` lokal | Secret manager dan rotasi |
| Mobile | Debug signing | Release signing terproteksi |

Gate lengkap sebelum perluasan scope berada di [Security dan Privacy](./SECURITY_AND_PRIVACY.md).

