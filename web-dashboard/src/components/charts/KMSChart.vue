<template>
    <div class="kms-chart-container space-y-4">
        <!-- Legend Ringkas KMS -->
        <div class="flex flex-wrap gap-x-4 gap-y-2 text-xs bg-slate-50 p-3 rounded-xl border border-slate-100">
            <div class="flex items-center gap-1.5">
                <span class="w-3 h-3 rounded bg-red-600"></span>
                <span class="text-slate-600 font-medium">BGM (&lt; SD -3 / &gt; SD 3)</span>
            </div>
            <div class="flex items-center gap-1.5">
                <span class="w-3 h-3 rounded bg-amber-500"></span>
                <span class="text-slate-600 font-medium">Risiko Gizi (SD -3 s.d SD -2 / SD 2 s.d SD 3)</span>
            </div>
            <div class="flex items-center gap-1.5">
                <span class="w-3 h-3 rounded bg-green-600"></span>
                <span class="text-slate-600 font-medium">Gizi Normal (SD -2 s.d SD 2)</span>
            </div>
            <div class="flex items-center gap-1.5 ml-auto">
                <span class="w-5 h-1 bg-sky-500 rounded"></span>
                <span class="text-slate-800 font-bold">Berat Badan Anak</span>
            </div>
        </div>

        <!-- Chart -->
        <div class="relative min-h-[300px]">
            <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-white/50 z-10">
                <i class="pi pi-spin pi-refresh text-2xl text-green-700" />
            </div>
            <apexchart
                type="line"
                height="320"
                :options="chartOptions"
                :series="chartSeries"
            />
        </div>
    </div>
</template>

<script setup>
import { computed, ref, onMounted } from "vue";
import whoTables from "@/constants/whoTables.json";

const props = defineProps({
    jenisKelamin: {
        type: String,
        required: true,
        validator: (value) => ["L", "P", "l", "p"].includes(value),
    },
    tanggalLahir: {
        type: String,
        required: true,
    },
    riwayatPengukuran: {
        type: Array,
        required: true,
        default: () => [],
    },
});

const loading = ref(false);

/* ── Rumus LMS WHO ───────────────────────────────────────────────── */
const getWeightForZ = (L, M, S, Z) => {
    if (L === 0) {
        return M * Math.exp(S * Z);
    }
    return M * Math.pow(1 + L * S * Z, 1 / L);
};

/* ── Hitung Umur dalam Bulan ───────────────────────────────────────── */
const getAgeInMonths = (tanggalLahir, tanggalUkur) => {
    if (!tanggalLahir || !tanggalUkur) return 0;
    const lahir = new Date(tanggalLahir);
    const ukur = new Date(tanggalUkur);
    const diffTime = ukur - lahir;
    if (diffTime < 0) return 0;
    const diffDays = diffTime / (1000 * 60 * 60 * 24);
    return parseFloat((diffDays / 30.4375).toFixed(1));
};

/* ── Umur Anak Saat Ini (Bulan) ────────────────────────────────────── */
const currentAgeMonths = computed(() => {
    if (!props.tanggalLahir) return 0;
    const lahir = new Date(props.tanggalLahir);
    const sekarang = new Date();
    const diffTime = sekarang - lahir;
    const diffDays = diffTime / (1000 * 60 * 60 * 24);
    return diffDays / 30.4375;
});

/* ── Batas Maksimal X-Axis ───────────────────────────────────────── */
const maxLimit = computed(() => {
    if (!props.riwayatPengukuran || props.riwayatPengukuran.length === 0) {
        return currentAgeMonths.value <= 24 ? 24 : 60;
    }
    const ages = props.riwayatPengukuran.map((p) =>
        getAgeInMonths(props.tanggalLahir, p.tanggal_ukur),
    );
    const maxAge = Math.max(currentAgeMonths.value, ...ages, 0);
    return maxAge <= 24 ? 24 : 60;
});

/* ── Pilih Data Referensi WHO ─────────────────────────────────────── */
const standardData = computed(() => {
    const isBoy = props.jenisKelamin ? props.jenisKelamin.toUpperCase() === "L" : true;
    return isBoy ? whoTables.bbu_L : whoTables.bbu_P;
});

/* ── Hitung Kurva Standard ────────────────────────────────────────── */
const getCurve = (Z) => {
    if (!standardData.value) return [];
    return standardData.value
        .filter((row) => row.bulan <= maxLimit.value)
        .map((row) => {
            const val = getWeightForZ(row.L, row.M, row.S, Z);
            return [row.bulan, parseFloat(val.toFixed(2))];
        });
};

