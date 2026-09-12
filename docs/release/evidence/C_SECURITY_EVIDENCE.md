# Evidence Workstream C — Security dan Privacy

Tanggal eksekusi: **2026-09-12**  
Branch: **`release/final-review`**  
Scope: **lokal, Web + Android, database fresh, single instance**

## 1. Perubahan terverifikasi

- Backend security header: CSP API, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, Permissions Policy, COOP, dan HSTS kondisional.
- Allowlist CORS menerima beberapa origin eksplisit; request tanpa `Origin` tetap diterima untuk Android/CLI.
- Request ID dari klien dibatasi 100 karakter aman; nilai lain diganti UUID.
- Request timeout default 120 detik dan tervalidasi 1–300 detik.
- JWT access/refresh wajib berbeda dan masing-masing minimal 32 karakter.
- Turnstile memerlukan `success=true`, action tepat, dan hostname dalam allowlist.
- Password create/change/reset menjadi minimal 8 karakter; backend menegakkan maksimum bcrypt 72 byte UTF-8.
- Cleanup refresh token expired/revoked berjalan saat startup dan setiap 6 jam.
- Pemanggilan `ipKeyGenerator` diperbaiki agar memakai `req.ip`; proxy IPv4 dan normalisasi subnet IPv6 diuji.
- CSP web dihasilkan dari `VITE_API_URL`; Vite dev/preview mengirim header browser security.
- Seeder memakai domain reservasi `example.test` dan log generator tidak mencetak nama/email.
- Log tap notifikasi mobile tidak lagi mencetak payload.

## 2. Automated verification

| Komponen | Command | Hasil |
|---|---|---|
| Backend | `npm test` | 262/262 test lulus |
| Proxy rate limit | `node --test test/proxy-rate-limit.test.js` | 1 test lulus |
| Web | `npm run check` | ESLint lulus, 68/68 test lulus, production build lulus |
| Android/Flutter | `dart format --output=none --set-exit-if-changed lib test` + `flutter analyze` + `flutter test` | 0 perubahan format, analyzer 0 issue, 126/126 test lulus |

## 3. Test kontrak security

- Origin allowlist menghasilkan ACAO untuk origin yang benar dan HTTP 403 untuk origin lain.
- Backend development tidak mengirim HSTS; konfigurasi menolak HSTS di luar production.
- Header API dan penghapusan `X-Powered-By` diverifikasi melalui server nyata pada ephemeral port.
- Request ID aman dipertahankan dan request ID dengan spasi diganti UUID.
- Password 7 karakter ditolak, 8 karakter diterima.
- Turnstile gagal bila action/hostname tidak cocok atau hostname kosong.
- Access token lama setelah `updated_at` ditolak oleh test auth middleware yang sudah ada.
- Serializer dan ownership orang tua tetap dilindungi oleh regression test backend yang sudah ada.

## 4. Secret dan source scan

Command menggunakan `git ls-files`, `git grep -Il`, dan `rg`; output dibatasi ke nama file agar nilai credential tidak tampil pada evidence.

Hasil:

- `.env` aktual tidak dilacak; yang dilacak hanya `.env.example`.
- Tidak ditemukan private key atau pola server token umum pada file terlacak.
- Satu match pola API key berada di `tumbuhapp/android/app/google-services.json`. Ini adalah Firebase client configuration, bukan service-account private key; pembatasan package/SHA/API masih memerlukan verifikasi Firebase Console (RA-C05).
- Tidak ditemukan `v-html`, `innerHTML`, atau `eval` pada source aplikasi web.
- Tidak ditemukan pola log eksplisit untuk token/password/NIK/chat; output fixture dan payload FCM yang teridentifikasi telah diperbaiki.

## 5. Verifikasi lokal dan batas evidence

Evidence ini membuktikan implementasi dan automated test lokal. Evidence ini belum membuktikan:

- HTTPS/HSTS dan header dari hosting production;
- jumlah reverse proxy aktual selain keputusan lokal `TRUST_PROXY_HOPS=0`;
- Turnstile, SMTP, Gemini, serta FCM nyata secara end-to-end;
- restriction Firebase pada console provider;
- audit trail atau kebijakan retensi institusional.

Item tersebut tidak disamarkan sebagai selesai dan dibawa sebagai risk acceptance/gate sebelum public deployment.

## 6. Final rerun

Final rerun setelah seluruh perubahan kode dan dokumentasi:

- backend: 262 pass, 0 fail;
- web: lint pass, 68 test pass, build pass;
- Flutter: format pass, analyzer pass, 126 test pass;
- live backend: HTTP 200, CSP ada, `nosniff`, frame `DENY`, HSTS tidak aktif pada local HTTP;
- live Vite: HTTP 200, CSP header dan CSP meta tersedia.
