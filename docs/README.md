<div align="center">

<img src="../web-dashboard/src/assets/tumbuh.png" alt="Logo Tumbuh Posyandu" width="82" />

# Dokumentasi Tumbuh Posyandu

**Pusat panduan aktif, keputusan finalisasi, dan navigasi teknis project.**

![Documentation](https://img.shields.io/badge/Documentation-project%20guide-2563EB?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-Web%20%2B%20Mobile-7C3AED?style=flat-square)
![Integration](https://img.shields.io/badge/Integration-SAW%20%2B%20Gemini-0A8754?style=flat-square)

[Mulai](#mulai-dokumentasi) · [Dokumen inti](#dokumen-inti-aktif) · [Sumber kebenaran](#sumber-kebenaran) · [Pemeliharaan](#aturan-pemeliharaan)

</div>

Folder ini adalah indeks dokumentasi lintas komponen Tumbuh Posyandu, project digitalisasi ekosistem Posyandu berbasis Web dan Mobile yang terintegrasi dengan DSS SAW dan Conversational AI Gemini.

## 🏷️ Status dokumen

| Status | Arti |
|---|---|
| Aktif | Menjelaskan perilaku atau keputusan yang berlaku sekarang |
| Plan aktif | Checklist pekerjaan yang sedang dijalankan |
| Release record | Bukti, keputusan, atau risiko pada proses finalisasi |
| Historis | Analisis/rencana lama; bukan petunjuk implementasi saat ini |
| Direncanakan | Belum dibuat dan tidak boleh dianggap tersedia |

<a id="mulai-dokumentasi"></a>

## 🚀 Mulai dari sini

- [Root README](../README.md) — ringkasan project, quick start lokal, akun demo, quality gate, dan batasan.
- [Setup Lokal](./LOCAL_SETUP.md) — panduan menjalankan database, backend, Web, dan Android.
- [Arsitektur](./ARCHITECTURE.md) — komponen, trust boundary, data flow, dan worker.
- [Panduan Pengguna](./USER_GUIDE.md) — alur tiga role dan urutan demo proyek akhir.
- [Plan finalisasi README dan dokumentasi](./DOCUMENTATION_IMPLEMENTATION_PLAN.md) — sumber utama pekerjaan dokumentasi saat ini.
- [Security dan privacy](./SECURITY_AND_PRIVACY.md) — batas penggunaan lokal, data, autentikasi, AI, secret, serta privacy notice.
- [Dokumentasi teknis backend](../backend-express/docs/README.md) — indeks API, kontrak data, dan kebijakan backend.

## 📌 Dokumen aktif di root

| Dokumen | Status | Fungsi |
|---|---|---|
| [DOCUMENTATION_IMPLEMENTATION_PLAN.md](./DOCUMENTATION_IMPLEMENTATION_PLAN.md) | Plan aktif | Tahapan pembaruan README, dokumen inti, arsip, dan verifikasi |
| [SECURITY_AND_PRIVACY.md](./SECURITY_AND_PRIVACY.md) | Aktif | Sumber utama security, privacy, autentikasi, dan perlindungan data |
| [FINALIZATION_IMPLEMENTATION_PLAN.md](./FINALIZATION_IMPLEMENTATION_PLAN.md) | Release record | Rencana finalisasi lengkap awal; bukan panduan setup harian |

## 🧾 Release records

[Indeks release records](./release/README.md) memisahkan governance, known issues, risk acceptance, dan evidence bertanggal dari panduan aktif. Gunakan indeks tersebut untuk final review; jangan memakai release record sebagai pengganti setup atau user guide.

## 📚 Dokumen inti aktif

| Dokumen | Fungsi |
|---|---|
| [LOCAL_SETUP.md](./LOCAL_SETUP.md) | Instalasi database dan cara menjalankan seluruh aplikasi |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Komponen, aliran data, integrasi, worker, dan batas arsitektur |
| [CONFIGURATION.md](./CONFIGURATION.md) | Environment backend, Web, mobile, dan profil deployment |
| [DATABASE.md](./DATABASE.md) | Schema, tabel, relasi, seeder, constraint, dan script migrasi terbatas |
| [TESTING.md](./TESTING.md) | Automated gate, manual smoke, evidence, dan gap pengujian |
| [USER_GUIDE.md](./USER_GUIDE.md) | Alur kader, puskesmas, orang tua, dan urutan demo |
| [SECURITY_AND_PRIVACY.md](./SECURITY_AND_PRIVACY.md) | Model akses, data, session, secret, AI, retensi, dan gate perluasan scope |

## 🎯 Sumber kebenaran

| Topik | Sumber saat ini | Target akhir |
|---|---|---|
| Gambaran dan quick start | Root README + `LOCAL_SETUP.md` | Tetap |
| Command backend/web/WHO | README komponen; manifest sebagai bukti teknis | Tetap |
| Command mobile | `tumbuhapp/README.md`; config dan Flutter tooling sebagai bukti teknis | Tetap |
| Environment | `CONFIGURATION.md`; source teknis di file example | Tetap |
| Database | `DATABASE.md`; source teknis di schema/setup scripts | Tetap |
| API/kontrak role | `backend-express/docs/` | Tetap di backend docs |
| Security/privacy | `SECURITY_AND_PRIVACY.md` dan source/test | Tetap di `SECURITY_AND_PRIVACY.md` |
| Status quality gate | `TESTING.md` yang menautkan evidence Workstream B/C | Tetap |
| Issue/risiko finalisasi | `docs/release/` | Tetap sebagai release records |

Jika isi dokumentasi bertentangan dengan source/config/test aktual, source/config/test menjadi bukti teknis dan dokumentasi harus diperbarui.

## 🧩 Dokumentasi komponen

| Komponen | README | Dokumentasi tambahan |
|---|---|---|
| Backend Express | [README backend](../backend-express/README.md) | [Indeks backend docs](../backend-express/docs/README.md) |
| Web dashboard | [README dashboard](../web-dashboard/README.md) | Detail lintas komponen berada di root docs |
| Android Flutter | [README aplikasi](../tumbuhapp/README.md) | Detail lintas komponen berada di root docs |
| WHO converter | [README converter](../who-converter/README.md) | Risk/evidence berada di `docs/release/` |

README bawaan Xcode pada `tumbuhapp/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` adalah aset platform, bukan dokumentasi project aktif. File tersebut dipertahankan untuk roadmap iOS dan tidak dimasukkan ke navigasi pengguna.

## 🧹 Aturan pemeliharaan

- README harus ringkas dan menautkan detail, bukan menyalinnya.
- Jangan memasukkan secret, `.env` aktual, database, backup, laporan, atau identitas nyata.
- Angka test harus disertai tanggal/evidence atau ditulis tanpa klaim yang cepat usang.
- Dokumen historis harus memiliki label yang jelas dan tidak dipakai sebagai panduan saat ini.
- File tidak dipindahkan/dihapus sebelum inbound link diperiksa.
- Perubahan perilaku aplikasi tidak dilakukan sebagai bagian perapian dokumentasi.

---

<div align="center">
  <sub>Kembali ke <a href="../README.md">README utama Tumbuh Posyandu</a></sub>
</div>
