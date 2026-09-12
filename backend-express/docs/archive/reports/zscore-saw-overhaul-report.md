# Laporan Lengkap Perombakan WHO Z-Score dan SAW

> **Status dokumen: HISTORIS — perubahan utama telah diterapkan.** Dokumen ini adalah laporan perubahan domain Agustus 2026. Angka test di bawah adalah snapshot; gunakan [kontrak prioritas aktif](../../PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md) dan [evidence terbaru](../../../../docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md).

**Sistem:** Tumbuh Posyandu / Backend Express  
**Tanggal:** 27 Agustus 2026  
**Cakupan:** `backend-express`, `who-converter`, tabel WHO, perhitungan antropometri, SAW, API pengukuran, dashboard, rujukan, AI insight, seeder, dan regression test.  
**Strategi database:** fresh database untuk data testing; tidak menggunakan migration.

## 1. Ringkasan Eksekutif

Modul antropometri dan perankingan telah dirombak agar memiliki pemisahan tanggung jawab yang jelas:

1. Data WHO menjadi sumber LMS untuk menghitung Z-score.
2. Permenkes digunakan untuk memberi kategori pada setiap indikator antropometri.
3. SAW hanya digunakan untuk mengurutkan prioritas pemantauan.
4. SAW tidak digunakan untuk mendiagnosis stunting atau membatasi keputusan rujukan.

Empat indikator yang digunakan adalah:

- BB/U — Weight-for-Age (WFA).
- TB/U — Length/Height-for-Age (LHFA).
- BB/TB — Weight-for-Length atau Weight-for-Height (WFL/WFH).
- IMT/U — BMI-for-Age (BFA).

Bobot SAW aktif:

| Kriteria | Bobot |
|---|---:|
| BB/U | 0,25 |
| TB/U | 0,30 |
| BB/TB | 0,25 |
| IMT/U | 0,20 |
| **Total** | **1,00** |

Tren berat badan telah dihapus dari seluruh perhitungan SAW, response, query, dan seeder.

## 2. Kondisi Sebelum Perombakan

### 2.1 Data WHO kehilangan granularitas

WHO Expanded Tables menyediakan referensi usia per hari dari hari 0 sampai 1.856. Converter lama mengubah tabel tersebut menjadi 61 titik bulanan melalui:

```text
hariTarget = round(month × 30,4375)
```

Converter kemudian memilih baris harian terdekat. Proses ini tidak merusak data Excel, tetapi menghilangkan granularitas sumber dan membuat backend perlu melakukan interpolasi bulanan kembali.

### 2.2 Kontrak JSON dan backend tidak konsisten

JSON baru menggunakan nama standar Inggris:

```text
wfa_boys, wfa_girls
lhfa_boys, lhfa_girls
wfl_boys, wfl_girls
wfh_boys, wfh_girls
bfa_boys, bfa_girls
```

Service lama masih mencari key seperti `bbu_L`, `tbu_P`, serta properti `bulan`, `panjang`, dan `tinggi`. Akibatnya referensi tidak ditemukan dan test Z-score gagal.

### 2.3 IMT/U belum digunakan

Tabel BFA telah tersedia, tetapi backend belum menghitung IMT, Z-score IMT/U, maupun kategorinya. IMT/U juga belum menjadi kriteria SAW.

### 2.4 Ambang kategori tidak sesuai Permenkes

Beberapa masalah sebelumnya:

- BB/U dianggap normal sampai +2 SD, seharusnya sampai +1 SD.
- TB/U dianggap normal sampai +2 SD, seharusnya sampai +3 SD.
- BB/TB dianggap normal sampai +2 SD, seharusnya sampai +1 SD.
- Kategori berisiko gizi lebih belum tersedia.
- Status beberapa indikator digabung menjadi satu `status_gizi` buatan sistem.

### 2.5 Model SAW lama tidak sesuai keputusan desain

Model sebelumnya memakai:

