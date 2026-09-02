# Kontrak Prioritas Pemantauan Antropometri

## Status dokumen

Dokumen ini membekukan keputusan teknis Tahap 1 untuk penyempurnaan prioritas
pemantauan. Layanan murni Tahap 2 sudah tersedia, Tahap 3 sudah
menghubungkannya ke enrichment pengukuran, Tahap 4 sudah mengalihkan ranking
dan statistik, serta Tahap 5 sudah mengalihkan kontrak orang tua tanpa mengubah
bentuk respons publik. Tahap 6 sudah menyelaraskan notifikasi pengukuran,
rujukan teknis, laporan, dan AI tanpa membuat diagnosis atau rujukan otomatis.
Tahap 7 membekukan regresi SAW dan cakupan pengujian prioritas akhir. Tahap 8
menyelaraskan dokumentasi serta label dashboard web dengan makna kontrak ini.

Matriks aturan merupakan aturan pemantauan aplikasi, bukan diagnosis atau
protokol rujukan klinis. Peninjauan tenaga gizi/Puskesmas wajib dilakukan
sebelum aturan diaktifkan pada rilis produksi.

## Tujuan dan batas tanggung jawab

Sistem mempunyai tiga hasil yang tidak boleh dicampur:

1. **Kategori antropometri** berasal dari perhitungan LMS WHO dan ambang
   antropometri yang berlaku.
2. **Prioritas SAW** adalah pemeringkatan risiko kekurangan gizi berdasarkan
   empat Z-score dan bobot yang sudah ada.
3. **Prioritas pemantauan** adalah arahan operasional akhir setelah prioritas
   SAW dilengkapi batas minimum berdasarkan kategori antropometri.

Prioritas pemantauan:

- bukan diagnosis stunting, wasting, obesitas, atau penyakit;
- tidak membuat rujukan secara otomatis;
- tidak menggantikan penilaian kader atau tenaga kesehatan;
- hanya membantu menentukan urutan perhatian dan komunikasi tindak lanjut.

## Dasar acuan

