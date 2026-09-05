<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Back Navigation ──────────────────────────────────── -->
        <div class="flex items-center">
            <button
                type="button"
                class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 hover:text-slate-900 transition-all shadow-2xs cursor-pointer"
                @click="router.push({ name: 'PuskesmasAnak' })"
            >
                <i class="pi pi-arrow-left text-xs text-slate-400" />
                <span>Kembali ke Data Anak</span>
            </button>
        </div>

        <!-- ─── Loading State ────────────────────────────────────── -->
        <div v-if="store.loading.anakDetail" class="space-y-4">
            <div class="skeleton h-36 rounded-2xl" />
            <div class="skeleton h-20 rounded-2xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <!-- ─── Error State ──────────────────────────────────────── -->
        <div
            v-else-if="store.error.anakDetail"
            class="bg-white p-8 rounded-2xl border border-red-100 flex flex-col items-center gap-3 text-center shadow-xs"
            role="alert"
        >
            <i class="pi pi-exclamation-circle text-4xl text-red-600" />
            <p class="text-sm m-0 text-slate-500">
                {{ store.error.anakDetail }}
            </p>
            <button
                class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white cursor-pointer"
                @click="loadData"
            >
                Coba Lagi
            </button>
        </div>

        <template v-else-if="store.anakDetail">
            <!-- ─── 1. Hero Card Info Anak ───────────────────────── -->
            <AnakCard
                :anak="store.anakDetail"
                :status-tbu-terakhir="store.pengukuranTerakhir?.status_tbu"
            >
                <template #actions>
                    <button
                        type="button"
                        class="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-xs disabled:opacity-60 cursor-pointer"
                        :disabled="downloading"
                        title="Unduh Laporan Medis Anak dalam format PDF"
                        @click="downloadLaporan"
                    >
                        <i
                            class="pi text-xs"
                            :class="downloading ? 'pi-spinner pi-spin' : 'pi-file-pdf'"
                            aria-hidden="true"
                        />
                        <span>{{ downloading ? "Menyiapkan PDF..." : "Unduh Laporan PDF" }}</span>
                    </button>
                </template>
            </AnakCard>

            <!-- ─── Download Message Alert ───────────────────────── -->
            <div
                v-if="downloadMessage.text"
                class="flex items-center gap-2.5 px-4 py-3 rounded-xl text-xs font-medium border transition-all"
                :class="
                    downloadMessage.type === 'success'
                        ? 'bg-emerald-50 text-emerald-800 border-emerald-200/80'
                        : 'bg-red-50 text-red-800 border-red-200/80'
                "
                role="status"
            >
                <i
                    :class="
                        downloadMessage.type === 'success'
                            ? 'pi pi-check-circle text-emerald-600'
                            : 'pi pi-exclamation-circle text-red-600'
                    "
                    aria-hidden="true"
                />
                <span>{{ downloadMessage.text }}</span>
            </div>

            <!-- ─── 2. Vital Stats Row (Pengukuran Terakhir) ──────── -->
            <section
                v-if="store.pengukuranTerakhir"
                class="space-y-2.5"
                aria-label="Ringkasan pengukuran terakhir"
            >
                <div class="flex items-center gap-2 px-0.5">
                    <span class="w-2 h-2 rounded-full bg-emerald-500" />
                    <h2 class="text-xs font-bold uppercase tracking-wider text-slate-600 m-0">
                        Pengukuran Terakhir
                    </h2>
                </div>

                <div class="grid grid-cols-2 lg:grid-cols-4 gap-3.5">
                <!-- Tanggal Pengukuran Terakhir -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-slate-50 text-slate-600 border border-slate-200/80 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-calendar text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400">Pengukuran Terakhir</div>
                        <div class="text-xs font-bold text-slate-800 truncate">
                            {{ formatTanggal(store.pengukuranTerakhir.tanggal_ukur) }}
                        </div>
                    </div>
                </div>

                <!-- Berat / Tinggi -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-sky-50 text-sky-600 border border-sky-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-chart-bar text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400">Berat & Tinggi</div>
                        <div class="text-sm font-bold text-slate-800 truncate">
                            {{ formatUkuran(store.pengukuranTerakhir.berat_badan) }} kg /
                            {{ formatUkuran(store.pengukuranTerakhir.tinggi_badan) }} cm
                        </div>
                    </div>
                </div>

                <!-- Status TB/U -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 border border-amber-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-heart text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400 mb-0.5">Tinggi Badan / Umur</div>
                        <StatusBadge
                            type="antropometri"
                            :value="store.pengukuranTerakhir.status_tbu"
                        />
                    </div>
                </div>

                <!-- Prioritas Pemantauan -->
                <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-2xs flex items-center gap-3.5">
                    <div class="w-10 h-10 rounded-xl bg-rose-50 text-rose-600 border border-rose-100 flex items-center justify-center flex-shrink-0">
                        <i class="pi pi-exclamation-circle text-sm" />
                    </div>
                    <div class="min-w-0 flex-1">
                        <div class="text-[11px] font-medium text-slate-400 mb-0.5">Prioritas Pemantauan</div>
                        <StatusBadge
                            type="prioritas"
                            :value="store.pengukuranTerakhir.prioritas_pemantauan?.kategori"
                        />
                    </div>
                </div>
                </div>
            </section>

            <!-- ─── 3. Tabel Riwayat Pengukuran ──────────────────── -->
            <section class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                <div class="p-4 flex items-center justify-between gap-3 border-b border-slate-100">
                    <div>
                        <h2 class="text-sm font-bold text-slate-800 m-0">
                            Riwayat Pengukuran Antropometri
                        </h2>
                        <p class="text-xs text-slate-400 mt-0.5 mb-0">
                            Data teknis diurutkan dari pemeriksaan terbaru
                        </p>
                    </div>
                    <span
                        class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                    >
                        {{ store.riwayatPengukuran.length }} data
                    </span>
                </div>

                <div
                    v-if="store.riwayatPengukuran.length === 0"
                    class="p-12 flex flex-col items-center gap-2 text-center"
                >
                    <i class="pi pi-chart-line text-3xl text-slate-300" />
                    <p class="text-sm text-slate-500 m-0">
                        Anak ini belum memiliki data pengukuran.
                    </p>
                </div>

                <div v-else class="overflow-x-auto">
                    <table class="w-full text-sm" aria-label="Riwayat pengukuran anak">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-100">
                                <th class="th-cell">Tanggal</th>
                                <th class="th-cell">BB / TB</th>
                                <th class="th-cell">Status Antropometri</th>
                                <th class="th-cell">Prioritas</th>
                                <th class="th-cell text-right">Skor SAW</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 bg-white">
                            <tr
                                v-for="item in store.riwayatPengukuran"
                                :key="item.id"
                                class="hover:bg-slate-50/80 transition-colors"
                            >
                                <td class="px-4 py-3.5 whitespace-nowrap text-sm text-slate-700 font-medium">
                                    {{ formatTanggal(item.tanggal_ukur) }}
                                </td>
                                <td class="px-4 py-3.5 whitespace-nowrap font-semibold text-slate-800">
                                    {{ formatUkuran(item.berat_badan) }} kg /
                                    {{ formatUkuran(item.tinggi_badan) }} cm
                                </td>
                                <td class="px-4 py-3.5 min-w-72">
                                    <div class="grid grid-cols-2 gap-x-3 gap-y-1 text-xs">
                                        <span
                                            v-for="status in statusItems(item)"
                                            :key="status.label"
                                            class="text-slate-600"
                                        >
                                            <span class="font-semibold text-slate-500">{{ status.label }}:</span>
                                            {{ formatStatusAntropometri(status.value) }}
                                        </span>
                                    </div>
                                </td>
                                <td class="px-4 py-3.5">
                                    <StatusBadge
                                        type="prioritas"
                                        :value="item.prioritas_pemantauan?.kategori"
                                    />
                                </td>
                                <td class="px-4 py-3.5 text-right font-mono text-xs font-semibold text-slate-700">
                                    {{ formatSkor(item.skor_saw) }}
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- ─── 4. Tabel Riwayat Pemberian ───────────────────── -->
            <section class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
                <div class="p-4 flex items-center justify-between gap-3 border-b border-slate-100">
                    <div>
                        <h2 class="text-sm font-bold text-slate-800 m-0">
                            Riwayat Pemberian PMT & Vitamin
                        </h2>
                        <p class="text-xs text-slate-400 mt-0.5 mb-0">
                            Vitamin, obat cacing, dan makanan tambahan yang telah dicatat Kader
                        </p>
                    </div>
                    <span
                        class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                    >
                        {{ store.riwayatPemberian.length }} data
                    </span>
                </div>

                <div v-if="store.loading.pemberian" class="p-4 space-y-3">
                    <div v-for="item in 3" :key="item" class="skeleton h-10 rounded-xl" />
                </div>

                <div v-else-if="store.error.pemberian" class="p-8 text-center" role="alert">
                    <p class="text-sm mt-0 mb-3 text-red-600">{{ store.error.pemberian }}</p>
                    <button
                        class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white cursor-pointer"
                        @click="loadPemberian"
                    >
                        Coba Lagi
                    </button>
                </div>

                <div
                    v-else-if="store.riwayatPemberian.length === 0"
                    class="p-12 flex flex-col items-center gap-2 text-center"
                >
                    <i class="pi pi-box text-3xl text-slate-300" />
                    <p class="text-sm text-slate-500 m-0">
                        Anak ini belum memiliki riwayat pemberian.
                    </p>
                </div>

                <div v-else class="overflow-x-auto">
                    <table class="w-full text-sm" aria-label="Riwayat pemberian anak">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-100">
                                <th class="th-cell">Tanggal</th>
                                <th class="th-cell">Jenis Pemberian</th>
                                <th class="th-cell">Dosis</th>
                                <th class="th-cell">Keterangan</th>
                                <th class="th-cell">Dicatat Oleh</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 bg-white">
                            <tr
                                v-for="item in store.riwayatPemberian"
                                :key="item.id"
                                class="hover:bg-slate-50/80 transition-colors"
                            >
                                <td class="px-4 py-3.5 whitespace-nowrap text-sm text-slate-700 font-medium">
                                    {{ formatTanggal(item.tanggal_pemberian) }}
                                </td>
                                <td class="px-4 py-3.5 font-semibold text-slate-800">
                                    {{ LABEL_JENIS[item.jenis] ?? item.jenis }}
                                </td>
                                <td class="px-4 py-3.5 text-slate-700">{{ item.dosis ?? "—" }}</td>
                                <td class="px-4 py-3.5 min-w-48 text-slate-500">{{ item.keterangan ?? "—" }}</td>
                                <td class="px-4 py-3.5 whitespace-nowrap text-slate-500">{{ item.dicatat_oleh ?? "—" }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </template>
    </div>
</template>

<script setup>
import { onMounted, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { usePuskesmasStore } from "@/stores/puskesmasStore";
import { LABEL_JENIS } from "@/stores/pemberianStore";
import laporanService, {
    getDownloadErrorMessage,
    savePdfResponse,
} from "@/services/laporanService";
import { formatTanggal, formatUkuran } from "@/utils/format";
import { formatStatusAntropometri } from "@/utils/antropometri";
import AnakCard from "@/components/cards/AnakCard.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";

const route = useRoute();
const router = useRouter();
const store = usePuskesmasStore();
const downloading = ref(false);
const downloadMessage = reactive({ type: "error", text: "" });

const loadPemberian = () => store.fetchPemberian(route.params.id);
const loadData = () =>
    Promise.all([
        store.fetchDetailAnak(route.params.id),
        loadPemberian(),
    ]);

const statusItems = (item) => [
    { label: "BB/U", value: item.status_bbu },
    { label: "TB/U", value: item.status_tbu },
    { label: "BB/TB", value: item.status_bbtb },
    { label: "IMT/U", value: item.status_imtu },
];

const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);

const downloadLaporan = async () => {
    if (downloading.value) return;
    downloading.value = true;
    downloadMessage.text = "";
    try {
        const response = await laporanService.downloadIndividual(route.params.id);
        const filename = savePdfResponse(
            response,
            `laporan-teknis-${store.anakDetail.nama}.pdf`,
        );
        downloadMessage.type = "success";
        downloadMessage.text = `${filename} berhasil diunduh.`;
    } catch (error) {
        downloadMessage.type = "error";
        downloadMessage.text = await getDownloadErrorMessage(
            error,
            "Gagal mengunduh laporan anak",
        );
    } finally {
        downloading.value = false;
    }
};

onMounted(loadData);
</script>

<style scoped>
.th-cell {
    padding: 0.75rem 1rem;
    text-align: left;
    color: #1e293b;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}
</style>

