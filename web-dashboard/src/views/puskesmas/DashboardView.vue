<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
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
                        authStore.namaLengkap
                    }}</strong>
                    — data per {{ tanggalHariIni }}
                </p>
            </div>
            <button
                class="btn-refresh flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium border transition-all"
                :disabled="dashboardStore.isAnyLoading"
                aria-label="Muat ulang data"
                @click="refresh"
            >
                <i
                    class="pi pi-refresh"
                    :class="{ 'pi-spin': dashboardStore.isAnyLoading }"
                    aria-hidden="true"
                />
                Perbarui
            </button>
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
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
            >
                <i
                    class="pi pi-exclamation-triangle flex-shrink-0"
                    aria-hidden="true"
                />
                <span>Gagal memuat sebagian data. Coba perbarui halaman.</span>
                <button
                    class="ml-auto bg-transparent border-0 cursor-pointer"
                    style="color: #b91c1c"
                    @click="clearErrors"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Stat cards ───────────────────────────────────────── -->
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

        <!-- ─── Rujukan aktif masuk ──────────────────────────────── -->
        <section aria-label="Rujukan aktif">
            <div class="card rounded-2xl overflow-hidden">
                <div class="flex items-center justify-between p-4">
                    <h2
                        class="text-base font-semibold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        <i
                            class="pi pi-send mr-1.5"
                            style="color: var(--color-green-700)"
                            aria-hidden="true"
                        />
                        Rujukan Masuk
                    </h2>
                    <div class="flex items-center gap-2">
                        <span
                            class="text-xs px-2 py-1 rounded-full font-medium"
                            style="background: #fef3c7; color: #d97706"
                        >
                            {{ rujukanStore.rujukanAktif.length }} aktif
                        </span>
                        <button
                            class="text-xs font-medium px-3 py-1.5 rounded-lg transition-colors"
                            style="
                                background: var(--color-green-100);
                                color: var(--color-green-700);
                                border: none;
                                cursor: pointer;
                            "
                            @click="router.push({ name: 'PuskesmasRujukan' })"
                        >
                            Lihat Semua
                        </button>
                    </div>
                </div>

                <!-- Loading -->
                <div v-if="rujukanStore.loading.fetchAll" class="p-4 space-y-3">
                    <div
                        v-for="i in 3"
                        :key="i"
                        class="skeleton h-14 rounded-xl"
                    />
                </div>

                <!-- Empty -->
                <div
                    v-else-if="rujukanStore.rujukanAktif.length === 0"
                    class="flex flex-col items-center py-10 gap-2"
                >
                    <i
                        class="pi pi-check-circle text-3xl"
                        style="color: var(--color-green-600)"
                        aria-hidden="true"
                    />
                    <p
                        class="text-sm m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Tidak ada rujukan aktif saat ini
                    </p>
                </div>

                <!-- List rujukan aktif (max 5) -->
                <div
                    v-else
                    class="divide-y"
                    style="border-color: var(--color-input-border)"
                >
                    <div
                        v-for="r in rujukanStore.rujukanAktif.slice(0, 5)"
                        :key="r.id"
                        class="flex items-center gap-4 px-4 py-3 transition-colors cursor-pointer hover:bg-slate-50"
                        @click="router.push({ name: 'PuskesmasRujukan' })"
                    >
                        <div
                            class="w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold text-white flex-shrink-0"
                            style="background: var(--color-green-700)"
                            aria-hidden="true"
                        >
                            {{ r.nama_anak?.charAt(0).toUpperCase() }}
                        </div>
                        <div class="flex-1 min-w-0">
                            <p
                                class="text-sm font-semibold m-0 truncate"
                                style="color: var(--color-text-heading)"
                            >
                                {{ r.nama_anak }}
                            </p>
                            <p
                                class="text-xs m-0"
                                style="color: var(--color-text-muted)"
                            >
                                {{ r.nama_orang_tua }} •
                                {{ formatTanggal(r.created_at) }}
                            </p>
                        </div>
                        <div class="flex items-center gap-2 flex-shrink-0">
                            <StatusBadge
                                type="prioritas"
                                :value="r.prioritas_pemantauan?.kategori"
                            />
                            <StatusBadge type="rujukan" :value="r.status" />
                        </div>
                    </div>
                </div>

                <!-- Tampilkan lebih -->
                <div
                    v-if="rujukanStore.rujukanAktif.length > 5"
                    class="px-4 py-3 text-center border-t"
                    style="border-color: var(--color-input-border)"
                >
                    <button
                        class="text-sm font-medium"
                        style="
                            color: var(--color-green-700);
                            background: none;
                            border: none;
                            cursor: pointer;
                        "
                        @click="router.push({ name: 'PuskesmasRujukan' })"
                    >
                        Lihat {{ rujukanStore.rujukanAktif.length - 5 }} rujukan
                        lainnya →
                    </button>
                </div>
            </div>
        </section>

        <!-- ─── Charts ───────────────────────────────────────────── -->
        <section aria-label="Grafik dan visualisasi">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div class="lg:col-span-2">
                    <TrenGiziChart
                        v-model:bulan="selectedBulan"
                        :data="dashboardStore.trenGizi"
                        :loading="dashboardStore.loading.trenGizi"
                    />
                </div>
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
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/authStore";
import { useDashboardStore } from "@/stores/dashboardStore";
import { useRujukanStore } from "@/stores/rujukanStore";
import StatCard from "@/components/ui/StatCard.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import TrenGiziChart from "@/components/charts/TrenGiziChart.vue";
import DistribusiGiziChart from "@/components/charts/DistribusiGiziChart.vue";
import RisikoChart from "@/components/charts/RisikoChart.vue";

const router = useRouter();
const authStore = useAuthStore();
const dashboardStore = useDashboardStore();
const rujukanStore = useRujukanStore();

const selectedBulan = ref(6);

watch(selectedBulan, (bulan) => dashboardStore.fetchTrenGizi(bulan));

const tanggalHariIni = computed(() =>
    new Date().toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    }),
);

const hasError = computed(() =>
    Object.values(dashboardStore.error).some(Boolean),
);
const clearErrors = () =>
    Object.keys(dashboardStore.error).forEach((k) => {
        dashboardStore.error[k] = null;
    });

const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

const refresh = () => {
    dashboardStore.fetchAll(selectedBulan.value);
    rujukanStore.fetchAllRujukan({ page: 1 });
};

onMounted(refresh);
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
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