| Kriteria lama | Bobot lama |
|---|---:|
| TB/U | 0,40 |
| BB/U | 0,25 |
| BB/TB | 0,20 |
| Tren BB | 0,15 |

Normalisasi lama memetakan Z-score 0 menjadi nilai risiko 0,4. Anak dengan seluruh indikator di sekitar median WHO dapat memperoleh skor kategori sedang, terutama karena pengukuran pertama juga mendapat nilai tren netral 0,5.

### 2.6 Seeder menduplikasi algoritma

Generator seeder memiliki salinan perhitungan Z-score dan SAW sendiri. Salinan tersebut masih memakai key bulanan lama serta fallback nilai Z-score `0`, sehingga kesalahan referensi dapat tersembunyi dan menghasilkan data testing yang tampak valid.

## 3. Perombakan WHO Converter

File utama:

```text
who-converter/convert.js
who-converter/whoTables.json
```

### 3.1 Konversi harian dihapus

Fungsi `konversiHariKeBulan` dihapus. WFA, LHFA, dan BFA sekarang mempertahankan setiap baris sumber dengan format:

```json
{
  "day": 45,
  "L": 0.123,
  "M": 5.123,
  "S": 0.101
}
```

### 3.2 Jumlah data hasil converter

| Tabel | Jumlah per jenis kelamin | Referensi |
|---|---:|---|
| WFA | 1.857 | hari 0–1.856 |
| LHFA | 1.857 | hari 0–1.856 |
| BFA | 1.857 | hari 0–1.856 |
| WFL | 651 | panjang 45–110 cm, interval 0,1 cm |
| WFH | 551 | tinggi 65–120 cm, interval 0,1 cm |

### 3.3 Validasi converter

Converter sekarang memeriksa:

- Header `Day`, `Length`, atau `Height` tersedia.
- Kolom `L`, `M`, dan `S` tersedia.
- Seluruh nilai yang diproses numerik.
- Data harian berurutan dan tidak memiliki hari yang hilang.

JSON converter dan JSON backend telah diverifikasi memiliki hash SHA-256 yang identik saat sinkronisasi dilakukan.

## 4. Perombakan Perhitungan Z-Score

File utama:

```text
src/services/zscoreService.js
```

### 4.1 Usia dihitung dalam hari kalender

Backend menghitung:

```text
usia_hari = tanggal_ukur - tanggal_lahir
```

Tanggal dinormalisasi sebagai tanggal kalender UTC sehingga perbedaan timezone atau daylight-saving tidak menggeser hasil satu hari.

`usia_bulan` tetap disediakan untuk kompatibilitas dan tampilan, tetapi lookup LMS menggunakan `usia_hari`.

Rentang yang didukung:

```text
0–1.856 hari
```

### 4.2 Pemetaan jenis kelamin

```text
L → boys
P → girls
```

### 4.3 Lookup tabel

| Indikator | Tabel laki-laki | Tabel perempuan |
|---|---|---|
| BB/U | `wfa_boys` | `wfa_girls` |
| TB/U | `lhfa_boys` | `lhfa_girls` |
| BB/TB usia <731 hari | `wfl_boys` | `wfl_girls` |
| BB/TB usia ≥731 hari | `wfh_boys` | `wfh_girls` |
| IMT/U | `bfa_boys` | `bfa_girls` |

Data usia harian diakses langsung melalui indeks array dan diverifikasi kembali melalui properti `day`.

### 4.4 Rumus LMS

Untuk `L ≠ 0`:

```text
Z = ((nilai / M)^L - 1) / (L × S)
```

Untuk `L = 0`:

```text
Z = ln(nilai / M) / S
```

### 4.5 Modified Z-score untuk nilai ekstrem

Untuk hasil LMS di luar ±3 SD, backend menggunakan ekstrapolasi linear berdasarkan jarak antara kurva SD2 dan SD3. Hal ini mencegah distorsi formula LMS pada nilai antropometri ekstrem.

