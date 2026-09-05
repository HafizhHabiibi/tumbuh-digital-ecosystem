<template>
    <article class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-xs">
        <header class="mb-4">
            <div class="flex items-start justify-between gap-3">
                <div>
                    <h3 class="text-sm font-bold text-slate-800 m-0">
                        {{ config.title }}
                    </h3>
                    <p class="text-xs text-slate-400 mt-1 mb-0">
                        {{ config.description }}
                    </p>
                </div>
                <span
                    class="inline-flex items-center gap-1.5 text-[11px] font-semibold text-emerald-700 whitespace-nowrap"
                >
                    <span class="w-5 h-0.5 rounded-full bg-emerald-600" />
                    {{ config.legend }}
                </span>
            </div>
        </header>

        <apexchart
            type="area"
            height="280"
            :options="chartOptions"
            :series="chartSeries"
        />

        <p class="text-[11px] text-slate-400 text-center mt-1 mb-0">
            Tanggal pengukuran
        </p>
    </article>
</template>

<script setup>
import { computed } from "vue";
import { formatStatusAntropometri } from "@/utils/antropometri";

const props = defineProps({
    metric: {
        type: String,
        required: true,
        validator: (value) => ["weight", "height"].includes(value),
    },
    measurements: {
        type: Array,
        default: () => [],
    },
});

const metricConfigs = {
    weight: {
        title: "Perkembangan Berat Badan",
        description: "Berat badan dalam kilogram berdasarkan tanggal pengukuran",
        legend: "Berat badan anak",
        field: "berat_badan",
        statusField: "status_bbu",
        unit: "kg",
        minimumPadding: 1,
        decimals: 2,
    },
    height: {
        title: "Perkembangan Tinggi Badan",
        description: "Tinggi badan dalam sentimeter berdasarkan tanggal pengukuran",
        legend: "Tinggi badan anak",
        field: "tinggi_badan",
        statusField: "status_tbu",
        unit: "cm",
        minimumPadding: 5,
        decimals: 1,
    },
};

const config = computed(() => metricConfigs[props.metric]);

const sortedMeasurements = computed(() =>
    [...props.measurements]
        .filter((item) => Number.isFinite(Number(item[config.value.field])))
        .sort(
            (a, b) =>
                new Date(a.tanggal_ukur).getTime() -
                new Date(b.tanggal_ukur).getTime(),
        ),
);

const values = computed(() =>
    sortedMeasurements.value.map((item) => Number(item[config.value.field])),
);

const yAxisBounds = computed(() => {
    if (!values.value.length) return { min: 0, max: 10 };
    const minimum = Math.min(...values.value);
    const maximum = Math.max(...values.value);
    const padding = Math.max(
        (maximum - minimum) * 0.2,
        config.value.minimumPadding,
    );
    return {
        min: Math.max(0, Math.floor((minimum - padding) * 10) / 10),
        max: Math.ceil((maximum + padding) * 10) / 10,
    };
});

const formatShortDate = (value) =>
    new Date(value).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
    });

const chartSeries = computed(() => [
    {
        name: config.value.legend,
        data: values.value,
    },
]);

const chartOptions = computed(() => ({
    chart: {
        type: "area",
        fontFamily: "Poppins, sans-serif",
        toolbar: { show: false },
        zoom: { enabled: false },
        animations: { enabled: true, speed: 350 },
    },
    colors: ["#059669"],
    dataLabels: { enabled: false },
    stroke: {
        curve: sortedMeasurements.value.length > 2 ? "smooth" : "straight",
        width: 3,
        lineCap: "round",
    },
    fill: {
        type: "solid",
        opacity: 0.08,
    },
    markers: {
        size: 5,
        colors: ["#059669"],
        strokeColors: "#ffffff",
        strokeWidth: 2,
        hover: { size: 7 },
    },
    xaxis: {
        categories: sortedMeasurements.value.map((item) =>
            formatShortDate(item.tanggal_ukur),
        ),
        tickAmount: Math.min(5, Math.max(1, sortedMeasurements.value.length - 1)),
        labels: {
            rotate: 0,
            hideOverlappingLabels: true,
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "10px",
                colors: "#64748b",
            },
        },
        axisBorder: { show: true, color: "#e2e8f0" },
        axisTicks: { show: false },
        tooltip: { enabled: false },
    },
    yaxis: {
        min: yAxisBounds.value.min,
        max: yAxisBounds.value.max,
        tickAmount: 4,
        labels: {
            formatter: (value) =>
                `${Number(value).toFixed(config.value.decimals === 2 ? 1 : 0)} ${config.value.unit}`,
            style: {
                fontFamily: "Poppins, sans-serif",
                fontSize: "10px",
                colors: "#64748b",
            },
        },
    },
    grid: {
        borderColor: "#e2e8f0",
        strokeDashArray: 3,
        xaxis: { lines: { show: false } },
        padding: { left: 4, right: 8 },
    },
    legend: { show: false },
    tooltip: {
        intersect: false,
        shared: false,
        style: { fontFamily: "Poppins, sans-serif", fontSize: "12px" },
        y: {
            formatter: (value, { dataPointIndex }) => {
                const measurement = sortedMeasurements.value[dataPointIndex];
                const status = formatStatusAntropometri(
                    measurement?.[config.value.statusField],
                );
                return `${Number(value).toFixed(config.value.decimals)} ${config.value.unit} · ${status}`;
            },
        },
    },
}));
</script>