- [Permenkes Nomor 2 Tahun 2020](https://jdih.kemkes.go.id/documents/peraturan-menteri-kesehatan-nomor-2-tahun-2020)
  menetapkan empat indeks antropometri dan penggunaannya untuk menilai status
  gizi serta tren pertumbuhan anak.
- [WHO Child Growth Standards](https://www.who.int/tools/child-growth-standards/standards)
  menjadi sumber resmi standar pertumbuhan; tabel LMS yang sudah tersedia di
  backend merupakan data referensi untuk perhitungan Z-score.
- Dua artikel SAW proyek tetap menjadi referensi pemilihan empat kriteria dan
  bobot, bukan sumber diagnosis atau aturan rujukan.
- Pemetaan kategori menjadi prioritas minimum di dokumen ini adalah keputusan
  desain aplikasi dan harus divalidasi tenaga gizi sebelum produksi.

## Istilah lintas fitur

| Istilah | Makna | Penggunaan |
| --- | --- | --- |
| Kategori antropometri | Kategori hasil Z-score berdasarkan standar pertumbuhan dan ambang yang berlaku | Backend, laporan, AI, dashboard, dan aplikasi orang tua |
| Skor/kategori SAW | Pemeringkatan teknis risiko kekurangan gizi | Backend, laporan teknis, dan dashboard petugas |
| Prioritas pemantauan | Tingkat akhir setelah kategori SAW dilengkapi batas minimum antropometri | Ranking, statistik, notifikasi, rujukan teknis, laporan, AI, dan status orang tua |

Label “Prioritas SAW” tidak digunakan untuk hasil akhir. Pada antarmuka teknis,
hasil SAW harus diberi label “Skor SAW risiko kekurangan gizi” atau istilah
setara dan ditampilkan terpisah dari “Prioritas Pemantauan”.

## Kontrak input

Layanan prioritas menerima hasil yang sudah dihitung oleh layanan Z-score dan
SAW. Layanan tidak boleh menghitung ulang Z-score atau kategori.

```json
{
  "kategori_prioritas_saw": "rendah",
  "status_bbu": "berat_badan_normal",
  "status_tbu": "normal",
  "status_bbtb": "gizi_baik",
  "status_imtu": "obesitas"
}
```

Enum `kategori_prioritas_saw`:

```text
rendah
sedang
tinggi
```

Enum empat status antropometri harus sama dengan hasil `zscoreService`. Nilai
yang tidak dikenal harus ditolak secara eksplisit dan tidak boleh diam-diam
dianggap normal.

## Tingkat dan aturan penggabungan

Urutan tingkat:

```text
rendah = 1
sedang = 2
tinggi = 3
```

Prioritas akhir menggunakan tingkat tertinggi:

```text
prioritas_pemantauan = max(prioritas_saw, prioritas_minimum_antropometri)
```

Aturan tidak boleh menurunkan hasil SAW. Jika tidak ada kategori yang menaikkan
prioritas, `prioritas_minimum_antropometri` bernilai `null`, bukan `rendah`.

## Matriks aturan yang dibekukan

### BB/U

| Status | Minimum | Kode alasan |
| --- | --- | --- |
| `berat_badan_sangat_kurang` | tinggi | `bbu_berat_badan_sangat_kurang` |
| `berat_badan_kurang` | sedang | `bbu_berat_badan_kurang` |
| `berat_badan_normal` | tidak menaikkan | - |
| `risiko_berat_badan_lebih` | tidak menaikkan sendiri | - |

`risiko_berat_badan_lebih` pada BB/U harus dikonfirmasi melalui BB/TB atau
IMT/U. Status tersebut tidak boleh sendirian dianggap obesitas.

### TB/U

| Status | Minimum | Kode alasan |
| --- | --- | --- |
| `sangat_pendek` | tinggi | `tbu_sangat_pendek` |
| `pendek` | sedang | `tbu_pendek` |
| `normal` | tidak menaikkan | - |
| `tinggi` | tidak menaikkan | - |

TB/U `tinggi` bukan indikator obesitas dan tidak boleh diproses sebagai risiko
gizi lebih.

### BB/TB

| Status | Minimum | Kode alasan |
| --- | --- | --- |
| `gizi_buruk` | tinggi | `bbtb_gizi_buruk` |
| `gizi_kurang` | sedang | `bbtb_gizi_kurang` |
| `gizi_baik` | tidak menaikkan | - |
| `risiko_gizi_lebih` | sedang | `bbtb_risiko_gizi_lebih` |
| `gizi_lebih` | sedang | `bbtb_gizi_lebih` |
| `obesitas` | tinggi | `bbtb_obesitas` |

### IMT/U

| Status | Minimum | Kode alasan |
| --- | --- | --- |
| `gizi_buruk` | tinggi | `imtu_gizi_buruk` |
| `gizi_kurang` | sedang | `imtu_gizi_kurang` |
| `gizi_baik` | tidak menaikkan | - |
| `risiko_gizi_lebih` | sedang | `imtu_risiko_gizi_lebih` |
| `gizi_lebih` | sedang | `imtu_gizi_lebih` |
| `obesitas` | tinggi | `imtu_obesitas` |

Semua alasan yang relevan dipertahankan dalam urutan indeks tetap:

```text
BB/U -> TB/U -> BB/TB -> IMT/U
```

Urutan tersebut membuat output dan pengujian deterministik.

## Penentuan sumber utama

Enum `sumber_utama`:

```text
saw
antropometri
gabungan
```

Aturannya:

1. `saw` jika tidak ada minimum antropometri atau tingkat SAW lebih tinggi;
2. `antropometri` jika minimum antropometri lebih tinggi daripada SAW;
3. `gabungan` jika minimum antropometri dan SAW sama-sama aktif pada tingkat
   akhir yang sama.

Sumber hanya menjelaskan asal tingkat akhir. Semua alasan antropometri tetap
disertakan walaupun tingkat SAW lebih tinggi.

## Kontrak output internal

```json
{
  "kategori": "tinggi",
  "sumber_utama": "antropometri",
  "alasan": ["imtu_obesitas"]
}
```

Ketentuan output:

- `kategori` wajib salah satu `rendah`, `sedang`, atau `tinggi`;
- `sumber_utama` wajib mengikuti enum di atas;
- `alasan` selalu array dan boleh kosong jika hasil hanya berasal dari SAW;
- kode alasan tidak boleh digunakan langsung sebagai teks UI;
- input tidak boleh dimutasi.

## Contoh keputusan

| SAW | Temuan antropometri | Akhir | Sumber |
| --- | --- | --- | --- |
| rendah | seluruhnya normal | rendah | saw |
| sedang | seluruhnya normal | sedang | saw |
| tinggi | seluruhnya normal | tinggi | saw |
| rendah | IMT/U obesitas | tinggi | antropometri |
| sedang | BB/TB gizi lebih | sedang | gabungan |
| tinggi | IMT/U risiko gizi lebih | tinggi | saw |
| rendah | BB/U risiko berat badan lebih, BB/TB dan IMT/U baik | rendah | saw |
| rendah | TB/U tinggi | rendah | saw |

## Kontrak untuk orang tua

Kontrak orang tua tetap menggunakan field yang sudah ada:

```text
status_pemantauan
```

Pemetaan:

| Prioritas akhir | Nilai API | Label UI |
| --- | --- | --- |
| rendah | `rutin` | Pemantauan rutin |
| sedang | `perlu_perhatian` | Perlu perhatian |
| tinggi | `konsultasi` | Disarankan konsultasi |

Orang tua tidak menerima:

- skor dan detail SAW;
- Z-score;
- `sumber_utama` mentah;
- kode alasan internal;
- klaim diagnosis atau rujukan otomatis.

Jika alasan pemantauan kelak ditambahkan ke API orang tua, alasan harus berupa
label yang ramah, ditinjau secara terpisah, dan masuk strict whitelist.

## Kontrak rujukan

Prioritas `tinggi` berarti perlu mendapat perhatian dalam antrean pemantauan.
Hasil tersebut tidak boleh:

- membuat data rujukan baru;
- mengubah status lifecycle rujukan;
- menyatakan anak pasti harus dirujuk;
- menggantikan pemeriksaan tenaga kesehatan.

Pengajuan rujukan tetap merupakan tindakan kader sesuai penilaian dan alur yang
sudah berlaku.

## Gerbang sebelum implementasi dan rilis

Tahap 2 dapat membangun layanan berdasarkan kontrak ini. Namun, aktivasi pada
rilis produksi mensyaratkan:

1. tenaga gizi/Puskesmas meninjau tingkat minimum pada setiap kategori;
2. istilah “disarankan konsultasi” disetujui untuk orang tua;
3. dipastikan tidak ada konsumen yang menganggap prioritas sebagai diagnosis;
4. test regresi membuktikan rumus serta hasil SAW lama tidak berubah; dan
5. fixture obesitas membuktikan SAW rendah dapat menghasilkan pemantauan tinggi.
