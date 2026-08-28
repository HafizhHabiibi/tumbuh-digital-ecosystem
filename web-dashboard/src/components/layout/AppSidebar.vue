<template>
    <!-- Overlay mobile -->
    <Transition name="fade">
        <div
            v-if="open"
            class="fixed inset-0 bg-black/40 backdrop-blur-sm z-40 md:hidden"
            aria-hidden="true"
            @click="$emit('close')"
        />
    </Transition>

    <!-- Sidebar panel -->
    <aside
        id="app-sidebar"
        class="sidebar-panel flex flex-col flex-shrink-0 w-60 h-dvh z-50 px-3 py-5"
        :class="{ 'sidebar--open': open }"
        role="navigation"
        aria-label="Navigasi utama"
    >
        <!-- Brand -->
        <div class="flex items-center gap-2.5 px-3 pb-3">
            <BrandingIllustration
                image-class="w-8 h-auto illustration--green"
                aria-label="Logo Tumbuh"
            />
            <div class="flex flex-col">
                <span
                    class="text-lg font-extrabold tracking-tight leading-none"
                    style="color: var(--color-green-700)"
                    >Tumbuh</span
                >
                <span
                    class="text-[0.6rem] uppercase tracking-widest mt-1"
                    style="color: var(--color-text-muted)"
                    >{{ roleLabel }}</span
                >
            </div>
        </div>

        <div
            class="h-px mx-2 my-1"
            style="background: var(--color-input-border)"
            aria-hidden="true"
        />

        <!-- Menu utama -->
        <nav class="mt-2" aria-label="Menu utama">
            <ul class="flex flex-col gap-0.5 list-none m-0 p-0" role="list">
                <li v-for="item in menuItems" :key="item.name">
                    <RouterLink
                        :to="{ name: item.name }"
                        class="sidebar-link flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium no-underline transition-all duration-150 relative w-full"
                        :aria-label="item.label"
                        @click="$emit('close')"
                    >
                        <span
                            class="w-5 flex items-center justify-center flex-shrink-0"
                            aria-hidden="true"
                        >
                            <i :class="`pi ${item.icon} text-base`" />
                        </span>
                        <span>{{ item.label }}</span>
                    </RouterLink>
                </li>
            </ul>
        </nav>

        <div class="flex-1" />

        <div
            class="h-px mx-2 my-1"
            style="background: var(--color-input-border)"
            aria-hidden="true"
        />

        <!-- Bottom: Profil + Logout -->
        <div class="flex flex-col gap-0.5 mt-2">
            <RouterLink
                :to="{ name: profilRoute }"
                class="sidebar-link flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium no-underline transition-all duration-150 relative w-full"
                aria-label="Profil akun saya"
                @click="$emit('close')"
            >
                <span
                    class="w-5 flex items-center justify-center flex-shrink-0"
                    aria-hidden="true"
                >
                    <i class="pi pi-user text-base" />
                </span>
                <span>Profil</span>
            </RouterLink>

            <button
                class="sidebar-link sidebar-logout flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-150 relative w-full text-left bg-transparent border-0 cursor-pointer"
                aria-label="Keluar dari aplikasi"
                @click="handleLogout"
            >
                <span
                    class="w-5 flex items-center justify-center flex-shrink-0"
                    aria-hidden="true"
                >
                    <i class="pi pi-sign-out text-base" />
                </span>
                <span>Keluar</span>
            </button>
        </div>
    </aside>
</template>

<script setup>
import { computed } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/authStore";
import BrandingIllustration from "@/components/ui/BrandingIllustration.vue";

defineProps({ open: { type: Boolean, default: false } });
defineEmits(["close"]);

const router = useRouter();
const authStore = useAuthStore();
const isKader = computed(() => authStore.isKader);
const roleLabel = computed(() =>
    isKader.value ? "Kader Posyandu" : "Puskesmas",
);

const kaderMenu = [
    { name: "KaderDashboard", label: "Dashboard", icon: "pi-home" },
    { name: "KaderRanking", label: "Prioritas SAW", icon: "pi-sort-amount-down-alt" },
    { name: "KaderAnak", label: "Data Anak", icon: "pi-heart" },
    { name: "KaderOrangTua", label: "Orang Tua", icon: "pi-users" },
    { name: "KaderPengukuran", label: "Pengukuran", icon: "pi-chart-line" },
    { name: "KaderPemberian", label: "Pemberian", icon: "pi-list" },
    { name: "KaderRujukan", label: "Rujukan", icon: "pi-send" },
    { name: "KaderJadwal", label: "Jadwal", icon: "pi-calendar" },
    { name: "KaderLaporan", label: "Laporan", icon: "pi-file-pdf" },
];
const puskesmasMenu = [
    { name: "PuskesmasDashboard", label: "Dashboard", icon: "pi-home" },
    { name: "PuskesmasRanking", label: "Prioritas SAW", icon: "pi-sort-amount-down-alt" },
    { name: "PuskesmasAnak", label: "Data Anak", icon: "pi-heart" },
    { name: "PuskesmasRujukan", label: "Rujukan", icon: "pi-send" },
    { name: "PuskesmasJadwal", label: "Jadwal", icon: "pi-calendar" },
    { name: "PuskesmasLaporan", label: "Laporan", icon: "pi-file-pdf" },
];

const menuItems = computed(() => (isKader.value ? kaderMenu : puskesmasMenu));
const profilRoute = computed(() =>
    isKader.value ? "KaderProfil" : "PuskesmasProfil",
);
const handleLogout = () => {
    authStore.logout();
    router.push({ name: "Login" });
};
</script>

<style scoped>
/* Panel putih dengan shadow */
.sidebar-panel {
    background: white;
    box-shadow: 4px 0 16px rgba(0, 0, 0, 0.06);
    border-right: 1px solid var(--color-card-border);
}

/* Desktop: sticky dalam flex row */
@media (min-width: 768px) {
    .sidebar-panel {
        position: sticky;
        top: 0;
        align-self: flex-start;
    }
}

/* Mobile: fixed, tersembunyi default */
@media (max-width: 767px) {
    .sidebar-panel {
        position: fixed;
        top: 0;
        left: 0;
        transform: translateX(-100%);
        transition: transform 0.25s ease;
    }
    .sidebar--open {
        transform: translateX(0);
    }
}

/* ─── Link default ────────────────────────────────────────────────── */
.sidebar-link {
    color: var(--color-text-body);
}
.sidebar-link:hover {
    background: var(--color-green-50);
    color: var(--color-green-700);
}

/* ─── Link aktif — hijau muda ─────────────────────────────────────── */
.sidebar-link.router-link-active {
    background: var(--color-green-100);
    color: var(--color-green-700);
    font-weight: 600;
}
.sidebar-link.router-link-active::before {
    content: "";
    position: absolute;
    left: 0;
    top: 20%;
    bottom: 20%;
    width: 3px;
    border-radius: 0 2px 2px 0;
    background: var(--color-green-700);
}

/* ─── Logout ──────────────────────────────────────────────────────── */
.sidebar-logout {
    color: #dc2626;
}
.sidebar-logout:hover {
    background: #fee2e2;
    color: #b91c1c;
}

/* Fade overlay */
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.25s;
}
.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.illustration--green {
    filter: invert(28%) sepia(64%) saturate(620%) hue-rotate(94deg)
        brightness(85%) contrast(101%);
}
</style>
