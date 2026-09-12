# Perbaikan High-Risk

> **Status dokumen: HISTORIS — perubahan utama telah diterapkan.** Dokumen ini adalah change report setelah baseline review Agustus 2026, bukan panduan setup atau status quality gate terkini. Gunakan [evidence terbaru](../../../../docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md).

Dokumen ini mencatat perubahan keamanan dan domain yang diterapkan setelah review 26 Agustus 2026.

## Perubahan kode

1. Endpoint generik `GET /api/pemberian/anak/:anak_id` sekarang hanya dapat dipakai kader dan puskesmas. Orang tua tetap memakai endpoint scoped `GET /api/orang-tua/anak/:id/pemberian` yang memeriksa kepemilikan anak.
2. `GET /api/pengukuran/:id/insight` sekarang memuat profil orang tua dan query insight melakukan join ke anak dengan syarat `orang_tua_id` yang login.
3. Middleware autentikasi memeriksa user aktif dan mengambil role terbaru dari database pada setiap request. Access token yang terbit sebelum perubahan password/user juga ditolak.
4. Refresh token dirotasi secara atomik. Token lama dicabut dan response refresh sekarang mengembalikan access token serta refresh token pengganti.
5. Reset password mencabut semua refresh token user.
6. Refresh token memiliki `jti` acak sehingga dua login pada detik yang sama tidak menghasilkan token identik.
7. Pengukuran menolak tanggal invalid, tanggal sebelum lahir, tanggal masa depan, input nonnumerik, usia di atas 60 bulan, dan tinggi/panjang di luar tabel referensi WHO.
8. Lookup WHO tidak lagi fallback ke Z-score `0` ketika data referensi tidak ditemukan.
9. Tren berat badan sekarang dinormalisasi ke kg/bulan berdasarkan interval hari antar pengukuran.
10. Perhitungan domain dilakukan sebelum insert pengukuran sehingga data yang ditolak tidak tersimpan sebagian.
11. Firebase service account tidak lagi dibaca dari file repository. Aplikasi memakai credential base64 dari environment atau Application Default Credentials.
12. Dependency utama diperbarui dan regression test berbasis `node:test` ditambahkan.

## Perubahan kontrak API

Client mobile harus mengganti refresh token lokal setiap kali memanggil `POST /api/auth/refresh`:

```json
{
  "data": {
    "token": "access-token-baru",
    "refresh_token": "refresh-token-baru"
  }
}
```

Refresh token lama menjadi tidak berlaku setelah response berhasil.

## Konfigurasi Firebase

Pilih salah satu metode berikut:

- Isi `FIREBASE_SERVICE_ACCOUNT_BASE64` dengan hasil base64 dari JSON service account yang disimpan di secret manager; atau
- Gunakan Application Default Credentials dan set `FIREBASE_USE_APPLICATION_DEFAULT=true`.

Jangan menyimpan JSON service account di repository.

## Tindakan manual wajib

Perubahan repository tidak dapat mencabut key yang sudah terbit atau menghapus salinan pada remote. Administrator harus:

1. Mencabut key Firebase/Google Cloud lama dan membuat credential baru.
2. Memeriksa audit log untuk penggunaan yang tidak sah.
3. Membersihkan `firebase-service-account.json` dari seluruh history Git dengan `git filter-repo` atau BFG.
4. Mengoordinasikan force-push dan meminta seluruh kontributor melakukan re-clone.

Jangan memakai kembali private key lama walaupun file sudah dihapus dari working tree.
