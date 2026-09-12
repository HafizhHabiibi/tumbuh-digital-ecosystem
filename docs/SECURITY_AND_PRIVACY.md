# Security dan Privacy

Status: **aktif untuk scope lokal; final review diperlukan sebelum perluasan scope**  
Tanggal review: **2026-09-12**  
Owner: **Project Author**  
Scope aktif: **penggunaan lokal untuk proyek akhir, Web + Android, database fresh**

Dokumen ini adalah sumber utama keputusan security dan privacy. Cara menjalankan aplikasi berada di [Setup Lokal](./LOCAL_SETUP.md), katalog environment berada di [Configuration](./CONFIGURATION.md), sedangkan risk acceptance dan bukti verifikasi tetap dipisahkan dalam [release records](./release/).

## 1. Batas penggunaan

Release saat ini hanya untuk pengembangan, pengujian, demonstrasi, dan penilaian akademik pada perangkat yang dikendalikan owner. Seeder wajib dianggap data sintetis. Data kesehatan atau identitas orang nyata tidak boleh dimasukkan sebelum ada persetujuan institusi, dasar pemrosesan, kebijakan retensi resmi, kontrol akses operasional, backup terenkripsi, audit trail, dan deployment HTTPS yang telah direview.

iOS, deployment publik, dan operasi multi-instance berada di luar scope saat ini. Seluruh prasyarat yang wajib dipenuhi sebelum scope diperluas dicatat pada bagian 13.

## 2. Model akses

| Role | Platform | Akses utama | Batas data |
|---|---|---|---|
| `kader` | Web | Kelola orang tua/anak, pengukuran, pemberian, rujukan, jadwal, ranking, dan laporan | Endpoint teknis memerlukan token role petugas; constraint penghapusan melindungi riwayat klinis |
| `puskesmas` | Web | Monitoring, rujukan, dashboard, ranking, profil, dan laporan teknis | Tidak dapat masuk aplikasi mobile; endpoint dibatasi middleware role |
| `orang_tua` | Android | Profil sendiri, anak sendiri, pengukuran ringkas, jadwal, notifikasi, rujukan, insight dan chat edukatif | Ownership diverifikasi server; serializer menyembunyikan Z-score, detail SAW, dan data anak lain |

Role tidak boleh ditentukan hanya dari UI. Backend selalu memverifikasi bearer token, status akun, role terbaru, dan kepemilikan resource. Matriks platform menolak orang tua pada web serta kader/puskesmas pada mobile.

## 3. Data yang diproses

| Kelompok | Contoh data | Tujuan | Akses | Retensi scope lokal |
|---|---|---|---|---|
| Akun dan profil | email, password hash, role, nama, telepon, jabatan | autentikasi dan identifikasi operator | pemilik akun dan role terkait | sampai database demo dihapus |
| Orang tua | nama, NIK, alamat, telepon, email | menghubungkan wali dengan anak dan tindak lanjut | petugas; orang tua untuk profil sendiri | sampai database demo dihapus |
| Anak | nama, NIK, jenis kelamin, tanggal lahir, relasi wali | identitas subjek pemantauan | petugas; wali pemilik | sampai database demo dihapus |
| Pengukuran | tanggal, berat, tinggi, lingkar, Z-score, kategori, SAW, prioritas | penilaian pertumbuhan dan prioritas pemantauan | detail teknis hanya petugas; ringkasan aman untuk wali | sampai database demo dihapus |
| Pemberian | vitamin, obat cacing, PMT, dosis, tanggal | riwayat layanan | petugas; ringkasan sesuai endpoint wali | sampai database demo dihapus |
| Rujukan | alasan, status, catatan, hasil penanganan | tindak lanjut kasus | petugas; status aman untuk wali pemilik | sampai database demo dihapus |
| Jadwal | tanggal, jenis, lokasi/keterangan | operasional posyandu | petugas dan wali sesuai endpoint | sampai database demo dihapus |
| Notifikasi/outbox | judul, pesan, referensi, token FCM | pengiriman informasi ke perangkat | sistem dan wali tujuan | sampai database demo dihapus; outbox terminal akan ditinjau lagi di Workstream D |
| Insight AI | kategori pertumbuhan dan rekomendasi edukatif | edukasi non-diagnostik | wali pemilik dan sistem | sampai database demo dihapus |
| Percakapan AI | pesan wali dan jawaban assistant | konteks edukasi | wali pemilik; backend membatasi history | sampai database demo dihapus |
| Sesi | hash refresh token, expiry, status revoke | mempertahankan sesi Android | backend saja | maksimum 30 hari; expired/revoked dibersihkan setiap 6 jam |

