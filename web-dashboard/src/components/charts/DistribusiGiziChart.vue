<template>
    <!--
        DistribusiGiziChart.vue
        Donut chart distribusi status gizi balita.
        Data dari dashboardStore.distribusiGiziChart (getter).
    -->
    <ChartCard
        title="Distribusi Status Gizi"
        subtitle="Berdasarkan pengukuran terakhir"
        :loading="loading"
        :empty="!series.some((v) => v > 0)"
    >
        <!-- Skeleton -->
        <div v-if="loading" class="flex flex-col items-center gap-4 py-4">
            <div class="skeleton w-40 h-40 !rounded-full" />
            <div class="flex gap-3 flex-wrap justify-center">
                <div
                    v-for="i in 4"
                    :key="i"
                    class="skeleton w-20 h-3"
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
    </ChartCard>
</template>

<script setup>
import { computed } from "vue";
import ChartCard from "./ChartCard.vue";

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
