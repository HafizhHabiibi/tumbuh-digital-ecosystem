# API Download Laporan Pertumbuhan

Dokumen ini menjelaskan endpoint backend untuk mengunduh laporan pertumbuhan
dalam format PDF. Sistem menggunakan ruang lingkup satu Posyandu, satu
Puskesmas, dan banyak akun orang tua.

## Konfigurasi fasilitas

Isi identitas fasilitas pada environment backend:

```env
NAMA_POSYANDU=Posyandu Melati
NAMA_PUSKESMAS=Puskesmas Kecamatan Sehat
```

Nilai tersebut digunakan pada header seluruh PDF. Jika tidak diisi, backend
menggunakan nama generik `Posyandu` dan `Puskesmas`.

## Matriks akses

| Jenis laporan | Orang tua | Kader | Puskesmas |
|---|---:|---:|---:|
| Individual sederhana | Anak sendiri | - | - |
| Individual teknis | Tidak | Semua anak | Semua anak |
| Rekap periode | Tidak | Ya | Ya |

Varian individual dipilih oleh backend berdasarkan role pada access token.
Parameter seperti `jenis=teknis` tidak dapat digunakan orang tua untuk meminta
versi teknis.

## Autentikasi

Semua endpoint membutuhkan access token:

```http
Authorization: Bearer <access_token>
```

Respons tanpa token atau dengan token tidak valid mengikuti mekanisme
autentikasi backend (`401`).

## Download laporan individual

```http
GET /api/laporan/anak/:anak_id
```

`anak_id` wajib berupa UUID valid.

Contoh:

```bash
curl -L \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -o laporan-anak.pdf \
  "http://localhost:3000/api/laporan/anak/018f0000-0000-7000-8000-000000000001"
```

Perilaku berdasarkan role:

- Orang tua menerima ringkasan yang mudah dipahami tanpa Z-Score, skor SAW,
  bobot, atau ranking.
- Kader dan Puskesmas menerima laporan teknis berisi Z-Score, rincian SAW,
  riwayat pengukuran, dan rujukan.
- Orang tua yang meminta ID anak lain menerima `404`, sama seperti ID yang tidak
  tersedia. Kebijakan ini mencegah enumerasi ID anak.

## Download laporan rekap

```http
GET /api/laporan/rekap?tanggal_mulai=YYYY-MM-DD&tanggal_selesai=YYYY-MM-DD
```

Ketentuan periode:

- Kedua tanggal wajib tersedia dan valid.
- Tanggal selesai tidak boleh sebelum tanggal mulai.
- Tanggal tidak boleh berada di masa depan.
- Rentang maksimal 366 hari kalender secara inklusif.
- Endpoint hanya dapat digunakan kader dan Puskesmas.

Contoh:

```bash
curl -L \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -o laporan-rekap-agustus.pdf \
  "http://localhost:3000/api/laporan/rekap?tanggal_mulai=2026-08-01&tanggal_selesai=2026-08-27"
```

Rekap menggunakan pengukuran terakhir setiap anak di dalam periode untuk
distribusi antropometri dan daftar tindak lanjut. `total_pengukuran` tetap
menghitung seluruh kunjungan pada periode tersebut. Dengan demikian, anak yang
diukur beberapa kali tidak mendominasi distribusi.

Daftar tindak lanjut hanya memuat prioritas sedang dan tinggi. Prioritas rendah
tetap dihitung dalam distribusi.

## Respons berhasil

Endpoint mengembalikan body biner PDF dengan header:

```http
Content-Type: application/pdf
Content-Disposition: attachment; filename="laporan-....pdf"
Content-Length: <ukuran byte>
Cache-Control: private, no-store
```

Contoh download dari frontend dengan `fetch`:

```js
const response = await fetch(url, {
  headers: { Authorization: `Bearer ${accessToken}` },
});

if (!response.ok) {
  const payload = await response.json();
  throw new Error(payload.message);
}

const blob = await response.blob();
const objectUrl = URL.createObjectURL(blob);
const link = document.createElement("a");
link.href = objectUrl;
link.download = "laporan-pertumbuhan.pdf";
link.click();
URL.revokeObjectURL(objectUrl);
```

## Respons error

| Status | Kondisi |
|---:|---|
| `400` | UUID, tanggal, atau rentang periode tidak valid |
| `401` | Token tidak tersedia, tidak valid, atau kedaluwarsa |
| `403` | Role tidak memiliki akses ke jenis laporan |
| `404` | Profil/laporan tidak ditemukan atau anak bukan milik orang tua |
| `422` | Anak terdaftar tetapi belum memiliki pengukuran |
| `500` | Kesalahan internal saat mengambil data atau membuat PDF |

Respons error tetap berupa JSON standar backend, bukan PDF.

## Arti hasil laporan

- Kategori antropometri dihitung dari Z-Score referensi pertumbuhan WHO dan
  ambang kategori Permenkes.
- SAW menggunakan BB/U, TB/U, BB/TB, dan IMT/U untuk mengurutkan prioritas
  pemantauan.
- SAW bukan metode diagnosis dan tidak menyatakan seorang anak mengalami
  stunting.
- PDF dibuat saat diminta dan tidak disimpan di database maupun filesystem
  backend.

## Keamanan dan privasi

- Access token diverifikasi sebelum endpoint dijalankan.
- Role dibaca dari akun aktif di database, bukan dipercaya dari request body.
- Kepemilikan anak diverifikasi melalui relasi `anak` dan akun `orang_tua`.
- Query memakai parameter SQL, bukan interpolasi input pengguna.
- Nama file disanitasi sebelum dimasukkan ke `Content-Disposition`.
- PDF menggunakan `private, no-store` untuk mencegah cache data anak.

## Preview dan validasi layout

Generate tiga PDF contoh tanpa database:

```bash
npm run report:preview
```

Secara default file dibuat di folder temporary sistem
`tumbuh-posyandu-laporan-preview`. Lokasi dan ukuran setiap file ditampilkan
pada terminal. Untuk menentukan folder sendiri:

```bash
npm run report:preview -- ./laporan-preview
```

Folder `laporan-preview/` sudah diabaikan Git.

Checklist pemeriksaan visual manual:

- Identitas fasilitas dan judul tidak bertumpuk.
- Seluruh kartu ringkasan terbaca dan tetap berada dalam margin A4.
- Header tabel muncul kembali setelah perpindahan halaman.
- Tidak ada baris tabel yang terpotong di batas bawah halaman.
- Footer dan nomor halaman tampil pada seluruh halaman.
- Laporan orang tua tidak menampilkan Z-Score, skor, atau bobot SAW.
- Laporan teknis menampilkan empat indeks dan empat detail kriteria SAW.
- Rekap menampilkan tabel lanjutan secara konsisten pada beberapa halaman.

## Verifikasi otomatis

Jalankan seluruh unit test, renderer test, serta integrasi endpoint:

```bash
npm test
```
