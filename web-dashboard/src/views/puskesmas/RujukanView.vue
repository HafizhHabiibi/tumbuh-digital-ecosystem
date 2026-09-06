<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <PageHeader title="Rujukan Anak" />

        <!-- ─── Alert Notifikasi Hasil Update Status ──────────────── -->
        <Transition name="slide-down">
            <div
                v-if="rujukanStore.updateResult"
                class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200/90 text-emerald-900 shadow-2xs"
                role="status"
            >
                <div class="flex items-start gap-3">
                    <div class="w-8 h-8 rounded-xl bg-emerald-100 flex items-center justify-center text-emerald-700 shrink-0 mt-0.5">
                        <i class="pi pi-check text-sm font-bold" aria-hidden="true" />
                    </div>
                    <div>
                        <p class="text-sm font-bold text-emerald-900 m-0">Status rujukan berhasil diperbarui</p>
                        <p class="text-xs text-emerald-700 mt-1 mb-0">
                            Status pasien saat ini <strong>{{ LABEL_STATUS[rujukanStore.updateResult.status] }}</strong>.
                        </p>
                    </div>
                </div>
                <button
                    type="button"
                    class="p-1.5 text-emerald-600 hover:text-emerald-800 rounded-lg hover:bg-emerald-100/60 transition-colors cursor-pointer"
                    aria-label="Tutup pemberitahuan"
                    @click="rujukanStore.updateResult = null"
                >
                    <i class="pi pi-times text-xs" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Alert Error Fetch API ─────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="rujukanStore.error.fetchAll"
                class="flex items-center justify-between gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700 shadow-2xs"
                role="alert"
            >
                <div class="flex items-center gap-2.5">
                    <i class="pi pi-exclamation-circle text-base shrink-0" aria-hidden="true" />
                    <span>{{ rujukanStore.error.fetchAll }}</span>
                </div>
                <button
                    type="button"
                    class="text-xs font-bold underline hover:text-red-900 cursor-pointer"
                    @click="loadData()"
                >
                    Coba lagi
                </button>
            </div>
        </Transition>

        <!-- ─── 3 Kartu Ringkasan Status Rujukan (Style Daftar Anak) ── -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4" aria-label="Ringkasan status rujukan">
            <button
                v-for="stat in statCardsConfig"
                :key="stat.key"
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    filterStatus === stat.key
                        ? stat.activeClass
                        : stat.inactiveClass
                "
                :aria-pressed="filterStatus === stat.key"
                @click="handleKlikCard(stat.key)"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold flex items-center gap-1.5"
                        :class="stat.textColor"
                    >
                        <span class="w-2 h-2 rounded-full" :class="stat.dotColor" />
                        {{ stat.label }}
                    </span>
                    <i :class="[stat.icon, stat.iconColor]" class="text-sm" aria-hidden="true" />
                </div>
                <div class="text-2xl font-extrabold text-slate-900 tracking-tight">
                    {{ rujukanStore.jumlahPerStatus[stat.key] ?? 0 }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
            </button>
        </div>

        <!-- ─── Card Terpadu Antrean Rujukan & Kontrol Data ───── -->
        <section class="rounded-2xl bg-white border border-slate-200/80 shadow-2xs overflow-hidden" aria-labelledby="queue-title">
            <!-- Header Kartu: Judul, Filter Chips & Search Bar -->
            <div class="p-4 sm:p-5 space-y-3.5 border-b border-slate-100">
                <div class="flex items-center justify-between gap-3 flex-wrap">
                    <h2 id="queue-title" class="text-base font-bold text-slate-800 m-0">
                        Antrean Rujukan
                    </h2>

                    <!-- ─── Filter Chips (Diajukan, Ditangani, Selesai - Style Detail Anak) ── -->
                    <div
                        class="bg-slate-100/90 p-1 rounded-2xl flex gap-1 border border-slate-200/70 overflow-x-auto self-start sm:self-auto"
                        role="tablist"
                        aria-label="Filter status rujukan"
                    >
                        <button
                            v-for="chip in filterChips"
                            :key="chip.value"
                            type="button"
                            role="tab"
                            :aria-selected="filterStatus === chip.value"
                            class="flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer whitespace-nowrap focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-emerald-600"
                            :class="
                                filterStatus === chip.value
                                    ? 'bg-emerald-600 text-white shadow-xs'
                                    : 'text-slate-600 hover:text-slate-900 hover:bg-slate-200/60'
                            "
                            @click="handleFilterChip(chip.value)"
                        >
                            <span>{{ chip.label }}</span>
                            <span
                                class="min-w-5 px-1.5 py-0.5 rounded-full text-[10px] font-bold text-center transition-colors"
                                :class="
                                    filterStatus === chip.value
                                        ? 'bg-white/20 text-white'
                                        : 'bg-slate-200 text-slate-600'
                                "
                            >
                                {{ chip.count }}
                            </span>
                        </button>
                    </div>
                </div>

                <!-- Search Bar -->
                <div class="relative">
                    <i class="pi pi-search absolute left-3.5 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
                    <input
                        v-model="search"
                        type="search"
                        placeholder="Cari nama anak atau nama orang tua..."
                        class="w-full pl-9 pr-9 py-2.5 rounded-xl text-xs bg-slate-50/70 border border-slate-200/90 text-slate-800 placeholder-slate-400 focus:outline-none focus:bg-white focus:border-emerald-600 focus:ring-2 focus:ring-emerald-500/20 transition-all shadow-2xs"
                        aria-label="Cari rujukan"
                    />
                    <button
                        v-if="search"
                        type="button"
                        class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                        aria-label="Bersihkan pencarian"
                        @click="search = ''"
                    >
                        <i class="pi pi-times text-xs" />
                    </button>
                </div>
            </div>
                <!-- Skeleton Loading -->
                <div v-if="rujukanStore.loading.fetchAll" class="p-4 space-y-3">
                    <div v-for="i in 5" :key="i" class="skeleton h-14 rounded-xl" />
                </div>

                <!-- Empty State -->
                <div v-else-if="rujukanStore.rujukanList.length === 0" class="flex flex-col items-center py-16 gap-3 text-center px-4">
                    <div class="w-14 h-14 rounded-2xl bg-slate-100 flex items-center justify-center text-slate-400">
                        <i class="pi pi-inbox text-2xl" aria-hidden="true" />
                    </div>
                    <div>
                        <p class="text-sm font-bold text-slate-700 m-0">
                            {{ search ? "Tidak ada hasil pencarian" : `Tidak ada rujukan berstatus ${LABEL_STATUS[filterStatus] || filterStatus}` }}
                        </p>
                        <p class="text-xs text-slate-400 mt-1 mb-0">
                            {{ search ? "Coba gunakan kata kunci pencarian yang lain." : "Semua rujukan telah tertangani atau belum ada pengajuan baru." }}
                        </p>
                    </div>
                </div>

                <!-- Content Table -->
                <template v-else>
                    <p class="sm:hidden text-[11px] text-slate-400 px-4 pt-3 mb-0">
                        Geser tabel ke samping untuk melihat seluruh informasi.
                    </p>
                    <div class="overflow-x-auto">
                        <table class="w-full min-w-[1200px] text-left border-collapse" aria-label="Antrean rujukan puskesmas">
                            <thead>
                                <tr class="bg-slate-50/80 border-b border-slate-200/80">
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Nama Anak</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Jenis Kelamin</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Nama Orang Tua</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Status</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Prioritas</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Tanggal Diajukan</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Tanggal Ditangani</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Tanggal Selesai</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Kader</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider whitespace-nowrap">Puskesmas</th>
                                    <th class="px-4 py-3 text-[11px] font-bold text-slate-600 uppercase tracking-wider text-right whitespace-nowrap">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                <tr
                                    v-for="(item, index) in rujukanStore.rujukanList"
                                    :key="item.id"
                                    class="hover:bg-slate-50/70 transition-colors"
                                    :class="{ 'bg-slate-50/30': index % 2 !== 0 }"
                                >
                                    <!-- 1. Kolom Nama Anak -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <div class="flex items-center gap-2.5">
                                            <div
                                                class="w-7 h-7 rounded-xl flex items-center justify-center font-bold text-xs shrink-0 shadow-2xs"
                                                :class="item.jenis_kelamin === 'L' ? 'bg-sky-100 text-sky-700' : 'bg-rose-100 text-rose-700'"
                                                aria-hidden="true"
                                            >
                                                {{ getInitials(item.nama_anak) }}
                                            </div>
                                            <span class="font-bold text-slate-800 text-xs">
                                                {{ item.nama_anak }}
                                            </span>
                                        </div>
                                    </td>

                                    <!-- 2. Kolom Jenis Kelamin -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <span
                                            class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold"
                                            :class="
                                                item.jenis_kelamin === 'L'
                                                    ? 'bg-sky-50 text-sky-700 border border-sky-200/80'
                                                    : 'bg-rose-50 text-rose-700 border border-rose-200/80'
                                            "
                                        >
                                            <span
                                                class="w-1.5 h-1.5 rounded-full"
                                                :class="item.jenis_kelamin === 'L' ? 'bg-sky-500' : 'bg-rose-500'"
                                            />
                                            {{ item.jenis_kelamin === "L" ? "Laki-laki" : (item.jenis_kelamin === "P" ? "Perempuan" : "—") }}
                                        </span>
                                    </td>

                                    <!-- 3. Kolom Nama Orang Tua -->
                                    <td class="px-4 py-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                                        {{ item.nama_orang_tua || "—" }}
                                    </td>

                                    <!-- 4. Kolom Status Rujukan -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge type="rujukan" :value="item.status" />
                                    </td>

                                    <!-- 5. Kolom Prioritas Pemantauan -->
                                    <td class="px-4 py-3 whitespace-nowrap">
                                        <StatusBadge type="prioritas" :value="item.prioritas_pemantauan?.kategori || item.kategori_prioritas" />
                                    </td>

                                    <!-- 6. Kolom Tanggal Diajukan -->
                                    <td class="px-4 py-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                                        {{ formatTanggal(item.created_at) }}
                                    </td>

                                    <!-- 7. Kolom Tanggal Ditangani -->
                                    <td class="px-4 py-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                                        {{ item.validated_at ? formatTanggal(item.validated_at) : "—" }}
                                    </td>

                                    <!-- 8. Kolom Tanggal Selesai -->
                                    <td class="px-4 py-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                                        {{ item.completed_at ? formatTanggal(item.completed_at) : "—" }}
                                    </td>

                                    <!-- 9. Kolom Kader -->
                                    <td class="px-4 py-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                                        {{ item.nama_kader || "—" }}
                                    </td>

                                    <!-- 10. Kolom Puskesmas -->
                                    <td class="px-4 py-3 whitespace-nowrap text-xs text-slate-600 font-medium">
                                        {{ item.ditangani_oleh || "—" }}
                                    </td>

                                    <!-- 11. Kolom Detail / Aksi -->
                                    <td class="px-4 py-3 text-right whitespace-nowrap">
                                        <div class="flex items-center justify-end gap-2">
                                            <button
                                                type="button"
                                                class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer inline-flex items-center gap-1.5"
                                                @click="lihatDetail(item.id)"
                                            >
                                                <i class="pi pi-eye text-xs" aria-hidden="true" />
                                                <span>Detail</span>
                                            </button>
                                            <button
                                                v-if="rujukanStore.bisaDiupdate(item.status)"
                                                type="button"
                                                class="px-3 py-1.5 rounded-lg text-xs font-semibold text-white transition-colors cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                                                :class="item.status === 'diajukan' ? 'bg-blue-600 hover:bg-blue-700' : 'bg-emerald-600 hover:bg-emerald-700'"
                                                @click="bukaUpdateStatus(item)"
                                            >
                                                <i :class="item.status === 'diajukan' ? 'pi pi-play text-xs' : 'pi pi-check-circle text-xs'" aria-hidden="true" />
                                                <span>{{ item.status === "diajukan" ? "Mulai Tangani" : "Selesaikan" }}</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="p-3 border-t border-slate-100">
                        <PaginationControls
                            :pagination="rujukanStore.pagination"
                            :loading="rujukanStore.loading.fetchAll"
                            @change-page="changePage"
                        />
                    </div>
                </template>
        </section>

        <!-- ─── Dialog Detail Rujukan ────────────────────────────── -->
        <Dialog
            v-model:visible="showDetail"
            modal
            header="Detail Rujukan"
            :style="{ width: '640px', maxWidth: '95vw' }"
            :pt="{
                header: { class: '!pb-3 !border-b !border-slate-100' },
            }"
        >
            <div v-if="rujukanStore.loading.fetchDetail" class="p-4 space-y-3">
                <div v-for="i in 5" :key="i" class="skeleton h-12 rounded-xl" />
            </div>
            <div
                v-else-if="rujukanStore.error.fetchDetail"
                class="p-4 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm"
                role="alert"
            >
                {{ rujukanStore.error.fetchDetail }}
            </div>
            <RujukanDetailCard
                v-else-if="rujukanStore.rujukanDetail"
                :rujukan="rujukanStore.rujukanDetail"
                @close="showDetail = false"
            />
        </Dialog>

        <!-- ─── Dialog Form Update Status ────────────────────────── -->
        <Dialog
            v-model:visible="showUpdateStatus"
            modal
            :closable="!rujukanStore.loading.updateStatus"
            :header="updateDialogTitle"
            :style="{ width: '480px', maxWidth: '95vw' }"
            :pt="{
                header: { class: '!pb-3 !border-b !border-slate-100' },
            }"
        >
            <FormUpdateStatus
                v-if="rujukanDipilih"
                :rujukan="rujukanDipilih"
                :loading="rujukanStore.loading.updateStatus"
                :error="rujukanStore.error.updateStatus"
                @submit="handleUpdateStatus"
                @cancel="closeUpdateStatus"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { Dialog } from "primevue";
