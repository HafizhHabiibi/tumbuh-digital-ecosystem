# Implementation Plan Perbaikan Temuan Prioritas Frontend × Backend

**Tanggal:** 3 September 2026  
**Sumber:** `verifikasi_temuan_prioritas.md`  
**Cakupan:** `web-dashboard` dan `backend-express`

## 1. Tujuan

Menyelesaikan lima temuan integrasi frontend–backend tanpa memutus kontrak aplikasi mobile, menjaga hasil antropometri tetap deterministik, dan membuat pencarian pada data terpaginasikan bekerja terhadap seluruh dataset.

Target akhir:

1. Dashboard web hanya menerima role `kader` dan `puskesmas` tanpa redirect loop.
2. Nilai pengukuran memiliki rentang dan presisi yang sama dari form, API, perhitungan, sampai database.
3. Search/filter berjalan sebelum pagination.
4. Pengguna mendapat validasi jelas ketika tanggal pengukuran berada di luar rentang WHO.
5. Tampilan satuan dan penggunaan dataset WHO terdokumentasi serta konsisten.

## 2. Keputusan Implementasi

### 2.1 Kanal autentikasi

- Web selalu mengirim `platform: "web"`.
- Mobile tetap mengirim `platform: "mobile"`.
- Backend menerapkan matriks role:
  - `web`: hanya `kader` dan `puskesmas`.
  - `mobile`: hanya `orang_tua`.
- Nilai `platform` tetap opsional sementara untuk kompatibilitas, tetapi request tanpa platform diperlakukan sebagai `web` dan dicatat untuk evaluasi penghapusan fallback.
- Frontend tetap memvalidasi allowlist role sebagai pertahanan UX. Role yang tidak didukung tidak boleh disimpan ke `localStorage`.

### 2.2 Presisi pengukuran

- Kontrak kanonis adalah maksimal dua angka desimal karena database memakai `DECIMAL(5,2)`.
- Backend menormalisasi seluruh ukuran ke dua desimal **sebelum** menghitung Z-score dan menyimpan data.
- Frontend memakai `step="0.01"`, validasi maksimal dua desimal, dan menampilkan maksimal dua desimal secara konsisten.
- Tidak diperlukan migrasi skema database.

### 2.3 Rentang ukuran

Gunakan rentang backend saat ini sebagai kontrak API:

| Field | Minimum | Maksimum | Unit |
|---|---:|---:|---|
| `berat_badan` | 0,01 | 30 | kg |
| `tinggi_badan` | 0,01 | 120 | cm |
| `lingkar_kepala` | 1 | 80 | cm |
| `lingkar_lengan` | 1 | 60 | cm |

Validasi domain WHO—termasuk batas tinggi/panjang berdasarkan tabel dan usia 0–1856 hari—tetap menjadi otoritas backend. Frontend melakukan pre-validation usia untuk UX, tetapi tidak menghitung kategori antropometri sendiri.

### 2.4 Anak di luar rentang WHO

- Data anak tidak dihapus dan pendaftaran anak yang lebih tua tidak langsung dilarang karena data historis mungkin tetap dibutuhkan.
- Form pengukuran memvalidasi kombinasi `tanggal_lahir` dan `tanggal_ukur`.
- Anak yang saat ini di luar rentang diberi penanda pada dropdown/daftar. Pengguna masih dapat memilih tanggal historis yang valid.
- Backend tetap menjadi pengaman terakhir dan mengembalikan error domain yang terstruktur.

### 2.5 Search dan filter

- Search/filter dilakukan server-side sebelum `LIMIT/OFFSET`.
- Parameter pencarian dibatasi, dinormalisasi, dan dipakai melalui parameterized query.
- Ranking boleh tetap dihitung in-memory karena service saat ini memang mengambil seluruh pengukuran terbaru; filter harus diterapkan sebelum `slice()` pagination.

## 3. Urutan Implementasi

### Fase 0 — Bekukan kontrak dan tambahkan regression test

**Status:** Selesai pada 3 September 2026 (red phase).

Baseline setelah test ditambahkan:

- Backend: 216 test, 211 lulus, 5 gagal pada kontrak yang belum diimplementasikan.
- Frontend: 15 test, 8 lulus, 7 gagal pada kontrak yang belum diimplementasikan.
- Lint frontend: lulus.
- Test lama tetap lulus; seluruh kegagalan berasal dari regression test Fase 0.

