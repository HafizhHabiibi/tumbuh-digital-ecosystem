<div align="center">

# Release Records

**Jejak keputusan, risiko, dan bukti finalisasi project.**

![Governance](https://img.shields.io/badge/Documentation-governance-334155?style=flat-square)
![Evidence](https://img.shields.io/badge/Quality-evidence-2563EB?style=flat-square)
![Risk](https://img.shields.io/badge/Review-risk%20records-EA580C?style=flat-square)

[Kontrol](#kontrol-finalisasi) · [Risk acceptance](#risk-acceptance) · [Evidence](#evidence) · [Urutan membaca](#urutan-membaca)

</div>

Folder ini menyimpan governance, known issues, risk acceptance, dan evidence finalisasi Tumbuh Posyandu. Isinya mendukung audit keputusan pada branch `release/final-review`; bukan panduan setup atau klaim bahwa project siap production.

Catatan keputusan dibuat untuk project akademik Web dan Android yang dikelola oleh satu pengembang. Persiapan iOS dan pengembangan deployment berikutnya dicatat sebagai roadmap.

## 🧭 Kontrol finalisasi

| Dokumen | Status/fungsi |
|---|---|
| [GOVERNANCE.md](./GOVERNANCE.md) | Aturan feature freeze, branch, severity, owner, dan kontrol perubahan |
| [KNOWN_ISSUES.md](./KNOWN_ISSUES.md) | Register issue terbuka, diterima, dan ditutup |
| [Finalization Implementation Plan](../FINALIZATION_IMPLEMENTATION_PLAN.md) | Baseline/rencana finalisasi lengkap; dipertahankan sebagai release record |
| [Documentation Implementation Plan](../DOCUMENTATION_IMPLEMENTATION_PLAN.md) | Plan aktif perapian dokumentasi sampai final review |

## ⚖️ Risk acceptance

| Dokumen | Status |
|---|---|
| [WHO_CONVERTER_RISK_ACCEPTANCE.md](./WHO_CONVERTER_RISK_ACCEPTANCE.md) | Diterima untuk trusted-input tool offline pada final review lokal |
| [C_SECURITY_RISK_ACCEPTANCE.md](./C_SECURITY_RISK_ACCEPTANCE.md) | Menunggu persetujuan Project Author; hanya berlaku untuk scope lokal yang tertulis |

Risk acceptance tidak berlaku untuk data nyata atau deployment publik dan tidak menggantikan perbaikan blocker yang dilarang governance.

## 🔎 Evidence

| Dokumen | Tanggal | Fungsi |
|---|---|---|
| [G0_BASELINE.md](./evidence/G0_BASELINE.md) | 11–12 September 2026 | Kondisi awal feature freeze |
| [B_DEPENDENCY_EVIDENCE.md](./evidence/B_DEPENDENCY_EVIDENCE.md) | 12 September 2026 | Dependency audit dan clean install |
| [C_SECURITY_EVIDENCE.md](./evidence/C_SECURITY_EVIDENCE.md) | 12 September 2026 | Security verification Workstream C |
| [DOCUMENTATION_FINAL_REVIEW.md](./evidence/DOCUMENTATION_FINAL_REVIEW.md) | 12 September 2026 | Audit seluruh dokumentasi dan quality gate final terbaru |

Evidence adalah snapshot bertanggal. Untuk status test terbaru, jalankan command pada [Testing](../TESTING.md) dan buat record baru bila hasilnya perlu dibekukan.

## 📖 Urutan membaca

1. Baca [Governance](./GOVERNANCE.md) untuk scope dan aturan freeze.
2. Baca [Known Issues](./KNOWN_ISSUES.md) untuk keputusan terbuka/diterima.
3. Periksa risk acceptance yang terkait dengan issue.
4. Gunakan evidence bertanggal untuk klaim verifikasi.

Panduan penggunaan aktif berada di [indeks dokumentasi](../README.md). Laporan implementasi backend lama berada di [arsip backend](../../backend-express/docs/archive/README.md).

---

<div align="center">
  <sub><a href="../README.md">Indeks dokumentasi</a> · <a href="../../README.md">README utama</a></sub>
</div>
