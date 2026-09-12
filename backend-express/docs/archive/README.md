<div align="center">

# Arsip Dokumentasi Backend

**Snapshot rencana dan laporan lama—dipertahankan sebagai riwayat, bukan panduan aktif.**

![Plans](https://img.shields.io/badge/Archive-implementation%20plans-64748B?style=flat-square)
![Reports](https://img.shields.io/badge/Archive-review%20reports-EA580C?style=flat-square)

[Plans](#plans) · [Reports](#reports) · [Kontrak aktif](../README.md)

</div>

Folder ini menyimpan implementation plan, baseline review, dan laporan perubahan lama. Dokumen di sini adalah riwayat keputusan, bukan petunjuk setup, kontrak aktif, atau status quality gate terkini.

Gunakan [README backend](../../README.md) untuk menjalankan API, [indeks kontrak aktif](../README.md) untuk perilaku terkini, dan [Testing](../../../docs/TESTING.md) untuk hasil pengujian terbaru.

## 🗂️ Plans

| Dokumen | Status historis | Sumber aktif pengganti |
|---|---|---|
| [Conversational AI](./plans/implementation-plan-conversational-ai.md) | Implementasi utama tersedia; checklist lama dipertahankan sebagai snapshot | [API](../CONVERSATIONAL_AI_API.md) dan [policy](../CONVERSATIONAL_AI_POLICY.md) |
| [Penyaringan data teknis orang tua](./plans/implementation-plan-data-teknis-orang-tua.md) | Implementasi selesai | [Kontrak pengukuran](../ORANG_TUA_PENGUKURAN_CONTRACT.md), [rujukan](../ORANG_TUA_RUJUKAN_CONTRACT.md), dan [policy](../DATA_TEKNIS_UX_SECURITY_POLICY.md) |
| [Perbaikan temuan prioritas](./plans/implementation-plan-perbaikan-temuan-prioritas.md) | Perbaikan utama telah diterapkan | [Evidence terkini](../../../docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md) |
| [Prioritas pemantauan antropometri](./plans/implementation-plan-prioritas-pemantauan-antropometri.md) | Implementasi selesai | [Kontrak prioritas](../PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md) |

## 📋 Reports

| Dokumen | Snapshot |
|---|---|
| [Verifikasi temuan prioritas](./reports/verifikasi-temuan-prioritas.md) | Temuan integrasi 3 September 2026 sebelum perbaikan |
| [Backend review](./reports/backend-review-report.md) | Baseline 26 Agustus 2026 |
| [High-risk fixes](./reports/high-risk-fixes.md) | Change report setelah baseline |
| [Medium-risk fixes](./reports/medium-risk-fixes-report.md) | Change report temuan menengah |
| [WHO Z-score dan SAW overhaul](./reports/zscore-saw-overhaul-report.md) | Perubahan domain 27 Agustus 2026 |

Angka test, path dengan nomor baris, status fase, dan penilaian risiko di dalam arsip berlaku pada tanggal dokumen. Jangan memperbarui snapshot agar tampak seperti laporan baru; tambahkan evidence bertanggal di `docs/release/evidence/` bila verifikasi baru dilakukan.

---

<div align="center">
  <sub>Kembali ke <a href="../README.md">dokumentasi backend aktif</a></sub>
</div>
