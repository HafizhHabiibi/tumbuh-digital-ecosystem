# Implementation Plan — Halaman Chat Khusus

## Gambaran Alur Utama

```text
Detail Pengukuran
        ↓
Kartu AI Insight
        ↓
“Tanya lebih lanjut”
        ↓
Halaman Conversational AI
```

Percakapan selalu terikat pada **satu pengukuran** agar konteks anak tidak tertukar antar-sesi.

---

## 1. Validasi Backend dan Gemini

Sebelum implementasi mobile dimulai, pastikan integrasi backend dengan Gemini sudah siap dan dapat diverifikasi.

### Checklist

- Pastikan API key terdeteksi tanpa pernah menampilkan nilainya.
- Jalankan **synthetic smoke test** ke Gemini.
- Verifikasi structured response dari `gemini-3.6-flash`.
- Tambahkan konfigurasi AI ke endpoint atau mekanisme **backend readiness**.
- Bedakan antara:
  - backend aktif;
  - layanan AI siap digunakan.

### Hasil yang Diharapkan

- `GET history` berfungsi.
- `POST` pesan yang valid menghasilkan jawaban dari Gemini.
- Gangguan provider AI dikembalikan sebagai HTTP `503`.

---

## 2. Hardening Privasi Pesan

Sebelum pesan disimpan ke database atau dikirim ke Gemini, lakukan validasi terhadap data pribadi.

### Data yang Perlu Dideteksi

- NIK;
- alamat email;
- nomor telepon;
- nama atau pola identitas sensitif lainnya.

### Perilaku Backend

Jika pesan mengandung data pribadi:

- Tolak request dengan HTTP `400`.
- Gunakan error code khusus, misalnya:

```text
CHAT_PII_DETECTED
```

- Pastikan pesan tidak masuk ke database.
- Pastikan pesan tidak diteruskan ke provider AI.

### Pesan pada Mobile

> Hapus nama, NIK, nomor telepon, atau informasi pribadi dari pertanyaan Anda.

### Pengujian

Tambahkan test untuk memastikan pesan yang mengandung PII:

- ditolak sebelum disimpan;
- tidak masuk database;
- tidak pernah dikirim ke Gemini.

---

## 3. Perbaikan State AI Insight pada Mobile

Perbarui `InsightModel` agar membaca field:

- `insight_status`;
- `insight_teks`;
- `insight_generated_at`.

### State UI

#### `pending` / `processing`

- Tampilkan status bahwa analisis sedang berlangsung.
- Jalankan polling secara terbatas.

#### `completed`

- Tampilkan insight.
- Aktifkan tombol **Tanya lebih lanjut**.

#### `failed`

- Tampilkan status gagal.
- Sediakan tombol refresh atau periksa kembali.

#### Network Error

- Tampilkan error jaringan secara eksplisit.
- Jangan menampilkan insight kosong seolah-olah proses berhasil.

### Strategi Polling

Contoh:

- interval: setiap `3 detik`;
- durasi maksimum: `1 menit`.

Jika batas polling tercapai, tampilkan tombol:

> Periksa kembali

---

## 4. Kontrak Chat pada Mobile

### Endpoint

```http
GET  /orang-tua/pengukuran/:id/chat
POST /orang-tua/pengukuran/:id/chat
```

### Model Baru

- `ChatConversation`
- `ChatMessage`
- `ChatPagination`
- `ChatExchange`
- `ChatResponseType`
- `ChatSendStatus`

### Struktur Fitur

```text
lib/features/chat/
├── data/
│   └── chat_service.dart
├── models/
│   └── chat_models.dart
├── providers/
│   └── chat_provider.dart
└── screens/
    └── conversational_ai_screen.dart
```

### Tambahan

- Tambahkan endpoint chat ke `ApiConstants`.
- Tambahkan dependensi `uuid` secara langsung.

---

## 5. State Management Percakapan

`ChatNotifier` bertanggung jawab atas:

- memuat conversation awal;
- memuat halaman history sebelumnya;
- menyimpan pesan yang sedang diketik;
- membuat optimistic bubble saat pesan dikirim;
- mengganti bubble pending dengan respons backend;
- menandai pesan gagal;
- retry menggunakan UUID yang sama;
- mencegah double tap;
- menentukan mode aktif atau read-only.

### Aturan Pengiriman

Dalam satu waktu hanya boleh ada **satu pesan aktif**.

Tujuannya adalah mencegah:

- request paralel yang tidak diperlukan;
- jawaban muncul dalam urutan yang membingungkan;
- request Gemini ganda.

---

## 6. Entry Point pada Detail Pengukuran

Setelah AI Insight tersedia, tampilkan tombol:

> Tanya lebih lanjut

### Kondisi Aktif

Tombol hanya aktif jika:

```text
insight_status == completed
```

### Navigasi

Ketika ditekan:

```text
/pengukuran/:pengukuranId/chat
```

### Jika Insight Belum Selesai

Tombol dinonaktifkan dan tampilkan keterangan:

> Percakapan tersedia setelah insight selesai.

---

## 7. Halaman Conversational AI

## 7.1 Header

Contoh:

```text
Tanya AI
Pengukuran 29 Agustus 2026
```

Header juga menampilkan badge status:

- `Aktif`
- `Riwayat`

---

## 7.2 Kartu Konteks

Di bagian atas halaman:

