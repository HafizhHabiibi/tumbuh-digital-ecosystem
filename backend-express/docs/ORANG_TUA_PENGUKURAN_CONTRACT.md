# Kontrak Data Pengukuran Orang Tua

Dokumen ini adalah sumber kebenaran kontrak item `riwayat` pada endpoint:

```http
GET /api/orang-tua/anak/:id/pengukuran
```

Kontrak ini khusus untuk role `orang_tua`. Kontrak teknis kader dan Puskesmas
tidak berubah. Z-score dan SAW tetap dihitung di backend untuk menghasilkan
status antropometri dan prioritas pemantauan, tetapi nilai serta istilah
teknisnya tidak dikirim kepada orang tua.

## Bentuk response

Envelope endpoint tetap menggunakan format response API saat ini. Perubahan
hanya berlaku pada setiap item `data.riwayat`.

```json
{
  "success": true,
  "message": "Riwayat pengukuran berhasil diambil",
  "data": {
    "anak": {},
    "riwayat": [
      {
        "id": 12,
        "tanggal_ukur": "2026-08-29",
        "berat_badan": 11.5,
        "tinggi_badan": 84.2,
        "lingkar_kepala": 48.1,
        "lingkar_lengan": null,
        "usia_bulan": 34,
        "status_bbu": "berat_badan_normal",
        "status_tbu": "normal",
        "status_bbtb": "gizi_baik",
        "status_imtu": "gizi_baik",
        "status_pemantauan": "rutin",
        "created_at": "2026-08-29T08:00:00.000Z"
      }
    ]
  }
}
```

Objek `data.anak` tidak diubah dalam pekerjaan ini dan mengikuti kontrak yang
sudah berlaku.

## Whitelist field

Serializer Tahap 2 wajib membangun objek baru hanya dari field berikut. Spread
objek sumber seperti `...pengukuran` tidak diperbolehkan.

| Field | Tipe JSON | Nullable | Aturan |
| --- | --- | --- | --- |
| `id` | number integer | tidak | ID pengukuran positif |
| `tanggal_ukur` | string | tidak | tanggal kalender `YYYY-MM-DD` |
| `berat_badan` | number | tidak | kilogram, lebih besar dari 0 |
| `tinggi_badan` | number | tidak | sentimeter, lebih besar dari 0 |
| `lingkar_kepala` | number | ya | sentimeter atau `null` |
| `lingkar_lengan` | number | ya | sentimeter atau `null` |
| `usia_bulan` | number integer | tidak | usia saat pengukuran, minimal 0 |
| `status_bbu` | string enum | tidak | kategori berat badan menurut umur |
| `status_tbu` | string enum | tidak | kategori tinggi badan menurut umur |
| `status_bbtb` | string enum | tidak | kategori berat badan menurut tinggi badan |
| `status_imtu` | string enum | tidak | kategori IMT menurut umur |
| `status_pemantauan` | string enum | tidak | hasil pemetaan prioritas internal |
| `created_at` | string | tidak | timestamp ISO 8601 UTC |

Nilai desimal harus dikirim sebagai JSON number, bukan string hasil tipe
`DECIMAL` dari database.

## Enum status antropometri

### `status_bbu`

```text
berat_badan_sangat_kurang
berat_badan_kurang
berat_badan_normal
risiko_berat_badan_lebih
```

### `status_tbu`

```text
sangat_pendek
pendek
normal
tinggi
```

### `status_bbtb` dan `status_imtu`

```text
gizi_buruk
gizi_kurang
gizi_baik
risiko_gizi_lebih
gizi_lebih
obesitas
```

## Pemetaan status pemantauan

Pemetaan dilakukan di backend setelah perhitungan internal selesai.

| Kategori internal | `status_pemantauan` | Label UI orang tua |
| --- | --- | --- |
| `rendah` | `rutin` | Pemantauan rutin |
| `sedang` | `perlu_perhatian` | Perlu perhatian |
| `tinggi` | `konsultasi` | Disarankan konsultasi |

`status_pemantauan` adalah arahan pemantauan, bukan diagnosis atau persentase
risiko. Respons orang tua tidak boleh menyebut SAW sebagai sumber kategori.

## Field terlarang

Daftar berikut tidak boleh muncul pada level mana pun di dalam item riwayat
orang tua:

```text
usia_hari
nilai_imt
zscore_bbu
zscore_tbu
zscore_bbtb
zscore_imtu
skor_saw
kategori_prioritas
detail_saw
bobot
nilai_normalisasi
peringkat
```

Strict whitelist berlaku juga untuk field teknis baru yang belum tercantum.
Penambahan field pada kontrak orang tua harus melalui review kontrak dan test
regresi kebocoran data.

## Aturan kompatibilitas dan rilis

Penghapusan field teknis adalah breaking change bagi model mobile saat ini.
Karena itu:

1. perubahan backend dan mobile harus berada dalam satu rangkaian rilis;
2. backend dengan serializer baru tidak boleh dideploy sendiri sebelum model
   dan UI mobile tidak lagi bergantung pada field teknis;
3. endpoint kader dan Puskesmas harus tetap memakai kontrak teknisnya;
4. perubahan ini tidak memerlukan migrasi database; dan
5. perhitungan Z-score, SAW, AI Insight, serta laporan teknis tidak diubah.

## Batas Tahap 1

Tahap 1 hanya memfinalkan kontrak. Endpoint produksi belum disaring pada tahap
ini. Implementasi serializer dan perubahan response dilakukan pada Tahap 2.
