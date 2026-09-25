# Rencana Perbaikan Rotasi API Key Gemini

> Status: fase 1 sampai 7 selesai; fase 8 sudah dijalankan dan menunggu pemulihan quota/provider serta verifikasi project di Google AI Studio  
> Ruang lingkup: integrasi Gemini untuk insight dan conversational chat  
> Tujuan: memperbaiki klasifikasi error, rotasi key, retry, cooldown, dan observability agar error generik tidak menyamarkan penyebab sebenarnya.

## 1. Latar Belakang

Backend telah membaca lima API key unik dan mekanisme round-robin dasar telah
berfungsi pada unit test. Namun, beberapa jenis kegagalan yang berbeda saat ini
dapat berakhir sebagai `GEMINI_KEYS_EXHAUSTED`, antara lain:

- HTTP `429` atau rate limit;
- HTTP `5xx` atau gangguan provider;
- timeout dan gangguan jaringan;
- respons Gemini tidak berisi teks;
- respons bukan JSON valid; dan
- respons tidak sesuai schema aplikasi.

Akibatnya, log tidak dapat membedakan key yang benar-benar terkena limit dari
gangguan provider atau kegagalan structured output. Respons invalid juga dapat
membuat key masuk cooldown walaupun credential dan quota key tersebut sehat.

Pola kejadian yang teramati:

```text
Beberapa request berhasil
        ↓
Satu request mencoba beberapa atau seluruh key
        ↓
Semua percobaan dianggap retryable
        ↓
Semua key masuk cooldown
        ↓
GEMINI_KEYS_EXHAUSTED
        ↓
Request berikutnya gagal cepat karena tidak ada key available
```

## 2. Target Perilaku

| Kondisi | Tindakan yang diharapkan |
| --- | --- |
| Key mendapat `429` | Cooldown key tersebut dan lanjut ke key available berikutnya |
| Key mendapat credential error yang terverifikasi | Nonaktifkan key dan lanjut ke key berikutnya |
| Gemini mendapat `500/502/503/504` | Retry dengan backoff tanpa membuat seluruh key cooldown |
| Timeout atau network error | Retry terbatas tanpa mengklaim quota habis |
| Output kosong, JSON invalid, atau schema invalid | Retry generasi terbatas tanpa mengubah state key |
| Request/configuration error `400` | Hentikan request tanpa merotasi seluruh key |
| Semua key benar-benar mendapat `429` | Kembalikan error khusus rate limit beserta waktu retry |

Contoh fallback yang wajib bekerja:

```text
key 1 → 429 → cooldown
key 2 → berhasil → kembalikan jawaban
```

## 3. Fase Implementasi

### 3.1 Observability per Percobaan Provider

- [x] Tambahkan event log untuk setiap percobaan Gemini yang gagal.
- [x] Sertakan `request_id` agar seluruh attempt dapat dikorelasikan dengan chat.
- [x] Catat index atau fingerprint key, bukan API key asli.
- [x] Catat HTTP status, provider status/reason, klasifikasi, nomor attempt, dan retry delay.
- [x] Catat kategori output invalid tanpa menyimpan isi prompt atau respons lengkap.
- [x] Pastikan log tidak memuat data anak, pengguna, credential, atau isi percakapan.

Contoh event aman:

```json
{
  "event": "gemini_attempt_failed",
  "request_id": "request-uuid",
  "key_index": 2,
  "key_fingerprint": "a81f25c9",
  "attempt": 1,
  "http_status": 429,
  "provider_status": "RESOURCE_EXHAUSTED",
  "classification": "rate_limit",
  "retry_after_ms": 60000
}
```

Kriteria penerimaan:

- Satu kegagalan chat cukup untuk membedakan `429`, `503`, timeout, network
  error, output kosong, JSON invalid, dan schema invalid.
- Tidak ada API key atau isi percakapan pada log.

### 3.2 Pemisahan Error HTTP dan Structured Output

- [x] Pisahkan pemanggilan HTTP dari ekstraksi dan validasi respons.
- [x] Jangan menangkap kegagalan parsing dalam blok penanganan error HTTP/key.
- [x] Bedakan output kosong, JSON invalid, dan schema invalid.
- [x] Pastikan kegagalan output tidak mengubah `cooldownUntil` atau `disabled`.

Alur yang ditargetkan:

```text
Panggil Gemini
├─ HTTP gagal
│  └─ klasifikasikan transport/provider error
└─ HTTP berhasil
   ├─ tidak ada text → GEMINI_EMPTY_RESPONSE
   ├─ JSON invalid → GEMINI_INVALID_JSON
   ├─ schema invalid → GEMINI_INVALID_SCHEMA
   └─ valid → selesai
```

Kriteria penerimaan:

- Respons invalid tidak mengurangi jumlah key available.
- Penyebab kegagalan output tetap dapat dilihat di log internal.

