<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Back button ──────────────────────────────────────── -->
        <button
            class="flex items-center gap-2 text-sm font-medium transition-colors hover:opacity-70"
            style="
                color: var(--color-green-700);
                background: none;
                border: none;
                cursor: pointer;
                padding: 0;
            "
            @click="router.back()"
        >
            <i class="pi pi-arrow-left" aria-hidden="true" />
            Kembali
        </button>

        <!-- ─── Loading ──────────────────────────────────────────── -->
        <div v-if="kaderStore.loading.anakDetail" class="space-y-4">
            <div class="skeleton h-28 rounded-2xl" />
            <div class="skeleton h-12 rounded-xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
        <div
            v-else-if="kaderStore.error.anakDetail"
            class="card p-8 rounded-2xl flex flex-col items-center gap-3 text-center"
        >
            <i
                class="pi pi-exclamation-circle text-4xl"
                style="color: #dc2626"
                aria-hidden="true"
            />
            <p class="text-sm m-0" style="color: var(--color-text-muted)">
                {{ kaderStore.error.anakDetail }}
            </p>
            <button
                class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                @click="fetchData"
            >
                Coba Lagi
            </button>
        </div>

        <template v-else-if="kaderStore.anakDetail">
            <!-- ─── Card info anak ───────────────────────────────── -->
            <AnakCard
                :anak="kaderStore.anakDetail"
                :status-tbu-terakhir="
                    pengukuranStore.pengukuranTerakhir?.status_tbu
                "
            />

            <!-- ─── Tab navigation ───────────────────────────────── -->
            <div
                class="flex gap-1 p-1 rounded-xl w-fit"
                style="background: var(--color-green-50)"
            >
                <button
                    v-for="tab in tabs"
                    :key="tab.key"
                    class="flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-medium transition-all"
                    :class="activeTab === tab.key ? 'text-white' : ''"
                    :style="
                        activeTab === tab.key
                            ? 'background: var(--color-green-700)'
                            : 'background: transparent; color: var(--color-text-muted)'
                    "
                    :aria-pressed="activeTab === tab.key"
                    @click="activeTab = tab.key"
                >
                    <i :class="`pi ${tab.icon} text-xs`" aria-hidden="true" />
                    {{ tab.label }}
                    <!-- Badge jumlah -->
                    <span
                        v-if="tab.count !== undefined"
                        class="px-1.5 py-0.5 rounded-full text-[10px] font-bold"
                        :style="
                            activeTab === tab.key
                                ? 'background: rgba(255,255,255,0.25); color: white'
                                : 'background: var(--color-green-100); color: var(--color-green-700)'
                        "
                    >
                        {{ tab.count }}
                    </span>
                </button>
            </div>

            <!-- ══ TAB: Pengukuran ══════════════════════════════════ -->
            <div v-show="activeTab === 'pengukuran'" class="space-y-4">
                <!-- Grid Chart: KMS & Tinggi Badan -->
                <div v-if="pengukuranStore.trenPertumbuhan.length > 0" class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                    <!-- Grafik KMS (Berat Badan menurut Umur) -->
                    <div class="card p-5 rounded-2xl">
                        <h3
                            class="text-sm font-semibold m-0 mb-4"
                            style="color: var(--color-text-heading)"
                        >
                            <i
                                class="pi pi-chart-line mr-1.5"
                                style="color: var(--color-green-700)"
                                aria-hidden="true"
                            />
                            Grafik KMS (Berat Badan / Umur)
                        </h3>
                        <KMSChart
                            :jenis-kelamin="kaderStore.anakDetail.jenis_kelamin"
                            :tanggal-lahir="kaderStore.anakDetail.tanggal_lahir"
                            :riwayat-pengukuran="pengukuranStore.riwayat.list"
                        />
                    </div>

                    <!-- Tren Tinggi Badan -->
                    <div class="card p-5 rounded-2xl">
                        <h3
                            class="text-sm font-semibold m-0 mb-4"
                            style="color: var(--color-text-heading)"
                        >
                            <i
                                class="pi pi-chart-line mr-1.5"
                                style="color: var(--color-green-700)"
                                aria-hidden="true"
                            />
                            Tren Tinggi Badan
                        </h3>
                        <apexchart
                            type="line"
                            height="320"
                            :options="heightChartOptions"
                            :series="heightChartSeries"
                        />
                    </div>
                </div>

                <!-- Tabel riwayat pengukuran -->
                <div class="card rounded-2xl overflow-hidden">
                    <div class="flex items-center justify-between p-4 pb-0">
                        <h3
                            class="text-sm font-semibold m-0"
                            style="color: var(--color-text-heading)"
                        >
                            Riwayat Pengukuran
                        </h3>
                        <span
                            class="text-xs px-2 py-1 rounded-full font-medium"
                            style="
                                background: var(--color-green-100);
                                color: var(--color-green-700);
                            "
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
                        class="flex flex-col items-center py-10 gap-2"
                    >
                        <i
                            class="pi pi-chart-bar text-3xl"
                            style="color: var(--color-text-muted)"
                            aria-hidden="true"
                        />
                        <p
                            class="text-sm m-0"
                            style="color: var(--color-text-muted)"
                        >
                            Belum ada data pengukuran
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto mt-3">
                        <table class="w-full text-sm">
                            <thead>
                            <tr
                                style="
                                        background: var(--color-green-50);
                                        border-bottom: 1px solid
                                            var(--color-input-border);
                                    "
                                >
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">BB (kg)</th>
                                    <th class="th-cell">TB (cm)</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Status Antropometri
                                    </th>
                                    <th class="th-cell hidden md:table-cell">
                                        Prioritas Pemantauan
                                    </th>
                                    <th class="th-cell hidden lg:table-cell">
                                        Skor SAW
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(p, i) in pengukuranStore.riwayat
                                        .list"
                                    :key="p.id"
                                    class="table-row"
                                    :style="
                                        i % 2 !== 0
                                            ? 'background: var(--color-green-50)'
                                            : ''
                                    "
                                >
                                    <td
                                        class="px-4 py-3 text-sm"
                                        style="
                                            color: var(--color-text-body);
                                            white-space: nowrap;
                                        "
                                    >
                                        {{ formatTanggal(p.tanggal_ukur) }}
                                    </td>
                                    <td
                                        class="px-4 py-3 font-semibold"
                                        style="color: var(--color-text-heading)"
                                    >
                                        {{ p.berat_badan }}
                                    </td>
                                    <td
                                        class="px-4 py-3 font-semibold"
                                        style="color: var(--color-text-heading)"
                                    >
                                        {{ p.tinggi_badan }}
                                    </td>
                                    <td class="px-4 py-3 hidden md:table-cell">
                                        <div class="grid grid-cols-2 gap-x-2 gap-y-1 text-[10px]">
                                            <span
                                                v-for="item in statusAntropometri(p)"
                                                :key="item.label"
                                                :title="formatStatusAntropometri(item.value)"
                                            >
                                                <strong>{{ item.label }}:</strong>
                                                {{ formatStatusAntropometri(item.value) }}
                                            </span>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 hidden md:table-cell">
                                        <StatusBadge
                                            type="prioritas"
                                            :value="p.prioritas_pemantauan?.kategori"
                                        />
                                    </td>
                                    <td
                                        class="px-4 py-3 hidden lg:table-cell font-mono text-xs"
                                        style="color: var(--color-text-body)"
                                    >
                                        {{
                                            formatSkor(p.skor_saw)
                                        }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ TAB: Pemberian ═══════════════════════════════════ -->
            <div v-show="activeTab === 'pemberian'" class="space-y-4">
                <div class="card rounded-2xl overflow-hidden">
                    <div class="flex items-center justify-between p-4 pb-0">
                        <h3
                            class="text-sm font-semibold m-0"
                            style="color: var(--color-text-heading)"
                        >
                            Pemberian
                        </h3>
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
                        class="flex flex-col items-center py-10 gap-2"
                    >
                        <i
                            class="pi pi-inbox text-3xl"
                            style="color: var(--color-text-muted)"
                            aria-hidden="true"
                        />
                        <p
                            class="text-sm m-0"
                            style="color: var(--color-text-muted)"
                        >
                            Belum ada pemberian
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto mt-3">
                        <table class="w-full text-sm">
                            <thead>
                                <tr
                                    style="
                                        background: var(--color-green-50);
                                        border-bottom: 1px solid
                                            var(--color-input-border);
                                    "
                                >
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">Jenis</th>
                                    <th class="th-cell">Dosis</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Dicatat Oleh
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(item, i) in pemberianStore.riwayat
                                        .list"
                                    :key="item.id"
                                    class="table-row"
                                    :style="
                                        i % 2 !== 0
                                            ? 'background: var(--color-green-50)'
                                            : ''
                                    "
                                >
                                    <td
                                        class="px-4 py-3 text-sm"
                                        style="
                                            color: var(--color-text-body);
                                            white-space: nowrap;
                                        "
                                    >
                                        {{
                                            formatTanggal(
                                                item.tanggal_pemberian,
                                            )
                                        }}
                                    </td>
                                    <td class="px-4 py-3">
                                        <StatusBadge
                                            :label="
                                                LABEL_JENIS[item.jenis] ??
                                                item.jenis
                                            "
                                            :variant="
                                                variantJenis[item.jenis] ??
                                                'gray'
                                            "
                                        />
                                    </td>
                                    <td
                                        class="px-4 py-3 font-medium"
                                        style="color: var(--color-text-heading)"
                                    >
                                        {{ item.dosis ?? "—" }}
                                    </td>
                                    <td
                                        class="px-4 py-3 hidden md:table-cell text-sm"
                                        style="color: var(--color-text-muted)"
                                    >
                                        {{ item.dicatat_oleh }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ══ TAB: Rujukan ════════════════════════════════════ -->
            <div v-show="activeTab === 'rujukan'" class="space-y-4">
                <div class="card rounded-2xl overflow-hidden">
                    <div class="flex items-center justify-between p-4 pb-0">
                        <h3
                            class="text-sm font-semibold m-0"
                            style="color: var(--color-text-heading)"
                        >
                            Riwayat Rujukan
                        </h3>
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
                        class="flex flex-col items-center py-10 gap-2"
                    >
                        <i
                            class="pi pi-send text-3xl"
                            style="color: var(--color-text-muted)"
                            aria-hidden="true"
                        />
                        <p
                            class="text-sm m-0"
                            style="color: var(--color-text-muted)"
                        >
                            Belum ada riwayat rujukan
                        </p>
                    </div>

                    <div v-else class="overflow-x-auto mt-3">
                        <table class="w-full text-sm">
                            <thead>
                                <tr
                                    style="
                                        background: var(--color-green-50);
                                        border-bottom: 1px solid
                                            var(--color-input-border);
                                    "
                                >
                                    <th class="th-cell">Tanggal</th>
                                    <th class="th-cell">Status</th>
                                    <th class="th-cell hidden md:table-cell">
                                        Prioritas Pemantauan
                                    </th>
                                    <th class="th-cell hidden md:table-cell">
                                        Ditangani Oleh
                                    </th>
                                    <th class="th-cell">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(r, i) in rujukanStore.riwayatAnak
                                        .list"
                                    :key="r.id"
                                    class="table-row"
                                    :style="
                                        i % 2 !== 0
                                            ? 'background: var(--color-green-50)'
                                            : ''
                                    "
                                >
                                    <td
                                        class="px-4 py-3 text-sm"
                                        style="
                                            color: var(--color-text-body);
                                            white-space: nowrap;
                                        "
                                    >
                                        {{ formatTanggal(r.created_at) }}
                                    </td>
                                    <td class="px-4 py-3">
                                        <StatusBadge
                                            type="rujukan"
                                            :value="r.status"
                                        />
                                    </td>
                                    <td class="px-4 py-3 hidden md:table-cell">
                                        <StatusBadge
                                            type="prioritas"
                                            :value="r.prioritas_pemantauan?.kategori"
                                        />
                                    </td>
                                    <td
                                        class="px-4 py-3 hidden md:table-cell text-sm"
                                        style="color: var(--color-text-muted)"
                                    >
                                        {{ r.ditangani_oleh ?? "—" }}
                                    </td>
                                    <td class="px-4 py-3">
                                        <button
                                            class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium"
                                            style="
                                                background: var(
                                                    --color-green-100
                                                );
                                                color: var(--color-green-700);
                                            "
                                            @click="lihatDetailRujukan(r.id)"
                                        >
                                            <i
                                                class="pi pi-eye text-xs"
                                                aria-hidden="true"
                                            />
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

/* ── Tabs ────────────────────────────────────────────────────────── */
const tabs = computed(() => [
    {
        key: "pengukuran",
        label: "Pengukuran",
        icon: "pi-chart-line",
        count: pengukuranStore.riwayat.list.length,
    },
    {
        key: "pemberian",
        label: "Pemberian",
        icon: "pi-shield",
        count: pemberianStore.riwayat.list.length,
    },
    {
        key: "rujukan",
        label: "Rujukan",
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
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
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