/* ── Data Pengukuran Anak ────────────────────────────────────────── */
const childData = computed(() => {
    if (!props.tanggalLahir || !props.riwayatPengukuran) return [];
    return [...props.riwayatPengukuran]
        .map((p) => {
            const age = getAgeInMonths(props.tanggalLahir, p.tanggal_ukur);
            return [age, parseFloat(p.berat_badan)];
        })
        .sort((a, b) => a[0] - b[0]);
});

/* ── Series Grafik ───────────────────────────────────────────────── */
const chartSeries = computed(() => [
    {
        name: "SD -3 (Sangat Kurang)",
        data: getCurve(-3),
    },
    {
        name: "SD -2 (Kurang)",
        data: getCurve(-2),
    },
    {
        name: "SD -1 (Normal-bawah)",
        data: getCurve(-1),
    },
    {
        name: "Median (Normal)",
        data: getCurve(0),
    },
    {
        name: "SD 1 (Normal-atas)",
        data: getCurve(1),
    },
    {
        name: "SD 2 (Lebih)",
        data: getCurve(2),
    },
    {
        name: "SD 3 (Sangat Lebih)",
        data: getCurve(3),
    },
    {
        name: "Berat Badan Anak",
        data: childData.value,
    },
]);

/* ── Konfigurasi Grafik ────────────────────────────────────────────── */
const chartOptions = computed(() => ({
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
        zoom: {
            enabled: true,
        },
    },
    // Urutan warna: SD -3 (merah), SD -2 (kuning), SD -1 (hijau muda), Median (hijau tua), SD 1 (hijau muda), SD 2 (kuning), SD 3 (merah), Anak (biru langit)
    colors: [
        "#dc2626", // SD -3: Merah
        "#f59e0b", // SD -2: Kuning/Amber
        "#86efac", // SD -1: Hijau Muda
        "#16a34a", // Median: Hijau Tua
        "#86efac", // SD 1: Hijau Muda
        "#f59e0b", // SD 2: Kuning/Amber
        "#dc2626", // SD 3: Merah
        "#0284c7", // Anak: Biru
    ],
    stroke: {
        curve: "smooth",
        width: [1.5, 1.5, 1.2, 2.5, 1.2, 1.5, 1.5, 4.5], // Garis anak lebih tebal, median tebal sedang, standar tipis
        dashArray: [0, 0, 5, 0, 5, 0, 0, 0], // Garis SD -1 dan SD 1 putus-putus
    },
    markers: {
        size: [0, 0, 0, 0, 0, 0, 0, 6], // Hanya tampilkan dot marker untuk data anak
        colors: ["#ffffff"],
        strokeColors: ["#0284c7"],
        strokeWidth: 3,
        hover: {
            size: 8,
            sizeOffset: 2,
        },
    },
    xaxis: {
        type: "numeric",
        min: 0,
        max: maxLimit.value,
        tickAmount: maxLimit.value === 24 ? 12 : 12, // Tampil tiap 2 bulan (untuk 24) atau 5 bulan (untuk 60)
        title: {
            text: "Usia (Bulan)",
            style: {
                fontFamily: "Poppins, sans-serif",
                fontWeight: 600,
                color: "#475569",
            },
        },
        labels: {
            formatter: (val) => `${Math.round(val)} M`,
            style: {
                fontSize: "11px",
                colors: "#64748b",
            },
        },
    },
    yaxis: {
        title: {
            text: "Berat Badan (kg)",
            style: {
                fontFamily: "Poppins, sans-serif",
                fontWeight: 600,
                color: "#475569",
            },
        },
        labels: {
            formatter: (val) => `${val.toFixed(1)} kg`,
            style: {
                fontSize: "11px",
                colors: "#64748b",
            },
        },
    },
    grid: {
        borderColor: "#f1f5f9",
        strokeDashArray: 4,
    },
    legend: {
        position: "top",
        horizontalAlign: "left",
        fontFamily: "Poppins, sans-serif",
        fontSize: "11px",
        markers: {
            radius: 12,
        },
        // Sembunyikan legenda standar WHO agar tidak terlalu penuh, cukup tampilkan legenda kustom di atas chart
        show: false,
    },
    tooltip: {
        shared: true,
        intersect: false,
        style: {
            fontFamily: "Poppins, sans-serif",
            fontSize: "12px",
        },
        x: {
            formatter: (val) => `Usia: ${val.toFixed(1)} bulan`,
        },
        y: {
            formatter: (val, opts) => {
                if (opts.seriesIndex === 7) {
                    return `<strong>${val.toFixed(2)} kg</strong> (Berat Anak)`;
                }
                return `${val.toFixed(2)} kg`;
            },
        },
    },
}));
</script>

<style scoped>
.kms-chart-container {
    width: 100%;
}
</style>
