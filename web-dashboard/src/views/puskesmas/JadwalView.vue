<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <PageHeader title="Jadwal Posyandu" />

        <!-- ─── Alert Notifikasi Error API ────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="store.error.fetchAll"
                class="flex items-center justify-between gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700"
                role="alert"
            >
                <div class="flex items-center gap-2.5">
                    <i class="pi pi-exclamation-circle shrink-0" aria-hidden="true" />
                    <span>{{ store.error.fetchAll }}</span>
                </div>
                <button
                    type="button"
                    class="text-xs font-bold underline hover:text-red-900 cursor-pointer"
                    @click="loadPage(store.pagination.page)"
                >
                    Coba Lagi
                </button>
            </div>
        </Transition>

        <!-- ─── Alert Sukses Salin Pengumuman ─────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="copySuccess"
                class="flex items-center gap-2.5 px-4 py-2.5 rounded-xl text-xs bg-emerald-500 text-white font-medium shadow-sm fixed bottom-6 right-6 z-50"
                role="status"
            >
                <i class="pi pi-check-circle text-sm" aria-hidden="true" />
                <span>Teks pengumuman berhasil disalin ke clipboard!</span>
            </div>
        </Transition>

        <!-- ─── Hero Card: Jadwal Terdekat ────────────────────────── -->
        <section
            v-if="store.jadwalTerdekat"
            class="hero-card p-5 sm:p-6 rounded-2xl relative overflow-hidden shadow-lg"
            aria-labelledby="hero-jadwal-title"
        >
            <!-- Dekorasi latar belakang kalender samar -->
            <i class="pi pi-calendar hero-bg-icon" aria-hidden="true" />

            <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-5">
                <div class="space-y-3 min-w-0">
                    <div class="flex items-center gap-2.5 flex-wrap">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold tracking-wider uppercase bg-white/15 text-white backdrop-blur-xs border border-white/20">
                            <i class="pi pi-calendar-clock text-[10px]" />
                            Jadwal Terdekat
                        </span>
                        <span
                            class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-bold"
                            :class="
                                isHariIni(store.jadwalTerdekat.tanggal)
                                    ? 'bg-amber-400 text-amber-950 animate-pulse'
                                    : 'bg-emerald-400 text-emerald-950'
                            "
                        >
                            <span class="w-1.5 h-1.5 rounded-full" :class="isHariIni(store.jadwalTerdekat.tanggal) ? 'bg-amber-900' : 'bg-emerald-900'" />
                            {{ sisaHari(store.jadwalTerdekat.tanggal) }}
                        </span>
                    </div>

                    <div>
                        <h2 id="hero-jadwal-title" class="text-xl sm:text-2xl font-extrabold text-white tracking-tight m-0">
                            {{ formatTanggalPanjang(store.jadwalTerdekat.tanggal) }}
                        </h2>
                        <div class="flex items-center gap-4 text-xs text-emerald-100 font-medium mt-2 flex-wrap">
                            <span class="inline-flex items-center gap-1.5">
                                <i class="pi pi-clock text-emerald-300" />
                                {{ formatWaktu(store.jadwalTerdekat.waktu_mulai) }} – {{ formatWaktu(store.jadwalTerdekat.waktu_selesai) }} WIB
                            </span>
                            <span class="inline-flex items-center gap-1.5">
                                <i class="pi pi-map-marker text-emerald-300" />
                                {{ store.jadwalTerdekat.lokasi }}
                            </span>
                        </div>
                    </div>
                </div>

                <div class="flex items-center gap-2.5 shrink-0">
                    <button
                        type="button"
                        class="px-3.5 py-2 rounded-xl text-xs font-semibold bg-white/15 hover:bg-white/25 text-white border border-white/20 backdrop-blur-xs transition-all cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                        title="Salin pesan pengumuman jadwal untuk WhatsApp"
                        @click="salinPengumuman(store.jadwalTerdekat)"
                    >
                        <i class="pi pi-share-alt text-[11px]" aria-hidden="true" />
                        <span>Salin Pesan WA</span>
                    </button>
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold bg-white text-emerald-900 hover:bg-emerald-50 transition-all cursor-pointer inline-flex items-center gap-1.5 shadow-xs"
                        @click="lihatDetail(store.jadwalTerdekat.id)"
                    >
                        <i class="pi pi-eye text-[11px]" aria-hidden="true" />
                        <span>Lihat Detail</span>
                    </button>
                </div>
            </div>
        </section>

        <!-- ─── Toolbar Filter ────────────────────────────────────── -->
        <section class="card p-3.5 sm:p-4 rounded-2xl flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3.5 w-full min-w-0" aria-label="Menu navigasi jadwal">
            <!-- Filter Chips (Style Riwayat Rujukan) -->
            <div
                class="bg-slate-100/90 p-0.5 rounded-xl flex items-center gap-0.5 border border-slate-200/70 overflow-x-auto min-w-0 filter-scroll self-start sm:self-auto"
                role="tablist"
                aria-label="Filter status jadwal"
            >
                <button
                    v-for="tab in filterTabs"
                    :key="tab.key"
                    type="button"
                    role="tab"
                    :aria-selected="activeFilter === tab.key"
                    class="flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-all cursor-pointer whitespace-nowrap shrink-0 tracking-tight focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-emerald-600"
                    :class="
                        activeFilter === tab.key
                            ? 'bg-emerald-600 text-white shadow-2xs'
                            : 'text-slate-600 hover:text-slate-900 hover:bg-slate-200/60'
                    "
                    @click="activeFilter = tab.key"
                >
                    <span>{{ tab.label }}</span>
                    <span
                        class="min-w-3.5 px-1 py-0.2 rounded-full text-[9px] font-bold text-center leading-none transition-colors"
                        :class="
                            activeFilter === tab.key
                                ? 'bg-white/20 text-white'
                                : 'bg-slate-200 text-slate-600'
                        "
                    >
                        {{ getTabCount(tab.key) }}
                    </span>
                </button>
            </div>
        </section>

        <!-- ─── Loading State ─────────────────────────────────────── -->
        <div v-if="store.loading.fetchAll" class="space-y-3">
            <div v-for="i in 3" :key="i" class="skeleton h-24 rounded-2xl" />
        </div>

        <!-- ─── Empty State ───────────────────────────────────────── -->
        <div
            v-else-if="jadwalTampil.length === 0"
            class="card p-10 sm:p-12 rounded-2xl flex flex-col items-center justify-center gap-3 text-center bg-white border border-slate-200/80 shadow-2xs"
        >
            <div class="w-12 h-12 rounded-2xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600 shadow-2xs">
                <i class="pi pi-calendar text-xl" aria-hidden="true" />
            </div>
            <div>
                <p class="text-sm font-bold text-slate-800 m-0">
                    {{ activeFilter === "mendatang" ? "Belum ada jadwal posyandu mendatang" : (activeFilter === "lewat" ? "Belum ada riwayat jadwal yang lewat" : "Belum ada data jadwal") }}
                </p>
                <p class="text-xs text-slate-500 mt-1 mb-0 max-w-sm">
                    {{ activeFilter === "mendatang" ? "Jadwal kegiatan posyandu yang disusun oleh kader di wilayah kerja akan muncul di sini." : "Semua kegiatan posyandu yang telah selesai akan tercatat di sini." }}
                </p>
            </div>
        </div>

        <!-- ─── Daftar Jadwal Berkonsep Kartu Modern ──────────────── -->
        <div v-else class="space-y-3">
            <article
                v-for="jadwal in jadwalTampil"
                :key="jadwal.id"
                class="card p-4 sm:p-5 rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-4 transition-all duration-150 hover:shadow-md border border-slate-200/80 bg-white"
                :class="{ 'ring-1 ring-amber-300 bg-amber-50/20': isHariIni(jadwal.tanggal) }"
            >
                <!-- Group Kiri: Kotak Tanggal & Rincian Jadwal -->
                <div class="flex items-start sm:items-center gap-4 min-w-0">
                    <!-- Kotak Tanggal Visual -->
                    <div
                        class="w-16 h-16 sm:w-18 sm:h-18 rounded-2xl flex flex-col items-center justify-center shrink-0 border transition-colors shadow-2xs select-none"
                        :class="
                            isHariIni(jadwal.tanggal)
                                ? 'bg-amber-100/90 border-amber-300 text-amber-900'
                                : isLewat(jadwal.tanggal)
                                    ? 'bg-slate-100 border-slate-200 text-slate-500'
                                    : 'bg-emerald-50 border-emerald-200/80 text-emerald-900'
                        "
                    >
                        <span class="text-[10px] uppercase font-bold tracking-wider leading-none">
                            {{ namaHari(jadwal.tanggal) }}
                        </span>
                        <span class="text-xl sm:text-2xl font-extrabold tracking-tight leading-none my-0.5">
                            {{ angkaTanggal(jadwal.tanggal) }}
                        </span>
                        <span class="text-[10px] font-semibold leading-none opacity-80">
                            {{ bulanSingkat(jadwal.tanggal) }}
                        </span>
                    </div>

                    <!-- Informasi Jadwal -->
                    <div class="space-y-1 min-w-0">
                        <div class="flex items-center gap-2 flex-wrap">
                            <h3 class="text-sm sm:text-base font-bold text-slate-800 m-0 truncate">
                                {{ jadwal.lokasi }}
                            </h3>
                            <span
                                v-if="isHariIni(jadwal.tanggal)"
                                class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-amber-100 text-amber-800 border border-amber-200"
                            >
                                <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
                                Hari Ini
                            </span>
                            <span
                                v-else-if="isLewat(jadwal.tanggal)"
                                class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-medium bg-slate-100 text-slate-600 border border-slate-200"
                            >
                                Selesai
                            </span>
                            <span
                                v-else
                                class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/80"
                            >
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                                Mendatang
                            </span>
                        </div>

                        <p class="text-xs text-slate-500 m-0 flex items-center gap-2 flex-wrap">
                            <span class="inline-flex items-center gap-1 text-slate-600 font-medium">
                                <i class="pi pi-clock text-slate-400 text-[11px]" />
                                {{ formatWaktu(jadwal.waktu_mulai) }} – {{ formatWaktu(jadwal.waktu_selesai) }} WIB
                            </span>
                            <span class="text-slate-300">•</span>
                            <span class="inline-flex items-center gap-1 text-slate-600">
                                <i class="pi pi-user text-slate-400 text-[11px]" />
                                Dicatat: {{ jadwal.dibuat_oleh || 'Kader' }}
                            </span>
                        </p>

                        <p
                            v-if="jadwal.keterangan"
                            class="text-xs text-slate-500 m-0 mt-2.5 pt-1.5 border-t border-slate-100/80 line-clamp-1 italic"
                        >
                            {{ jadwal.keterangan }}
                        </p>
                    </div>
                </div>

                <!-- Group Kanan: Aksi Kartu -->
                <div class="flex items-center gap-2 shrink-0 self-end sm:self-center">
                    <button
                        type="button"
                        class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer inline-flex items-center gap-1.5"
                        title="Lihat detail lengkap jadwal"
                        @click="lihatDetail(jadwal.id)"
                    >
                        <i class="pi pi-eye text-[11px]" aria-hidden="true" />
                        <span>Detail</span>
                    </button>
                </div>
            </article>

            <!-- Kontrol Paginasi -->
            <div class="card rounded-2xl overflow-hidden mt-4">
                <PaginationControls
                    :pagination="store.pagination"
                    :loading="store.loading.fetchAll"
                    @change-page="loadPage"
                />
            </div>
        </div>

        <!-- ─── Dialog Detail Jadwal ──────────────────────────────── -->
        <Dialog
            v-model:visible="showDetail"
            modal
            header="Detail Jadwal Posyandu"
            :style="{ width: '480px', maxWidth: '95vw' }"
            :pt="{ header: { style: 'border-bottom: 1px solid var(--color-input-border)' } }"
        >
            <div v-if="store.loading.fetchDetail" class="p-5 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-12 rounded-xl" />
            </div>
            <div v-else-if="store.jadwalDetail" class="space-y-4 pt-3">
                <!-- Hero Header Kartu Jadwal -->
                <div
                    class="p-4 rounded-2xl border flex items-center justify-between gap-3"
                    :class="
                        isHariIni(store.jadwalDetail.tanggal)
                            ? 'bg-amber-50/70 border-amber-200'
                            : isLewat(store.jadwalDetail.tanggal)
                                ? 'bg-slate-50 border-slate-200/80'
                                : 'bg-emerald-50/70 border-emerald-200/80'
                    "
                >
                    <div class="flex items-center gap-3.5 min-w-0">
                        <!-- Kotak Tanggal Visual -->
                        <div
                            class="w-14 h-14 rounded-xl flex flex-col items-center justify-center shrink-0 border shadow-2xs select-none"
                            :class="
                                isHariIni(store.jadwalDetail.tanggal)
                                    ? 'bg-amber-100 border-amber-300 text-amber-900'
                                    : isLewat(store.jadwalDetail.tanggal)
                                        ? 'bg-white border-slate-200 text-slate-600'
                                        : 'bg-white border-emerald-200 text-emerald-800'
                            "
                        >
                            <span class="text-[9px] uppercase font-bold tracking-wider leading-none">
                                {{ namaHari(store.jadwalDetail.tanggal) }}
                            </span>
                            <span class="text-xl font-extrabold tracking-tight leading-none my-0.5">
                                {{ angkaTanggal(store.jadwalDetail.tanggal) }}
                            </span>
                            <span class="text-[9px] font-semibold leading-none opacity-80">
                                {{ bulanSingkat(store.jadwalDetail.tanggal) }}
                            </span>
                        </div>

                        <div class="min-w-0">
                            <h3 class="text-sm sm:text-base font-bold text-slate-800 m-0 truncate">
                                {{ store.jadwalDetail.lokasi }}
                            </h3>
                            <p class="text-xs text-slate-500 m-0 mt-0.5">
                                {{ formatTanggalPanjang(store.jadwalDetail.tanggal) }}
                            </p>
                        </div>
                    </div>

                    <!-- Badge Status -->
                    <span
                        v-if="isHariIni(store.jadwalDetail.tanggal)"
                        class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-100 text-amber-800 border border-amber-200 shrink-0"
                    >
                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse" />
                        Hari Ini
                    </span>
                    <span
                        v-else-if="isLewat(store.jadwalDetail.tanggal)"
                        class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium bg-slate-100 text-slate-600 border border-slate-200 shrink-0"
                    >
                        Selesai
                    </span>
                    <span
                        v-else
                        class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800 border border-emerald-200 shrink-0"
                    >
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-600" />
                        Mendatang
                    </span>
                </div>

                <!-- Rincian Waktu & Lokasi (Atas Bawah agar tidak terpotong) -->
                <div class="space-y-3">
                    <!-- Kartu Waktu -->
                    <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-start gap-3">
                        <div class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-800 flex items-center justify-center shrink-0 mt-0.5">
                            <i class="pi pi-clock text-xs" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="text-[11px] font-semibold text-slate-500 m-0">
                                Waktu Pelaksanaan
                            </p>
                            <p class="text-xs font-bold text-slate-800 m-0 mt-0.5">
                                {{ formatWaktu(store.jadwalDetail.waktu_mulai) }} – {{ formatWaktu(store.jadwalDetail.waktu_selesai) }} WIB
                            </p>
                        </div>
                    </div>

                    <!-- Kartu Lokasi -->
                    <div class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-start gap-3">
                        <div class="w-8 h-8 rounded-lg bg-emerald-100 text-emerald-800 flex items-center justify-center shrink-0 mt-0.5">
                            <i class="pi pi-map-marker text-xs" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="text-[11px] font-semibold text-slate-500 m-0">
                                Lokasi Pelaksanaan
                            </p>
                            <p class="text-xs font-bold text-slate-800 m-0 mt-0.5 break-words">
                                {{ store.jadwalDetail.lokasi }}
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Box Catatan / Instruksi Khusus (jika ada) -->
                <div
                    v-if="store.jadwalDetail.keterangan"
                    class="p-3.5 rounded-xl bg-slate-50 border border-slate-200/80 flex items-start gap-3"
                >
                    <div class="w-8 h-8 rounded-lg bg-amber-100 text-amber-800 flex items-center justify-center shrink-0 mt-0.5">
                        <i class="pi pi-info-circle text-xs" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <p class="text-[11px] font-semibold text-slate-700 m-0">
                            Catatan & Instruksi
                        </p>
                        <p class="text-xs text-slate-600 m-0 mt-0.5 leading-relaxed break-words">
                            {{ store.jadwalDetail.keterangan }}
                        </p>
                    </div>
                </div>

                <!-- Petugas Pencatat (Di paling bawah, di bawah catatan) -->
                <div class="p-3 rounded-xl bg-slate-50/70 border border-slate-200/60 flex items-center justify-between gap-3">
                    <div class="flex items-center gap-2.5 min-w-0">
                        <div class="w-7 h-7 rounded-lg bg-slate-200/80 text-slate-600 flex items-center justify-center font-bold text-xs shrink-0">
                            <i class="pi pi-user text-xs" />
                        </div>
                        <div class="min-w-0">
                            <span class="text-[10px] uppercase font-bold tracking-wider text-slate-400 block">
                                Dicatat Oleh
                            </span>
                            <span class="text-xs font-semibold text-slate-700 block truncate">
                                {{ store.jadwalDetail.dibuat_oleh || 'Kader Posyandu' }}
                            </span>
                        </div>
                    </div>
                    <span class="text-[10px] px-2 py-0.5 rounded-md font-semibold bg-slate-200/70 text-slate-600 shrink-0">
                        Kader
                    </span>
                </div>

                <!-- Footer Aksi -->
                <div class="flex justify-end pt-1">
                    <button
                        type="button"
                        class="px-5 py-2.5 rounded-xl text-xs font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer border-0"
                        @click="showDetail = false"
                    >
                        Tutup
                    </button>
                </div>
            </div>
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Dialog } from "primevue";
import PageHeader from "@/components/ui/PageHeader.vue";
import { useJadwalStore } from "@/stores/jadwalStore";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { toLocalDateStr } from "@/utils/format.js";

