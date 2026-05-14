<template>
    <!-- Hanya tampil di mobile -->
    <header
        class="md:hidden sticky top-0 z-30 flex items-center gap-3 px-4 h-14 bg-white border-b border-[rgba(190,202,184,0.4)] shadow-sm"
        role="banner"
    >
        <!-- Hamburger -->
        <button
            class="w-9 h-9 flex items-center justify-center rounded-lg border-0 bg-transparent text-[#3f4a3c] cursor-pointer text-lg transition-colors hover:bg-[#eff6e9] hover:text-[#006e1c]"
            :aria-label="sidebarOpen ? 'Tutup menu' : 'Buka menu'"
            :aria-expanded="sidebarOpen"
            aria-controls="app-sidebar"
            @click="$emit('toggle-sidebar')"
        >
            <i
                :class="sidebarOpen ? 'pi pi-times' : 'pi pi-bars'"
                aria-hidden="true"
            />
        </button>

        <!-- Judul halaman -->
        <h1
            class="flex-1 text-[0.95rem] font-semibold text-[#171d16] m-0 truncate"
        >
            {{ pageTitle }}
        </h1>

        <!-- Avatar -->
        <div
            class="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0 select-none"
            style="
                background: linear-gradient(
                    135deg,
                    var(--color-green-600),
                    var(--color-green-800)
                );
            "
            :aria-label="`Pengguna: ${userName}`"
        >
            {{ userInitial }}
        </div>
    </header>
</template>

<script setup>
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useAuthStore } from "@/stores/authStore";

defineProps({ sidebarOpen: { type: Boolean, default: false } });
defineEmits(["toggle-sidebar"]);

const route = useRoute();
const authStore = useAuthStore();

const routeTitleMap = {
    KaderDashboard: "Dashboard",
    KaderAnak: "Data Anak",
    KaderOrangTua: "Orang Tua",
    KaderPengukuran: "Pengukuran",
    KaderPemberian: "Riwayat Pemberian",
    KaderRujukan: "Rujukan",
    KaderJadwal: "Jadwal",
    KaderProfil: "Profil",
    PuskesmasDashboard: "Dashboard",
    PuskesmasRujukan: "Rujukan",
    PuskesmasProfil: "Profil",
};

const pageTitle = computed(() => routeTitleMap[route.name] ?? "Tumbuh");
const userName = computed(() => authStore.namaLengkap ?? "Pengguna");
const userInitial = computed(() => userName.value.charAt(0).toUpperCase());
</script>