Tujuan fase ini adalah membuat test gagal untuk setiap bug sebelum implementasi diperbaiki.

1. Tambahkan test backend untuk matriks `platform × role`.
2. Tambahkan test normalisasi dua desimal dan konsistensi hasil create/read.
3. Tambahkan test query search/filter beserta total pagination.
4. Tambahkan test batas usia 0, 1856, dan 1857 hari.
5. Tambahkan test frontend untuk pemetaan role, validasi ukuran, dan pembentukan query list.

Output fase: test baru mereproduksi lima temuan dan gagal pada implementasi lama.

---

### Fase 1 — Perbaikan autentikasi web

**Status:** Selesai pada 3 September 2026.

Verifikasi:

- 13 test autentikasi backend terfokus lulus.
- 7 test autentikasi/routing frontend terfokus lulus; 2 test domain fase berikutnya tetap merah.
- Build dan lint frontend lulus.
- 9 test autentikasi mobile Flutter lulus.
- Suite penuh menyisakan 4 kegagalan backend dan 4 kegagalan frontend yang seluruhnya merupakan kontrak Fase 2–4.

#### Backend

File utama:

- `src/controllers/authController.js`
- `src/validation/schemas.js`
- `test/` — test autentikasi kanal/role baru

Perubahan:

1. Normalisasikan `platform` menjadi `platform ?? "web"`.
2. Setelah password terverifikasi, tolak kombinasi role/platform yang tidak diizinkan.
3. Jangan membuat access token atau refresh token untuk kombinasi yang ditolak.
4. Web tetap tidak menerima refresh token; mobile orang tua tetap menerima refresh token.
5. Gunakan respons `403` dengan pesan aman dan dapat ditampilkan UI, misalnya “Akun ini tidak tersedia pada dashboard web”.

#### Frontend

File utama:

- `src/services/authService.js`
- `src/stores/authStore.js`
- `src/router/index.js`
- `src/views/auth/LoginView.vue`

Perubahan:

1. Sertakan `platform: "web"` pada login dan forgot-password.
2. Sebelum `setAuth`, validasi bahwa role termasuk `kader` atau `puskesmas`.
3. Buat helper tunggal `dashboardPathForRole(role)` yang mengembalikan path atau `null`.
4. Route guard tidak boleh memakai pola “selain kader berarti Puskesmas”.
5. Jika role tidak didukung atau data sesi korup, panggil `clearAuth()` dan arahkan sekali ke `/login` dengan pesan yang sesuai.

#### Test wajib

- Kader + web berhasil.
- Puskesmas + web berhasil.
- Orang tua + web ditolak tanpa token tersimpan.
- Orang tua + mobile tetap berhasil dan mendapat refresh token.
- Kader/Puskesmas + mobile ditolak.
- Route guard tidak mengalami redirect berulang untuk role tak dikenal.

#### Acceptance criteria

- Tidak ada cabang routing yang menganggap role tidak dikenal sebagai Puskesmas.
- Login orang tua melalui dashboard menghasilkan satu pesan error dan tetap berada di halaman login.
- Lifecycle login mobile tidak berubah.

---

### Fase 2 — Satukan kontrak KG/CM dan presisi

**Status:** Selesai pada 3 September 2026.

Verifikasi:

- 17 test backend pengukuran terfokus lulus, termasuk create/read dan kontrak orang tua.
- 7 test frontend Fase 2 lulus; 1 test tanggal WHO Fase 4 tetap merah.
- Lint dan build frontend lulus.
- 23 test fitur pengukuran Flutter lulus.
- Suite penuh menyisakan 3 kegagalan backend untuk Fase 3 serta 3 kegagalan frontend untuk Fase 3–4.

#### Backend

File utama:

- `src/middlewares/validate.js`
- `src/validation/schemas.js`
- `src/controllers/pengukuranController.js`
- `src/services/pengukuranService.js`
- test pengukuran baru atau `test/pengukuran-model-insight.test.js`

Perubahan:

