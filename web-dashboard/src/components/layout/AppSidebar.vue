<template>
    <!-- Overlay mobile -->
    <Transition name="fade">
        <div
            v-if="open"
            class="fixed inset-0 bg-slate-900/40 backdrop-blur-xs z-40 md:hidden"
            aria-hidden="true"
            @click="$emit('close')"
        />
    </Transition>

    <!-- Sidebar panel -->
    <aside
        id="app-sidebar"
        class="sidebar-panel flex flex-col flex-shrink-0 w-64 h-dvh z-40 bg-white select-none relative"
        :class="{ 'sidebar--open': open }"
        role="navigation"
        aria-label="Navigasi utama"
    >
        <!-- Brand Header: HANYA Logo tanpa background & Teks Tumbuh -->
        <div class="flex items-center justify-between px-4 py-4 border-b border-slate-100 flex-shrink-0">
            <div class="flex items-center gap-3 min-w-0">
                <BrandingIllustration
                    image-class="h-10 w-auto object-contain flex-shrink-0"
                    aria-label="Logo Tumbuh"
                />
                <span
                    class="text-2xl font-semibold tracking-tight leading-none"
                    style="color: var(--color-green-800)"
                >
                    Tumbuh
                </span>
            </div>

            <!-- Tombol tutup drawer khusus mobile -->
            <button
                class="md:hidden w-8 h-8 flex items-center justify-center rounded-lg text-slate-500 hover:text-slate-800 hover:bg-slate-100 transition-colors border-0 bg-transparent cursor-pointer"
                aria-label="Tutup menu navigasi"
                @click="$emit('close')"
            >
                <i class="pi pi-times text-sm" />
            </button>
        </div>

        <!-- Menu Utama Terorganisir & Terkategori -->
        <nav
            class="flex-1 overflow-y-auto px-3 py-3 space-y-4 custom-scrollbar"
            aria-label="Menu navigasi aplikasi"
        >
            <div
                v-for="group in menuGroups"
                :key="group.title"
                class="space-y-1"
            >
                <!-- Label Kategori: Lebih Gelap & Tegas -->
                <p class="px-3 text-[11px] font-bold tracking-wider text-slate-600 uppercase select-none m-0 pb-1">
                    {{ group.title }}
                </p>

                <!-- Daftar Tautan Menu -->
                <ul class="flex flex-col gap-0.5 list-none m-0 p-0" role="list">
                    <li v-for="item in group.items" :key="item.name">
                        <RouterLink
                            :to="{ name: item.name }"
                            class="sidebar-nav-item flex items-center gap-3 px-3 py-2 rounded-xl text-sm font-medium transition-all duration-150 relative w-full group no-underline"
                            :class="{ 'sidebar-nav-item--active': isItemActive(item) }"
                            :aria-label="item.label"
                            :aria-current="isItemActive(item) ? 'page' : undefined"
                            @click="$emit('close')"
                        >
                            <span
                                class="w-5 h-5 flex items-center justify-center flex-shrink-0 transition-colors"
                                aria-hidden="true"
                            >
                                <i
                                    :class="[
                                        'pi text-base transition-transform duration-150 group-hover:scale-105',
                                        item.icon,
                                        isItemActive(item) ? 'text-[#005015]' : 'text-slate-600 group-hover:text-slate-900'
                                    ]"
                                />
                            </span>
                            <span class="truncate">{{ item.label }}</span>
                            <span
                                v-if="isItemActive(item)"
                                class="active-indicator ml-auto w-1.5 h-1.5 rounded-full bg-[#005015]"
                                aria-hidden="true"
                            />
                        </RouterLink>
                    </li>
                </ul>
            </div>
        </nav>

        <!-- Bagian Bawah: Informasi Pengguna (Menghubungkan ke Profil) -->
        <div class="p-3 border-t border-slate-100 bg-slate-50/60 flex-shrink-0">
            <RouterLink
                :to="{ name: profilRoute }"
                class="flex items-center gap-3 p-2.5 rounded-xl transition-all duration-150 hover:bg-white text-slate-800 no-underline group border border-transparent hover:border-slate-200/60 hover:shadow-2xs"
                :class="{ 'bg-white border-slate-200/60 shadow-2xs': isItemActive({ name: profilRoute }) }"
                aria-label="Buka profil saya"
                @click="$emit('close')"
            >
                <div class="relative flex-shrink-0">
                    <div
                        class="w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-2xs select-none"
                        style="background: linear-gradient(135deg, var(--color-green-600), var(--color-green-800));"
                    >
                        {{ userInitial }}
                    </div>
                    <span
                        class="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-2 ring-white"
                        title="Status aktif"
                        aria-hidden="true"
                    />
                </div>

                <div class="flex flex-col min-w-0 flex-1">
                    <span class="text-xs font-bold text-slate-900 truncate leading-tight group-hover:text-[#005015] transition-colors">
                        {{ userName }}
                    </span>
                    <span class="text-[11px] font-medium text-slate-600 truncate mt-0.5">
                        {{ roleFullLabel }}
                    </span>
                </div>

                <i class="pi pi-angle-right text-xs text-slate-500 group-hover:text-slate-900 group-hover:translate-x-0.5 transition-all flex-shrink-0" />
            </RouterLink>
        </div>
    </aside>
</template>

