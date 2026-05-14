<template>
    <div class="dashboard">
        <!-- ─── Header halaman ─────────────────────────────────────── -->
        <header class="dashboard-header">
            <div>
                <h1 class="page-title">Dashboard</h1>
                <p class="page-subtitle">
                    Selamat datang,
                    <strong>{{ authStore.user?.nama ?? "Kader" }}</strong> —
                    data per {{ tanggalHariIni }}
                </p>
            </div>

            <!-- Tombol refresh -->
            <button
                class="btn-refresh"
                :disabled="dashboardStore.isAnyLoading"
                aria-label="Muat ulang data dashboard"
                @click="refresh"
            >
                <i
                    class="pi pi-refresh"
                    :class="{ 'pi-spin': dashboardStore.isAnyLoading }"
                    aria-hidden="true"
                />
                <span class="btn-refresh__label">Perbarui</span>
            </button>
        </header>

        <!-- ─── Error global ───────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="hasError"
                class="error-banner"
                role="alert"
                aria-live="assertive"
            >
                <i class="pi pi-exclamation-triangle" aria-hidden="true" />
                <span>Gagal memuat sebagian data. Coba perbarui halaman.</span>
                <button
                    class="error-banner__close"
                    aria-label="Tutup peringatan"
                    @click="clearErrors"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Stat Cards ─────────────────────────────────────────── -->
        <section aria-label="Ringkasan statistik">
            <div class="stat-grid">
                <StatCard
                    label="Total Anak Terdaftar"
                    icon="pi-users"
                    color="green"
                    :value="dashboardStore.statistik.total_anak"
                    :loading="dashboardStore.loading.statistik"
                />
                <StatCard
                    label="Terindikasi Stunting"
                    icon="pi-chart-line"
                    color="red"
                    :value="dashboardStore.statistik.total_stunting"
                    :sub="`${dashboardStore.persentaseStunting}% dari total anak`"
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
            <div class="charts-grid">
                <!-- Tren gizi — lebar penuh di atas -->
                <div class="charts-grid__full">
                    <TrenGiziChart
                        v-model:bulan="selectedBulan"
                        :data="dashboardStore.trenGizi"
                        :loading="dashboardStore.loading.trenGizi"
                    />
                </div>

                <!-- Distribusi gizi + Risiko stunting — berdampingan -->
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
/* ─── Wrapper ─────────────────────────────────────────────────────── */
.dashboard {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    padding: 1.5rem;
    max-width: 1280px;
    margin: 0 auto;
}

/* ─── Header ──────────────────────────────────────────────────────── */
.dashboard-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 1rem;
    flex-wrap: wrap;
}

.page-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--color-text-heading);
    margin: 0 0 0.25rem;
}
.page-subtitle {
    font-size: 0.85rem;
    color: var(--color-text-muted);
    margin: 0;
}
.page-subtitle strong {
    color: var(--color-green-700);
    font-weight: 600;
}

/* ─── Tombol refresh ──────────────────────────────────────────────── */
.btn-refresh {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    padding: 0.5rem 1rem;
    border-radius: 0.625rem;
    border: 1px solid var(--color-input-border);
    background: white;
    color: var(--color-text-body);
    font-family: "Poppins", sans-serif;
    font-size: 0.8rem;
    font-weight: 500;
    cursor: pointer;
    transition:
        background 0.15s,
        border-color 0.15s;
    white-space: nowrap;
}
.btn-refresh:hover:not(:disabled) {
    background: #f5fbef;
    border-color: var(--color-green-700);
    color: var(--color-green-700);
}
.btn-refresh:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

@media (max-width: 480px) {
    .btn-refresh__label {
        display: none;
    }
}

/* ─── Error banner ────────────────────────────────────────────────── */
.error-banner {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1rem;
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #b91c1c;
    border-radius: 0.75rem;
    font-size: 0.85rem;
}
.error-banner__close {
    margin-left: auto;
    background: none;
    border: none;
    color: #b91c1c;
    cursor: pointer;
    padding: 0;
    line-height: 1;
}

/* ─── Stat grid ───────────────────────────────────────────────────── */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1rem;
}
@media (max-width: 1024px) {
    .stat-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}
@media (max-width: 480px) {
    .stat-grid {
        grid-template-columns: 1fr;
    }
}

/* ─── Charts grid ─────────────────────────────────────────────────── */
.charts-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 1rem;
}
.charts-grid__full {
    grid-column: 1 / -1;
}
@media (max-width: 768px) {
    .charts-grid {
        grid-template-columns: 1fr;
    }
}

/* ─── Transisi error ──────────────────────────────────────────────── */
.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.25s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-8px);
}
</style>
