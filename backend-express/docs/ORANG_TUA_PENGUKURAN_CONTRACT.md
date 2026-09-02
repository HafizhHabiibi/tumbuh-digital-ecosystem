# Kontrak Data Pengukuran Orang Tua

Dokumen ini adalah sumber kebenaran kontrak item `riwayat` pada endpoint:

```http
GET /api/orang-tua/anak/:id/pengukuran
```

Kontrak ini khusus untuk role `orang_tua`. Kontrak teknis kader dan Puskesmas
tidak berubah. Z-score dan SAW tetap dihitung di backend. Prioritas pemantauan
akhir mengambil tingkat tertinggi antara kategori SAW dan batas minimum
antropometri, tetapi nilai serta istilah teknisnya tidak dikirim kepada orang
tua.

## Pemisahan kontrak berdasarkan peran

| Pengguna | Endpoint utama | Kontrak |
| --- | --- | --- |
| Orang tua | `GET /api/orang-tua/anak/:id/pengukuran` | Nilai fisik, kategori antropometri, dan `status_pemantauan` |
| Kader/Puskesmas | `GET /api/pengukuran/anak/:anak_id` | Data pengukuran teknis untuk pemantauan profesional |
| Kader/Puskesmas | `GET /api/pengukuran/:id` | Detail pengukuran beserta Z-score dan hasil SAW |
| Kader/Puskesmas | `GET /api/pengukuran/:id/saw` | Skor, kategori internal, detail, dan bobot SAW |
| Puskesmas | `GET /api/puskesmas/anak/:id/pengukuran` | Riwayat teknis anak untuk tindak lanjut |

Pemisahan dilakukan oleh route, otorisasi role, dan serializer backend. Klien
orang tua tidak dapat meminta kontrak teknis melalui query parameter atau
sekadar menyembunyikan field di UI.

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

Serializer aplikasi wajib membangun objek baru hanya dari field berikut. Spread
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
| `status_pemantauan` | string enum | tidak | hasil pemetaan prioritas pemantauan akhir |
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

Pemetaan dilakukan di backend dari `prioritas_pemantauan.kategori` setelah
perhitungan internal selesai. Kategori SAW murni tidak dipetakan langsung ke
kontrak orang tua.

| Kategori internal | `status_pemantauan` | Label UI orang tua |
| --- | --- | --- |
| `rendah` | `rutin` | Pemantauan rutin |
| `sedang` | `perlu_perhatian` | Perlu perhatian |
| `tinggi` | `konsultasi` | Disarankan konsultasi |

`status_pemantauan` adalah arahan pemantauan, bukan diagnosis atau persentase
risiko. Respons orang tua tidak boleh menyebut SAW sebagai sumber kategori.
Kategori antropometri juga merupakan hasil klasifikasi pertumbuhan berdasarkan
referensi yang digunakan backend, bukan diagnosis klinis. Penilaian dan tindak
lanjut profesional tetap dilakukan kader atau petugas Puskesmas.

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
prioritas_pemantauan
sumber_utama
kode_alasan_prioritas
detail_saw
bobot
nilai_normalisasi
peringkat
```

Strict whitelist berlaku juga untuk field teknis baru yang belum tercantum.
Penambahan field pada kontrak orang tua harus melalui review kontrak dan test
regresi kebocoran data.

## Aturan kompatibilitas dan perubahan kontrak

1. endpoint kader dan Puskesmas tetap memakai kontrak teknisnya;
2. perubahan whitelist orang tua harus disertai model test, integration test,
   dan review kebocoran data;
3. field teknis baru bersifat ditolak secara default untuk kontrak orang tua;
4. perubahan ini tidak memerlukan migrasi database; dan
5. perhitungan Z-score dan SAW tidak diubah; prioritas pemantauan akhir
   melengkapinya dengan batas minimum antropometri.

## Status implementasi

Kontrak ini telah diterapkan pada serializer dan endpoint aplikasi. Model serta
UI mobile tidak lagi bergantung pada field teknis. Aturan penyajian dan
perlindungan lintas fitur dijelaskan dalam
[Kebijakan UX dan Keamanan Data Teknis](./DATA_TEKNIS_UX_SECURITY_POLICY.md).
