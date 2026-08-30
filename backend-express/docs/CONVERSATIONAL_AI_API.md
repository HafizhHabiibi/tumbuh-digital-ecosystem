# API Conversational AI Posyandu

## Tujuan dan batas penggunaan

Fitur ini memberikan insight awal setelah pengukuran dan percakapan edukatif
lanjutan untuk orang tua. Respons AI bukan diagnosis dan tidak menggantikan
penilaian kader maupun tenaga kesehatan.

Chat hanya membahas hasil pengukuran terbaru, makanan dan pola makan, aktivitas
dan stimulasi, kebersihan dan sanitasi, serta pemantauan pertumbuhan rutin.
Pertanyaan tentang diagnosis, obat, dosis, terapi, atau keputusan klinis akan
ditolak dengan jawaban tetap dari backend.

## Konfigurasi

```env
GEMINI_API_KEYS=key_pertama,key_kedua
GEMINI_API_KEY=
GEMINI_MODEL=gemini-3.6-flash
GEMINI_TIMEOUT_MS=15000
GEMINI_MAX_RETRIES=2
GEMINI_KEY_COOLDOWN_MS=60000
GEMINI_MAX_BACKOFF_MS=4000

CHAT_RATE_LIMIT_WINDOW_MS=300000
CHAT_RATE_LIMIT_MAX=10
```

`GEMINI_API_KEYS` menerima beberapa key yang dipisahkan koma. Variabel
`GEMINI_API_KEY` tetap didukung untuk satu key. Nilai model dapat diganti tanpa
mengubah source code.

Konfigurasi numerik Gemini divalidasi ketika proses backend dimulai. Endpoint
`GET /api/health/ready` juga memeriksa database dan ketersediaan key tanpa
menampilkan nilai key. Readiness mengembalikan komponen berikut:

```json
{
  "database": "ready",
  "ai": "ready",
  "ai_model": "gemini-3.6-flash"
}
```

Nilai `ai` dapat berupa `ready`, `not_configured`, atau `unavailable`. Jalankan
smoke test provider dengan konteks sintetis tanpa data pengguna setelah
memasang atau merotasi key:

```bash
npm run ai:smoke
```

Untuk memverifikasi alur lengkap bearer auth, endpoint chat, database, Gemini,
persistence, dan retry idempotent menggunakan data sintetis, jalankan:

```bash
npm run ai:smoke:e2e
```

Smoke test E2E menghapus kembali exchange sintetis yang dibuatnya.

Rate limit default adalah 10 pengiriman pesan per orang tua dalam 5 menit.
Pembacaan riwayat tidak mengurangi kuota pengiriman pesan.

## Autentikasi dan kepemilikan

Kedua endpoint chat membutuhkan access token dengan role `orang_tua`:

```http
Authorization: Bearer <access_token>
```

Backend selalu memeriksa kepemilikan melalui relasi orang tua, anak, dan
pengukuran. Pengukuran milik orang tua lain dikembalikan sebagai tidak ditemukan
agar informasi kepemilikan tidak bocor.

## Mengambil percakapan

```http
GET /api/orang-tua/pengukuran/:id/chat?limit=50&before_id=120
```

Parameter query:

| Parameter | Wajib | Keterangan |
| --- | --- | --- |
| `limit` | Tidak | Jumlah pesan, default 50 dan maksimal 100 |
| `before_id` | Tidak | Cursor untuk mengambil pesan yang lebih lama |

Contoh respons:

```json
{
  "success": true,
  "message": "Percakapan berhasil diambil",
  "data": {
    "pengukuran_id": 12,
    "latest_pengukuran_id": 12,
    "is_active": true,
    "insight_status": "completed",
    "insight_teks": "**Kondisi Saat Ini**\n...",
    "messages": [
      {
        "id": 31,
        "client_message_id": "018f0000-0000-7000-8000-000000000001",
        "reply_to_message_id": null,
        "role": "orang_tua",
        "content": "Apa contoh sumber protein yang mudah?",
        "response_type": null,
        "created_at": "2026-08-27T08:00:00.000Z"
      },
      {
        "id": 32,
        "client_message_id": null,
        "reply_to_message_id": 31,
        "role": "assistant",
        "content": "Telur, ikan, tempe, dan tahu dapat divariasikan...",
        "response_type": "answered",
        "created_at": "2026-08-27T08:00:01.000Z"
      }
    ],
    "pagination": {
      "has_more": false,
      "next_before_id": null
    }
  }
}
```

`is_active: false` berarti pengukuran tersebut bukan pengukuran terbaru. Riwayat
dan insight awal tetap dapat ditampilkan, tetapi kolom input chat harus dibuat
read-only oleh frontend. Gunakan `latest_pengukuran_id` untuk membuka langsung
detail pengukuran terbaru dari banner mode riwayat.

Untuk memuat halaman sebelumnya, gunakan nilai `next_before_id` sebagai
`before_id`, lalu letakkan hasilnya sebelum pesan yang sudah tampil.

## Mengirim pesan

```http
POST /api/orang-tua/pengukuran/:id/chat
Content-Type: application/json
```

```json
{
  "client_message_id": "018f0000-0000-7000-8000-000000000001",
  "message": "Apa contoh sumber protein yang mudah?"
}
```

Ketentuan:

- `client_message_id` wajib berupa UUID yang dibuat frontend untuk setiap pesan;
- aplikasi mobile menggunakan UUIDv7 agar konsisten dengan ID domain dan dapat
  diurutkan berdasarkan waktu pembuatan;