### 4.6 IMT/U

IMT dihitung dengan:

```text
IMT = berat badan kg / (tinggi badan meter)^2
```

Response menambahkan:

```text
nilai_imt
zscore_imtu
status_imtu
```

## 5. Kategori Antropometri Permenkes

Kategori dipertahankan secara independen. Backend tidak lagi membuat kesimpulan gabungan `status_gizi`.

### 5.1 BB/U

| Z-score | Status backend |
|---|---|
| `< -3` | `berat_badan_sangat_kurang` |
| `-3 sampai < -2` | `berat_badan_kurang` |
| `-2 sampai +1` | `berat_badan_normal` |
| `> +1` | `risiko_berat_badan_lebih` |

### 5.2 TB/U

| Z-score | Status backend |
|---|---|
| `< -3` | `sangat_pendek` |
| `-3 sampai < -2` | `pendek` |
| `-2 sampai +3` | `normal` |
| `> +3` | `tinggi` |

### 5.3 BB/TB dan IMT/U

| Z-score | Status backend |
|---|---|
| `< -3` | `gizi_buruk` |
| `-3 sampai < -2` | `gizi_kurang` |
| `-2 sampai +1` | `gizi_baik` |
| `> +1 sampai +2` | `risiko_gizi_lebih` |
| `> +2 sampai +3` | `gizi_lebih` |
| `> +3` | `obesitas` |

## 6. Perombakan SAW

File utama:

```text
src/services/sawService.js
```

### 6.1 Tujuan SAW

SAW digunakan untuk:

- Menghasilkan skor prioritas pemantauan.
- Mengurutkan anak dari prioritas tertinggi ke terendah.
- Membantu kader dan Puskesmas mengatur urutan tindak lanjut.

SAW tidak digunakan untuk:

- Menetapkan diagnosis stunting.
- Menggantikan interpretasi indikator antropometri.
- Menggantikan pemeriksaan tenaga kesehatan.
- Menolak rujukan yang dibuat berdasarkan penilaian kader atau tenaga kesehatan.

### 6.2 Sumber bobot

Bobot diadopsi dari dua penelitian SAW sejenis yang menggunakan BB/U, TB/U, BB/TB, dan IMT/U. Pada penelitian tersebut bobot ditetapkan melalui wawancara dengan pihak Puskesmas dan bidan.

Yang diadopsi hanya susunan kriteria dan nilai bobot. Sistem tidak mengadopsi keputusan diagnosis, rating subkriteria, maupun batas stunting dari artikel tersebut.

### 6.3 Transformasi Z-score

Z-score negatif tidak dapat langsung digunakan dalam weighted sum. Backend mengubahnya menjadi nilai prioritas 0–1:

```text
nilai_prioritas = clamp(-Z / 3, 0, 1)
```

| Z-score | Nilai prioritas |
|---:|---:|
| `≥ 0` | 0,000 |
| `-1` | 0,333 |
| `-2` | 0,667 |
| `≤ -3` | 1,000 |

Setelah transformasi, semua kriteria diperlakukan sebagai benefit: nilai lebih besar berarti prioritas pemantauan lebih tinggi.

### 6.4 Weighted sum

```text
skor_akhir =
    nilai BB/U  × 0,25 +
    nilai TB/U  × 0,30 +
    nilai BB/TB × 0,25 +
    nilai IMT/U × 0,20
```

Total bobot diverifikasi saat module dimuat. Backend gagal memuat service apabila total bobot tidak sama dengan 1.

### 6.5 Kategori prioritas

| Skor | Kategori |
|---|---|
| `0–0,3333` | `rendah` |
| `>0,3333–0,6667` | `sedang` |
| `>0,6667–1` | `tinggi` |

Batas tersebut merupakan pembagian operasional sistem, bukan batas klinis WHO atau Permenkes.

### 6.6 Perubahan cost dan benefit

