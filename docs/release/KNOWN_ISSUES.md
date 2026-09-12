# Known Issues Register — Final Review

Status: **Open for finalization**  
Baseline: `release/final-review` dari commit `9893d91`

Severity menggunakan definisi pada `docs/release/GOVERNANCE.md`. Status yang valid: `Open`, `In Progress`, `Blocked`, `Ready for Review`, `Accepted`, atau `Closed`.

| ID | Severity | Area | Temuan | Exit criteria | Owner | Status |
|---|---|---|---|---|---|---|
| KI-001 | P0 | Backend dependency | Audit awal menemukan 1 high dan 8 moderate vulnerability | Audit bersih; clean install, 250 backend test, live/ready check lulus | Backend owner | Closed |
| KI-002 | P0 | WHO converter dependency | Audit awal menemukan 2 high dan 2 moderate vulnerability | High selesai; 2 moderate UUID diterima khusus trusted-input tool offline; integrity/checksum lulus | Backend/tooling owner | Accepted |
| KI-003 | P1 | Android signing | Release build masih memakai debug signing key | Wajib sebelum distribusi publik; tidak memblokir demo lokal | Mobile owner | Accepted |
| KI-004 | P0 | CI | Web dan WHO converter belum menjadi quality gate CI | Clean checkout CI menjalankan seluruh komponen | Operations owner | Open |
| KI-005 | P1 | CI/branch | Push check hanya aktif pada `main`, bukan integration/release branch | Required checks aktif sebelum kolaborasi/remote release | Operations owner | Accepted |
| KI-006 | P1 | Database | Belum ada migration runner dan schema history | Fresh setup wajib lulus; migration runner menjadi wajib sebelum memakai database existing | Database owner | Accepted |
| KI-007 | P1 | Recovery | Backup/restore production belum dibuktikan | Tidak memblokir fresh local database; wajib sebelum data nyata/public deployment | Database owner | Accepted |
| KI-008 | P0 | Integration | MySQL/SMTP/Turnstile/Gemini/FCM nyata belum tervalidasi bersama | Seluruh staging smoke/E2E lulus | Backend/operations owner | Open |
| KI-009 | P0 | UAT | Checklist manual lama masih memiliki 21 item terbuka | UAT tiga role lulus dan memiliki sign-off | Product/UAT approver | Open |
| KI-010 | P2 | Platform scope | Dokumentasi sebelumnya menempatkan IPA/iOS pada alur aktif | Seluruh dokumentasi menyatakan iOS sebagai roadmap, bukan scope final saat ini | Mobile/release owner | Closed |
| KI-011 | P1 | HTTP security | Header backend dan CSP web lokal sudah diterapkan; hosting HTTPS aktual belum diuji | Wajib staging test sebelum publik; RA-C06 diajukan untuk lokal | Security/web owner | Open |
| KI-012 | P1 | Web session | Bearer token disimpan di `localStorage` | RA-C01 diajukan hanya untuk lokal; secure cookie/review formal sebelum publik | Security/web owner | Open |
| KI-013 | P1 | Authentication | Password create/change/reset sebelumnya minimum 6 karakter | Minimum 8 karakter dan maksimum 72 byte UTF-8 diterapkan lintas backend/web/Android | Backend/security owner | Closed |
| KI-014 | P1 | Rate limit | Store in-memory tidak konsisten untuk multi-instance | RA-C02 diajukan untuk single-instance; central store sebelum scaling | Backend/operations owner | Open |
| KI-015 | P1 | Database security | TLS database belum dikonfigurasi | RA-C03 diajukan hanya untuk DB lokal; TLS sebelum network tidak dipercaya | Database/operations owner | Open |
| KI-016 | P1 | Observability | Logging/metric/alert production minimum belum tersedia | Request tracing, redaction, queue/error alert diverifikasi | Operations owner | Open |
| KI-017 | P1 | Documentation | Root README usang; Web README masih template; backend README tidak ada | Documentation workstream acceptance criteria lulus | Release owner | Closed |
| KI-018 | P1 | Governance | Tidak ada version/tag/release notes final | Versi konsisten, RC/tag/checksum/release notes tersedia | Release owner | Open |
| KI-019 | P1 | Mobile maintenance | Flutter memberi warning migrasi Built-in Kotlin dan plugin `file_saver` | Kompatibilitas versi target diputuskan dan dicatat | Mobile owner | Open |
| KI-020 | P1 | Firebase client | Restriction package/SHA/API key Android belum diverifikasi di provider console | Verifikasi sebelum APK/AAB dibagikan; RA-C05 diajukan | Mobile/security owner | Open |
| KI-021 | P1 | Auditability | Perubahan data klinis belum memiliki audit trail actor lengkap | RA-C04 diajukan hanya untuk fixture lokal; implementasi sebelum data nyata | Backend/security owner | Open |
| KI-022 | P2 | Maintainability | Beberapa file UI berukuran lebih dari 700–900 baris | Backlog refactor pascarilis memiliki owner/prioritas | Web/mobile owner | Open |
| KI-023 | P2 | Web performance | Bundle vendor besar tetapi build masih berhasil | Baseline dicatat; optimasi dijadwalkan jika ada target budget | Web owner | Open |

## Risk acceptance

Risk acceptance tidak boleh digunakan untuk auth bypass, kebocoran data, salah perhitungan antropometri, kehilangan data, debug signing, atau migrasi yang belum diuji.

Setiap acceptance wajib memuat:

- issue ID;
- alasan tidak diperbaiki pada release ini;
- dampak dan kemungkinan;
- mitigasi sementara;
- owner;
- tanggal kedaluwarsa acceptance;
- approver.
