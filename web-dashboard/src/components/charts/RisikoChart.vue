<template>
    <!--
        RisikoChart.vue
        Bar chart distribusi prioritas pemantauan berdasarkan hasil SAW.
        Tiga kategori: Rendah, Sedang, Tinggi.
    -->
    <ChartCard
        title="Distribusi Prioritas Pemantauan"
        subtitle="SAW digunakan untuk mengurutkan tindak lanjut, bukan diagnosis"
        :loading="loading"
        :empty="!series[0]?.data?.some((v) => v > 0)"
    >
        <!-- Skeleton -->
        <div v-if="loading" class="py-4">
            <div class="flex items-end justify-center gap-8 h-[200px]">
                <div
                    v-for="i in 3"
                    :key="i"
                    class="flex flex-col items-center gap-2 w-[60px] h-full justify-end"
                >
                    <div
                        class="skeleton w-full"
                        :style="{ height: `${40 + i * 20}%` }"
                    />
                    <div class="skeleton w-12 h-3" />
                </div>
            </div>
        </div>

        <!-- Chart -->
        <apexchart
            v-else-if="series[0]?.data?.some((v) => v > 0)"
            type="bar"
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