1. Tambahkan utilitas numerik kanonis, misalnya `normalizeMeasurement(value, scale = 2)`.
2. Normalisasi dilakukan setelah pemeriksaan finite/range dan sebelum pemanggilan `hitungSemuaZScore()`.
3. Gunakan BB/TB ternormalisasi untuk perhitungan Z-score, SAW/prioritas, insert database, response create, dan notifikasi.
4. Normalisasikan `lingkar_kepala` dan `lingkar_lengan` jika terisi hanya untuk penyimpanan dan response; kedua field ini tidak menjadi input Z-score atau SAW.
5. Hindari kebenaran berbasis `if (value)` untuk field opsional; gunakan pemeriksaan `null/undefined` eksplisit.
6. Pertahankan `DECIMAL(5,2)` sehingga tidak ada migrasi data.

#### Frontend

File utama:

- `src/views/kader/PengukuranView.vue`
- `src/utils/format.js`
- `src/components/cards/PengukuranResultCard.vue`
- halaman detail/ranking yang menampilkan BB/TB

Perubahan:

1. Ubah semua input ukuran menjadi `step="0.01"`.
2. Samakan `min/max` HTML dan computed validation dengan kontrak API.
3. Tambahkan validasi inline untuk lingkar kepala/lengan.
4. Tolak lebih dari dua angka desimal sebelum submit.
5. Buat formatter ukuran terpusat agar nilai tidak tampil sebagai campuran `11`, `11.0`, dan `11.00` tanpa aturan.
6. Tetap tampilkan unit terpisah dari nilai agar payload selalu numerik.

#### Test wajib

- Permintaan API dengan `10.123` dinormalisasi menjadi nilai kanonis `10.12`; hasil perhitungan harus identik dengan nilai yang akhirnya tersimpan.
- Create response dan read response menghasilkan ukuran, Z-score, status, SAW, dan prioritas yang identik.
- Batas min/max dan nilai tepat pada batas diterima.
- Nilai di luar batas ditolak frontend dan backend.
- Field opsional kosong menjadi `null`, bukan `0` atau string kosong.

#### Acceptance criteria

- Tidak ada nilai yang dihitung dengan presisi berbeda dari nilai yang tersimpan.
- Semua empat field ukuran mempunyai feedback inline.
- API dan UI menggunakan rentang yang sama.

---

### Fase 3 — Server-side search/filter sebelum pagination

#### Kontrak query

| Endpoint | Parameter baru |
|---|---|
| `GET /api/kader/orang-tua` | `search` |
| `GET /api/kader/anak` | `search`, `jenis_kelamin` |
| `GET /api/puskesmas/anak` | `search`, `jenis_kelamin` |
| `GET /api/pengukuran/ranking` | `search`, `prioritas` |
| `GET /api/rujukan` | `search`, `status` |

Ketentuan:

- `search`: opsional, trim, maksimum 100 karakter.
- `jenis_kelamin`: `L` atau `P`.
- `prioritas`: `rendah`, `sedang`, atau `tinggi`.
- `status`: `diajukan`, `ditangani`, atau `selesai`.
- `pagination.total` dan `total_pages` dihitung setelah filter.

#### Backend

File utama:

- `src/validation/schemas.js`
- `src/routes/kader.js`
- `src/routes/puskesmas.js`
- `src/routes/pengukuran.js`
- `src/routes/rujukan.js`
- `src/controllers/kaderController.js`
- `src/controllers/puskesmasController.js`
- `src/controllers/pengukuranController.js`
- `src/controllers/rujukanController.js`
- `src/models/anakModel.js`
- `src/models/orangTuaModel.js`
- `src/models/rujukanModel.js`
- `src/services/pengukuranService.js`

Perubahan:

1. Tambahkan schema query per jenis list dan gunakan `validateQuery` pada route.
2. Ubah signature model menjadi menerima object filter, bukan daftar argumen posisi yang terus bertambah.
3. Bangun `WHERE` dan parameter untuk query list serta count dari helper yang sama agar hasil dan total tidak berbeda.
4. Search orang tua mencakup nama, NIK, alamat, dan email bila dibutuhkan UI.
5. Search anak mencakup nama anak dan nama orang tua.
6. Search rujukan mencakup nama anak dan nama orang tua.
7. Ranking menerapkan `search/prioritas` setelah enrichment tetapi sebelum sort/slice; `total` berasal dari list yang sudah difilter.
8. Untuk ringkasan status rujukan, kembalikan agregat seluruh hasil—bukan menghitung dari satu halaman—atau sediakan endpoint summary terpisah.

#### Frontend

File utama:

