# Implementation Plan — Penyaringan Data Teknis Orang Tua

## Tujuan

- Orang tua hanya melihat hasil pertumbuhan dalam bahasa yang mudah dipahami.
- Z-score, skor SAW, bobot, normalisasi, dan peringkat tetap tersedia untuk proses internal, kader, dan Puskesmas.
- Data teknis tidak hanya disembunyikan dari UI, tetapi juga tidak dikirim melalui endpoint orang tua.
- AI Insight dan laporan orang tua tetap menggunakan kategori yang telah dihitung backend.

## Tahap 1 — Tetapkan kontrak data orang tua

**Status: selesai.** Kontrak normatif beserta tipe, nullability, enum, contoh
response, field terlarang, dan aturan rilis tersedia di
[`ORANG_TUA_PENGUKURAN_CONTRACT.md`](./ORANG_TUA_PENGUKURAN_CONTRACT.md).

Buat kontrak respons khusus pengukuran orang tua menggunakan whitelist.

Field yang boleh dikirim:

```
id
tanggal_ukur
berat_badan
tinggi_badan
lingkar_kepala
lingkar_lengan
usia_bulan
status_bbu
status_tbu
status_bbtb
status_imtu
status_pemantauan
created_at
```

Field yang dilarang:

```
usia_hari
zscore_bbu
zscore_tbu
zscore_bbtb
zscore_imtu
skor_saw
detail_saw
bobot
nilai_normalisasi
peringkat
```

`status_pemantauan` berasal dari kategori SAW internal:

| Kategori internal | Respons orang tua | Teks UI |
| --- | --- | --- |
| `rendah` | `rutin` | Pemantauan rutin |
| `sedang` | `perlu_perhatian` | Perlu perhatian |
| `tinggi` | `konsultasi` | Disarankan konsultasi |

Istilah SAW tidak digunakan dalam respons orang tua.

## Tahap 2 — Serializer khusus orang tua di backend

**Status: selesai.** Serializer strict-whitelist tersedia di
`src/serializers/orangTuaPengukuranSerializer.js` dan telah diterapkan hanya
pada `GET /api/orang-tua/anak/:id/pengukuran`. Perhitungan internal serta
endpoint kader/Puskesmas tidak diubah. Perubahan backend ini belum boleh
dideploy terpisah sebelum model dan UI mobile pada tahap berikutnya selesai.

Tambahkan serializer murni, misalnya:

```
toOrangTuaPengukuran(pengukuran)
```

Serializer harus:

- membangun objek baru dengan whitelist;
- tidak menggunakan spread `...pengukuran`;
- mengubah kategori internal menjadi `status_pemantauan`;
- mempertahankan status antropometri;
- tidak mengubah perhitungan Z-score atau SAW internal.

Endpoint yang diperbarui:

```
GET /api/orang-tua/anak/:id/pengukuran
```

Alurnya menjadi:

```
data DB
  ↓
hitung Z-score dan SAW
  ↓
hasilkan status/kategori
  ↓
serializer orang tua
  ↓
respons tanpa nilai teknis
```

Endpoint kader dan Puskesmas tidak diubah.

## Tahap 3 — Lindungi kontrak rujukan orang tua

**Status: selesai.** Kontrak normatif tersedia di
[`ORANG_TUA_RUJUKAN_CONTRACT.md`](./ORANG_TUA_RUJUKAN_CONTRACT.md). Serializer
strict-whitelist `src/serializers/orangTuaRujukanSerializer.js` telah diterapkan
khusus pada `GET /api/orang-tua/anak/:id/rujukan`. Endpoint teknis kader dan
Puskesmas tidak diubah. UI mobile lama masih dapat menampilkan nilai default
`Skor SAW 0.0000` sampai Tahap 4 dan 7 selesai, sehingga rilis tetap harus
terkoordinasi.

Audit dan tetapkan whitelist untuk:

```
GET /api/orang-tua/anak/:id/rujukan
```

Field yang dapat ditampilkan:

- status rujukan;
- tanggal pengajuan;
- tanggal validasi/selesai;
- catatan kader;
- catatan Puskesmas;
- petugas yang menangani;
- tanggal pengukuran terkait;
- berat dan tinggi badan.

Jangan mengirim atau menampilkan:

- skor SAW;
- kategori SAW mentah;
- Z-score;
- rincian perhitungan prioritas.

Ini juga memperbaiki kondisi mobile yang saat ini dapat menampilkan `Skor SAW 0.0000` karena field tersebut tidak dikirim backend tetapi diberi nilai default oleh model.

## Tahap 4 — Sederhanakan model mobile

