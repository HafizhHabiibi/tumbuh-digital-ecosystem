<template>
    <!--
        DistribusiGiziChart.vue
        Split layout modern: Donut chart di kiri + breakdown metrik & persentase di kanan.
        Data dari dashboardStore.distribusiGiziChart (getter).
    -->
    <ChartCard
        title="Distribusi Status Tinggi Badan Berdasarkan Umur"
        :loading="loading"
        :empty="!series.some((v) => v > 0)"
    >
        <!-- Skeleton Loading -->
        <div
            v-if="loading"
            class="grid grid-cols-1 sm:grid-cols-12 gap-6 items-center py-3"
        >
            <div class="sm:col-span-5 flex justify-center">
                <div class="skeleton w-36 h-36 !rounded-full" />
            </div>
            <div class="sm:col-span-7 space-y-3">
                <div
                    v-for="i in 4"
                    :key="i"
                    class="space-y-1.5 p-2"
                >
                    <div class="flex justify-between">
                        <div class="skeleton w-24 h-3.5 rounded" />
                        <div class="skeleton w-16 h-3.5 rounded" />
                    </div>
                    <div class="skeleton w-full h-1.5 rounded-full" />
                </div>
            </div>
        </div>

        <!-- Modern Split Layout -->
        <div
            v-else-if="series.length > 0 && series.some((v) => v > 0)"
            class="grid grid-cols-1 sm:grid-cols-12 gap-6 items-center py-2"
        >
            <!-- Kolom Kiri: Donut Chart -->
            <div class="sm:col-span-5 flex justify-center items-center">
                <apexchart
                    type="donut"
                    height="240"
                    width="100%"
                    :options="chartOptions"
                    :series="series"
                />
            </div>

            <!-- Kolom Kanan: Breakdown Rincian Status -->
            <div class="sm:col-span-7 space-y-2.5 sm:pl-2">
                <div
                    v-for="item in breakdownData"
                    :key="item.label"
                    class="p-2 rounded-xl transition-all duration-150 hover:bg-slate-50/80"
                >
                    <!-- Header Baris: Label, Nilai, dan Persentase -->
                    <div class="flex items-center justify-between gap-2 text-xs mb-1.5">
                        <span class="flex items-center gap-2 font-semibold text-slate-700">
                            <span
                                class="w-2.5 h-2.5 rounded-full shrink-0"
                                :style="{ backgroundColor: item.color }"
                            />
                            {{ item.label }}
                        </span>
                        <div class="flex items-center gap-2 font-bold text-slate-900">
                            <span>
                                {{ item.value }}
                                <span class="font-normal text-slate-400 text-[11px]">anak</span>
                            </span>
                            <span
                                class="text-[11px] font-semibold text-slate-600 bg-slate-100 px-1.5 py-0.5 rounded-md min-w-[42px] text-right"
                            >
                                {{ item.percentage }}%
                            </span>
                        </div>
                    </div>

                    <!-- Mini Progress Bar Proporsi -->
                    <div class="w-full bg-slate-100 rounded-full h-1.5 overflow-hidden">
                        <div
                            class="h-full rounded-full transition-all duration-500"
                            :style="{
                                width: `${item.percentage}%`,
                                backgroundColor: item.color,
                            }"
                        />
                    </div>
                </div>
            </div>
        </div>
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

const totalAnak = computed(() =>
    props.data.reduce((acc, curr) => acc + (curr.value || 0), 0),
);

const breakdownData = computed(() => {
    const total = totalAnak.value;
    return props.data.map((item) => ({
        ...item,
        percentage:
            total > 0 ? ((item.value / total) * 100).toFixed(1) : "0.0",
    }));
});

const chartOptions = computed(() => ({
    chart: {
        type: "donut",
        fontFamily: "Poppins, sans-serif",
        toolbar: { show: false },
        animations: { enabled: true, speed: 600 },
    },
    labels: props.data.map((d) => d.label),
    colors: props.data.map((d) => d.color),
    stroke: {
        width: 2,
        colors: ["#ffffff"],
    },
    legend: {
        show: false, // Digantikan dengan panel rincian interaktif di sisi kanan
    },
    dataLabels: {
        enabled: false,
    },
    plotOptions: {
        pie: {
            donut: {
                size: "72%",
                labels: {
                    show: true,
                    name: {
                        show: true,
                        fontFamily: "Poppins, sans-serif",
                        fontSize: "11px",
                        fontWeight: 500,
                        color: "#64748b",
                        offsetY: -6,
                    },
                    value: {
                        show: true,
                        fontFamily: "Poppins, sans-serif",
                        fontSize: "20px",
                        fontWeight: "800",
                        color: "#0f172a",
                        offsetY: 4,
                        formatter: (val) => `${val} anak`,
                    },
                    total: {
                        show: true,
                        label: "Total Balita",
                        fontFamily: "Poppins, sans-serif",
                        fontSize: "11px",
                        fontWeight: 500,
                        color: "#64748b",
                        formatter: (w) => {
                            const sum = w.globals.seriesTotals.reduce(
                                (a, b) => a + b,
                                0,
                            );
                            return `${sum}`;
                        },
                    },
                },
            },
        },
    },
    tooltip: {
        y: { formatter: (val) => `${val} anak` },
    },
}));
</script>

<style scoped>
.skeleton {
    background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 50%, #f1f5f9 75%);
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
