<div align="center">

<img src="../../web-dashboard/src/assets/tumbuh.png" alt="Logo Tumbuh Posyandu" width="76" />

# Indeks Dokumentasi Backend Express

**Kontrak API, batas data, dan kebijakan teknis backend yang berlaku saat ini.**

![API](https://img.shields.io/badge/API-REST-2563EB?style=flat-square)
![Backend](https://img.shields.io/badge/Express-5-111827?style=flat-square&logo=express&logoColor=white)
![AI](https://img.shields.io/badge/Gemini-Conversational%20AI-8E75B2?style=flat-square&logo=googlegemini&logoColor=white)
![DSS](https://img.shields.io/badge/DSS-SAW-0A8754?style=flat-square)

[Kontrak aktif](#dokumen-aktif-dan-normatif) · [Checklist](#checklist-release) · [Arsip](#arsip-historis) · [Lintas project](#navigasi-lintas-project)

</div>

Folder ini memuat kontrak API/data dan kebijakan teknis backend yang masih berlaku. Implementation plan dan laporan lama telah dipisahkan ke arsip. Untuk instalasi dan menjalankan backend, gunakan [README backend](../README.md).

## 📘 Dokumen aktif dan normatif

| Dokumen | Fungsi |
|---|---|
| [CONVERSATIONAL_AI_API.md](./CONVERSATIONAL_AI_API.md) | Endpoint, kontrak, error, ownership, dan alur chat |
| [CONVERSATIONAL_AI_POLICY.md](./CONVERSATIONAL_AI_POLICY.md) | Batas edukasi AI, konteks yang diizinkan, dan validasi output |
| [DATA_TEKNIS_UX_SECURITY_POLICY.md](./DATA_TEKNIS_UX_SECURITY_POLICY.md) | Pemisahan informasi teknis petugas dan informasi aman orang tua |
| [LAPORAN_API.md](./LAPORAN_API.md) | Kontrak download laporan individual/rekap dan matriks akses |
| [ORANG_TUA_PENGUKURAN_CONTRACT.md](./ORANG_TUA_PENGUKURAN_CONTRACT.md) | Whitelist response pengukuran untuk orang tua |
| [ORANG_TUA_RUJUKAN_CONTRACT.md](./ORANG_TUA_RUJUKAN_CONTRACT.md) | Whitelist response rujukan untuk orang tua |
| [PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md](./PRIORITAS_PEMANTAUAN_ANTROPOMETRI_CONTRACT.md) | Aturan prioritas pemantauan dan batas tanggung jawab SAW |

Dokumen aktif menjelaskan kontrak yang dilindungi automated test. Perubahan terhadapnya harus disertai perubahan test dan review lintas backend, web, atau mobile yang terdampak.

## ✅ Checklist release

- [PRIORITAS_PEMANTAUAN_RELEASE_CHECKLIST.md](./PRIORITAS_PEMANTAUAN_RELEASE_CHECKLIST.md) — automated evidence, manual staging checklist, dan rollback untuk prioritas antropometri. Ini bukan panduan setup backend.

## 🗃️ Arsip historis

Implementation plan dan laporan review/perbaikan lama berada di [indeks arsip](./archive/README.md). Arsip mempertahankan konteks keputusan dan angka test sebagai snapshot bertanggal; gunakan kontrak di folder ini serta evidence release untuk status project terkini.

## 🧭 Navigasi lintas project

- [Indeks dokumentasi utama](../../docs/README.md)
- [Security dan privacy](../../docs/SECURITY_AND_PRIVACY.md)
- [Plan finalisasi dokumentasi](../../docs/DOCUMENTATION_IMPLEMENTATION_PLAN.md)
- [Known issues final review](../../docs/release/KNOWN_ISSUES.md)

## 📌 Catatan status

- Panduan runtime dan inisialisasi database berada pada README backend serta dokumentasi setup utama.
- Dokumen staging dan deployment lama dipertahankan sebagai roadmap atau checklist pengembangan lanjutan.
- Status test terkini berada pada [Documentation Final Review Evidence](../../docs/release/evidence/DOCUMENTATION_FINAL_REVIEW.md), bukan pada laporan historis.

---

<div align="center">
  <sub><a href="../README.md">README backend</a> · <a href="../../docs/README.md">Dokumentasi utama</a></sub>
</div>