Z-score rendah pada awalnya merepresentasikan kondisi yang perlu lebih diperhatikan. Setelah ditransformasikan menjadi nilai prioritas, arah kriterianya dibalik:

```text
Z-score semakin rendah
        ↓
nilai prioritas semakin tinggi
        ↓
skor SAW semakin tinggi
```

Karena itu implementasi akhir memperlakukan seluruh nilai prioritas sebagai benefit. Tidak ada lagi kombinasi `min/x` atau `x/max` pada Z-score negatif.

## 7. Arti Prioritas Bagi Pengguna

### 7.1 Kader

Prioritas digunakan sebagai work queue:

- Menentukan anak yang lebih dahulu diperhatikan.
- Melihat status empat indikator secara terpisah.
- Memberikan edukasi dan pendampingan.
- Mengomunikasikan temuan kepada Puskesmas bila diperlukan.

Prioritas tidak menyatakan bahwa hasil pengukuran kader salah. Pengukuran ulang hanya diperlukan jika terdapat indikasi nilai tidak wajar, masalah alat, prosedur ukur yang tidak sesuai, atau keputusan petugas.

### 7.2 Petugas Puskesmas

Prioritas berfungsi sebagai triase administratif awal. Petugas tetap menilai:

- Hasil antropometri per indikator.
- Riwayat pertumbuhan.
- Kondisi klinis dan faktor lain di luar SAW.
- Kebutuhan konseling, intervensi, pemeriksaan, atau rujukan.

### 7.3 Orang tua

Orang tua cukup melihat kategori prioritas, status indikator, dan arahan tindak lanjut. Ranking numerik antar-anak tidak perlu ditampilkan.

Redaksi yang disarankan:

```text
Prioritas pemantauan: Sedang

Hasil pertumbuhan anak memerlukan perhatian lebih. Silakan mengikuti
pemantauan rutin dan berkonsultasi dengan kader atau petugas Puskesmas
untuk mendapatkan saran pendampingan yang sesuai.
```

Catatan non-diagnosis sebaiknya ditempatkan pada halaman detail, bukan sebagai kalimat utama yang dapat mengurangi kepercayaan terhadap kader:

```text
Prioritas pemantauan merupakan alat bantu kader dan petugas Puskesmas
dalam menentukan urutan tindak lanjut, bukan diagnosis medis.
```

## 8. Perubahan Kontrak API

### 8.1 Field yang ditambahkan

```text
usia_hari
nilai_imt
zscore_imtu
status_imtu
kategori_prioritas
total_prioritas_tinggi
```

### 8.2 Field yang dihapus atau diganti

```text
tren_bb           → dihapus
status_gizi       → dihapus; gunakan status tiap indikator
kategori_risiko   → kategori_prioritas
total_stunting    → total_prioritas_tinggi
```

### 8.3 Contoh response pengukuran

```json
{
  "usia_bulan": 24,
  "usia_hari": 730,
  "berat_badan": 11,
  "tinggi_badan": 85,
  "nilai_imt": 15.22,
  "zscore_bbu": -0.4,
  "zscore_tbu": -1.2,
  "zscore_bbtb": 0.1,
  "zscore_imtu": 0.15,
  "status_bbu": "berat_badan_normal",
  "status_tbu": "normal",
  "status_bbtb": "gizi_baik",
  "status_imtu": "gizi_baik",
  "skor_saw": 0.1533,
  "kategori_prioritas": "rendah"
}
```

### 8.4 Dashboard

Dashboard distribusi sekarang mengembalikan bucket terpisah:

```text
bbu
tbu
bbtb
imtu
```

Endpoint baru:

```text
GET /dashboard/prioritas
```

Endpoint lama tetap tersedia sementara sebagai alias kompatibilitas:

```text
GET /dashboard/risiko
```

## 9. Perubahan Integrasi Backend

### 9.1 Pengukuran controller

