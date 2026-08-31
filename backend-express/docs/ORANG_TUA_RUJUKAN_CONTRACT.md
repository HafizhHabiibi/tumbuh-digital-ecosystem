# Kontrak Data Rujukan Orang Tua

Dokumen ini adalah sumber kebenaran kontrak setiap item `rujukan` pada
endpoint:

```http
GET /api/orang-tua/anak/:id/rujukan
```

Kontrak ini hanya berlaku untuk role `orang_tua`. Endpoint kader dan
Puskesmas tetap menggunakan kontrak teknis yang diperlukan untuk menjalankan
proses rujukan.

## Pemisahan kontrak berdasarkan peran

| Pengguna | Endpoint utama | Kontrak |
| --- | --- | --- |
| Orang tua | `GET /api/orang-tua/anak/:id/rujukan` | Status, catatan, tindak lanjut, waktu, dan petugas |
| Kader/Puskesmas | `GET /api/rujukan/anak/:anak_id` | Riwayat rujukan beserta data teknis pengukuran |
| Kader/Puskesmas | `GET /api/rujukan` dan `GET /api/rujukan/:id` | Daftar/detail operasional termasuk prioritas internal |
| Kader | `POST /api/rujukan` | Pengajuan berdasarkan penilaian kader |
| Puskesmas | `PUT /api/rujukan/:id/status` | Pembaruan penanganan dan catatan Puskesmas |

Serializer orang tua tidak digunakan endpoint teknis. Akses setiap endpoint
tetap dibatasi middleware autentikasi dan role backend.

## Bentuk response

Envelope endpoint tidak berubah. Strict whitelist diterapkan pada setiap item
`data.rujukan`.

```json
{
  "success": true,
  "message": "Riwayat rujukan berhasil diambil",
  "data": {
    "anak": {},
    "rujukan": [
      {
        "id": 4,
        "status": "ditangani",
        "catatan_kader": "Perlu pemeriksaan lebih lanjut.",
        "catatan_puskesmas": "Pemantauan gizi dijadwalkan kembali.",
        "created_at": "2026-08-29T08:00:00.000Z",
        "validated_at": "2026-08-30T03:30:00.000Z",
        "tanggal_ukur": "2026-08-29",
        "berat_badan": 11.5,
        "tinggi_badan": 84.2,
        "ditangani_oleh": "dr. Sinta"
      }
    ]
  }
}
```

Objek `data.anak` mengikuti kontrak profil anak yang
sudah berlaku.

## Whitelist field

| Field | Tipe JSON | Nullable | Aturan |
| --- | --- | --- | --- |
| `id` | number integer | tidak | ID rujukan positif |
| `status` | string enum | tidak | `diajukan`, `ditangani`, atau `selesai` |
| `catatan_kader` | string | ya | catatan yang menyertai pengajuan |
| `catatan_puskesmas` | string | ya | hasil atau tindak lanjut Puskesmas |
| `created_at` | string | tidak | timestamp pengajuan dalam ISO 8601 UTC |
| `validated_at` | string | ya | timestamp pertama kali ditangani atau `null` |
| `tanggal_ukur` | string | tidak | tanggal pengukuran terkait `YYYY-MM-DD` |
| `berat_badan` | number | tidak | kilogram, lebih besar dari 0 |
| `tinggi_badan` | number | tidak | sentimeter, lebih besar dari 0 |
| `ditangani_oleh` | string | ya | nama petugas Puskesmas atau `null` |

Nilai desimal dikirim sebagai JSON number. Field nullable tetap dikirim dengan
nilai `null` agar bentuk objek stabil di semua status rujukan.

## Field terlarang

Item rujukan orang tua tidak boleh memuat nilai atau rincian perhitungan
prioritas, termasuk:

```text
pengukuran_id
skor_saw
kategori_prioritas
usia_hari
zscore_bbu
zscore_tbu
zscore_bbtb
zscore_imtu
detail_saw
bobot
nilai_normalisasi
peringkat
```

Field internal baru juga tidak ikut terkirim secara otomatis. Penambahannya ke
kontrak orang tua harus melalui review kontrak dan test kebocoran data.

Keberadaan rujukan menjelaskan bahwa anak memerlukan tindak lanjut, tetapi
bukan diagnosis klinis. Skor SAW hanya dapat menjadi informasi prioritas bagi
petugas dan tidak menentukan kelayakan rujukan secara otomatis.

## Batas peran dan rilis

- Perhitungan Z-score dan SAW di backend tidak diubah.
- Endpoint teknis kader/Puskesmas tidak menggunakan serializer ini.
- Perubahan tidak memerlukan migrasi database.
- Model dan UI orang tua tidak bergantung pada skor atau kategori prioritas
  internal.
- Perubahan whitelist wajib dilindungi unit test dan integration test.

Kontrak ini telah diterapkan pada serializer dan endpoint aplikasi. Aturan
penyajian dan perlindungan lintas fitur dijelaskan dalam
[Kebijakan UX dan Keamanan Data Teknis](./DATA_TEKNIS_UX_SECURITY_POLICY.md).