- seluruh service/store list terkait
- `src/views/kader/AnakView.vue`
- `src/views/kader/OrangTuaView.vue`
- `src/views/kader/RankingView.vue`
- `src/views/puskesmas/AnakView.vue`
- `src/views/puskesmas/RankingView.vue`
- `src/views/puskesmas/RujukanView.vue`

Perubahan:

1. Store meneruskan seluruh filter, tidak hanya `page` dan `limit`.
2. Saat search/filter berubah, reset page ke `1`.
3. Search dikirim dengan debounce sekitar 300 ms.
4. Abaikan response request lama jika request baru telah dikirim, agar hasil tidak tertimpa race condition.
5. Hapus computed filter lokal yang memberi kesan pencarian global, atau gunakan hanya sebagai fallback tampilan tanpa mengubah total.
6. Pertahankan filter ketika pengguna berpindah halaman.

#### Test wajib

- Item pada halaman ketiga ditemukan dari halaman pertama melalui search.
- Total dan total halaman mengikuti filter.
- Kombinasi search + enum filter bekerja.
- Query invalid ditolak `400`.
- Karakter `%`, `_`, kutip, dan input panjang tidak mengubah struktur SQL.
- Perubahan search cepat tidak menampilkan response lama.

#### Acceptance criteria

- Search/filter selalu berlaku terhadap seluruh dataset.
- Angka “x dari y data” dan ringkasan status tidak berasal dari halaman aktif saja.
- URL API tetap backward-compatible saat parameter baru tidak diberikan.

---

### Fase 4 — Validasi rentang usia WHO

#### Backend

File utama:

- `src/services/zscoreService.js`
- `src/controllers/pengukuranController.js`
- `src/utils/response.js` bila diperlukan untuk error code

Perubahan:

1. Ekspor helper domain untuk validasi rentang usia agar tidak ada angka `1856` yang diduplikasi.
2. Kembalikan kode error stabil, misalnya `PENGUKURAN_USIA_DI_LUAR_REFERENSI`, bersama pesan pengguna.
3. Pertahankan pemeriksaan tanggal ukur sebelum tanggal lahir dan setelah hari ini.
4. Dokumentasikan bahwa kelayakan bergantung pada tanggal ukur, bukan hanya umur anak hari ini.

#### Frontend

File utama:

- `src/views/kader/PengukuranView.vue`
- `src/components/forms/FormAnak.vue`
- utilitas tanggal domain baru, misalnya `src/utils/measurementEligibility.js`

Perubahan:

1. Hitung selisih hari kalender antara tanggal lahir dan tanggal ukur.
2. Set `min-date` pengukuran ke tanggal lahir dan `max-date` ke minimum antara hari ini dan hari ke-1856.
3. Tampilkan alasan ketika anak/tanggal tidak memenuhi referensi WHO.
4. Pada pendaftaran anak yang saat ini di luar usia, tampilkan warning bahwa pengukuran baru hanya dapat dicatat untuk tanggal historis dalam rentang yang didukung.
5. Jangan menghitung Z-score atau kategori di frontend.

#### Test wajib

- Tanggal ukur sebelum lahir ditolak.
- Usia hari ke-0 dan ke-1856 diterima.
- Usia hari ke-1857 ditolak.
- Perhitungan tetap benar melewati tahun kabisat dan timezone WIB.

#### Acceptance criteria

- Pengguna mengetahui ketidaklayakan sebelum submit.
- Backend dan frontend setuju pada batas tanggal yang sama.
- Data anak lama tetap dapat dibuka dan dilaporkan.

---

### Fase 5 — Konsistensi satuan dan dataset WHO

#### Perubahan

1. Gunakan simbol SI `kg`, `cm`, dan `kg/m²` pada web, notifikasi, dan PDF.
2. Ubah `whoTables.json` frontend menjadi nama yang menjelaskan kegunaannya, misalnya `whoMonthlyChartTables.json`.
3. Dokumentasikan bahwa:
   - kategori resmi dihitung backend dari tabel harian;
   - frontend hanya menggambar kurva referensi bulanan;
   - grafik bukan sumber keputusan kategori.
4. Tambahkan metadata versi/sumber atau script generator sehingga file WHO tidak diedit manual.
5. Tambahkan test checksum/semantic untuk tabel yang memang harus identik (`wfl` dan `wfh`).
6. Tambahkan keterangan pada grafik bahwa status antropometri mengikuti hasil server berbasis usia harian.