- Menghitung empat Z-score sebelum menyimpan raw measurement.
- Menghitung SAW tanpa data pengukuran sebelumnya.
- Mengembalikan IMT/U dan kategori prioritas.
- Notifikasi memakai istilah prioritas pemantauan.

### 9.2 Pengukuran service

- Enrichment riwayat tidak lagi membalik daftar untuk menghitung tren BB.
- Ranking memakai empat indikator.
- Statistik mengganti `total_stunting` dengan `total_prioritas_tinggi`.
- Distribusi status dipisahkan per indikator.
- Tren dashboard dipisahkan per indikator.

### 9.3 Pengukuran model

- Query pengukuran terakhir tidak lagi menghitung `LAG(berat_badan)`.
- Field `berat_sebelumnya` dan `tanggal_sebelumnya` dihapus.
- Fungsi `findPrevious` untuk tren berat dihapus.

### 9.4 Rujukan

Prioritas SAW hanya dilampirkan sebagai informasi. Backend tidak lagi menolak rujukan hanya karena prioritas SAW rendah.

### 9.5 Gemini insight

Prompt sekarang menerima:

- Usia hari.
- Nilai IMT.
- Z-score dan status IMT/U.
- Kategori prioritas.

Prompt menyatakan bahwa SAW adalah pemeringkatan prioritas dan bukan diagnosis stunting.

## 10. Perombakan Seeder

File:

```text
src/database/seeder/generate-seeder.js
src/database/seeder/seeder.sql
```

Generator tidak lagi memiliki salinan algoritma WHO dan SAW. Seeder mengimpor langsung:

```text
hitungSemuaZScore
hitungUsiaBulan
hitungSAW
```

Dampaknya:

- Key WHO harian selalu sama dengan production service.
- Tidak ada fallback Z-score `0`.
- Tidak ada bobot ganda yang berpotensi berbeda.
- IMT/U otomatis ikut dihitung.
- Perubahan algoritma service langsung digunakan seeder.

Generator final berhasil membuat:

```text
15 anak
90 pengukuran
40 riwayat pemberian
1 contoh rujukan prioritas tinggi
11 notifikasi
```

Seeder SQL telah dibuat ulang, tetapi tidak dijalankan ke database selama implementasi ini.

## 11. Pengujian dan Verifikasi

Regression test mencakup:

- Lookup usia harian.
- Tahun kabisat.
- Batas perpindahan WFL/WFH pada hari ke-731.
- Penolakan usia di luar 1.856 hari.
- Penolakan tanggal dan nilai numerik tidak valid.
- Perhitungan IMT/U.
- Kategori Permenkes pada batas -3, -2, +1, +2, dan +3.
- Bobot SAW berjumlah 1.
- Empat kriteria SAW sesuai desain.
- Tidak ada tren BB dalam detail SAW.
- Z-score 0 menghasilkan skor prioritas 0.
- Z-score -3 pada seluruh indikator menghasilkan skor 1.
- Kriteria IMT/U wajib tersedia dan tidak memiliki fallback.
- Status obesitas BB/TB dan IMT/U independen.

Hasil akhir:

```text
16 test lulus
0 test gagal
Sintaks seluruh file JavaScript valid
Generator seeder berhasil
git diff --check berhasil
```

## 12. Breaking Changes

Frontend atau client yang masih memakai field berikut harus diperbarui:

```text
status_gizi
kategori_risiko
tren_bb
total_stunting
```

Client juga harus mampu menampilkan kategori status baru dan distribusi dashboard berbentuk nested object per indikator.

Tidak ada migration database karena seluruh nilai Z-score dan SAW dihitung on-the-fly dari raw measurement.

## 13. Batasan dan Risiko yang Masih Berlaku

### 13.1 Metode pengukuran panjang/tinggi diasumsikan dari usia

Backend belum menyimpan apakah anak diukur berbaring atau berdiri. Sistem mengasumsikan:

