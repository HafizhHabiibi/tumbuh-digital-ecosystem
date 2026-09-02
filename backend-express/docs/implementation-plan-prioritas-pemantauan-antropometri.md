# Implementation Plan Prioritas Pemantauan Antropometri

## 1. Tujuan

Menyempurnakan prioritas pemantauan agar kondisi gizi berlebih dan obesitas
yang sudah dikenali oleh perhitungan LMS WHO tidak terlewat hanya karena skor
SAW saat ini berfokus pada penyimpangan Z-score negatif.

Perubahan ini bukan fitur diagnosis, bukan otomatisasi rujukan, dan bukan
penggantian metode SAW. Perubahan menambahkan lapisan aturan antropometri di
atas hasil WHO dan SAW untuk menentukan prioritas pemantauan akhir.

## 2. Kondisi Saat Ini

Alur yang berjalan:

```text
Data pengukuran
  -> LMS WHO dan Z-score
  -> kategori BB/U, TB/U, BB/TB, dan IMT/U
  -> normalisasi SAW: clamp(-z / 3, 0, 1)
  -> skor dan kategori prioritas SAW
```

Rumus SAW tersebut sesuai untuk memeringkat risiko kekurangan gizi: semakin
negatif Z-score, semakin besar skor perhatian. Namun, Z-score positif menjadi
`0`, sehingga `gizi_lebih` dan `obesitas` tidak menaikkan prioritas SAW meskipun
kategorinya sudah terdeteksi dengan benar oleh LMS WHO.

## 3. Keputusan Desain

Gunakan dua hasil yang memiliki tanggung jawab berbeda:

1. **Prioritas SAW** tetap merupakan hasil asli perhitungan berbobot untuk
   risiko kekurangan gizi dan ranking sekunder.
2. **Prioritas pemantauan** merupakan hasil akhir setelah menerapkan batas
   minimum dari kategori antropometri.

```text
prioritas_pemantauan = maksimum(
  prioritas_saw,
  prioritas_minimum_antropometri
)
```

Urutan tingkat prioritas:

```text
rendah < sedang < tinggi
```

Prinsip implementasi:

- rumus LMS WHO, tabel WHO, dan ambang kategori tidak diubah;
- rumus, bobot, serta ambang SAW tidak diubah;
- kategori antropometri tidak ditentukan ulang di luar `zscoreService`;
- aturan antropometri hanya dapat menaikkan, tidak menurunkan, hasil SAW;
- status pemantauan bukan diagnosis dan tidak membuat rujukan otomatis;
- setiap kenaikan prioritas mempunyai kode alasan yang dapat diaudit;
- data teknis tetap disembunyikan dari kontrak orang tua.

## 4. Matriks Aturan yang Diusulkan

Matriks berikut adalah rancangan awal. Sebelum rilis produksi, istilah tindak
lanjut dan tingkat minimumnya perlu dikonfirmasi bersama tenaga gizi/Puskesmas.

| Indeks | Kategori | Prioritas minimum | Keterangan |
| --- | --- | --- | --- |
| BB/U | `berat_badan_sangat_kurang` | tinggi | Perlu perhatian segera |
| BB/U | `berat_badan_kurang` | sedang | Perlu perhatian |
| BB/U | `berat_badan_normal` | tidak menaikkan | Normal |
| BB/U | `risiko_berat_badan_lebih` | tidak menaikkan sendiri | Konfirmasi menggunakan BB/TB atau IMT/U |
| TB/U | `sangat_pendek` | tinggi | Perlu perhatian segera |
| TB/U | `pendek` | sedang | Perlu perhatian |
| TB/U | `normal` | tidak menaikkan | Normal |
| TB/U | `tinggi` | tidak menaikkan | Bukan indikator obesitas |
| BB/TB atau IMT/U | `gizi_buruk` | tinggi | Perlu perhatian segera |
| BB/TB atau IMT/U | `gizi_kurang` | sedang | Perlu perhatian |
| BB/TB atau IMT/U | `gizi_baik` | tidak menaikkan | Normal |
| BB/TB atau IMT/U | `risiko_gizi_lebih` | sedang | Perlu perhatian dan pemantauan |
| BB/TB atau IMT/U | `gizi_lebih` | sedang | Perlu perhatian dan konsultasi sesuai penilaian petugas |
| BB/TB atau IMT/U | `obesitas` | tinggi | Perlu konsultasi/penilaian tenaga kesehatan |

