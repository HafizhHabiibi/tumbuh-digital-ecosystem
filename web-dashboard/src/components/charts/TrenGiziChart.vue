<template>
    <!--
        TrenGiziChart.vue
        Line chart tren status gizi N bulan terakhir.
        Mendukung filter 3 / 6 / 12 bulan via emit.
    -->
    <div class="chart-card">
        <header class="chart-header">
            <div>
                <h3 class="chart-title">Tren Status Gizi</h3>
                <p class="chart-subtitle">{{ bulan }} bulan terakhir</p>
            </div>

            <!-- Filter bulan -->
            <div
                class="bulan-filter"
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
                    {{ opt }}B
                </button>
            </div>
        </header>

        <!-- Skeleton -->
        <div v-if="loading" class="chart-skeleton" aria-label="Memuat chart...">
            <div class="skeleton skeleton--chart" />
        </div>

        <!-- Chart -->
        <apexchart
            v-else
            type="line"
            height="280"
            :options="chartOptions"
            :series="series"
        />
    </div>
</template>

<script setup>
import { computed } from "vue";

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
    { name: "Normal", data: props.data.map((d) => d.normal) },
    { name: "Kurang", data: props.data.map((d) => d.kurang) },
    { name: "Buruk", data: props.data.map((d) => d.buruk) },
    { name: "Lebih", data: props.data.map((d) => d.lebih) },
]);

const chartOptions = computed(() => ({
    chart: {
        type: "line",
        fontFamily: "Poppins, sans-serif",
        toolbar: { show: false },
        zoom: { enabled: false },
        animations: { enabled: true, speed: 600 },
    },
    colors: ["#22c55e", "#f59e0b", "#ef4444", "#3b82f6"],
    stroke: { curve: "smooth", width: 2.5 },
    markers: { size: 4, hover: { size: 6 } },
    xaxis: {
        categories: categories.value,
        labels: {
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "11px",
                colors: "#6f7a6b",
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
                colors: "#6f7a6b",
            },
            formatter: (v) => Math.round(v),
        },
        min: 0,
    },
    grid: {
        borderColor: "#f0f0f0",
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
        style: { fontFamily: "Poppins, sans-serif" },
        y: { formatter: (val) => `${val} anak` },
    },
}));
</script>

<style scoped>
.chart-card {
    background: white;
    border-radius: 1rem;
    padding: 1.25rem 1.5rem;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
    border: 1px solid rgba(190, 202, 184, 0.3);
}

.chart-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 0.5rem;
    gap: 1rem;
}

.chart-title {
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--color-text-heading);
    margin: 0 0 0.2rem;
}
.chart-subtitle {
    font-size: 0.75rem;
    color: var(--color-text-muted);
    margin: 0;
}

/* ─── Filter tombol bulan ─────────────────────────────────────────── */
.bulan-filter {
    display: flex;
    gap: 0.25rem;
    background: #f5fbef;
    padding: 0.2rem;
    border-radius: 0.5rem;
    flex-shrink: 0;
}
.filter-btn {
    font-family: "Poppins", sans-serif;
    font-size: 0.7rem;
    font-weight: 500;
    padding: 0.2rem 0.6rem;
    border-radius: 0.375rem;
    border: none;
    background: transparent;
    color: var(--color-text-muted);
    cursor: pointer;
    transition:
        background 0.15s,
        color 0.15s;
}
.filter-btn--active {
    background: var(--color-green-700);
    color: white;
}
.filter-btn:hover:not(.filter-btn--active) {
    background: rgba(0, 110, 28, 0.08);
    color: var(--color-green-700);
}

/* ─── Skeleton ────────────────────────────────────────────────────── */
.chart-skeleton {
    padding: 0.5rem 0;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
    border-radius: 0.5rem;
}
.skeleton--chart {
    height: 280px;
    width: 100%;
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