File utama:

- `web-dashboard/src/components/charts/KMSChart.vue`
- `web-dashboard/src/constants/whoTables.json`
- `web-dashboard/src/utils/format.js`
- `backend-express/src/services/laporanRendererService.js`
- `backend-express/src/controllers/pengukuranController.js`
- `who-converter/`

#### Acceptance criteria

- Tidak ada unit `KG`, `CM`, atau `KG/m²` pada output pengguna.
- Perubahan dataset WHO hanya dilakukan melalui proses yang terdokumentasi dan dapat diverifikasi.
- UI tidak mengklaim bahwa posisi visual kurva adalah hasil klasifikasi resmi.

## 4. Strategi Test Menyeluruh

### Backend

Jalankan:

```bash
npm test
```

Tambahkan cakupan minimal:

- kontrak autentikasi kanal/role;
- normalisasi ukuran dan boundary value;
- integrasi endpoint list dengan search/filter/pagination;
- regresi Z-score, SAW, prioritas, rujukan, dan laporan;
- error code usia WHO.

### Frontend

Jalankan:

```bash
npm run check
```

Tambahkan unit/integration test minimal untuk:

- helper role-to-route;
- auth store tidak menyimpan role tak didukung;
- validator pengukuran;
- store meneruskan query filter;
- debounce dan stale-response handling;
- batas tanggal pengukuran;
- formatter unit.

### Pengujian end-to-end

Skenario smoke setelah backend dan frontend dijalankan dengan database uji:

1. Login kader dan Puskesmas berhasil.
2. Login orang tua pada web ditolak tanpa loop.
3. Catat pengukuran dua desimal, lalu buka detail dan pastikan hasil identik.
4. Cari data yang sebelumnya berada di halaman lebih dari satu.
5. Uji anak pada batas usia WHO.
6. Buat rujukan, ubah status berurutan, dan unduh laporan PDF.

## 5. Urutan Deployment

1. Deploy backend yang menerima kontrak lama sekaligus query/filter baru.
2. Jalankan test dan smoke terhadap aplikasi mobile untuk memastikan autentikasi mobile tidak berubah.
3. Deploy frontend web dengan `platform: "web"`, route guard baru, validasi ukuran, dan server-side search.
4. Pantau selama satu siklus penggunaan:
   - jumlah login role/platform yang ditolak;
   - error validasi pengukuran;
   - request pencarian lambat;
   - error usia WHO;
   - perbedaan hasil create/read.
5. Setelah tidak ada client lama tanpa `platform`, pertimbangkan menjadikan `platform` wajib pada versi API berikutnya.

Rollback frontend dan backend dapat dilakukan terpisah karena parameter query baru bersifat opsional dan schema database tidak berubah.

## 6. Definition of Done

Perbaikan dianggap selesai jika:

- seluruh test backend dan `npm run check` frontend lulus;
- lima regression test utama tersedia;
- tidak ada redirect loop untuk role apa pun;
- response create dan read pengukuran identik untuk data yang sama;
- search/filter bekerja terhadap seluruh dataset dan total pagination benar;
- kombinasi tanggal lahir/tanggal ukur di luar WHO diblokir dengan pesan jelas;
- unit tampil konsisten sebagai `kg`, `cm`, dan `kg/m²`;
- dokumentasi kontrak API dan catatan dataset WHO diperbarui;
- smoke test login, pengukuran, ranking, rujukan, dan laporan lulus;
- tidak ada regresi pada aplikasi mobile.

## 7. Estimasi Urutan Pengerjaan

| Paket kerja | Dependensi | Perkiraan relatif |
|---|---|---|
| Fase 0: regression tests | — | Sedang |
| Fase 1: autentikasi | Fase 0 | Kecil |
| Fase 2: KG/CM dan presisi | Fase 0 | Sedang |
| Fase 3: search/filter | Fase 0 | Besar |
| Fase 4: usia WHO | Fase 2 | Sedang |
| Fase 5: unit/dataset WHO | Fase 2 dan 4 | Kecil–sedang |

Fase 1 dan Fase 2 dapat dikerjakan paralel. Fase 3 dapat dimulai setelah kontrak query disepakati. Fase 5 dikerjakan terakhir agar hanya merapikan kontrak yang sudah stabil.