Untuk scope akademik, owner harus menghapus database lokal, backup, screenshot, ekspor, dan artefak demonstrasi paling lambat 90 hari setelah penilaian akhir selesai, kecuali seluruh isinya telah diverifikasi sintetis dan masih diperlukan sebagai fixture pengembangan.

## 4. Authentication dan session

- Password baru untuk pembuatan akun, reset, dan perubahan password: minimal 8 karakter dan maksimal 72 byte UTF-8. Batas byte mengikuti input bcrypt yang digunakan aplikasi.
- Password disimpan sebagai hash bcrypt; password mentah tidak boleh masuk log, source control, screenshot, atau dokumentasi.
- Access token petugas berlaku 8 jam; access token orang tua berlaku 15 menit.
- Refresh token Android berlaku 30 hari, disimpan sebagai hash SHA-256, mendukung multi-device, dan dirotasi secara atomik. Token lama ditolak setelah rotasi.
- Logout dan perubahan/reset password mencabut seluruh refresh token milik user.
- Middleware membaca `users.updated_at`; access token yang diterbitkan sebelum perubahan password/status akun ditolak.
- Reset token berlaku 15 menit, memiliki purpose khusus, dan hanya dapat digunakan sekali melalui `reset_password_at`.
- Login dan forgot-password memiliki limit per IP dan per email. IP IPv6 dinormalisasi ke subnet oleh library.
- Turnstile untuk web production wajib cocok pada `success`, `action`, dan `hostname` allowlist. Mobile tidak memakai Turnstile dan tetap dilindungi rate limit.

### Keputusan session web

Bearer access token web tetap berada di `localStorage` untuk release lokal karena aplikasi dijalankan pada perangkat owner dan migrasi cookie akan mengubah kontrak lintas backend/web. Risiko XSS diterima sementara dengan CSP, larangan rendering HTML mentah, dependency audit, dan larangan data nyata.

Keputusan ini tidak berlaku untuk deployment publik. Sebelum publik, pilih salah satu:

1. migrasikan sesi ke cookie `HttpOnly`, `Secure`, dan `SameSite` disertai proteksi CSRF; atau
2. lakukan review keamanan formal yang menyetujui bearer storage beserta CSP production yang ketat.

## 5. HTTP dan browser security

Backend menerapkan:

- allowlist `CORS_ORIGIN` eksplisit dan mendukung beberapa origin yang dipisahkan koma;
- security header CSP untuk API, `nosniff`, `DENY` frame, `no-referrer`, Permissions Policy, dan COOP;
- HSTS hanya bila `NODE_ENV=production` dan `ENABLE_HSTS=true` setelah HTTPS end-to-end dipastikan;
- body JSON maksimum 100 KiB;
- request timeout default 120 detik; timeout reverse proxy harus sedikit lebih besar;
- request ID maksimum 100 karakter dengan karakter aman untuk mencegah log injection;
- `X-Powered-By` dinonaktifkan.

