<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header halaman ─────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Dashboard
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Selamat datang,
                    <strong style="color: var(--color-green-700)">{{
                        authStore.namaLengkap ?? "Kader"
                    }}</strong>
                    — data per {{ tanggalHariIni }}
                </p>
            </div>

            <!-- Tombol refresh -->
            <button
                class="btn-refresh flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium border transition-all"
                :disabled="dashboardStore.isAnyLoading"
                aria-label="Muat ulang data dashboard"
                @click="refresh"
            >
                <i
                    class="pi pi-refresh"
                    :class="{ 'pi-spin': dashboardStore.isAnyLoading }"
                    aria-hidden="true"
                />
                <span class="max-[480px]:hidden">Perbarui</span>
            </button>
        </div>

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
                <span>Gagal memuat sebagian data. Coba perbarui halaman.</span>
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
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
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
                    :sub="`${dashboardStore.persentasePrioritasTinggi}% dari total anak`"
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
        <section aria-label="Grafik dan visualisasi data">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <!-- Tren gizi — lebar penuh di atas -->
                <div class="lg:col-span-2">
                    <TrenGiziChart
                        v-model:bulan="selectedBulan"
                        :data="dashboardStore.trenGizi"
                        :loading="dashboardStore.loading.trenGizi"
                    />
                </div>

                <!-- Distribusi antropometri + prioritas — berdampingan -->
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
import { useAuthStore } from "@/stores/authStore";

import StatCard from "@/components/ui/StatCard.vue";
import TrenGiziChart from "@/components/charts/TrenGiziChart.vue";
import DistribusiGiziChart from "@/components/charts/DistribusiGiziChart.vue";
import RisikoChart from "@/components/charts/RisikoChart.vue";

const dashboardStore = useDashboardStore();
const authStore = useAuthStore();

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

/* ── Tanggal hari ini ────────────────────────────────────────────── */
const tanggalHariIni = computed(() =>
    new Date().toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    }),
);

/* ── Refresh ─────────────────────────────────────────────────────── */
const refresh = () => dashboardStore.fetchAll(selectedBulan.value);

/* ── Initial fetch ───────────────────────────────────────────────── */
onMounted(() => dashboardStore.fetchAll(selectedBulan.value));
</script>

<style scoped>
/* ─── Tombol refresh ──────────────────────────────────────────────── */
.btn-refresh {
    background: white;
    color: var(--color-text-body);
    border-color: var(--color-input-border);
}
.btn-refresh:hover:not(:disabled) {
    background: var(--color-green-50);
    border-color: var(--color-green-700);
    color: var(--color-green-700);
}
.btn-refresh:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
</style>
