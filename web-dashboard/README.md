<div align="center">

<img src="./src/assets/tumbuh.png" alt="Logo Tumbuh Posyandu" width="92" />

# Dashboard Web Tumbuh Posyandu

**Ruang kerja digital untuk operasional kader, monitoring puskesmas, dan visualisasi hasil DSS SAW.**

![Vue](https://img.shields.io/badge/Vue-3-42B883?style=flat-square&logo=vuedotjs&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-8-646CFF?style=flat-square&logo=vite&logoColor=white)
![Pinia](https://img.shields.io/badge/Pinia-3-F7D336?style=flat-square)
![PrimeVue](https://img.shields.io/badge/PrimeVue-4-41B883?style=flat-square)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white)

[Fitur](#fitur-dashboard) · [Setup](#setup-dashboard) · [Command](#command-dashboard) · [Troubleshooting](#troubleshooting-dashboard)

</div>

Dashboard Vue menjadi antarmuka operasional Web dalam ekosistem Tumbuh Posyandu. Aplikasi ini digunakan oleh role `kader` dan `puskesmas`, sedangkan orang tua mengakses layanan melalui aplikasi Android.

<a id="fitur-dashboard"></a>

## ✨ Fitur

Kader dapat mengakses dashboard, prioritas pemantauan, data orang tua dan anak, pengukuran, pemberian, rujukan, jadwal, laporan, serta profil. Puskesmas memperoleh dashboard monitoring, prioritas, data anak, rujukan dan tindak lanjut, jadwal, laporan, serta profil.

Route utama dibagi ke namespace `/kader/*` dan `/puskesmas/*`. Router guard mengarahkan pengguna berdasarkan role, sementara otorisasi sebenarnya tetap ditegakkan oleh backend.

## ✅ Prasyarat

- Node.js `22` dan npm;
- backend berjalan pada `http://localhost:3000`;
- pasangan site key/secret Cloudflare Turnstile yang valid untuk login Web.

<a id="setup-dashboard"></a>

## 🚀 Setup dan menjalankan

```powershell
npm install
Copy-Item .env.example .env
npm run dev
```

Vite tersedia pada `http://localhost:5173` secara default.

Konfigurasi `.env`:

| Variable | Fungsi |
|---|---|
| `VITE_API_URL` | Base URL API absolut dan berakhir dengan `/api`; lokal: `http://localhost:3000/api` |
| `VITE_TURNSTILE_SITE_KEY` | Site key Turnstile untuk login dan forgot-password Web |

Site key harus cocok dengan `TURNSTILE_SECRET_KEY` serta hostname yang diizinkan backend. Variable Vite dikirim ke bundle browser, sehingga jangan menaruh secret di dalam `VITE_*`.

<a id="command-dashboard"></a>

## 🧪 Command

| Command | Fungsi |
|---|---|
| `npm run dev` | Menjalankan Vite development server |
| `npm run lint` | Menjalankan ESLint |
| `npm test` | Menjalankan test Vitest sekali |
| `npm run build` | Membuat production bundle ke `dist/` |
| `npm run preview` | Menyajikan hasil build secara lokal |
| `npm run check` | Menjalankan lint, test, dan build berurutan |

Quality gate utama:

```powershell
npm run check
```

Untuk memeriksa bundle secara lokal:

```powershell
npm run build
npm run preview
```

## 🔐 Session dan browser security

Token dan profil petugas disimpan di `localStorage`. Logout dan perubahan password membersihkan session browser, sementara backend tetap memvalidasi token, status akun, dan role pada setiap request terlindungi.

Vite menghasilkan Content Security Policy dari origin `VITE_API_URL` dan mengirim security headers pada development/preview server. Hosting production nantinya tetap harus dikonfigurasi untuk mengirim header HTTP yang sesuai.

<a id="troubleshooting-dashboard"></a>

## 🛠️ Troubleshooting

| Gejala | Pemeriksaan |
|---|---|
| Vite menolak `VITE_API_URL` | Gunakan URL HTTP/HTTPS absolut, misalnya `http://localhost:3000/api` |
| Request API gagal | Pastikan backend hidup dan URL tidak kehilangan suffix `/api` |
| Error CORS | Samakan origin dashboard dengan `CORS_ORIGIN` backend |
| Turnstile tidak tampil/login tidak aktif | Isi site key yang valid dan pastikan akses ke domain Cloudflare tidak diblokir |
| Login ditolak untuk orang tua | Perilaku benar; role orang tua hanya didukung aplikasi Android |
| Refresh route langsung menghasilkan 404 saat hosting | Konfigurasikan SPA fallback ke `index.html` pada web server |

Lihat [README root](../README.md) untuk urutan setup lengkap dan [Security dan Privacy](../docs/SECURITY_AND_PRIVACY.md) untuk penjelasan perlindungan data serta autentikasi.

---

<div align="center">
  <sub>Bagian dari <a href="../README.md">Tumbuh Posyandu</a></sub>
</div>