import PageHeader from "@/components/ui/PageHeader.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import FormUpdateStatus from "@/components/forms/FormUpdateStatus.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { useRujukanStore, LABEL_STATUS } from "@/stores/rujukanStore";
import { formatTanggal } from "@/utils/format.js";
import { debounce } from "@/utils/debounce.js";

const rujukanStore = useRujukanStore();
const search = ref("");
const filterStatus = ref("diajukan");
const showDetail = ref(false);
const showUpdateStatus = ref(false);
const rujukanDipilih = ref(null);

const filterChips = computed(() => [
    {
        value: "diajukan",
        label: "Diajukan",
        count: rujukanStore.summary.diajukan ?? 0,
    },
    {
        value: "ditangani",
        label: "Ditangani",
        count: rujukanStore.summary.ditangani ?? 0,
    },
    {
        value: "selesai",
        label: "Selesai",
        count: rujukanStore.summary.selesai ?? 0,
    },
]);

const statCardsConfig = [
    {
        key: "diajukan",
        label: "Diajukan",
        dotColor: "bg-blue-500",
        textColor: "text-blue-700",
        icon: "pi pi-inbox",
        iconColor: "text-blue-600",
        activeClass: "border-blue-500 bg-blue-50/70 ring-2 ring-blue-500/20 shadow-xs",
        inactiveClass: "border-slate-200/80 bg-white hover:border-blue-200 hover:bg-blue-50/30",
    },
    {
        key: "ditangani",
        label: "Ditangani",
        dotColor: "bg-amber-500",
        textColor: "text-amber-700",
        icon: "pi pi-sync",
        iconColor: "text-amber-600",
        activeClass: "border-amber-500 bg-amber-50/70 ring-2 ring-amber-500/20 shadow-xs",
        inactiveClass: "border-slate-200/80 bg-white hover:border-amber-200 hover:bg-amber-50/30",
    },
    {
        key: "selesai",
        label: "Selesai",
        dotColor: "bg-emerald-500",
        textColor: "text-emerald-700",
        icon: "pi pi-check-circle",
        iconColor: "text-emerald-600",
        activeClass: "border-emerald-500 bg-emerald-50/70 ring-2 ring-emerald-500/20 shadow-xs",
        inactiveClass: "border-slate-200/80 bg-white hover:border-emerald-200 hover:bg-emerald-50/30",
    },
];