Jika beberapa kategori aktif sekaligus, gunakan tingkat tertinggi dan simpan
semua alasan yang relevan. Contoh:

```text
SAW                         = rendah
IMT/U                       = obesitas
prioritas minimum WHO       = tinggi
prioritas pemantauan akhir  = tinggi
alasan                      = ["imtu_obesitas"]
```

## 5. Bentuk Data Internal

Jangan mengubah makna `skor_saw` atau memasangkan skor SAW rendah dengan label
SAW tinggi. Tambahkan hasil terpisah pada enrichment:

```json
{
  "skor_saw": 0,
  "kategori_prioritas": "rendah",
  "prioritas_pemantauan": {
    "kategori": "tinggi",
    "sumber_utama": "antropometri",
    "alasan": ["imtu_obesitas"]
  }
}
```

Ketentuan:

- `kategori_prioritas` tetap berarti kategori SAW untuk kompatibilitas endpoint
  teknis yang ada;
- `prioritas_pemantauan.kategori` menjadi sumber status akhir lintas fitur;
- `sumber_utama` menggunakan enum `saw`, `antropometri`, atau `gabungan`;
- `alasan` menggunakan kode stabil, bukan kalimat UI;
- label ramah pengguna dipetakan di serializer/mobile, bukan disimpan ke DB.

Tidak diperlukan migrasi database karena seluruh nilai dihitung saat request,
sama seperti Z-score dan SAW sekarang.

## 6. Tahapan Implementasi

### Tahap 1 — Validasi aturan dan pembekuan kontrak

1. Konfirmasi matriks pada bagian 4 bersama tenaga gizi/Puskesmas.
2. Tegaskan bahwa prioritas akhir adalah arahan pemantauan, bukan diagnosis atau
   keputusan rujukan otomatis.
3. Tetapkan enum kategori, sumber, serta kode alasan.
4. Putuskan label orang tua:
   - `rendah` -> `rutin` / Pemantauan rutin;
   - `sedang` -> `perlu_perhatian` / Perlu perhatian;
   - `tinggi` -> `konsultasi` / Disarankan konsultasi.
5. Dokumentasikan bahwa BB/U risiko berat badan lebih harus dikonfirmasi dengan
   BB/TB atau IMT/U dan tidak menaikkan prioritas sendirian.

**Kriteria selesai:** matriks dan kontrak disetujui; tidak ada kategori yang
ambigu.

**Status:** kontrak teknis dan matriks aturan telah dibekukan dalam
[`PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md`](./PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md).
Validasi tenaga gizi/Puskesmas tetap menjadi gerbang wajib sebelum aturan
diaktifkan pada rilis produksi.

### Tahap 2 — Unit layanan prioritas antropometri

1. Tambahkan layanan murni, misalnya
   `src/services/monitoringPriorityService.js`.
2. Implementasikan fungsi untuk:
   - memvalidasi empat kategori antropometri;
   - menentukan prioritas minimum dan kode alasan;
   - menggabungkan kategori SAW dengan prioritas minimum;
   - menentukan `sumber_utama` secara deterministik.
3. Jangan mengimpor database atau memanggil LMS kembali dari layanan ini.
4. Jangan mengubah `sawService.js`, kecuali komentar dokumentasi bila diperlukan.

**Kriteria selesai:** fungsi bersifat deterministik, tanpa efek samping, dan
SAW rendah + obesitas menghasilkan prioritas pemantauan tinggi.

**Status:** selesai. Layanan murni tersedia di
`src/services/monitoringPriorityService.js` beserta unit test. Integrasi ke
pengukuran dan konsumen lain tetap menjadi cakupan Tahap 3 dan seterusnya.

### Tahap 3 — Integrasi enrichment pengukuran

1. Panggil layanan baru setelah `hitungSemuaZScore()` dan `hitungSAW()` pada
   `pengukuranService`.
2. Tambahkan `prioritas_pemantauan` ke hasil
   `enrichPengukuranDenganPrioritas`.
3. Gunakan helper enrichment yang sama pada detail, riwayat, ranking, dan
   enrichment rujukan agar tidak ada implementasi aturan ganda.
4. Pastikan perhitungan pengukuran historis tetap deterministik; antrean
   operasional hanya menggunakan pengukuran terbaru per anak.

