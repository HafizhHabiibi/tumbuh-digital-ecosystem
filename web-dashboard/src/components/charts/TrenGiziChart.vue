<template>
    <!--
        TrenGiziChart.vue
        Smooth Area Chart tren status Tinggi Badan Berdasarkan Umur N bulan terakhir.
        Mendukung filter 3 / 6 / 12 bulan via emit.
    -->
    <ChartCard
        title="Tren Status Tinggi Badan Berdasarkan Umur"
        :loading="loading"
        :empty="categories.length === 0"
    >
        <!-- Filter bulan -->
        <template #actions>
            <div
                class="flex gap-1 bg-slate-100 p-1 rounded-xl shrink-0"
                role="group"
                aria-label="Filter rentang waktu"
            >
                <button
                    v-for="opt in bulanOptions"
                    :key="opt"
                    class="filter-btn"
                    :class="{ 'filter-btn--active': bulan === opt }"
                    :aria-pressed="bulan === opt"
                    @click="$emit('update:bulan', opt)"
                >
                    {{ opt }} Bulan
                </button>
            </div>
        </template>

        <!-- Skeleton -->
        <div v-if="loading" class="py-2">
            <div class="skeleton h-[280px] w-full rounded-xl" />
        </div>

        <!-- Chart -->
        <apexchart
            v-else-if="categories.length > 0"
            type="area"
            height="280"
            :options="chartOptions"
            :series="series"
        />
    </ChartCard>
</template>

<script setup>
import { computed } from "vue";
import ChartCard from "./ChartCard.vue";

const props = defineProps({
    data: { type: Array, default: () => [] },
    bulan: { type: Number, default: 6 },
    loading: { type: Boolean, default: false },
});

defineEmits(["update:bulan"]);

const bulanOptions = [3, 6, 12];

/* Format "2024-01" → "Jan '24" */
const formatPeriode = (p) => {
    const [year, month] = p.split("-");
    const nama = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "Mei",
        "Jun",
        "Jul",
        "Agu",
        "Sep",
        "Okt",
        "Nov",
        "Des",
    ];
    return `${nama[parseInt(month) - 1]} '${year.slice(2)}`;
};

const categories = computed(() =>
    props.data.map((d) => formatPeriode(d.periode)),
);

const series = computed(() => [
    {
        name: "Sangat Pendek",
        data: props.data.map((d) => d.tbu?.sangat_pendek ?? 0),
    },
    { name: "Pendek", data: props.data.map((d) => d.tbu?.pendek ?? 0) },
    { name: "Normal", data: props.data.map((d) => d.tbu?.normal ?? 0) },
    { name: "Tinggi", data: props.data.map((d) => d.tbu?.tinggi ?? 0) },
]);

const chartOptions = computed(() => ({
    chart: {
        type: "area",
        fontFamily: "Poppins, sans-serif",
        toolbar: { show: false },
        zoom: { enabled: false },
        animations: { enabled: true, speed: 600 },
    },
    dataLabels: {
        enabled: false,
    },
    colors: ["#ef4444", "#f59e0b", "#10b981", "#3b82f6"],
    stroke: { curve: "smooth", width: 2.5 },
    fill: {
        type: "gradient",
        gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.28,
            opacityTo: 0.02,
            stops: [0, 90, 100],
        },
    },
    markers: {
        size: 4,
        strokeColors: "#ffffff",
        strokeWidth: 2,
        hover: { size: 6.5, strokeWidth: 2 },
    },
    xaxis: {
        categories: categories.value,
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
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "11px",
                colors: "#64748b",
            },
            formatter: (v) => Math.round(v),
        },
        min: 0,
    },
    grid: {
        borderColor: "#f1f5f9",
        strokeDashArray: 4,
        padding: { left: 0, right: 0 },
    },
    legend: {
        position: "top",
        horizontalAlign: "right",
        fontFamily: "Poppins, sans-serif",
        fontSize: "12px",
        markers: { width: 8, height: 8, radius: 50 },
    },
    tooltip: {
        shared: true,
        intersect: false,
        custom: function ({ series: seriesData, dataPointIndex, w }) {
            const periode = w.globals.categoryLabels[dataPointIndex] || "";
            const seriesNames = w.globals.seriesNames;
            const colors = w.globals.colors;

            let total = 0;
            seriesData.forEach((s) => {
                total += s[dataPointIndex] || 0;
            });

            let itemsHtml = "";
            seriesNames.forEach((name, i) => {
                const val = seriesData[i][dataPointIndex] ?? 0;
                const color = colors[i];
                itemsHtml += `
                    <div style="display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-top: 5px;">
                        <span style="display: flex; align-items: center; gap: 7px; font-size: 11.5px; color: #475569; font-weight: 500;">
                            <span style="width: 7px; height: 7px; border-radius: 50%; background-color: ${color}; flex-shrink: 0;"></span>
                            ${name}
                        </span>
                        <span style="font-size: 12px; font-weight: 700; color: #0f172a;">
                            ${val} <span style="font-size: 10px; font-weight: 400; color: #94a3b8;">anak</span>
                        </span>
                    </div>
                `;
            });

            return `
                <div style="background: #ffffff; border-radius: 12px; padding: 10px 14px; border: 1px solid rgba(226, 232, 240, 0.95); box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.04); font-family: 'Poppins', sans-serif; min-width: 175px;">
                    <div style="display: flex; align-items: center; justify-content: space-between; padding-bottom: 6px; border-bottom: 1px solid #f1f5f9; margin-bottom: 4px;">
                        <span style="font-size: 12px; font-weight: 700; color: #0f172a;">${periode}</span>
                        <span style="font-size: 10.5px; font-weight: 600; color: #059669; background: #ecfdf5; padding: 2px 7px; border-radius: 6px;">Total: ${total}</span>
                    </div>
                    ${itemsHtml}
                </div>
            `;
        },
    },
}));
</script>

<style scoped>
/* ─── Filter tombol bulan segmented control ────────────────────────── */
.filter-btn {
    font-family: "Poppins", sans-serif;
    font-size: 0.725rem;
    font-weight: 500;
    padding: 0.25rem 0.65rem;
    border-radius: 0.5rem;
    border: none;
    background: transparent;
    color: #64748b;
    cursor: pointer;
    transition: all 0.15s ease;
    line-height: 1.25;
}

.filter-btn--active {
    background: #ffffff;
    color: #0f172a;
    font-weight: 600;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.filter-btn:hover:not(.filter-btn--active) {
    color: #0f172a;
}

/* ─── Override default ApexCharts Tooltip Container ────────────────── */
:deep(.apexcharts-tooltip) {
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
}
</style>
