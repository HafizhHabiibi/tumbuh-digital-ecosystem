<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header Halaman ─────────────────────────────────────── -->
        <PageHeader title="Pemantauan" />

        <!-- ─── 3 Kartu Ringkasan Prioritas Interaktif ─────────────────── -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <!-- Prioritas Tinggi -->
            <button
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    selectedPrioritas === 'tinggi'
                        ? 'border-red-500 bg-red-50/80 ring-2 ring-red-500/20 shadow-xs'
                        : 'border-slate-100 bg-white hover:border-red-200 hover:bg-red-50/30'
                "
                @click="togglePrioritas('tinggi')"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold text-red-600 flex items-center gap-1.5"
                    >
                        <span
                            class="w-2 h-2 rounded-full bg-red-500 animate-pulse"
                        />
                        Prioritas Tinggi
                    </span>
                    <i class="pi pi-exclamation-circle text-red-500 text-sm" />
                </div>
                <div
                    class="text-2xl font-extrabold text-slate-900 tracking-tight"
                >
                    {{ countTinggi }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
                <p class="text-[11px] font-medium text-red-600/80 mt-1">
                    Perlu perhatian & rujukan segera
                </p>
            </button>

            <!-- Prioritas Sedang -->
            <button
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    selectedPrioritas === 'sedang'
                        ? 'border-amber-500 bg-amber-50/80 ring-2 ring-amber-500/20 shadow-xs'
                        : 'border-slate-100 bg-white hover:border-amber-200 hover:bg-amber-50/30'
                "
                @click="togglePrioritas('sedang')"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold text-amber-600 flex items-center gap-1.5"
                    >
                        <span class="w-2 h-2 rounded-full bg-amber-500" />
                        Prioritas Sedang
                    </span>
                    <i class="pi pi-info-circle text-amber-500 text-sm" />
                </div>
                <div
                    class="text-2xl font-extrabold text-slate-900 tracking-tight"
                >
                    {{ countSedang }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
                <p class="text-[11px] font-medium text-amber-600/80 mt-1">
                    Perhatian & pendampingan gizi
                </p>
            </button>

            <!-- Prioritas Rendah -->
            <button
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    selectedPrioritas === 'rendah'
                        ? 'border-emerald-500 bg-emerald-50/80 ring-2 ring-emerald-500/20 shadow-xs'
                        : 'border-slate-100 bg-white hover:border-emerald-200 hover:bg-emerald-50/30'
                "
                @click="togglePrioritas('rendah')"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold text-emerald-600 flex items-center gap-1.5"
                    >
                        <span class="w-2 h-2 rounded-full bg-emerald-500" />
                        Prioritas Rendah
                    </span>
                    <i class="pi pi-check-circle text-emerald-500 text-sm" />
                </div>
                <div
                    class="text-2xl font-extrabold text-slate-900 tracking-tight"
                >
                    {{ countRendah }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
                <p class="text-[11px] font-medium text-emerald-600/80 mt-1">
                    Pemantauan pertumbuhan rutin
                </p>
            </button>
        </div>

        <!-- ─── Filter & Search Bar Modern ────────────────────────────── -->
        <div
            class="card p-3.5 rounded-2xl flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between"
        >
            <!-- Search -->
            <div class="relative flex-1 max-w-md">
                <i
                    class="pi pi-search absolute left-3.5 top-1/2 -translate-y-1/2 text-sm text-slate-400"
                />
                <input
                    v-model="searchQuery"
                    type="text"
                    placeholder="Cari nama anak..."
                    class="input-field w-full pl-10 pr-9 py-2 rounded-xl text-sm"
                />
                <button
                    v-if="searchQuery"
                    type="button"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1 cursor-pointer"
                    aria-label="Hapus pencarian"
                    @click="searchQuery = ''"
                >
                    <i class="pi pi-times text-xs" />
                </button>
            </div>

            <!-- Segmented Filter Pills -->
            <div
                class="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0 custom-scrollbar"
            >
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 flex-shrink-0 cursor-pointer"
                    :class="
                        selectedPrioritas === ''
                            ? 'bg-slate-900 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-slate-200/80'
                    "
                    @click="selectedPrioritas = ''"
                >
                    Semua
                </button>
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 flex-shrink-0 cursor-pointer"
                    :class="
                        selectedPrioritas === 'tinggi'
                            ? 'bg-red-600 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-red-50 hover:text-red-700'
                    "
                    @click="selectedPrioritas = 'tinggi'"
                >
                    <span class="w-1.5 h-1.5 rounded-full bg-red-400" />
                    Tinggi
                </button>
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 flex-shrink-0 cursor-pointer"
                    :class="
                        selectedPrioritas === 'sedang'
                            ? 'bg-amber-600 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-amber-50 hover:text-amber-700'
                    "
                    @click="selectedPrioritas = 'sedang'"
                >
                    <span class="w-1.5 h-1.5 rounded-full bg-amber-400" />
                    Sedang
                </button>
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 flex-shrink-0 cursor-pointer"
                    :class="
                        selectedPrioritas === 'rendah'
                            ? 'bg-emerald-600 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-emerald-50 hover:text-emerald-700'
                    "
                    @click="selectedPrioritas = 'rendah'"
                >
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400" />
                    Rendah
                </button>
            </div>
        </div>

        <!-- ─── Tabel Perangkingan ──────────────────────────────────── -->
        <div class="card rounded-2xl overflow-hidden">
            <!-- Loading State -->
            <div v-if="pengukuranStore.loading.ranking" class="p-6 space-y-4">
                <div v-for="i in 5" :key="i" class="skeleton h-14 rounded-xl" />
            </div>

            <!-- Error State -->
            <div
                v-else-if="pengukuranStore.error.ranking"
                class="p-12 flex flex-col items-center justify-center gap-3 text-center"
            >
                <i
                    class="pi pi-exclamation-circle text-4xl text-red-600"
                    aria-hidden="true"
                />
                <p class="text-sm m-0 text-slate-500">
                    Gagal memuat data ranking: {{ pengukuranStore.error.ranking }}
                </p>
                <button
                    class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white cursor-pointer"
                    @click="loadData()"
                >
                    Coba Lagi
                </button>
            </div>

            <!-- Empty State -->
            <div
                v-else-if="filteredRanking.length === 0"
                class="p-16 flex flex-col items-center justify-center gap-3 text-center"
            >
                <i
                    class="pi pi-sort-amount-down text-4xl text-slate-400"
                    aria-hidden="true"
                />
                <p class="text-sm m-0 text-slate-500">
                    Tidak ada data perangkingan yang cocok.
                </p>
            </div>

            <!-- Table -->
            <div v-else class="overflow-x-auto">
                <table
                    class="w-full text-sm"
                    aria-label="Tabel prioritas pemantauan anak"
                >
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-100">
                            <th class="th-cell text-center w-16">Peringkat</th>
                            <th class="th-cell">Nama Anak</th>
                            <th class="th-cell hidden sm:table-cell">Jenis Kelamin</th>
                            <th class="th-cell hidden md:table-cell">Usia</th>
                            <th class="th-cell">Pengukuran Terakhir</th>
                            <th class="th-cell hidden lg:table-cell">
                                Tinggi Badan / Umur
                            </th>
                            <th class="th-cell">Prioritas</th>
                            <th class="th-cell text-right">Skor SAW</th>
                            <th class="th-cell text-center w-14">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 bg-white">
                        <tr
                            v-for="(row, index) in filteredRanking"
                            :key="row.anak_id"
                            class="hover:bg-slate-50/80 transition-colors duration-150"
                        >
                            <!-- Rank -->
                            <td class="px-4 py-3.5 text-center">
                                <span
                                    class="w-7 h-7 rounded-full flex items-center justify-center mx-auto text-xs transition-colors"
                                    :class="getRankBadgeClass(index)"
                                >
                                    {{ nomorPeringkat(index) }}
                                </span>
                            </td>

                            <!-- Nama Anak -->
                            <td class="px-4 py-3.5">
                                <div class="font-semibold text-slate-800">
                                    {{ row.nama_anak }}
                                </div>
                            </td>

                            <!-- Jenis Kelamin -->
                            <td class="px-4 py-3.5 hidden sm:table-cell">
                                <span
                                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                                    :class="
                                        row.jenis_kelamin === 'L'
                                            ? 'bg-sky-50 text-sky-700 border border-sky-200/80'
                                            : 'bg-rose-50 text-rose-700 border border-rose-200/80'
                                    "
                                >
                                    <span
                                        class="w-1.5 h-1.5 rounded-full"
                                        :class="
                                            row.jenis_kelamin === 'L'
                                                ? 'bg-sky-500'
                                                : 'bg-rose-500'
                                        "
                                    />
                                    {{
                                        row.jenis_kelamin === "L"
                                            ? "Laki-laki"
                                            : "Perempuan"
                                    }}
                                </span>
                            </td>

                            <!-- Usia -->
                            <td
                                class="px-4 py-3.5 hidden md:table-cell text-slate-600"
                            >
                                {{ hitungUsia(row.tanggal_lahir) }}
                            </td>

                            <!-- Pengukuran -->
                            <td class="px-4 py-3.5">
                                <div class="font-medium text-slate-800">
                                    {{ formatUkuran(row.berat_badan) }} kg /
                                    {{ formatUkuran(row.tinggi_badan) }} cm
                                </div>
                                <div class="text-[11px] text-slate-400">
                                    Diukur: {{ formatTanggal(row.tanggal_ukur) }}
                                </div>
                            </td>

                            <!-- Tinggi Badan Berdasarkan Umur -->
                            <td class="px-4 py-3.5 hidden lg:table-cell">
                                <StatusBadge
                                    type="antropometri"
                                    :value="row.status_tbu"
                                />
                            </td>

                            <!-- Prioritas pemantauan -->
                            <td class="px-4 py-3.5">
                                <StatusBadge
                                    type="prioritas"
                                    :value="row.prioritas_pemantauan?.kategori"
                                />
                            </td>

                            <!-- Skor SAW -->
                            <td
                                class="px-4 py-3.5 text-right font-mono font-semibold text-slate-700"
                            >
                                {{ formatSkor(row.skor_saw) }}
                            </td>

                            <!-- Aksi -->
                            <td class="px-4 py-3.5 text-center" @click.stop>
                                <button
                                    type="button"
                                    class="w-8 h-8 rounded-lg inline-flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors mx-auto cursor-pointer"
                                    title="Menu Aksi"
                                    aria-label="Menu Aksi"
                                    @click.stop="toggleMenu($event, row)"
                                >
                                    <i class="pi pi-ellipsis-v text-xs" />
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <PaginationControls
                :pagination="pengukuranStore.rankingPagination"
                :loading="pengukuranStore.loading.ranking"
                @change-page="loadData"
            />
        </div>
        <!-- ─── Action Menu Popover ────────────────────────────────── -->
        <Menu ref="actionMenu" :model="menuItems" :popup="true">
            <template #item="{ item }">
                <button
                    v-if="!item.separator"
                    type="button"
                    class="w-full flex items-center gap-2.5 px-3 py-2 text-xs font-medium rounded-lg transition-colors cursor-pointer text-left"
                    :class="
                        item.danger
                            ? 'text-red-600 hover:bg-red-50'
                            : 'text-slate-700 hover:bg-slate-100'
                    "
                    @click="handleMenuItemClick(item)"
                >
                    <i
                        :class="item.icon"
                        class="text-xs"
                        :style="item.danger ? 'color: #dc2626' : 'color: #64748b'"
                    />
                    <span>{{ item.label }}</span>
                </button>
                <div v-else class="my-1 border-t border-slate-100" />
            </template>
        </Menu>
    </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount, onMounted, watch } from "vue";
import { useRouter } from "vue-router";
import Menu from "primevue/menu";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useDashboardStore } from "@/stores/dashboardStore";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import PageHeader from "@/components/ui/PageHeader.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { formatUkuran, hitungUsia } from "@/utils/format.js";
import { debounce } from "@/utils/debounce.js";

const router = useRouter();
const pengukuranStore = usePengukuranStore();
const dashboardStore = useDashboardStore();

const searchQuery = ref("");
const selectedPrioritas = ref("");
const actionMenu = ref(null);
const selectedRow = ref(null);

const toggleMenu = (event, row) => {
    selectedRow.value = row;
    actionMenu.value.toggle(event);
};

const handleMenuItemClick = (item) => {
    actionMenu.value.hide();
    if (item.command) {
        item.command();
    }
};

const menuItems = computed(() => {
    if (!selectedRow.value) return [];
    return [
        {
            label: "Detail Anak",
            icon: "pi pi-eye",
            command: () => {
                router.push({
                    name: "KaderDetailAnak",
                    params: { id: selectedRow.value.anak_id },
                });
            },
        },
        {
            label: "Rujuk Anak",
            icon: "pi pi-send",
            command: () => {
                router.push({
                    name: "KaderRujukan",
                    query: { anakId: selectedRow.value.anak_id },
                });
            },
        },
    ];
});

/* ── Toggle Prioritas Card ───────────────────────────────────────── */
const togglePrioritas = (val) => {
    selectedPrioritas.value = selectedPrioritas.value === val ? "" : val;
};

/* ── Hitungan Ringkasan Prioritas ────────────────────────────────── */
const countTinggi = computed(() => {
    if (dashboardStore.distribusiRisiko.tinggi) {
        return dashboardStore.distribusiRisiko.tinggi;
    }
    return filteredRanking.value.filter(
        (r) => r.prioritas_pemantauan?.kategori?.toLowerCase() === "tinggi",
    ).length;
});

const countSedang = computed(() => {
    if (dashboardStore.distribusiRisiko.sedang) {
        return dashboardStore.distribusiRisiko.sedang;
    }
    return filteredRanking.value.filter(
        (r) => r.prioritas_pemantauan?.kategori?.toLowerCase() === "sedang",
    ).length;
});

const countRendah = computed(() => {
    if (dashboardStore.distribusiRisiko.rendah) {
        return dashboardStore.distribusiRisiko.rendah;
    }
    return filteredRanking.value.filter(
        (r) => r.prioritas_pemantauan?.kategori?.toLowerCase() === "rendah",
    ).length;
});

/* ── Badge Styling Peringkat ─────────────────────────────────────── */
const getRankBadgeClass = (index) => {
    const rank = nomorPeringkat(index);
    if (rank === 1) {
        return "bg-red-50 text-red-600 border border-red-200 font-extrabold shadow-2xs";
    }
    if (rank === 2) {
        return "bg-amber-50 text-amber-600 border border-amber-200 font-extrabold shadow-2xs";
    }
    if (rank === 3) {
        return "bg-blue-50 text-blue-600 border border-blue-200 font-bold shadow-2xs";
    }
    return "bg-slate-100 text-slate-600 font-medium";
};

/* ── Load data ranking anak ──────────────────────────────────────── */
const loadData = (page = pengukuranStore.rankingPagination.page) => {
    pengukuranStore.fetchRankingAnak({
        page,
        search: searchQuery.value.trim() || undefined,
        prioritas: selectedPrioritas.value || undefined,
    });
};

const filteredRanking = computed(() => pengukuranStore.rankingAnak || []);
const reloadFromFirstPage = debounce(() => loadData(1));
watch([searchQuery, selectedPrioritas], reloadFromFirstPage);

/* ── Helpers ─────────────────────────────────────────────────────── */
const formatTanggal = (tgl) => {
    if (!tgl) return "—";
    return new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });
};



const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);

const nomorPeringkat = (index) =>
    (pengukuranStore.rankingPagination.page - 1) *
        pengukuranStore.rankingPagination.limit +
    index +
    1;

onMounted(() => {
    loadData();
    dashboardStore.fetchDistribusiRisiko();
});

onBeforeUnmount(reloadFromFirstPage.cancel);
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    font-family: "Poppins", sans-serif;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}

.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #1e293b;
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
</style>
