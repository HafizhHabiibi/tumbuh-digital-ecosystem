<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <header>
            <p class="eyebrow">Agenda Posyandu</p>
            <h1 class="text-2xl font-bold m-0" style="color: var(--color-text-heading)">
                Jadwal Kegiatan
            </h1>
            <p class="text-sm mt-2 mb-0" style="color: var(--color-text-muted)">
                Informasi jadwal ini hanya dapat dilihat oleh Puskesmas. Perubahan dilakukan oleh Kader.
            </p>
        </header>

        <div v-if="store.error.fetchAll" class="message-error" role="alert">
            <i class="pi pi-exclamation-circle" aria-hidden="true" />
            <span>{{ store.error.fetchAll }}</span>
            <button class="retry-button" @click="loadPage(store.pagination.page)">Coba Lagi</button>
        </div>

        <section v-if="store.jadwalTerdekat" class="next-card">
            <div>
                <span class="eyebrow">Jadwal Terdekat</span>
                <h2 class="text-lg font-bold mt-1 mb-2">
                    {{ formatTanggal(store.jadwalTerdekat.tanggal) }}
                </h2>
                <p class="m-0 text-sm">
                    {{ formatWaktu(store.jadwalTerdekat.waktu_mulai) }}–{{ formatWaktu(store.jadwalTerdekat.waktu_selesai) }} WIB
                    · {{ store.jadwalTerdekat.lokasi }}
                </p>
            </div>
            <span class="next-badge">{{ sisaHari(store.jadwalTerdekat.tanggal) }}</span>
        </section>

        <div class="flex gap-2" role="tablist" aria-label="Filter jadwal">
            <button
                v-for="item in filters"
                :key="item.key"
                class="filter-button"
                :class="{ active: activeFilter === item.key }"
                role="tab"
                :aria-selected="activeFilter === item.key"
                @click="activeFilter = item.key"
            >
                {{ item.label }}
            </button>
        </div>

        <div v-if="store.loading.fetchAll" class="grid md:grid-cols-2 gap-4">
            <div v-for="item in 4" :key="item" class="skeleton h-40 rounded-2xl" />
        </div>

        <section v-else-if="jadwalTampil.length" class="grid md:grid-cols-2 gap-4">
            <article v-for="jadwal in jadwalTampil" :key="jadwal.id" class="schedule-card">
                <div class="date-box">
                    <strong>{{ new Date(`${jadwal.tanggal}T00:00:00`).getDate() }}</strong>
                    <span>{{ bulanSingkat(jadwal.tanggal) }}</span>
                </div>
                <div class="min-w-0">
                    <h2 class="text-base font-bold m-0 truncate">{{ jadwal.lokasi }}</h2>
                    <p class="meta"><i class="pi pi-clock" /> {{ formatWaktu(jadwal.waktu_mulai) }}–{{ formatWaktu(jadwal.waktu_selesai) }} WIB</p>
                    <p v-if="jadwal.keterangan" class="description">{{ jadwal.keterangan }}</p>
                    <span class="status-badge" :class="isLewat(jadwal.tanggal) ? 'past' : 'upcoming'">
                        {{ isLewat(jadwal.tanggal) ? "Selesai" : sisaHari(jadwal.tanggal) }}
                    </span>
                </div>
            </article>
        </section>

        <div v-else-if="!store.error.fetchAll" class="empty-card">
            <i class="pi pi-calendar text-4xl" aria-hidden="true" />
            <p class="m-0">Belum ada jadwal {{ activeFilter === "mendatang" ? "mendatang" : "yang sudah lewat" }} pada halaman ini.</p>
        </div>

        <PaginationControls
            :pagination="store.pagination"
            :loading="store.loading.fetchAll"
            @change-page="loadPage"
        />
    </div>
</template>

<script setup>
import { computed, onMounted, ref } from "vue";
import { useJadwalStore } from "@/stores/jadwalStore";
import PaginationControls from "@/components/ui/PaginationControls.vue";

const store = useJadwalStore();
const activeFilter = ref("mendatang");
const filters = [
    { key: "mendatang", label: "Mendatang" },
    { key: "lewat", label: "Sudah Lewat" },
];
const jadwalTampil = computed(() =>
    activeFilter.value === "mendatang" ? store.jadwalMendatang : store.jadwalLewat,
);
const now = new Date();
const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
const isLewat = (tanggal) => tanggal < today;
const formatWaktu = (waktu) => waktu?.slice(0, 5) ?? "—";
const bulanSingkat = (tanggal) =>
    new Date(`${tanggal}T00:00:00`).toLocaleDateString("id-ID", { month: "short" });
const formatTanggal = (tanggal) =>
    new Date(`${tanggal}T00:00:00`).toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    });
const sisaHari = (tanggal) => {
    if (tanggal === today) return "Hari ini";
    const selisih = Math.round(
        (new Date(`${tanggal}T00:00:00`) - new Date(`${today}T00:00:00`)) /
            86400000,
    );
    return selisih === 1 ? "Besok" : `${selisih} hari lagi`;
};
const loadPage = (page = 1) => store.fetchAllJadwal({ page });

onMounted(() => loadPage(store.pagination.page));
</script>

<style scoped>
.eyebrow { margin: 0; color: var(--color-green-700); font-size: 0.7rem; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; }
.next-card, .schedule-card, .empty-card { border: 1px solid var(--color-card-border); border-radius: 1rem; background: white; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
.next-card { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1.25rem; background: var(--color-green-50); }
.next-badge, .status-badge { width: fit-content; border-radius: 999px; padding: .3rem .65rem; font-size: .7rem; font-weight: 700; }
.next-badge, .upcoming { color: var(--color-green-700); background: var(--color-green-100); }
.past { color: #475569; background: #e2e8f0; }
.filter-button { border: 1px solid var(--color-card-border); border-radius: 999px; background: white; color: var(--color-text-body); padding: .5rem .85rem; cursor: pointer; font-size: .75rem; font-weight: 600; }
.filter-button.active { border-color: var(--color-green-700); background: var(--color-green-700); color: white; }
.schedule-card { display: grid; grid-template-columns: 4rem minmax(0,1fr); gap: 1rem; padding: 1rem; }
.date-box { display: flex; min-height: 4rem; flex-direction: column; align-items: center; justify-content: center; border-radius: .75rem; color: var(--color-green-700); background: var(--color-green-100); }
.date-box strong { font-size: 1.35rem; line-height: 1; }.date-box span { margin-top: .3rem; font-size: .65rem; font-weight: 700; text-transform: uppercase; }
.meta, .description { margin: .45rem 0; color: var(--color-text-muted); font-size: .75rem; }.description { overflow-wrap: anywhere; }
.empty-card { display: flex; min-height: 12rem; flex-direction: column; align-items: center; justify-content: center; gap: .75rem; color: var(--color-text-muted); text-align: center; }
.message-error { display: flex; align-items: center; gap: .75rem; border: 1px solid #fecaca; border-radius: .75rem; padding: .75rem 1rem; background: #fef2f2; color: #b91c1c; font-size: .75rem; }
.retry-button { margin-left: auto; border: 0; background: transparent; color: inherit; cursor: pointer; font-weight: 700; }
.skeleton { background: linear-gradient(90deg,#f0f0f0 25%,#e0e0e0 50%,#f0f0f0 75%); background-size: 200% 100%; animation: shimmer 1.5s infinite; }
@keyframes shimmer { from { background-position: 200% 0; } to { background-position: -200% 0; } }
</style>
