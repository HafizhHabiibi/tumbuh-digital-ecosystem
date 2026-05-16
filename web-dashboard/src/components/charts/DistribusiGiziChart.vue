<template>
    <!--
        DistribusiGiziChart.vue
        Donut chart distribusi status gizi balita.
        Data dari dashboardStore.distribusiGiziChart (getter).
    -->
    <div class="chart-card">
        <header class="chart-header">
            <div>
                <h3 class="chart-title">Distribusi Status Gizi</h3>
                <p class="chart-subtitle">Berdasarkan pengukuran terakhir</p>
            </div>
        </header>

        <!-- Skeleton -->
        <div v-if="loading" class="chart-skeleton" aria-label="Memuat chart...">
            <div class="skeleton skeleton--circle" />
            <div class="skeleton-legend">
                <div
                    v-for="i in 4"
                    :key="i"
                    class="skeleton skeleton--legend-item"
                />
            </div>
        </div>

        <!-- Chart -->
        <apexchart
            v-else-if="series.length > 0 && series.some((v) => v > 0)"
            type="donut"
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
    loading: { type: Boolean, default: false },
});

const series = computed(() => props.data.map((d) => d.value));

const chartOptions = computed(() => ({
    chart: {
        type: "donut",
        fontFamily: "Poppins, sans-serif",
        toolbar: { show: false },
        animations: { enabled: true, speed: 600 },
    },
    labels: props.data.map((d) => d.label),
    colors: props.data.map((d) => d.color),
    legend: {
        position: "bottom",
        fontFamily: "Poppins, sans-serif",
        fontSize: "12px",
        markers: { width: 10, height: 10, radius: 50 },
        itemMargin: { horizontal: 8 },
    },
    dataLabels: {
        enabled: true,
        formatter: (val) => `${val.toFixed(1)}%`,
        style: { fontFamily: "Poppins, sans-serif", fontSize: "11px" },
        dropShadow: { enabled: false },
    },
    plotOptions: {
        pie: {
            donut: {
                size: "65%",
                labels: {
                    show: true,
                    total: {
                        show: true,
                        label: "Total Anak",
                        fontSize: "12px",
                        fontFamily: "Poppins, sans-serif",
                        color: "#6f7a6b",
                        formatter: (w) =>
                            w.globals.seriesTotals.reduce((a, b) => a + b, 0),
                    },
                    value: {
                        fontSize: "22px",
                        fontWeight: 700,
                        fontFamily: "Poppins, sans-serif",
                        color: "#171d16",
                    },
                },
            },
        },
    },
    stroke: { width: 2, colors: ["#fff"] },
    tooltip: {
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

/* ─── Skeleton ────────────────────────────────────────────────────── */
.chart-skeleton {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
    padding: 1rem 0;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
    border-radius: 0.375rem;
}
.skeleton--circle {
    width: 160px;
    height: 160px;
    border-radius: 50%;
}
.skeleton-legend {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
    justify-content: center;
}
.skeleton--legend-item {
    width: 80px;
    height: 12px;
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