const store = useJadwalStore();

const todayDate = new Date();
const todayStr = toLocalDateStr(todayDate);

const activeFilter = ref("mendatang");
const showDetail = ref(false);
const copySuccess = ref(false);

const filterTabs = [
    { key: "mendatang", label: "Mendatang" },
    { key: "lewat", label: "Riwayat Lewat" },
    { key: "semua", label: "Semua" },
];

const jadwalTampil = computed(() => {
    if (activeFilter.value === "mendatang") return store.jadwalMendatang;
    if (activeFilter.value === "lewat") return store.jadwalLewat;
    return store.jadwalList;
});

const getTabCount = (key) => {
    if (key === "mendatang") return store.jadwalMendatang.length;
    if (key === "lewat") return store.jadwalLewat.length;
    return store.jadwalList.length;
};

const isLewat = (tgl) => tgl < todayStr;
const isHariIni = (tgl) => tgl === todayStr;

const sisaHari = (tgl) => {
    if (tgl === todayStr) return "Hari ini!";
    const tglDate = new Date(tgl + "T00:00:00");
    const todayD = new Date(todayStr + "T00:00:00");
    const diff = Math.round((tglDate - todayD) / (1000 * 60 * 60 * 24));
    if (diff === 1) return "Besok";
    if (diff < 0) return `${Math.abs(diff)} hari lalu`;
    return `${diff} hari lagi`;
};

