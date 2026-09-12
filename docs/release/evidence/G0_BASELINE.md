# G0 Baseline Evidence — Final Review

Tanggal audit teknis: **11 September 2026**  
Tanggal freeze record: **12 September 2026**  
Baseline commit: `9893d9178203a1619a6574edcf9bc9fd8d2240f3`  
Baseline branch sumber: `development`  
Release branch lokal: `release/final-review`

## Repository

- Worktree bersih sebelum pembuatan dokumen finalisasi.
- `development` menunjuk commit `9893d91` dan sinkron dengan `origin/development` pada saat audit.
- Belum ada release branch atau tag sebelum Workstream A dimulai.
- Dokumen finalisasi adalah perubahan dokumentasi pertama setelah baseline kode.

## Automated verification

| Komponen | Command | Hasil |
|---|---|---|
| Backend | `npm test` | 250 passed, 0 failed |
| Web | `npm run check` | ESLint lulus, 66 test lulus, production build berhasil |
| WHO converter | `npm test` | 4 passed, 0 failed |
| Flutter format | `dart format --output=none --set-exit-if-changed lib test` | 85 file diperiksa, 0 berubah |
| Flutter analyzer | `flutter analyze` | No issues found |
| Flutter test | `flutter test` | 126 passed |
| Android debug build | `flutter build apk --debug --dart-define-from-file=config/development-emulator.json` | Berhasil |

Total test yang lulus pada baseline: **446**.

## Dependency audit

| Komponen | Command | Hasil baseline |
|---|---|---|
| Backend | `npm audit --omit=dev --audit-level=moderate` | 1 high, 8 moderate |
| Web | `npm audit --omit=dev --audit-level=moderate` | 0 vulnerability |
| WHO converter | `npm audit --omit=dev --audit-level=moderate` | 2 high, 2 moderate |

Audit dependency bersifat time-sensitive dan wajib diulang pada lockfile release candidate.

## Runtime readiness

Pemeriksaan `checkReadiness()` lokal menghasilkan:

```json
{
  "ready": false,
  "components": {
    "database": "unavailable",
    "ai": "unknown"
  },
  "errorCode": "ECONNREFUSED"
}
```

Hasil tersebut menunjukkan MySQL lokal tidak aktif/terjangkau pada saat audit. Karena itu baseline tidak mengklaim kelulusan end-to-end database atau integrasi eksternal.

## Toolchain audit

- Node.js `v24.14.1` pada mesin audit.
- npm `11.18.0`.
- Flutter `3.44.2` stable.
- Dart `3.12.2`.
- Java 17.
- CI saat baseline menggunakan Node.js 22, Flutter 3.44.2, dan Java 17.

Perbedaan Node.js lokal dan CI harus dipertimbangkan dalam reproducible-build verification.

## Baseline limitations

- Tidak ada test terhadap database staging/production nyata.
- Tidak ada smoke test nyata SMTP, Turnstile, Gemini, dan FCM.
- Tidak ada device UAT yang tercatat.
- Tidak ada build Android release dengan production signing.
- Tidak ada build iOS.
- Tidak ada backup/restore drill.
- Tidak ada evidence deployment production.

## Approval

| Peran | Nama | Keputusan | Tanggal |
|---|---|---|---|
| Release owner | Project Author | Approved | 12 September 2026 |
| Product/UAT approver | Project Author | Approved untuk scope lokal | 12 September 2026 |
| Technical reviewer | Project Author | Approved | 12 September 2026 |