### 3.3 Perbaikan State Machine Key

State key yang digunakan:

```text
available
cooldown
disabled
```

- [x] Hanya `429` yang menempatkan key ke cooldown.
- [x] Credential invalid yang terverifikasi menonaktifkan key.
- [x] Error `5xx`, timeout, network, dan invalid output tidak mengubah state key.
- [x] Key cooldown otomatis tersedia kembali setelah waktunya habis.
- [x] Simpan alasan state terakhir untuk observability internal.
- [x] Hitung waktu terdekat ketika sebuah key kembali available.

Kriteria penerimaan:

- Satu key yang terkena limit tidak menggagalkan chat selama masih ada key sehat.
- Gangguan provider global tidak membuat seluruh pool terlihat kehabisan key.

### 3.4 Strategi Retry dan Batas Attempt

Konfigurasi yang diusulkan:

```env
GEMINI_MAX_TOTAL_ATTEMPTS=6
GEMINI_MAX_TRANSIENT_RETRIES=2
GEMINI_INVALID_RESPONSE_RETRIES=1
GEMINI_KEY_COOLDOWN_MS=60000
GEMINI_MAX_BACKOFF_MS=4000
```

- [x] Untuk `429`, lanjut ke key berikutnya tanpa mencoba ulang key yang sama.
- [x] Untuk `5xx`, lakukan retry terbatas dengan exponential backoff dan jitter.
- [x] Untuk timeout/network, lakukan retry terbatas tanpa menandai quota habis.
- [x] Untuk output invalid, retry generasi maksimal satu kali tanpa cooldown key.
- [x] Untuk `400`, hentikan request karena pergantian key umumnya tidak membantu.
- [x] Terapkan batas attempt total per pesan.
- [x] Gunakan `Retry-After` atau retry delay provider jika tersedia.
- [x] Gunakan fallback cooldown hanya jika provider tidak memberikan retry delay.

Contoh backoff:

```text
1000 ms + jitter
2000 ms + jitter
4000 ms + jitter
```

Kriteria penerimaan:

- Satu pesan tidak dapat memicu panggilan provider tanpa batas.
- Jumlah panggilan aktual dapat diketahui melalui test dan log.

### 3.5 Kode Error yang Spesifik

- [x] Ganti error generik dengan kode internal yang sesuai penyebab.
- [x] Pertahankan pesan publik yang aman dan sederhana.
- [x] Sertakan `retry_after_ms` pada error yang memang dapat dicoba kembali.

Kode internal yang diusulkan:

```text
GEMINI_ALL_KEYS_RATE_LIMITED
GEMINI_NO_VALID_KEYS
GEMINI_PROVIDER_UNAVAILABLE
GEMINI_NETWORK_ERROR
GEMINI_TIMEOUT
GEMINI_EMPTY_RESPONSE
GEMINI_INVALID_JSON
GEMINI_INVALID_SCHEMA
GEMINI_ATTEMPT_LIMIT_REACHED
GEMINI_REQUEST_REJECTED
```

Contoh respons publik:

```json
{
  "success": false,
  "message": "Layanan edukasi AI sedang tidak tersedia, silakan coba kembali",
  "data": {
    "code": "AI_TEMPORARILY_UNAVAILABLE",
    "retry_after_ms": 60000
  }
}
```

### 3.6 Health Monitoring Pool

- [x] Perluas data internal `getHealth()` dengan jumlah key per state.
- [x] Tambahkan waktu sampai key berikutnya tersedia.
- [x] Jangan mengekspos key atau fingerprint melalui endpoint publik.
- [x] Pertahankan readiness publik dalam bentuk status sederhana.

Struktur internal yang ditargetkan:

```json
{
  "model": "gemini-3.6-flash",
  "totalKeys": 5,
  "availableKeys": 2,
  "cooldownKeys": 2,
  "disabledKeys": 1,
  "nextAvailableInMs": 28000
}
```

### 3.7 Pengujian

Tambahkan unit dan integration test berikut:

- [x] Key 1 mendapat `429`, key 2 berhasil.
- [x] Key 1 sampai 4 mendapat `429`, key 5 berhasil.
- [x] Semua key mendapat `429`.
- [x] Cooldown berakhir dan key kembali tersedia.
- [x] `Retry-After` provider digunakan.
- [x] `503` tidak membuat seluruh key cooldown.
- [x] Timeout tidak dilaporkan sebagai quota.
- [x] Network error tidak dilaporkan sebagai quota.
- [x] JSON invalid tidak membuat key cooldown.
- [x] Schema invalid tidak membuat key cooldown.
- [x] Output kosong tidak membuat key cooldown.
- [x] Credential invalid menonaktifkan key.
- [x] Error `400` tidak merotasi seluruh key.
- [x] Jumlah panggilan tidak melewati batas attempt total.
- [x] Log tidak mengandung API key atau prompt.
- [x] Fingerprint konsisten tetapi tidak mengungkap credential.
- [x] Controller menghasilkan HTTP dan respons publik yang tepat.
- [x] Readiness membedakan pool ready dan unavailable.