const formatTanggalPanjang = (tgl) =>
    new Date(tgl + "T00:00:00").toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    });

const namaHari = (tgl) =>
    new Date(tgl + "T00:00:00").toLocaleDateString("id-ID", { weekday: "short" });

const angkaTanggal = (tgl) =>
    new Date(tgl + "T00:00:00").getDate();

const bulanSingkat = (tgl) =>
    new Date(tgl + "T00:00:00").toLocaleDateString("id-ID", { month: "short" });

const formatWaktu = (waktu) => waktu?.slice(0, 5) ?? "—";

const salinPengumuman = async (j) => {
    if (!j) return;
    const teks = `📢 *PENGUMUMAN JADWAL POSYANDU*\n\nBunda dan Ayah, berikut jadwal pelayanan Posyandu berikutnya:\n📅 *Hari / Tanggal:* ${formatTanggalPanjang(j.tanggal)}\n⏰ *Waktu:* ${formatWaktu(j.waktu_mulai)} – ${formatWaktu(j.waktu_selesai)} WIB\n📍 *Lokasi:* ${j.lokasi}\n${j.keterangan ? `📝 *Catatan:* ${j.keterangan}\n` : ''}\nYuk bawa si kecil ke posyandu untuk pemantauan tumbuh kembang optimal! 🌿`;
    try {
        await navigator.clipboard.writeText(teks);
        copySuccess.value = true;
        setTimeout(() => {
            copySuccess.value = false;
        }, 3000);
    } catch {
        // Fallback
    }
};

const lihatDetail = async (id) => {
    showDetail.value = true;
    await store.fetchDetailJadwal(id);
};

const loadPage = (page = 1) => store.fetchAllJadwal({ page });

onMounted(() => loadPage(store.pagination.page));
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.hero-card {
    background: linear-gradient(135deg, #059669 0%, #047857 50%, #064e3b 100%);
    box-shadow: 0 10px 25px -5px rgba(4, 120, 87, 0.3), 0 8px 10px -6px rgba(4, 120, 87, 0.2);
}

.hero-bg-icon {
    position: absolute;
    right: -1.5rem;
    bottom: -2rem;
    font-size: 11rem;
    color: rgba(255, 255, 255, 0.07);
    pointer-events: none;
}

.filter-scroll {
    scrollbar-width: none;
    -ms-overflow-style: none;
}
.filter-scroll::-webkit-scrollbar {
    display: none;
}


.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
    0% {
        background-position: 200% 0;
    }
    100% {
        background-position: -200% 0;
    }
}

.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.25s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-8px);
}
</style>
