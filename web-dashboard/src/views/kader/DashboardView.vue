<template>
    <div class="p-6 max-w-6xl mx-auto space-y-7">
        <!-- ─── Header halaman ─────────────────────────────────────── -->
        <PageHeader title="Dashboard" />

        <!-- ─── Error global ───────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="hasError"
                class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm"
                style="
                    background: #fef2f2;
                    border: 1px solid #fecaca;
                    color: #b91c1c;
                "
                role="alert"
                aria-live="assertive"
            >
                <i
                    class="pi pi-exclamation-triangle shrink-0"
                    aria-hidden="true"
                />
                <span>Gagal memuat sebagian data. Coba muat ulang halaman.</span>
                <button
                    class="ml-auto bg-transparent border-0 cursor-pointer p-0 leading-none"
                    style="color: #b91c1c"
                    aria-label="Tutup peringatan"
                    @click="clearErrors"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Stat Cards ─────────────────────────────────────────── -->
        <section aria-label="Ringkasan statistik">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard
                    label="Total Anak Terdaftar"
                    icon="pi-users"
                    color="green"
                    :value="dashboardStore.statistik.total_anak"
                    :loading="dashboardStore.loading.statistik"
                />
                <StatCard
                    label="Prioritas Pemantauan Tinggi"
                    icon="pi-chart-line"
                    color="red"
                    :value="dashboardStore.statistik.total_prioritas_tinggi"
                    :loading="dashboardStore.loading.statistik"
                />
                <StatCard
                    label="Rujukan Aktif"
                    icon="pi-send"
                    color="amber"
                    :value="dashboardStore.statistik.total_rujukan_aktif"
                    :loading="dashboardStore.loading.statistik"
                />
                <StatCard
                    label="Pengukuran Bulan Ini"
                    icon="pi-calendar-clock"
                    color="blue"
                    :value="dashboardStore.statistik.total_pengukuran_bulan"
                    :loading="dashboardStore.loading.statistik"
                />
            </div>
        </section>

        <!-- ─── Charts ─────────────────────────────────────────────── -->
        <section aria-label="Grafik dan visualisasi data" class="space-y-6">
            <!-- Tren pertumbuhan — lebar penuh di atas -->
            <div>
                <TrenGiziChart
                    v-model:bulan="selectedBulan"
                    :data="dashboardStore.trenGizi"
                    :loading="dashboardStore.loading.trenGizi"
                />
            </div>

            <!-- Distribusi antropometri + prioritas — berdampingan -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <DistribusiGiziChart
                    :data="dashboardStore.distribusiGiziChart"
                    :loading="dashboardStore.loading.distribusiGizi"
                />

                <RisikoChart
                    :data="dashboardStore.distribusiRisikoChart"
                    :loading="dashboardStore.loading.distribusiRisiko"
                />
            </div>
        </section>
    </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from "vue";
import { useDashboardStore } from "@/stores/dashboardStore";

import PageHeader from "@/components/ui/PageHeader.vue";
import StatCard from "@/components/ui/StatCard.vue";
import TrenGiziChart from "@/components/charts/TrenGiziChart.vue";
import DistribusiGiziChart from "@/components/charts/DistribusiGiziChart.vue";
import RisikoChart from "@/components/charts/RisikoChart.vue";

const dashboardStore = useDashboardStore();

/* ── Filter bulan tren gizi ──────────────────────────────────────── */
const selectedBulan = ref(6);

/* Watch perubahan filter bulan → fetch ulang hanya tren gizi */
watch(selectedBulan, (bulan) => {
    dashboardStore.fetchTrenGizi(bulan);
});

/* ── Error global ────────────────────────────────────────────────── */
const hasError = computed(() =>
    Object.values(dashboardStore.error).some(Boolean),
);
const clearErrors = () => {
    Object.keys(dashboardStore.error).forEach((k) => {
        dashboardStore.error[k] = null;
    });
};

/* ── Initial fetch ───────────────────────────────────────────────── */
onMounted(() => dashboardStore.fetchAll(selectedBulan.value));
</script>

<style scoped>
</style>