**Status: selesai.** `PengukuranModel` kini mengikuti kontrak orang tua,
mempertahankan status antropometri, dan menggunakan `statusPemantauan` tanpa
menyimpan Z-score, skor SAW, atau kategori prioritas mentah. `RujukanModel`
tidak lagi memiliki nilai teknis. Parsing field wajib kini ketat dan tidak
memberikan fallback angka `0`. Referensi UI yang tidak dapat dikompilasi tanpa
field lama telah disesuaikan secara minimum; review UX lengkap tetap dilakukan
pada Tahap 5–7.

Perbarui `PengukuranModel` dengan menghapus:

```
zscoreBbu
zscoreTbu
zscoreBbtb
zscoreImtu
skorSaw
kategoriPrioritas
```

Tambahkan:

```
statusPemantauan
```

Model tetap mempertahankan:

```
statusBbu
statusTbu
statusBbtb
statusImtu
```

Perbarui `RujukanModel` dengan menghapus:

```
skorSaw
kategoriPrioritas
```

Parsing harus ketat untuk field wajib. Jangan memberikan nilai default `0` untuk field teknis yang sebenarnya tidak tersedia.

## Tahap 5 — Perbaiki UI detail dan riwayat pengukuran

**Status: selesai.** Detail pengukuran tidak lagi menampilkan bagian Z-score,
skor akhir, skor SAW, atau progress numerik. Data antropometri, empat status
pertumbuhan, AI Insight, conversational AI, dan kartu `Status Pemantauan`
tetap tersedia. Kartu riwayat hanya menampilkan tanggal, BB, TB, kategori
BB/TB, status pemantauan, dan navigasi detail. Subtitle detail anak telah
diubah menjadi bahasa pertumbuhan yang mudah dipahami. Komponen teknis grafik
dan skeleton yang sudah tidak digunakan akan diaudit pada Tahap 6.

### Detail pengukuran

Hapus:

- bagian Z-Score;
- kartu skor SAW;
- angka skor akhir;
- progress bar numerik SAW.

Pertahankan:

- berat dan tinggi badan;
- lingkar kepala dan lengan;
- kategori BB/U, TB/U, BB/TB dan IMT/U;
- AI Insight;
- tombol conversational AI.

Ganti kartu SAW dengan kartu sederhana:

```
Status Pemantauan

Perlu perhatian

Pantau pola makan dan pertumbuhan anak secara rutin.
Konsultasikan dengan kader bila ada kekhawatiran.
```

Tidak ada angka atau istilah algoritma.

### Riwayat pengukuran

Hapus metrik `Skor SAW`.

Setiap kartu cukup menampilkan:

- tanggal;
- berat badan;
- tinggi badan;
- kategori BB/TB;
- status pemantauan;
- tombol lihat detail.

### Detail anak

Ubah subtitle:

```
Lihat data BB, TB, dan z-score
```

menjadi:

```
Lihat pertumbuhan dan status gizi anak
```

## Tahap 6 — Sederhanakan grafik pertumbuhan

**Status: selesai.** Grafik orang tua kini kronologis berdasarkan tanggal dan
hanya memakai nilai fisik BB dalam kilogram serta TB dalam sentimeter. Tooltip
menampilkan tanggal, nilai fisik, dan kategori BB/U atau TB/U tanpa Z-score.
Kategori BB/TB dan IMT/U tersedia dalam daftar ringkas per pengukuran. Provider
dan asset kurva WHO pada mobile, `ZScoreCard`, formatter Z-score, serta skeleton
terkait telah dihapus karena tidak lagi digunakan layar lain. Perhitungan WHO
di backend dan kategori hasil pengukuran tidak berubah.

Grafik orang tua tidak lagi menggunakan Z-score sebagai nilai sumbu atau tooltip.

Gunakan grafik kronologis:

- berat badan dalam kilogram terhadap tanggal;
- tinggi badan dalam sentimeter terhadap tanggal;
- opsional lingkar kepala terhadap tanggal.

Pada setiap titik dapat ditampilkan:

```
29 Agustus 2026
Berat badan: 11,5 kg
Status BB/U: Berat badan normal
```

Jangan tampilkan:

```
Z-Score: -1.253
```

Untuk BB/TB dan IMT/U, tampilkan kategori per pengukuran dalam daftar ringkas apabila visualisasi nilai fisiknya belum sesuai.

Komponen `ZScoreCard`, formatter Z-score, dan skeleton terkait dapat dihapus apabila sudah tidak dipakai layar lain.

## Tahap 7 — Perbaiki UI status rujukan

**Status: selesai.** Tampilan rujukan orang tua telah diselaraskan dengan tiga
status yang didukung backend: `diajukan`, `ditangani`, dan `selesai`. Kartu
menampilkan tanggal pengajuan, alasan atau catatan kader, tindak lanjut
Puskesmas, petugas yang menangani, serta waktu mulai ditangani jika tersedia.
Skor SAW, kategori prioritas internal, dan status lama yang tidak didukung
kontrak API tidak ditampilkan.

