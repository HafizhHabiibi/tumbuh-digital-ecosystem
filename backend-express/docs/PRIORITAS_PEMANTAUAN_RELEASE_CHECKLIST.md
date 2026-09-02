# Checklist Rilis Prioritas Pemantauan Antropometri

Dokumen ini memisahkan verifikasi otomatis dan manual untuk Tahap 9. Seluruh
pengujian dengan data contoh wajib dilakukan di lingkungan pengembangan atau
staging, bukan dengan membuat data fiktif di produksi.

## Fixture acuan

Fixture menggunakan anak laki-laki, tanggal lahir `2024-08-26`, tanggal ukur
`2026-08-26`, dan tinggi badan `85 CM`.

| Skenario | Berat | BB/TB | SAW lama | Prioritas akhir | Status orang tua |
| --- | ---: | --- | --- | --- | --- |
| Normal | 11 KG | Gizi baik | rendah | rendah | Pemantauan rutin |
| Kekurangan gizi | 9 KG | Gizi buruk | tinggi | tinggi | Disarankan konsultasi |
| Gizi lebih | 14 KG | Gizi lebih | rendah | sedang | Perlu perhatian |
| Obesitas | 15 KG | Obesitas | rendah | tinggi | Disarankan konsultasi |

Fixture hanya mengunci perilaku perangkat lunak terhadap tabel referensi yang
tersedia di repositori. Fixture bukan contoh diagnosis atau pengganti penilaian
tenaga kesehatan.

## Verifikasi otomatis

1. Backend: jalankan `npm test` dari `backend-express`.
2. Mobile: jalankan `flutter test` dari `tumbuhapp`.
3. Dashboard web: jalankan `npm run check` dari `web-dashboard`.
4. Konsistensi empat skenario, kontrak orang tua, perubahan distribusi, dan
   batas tanpa rujukan otomatis dijaga oleh
   `test/monitoring-priority-release-verification.test.js`.
5. Kebocoran data teknis, laporan, AI, ranking, dan regresi SAW dijaga oleh
   suite backend terkait.
6. Jalankan `git diff --check` sebelum commit.

Perubahan distribusi untuk fixture yang sama dapat dijelaskan sebagai berikut:

```text
Kategori SAW lama       : rendah 3, sedang 0, tinggi 1
Prioritas pemantauan baru: rendah 1, sedang 1, tinggi 2
```

Anak dengan gizi lebih berpindah dari rendah ke sedang dan anak dengan
obesitas berpindah dari rendah ke tinggi. Anak normal dan kekurangan gizi tidak
berubah. Tidak ada skor atau kategori SAW yang dimodifikasi.

## Checklist manual staging

- [ ] Masukkan atau pilih data yang mewakili empat skenario dan cocokkan status
  pada detail pengukuran, riwayat, ranking, serta dashboard.
- [ ] Pastikan aplikasi orang tua menampilkan `Pemantauan rutin`,
  `Perlu perhatian`, atau `Disarankan konsultasi` tanpa Z-score dan skor SAW.
- [ ] Pastikan dashboard kader/Puskesmas memisahkan `Prioritas Pemantauan` dari
  `Skor SAW`.
- [ ] Catat jumlah rujukan sebelum pengukuran gizi lebih/obesitas, simpan
  pengukuran, lalu pastikan jumlah dan tabel rujukan tidak bertambah otomatis.
- [ ] Pastikan notifikasi pengukuran menyebut prioritas pemantauan akhir.
- [ ] Unduh laporan orang tua dan teknis. Pastikan laporan orang tua memakai
  bahasa sederhana, sedangkan laporan teknis memisahkan SAW dan prioritas akhir.
- [ ] Generate AI Insight dan lakukan chat pada kasus gizi lebih/obesitas.
  Pastikan AI menyarankan konsultasi secara aman, tidak mengklaim diagnosis,
  tidak menghitung ulang kategori, dan tidak memberi obat/dosis/terapi.
- [ ] Uji navigasi dan tampilan pada perangkat Android nyata, termasuk ukuran
  layar yang digunakan pengguna sasaran.
- [ ] Konfirmasi matriks kategori, tingkat prioritas, serta redaksi tindak lanjut
  bersama tenaga gizi/Puskesmas sebelum aktivasi produksi.
- [ ] Bangun ulang APK sesuai prosedur rilis proyek setelah checklist lulus.

## Rencana rollback

Rollback dilakukan dengan me-revert perubahan fitur prioritas pemantauan pada
commit rilis, bukan dengan mengubah tabel WHO, rumus LMS, data pengukuran, atau
rumus SAW. Tidak ada migrasi database yang perlu dibatalkan.

Jika rollback parsial benar-benar diperlukan, kembalikan konsumen berikut ke
kategori SAW murni secara serentak agar hasil lintas fitur tidak bertentangan:

1. serializer orang tua;
2. ranking, statistik, dan distribusi dashboard;
3. notifikasi pengukuran;
4. enrichment rujukan teknis;
5. laporan orang tua dan teknis;
6. konteks AI Insight/chat; dan
7. badge serta filter dashboard web.

Setelah rollback, jalankan kembali seluruh verifikasi otomatis dan empat
skenario manual. Revert parsial tidak boleh dirilis bila hanya sebagian
konsumen yang sudah dikembalikan.