**Kriteria selesai:** semua jalur enrichment memberikan hasil akhir yang sama
untuk input pengukuran yang sama.

**Status:** selesai. Detail dan riwayat memakai helper enrichment pusat;
enrichment ranking memakai helper yang sama tanpa mengubah urutan ranking lama;
dan jalur rujukan yang sudah memakai helper otomatis memperoleh hasil prioritas
pemantauan. Pengalihan konsumen API serta urutan operasional mengikuti tahap
berikutnya.

### Tahap 4 — Ranking dan statistik dashboard

1. Ubah ranking operasional menjadi:
   - urutkan `prioritas_pemantauan.kategori` terlebih dahulu;
   - gunakan `skor_saw` sebagai pengurut kedua;
   - gunakan tanggal ukur dan ID sebagai tie-breaker deterministik.
2. Hitung `total_prioritas_tinggi` dan distribusi prioritas dari prioritas
   pemantauan akhir, bukan kategori SAW murni.
3. Endpoint detail SAW tetap menampilkan hasil SAW murni.
4. Bila UI teknis perlu membedakan keduanya, tampilkan label
   “Prioritas pemantauan” dan “Skor SAW kekurangan gizi” secara eksplisit.

**Kriteria selesai:** anak obesitas muncul pada kelompok prioritas tinggi tanpa
memalsukan nilai atau kategori SAW.

**Status:** selesai pada backend. Ranking memakai prioritas pemantauan akhir,
skor SAW, tanggal ukur, lalu ID anak secara deterministik. Statistik dan
distribusi prioritas memakai pengukuran terbaru serta kategori pemantauan akhir.
Endpoint detail SAW tetap mengembalikan hasil SAW murni. Audit label UI teknis
dilanjutkan bersama tahapan konsumen antarmuka.

### Tahap 5 — Kontrak API orang tua dan mobile

1. Ubah serializer orang tua agar `status_pemantauan` berasal dari
   `prioritas_pemantauan.kategori`, bukan langsung dari `kategori_prioritas`.
2. Pertahankan whitelist: Z-score, skor SAW, detail bobot, dan kode teknis tidak
   dikirim ke orang tua.
3. Untuk perubahan minimum, pertahankan bentuk API `status_pemantauan` yang ada.
4. Jika alasan perlu ditampilkan, tambahkan field ramah pengguna secara terpisah
   hanya setelah kontrak disetujui, misalnya `alasan_pemantauan`; jangan
   mengekspos kode internal mentah.
5. Mobile tidak memerlukan menu atau halaman obesitas baru; cukup memakai status
   dan kategori antropometri yang sudah tersedia.

**Kriteria selesai:** UI orang tua dapat menunjukkan arahan yang benar tanpa
membocorkan SAW atau menyatakan diagnosis.

**Status:** selesai. Serializer menggunakan kategori prioritas pemantauan akhir
dan tetap menghasilkan enum `status_pemantauan` yang sama. Objek internal,
sumber, alasan, Z-score, dan SAW tidak masuk kontrak orang tua. Model serta UI
mobile tidak berubah karena bentuk kontrak publik tetap kompatibel.

### Tahap 6 — Rujukan, laporan, dan AI Insight

1. Rujukan tetap dibuat oleh kader; prioritas tinggi tidak boleh membuat row
   rujukan secara otomatis.
2. Endpoint rujukan teknis dapat menyertakan prioritas pemantauan sebagai
   informasi pendukung, sedangkan status lifecycle rujukan tidak berubah.
3. Laporan orang tua menggunakan prioritas pemantauan akhir.
4. Laporan teknis membedakan skor/kategori SAW dari prioritas pemantauan akhir.
5. AI Context menerima prioritas pemantauan akhir dan kategori antropometri;
   prompt tidak boleh menyebut obesitas sebagai hasil SAW.
6. Guardrail tetap melarang AI menghitung ulang Z-score, mengubah kategori, atau
   memberikan diagnosis.

**Kriteria selesai:** dashboard, laporan, rujukan, dan AI tidak memberi hasil
prioritas yang saling bertentangan.

**Status:** selesai. Notifikasi pengukuran menggunakan prioritas akhir;
rujukan teknis menyertakan prioritas akhir sebagai informasi tanpa otomatisasi;
laporan orang tua menggunakan prioritas akhir; laporan teknis memisahkan SAW
risiko kekurangan gizi dari prioritas pemantauan; serta konteks AI hanya memuat
kategori antropometri dan prioritas akhir tanpa Z-score, skor, sumber, atau kode
alasan internal.