Web build menyisipkan CSP berdasarkan origin dari `VITE_API_URL`. Vite development/preview juga mengirim CSP, `nosniff`, frame denial, dan referrer policy. Meta CSP merupakan defense-in-depth; web server production tetap wajib mengirim header HTTP yang setara, termasuk `frame-ancestors`, HSTS, dan HTTPS redirect.

Audit source 2026-09-12 tidak menemukan `v-html`, `innerHTML`, atau `eval` pada source aplikasi web. `style-src 'unsafe-inline'` masih diperlukan oleh komponen UI/chart dan harus dievaluasi ulang bila frontend berubah.

Untuk penggunaan lokal langsung tanpa reverse proxy, `TRUST_PROXY_HOPS=0`. Nilai hanya boleh diubah menjadi jumlah hop proxy aktual; nilai yang terlalu besar membuat alamat klien dapat dipalsukan dan merusak rate limit.

## 6. Secret dan credential

| Secret/config | Lokasi yang diizinkan | Aturan |
|---|---|---|
| `JWT_SECRET` | environment backend | acak minimal 32 karakter, berbeda dari refresh secret |
| `JWT_REFRESH_SECRET` | environment backend | acak minimal 32 karakter, berbeda dari access secret |
| `DB_PASSWORD` | environment backend | akun DB least privilege; jangan taruh dalam URL/log |
| `MAIL_USER`, `MAIL_PASS` | environment backend | gunakan app password/sandbox account |
| `TURNSTILE_SECRET_KEY` | environment backend | server-side saja; rotasi jika pernah terekspos |
| `GEMINI_API_KEY(S)` | environment backend | batasi quota/project; server-side saja |
| Firebase Admin credential | Base64 environment atau ADC lokal | jangan commit JSON service account |
| `google-services.json` Android | source Android | berisi client configuration, bukan private key; API key tetap wajib dibatasi ke package/SHA/API yang diperlukan |
| Android keystore/password | di luar repository | baru diperlukan pada Workstream G; simpan melalui file ignore/secret CI |

File `.env` aktual harus tetap di-ignore. Hanya `.env.example` tanpa credential yang boleh dilacak. Credential yang pernah dikirim lewat chat, email, screenshot, commit, atau environment bersama harus dianggap bocor dan dirotasi sebelum deployment publik.

## 7. Logging dan observability

Log yang diperbolehkan: timestamp, level, request ID aman, route template, status, latency, nama worker, attempt, dan kode error yang tidak sensitif.

Log dilarang memuat:

- access/refresh/reset token, password, API key, cookie, dan authorization header;
- NIK, email, nomor telepon, alamat, nama lengkap, atau FCM token;
- isi chat, prompt lengkap, payload kesehatan, Z-score per individu, dan isi notifikasi;
- SQL parameter atau response provider mentah yang dapat membawa data di atas.

Seeder kini memakai alamat domain reservasi `example.test` dan tidak lagi mencetak nama/email fixture. Mobile hanya mencatat ada/tidaknya payload notifikasi, bukan isi payload. Error production harus dicatat dalam bentuk terklasifikasi; structured logging lengkap dilanjutkan di Workstream E.

## 8. Penggunaan Gemini

Gemini hanya boleh menerima konteks yang dibentuk backend dari allowlist:

- usia/jenis kelamin bila dibutuhkan secara edukatif;
- kategori antropometri dan prioritas dalam bentuk kategoris;
- insight aman yang sudah disanitasi;
- history chat terbatas dan tanpa identitas.

Gemini tidak boleh menerima nama, NIK, email, telepon, alamat, token, credential, identifier database, Z-score mentah, detail SAW mentah, atau seluruh rekam kesehatan. Backend menolak PII, prompt injection, diagnosis, resep/dosis, dan keputusan rujukan sebelum provider; output juga divalidasi. Jawaban AI adalah edukasi umum, bukan diagnosis atau pengganti tenaga kesehatan.

## 9. Koreksi, ekspor, dan penghapusan

Dalam scope lokal, Project Author menjadi kontak tunggal.