Hapus baris:

```
Skor SAW 0.0000
```

Ganti dengan informasi yang relevan:

- status rujukan;
- alasan atau catatan kader;
- tindak lanjut Puskesmas;
- tanggal pengajuan;
- petugas yang menangani.

Prioritas internal tidak perlu ditampilkan karena keberadaan rujukan sendiri sudah menjelaskan bahwa anak memerlukan tindak lanjut.

## Tahap 8 — Pengujian backend

**Status: selesai.** Unit test serializer mencakup daftar field yang diizinkan,
pemetaan seluruh kategori prioritas menjadi `status_pemantauan`, serta
ketiadaan Z-score, skor, detail, bobot, dan kategori SAW dari kontrak orang
tua. Integration test menjalankan endpoint pengukuran dan rujukan orang tua
melalui Express. Regression test memastikan endpoint detail pengukuran dan
detail SAW untuk kader/Puskesmas tetap menyediakan data teknis.

Tambahkan unit test serializer orang tua:

- memastikan seluruh field yang diizinkan tersedia;
- memastikan `zscore_*` tidak tersedia;
- memastikan `skor_saw` tidak tersedia;
- memastikan detail dan bobot SAW tidak tersedia;
- memastikan kategori internal dipetakan ke `status_pemantauan`.

Tambahkan integration test endpoint:

```
GET /api/orang-tua/anak/:id/pengukuran
GET /api/orang-tua/anak/:id/rujukan
```

Assertion utama:

```
assert.equal("zscore_bbu" in item, false);
assert.equal("skor_saw" in item, false);
assert.equal("status_pemantauan" in item, true);
```

Tambahkan regression test bahwa endpoint teknis kader/Puskesmas tetap menerima data teknis yang dibutuhkan.

## Tahap 9 — Pengujian mobile

**Status: selesai.** Model test memverifikasi parsing kontrak pengukuran orang
tua dan seluruh nilai `status_pemantauan` tanpa ketergantungan pada field
teknis. Widget test mencakup detail pengukuran, riwayat pengukuran, grafik
pertumbuhan, status rujukan, dan detail anak. Seluruh layar diuji agar tidak
menampilkan Z-score atau skor SAW, sementara kategori antropometri dan status
pemantauan tetap tersedia pada layar yang relevan.

Tambahkan model test:

- parsing kontrak pengukuran orang tua;
- parsing `status_pemantauan`;
- model tidak bergantung pada Z-score atau skor SAW;
- respons tanpa field teknis tetap valid.

Tambahkan widget test untuk memastikan teks berikut tidak muncul:

```
Z-Score
Skor SAW
Skor Akhir
0.0000
```

Cakupan layar:

- detail pengukuran;
- riwayat pengukuran;
- grafik pertumbuhan;
- status rujukan;
- detail anak.

Pastikan status antropometri dan status pemantauan tetap tampil.

## Tahap 10 — Dokumentasi

Perbarui dokumentasi API dengan membedakan:

```
Kontrak orang tua
Kontrak teknis kader/Puskesmas
```

Jelaskan bahwa:

- Z-score dan SAW tetap dihitung server;
- nilai mentah tidak dikirim kepada orang tua;
- kategori yang tampil bukan diagnosis;
- SAW hanya membantu prioritas pemantauan.

Tambahkan aturan yang sama pada dokumentasi kebijakan UX dan keamanan data.

## Tahap 11 — Validasi akhir

Jalankan:

```
npm test
flutter test
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

Pengujian manual:

1. Buka riwayat pengukuran.
2. Pastikan tidak ada skor SAW.
3. Buka detail pengukuran.
4. Pastikan tidak ada angka Z-score atau SAW.
5. Periksa grafik pertumbuhan.
6. Pastikan tooltip hanya berisi satuan fisik dan kategori.
7. Buka status rujukan.
8. Pastikan tidak ada `0.0000` atau istilah SAW.
9. Periksa AI Insight dan chat tetap berjalan.
10. Unduh laporan orang tua dan pastikan tetap nonteknis.

## Kriteria selesai

- Endpoint orang tua tidak mengirim `zscore_*`.
- Endpoint orang tua tidak mengirim `skor_saw`.
- Detail pengukuran tidak menampilkan Z-score atau SAW.
- Riwayat tidak menampilkan skor SAW.
- Grafik tidak menampilkan angka Z-score.
- Status rujukan tidak menampilkan skor teknis.
- Status antropometri tetap tersedia.
- Status pemantauan menggunakan bahasa yang ramah orang tua.
- Conversational AI tetap berfungsi.
- Laporan orang tua tetap nonteknis.
- Endpoint kader/Puskesmas tidak mengalami regresi.
- Seluruh test backend dan mobile lulus.
- APK terbaru berhasil diuji dengan backend lokal.