- gunakan kembali UUID yang sama ketika melakukan retry request yang sama;
- jangan gunakan UUID yang sama untuk isi pesan berbeda;
- panjang pesan 2 sampai 1.000 karakter; dan
- pesan baru hanya dapat dikirim untuk pengukuran terbaru dengan insight awal
  yang sudah tersedia.
- pesan yang memuat email, NIK, nomor telepon, ID internal, atau penyebutan
  eksplisit nama/alamat pribadi ditolak sebelum disimpan atau dikirim ke
  Gemini.

Pesan baru mengembalikan HTTP `201`. Retry dengan UUID dan isi yang sama
mengembalikan pasangan pesan lama dengan HTTP `200` dan `idempotent: true`.

```json
{
  "success": true,
  "message": "Pesan berhasil dijawab",
  "data": {
    "user_message": {
      "id": 31,
      "client_message_id": "018f0000-0000-7000-8000-000000000001",
      "role": "orang_tua",
      "content": "Apa contoh sumber protein yang mudah?"
    },
    "assistant_message": {
      "id": 32,
      "role": "assistant",
      "content": "Telur, ikan, tempe, dan tahu dapat divariasikan...",
      "response_type": "answered"
    },
    "idempotent": false
  }
}
```

Nilai `response_type`:

| Nilai | Makna |
| --- | --- |
| `answered` | Pertanyaan dijawab dalam ruang lingkup edukasi |
| `out_of_scope` | Pertanyaan berada di luar konteks fitur |
| `medical_advice_refused` | Permintaan diagnosis atau tindakan medis ditolak |

## Status HTTP penting

| Status | Kondisi |
| --- | --- |
| `200` | Riwayat berhasil atau retry idempotent berhasil |
| `201` | Pesan baru berhasil dijawab dan disimpan |
| `400` | Parameter, UUID, atau pesan tidak valid |
| `401` | Token tidak ada atau tidak valid |
| `403` | Role bukan orang tua |
| `404` | Pengukuran tidak ditemukan, bukan miliknya, atau sudah tidak aktif untuk POST |
| `409` | Insight belum siap atau idempotency key bentrok |
| `429` | Batas pengiriman pesan terlampaui |
| `503` | Provider AI sementara tidak tersedia |

Penolakan data pribadi menggunakan HTTP `400` dengan kode yang aman untuk UI:

```json
{
  "success": false,
  "message": "Hapus nama, NIK, nomor telepon, email, alamat, atau ID pribadi dari pertanyaan",
  "data": { "code": "CHAT_PII_DETECTED" }
}
```

Request concurrent dengan `client_message_id` yang sama menerima HTTP `409`
dengan kode `CHAT_REQUEST_PROCESSING`. Setelah request pertama selesai, retry
dengan UUID dan isi yang sama mengembalikan exchange tersimpan. Kode
`CHAT_IDEMPOTENCY_CONFLICT` bersifat terminal dan tidak boleh dicoba ulang.

Untuk status `409` karena insight belum siap, frontend dapat tetap menggunakan
endpoint insight yang sudah ada dan mengaktifkan input chat setelah
`insight_status` menjadi `completed`.

## Alur frontend yang disarankan

1. Ambil hasil pengukuran dan insight awal.
2. Panggil endpoint `GET` chat.
3. Tampilkan insight awal sebelum daftar pesan.
4. Aktifkan input hanya ketika `is_active` bernilai `true` dan
   `insight_status` bernilai `completed`.
5. Buat satu UUID baru ketika pengguna menekan kirim.
6. Pertahankan UUID tersebut sampai request berhasil atau mendapat respons
   terminal.
7. Jika jaringan terputus, kirim ulang payload yang sama dengan UUID yang sama.
8. Perlakukan seluruh jawaban sebagai edukasi, bukan hasil diagnosis.

## Privasi dan observability

Konteks yang dikirim ke Gemini tidak memuat nama, NIK, alamat, kontak, ID anak,
ID orang tua, nilai Z-score mentah, atau skor SAW. Hanya kategori hasil backend,
data pengukuran yang diperlukan, insight awal, dan maksimal 10 pesan terakhir
dari pengukuran yang sama yang digunakan.

Pesan baru juga diperiksa sebelum persistence dan provider call. Pengguna perlu
menghapus data pribadi apabila menerima kode `CHAT_PII_DETECTED`.

Audit operasional dicetak sebagai log terstruktur berprefix `[AI_AUDIT]`. Log
tidak memuat isi pesan ataupun identitas pengguna. Metrik penggunaan disimpan
di memori proses dan akan kembali nol ketika server dimulai ulang. Tidak ada
endpoint teknis AI yang ditampilkan kepada kader, Puskesmas, atau orang tua.

## Database

Sistem menggunakan satu tabel `chat_messages` yang terhubung langsung dengan
`pengukuran`. Tidak ada tabel session terpisah karena satu pengukuran sudah
menjadi batas satu sesi percakapan. `reply_to_message_id` menghubungkan satu
balasan assistant dengan satu pesan orang tua.

Untuk database fresh, jalankan skema terbaru melalui proses setup database
proyek sehingga migration tambahan tidak diperlukan.

Untuk database lokal yang sudah aktif sebelum reservasi idempotensi ditambahkan,
jalankan migration eksplisit berikut satu kali:

```bash
npm run db:migrate:chat-reservation
```
