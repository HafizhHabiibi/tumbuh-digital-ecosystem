# Release Governance — Final Review

Status: **Feature freeze aktif; G0 selesai**  
Tanggal mulai freeze: **12 September 2026**  
Release branch: `release/final-review`  
Baseline commit: `9893d9178203a1619a6574edcf9bc9fd8d2240f3`

## 1. Tujuan

Dokumen ini menetapkan aturan perubahan selama finalisasi project akhir. Seluruh pekerjaan mengikuti `docs/FINALIZATION_IMPLEMENTATION_PLAN.md` dan tidak boleh memperluas fitur produk. Branch final review sengaja tidak memakai nomor versi; versioning/tag baru diputuskan bila project akan didistribusikan.

## 2. Scope release

### Disepakati dari baseline

- Backend Express dan database MySQL.
- Dashboard web untuk kader dan puskesmas.
- Aplikasi Flutter untuk orang tua.
- WHO converter sebagai tool verifikasi data antropometri.
- Kontrak fitur yang sudah ada: autentikasi, data orang tua/anak, pengukuran, pemberian, rujukan, jadwal, dashboard, prioritas, laporan, notifikasi, insight, dan chat AI.

### Keputusan final review

| Keputusan | Hasil | Status |
|---|---|---|
| Platform final project | Web + Android | Disetujui |
| iOS | Hanya persiapan struktur untuk masa depan; bukan scope final review saat ini | Disetujui |
| Target deployment | Lokal pada perangkat pengembang untuk tahap pertama | Disetujui |
| Database | Fresh database; dibuat dari schema dan seeder yang tervalidasi | Disetujui |
| Pengelolaan project | Single maintainer oleh Project Author | Disetujui |
| Versioning branch | Branch tanpa nomor versi: `release/final-review` | Disetujui |

Pekerjaan production publik, production signing, cloud deployment, dan iOS dipertahankan dalam implementation plan sebagai kesiapan masa depan, tetapi bukan blocker final review lokal. Jika scope berubah, item tersebut harus direklasifikasi menjadi P0 sebelum distribusi.

## 3. Perubahan yang diizinkan selama freeze

Perubahan berikut boleh masuk release branch:

- perbaikan defect P0/P1;
- perbaikan vulnerability dan dependency yang tervalidasi;
- pengujian otomatis, integration test, dan fixture UAT;
- migration runner, backup/restore tooling, dan deployment configuration;
- release signing dan konfigurasi environment;
- security/privacy hardening;
- observability minimum untuk operasi production;
- dokumentasi, release notes, dan sinkronisasi checklist;
- refactor minimum yang secara langsung diperlukan untuk menyelesaikan item di atas.

Perubahan berikut tidak boleh masuk:

- fitur atau role baru;
- perubahan desain besar yang tidak memperbaiki defect;
- migrasi framework/dependency mayor tanpa blocker keamanan/build;
- refactor umum atau optimasi spekulatif;
- perubahan kontrak API tanpa defect P0 atau approval lintas backend, web, dan mobile;
- perubahan dataset/perhitungan WHO atau SAW tanpa bukti referensi, regression test, dan review domain.

## 4. Klasifikasi perubahan

| Kelas | Definisi | Syarat merge |
|---|---|---|
| P0 | Security, kebocoran data, auth bypass, salah hitung, kehilangan data, migration/build release gagal | Reviewer teknis terkait + release approver |
| P1 | Alur inti gagal, integrasi penting gagal, hardening production wajib | Reviewer teknis terkait + release owner |
| Test/Docs | Menambah bukti, kontrak, runbook, atau memperbaiki dokumentasi | Minimal satu reviewer |
| P2 | Maintainability/visual minor/optimasi non-blocking | Ditunda ke backlog pascarilis |

## 5. Aturan branch dan review

- `release/final-review` dibuat dari baseline commit yang tercantum di atas.
- Perubahan dibuat pada branch pekerjaan terpisah dan masuk melalui PR ke release branch.
- Dilarang commit langsung ke release branch setelah branch dipublikasikan, kecuali recovery yang disetujui release approver.
- Setiap PR harus menyebut item implementation plan, severity, komponen terdampak, hasil test, risiko, dan rollback.
- Seluruh required checks harus lulus sebelum merge.
- PR yang mengubah kontrak bersama wajib direview oleh owner backend dan client terdampak.
- PR database wajib menyertakan backup, dry run, verifikasi, dan strategi rollback/forward-fix.
- Squash/rebase policy ditetapkan ketika branch dipublikasikan; history final harus dapat ditelusuri ke PR.
- Force push dilarang pada release branch dan `main` setelah branch protection diterapkan.

## 6. Hotfix dan freeze exception

Freeze exception hanya diberikan untuk:

1. P0 yang baru ditemukan;
2. kegagalan build/deploy yang memblokir release;
3. perubahan eksternal wajib, seperti credential/provider/API;
4. koreksi dokumentasi yang mencegah prosedur operasional salah.

Pemohon exception wajib mencatat:

- alasan dan severity;
- dampak bila tidak diperbaiki;
- luas perubahan;
- test dan rollback;
- persetujuan release approver.

Untuk project single-maintainer ini, freeze exception disetujui dan dicatat oleh Project Author sendiri. Alasan, test, risiko, dan rollback tetap wajib ditulis agar keputusan dapat diaudit saat final review akademik.

## 7. Owner matrix

Project dikelola oleh satu orang. `Project Author` menjadi owner dan approver seluruh area; pemisahan peran pada tabel berikut tetap dipakai sebagai checklist tanggung jawab.

| Peran | Tanggung jawab | Nama |
|---|---|---|
| Release owner/manager | Koordinasi gate, scope, jadwal, dan keputusan go/no-go | Project Author |
| Product/UAT approver | Penerimaan alur bisnis dan known issues | Project Author |
| Backend owner | API, auth, worker, dependency, dan integration | Project Author |
| Database owner | Migrasi, backup, restore, dan data verification | Project Author |
| Web owner | Dashboard, browser UAT, dan web deployment | Project Author |
| Mobile owner | Android build, Firebase, dan device UAT | Project Author |
| Security/privacy reviewer | Vulnerability, secret, PII, AI, dan risk acceptance | Project Author |
| Operations owner | Environment lokal, log, startup, dan recovery | Project Author |

Satu orang boleh memegang beberapa peran untuk tim kecil, tetapi tanggung jawab dan approval harus tetap eksplisit.

## 8. Required evidence per perubahan

```text
Implementation plan item:
Severity:
Owner:
Commit/PR:
Komponen terdampak:
Environment:
Command/skenario test:
Hasil:
Artefak/log/screenshot:
Risiko tersisa:
Rollback:
Reviewer:
Tanggal:
```

## 9. Definition of Done Workstream A

Workstream A dinyatakan selesai jika:

- [x] Target platform dan deployment lokal disetujui.
- [x] Fresh database ditetapkan sebagai release path saat ini.
- [x] Seluruh tanggung jawab owner/approver dipegang Project Author.
- [x] Release branch lokal `release/final-review` tersedia dari baseline yang benar.
- [x] Known-issues register tersedia dan memakai severity yang jelas.
- [x] Baseline evidence tersedia.
- [x] Fitur baru dikeluarkan dari final-review scope.

Branch tetap lokal sesuai target pengerjaan saat ini. Publikasi remote dan branch protection tidak diperlukan untuk menyelesaikan G0, tetapi direkomendasikan sebelum repository dipakai untuk kolaborasi atau penyerahan jarak jauh.
