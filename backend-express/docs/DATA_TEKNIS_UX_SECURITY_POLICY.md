# Kebijakan UX dan Keamanan Data Teknis

Dokumen ini mengatur penyajian serta distribusi data pengukuran, Z-score, dan
SAW berdasarkan peran pengguna. Aturan berlaku untuk API, aplikasi mobile,
laporan PDF, AI Insight, dan conversational AI.

## Prinsip berdasarkan peran

| Peran | Informasi yang ditampilkan | Tujuan |
| --- | --- | --- |
| Orang tua | Nilai fisik, kategori antropometri, status pemantauan, dan tindak lanjut | Memahami pertumbuhan dan langkah berikutnya dengan bahasa sederhana |
| Kader | Data pengukuran, Z-score, SAW, dan prioritas internal | Pencatatan serta pemantauan operasional |
| Puskesmas | Data teknis lengkap, riwayat, rujukan, dan detail SAW | Penilaian serta tindak lanjut profesional |

Z-score dan SAW tetap dihitung backend. Nilai teknis tersebut tidak dikirim
melalui endpoint orang tua, bukan hanya disembunyikan oleh aplikasi mobile.

## Kebijakan UX orang tua

- Tampilkan berat badan dalam kilogram, tinggi/lingkar dalam sentimeter, usia
  saat pengukuran, dan tanggal pengukuran.
- Tampilkan kategori BB/U, TB/U, BB/TB, dan IMT/U dengan label yang dapat
  dipahami orang tua.
- Tampilkan `status_pemantauan` sebagai `Pemantauan rutin`, `Perlu perhatian`,
  atau `Disarankan konsultasi`.
- Grafik memakai nilai fisik terhadap tanggal. Tooltip tidak memuat Z-score,
  skor SAW, bobot, normalisasi, atau peringkat.
- Rujukan menampilkan status, alasan/catatan kader, tindak lanjut Puskesmas,
  waktu pengajuan/penanganan, dan petugas yang menangani.
- Jangan menampilkan istilah `Z-Score`, `SAW`, `skor akhir`, angka default
  seperti `0.0000`, atau prioritas internal kepada orang tua.

Kategori antropometri dan status pemantauan bukan diagnosis. UI dan dokumen
orang tua tidak boleh menyimpulkan penyakit, memastikan stunting, atau
menggantikan konsultasi dengan tenaga kesehatan.

## Kebijakan keamanan data

1. Serializer orang tua menggunakan whitelist dan membangun objek respons baru.
   Spread objek database atau hasil perhitungan teknis dilarang.
2. Field baru tidak otomatis masuk kontrak orang tua. Penambahan field wajib
   melalui review kontrak, privasi, UX, dan test kebocoran data.
3. Backend memverifikasi access token, role, serta kepemilikan anak. Keputusan
   akses tidak dipercayakan kepada flag atau query parameter dari klien.
4. Endpoint teknis hanya tersedia bagi kader/Puskesmas sesuai kebutuhan tugas.
5. Data teknis tidak dicatat ke log orang tua dan tidak dimasukkan ke konteks
   AI orang tua. AI hanya menerima kategori hasil backend yang diperlukan.
6. Laporan orang tua tetap nonteknis. Laporan teknis dan rekap hanya tersedia
   bagi role yang berwenang serta dikirim dengan
   `Cache-Control: private, no-store`.

## Peran SAW

SAW menggabungkan empat indikator antropometri untuk membantu pengurutan
prioritas pemantauan. SAW bukan alat diagnosis dan bukan satu-satunya dasar
rujukan. Keputusan rujukan dapat dibuat berdasarkan penilaian kader atau tenaga
kesehatan walaupun kategori prioritas internal berbeda.

## Perlindungan regresi

Perubahan terkait data pengukuran wajib menjaga pengujian berikut:

- unit test whitelist serializer orang tua;
- integration test endpoint pengukuran dan rujukan orang tua;
- regression test bahwa endpoint kader/Puskesmas tetap menerima data teknis;
- model test bahwa mobile valid tanpa field teknis; dan
- widget test bahwa Z-score/SAW tidak muncul pada layar orang tua.

Kontrak endpoint terkait tersedia di:

- [Kontrak Data Pengukuran Orang Tua](./ORANG_TUA_PENGUKURAN_CONTRACT.md);
- [Kontrak Data Rujukan Orang Tua](./ORANG_TUA_RUJUKAN_CONTRACT.md); dan
- [API Download Laporan Pertumbuhan](./LAPORAN_API.md).
