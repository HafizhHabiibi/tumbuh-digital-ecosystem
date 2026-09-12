# Workstream C — Security Risk Acceptance

Tanggal: **2026-09-12**  
Owner/approver scope lokal: **Project Author**  
Status: **menunggu persetujuan pada final review**

Acceptance berikut hanya berlaku untuk penggunaan lokal, single instance, database fresh, fixture sintetis, dan perangkat yang dikendalikan owner. Perluasan ke data nyata, pengguna eksternal, atau deployment publik otomatis membatalkan acceptance ini.

| ID | Risiko yang diterima | Dampak | Mitigasi sementara | Batas/tenggat |
|---|---|---|---|---|
| RA-C01 | Access token web disimpan di `localStorage` | XSS dapat mengambil sesi petugas | CSP berbasis API origin, tidak ada rendering HTML mentah, dependency audit 0, perangkat owner, tanpa data nyata | Migrasi secure cookie atau review formal sebelum publik |
| RA-C02 | Rate limit memakai memory store | Counter hilang saat restart dan tidak sinkron antar instance | Hanya satu proses lokal; login juga dibatasi per email; IPv4/IPv6 proxy test tersedia | Central store sebelum multi-instance/publik |
| RA-C03 | MySQL lokal belum memakai TLS | Traffic DB dapat disadap jika melewati jaringan tidak dipercaya | DB dan backend berada pada host/jaringan lokal owner | TLS wajib sebelum DB remote/untrusted network |
| RA-C04 | Audit trail klinis minimum belum tersedia | Perubahan data penting tidak memiliki histori actor lengkap | Fixture sintetis, satu owner, tidak ada operasi layanan nyata | Implementasikan sebelum data nyata/UAT institusi |
| RA-C05 | Restriction Firebase Android belum dapat dibuktikan dari repository | Penyalahgunaan client API key/quota bila restriction salah | Client config bukan private key; Firebase Admin tetap via env/ADC; distribusi dibatasi lokal | Verifikasi package, SHA, dan API restrictions sebelum APK/AAB dibagikan |
| RA-C06 | Header HTTP web production belum diuji pada hosting aktual | Meta CSP tidak menggantikan seluruh header/HSTS | Vite dev/preview mengirim header dan build memiliki meta CSP | Uji staging HTTPS sebelum publik |
| RA-C07 | Credential lama belum dirotasi dalam Workstream C | Credential yang pernah dibagikan dapat disalahgunakan | Repository scan tidak menemukan private/server key; hanya owner memegang environment lokal | Rotasi semua provider/JWT credential sebelum staging bersama/publik |
| RA-C08 | Tidak ada kebijakan retensi institusional | Data dapat tersimpan terlalu lama atau dihapus keliru | Data nyata dilarang; disposal lokal maksimum 90 hari setelah penilaian | Persetujuan institusi sebelum data nyata |

## Keputusan final-review

- [ ] Project Author menyetujui acceptance untuk scope lokal.
- [ ] Project Author mengonfirmasi fixture yang dipakai tidak berasal dari orang nyata.
- [ ] Project Author mengonfirmasi repository/artefak tidak akan dipublikasikan bersama `.env`, service-account, keystore, database, backup, atau laporan.