- Koreksi: ubah data melalui UI/API role yang berwenang; jangan mengedit hasil turunan tanpa memperbarui sumber pengukuran.
- Ekspor: laporan PDF hanya diberikan kepada role dan pemilik yang diizinkan. Simpan sementara dan hapus setelah tujuan demonstrasi selesai.
- Penghapusan: orang tua/anak hanya dapat dihapus bila constraint riwayat mengizinkan. Untuk permintaan penghapusan menyeluruh, hentikan aplikasi, buat catatan keputusan, hapus database/backup/ekspor terkait, lalu verifikasi tidak ada salinan tertinggal.
- Bila data nyata kelak digunakan, retensi dan pengecualian penghapusan harus ditetapkan institusi/kebijakan yang berlaku sebelum implementasi.

## 10. Privacy notice dan disclosure AI

Teks minimum yang harus ditampilkan sebelum data nyata digunakan:

> Tumbuh Posyandu memproses data identitas dan pertumbuhan anak untuk pencatatan, pemantauan, serta tindak lanjut layanan. Akses dibatasi menurut peran dan kepemilikan data. Fitur AI hanya memberikan informasi edukatif dan tidak menggantikan pemeriksaan tenaga kesehatan. Hubungi pengelola layanan untuk koreksi, akses, atau penghapusan data sesuai kebijakan yang berlaku.

Untuk demo lokal dengan fixture, tampilkan label: **“Data demonstrasi sintetis — bukan rekam medis.”**

## 11. Penanganan insiden

1. Hentikan akses aplikasi/provider yang terdampak dan jangan menghapus log diagnostik non-sensitif.
2. Identifikasi jenis data, rentang waktu, akun, perangkat, dan credential yang terdampak.
3. Cabut sesi dan rotasi secret/provider key terkait.
4. Pulihkan dari konfigurasi/backup bersih dan verifikasi ownership serta readiness.
5. Dokumentasikan kronologi, dampak, tindakan, owner, dan pencegahan berulang.
6. Bila melibatkan data orang nyata, eskalasi kepada institusi/pihak yang bertanggung jawab sesuai prosedur yang berlaku.

Kontak scope lokal: **Project Author** melalui kanal akademik yang disepakati; jangan menaruh email/telepon pribadi pada repository publik.

## 12. Retensi dan disposal lokal

- Refresh token expired/revoked: cleanup otomatis setiap 6 jam.
- File laporan/download: hapus setelah demonstrasi atau paling lambat 7 hari.
- Screenshot/video: gunakan fixture; hapus bila tanpa sengaja memuat data nyata.
- Database dan backup demo: hapus maksimal 90 hari setelah penilaian akhir.
- Log lokal: simpan hanya selama diagnosis, maksimum 30 hari, dan pastikan bebas PII/secret.

## 13. Gate sebelum data nyata atau deployment publik

- HTTPS web/API dan HSTS telah diuji dari jaringan eksternal.
- Header CSP production, CORS, proxy hop, timeout, dan rate limit tervalidasi di host aktual.
- Session web mendapat keputusan final; secure-cookie menjadi opsi utama.
- Secret dirotasi dan disimpan pada secret manager; Firebase API key/package/SHA restrictions diverifikasi.
- Database menggunakan TLS jika melewati jaringan tidak dipercaya, account least privilege, backup terenkripsi, serta restore drill.
- Audit trail perubahan klinis/operasional tersedia.
- Retensi, consent/privacy notice, incident contact, koreksi, ekspor, dan penghapusan disetujui institusi.
- Staging integration untuk SMTP, Turnstile, Gemini, dan FCM lulus tanpa data nyata.
- Security review dan UAT tiga role ditandatangani.

Risk acceptance untuk hal yang sengaja ditunda tersedia di [C Security Risk Acceptance](./release/C_SECURITY_RISK_ACCEPTANCE.md).
