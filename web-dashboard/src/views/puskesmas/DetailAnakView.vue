<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <button class="back-button" @click="router.push({ name: 'PuskesmasAnak' })">
            <i class="pi pi-arrow-left" aria-hidden="true" />
            Kembali ke Data Anak
        </button>

        <div v-if="store.loading.anakDetail" class="space-y-4">
            <div class="skeleton h-28 rounded-2xl" />
            <div class="skeleton h-24 rounded-2xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <div
            v-else-if="store.error.anakDetail"
            class="card p-10 rounded-2xl flex flex-col items-center gap-3 text-center"
            role="alert"
        >
            <i class="pi pi-exclamation-circle text-4xl text-red-600" />
            <p class="text-sm m-0" style="color: var(--color-text-muted)">
                {{ store.error.anakDetail }}
            </p>
            <button class="btn-primary" @click="loadData">Coba Lagi</button>
        </div>

        <template v-else-if="store.anakDetail">
            <AnakCard
                :anak="store.anakDetail"
                :status-tbu-terakhir="store.pengukuranTerakhir?.status_tbu"
            >
                <template #actions>
                    <button
                        class="btn-primary flex items-center gap-2"
                        :disabled="downloading"
                        @click="downloadLaporan"
                    >
                        <i
                            class="pi"
                            :class="downloading ? 'pi-spinner pi-spin' : 'pi-file-pdf'"
                            aria-hidden="true"
                        />
                        {{ downloading ? "Menyiapkan..." : "Unduh Laporan" }}
                    </button>
                </template>
            </AnakCard>

            <div
                v-if="downloadMessage.text"
                class="message"
                :class="`message-${downloadMessage.type}`"
                role="status"
            >
                <i
                    :class="downloadMessage.type === 'success'
                        ? 'pi pi-check-circle'
                        : 'pi pi-exclamation-circle'"
                    aria-hidden="true"
                />
                {{ downloadMessage.text }}
            </div>

            <section v-if="store.pengukuranTerakhir" class="grid grid-cols-2 lg:grid-cols-4 gap-3">
                <div class="summary-card">
                    <span>Pengukuran Terakhir</span>
                    <strong>{{ formatTanggal(store.pengukuranTerakhir.tanggal_ukur) }}</strong>
                </div>
                <div class="summary-card">
                    <span>Berat / Tinggi</span>
                    <strong>{{ store.pengukuranTerakhir.berat_badan }} kg / {{ store.pengukuranTerakhir.tinggi_badan }} cm</strong>
                </div>
                <div class="summary-card">
                    <span>Status TB/U</span>
                    <StatusBadge type="antropometri" :value="store.pengukuranTerakhir.status_tbu" />
                </div>
                <div class="summary-card">
                    <span>Prioritas</span>
                    <StatusBadge type="prioritas" :value="store.pengukuranTerakhir.kategori_prioritas" />
                </div>
            </section>

            <section class="card rounded-2xl overflow-hidden">
                <div class="p-4 flex items-center justify-between gap-3">
                    <div>
                        <h2 class="text-base font-bold m-0" style="color: var(--color-text-heading)">
                            Riwayat Pengukuran
                        </h2>
                        <p class="text-xs mt-1 mb-0" style="color: var(--color-text-muted)">
                            Data teknis diurutkan dari pengukuran terbaru.
                        </p>
                    </div>
                    <span class="count-badge">{{ store.riwayatPengukuran.length }} data</span>
                </div>

                <div
                    v-if="store.riwayatPengukuran.length === 0"
                    class="p-12 flex flex-col items-center gap-2 text-center"
                >
                    <i class="pi pi-chart-line text-4xl" style="color: var(--color-text-muted)" />
                    <p class="text-sm m-0" style="color: var(--color-text-muted)">
                        Anak ini belum memiliki data pengukuran.
                    </p>
                </div>

                <div v-else class="overflow-x-auto">
                    <table class="w-full text-sm" aria-label="Riwayat pengukuran anak">
                        <thead>
                            <tr class="table-head">
                                <th class="th-cell">Tanggal</th>
                                <th class="th-cell">BB / TB</th>
                                <th class="th-cell">Status Antropometri</th>
                                <th class="th-cell">Prioritas</th>
                                <th class="th-cell text-right">Skor SAW</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(item, index) in store.riwayatPengukuran"
                                :key="item.id"
                                class="table-row"
                                :class="{ 'bg-green-soft': index % 2 !== 0 }"
                            >
                                <td class="px-4 py-3 whitespace-nowrap">
                                    {{ formatTanggal(item.tanggal_ukur) }}
                                </td>
                                <td class="px-4 py-3 whitespace-nowrap font-semibold">
                                    {{ item.berat_badan }} kg / {{ item.tinggi_badan }} cm
                                </td>
                                <td class="px-4 py-3 min-w-72">
                                    <div class="grid grid-cols-2 gap-x-3 gap-y-1 text-xs">
                                        <span v-for="status in statusItems(item)" :key="status.label">
                                            <strong>{{ status.label }}:</strong>
                                            {{ formatStatusAntropometri(status.value) }}
                                        </span>
                                    </div>
                                </td>
                                <td class="px-4 py-3">
                                    <StatusBadge type="prioritas" :value="item.kategori_prioritas" />
                                </td>
                                <td class="px-4 py-3 text-right font-mono">
                                    {{ formatSkor(item.skor_saw) }}
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>

            <section class="card rounded-2xl overflow-hidden">
                <div class="p-4 flex items-center justify-between gap-3">
                    <div>
                        <h2 class="text-base font-bold m-0" style="color: var(--color-text-heading)">
                            Riwayat Pemberian
                        </h2>
                        <p class="text-xs mt-1 mb-0" style="color: var(--color-text-muted)">
                            Vitamin, obat cacing, dan makanan tambahan yang telah dicatat Kader.
                        </p>
                    </div>
                    <span class="count-badge">{{ store.riwayatPemberian.length }} data</span>
                </div>

                <div v-if="store.loading.pemberian" class="p-4 space-y-3">
                    <div v-for="item in 3" :key="item" class="skeleton h-10 rounded-xl" />
                </div>

                <div v-else-if="store.error.pemberian" class="p-8 text-center" role="alert">
                    <p class="text-sm mt-0 mb-3 text-red-700">{{ store.error.pemberian }}</p>
                    <button class="btn-primary" @click="loadPemberian">Coba Lagi</button>
                </div>

                <div
                    v-else-if="store.riwayatPemberian.length === 0"
                    class="p-12 flex flex-col items-center gap-2 text-center"
                >
                    <i class="pi pi-box text-4xl" style="color: var(--color-text-muted)" />
                    <p class="text-sm m-0" style="color: var(--color-text-muted)">
                        Anak ini belum memiliki riwayat pemberian.
                    </p>
                </div>

                <div v-else class="overflow-x-auto">
                    <table class="w-full text-sm" aria-label="Riwayat pemberian anak">
                        <thead>
                            <tr class="table-head">
                                <th class="th-cell">Tanggal</th>
                                <th class="th-cell">Jenis</th>
                                <th class="th-cell">Dosis</th>
                                <th class="th-cell">Keterangan</th>
                                <th class="th-cell">Dicatat Oleh</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(item, index) in store.riwayatPemberian"
                                :key="item.id"
                                class="table-row"
                                :class="{ 'bg-green-soft': index % 2 !== 0 }"
                            >
                                <td class="px-4 py-3 whitespace-nowrap">{{ formatTanggal(item.tanggal_pemberian) }}</td>
                                <td class="px-4 py-3 font-semibold">{{ LABEL_JENIS[item.jenis] ?? item.jenis }}</td>
                                <td class="px-4 py-3">{{ item.dosis ?? "—" }}</td>
                                <td class="px-4 py-3 min-w-48">{{ item.keterangan ?? "—" }}</td>
                                <td class="px-4 py-3 whitespace-nowrap">{{ item.dicatat_oleh ?? "—" }}</td>
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
import { formatTanggal } from "@/utils/format";
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
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.back-button {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0;
    border: 0;
    background: transparent;
    color: var(--color-green-700);
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 500;
}
.btn-primary {
    border: 0;
    border-radius: 0.625rem;
    background: var(--color-green-700);
    color: white;
    cursor: pointer;
    font-size: 0.75rem;
    font-weight: 600;
    padding: 0.625rem 0.875rem;
}
.btn-primary:disabled { cursor: not-allowed; opacity: 0.6; }
.summary-card {
    display: flex;
    min-height: 5.75rem;
    flex-direction: column;
    justify-content: center;
    gap: 0.5rem;
    padding: 1rem;
    border: 1px solid var(--color-card-border);
    border-radius: 1rem;
    background: white;
}
.summary-card > span:first-child {
    color: var(--color-text-muted);
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
}
.summary-card strong { color: var(--color-text-heading); font-size: 0.8rem; }
.count-badge {
    padding: 0.25rem 0.625rem;
    border-radius: 999px;
    background: var(--color-green-100);
    color: var(--color-green-700);
    font-size: 0.7rem;
    font-weight: 600;
}
.table-head, .bg-green-soft { background: var(--color-green-50); }
.th-cell {
    padding: 0.75rem 1rem;
    text-align: left;
    color: var(--color-text-muted);
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
.table-row:hover { background: var(--color-green-50); }
.message {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    border-radius: 0.75rem;
    font-size: 0.75rem;
}
.message-success { color: #166534; background: #f0fdf4; border: 1px solid #bbf7d0; }
.message-error { color: #b91c1c; background: #fef2f2; border: 1px solid #fecaca; }
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