<script setup>
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useAuthStore } from "@/stores/authStore";
import BrandingIllustration from "@/components/ui/BrandingIllustration.vue";

defineProps({ open: { type: Boolean, default: false } });
defineEmits(["close"]);

const route = useRoute();
const authStore = useAuthStore();

const isKader = computed(() => authStore.isKader);
const roleFullLabel = computed(() =>
    isKader.value ? "Kader Posyandu" : "Petugas Puskesmas",
);
const userName = computed(() => authStore.namaLengkap || "Pengguna");
const userInitial = computed(() =>
    userName.value.charAt(0).toUpperCase() || "U",
);

// Definisi menu terkategori untuk Kader
const kaderMenuGroups = [
    {
        title: "Menu Utama",
        items: [
            { name: "KaderDashboard", label: "Dashboard", icon: "pi-home" },
            {
                name: "KaderRanking",
                label: "Pemantauan",
                icon: "pi-sort-amount-down-alt",
            },
        ],
    },
    {
        title: "Pelayanan & Data",
        items: [
            {
                name: "KaderAnak",
                label: "Data Anak",
                icon: "pi-heart",
                subRoutes: ["KaderDetailAnak"],
            },
            {
                name: "KaderOrangTua",
                label: "Orang Tua",
                icon: "pi-users",
                subRoutes: ["KaderDetailOrangTua"],
            },
            {
                name: "KaderPengukuran",
                label: "Pengukuran",
                icon: "pi-chart-line",
            },
            {
                name: "KaderPemberian",
                label: "Pemberian",
                icon: "pi-list",
            },
            {
                name: "KaderRujukan",
                label: "Rujukan",
                icon: "pi-send",
            },
        ],
    },
    {
        title: "Operasional",
        items: [
            {
                name: "KaderJadwal",
                label: "Jadwal",
                icon: "pi-calendar",
            },
            {
                name: "KaderLaporan",
                label: "Laporan",
                icon: "pi-file-pdf",
            },
        ],
    },
];

// Definisi menu terkategori untuk Puskesmas
const puskesmasMenuGroups = [
    {
        title: "Menu Utama",
        items: [
            { name: "PuskesmasDashboard", label: "Dashboard", icon: "pi-home" },
            {
                name: "PuskesmasRanking",
                label: "Pemantauan",
                icon: "pi-sort-amount-down-alt",
            },
        ],
    },
    {
        title: "Pelayanan Wilayah",
        items: [
            {
                name: "PuskesmasAnak",
                label: "Data Anak",
                icon: "pi-heart",
                subRoutes: ["PuskesmasDetailAnak"],
            },
            {
                name: "PuskesmasRujukan",
                label: "Rujukan",
                icon: "pi-send",
            },
        ],
    },
    {
        title: "Operasional",
        items: [
            {
                name: "PuskesmasJadwal",
                label: "Jadwal",
                icon: "pi-calendar",
            },
            {
                name: "PuskesmasLaporan",
                label: "Laporan",
                icon: "pi-file-pdf",
            },
        ],
    },
];

const menuGroups = computed(() =>
    isKader.value ? kaderMenuGroups : puskesmasMenuGroups,
);

const profilRoute = computed(() =>
    isKader.value ? "KaderProfil" : "PuskesmasProfil",
);

// Pencocokan rute aktif termasuk sub-rute (detail halaman)
const isItemActive = (item) => {
    if (route.name === item.name) return true;
    if (item.subRoutes && item.subRoutes.includes(route.name)) return true;
    return false;
};
</script>

<style scoped>
/* Desktop: sticky dalam flex row dengan pembatas bayangan seamless */
.sidebar-panel {
    border-right: 1px solid rgba(0, 0, 0, 0.06);
    box-shadow: 4px 0 20px -2px rgba(0, 0, 0, 0.05), 1px 0 4px rgba(0, 0, 0, 0.02);
}

@media (min-width: 768px) {
    .sidebar-panel {
        position: sticky;
        top: 0;
        align-self: flex-start;
    }
}

/* Mobile: fixed drawer dengan transisi halus */
@media (max-width: 767px) {
    .sidebar-panel {
        position: fixed;
        top: 0;
        left: 0;
        transform: translateX(-100%);
        transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 8px 0 28px rgba(0, 0, 0, 0.14);
    }
    .sidebar--open {
        transform: translateX(0);
    }
}

/* ── Nav Item Styling (Lebih Gelap & Kontras Tinggi) ── */
.sidebar-nav-item {
    color: #1e293b; /* slate-800 */
}
.sidebar-nav-item:hover {
    background: #f1f5f9; /* slate-100 */
    color: #020617; /* slate-950 */
}

/* ── Active State: Soft Emerald Tint & Rich Dark Forest Green ── */
.sidebar-nav-item--active,
.sidebar-nav-item.router-link-active {
    background: #eaf6ec;
    color: #005015;
    font-weight: 600;
}

/* ── Slim Custom Scrollbar ───────────────────────── */
.custom-scrollbar {
    scrollbar-width: thin;
    scrollbar-color: rgba(148, 163, 184, 0.4) transparent;
}
.custom-scrollbar::-webkit-scrollbar {
    width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
    background-color: rgba(148, 163, 184, 0.4);
    border-radius: 9999px;
}

/* ── Overlay Fade ────────────────────────────────── */
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.25s ease;
}
.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

</style>
