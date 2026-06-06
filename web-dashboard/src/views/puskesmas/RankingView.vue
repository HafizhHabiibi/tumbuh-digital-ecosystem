<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header Halaman ─────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Prioritas Intervensi (SAW)
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Daftar prioritas penanganan stunting balita di wilayah kerja Puskesmas menggunakan metode Simple Additive Weighting (SAW)
                </p>
            </div>
        </div>

        <!-- ─── Filter & Search ─────────────────────────────────────── -->
        <div class="card p-4 rounded-2xl flex flex-col md:flex-row gap-4 items-center justify-between">
            <!-- Search -->
            <div class="relative w-full md:w-80">
                <i
                    class="pi pi-search absolute left-3 top-1/2 -translate-y-1/2 text-sm"
                    style="color: var(--color-text-muted)"
                />
                <input
                    v-model="searchQuery"
                    type="text"
                    placeholder="Cari nama anak..."
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                />
            </div>

            <!-- Filter Risiko -->
            <div class="flex items-center gap-3 w-full md:w-auto">
                <label
                    for="filter-risiko"
                    class="text-sm font-semibold flex-shrink-0"
                    style="color: var(--color-text-body)"
                >
                    Risiko SAW:
                </label>
                <div class="relative flex-1 md:w-48">
                    <select
                        id="filter-risiko"
                        v-model="selectedRisiko"
                        class="input-field w-full px-4 py-2.5 rounded-xl text-sm appearance-none"
                    >
                        <option value="">Semua Risiko</option>
                        <option value="tinggi">Tinggi</option>
                        <option value="sedang">Sedang</option>
                        <option value="rendah">Rendah</option>
                    </select>
                    <i
                        class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                </div>
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
                    class="pi pi-exclamation-circle text-4xl"
                    style="color: #dc2626"
                    aria-hidden="true"
                />
                <p class="text-sm m-0" style="color: var(--color-text-muted)">
                    Gagal memuat data ranking: {{ pengukuranStore.error.ranking }}
                </p>
                <button
                    class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                    @click="loadData"
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
                    class="pi pi-sort-amount-down text-4xl"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
                <p class="text-sm m-0" style="color: var(--color-text-muted)">
                    Tidak ada data perangkingan yang cocok.
                </p>
            </div>

            <!-- Table -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Tabel Perangkingan SAW Puskesmas">
                    <thead>
                        <tr
                            style="
                                background: var(--color-green-50);
                                border-bottom: 1px solid var(--color-input-border);
                            "
                        >
                            <th class="th-cell text-center w-16">Peringkat</th>
                            <th class="th-cell">Nama Balita</th>
                            <th class="th-cell hidden sm:table-cell">Gender</th>
                            <th class="th-cell hidden md:table-cell">Usia</th>
                            <th class="th-cell">Pengukuran Terakhir</th>
                            <th class="th-cell hidden lg:table-cell">Status Gizi</th>
                            <th class="th-cell">Risiko SAW</th>
                            <th class="th-cell text-right">Skor SAW</th>
                            <th class="th-cell text-center w-40">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(row, index) in filteredRanking"
                            :key="row.anak_id"
                            class="table-row"
                            :style="
                                index % 2 !== 0
                                    ? 'background: var(--color-green-50)'
                                    : ''
                            "
                        >
                            <!-- Rank -->
                            <td class="px-4 py-3 text-center font-bold">
                                <span
                                    class="w-7 h-7 rounded-full flex items-center justify-center mx-auto text-xs bg-slate-100 text-slate-600"
                                >
                                    {{ index + 1 }}
                                </span>
                            </td>

                            <!-- Nama Balita -->
                            <td class="px-4 py-3">
                                <div class="font-semibold text-slate-800">
                                    {{ row.nama_anak }}
                                </div>
                                <div class="text-xs text-slate-500">
                                    Ortu: {{ row.nama_orang_tua }}
                                </div>
                            </td>

                            <!-- Gender -->
                            <td class="px-4 py-3 hidden sm:table-cell">
                                <StatusBadge type="jk" :value="row.jenis_kelamin" />
                            </td>

                            <!-- Usia -->
                            <td class="px-4 py-3 hidden md:table-cell text-slate-600">
                                {{ hitungUsia(row.tanggal_lahir) }}
                            </td>

                            <!-- Pengukuran -->
                            <td class="px-4 py-3">
                                <div class="font-medium text-slate-800">
                                    {{ row.berat_badan }} kg / {{ row.tinggi_badan }} cm
                                </div>
                                <div class="text-[10px] text-slate-500">
                                    Diukur: {{ formatTanggal(row.tanggal_ukur) }}
                                </div>
                            </td>

                            <!-- Status Gizi -->
                            <td class="px-4 py-3 hidden lg:table-cell">
                                <StatusBadge type="gizi" :value="row.status_gizi" />
                            </td>

                            <!-- Risiko SAW -->
                            <td class="px-4 py-3">
                                <StatusBadge type="risiko" :value="row.kategori_risiko" />
                            </td>

                            <!-- Skor SAW -->
                            <td class="px-4 py-3 text-right font-mono font-semibold text-slate-700">
                                {{ row.skor_akhir.toFixed(4) }}
                            </td>

                            <!-- Aksi -->
                            <td class="px-4 py-3 text-center">
                                <button
                                    class="flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-xs font-semibold text-white transition-colors mx-auto"
                                    style="background: var(--color-green-700)"
                                    @click="router.push({ name: 'PuskesmasRujukan' })"
                                >
                                    <i class="pi pi-send text-[10px]" />
                                    <span>Rujukan</span>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import StatusBadge from "@/components/ui/StatusBadge.vue";

const router = useRouter();
const pengukuranStore = usePengukuranStore();

const searchQuery = ref("");
const selectedRisiko = ref("");

/* ── Load data ranking balita ────────────────────────────────────── */
const loadData = () => {
    pengukuranStore.fetchRankingAnak();
};

/* ── Filter & Search logic ────────────────────────────────────────── */
const filteredRanking = computed(() => {
    let list = pengukuranStore.rankingAnak || [];

    // Filter by search query
    if (searchQuery.value.trim()) {
        const query = searchQuery.value.toLowerCase().trim();
        list = list.filter(
            (item) =>
                item.nama_anak.toLowerCase().includes(query) ||
                item.nama_orang_tua.toLowerCase().includes(query),
        );
    }

    // Filter by risk category
    if (selectedRisiko.value) {
        list = list.filter((item) => item.kategori_risiko === selectedRisiko.value);
    }

    return list;
});

/* ── Helpers ─────────────────────────────────────────────────────── */
const formatTanggal = (tgl) => {
    if (!tgl) return "—";
    return new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });
};

const hitungUsia = (tgl) => {
    if (!tgl) return "—";
    const bulan = Math.floor(
        (new Date() - new Date(tgl)) / (1000 * 60 * 60 * 24 * 30.44),
    );
    if (bulan < 24) return `${bulan} bulan`;
    return `${Math.floor(bulan / 12)} thn ${bulan % 12} bln`;
};

onMounted(() => {
    loadData();
});
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

.btn-refresh {
    background: white;
    color: var(--color-text-body);
    border-color: var(--color-input-border);
}
.btn-refresh:hover:not(:disabled) {
    background: var(--color-green-50);
    border-color: var(--color-green-700);
    color: var(--color-green-700);
}

.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--color-text-muted);
}

.table-row:hover {
    background: var(--color-green-50) !important;
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
