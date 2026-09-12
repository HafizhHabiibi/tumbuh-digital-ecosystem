# Workstream B Evidence — Dependency dan Software Supply Chain

Tanggal verifikasi: **12 September 2026**  
Branch: `release/final-review`  
Owner: Project Author

## 1. Ringkasan hasil

| Komponen | Sebelum | Setelah | Clean install | Test/build |
|---|---:|---:|---|---|
| Backend | 1 high, 8 moderate | 0 vulnerability | `npm ci` lulus | 250 test lulus |
| Web dashboard | 0 vulnerability | 0 vulnerability | `npm ci` lulus | ESLint, 66 test, build lulus |
| WHO converter | 2 high, 2 moderate | 0 high, 2 moderate accepted | `npm ci` lulus | 4 test + checksum lulus |
| Flutter | Tidak ada advisory npm | Tidak di-upgrade | Lockfile dipertahankan | Format, analyze, 126 test lulus |

Tidak ada update dengan `--force` dan tidak ada major dependency upgrade.

## 2. Backend dependency update

### Versi runtime relevan setelah update

| Package | Sebelum | Setelah | Catatan |
|---|---:|---:|---|
| `mysql2` | 3.22.0 | 3.24.4 | Menghilangkan advisory decompression DoS |
| `nodemailer` | 9.0.5 | 9.1.1 | Memuat security fixes tanpa berpindah ke major 10 |
| `firebase-admin` | 14.3.0 | 14.4.0 | Memperbarui rantai Google Cloud/storage/firestore |
| `qs` | 6.15.3 transitif | 6.16.0 | Menghilangkan advisory parsing/DoS |
| `@google-cloud/storage` | 7.22.0 transitif | 8.1.0 | Membawa rantai request/UUID yang telah diperbaiki |

Referensi upstream yang ditinjau:

- [Nodemailer changelog](https://github.com/nodemailer/nodemailer/blob/master/CHANGELOG.md): 9.1.0 memperbaiki address parsing dan recipient handling; 9.1.1 memperbaiki message access policy.
- [Firebase Admin 14.4.0 release](https://github.com/firebase/firebase-admin-node/releases/tag/v14.4.0): pembaruan dependency Google Cloud dan perubahan ML yang tidak digunakan project.
- [MySQL2 changelog](https://github.com/sidorares/node-mysql2/blob/master/Changelog.md): tidak ditemukan breaking API note untuk penggunaan pool/query project; seluruh kontrak database tetap dilindungi backend test.

### Install-script allowlist

npm 11 meminta kebijakan eksplisit untuk tiga lifecycle script. Versi berikut telah ditinjau dan dipin pada `backend-express/package.json`:

- `bcrypt@6.0.0`: memilih/membangun native binary melalui `node-gyp-build`;
- `protobufjs@7.6.6`: menjalankan postinstall package;
- `@firebase/util@1.15.3`: menjalankan postinstall Firebase util.

Allowlist exact-version mencegah package dengan versi berbeda otomatis memperoleh izin script. Setiap update versi package tersebut wajib memperbarui allowlist melalui review baru.

### Verifikasi backend

```text
npm ci                                      PASS
npm test                                    PASS — 250/250
npm audit --omit=dev --audit-level=moderate PASS — 0 vulnerability
GET /api/health/live                        PASS — HTTP 200
GET /api/health/ready                       PASS — database ready, AI ready
```

SMTP reset-password dan pengiriman FCM nyata tidak dijalankan karena belum ada alamat/perangkat uji yang ditetapkan. Keduanya dipindahkan ke integration verification Workstream I.

## 3. Web dashboard

Tidak ada versi dependency web yang diubah karena audit awal sudah bersih. Major update Vue/Pinia/PrimeVue/Vitest/router tidak dilakukan selama freeze.

```text
npm ci                                      PASS
npm run lint                                PASS
npm run test                                PASS — 66/66
npm run build                               PASS
npm audit --omit=dev --audit-level=moderate PASS — 0 vulnerability
GET http://localhost:5173                   PASS — HTTP 200 setelah dev server dipulihkan
```

## 4. WHO converter

Update transitif non-breaking:

- `brace-expansion` 1.1.14 → 1.1.18;
- `brace-expansion` 2.1.0 → 2.1.4;
- `tmp` 0.2.5 → 0.2.7.

Seluruh high vulnerability hilang. Dua moderate tetap berasal dari `uuid@8.3.2` melalui `exceljs@4.4.0` dan ditangani dalam `docs/release/WHO_CONVERTER_RISK_ACCEPTANCE.md`.

```text
npm ci                         PASS
npm test                       PASS — 4/4
npm run generate               PASS
whoTables.json checksum before 3a3e435027b9d6ebf3cfe2e1ac8769c34cb7f9aa
whoTables.json checksum after  3a3e435027b9d6ebf3cfe2e1ac8769c34cb7f9aa
```

Output tetap tepat 10 tabel dan identik byte-for-byte menurut Git object hash.

## 5. Flutter dependency decision

`flutter pub outdated --no-dev-dependencies` telah dijalankan. Terdapat package patch/minor yang dapat di-upgrade dan banyak major version baru, tetapi tidak ada blocker keamanan yang teridentifikasi dari pemeriksaan ini. Untuk menekan risiko regresi selama freeze:

- `pubspec.yaml` dan `pubspec.lock` dipertahankan;
- tidak ada `flutter pub upgrade --major-versions`;
- major upgrade Firebase, Riverpod, routing, storage, chart, dan notification masuk backlog pascarilis;
- warning migrasi Built-in Kotlin serta kompatibilitas `file_saver` tetap tercatat sebagai KI-019.

```text
dart format --output=none --set-exit-if-changed lib test PASS — 0 berubah
flutter analyze                                      PASS — no issues
flutter test                                         PASS — 126/126
```

## 6. Gangguan lokal dan recovery

Clean install awal backend dan web gagal `EPERM` karena development server memegang native binary `bcrypt.node` dan Lightning CSS. Hanya proses dev workspace yang terverifikasi dihentikan. Setelah clean install dan quality gate selesai:

- backend dev server dinyalakan kembali dan health live mengembalikan 200;
- Vite dev server dinyalakan kembali dan halaman lokal mengembalikan 200;
- proses tooling lain tidak dihentikan.

## 7. Kesimpulan Workstream B

Workstream B memenuhi dependency gate untuk scope final review lokal:

- tidak ada high/critical vulnerability;
- backend dan web sepenuhnya bersih pada audit moderate;
- residual moderate converter dibatasi pada tool offline dengan trusted input dan risk acceptance;
- clean install serta seluruh test terkait lulus;
- data WHO dan regresi perhitungan tidak berubah;
- tidak ada major/force upgrade.

Perubahan package/lockfile dan evidence masih menunggu commit bersama final-review changes.