### Tahap 7 — Pengujian otomatis

Tambahkan unit test matriks minimal untuk kasus berikut:

1. seluruh kategori normal + SAW rendah -> rendah;
2. kategori normal + SAW sedang/tinggi -> hasil SAW dipertahankan;
3. BB/U kurang -> minimal sedang;
4. TB/U sangat pendek -> tinggi;
5. BB/TB risiko gizi lebih -> minimal sedang;
6. IMT/U gizi lebih -> minimal sedang;
7. BB/TB atau IMT/U obesitas + SAW rendah -> tinggi;
8. BB/U risiko berat badan lebih tanpa temuan BB/TB/IMT/U -> tidak menaikkan;
9. TB/U tinggi -> tidak dianggap obesitas;
10. beberapa temuan -> tingkat tertinggi dan semua alasan tersimpan;
11. kategori tidak dikenal -> gagal secara eksplisit;
12. input tidak berubah setelah fungsi dijalankan.

Tambahkan test integrasi/regresi untuk:

- enrichment pengukuran dan rujukan;
- ranking anak dan tie-breaker;
- statistik/distribusi dashboard;
- serializer orang tua dan pencegahan kebocoran data teknis;
- laporan orang tua dan laporan teknis;
- konteks serta prompt AI;
- hasil SAW lama tetap identik untuk fixture yang sama.

**Kriteria selesai:** seluruh test backend lulus dan terdapat fixture obesitas
yang sebelumnya menghasilkan SAW rendah tetapi kini dipantau sebagai tinggi.

**Status:** selesai. Dua belas skenario matriks aturan tercakup oleh unit test;
enrichment detail/riwayat dan rujukan, ranking beserta tie-breaker, statistik dan
distribusi dashboard, serializer orang tua, laporan, serta konteks/prompt AI
memiliki test integrasi atau regresi. Fixture SAW dibekukan untuk memastikan
skor dan kategori lama tidak berubah, termasuk fixture obesitas dengan SAW
rendah yang menghasilkan prioritas pemantauan tinggi.

### Tahap 8 — Dokumentasi dan audit istilah

1. Perbarui `ORANG_TUA_PENGUKURAN_CONTRACT.md`.
2. Perbarui dokumentasi laporan dan kebijakan AI bila bentuk konteks berubah.
3. Audit teks “prioritas SAW” pada UI/API agar tidak dipakai untuk menyebut
   prioritas pemantauan akhir.
4. Dokumentasikan sumber aturan:
   - WHO/LMS untuk Z-score;
   - ambang kategori mengikuti kebijakan antropometri yang berlaku;
   - dua artikel SAW untuk kriteria dan bobot;
   - aturan pengaman antropometri untuk prioritas pemantauan.
5. Cantumkan kebutuhan validasi tenaga gizi dan batas penggunaan sistem.

**Kriteria selesai:** istilah di kode, API, laporan, AI, dan UI konsisten.

**Status:** selesai. Kontrak pengukuran dan rujukan orang tua, dokumentasi
laporan, serta kebijakan AI membedakan kategori antropometri, SAW risiko
kekurangan gizi, dan prioritas pemantauan akhir. Dashboard web kader/Puskesmas
memakai `prioritas_pemantauan.kategori` untuk badge, filter, ranking, detail,
dan rujukan; `kategori_prioritas` tetap hanya untuk tampilan SAW teknis.
Dokumentasi mencantumkan standar WHO/LMS, ambang antropometri yang berlaku,
referensi artikel untuk kriteria/bobot SAW, aturan pengaman antropometri,
batas penggunaan, dan gerbang validasi tenaga gizi sebelum produksi.

### Tahap 9 — Verifikasi rilis

1. Jalankan seluruh test backend.
2. Jalankan test mobile yang terdampak serializer/model.
3. Uji manual empat skenario: normal, kekurangan gizi, gizi lebih, dan obesitas.
4. Pastikan tidak ada rujukan otomatis yang tercipta.
5. Bandingkan statistik dashboard sebelum/sesudah menggunakan data fixture yang
   sama dan jelaskan perubahan jumlah prioritas.
6. Verifikasi laporan serta AI menyampaikan saran konsultasi tanpa diagnosis.
7. Siapkan rollback dengan menonaktifkan pemakaian prioritas akhir pada konsumen;
   perhitungan WHO dan SAW tidak perlu di-rollback karena tidak berubah.

