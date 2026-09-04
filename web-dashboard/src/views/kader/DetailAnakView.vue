<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Header & Back Navigation ─────────────────────────── -->
        <div class="flex items-center justify-between gap-4 flex-wrap">
            <button
                type="button"
                class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 hover:text-slate-900 transition-all shadow-2xs cursor-pointer"
                @click="router.back()"
            >
                <i class="pi pi-arrow-left text-xs text-slate-400" />
                <span>Kembali ke Data Anak</span>
            </button>
            <div class="text-xs text-slate-400 font-medium">
                Rekam Medis & Tumbuh Kembang Balita
            </div>
        </div>

        <!-- ─── Loading State ────────────────────────────────────── -->
        <div v-if="kaderStore.loading.anakDetail" class="space-y-4">
            <div class="skeleton h-36 rounded-2xl" />
            <div class="skeleton h-20 rounded-2xl" />
            <div class="skeleton h-12 rounded-xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <!-- ─── Error State ──────────────────────────────────────── -->
        <div
            v-else-if="kaderStore.error.anakDetail"
            class="bg-white p-8 rounded-2xl border border-red-100 flex flex-col items-center gap-3 text-center shadow-xs"
        >
            <i class="pi pi-exclamation-circle text-4xl text-red-600" aria-hidden="true" />
            <p class="text-sm m-0 text-slate-500">
                {{ kaderStore.error.anakDetail }}
            </p>
            <button
                class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white cursor-pointer"
                @click="fetchData"
            >
                Coba Lagi
            </button>
        </div>

        <template v-else-if="kaderStore.anakDetail">
            <!-- ─── 1. Hero Card Info Anak ───────────────────────── -->
            <AnakCard
                :anak="kaderStore.anakDetail"
                :status-tbu-terakhir="pengukuranStore.pengukuranTerakhir?.status_tbu"
            >
                <template #actions>
                    <button
                        type="button"
                        class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-xs cursor-pointer"
                        title="Catat Pengukuran Baru untuk Balita Ini"
                        @click="catatPengukuranBaru"
                    >
                        <i class="pi pi-plus text-xs" />
                        <span>Catat Pengukuran</span>
                    </button>
                </template>
            </AnakCard>

            <!-- ─── 2. Vital Stats Row (Ringkasan Terakhir) ──────── -->
            <div
                v-if="pengukuranStore.pengukuranTerakhir"
                class="grid grid-cols-2 lg:grid-cols-4 gap-3.5"
            >
                <!-- Berat Badan -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-chart-bar text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400">Berat Badan</div>
                        <div class="text-base font-bold text-slate-800 tracking-tight">
                            {{ formatUkuran(pengukuranStore.pengukuranTerakhir.berat_badan) }}
                            <span class="text-xs font-normal text-slate-400">kg</span>
                        </div>
                    </div>
                </div>

                <!-- Tinggi Badan -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-sky-50 text-sky-600 border border-sky-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-arrows-v text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400">Tinggi Badan</div>
                        <div class="text-base font-bold text-slate-800 tracking-tight">
                            {{ formatUkuran(pengukuranStore.pengukuranTerakhir.tinggi_badan) }}
                            <span class="text-xs font-normal text-slate-400">cm</span>
                        </div>
                    </div>
                </div>

                <!-- Tinggi Badan / Umur -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 border border-amber-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-heart text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400 mb-0.5">Tinggi Badan / Umur</div>
                        <StatusBadge
                            type="antropometri"
                            :value="pengukuranStore.pengukuranTerakhir.status_tbu"
                        />
                    </div>
                </div>

                <!-- Prioritas Pemantauan -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 border border-rose-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-exclamation-circle text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400 mb-0.5">Prioritas Pemantauan</div>
                        <StatusBadge
                            type="prioritas"
                            :value="pengukuranStore.pengukuranTerakhir.prioritas_pemantauan?.kategori"
                        />
                    </div>
                </div>
            </div>

            <!-- ─── 3. Modern Segmented Tabs ─────────────────────── -->
            <div
                class="bg-slate-100/90 p-1 rounded-2xl flex gap-1 border border-slate-200/70 overflow-x-auto w-fit max-w-full"
            >
                <button
                    v-for="tab in tabs"
                    :key="tab.key"
                    type="button"
                    class="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer whitespace-nowrap"
                    :class="
                        activeTab === tab.key
                            ? 'bg-white text-emerald-800 shadow-xs'
                            : 'text-slate-600 hover:text-slate-900 hover:bg-slate-200/50'
                    "
                    :aria-pressed="activeTab === tab.key"
                    @click="activeTab = tab.key"
                >
                    <i :class="`pi ${tab.icon} text-xs`" aria-hidden="true" />
                    <span>{{ tab.label }}</span>
                    <!-- Badge count -->
                    <span
                        v-if="tab.count !== undefined"
                        class="px-1.5 py-0.5 rounded-full text-[10px] font-bold"
                        :class="
                            activeTab === tab.key
                                ? 'bg-emerald-100 text-emerald-700'
                                : 'bg-slate-200 text-slate-600'
                        "
                    >
                        {{ tab.count }}
                    </span>
                </button>
            </div>

            <!-- ══ TAB 1: Pengukuran & Pertumbuhan ══════════════════ -->
            <div v-show="activeTab === 'pengukuran'" class="space-y-5">
                <!-- Grid Chart: KMS & Tinggi Badan -->
                <div
                    v-if="pengukuranStore.trenPertumbuhan.length > 0"
                    class="grid grid-cols-1 lg:grid-cols-2 gap-5"
                >
                    <!-- Grafik KMS (Berat Badan menurut Umur) -->
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="text-sm font-semibold text-slate-800 m-0 flex items-center gap-2">
                                <i class="pi pi-chart-line text-emerald-600" aria-hidden="true" />
                                <span>Kurva Pertumbuhan KMS (BB/U)</span>
                            </h3>
                        </div>
                        <KMSChart
                            :jenis-kelamin="kaderStore.anakDetail.jenis_kelamin"
                            :tanggal-lahir="kaderStore.anakDetail.tanggal_lahir"
                            :riwayat-pengukuran="pengukuranStore.riwayat.list"
                        />
                    </div>

                    <!-- Tren Tinggi Badan -->
                    <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="text-sm font-semibold text-slate-800 m-0 flex items-center gap-2">
                                <i class="pi pi-chart-line text-sky-600" aria-hidden="true" />
                                <span>Tren Tinggi Badan (cm)</span>
                            </h3>
                        </div>
                        <apexchart
                            type="line"
                            height="320"
                            :options="heightChartOptions"
                            :series="heightChartSeries"
                        />
                    </div>
                </div>

                <!-- Tabel riwayat pengukuran -->
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-slate-100">
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">
                                Riwayat Pengukuran
                            </h3>
                            <p class="text-xs text-slate-400 mt-0.5 mb-0">
                                Data hasil pengukuran diurutkan dari yang terbaru
                            </p>
                        </div>
                        <span
                            class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                        >
                            {{ pengukuranStore.riwayat.list.length }} data
                        </span>
                    </div>

                    <div
                        v-if="pengukuranStore.loading.riwayat"
                        class="p-4 space-y-3"
                    >
                        <div
                            v-for="i in 3"
                            :key="i"
                            class="skeleton h-12 rounded-xl"
                        />
                    </div>

                    <div
                        v-else-if="pengukuranStore.riwayat.list.length === 0"
                        class="flex flex-col items-center py-12 gap-2 text-center"
                    >
                        <i class="pi pi-chart-bar text-3xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada riwayat pengukuran untuk balita ini
                        </p>
                        <button
                            type="button"
                            class="mt-2 text-xs font-semibold text-emerald-700 hover:underline cursor-pointer"
                            @click="catatPengukuranBaru"
                        >
                            + Catat Pengukuran Pertama
                        </button>
                    </div>

                    <div v-else class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">BB (kg)</th>
                                    <th class="th-cell">TB (cm)</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Status Antropometri
                                    </th>
                                    <th class="th-cell hidden md:table-cell">
                                        Prioritas
                                    </th>
                                    <th class="th-cell hidden lg:table-cell text-right">
                                        Skor SAW
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="p in pengukuranStore.riwayat.list"
                                    :key="p.id"
                                    class="hover:bg-slate-50/80 transition-colors"
                                >
                                    <td class="px-4 py-3.5 text-sm text-slate-700 whitespace-nowrap font-medium">
                                        {{ formatTanggal(p.tanggal_ukur) }}
                                    </td>
                                    <td class="px-4 py-3.5 font-semibold text-slate-800">
                                        {{ formatUkuran(p.berat_badan) }}
                                    </td>
                                    <td class="px-4 py-3.5 font-semibold text-slate-800">
                                        {{ formatUkuran(p.tinggi_badan) }}
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell">
                                        <div class="grid grid-cols-2 gap-x-3 gap-y-1 text-xs">
                                            <span
                                                v-for="item in statusAntropometri(p)"
                                                :key="item.label"
                                                class="text-slate-600"
                                                :title="formatStatusAntropometri(item.value)"
                                            >
                                                <span class="font-semibold text-slate-500">{{ item.label }}:</span>
                                                {{ formatStatusAntropometri(item.value) }}
                                            </span>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell">
                                        <StatusBadge
                                            type="prioritas"
                                            :value="p.prioritas_pemantauan?.kategori"
                                        />
                                    </td>
                                    <td
                                        class="px-4 py-3.5 hidden lg:table-cell font-mono text-xs text-right font-semibold text-slate-700"
                                    >
                                        {{ formatSkor(p.skor_saw) }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ TAB 2: Pemberian PMT & Vitamin ═══════════════════ -->
            <div v-show="activeTab === 'pemberian'" class="space-y-4">
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-slate-100">
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">
                                Riwayat Pemberian PMT & Vitamin
                            </h3>
                            <p class="text-xs text-slate-400 mt-0.5 mb-0">
                                Daftar asupan vitamin dan makanan tambahan yang telah dicatat
                            </p>
                        </div>
                        <span
                            class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                        >
                            {{ pemberianStore.riwayat.list.length }} data
                        </span>
                    </div>

                    <div
                        v-if="pemberianStore.loading.riwayat"
                        class="p-4 space-y-3"
                    >
                        <div
                            v-for="i in 3"
                            :key="i"
                            class="skeleton h-12 rounded-xl"
                        />
                    </div>

                    <div
                        v-else-if="pemberianStore.riwayat.list.length === 0"
                        class="flex flex-col items-center py-12 gap-2 text-center"
                    >
                        <i class="pi pi-inbox text-3xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada riwayat pemberian PMT atau vitamin untuk balita ini
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">Jenis Pemberian</th>
                                    <th class="th-cell">Dosis</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Dicatat Oleh
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="item in pemberianStore.riwayat.list"
                                    :key="item.id"
                                    class="hover:bg-slate-50/80 transition-colors"
                                >
                                    <td class="px-4 py-3.5 text-sm text-slate-700 whitespace-nowrap font-medium">
                                        {{ formatTanggal(item.tanggal_pemberian) }}
                                    </td>
                                    <td class="px-4 py-3.5">
                                        <StatusBadge
                                            :label="
                                                LABEL_JENIS[item.jenis] ?? item.jenis
                                            "
                                            :variant="
                                                variantJenis[item.jenis] ?? 'gray'
                                            "
                                        />
                                    </td>
                                    <td class="px-4 py-3.5 font-medium text-slate-800">
                                        {{ item.dosis ?? "—" }}
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell text-sm text-slate-500">
                                        {{ item.dicatat_oleh }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ TAB 3: Riwayat Rujukan ═══════════════════════════ -->
            <div v-show="activeTab === 'rujukan'" class="space-y-4">
                <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-slate-100">
                        <div>
                            <h3 class="text-sm font-bold text-slate-800 m-0">
                                Riwayat Rujukan
                            </h3>
                            <p class="text-xs text-slate-400 mt-0.5 mb-0">
                                Rekam jejak rujukan balita ke fasilitas pelayanan kesehatan
                            </p>
                        </div>
                        <span
                            class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                        >
                            {{ rujukanStore.riwayatAnak.list.length }} data
                        </span>
                    </div>

                    <div
                        v-if="rujukanStore.loading.fetchByAnak"
                        class="p-4 space-y-3"
                    >
                        <div
                            v-for="i in 3"
                            :key="i"
                            class="skeleton h-12 rounded-xl"
                        />
                    </div>

                    <div
                        v-else-if="rujukanStore.riwayatAnak.list.length === 0"
                        class="flex flex-col items-center py-12 gap-2 text-center"
                    >
                        <i class="pi pi-send text-3xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada riwayat rujukan untuk balita ini
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">Status</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Prioritas
                                    </th>
                                    <th class="th-cell hidden md:table-cell">
                                        Ditangani Oleh
                                    </th>
                                    <th class="th-cell text-center w-24">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="r in rujukanStore.riwayatAnak.list"
                                    :key="r.id"
                                    class="hover:bg-slate-50/80 transition-colors"
                                >
                                    <td class="px-4 py-3.5 text-sm text-slate-700 whitespace-nowrap font-medium">
                                        {{ formatTanggal(r.created_at) }}
                                    </td>
                                    <td class="px-4 py-3.5">
                                        <StatusBadge
                                            type="rujukan"
                                            :value="r.status"
                                        />
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell">
                                        <StatusBadge
                                            type="prioritas"
                                            :value="r.prioritas_pemantauan?.kategori"
                                        />
                                    </td>
                                    <td class="px-4 py-3.5 hidden md:table-cell text-sm text-slate-500">
                                        {{ r.ditangani_oleh ?? "—" }}
                                    </td>
                                    <td class="px-4 py-3.5 text-center">
                                        <button
                                            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 transition-colors cursor-pointer"
                                            @click="lihatDetailRujukan(r.id)"
                                        >
                                            <i class="pi pi-eye text-xs" aria-hidden="true" />
                                            Detail
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </template>

        <!-- ─── Dialog Detail Rujukan ────────────────────────────── -->
        <Dialog
            v-model:visible="showDetailRujukan"
            modal
            header="Detail Rujukan"
            :style="{ width: '520px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <div v-if="rujukanStore.loading.fetchDetail" class="p-4 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-10 rounded-xl" />
            </div>
            <RujukanDetailCard
                v-else-if="rujukanStore.rujukanDetail"
                :rujukan="rujukanStore.rujukanDetail"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Dialog } from "primevue";
import { useKaderStore } from "@/stores/kaderStore";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { usePemberianStore, LABEL_JENIS } from "@/stores/pemberianStore";
import { useRujukanStore } from "@/stores/rujukanStore";
import { formatStatusAntropometri } from "@/utils/antropometri";
import { formatUkuran } from "@/utils/format.js";

import AnakCard from "@/components/cards/AnakCard.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import KMSChart from "@/components/charts/KMSChart.vue";

const route = useRoute();
const router = useRouter();
const kaderStore = useKaderStore();
const pengukuranStore = usePengukuranStore();
const pemberianStore = usePemberianStore();
const rujukanStore = useRujukanStore();

const anakId = route.params.id;
const activeTab = ref("pengukuran");
const showDetailRujukan = ref(false);

/* ── Navigasi Catat Pengukuran Baru ──────────────────────────────── */
const catatPengukuranBaru = () => {
    router.push({
        name: "KaderPengukuran",
        query: { anakId: kaderStore.anakDetail?.id || anakId },
    });
};

/* ── Tabs ────────────────────────────────────────────────────────── */
const tabs = computed(() => [
    {
        key: "pengukuran",
        label: "Pengukuran & Pertumbuhan",
        icon: "pi-chart-line",
        count: pengukuranStore.riwayat.list.length,
    },
    {
        key: "pemberian",
        label: "Pemberian PMT & Vitamin",
        icon: "pi-shield",
        count: pemberianStore.riwayat.list.length,
    },
    {
        key: "rujukan",
        label: "Riwayat Rujukan",
        icon: "pi-send",
        count: rujukanStore.riwayatAnak.list.length,
    },
]);

/* ── Chart tren tinggi badan ──────────────────────────────────────── */
const heightChartSeries = computed(() => [
    {
        name: "Tinggi Badan (cm)",
        data: pengukuranStore.trenPertumbuhan.map((p) => p.tinggi_badan),
    },
]);

const heightChartOptions = computed(() => ({
    chart: {
        type: "line",
        fontFamily: "Poppins, sans-serif",
        toolbar: {
            show: true,
            tools: {
                download: true,
                selection: false,
                zoom: true,
                zoomin: true,
                zoomout: true,
                pan: false,
                reset: true,
            },
        },
        zoom: { enabled: true },
    },
    colors: ["#0284c7"],
    stroke: { curve: "smooth", width: 3 },
    markers: {
        size: 5,
        colors: ["#ffffff"],
        strokeColors: ["#0284c7"],
        strokeWidth: 2,
    },
    xaxis: {
        categories: pengukuranStore.trenPertumbuhan.map((p) =>
            new Date(p.tanggal).toLocaleDateString("id-ID", {
                day: "numeric",
                month: "short",
            }),
        ),
        labels: {
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "11px",
                colors: "#64748b",
            },
        },
        axisBorder: { show: false },
        axisTicks: { show: false },
    },
    yaxis: {
        labels: {
            formatter: (val) => `${val} cm`,
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "11px",
                colors: "#64748b",
            },
        },
    },
    grid: { borderColor: "#f1f5f9", strokeDashArray: 4 },
    tooltip: {
        style: { fontFamily: "Poppins, sans-serif", fontSize: "12px" },
    },
}));

