<template>
    <!--
        RisikoChart.vue
        Bar chart distribusi risiko stunting berdasarkan hasil SAW.
        Tiga kategori: Rendah, Sedang, Tinggi.
    -->
    <div class="chart-card">
        <header class="chart-header">
            <div>
                <h3 class="chart-title">Distribusi Risiko Stunting</h3>
                <p class="chart-subtitle">Berdasarkan hasil analisis SAW</p>
            </div>
        </header>

        <!-- Skeleton -->
        <div v-if="loading" class="chart-skeleton" aria-label="Memuat chart...">
            <div class="skeleton-bars">
                <div v-for="i in 3" :key="i" class="skeleton-bar-wrap">
                    <div
                        class="skeleton skeleton--bar"
                        :style="{ height: `${40 + i * 20}%` }"
                    />
                    <div class="skeleton skeleton--label" />
                </div>
            </div>
        </div>

        <!-- Chart -->
        <apexchart
            v-else
            type="bar"
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

const series = computed(() => [
    {
        name: "Jumlah Anak",
        data: props.data.map((d) => d.value),
    },
]);

const chartOptions = computed(() => ({
    chart: {
        type: "bar",
        fontFamily: "Poppins, sans-serif",
        toolbar: { show: false },
        animations: { enabled: true, speed: 600 },
    },
    colors: props.data.map((d) => d.color),
    plotOptions: {
        bar: {
            distributed: true,
            borderRadius: 6,
            columnWidth: "45%",
            dataLabels: { position: "top" },
        },
    },
    dataLabels: {
        enabled: true,
        formatter: (val) => val,
        offsetY: -20,
        style: {
            fontSize: "12px",
            fontFamily: "Poppins, sans-serif",
            fontWeight: 600,
            colors: ["#171d16"],
        },
    },
    xaxis: {
        categories: props.data.map((d) => d.label),
        labels: {
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "12px",
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
        padding: { left: 0, right: 0, top: 10 },
    },
    legend: { show: false },
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
    padding: 1rem 0;
}
.skeleton-bars {
    display: flex;
    align-items: flex-end;
    justify-content: center;
    gap: 2rem;
    height: 200px;
}
.skeleton-bar-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
    width: 60px;
    height: 100%;
    justify-content: flex-end;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
    border-radius: 0.375rem;
}
.skeleton--bar {
    width: 100%;
}
.skeleton--label {
    width: 48px;
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