const selectedStatus = computed(() => {
    return filterStatus.value;
});

const updateDialogTitle = computed(() => {
    if (rujukanDipilih.value?.status === "diajukan") {
        return "Mulai Tangani Rujukan";
    }
    return "Selesaikan Rujukan";
});

const loadData = (page = rujukanStore.pagination.page) => {
    return rujukanStore.fetchAllRujukan({
        page,
        search: search.value.trim() || undefined,
        status: selectedStatus.value,
    });
};

const reloadFromFirstPage = debounce(() => loadData(1));
watch([search, filterStatus], reloadFromFirstPage);

const lihatDetail = async (id) => {
    showDetail.value = true;
    await rujukanStore.fetchDetailRujukan(id);
};

const bukaUpdateStatus = (item) => {
    rujukanDipilih.value = item;
    rujukanStore.error.updateStatus = null;
    rujukanStore.updateResult = null;
    showUpdateStatus.value = true;
};

const closeUpdateStatus = () => {
    showUpdateStatus.value = false;
    rujukanDipilih.value = null;
};

const handleUpdateStatus = async (payload) => {
    if (!rujukanDipilih.value || rujukanStore.loading.updateStatus) return;
    const ok = await rujukanStore.updateStatusRujukan(rujukanDipilih.value.id, payload);
    if (ok) {
        closeUpdateStatus();
        await loadData();
    }
};

const handleKlikCard = (key) => {
    filterStatus.value = key;
};

const handleFilterChip = (val) => {
    filterStatus.value = val;
};

const changePage = (page) => loadData(page);


const getInitials = (name) => {
    if (!name) return "A";
    return name
        .split(" ")
        .map((part) => part[0])
        .filter(Boolean)
        .slice(0, 2)
        .join("")
        .toUpperCase();
};

onMounted(() => loadData());
onBeforeUnmount(reloadFromFirstPage.cancel);
</script>

<style scoped>
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