/* ── Warna badge jenis pemberian ─────────────────────────────────── */
const variantJenis = {
    vitamin_a_merah: "red",
    vitamin_a_biru: "blue",
    obat_cacing: "green",
    pmt_biskuit: "yellow",
    pmt_susu: "purple",
    pmt_lainnya: "green",
};

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);

const statusAntropometri = (pengukuran) => [
    { label: "BB/U", value: pengukuran.status_bbu },
    { label: "TB/U", value: pengukuran.status_tbu },
    { label: "BB/TB", value: pengukuran.status_bbtb },
    { label: "IMT/U", value: pengukuran.status_imtu },
];

/* ── Detail rujukan ──────────────────────────────────────────────── */
const lihatDetailRujukan = async (id) => {
    showDetailRujukan.value = true;
    await rujukanStore.fetchDetailRujukan(id);
};

/* ── Fetch semua data paralel ────────────────────────────────────── */
const fetchData = () => {
    Promise.all([
        kaderStore.fetchAnakById(anakId),
        pengukuranStore.fetchRiwayat(anakId),
        pemberianStore.fetchRiwayat(anakId),
        rujukanStore.fetchRujukanByAnak(anakId),
    ]);
};

onMounted(fetchData);
</script>

<style scoped>
.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--color-text-muted);
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