### 3.8 Validasi Provider Terkontrol

Tahap ini menggunakan quota provider nyata dan hanya dijalankan setelah unit
test lulus.

- [x] Jalankan seluruh quality gate lokal.
- [x] Jalankan satu smoke test dengan prompt sintetis.
- [x] Uji setiap key secara terisolasi, maksimal satu panggilan per key.
- [ ] Cocokkan setiap key dengan project ID di Google AI Studio.
- [ ] Periksa quota RPM, TPM, dan RPD setiap project.
- [ ] Verifikasi key pertama yang mendapat `429` dapat diambil alih key kedua.
- [x] Pantau log dan pastikan tidak ada data sensitif.

Hasil validasi terkontrol 24 September 2026:

- Quality gate lokal lulus `283/283` test.
- Lima key unik diuji secara terisolasi dengan tepat satu request sintetis per
  key dan retry dinonaktifkan.
- Seluruh key mengembalikan HTTP `429`, provider status
  `RESOURCE_EXHAUSTED`, dengan retry delay sekitar 49–51 detik.
- Rotasi tidak dapat menghasilkan respons sukses karena tidak ada key sehat
  pada saat validasi. Pemetaan project dan pemeriksaan quota harus dilakukan
  dari masing-masing akun melalui dashboard Google AI Studio.
- Output validator hanya mencatat index, fingerprint satu arah, kode error,
  status provider, retry delay, dan durasi; API key serta isi respons tidak
  dicetak.

### 3.9 Dokumentasi dan Runbook

- [ ] Dokumentasikan arti setiap kode error.
- [ ] Dokumentasikan cara memeriksa project untuk setiap key.
- [ ] Dokumentasikan perilaku cooldown dan waktu reset.
- [ ] Tambahkan prosedur ketika seluruh key mendapat `429`.
- [ ] Tambahkan prosedur ketika provider mendapat `503`.
- [ ] Tambahkan prosedur rotasi atau penggantian credential.
- [ ] Jelaskan bahwa quota Gemini berlaku per project, bukan sekadar per key.

## 4. File yang Diperkirakan Berubah

Urutan implementasi yang disarankan:

1. `src/integrations/geminiClient.js`
2. `src/services/aiObservabilityService.js`
3. `src/services/geminiService.js`
4. `src/controllers/chatController.js`
5. `src/services/healthService.js`
6. `test/gemini-client.test.js`
7. Test controller, health, service, dan integration terkait
8. `.env.example`
9. `docs/CONVERSATIONAL_AI_API.md`

## 5. Urutan Pengerjaan

1. Tambahkan diagnostic logging aman terlebih dahulu.
2. Pisahkan error HTTP dan error structured output.
3. Perbaiki state machine key.
4. Terapkan batas attempt dan strategi retry baru.
5. Tambahkan kode error spesifik dan mapping controller.
6. Perluas health monitoring internal.
7. Lengkapi unit dan integration test.
8. Jalankan seluruh quality gate lokal.
9. Jalankan smoke test provider secara terkontrol.
10. Perbarui dokumentasi dan runbook.

## 6. Definition of Done

Perbaikan dinyatakan selesai apabila:

- [ ] Key pertama mendapat `429` dan key kedua sehat menghasilkan chat sukses.
- [ ] Output invalid tidak membuat key masuk cooldown.
- [ ] Gangguan `503` tidak menghabiskan seluruh pool key.
- [ ] Semua key yang benar-benar mendapat `429` menghasilkan error rate limit khusus.
- [ ] Error akhir menyertakan retry delay yang benar jika tersedia.
- [ ] Log menjelaskan setiap attempt tanpa membocorkan secret atau data pengguna.
- [ ] Jumlah attempt selalu memiliki batas yang dapat diuji.
- [ ] Health internal menunjukkan state pool secara akurat.
- [ ] Seluruh test lama dan baru lulus.
- [ ] Smoke test provider berhasil atau menghasilkan diagnosis spesifik.

## 7. Catatan Keamanan dan Operasional

- Jangan pernah mencetak API key utuh atau sebagian API key asli.
- Jangan mencetak prompt, riwayat chat, atau respons lengkap Gemini.
- Fingerprint key dibuat menggunakan hash satu arah dan dipotong untuk korelasi log.
- Pengujian provider harus menggunakan konteks sintetis.
- Smoke test provider menggunakan quota nyata dan harus dilakukan secara terbatas.
- Pool beberapa key bukan pengganti pengelolaan quota, billing, dan rate limiting
  aplikasi yang benar.