```text
<731 hari  → berbaring/WFL
≥731 hari → berdiri/WFH
```

Asumsi ini memadai selama prosedur Posyandu konsisten. Jika metode aktual berbeda, penyesuaian panjang/tinggi 0,7 cm belum diterapkan.

### 13.2 Bobot belum divalidasi pada populasi lokal

Bobot mempunyai dasar literatur, tetapi belum melalui AHP, expert elicitation lokal, atau validasi terhadap data operasional Posyandu tempat sistem digunakan.

Bobot harus dituliskan sebagai bobot yang diadopsi dari penelitian, bukan sebagai bobot resmi WHO atau Kemenkes.

### 13.3 BB/TB dan IMT/U berkorelasi

Kedua indikator menggunakan berat dan tinggi sehingga informasi dapat tumpang tindih. Penggunaannya dipertahankan karena mengikuti model literatur, tetapi potensi double-counting harus dicantumkan sebagai keterbatasan penelitian.

### 13.4 Kategori prioritas bersifat operasional

Batas sepertiga rendah/sedang/tinggi belum divalidasi secara klinis. Batas tersebut hanya membantu pengelompokan work queue.

### 13.5 Z-score positif tidak menaikkan prioritas SAW

Transformasi SAW berorientasi pada gangguan pertumbuhan ke bawah:

```text
nilai_prioritas = clamp(-Z / 3, 0, 1)
```

Anak dengan Z-score IMT/U tinggi atau obesitas dapat memiliki prioritas SAW rendah. Status `status_imtu: obesitas` tetap tersedia dan harus ditindaklanjuti secara independen. SAW tidak boleh dipakai sebagai satu-satunya filter masalah gizi.

### 13.6 Belum ada validasi klinis prospektif

Test memastikan konsistensi perangkat lunak dan batas kategori, bukan akurasi klinis pada populasi nyata. Evaluasi lapangan tetap diperlukan sebelum penggunaan operasional skala besar.

## 14. Rekomendasi Tindak Lanjut

Prioritas berikutnya:

1. Sinkronkan frontend dengan field dan kategori API baru.
2. Tampilkan status empat indikator secara terpisah.
3. Tampilkan ranking lengkap hanya kepada kader dan Puskesmas.
4. Tampilkan kategori dan arahan sederhana kepada orang tua.
5. Tambahkan penjelasan sumber bobot pada dokumentasi penelitian.
6. Dokumentasikan kategori prioritas sebagai keputusan operasional, bukan klinis.
7. Lakukan user acceptance test dengan data contoh sebelum menjalankan fresh database setup.
8. Pertimbangkan field metode pengukuran hanya jika prosedur lapangan tidak selalu konsisten.

## 15. Daftar File yang Berubah

### WHO converter

```text
who-converter/convert.js
who-converter/whoTables.json
```

### Backend

```text
src/constants/whoTables.json
src/services/zscoreService.js
src/services/sawService.js
src/services/pengukuranService.js
src/services/geminiService.js
src/controllers/pengukuranController.js
src/controllers/dashboardController.js
src/controllers/rujukanController.js
src/models/pengukuranModel.js
src/routes/dashboard.js
src/database/seeder/generate-seeder.js
src/database/seeder/seeder.sql
test/high-risk-regression.test.js
```

## 16. Kesimpulan

Perombakan memisahkan standar pertumbuhan, kategori antropometri, dan pemeringkatan keputusan:

```text
Data WHO harian
        ↓
Z-score per indikator
        ↓
Kategori Permenkes independen
        ↓
Transformasi nilai prioritas
        ↓
Weighted sum SAW
        ↓
Ranking prioritas pemantauan
        ↓
Tindak lanjut kader/Puskesmas
```

Backend sekarang lebih konsisten dengan tujuan sistem: mendukung deteksi dan pemantauan risiko tanpa mengambil alih fungsi diagnosis atau keputusan klinis tenaga kesehatan.
