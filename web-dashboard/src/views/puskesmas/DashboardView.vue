<template>
    <div class="p-6 max-w-6xl mx-auto space-y-7">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <PageHeader title="Dashboard" />

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

        <!-- ─── Rujukan aktif masuk ──────────────────────────────── -->
        <section aria-label="Rujukan aktif">
            <div class="card rounded-2xl overflow-hidden border border-slate-200/80 shadow-xs">
                <div class="flex items-center justify-between p-4 border-b border-slate-100">
                    <h2 class="text-base font-bold m-0 text-slate-800">
                        Rujukan Masuk
                    </h2>
                    <div class="bg-slate-100/90 p-1 rounded-2xl flex gap-1 border border-slate-200/70">
                        <span
                            class="flex items-center gap-2 px-3.5 py-1.5 rounded-xl text-xs font-semibold bg-emerald-600 text-white shadow-xs"
                        >
                            <span>Aktif</span>
                            <span
                                class="min-w-5 px-1.5 py-0.5 rounded-full text-[10px] font-bold text-center bg-white/20 text-white"
                            >
                                {{ rujukanStore.rujukanAktif.length }}
                            </span>
                        </span>
                        <button
                            type="button"
                            class="flex items-center px-3.5 py-1.5 rounded-xl text-xs font-semibold text-slate-600 hover:text-slate-900 hover:bg-slate-200/60 transition-all cursor-pointer whitespace-nowrap border-0 bg-transparent"
                            @click="router.push({ name: 'PuskesmasRujukan' })"
                        >
                            <span>Lihat Semua</span>
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
                        class="pi pi-check-circle text-3xl text-emerald-600"
                        aria-hidden="true"
                    />
                    <p class="text-sm m-0 text-slate-500">
                        Tidak ada rujukan aktif saat ini
                    </p>
                </div>

                <!-- List rujukan aktif (max 5) -->
                <div
                    v-else
                    class="divide-y divide-slate-100"
                >
                    <div
                        v-for="r in rujukanStore.rujukanAktif.slice(0, 5)"
                        :key="r.id"
                        class="flex items-center justify-between p-4 hover:bg-slate-50/80 transition-colors"
                    >
                        <div class="space-y-0.5 min-w-0">
                            <p class="text-sm font-semibold m-0 text-slate-900 truncate">
                                {{ r.nama_anak }}
                            </p>
                            <p class="text-xs m-0 text-slate-500 truncate">
                                {{ r.nama_kader ? `Kader: ${r.nama_kader}` : (r.nama_orang_tua ? `Orang Tua: ${r.nama_orang_tua}` : "Posyandu") }} —
                                {{ formatTanggal(r.created_at) }}
                            </p>
                        </div>
                        <div class="flex items-center gap-2 shrink-0">
                            <StatusBadge type="rujukan" :value="r.status" />
                            <button
                                type="button"
                                class="text-xs font-semibold px-3 py-1.5 rounded-lg transition-colors cursor-pointer bg-slate-100 hover:bg-slate-200 text-slate-700 inline-flex items-center gap-1 border-0"
                                @click="
                                    router.push({
                                        name: 'PuskesmasRujukan',
                                        query: { id: r.id },
                                    })
                                "
                            >
                                <i class="pi pi-eye text-xs" aria-hidden="true" />
                                <span>Detail</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ─── Grafik dan visualisasi ───────────────────────────── -->
        <section aria-label="Grafik dan visualisasi" class="space-y-6">
            <!-- Tren gizi — lebar penuh di atas -->
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
import PageHeader from "@/components/ui/PageHeader.vue";
import { useRouter } from "vue-router";
import { useDashboardStore } from "@/stores/dashboardStore";
import { useRujukanStore } from "@/stores/rujukanStore";
import StatCard from "@/components/ui/StatCard.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import TrenGiziChart from "@/components/charts/TrenGiziChart.vue";
import DistribusiGiziChart from "@/components/charts/DistribusiGiziChart.vue";
import RisikoChart from "@/components/charts/RisikoChart.vue";

const router = useRouter();
const dashboardStore = useDashboardStore();
const rujukanStore = useRujukanStore();

const selectedBulan = ref(6);

watch(selectedBulan, (bulan) => dashboardStore.fetchTrenGizi(bulan));

const hasError = computed(() =>
    Object.values(dashboardStore.error).some(Boolean),
);
const clearErrors = () => {
    Object.keys(dashboardStore.error).forEach((k) => {
        dashboardStore.error[k] = null;
    });
};

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
    border: 1px solid rgba(226, 232, 240, 0.85);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03), 0 1px 2px rgba(0, 0, 0, 0.02);
}
</style>