**Kriteria selesai:** hasil konsisten pada backend dan mobile, tidak ada
kebocoran data teknis, dan perubahan statistik dapat dijelaskan oleh aturan
antropometri baru.

**Status:** verifikasi yang dapat diotomasi selesai. Suite rilis mencakup empat
fixture antropometri, kontrak orang tua, perbandingan distribusi sebelum/sesudah,
batas arsitektur tanpa pembuatan rujukan otomatis, laporan, AI, dan regresi SAW.
Checklist staging serta rencana rollback tersedia dalam
[`PRIORITAS_PEMANTAUAN_RELEASE_CHECKLIST.md`](./PRIORITAS_PEMANTAUAN_RELEASE_CHECKLIST.md).
Tahap 9 baru dinyatakan selesai sepenuhnya setelah checklist manual dan validasi
tenaga gizi/Puskesmas ditandatangani.

## 7. File yang Diperkirakan Terdampak

Backend utama:

- `src/services/monitoringPriorityService.js` (baru);
- `src/services/pengukuranService.js`;
- `src/serializers/orangTuaPengukuranSerializer.js`;
- `src/services/laporanService.js` dan renderer terkait;
- `src/services/aiContextService.js` serta prompt Gemini;
- controller rujukan/dashboard bila belum memakai enrichment terpusat.

Pengujian:

- unit test layanan prioritas baru;
- `orang-tua-data-contract.test.js`;
- `rujukan-enrichment.test.js`;
- test laporan, AI, dashboard, serta regresi risiko.

Mobile:

- kemungkinan tidak ada perubahan model jika hanya memakai
  `status_pemantauan` yang sudah ada;
- perubahan UI hanya diperlukan apabila `alasan_pemantauan` disetujui sebagai
  field kontrak baru.

## 8. Di Luar Cakupan

- mengubah atau mengunduh ulang tabel WHO;
- mengubah rumus LMS dan batas kategori antropometri;
- mengubah bobot atau normalisasi SAW;
- membuat algoritma SAW kedua untuk obesitas;
- membuat halaman khusus obesitas;
- membuat diagnosis otomatis;
- membuat rujukan otomatis;
- menyimpan hasil turunan ke database;
- memberikan rekomendasi obat, dosis, atau terapi melalui AI.

## 9. Risiko dan Mitigasi

| Risiko | Mitigasi |
| --- | --- |
| Skor SAW rendah tetapi label akhir tinggi dianggap inkonsisten | Pisahkan kategori SAW dan prioritas pemantauan pada kontrak teknis |
| Obesitas dianggap diagnosis oleh aplikasi | Gunakan bahasa “hasil kategori antropometri” dan “disarankan konsultasi” |
| BB/U risiko lebih memberi alarm palsu | Jangan menaikkan prioritas tanpa konfirmasi BB/TB atau IMT/U |
| Statistik dashboard berubah | Dokumentasikan bahwa statistik memakai prioritas pemantauan akhir |
| Aturan tersebar dan berbeda antarfitur | Gunakan satu layanan murni dan satu helper enrichment |
| Prioritas tinggi membuat rujukan otomatis | Pertahankan pemisahan eksplisit antara prioritas dan lifecycle rujukan |
| Aturan lokal belum tervalidasi | Jadikan validasi tenaga gizi sebagai gerbang sebelum rilis produksi |

## 10. Definition of Done

Pekerjaan dinyatakan selesai apabila:

1. LMS WHO dan hasil SAW lama tidak berubah;
2. obesitas pada BB/TB atau IMT/U menghasilkan prioritas pemantauan tinggi;
3. gizi lebih dan risiko gizi lebih tidak lagi hilang dari prioritas;
4. BB/U risiko berat badan lebih dikonfirmasi melalui BB/TB atau IMT/U;
5. dashboard, riwayat, laporan, rujukan, dan AI memakai sumber prioritas yang
   konsisten;
6. orang tua tidak menerima Z-score, skor SAW, atau kode alasan teknis;
7. tidak ada diagnosis maupun rujukan otomatis;
8. seluruh test otomatis lulus;
9. matriks aturan telah ditinjau tenaga gizi/Puskesmas; dan
10. dokumentasi kontrak serta batas penggunaan telah diperbarui.