```text
Percakapan ini membahas hasil pengukuran
29 Agustus 2026.

[Lihat insight awal]
```

Insight awal dapat dibuka dan diciutkan agar tidak memenuhi layar.

---

## 7.3 Area Pesan

Fitur yang dibutuhkan:

- bubble orang tua di kanan;
- bubble assistant di kiri;
- waktu pesan;
- indikator pending;
- tombol retry pada pesan gagal;
- indikator khusus untuk respons:
  - di luar lingkup;
  - penolakan medis;
- tombol **Muat pesan sebelumnya** jika pagination masih tersedia.

---

## 7.4 Composer

Ketentuan input:

- maksimal `1.000 karakter`;
- tampilkan counter ketika mendekati batas;
- tersedia tombol kirim;
- double tap dinonaktifkan;
- keyboard ditutup setelah pengiriman berhasil.

### Disclosure

> Jawaban bersifat edukatif dan bukan diagnosis medis.

---

## 8. Mode Pengukuran Lama

`GET chat` tetap dilakukan agar history dapat dibaca.

Jika:

```text
is_active == false
```

maka halaman masuk ke mode read-only.

### UI

Tampilkan banner:

> Ini adalah percakapan dari pengukuran sebelumnya.

Input chat tidak ditampilkan.

Tampilkan tombol:

> Buka pengukuran terbaru

### Aturan Backend

Tidak ada `POST` chat untuk pengukuran lama.

---

## 9. Penanganan Error

| Kondisi | UX / Perilaku |
|---|---|
| `400` pesan invalid | Tampilkan validasi di dekat input |
| `400` data pribadi | Minta pengguna menghapus informasi identitas |
| `401` | Jalankan refresh token |
| `403/404` | Tampilkan bahwa percakapan tidak tersedia |
| `409` insight belum siap | Refresh status insight |
| `409` UUID konflik | Jangan membuat UUID baru; hentikan retry |
| `429` | Nonaktifkan input sementara |
| `503` | Tampilkan tombol retry |
| Timeout | Pertahankan bubble dan gunakan UUID yang sama |
| Offline | Tandai pesan sebagai belum terkirim |

### Timeout Chat

Endpoint chat menggunakan **receive timeout khusus** yang lebih panjang daripada timeout global `30 detik`.

---

## 10. Hardening Idempotensi Backend

Untuk mencegah retry memanggil Gemini lebih dari sekali, gunakan mekanisme reservasi request berdasarkan:

```text
client_message_id
```

### Perilaku yang Diharapkan

- Request pertama melakukan reservasi UUID.
- Hanya request pertama yang boleh memanggil Gemini.
- Request concurrent dengan UUID yang sama menerima status `processing`.
- Retry setelah request selesai mengembalikan exchange lama.
- Request gagal dapat dicoba ulang tanpa membuat pesan ganda.

Jika perubahan schema diperlukan, gunakan **migration eksplisit**.

---

## 11. Pengujian

## 11.1 Backend

Pastikan tersedia pengujian untuk:

- API key dan readiness;
- `POST` nyata dengan synthetic context;
- PII tidak disimpan atau dikirim;
- idempotensi concurrent;
- guardrail:
  - diagnosis;
  - dosis;
  - obat;
  - prompt injection;
- timeout;
- provider unavailable;
- pagination;
- ownership / authorization.

---

## 11.2 Mobile

Pastikan tersedia pengujian untuk:

- parsing conversation;
- status insight;
- polling insight;
- initial history;
- pagination;
- optimistic bubble;
- retry menggunakan UUID yang sama;
- pencegahan double tap;
- mode read-only;
- seluruh status HTTP;
- widget test halaman chat;
- widget test tombol entry;
- deep link langsung berdasarkan ID pengukuran.

---

## Kriteria Selesai

Implementasi dianggap selesai apabila:

- [ ] Tombol chat hanya aktif setelah insight selesai.
- [ ] Halaman chat dapat dibuka langsung menggunakan ID pengukuran.
- [ ] History tetap tersedia setelah halaman dibuka ulang.
- [ ] Pesan hasil retry tidak terduplikasi.
- [ ] Pengukuran lama hanya dapat dibaca.
- [ ] Data pribadi ditolak sebelum mencapai Gemini atau database.
- [ ] Seluruh error memiliki state UI yang jelas.
- [ ] Backend lulus seluruh test.
- [ ] Mobile lulus seluruh test.
- [ ] APK debug berhasil dibangun.
- [ ] APK debug berhasil diuji menggunakan backend lokal.

---

## Urutan Implementasi

Belum ada kode Conversational AI yang perlu diubah pada tahap awal.

Implementasi dilakukan dengan urutan berikut:

```text
1. Validasi Gemini dan konfigurasi backend
                ↓
2. Hardening privasi dan idempotensi backend
                ↓
3. Perbaikan kontrak dan state AI Insight
                ↓
4. Implementasi kontrak chat mobile
                ↓
5. Implementasi service dan state management chat
                ↓
6. Implementasi halaman Conversational AI
                ↓
7. Integrasi entry point dari Detail Pengukuran
                ↓
8. Pengujian backend dan mobile
                ↓
9. End-to-end testing dengan backend lokal
```

Fokus implementasi dimulai dari **validasi Gemini dan hardening backend**, kemudian dilanjutkan ke **kontrak insight, service/state chat, UI**, dan terakhir **pengujian end-to-end**.
