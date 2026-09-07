<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-800 m-0 tracking-tight">
                    Laporan & Rekapitulasi
                </h1>
            </div>
            <div class="flex items-center gap-2 self-start sm:self-auto">
                <div class="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-slate-200/80 shadow-2xs text-xs text-slate-600 font-medium">
                    <i class="pi pi-calendar text-emerald-600 text-xs" />
                    <span>Hari ini: <strong class="text-slate-800">{{ formatTanggal(toLocalDateStr(todayDate)) }}</strong></span>
                </div>
            </div>
        </div>

        <!-- ─── Grid 2 Kolom: Individual & Rekap ─────────────────── -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-5 sm:gap-6 items-stretch">
            <!-- ── Kolom Kiri: Laporan Individual ───────────────── -->
            <section class="card rounded-2xl p-5 md:p-6 flex flex-col justify-between h-full">
                <div class="space-y-5 flex flex-col flex-1">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 border border-blue-100 flex items-center justify-center shrink-0">
                            <i class="pi pi-user text-base" />
                        </div>
                        <h2 class="text-base sm:text-lg font-bold text-slate-800 m-0">
                            Laporan Individual Anak
                        </h2>
                    </div>

                    <!-- Form Laporan Individual -->
                    <form class="flex flex-col justify-between flex-1 space-y-4" @submit.prevent="downloadIndividual">
                        <div
                            v-if="selectedAnak || loadingAnak || anakError || anakOptions.length"
                            class="space-y-3.5"
                        >
                            <AnakSearchSelect
                                v-if="!selectedAnak"
                                ref="individualSelect"
                                :model-value="selectedAnakId"
                                input-id="pilih-anak-laporan"
                                :options="anakOptions"
                                :loading="loadingAnak"
                                :error="anakError"
                                :invalid="individualSelectionError"
                                described-by="individual-message"
                                @update:model-value="handleAnakSelected"
                                @retry="loadAnak"
                            />

                            <!-- Kartu Profil Anak Terpilih -->
                            <div
                                v-else
                                class="p-3.5 sm:p-4 rounded-xl bg-slate-50/80 border border-slate-200/80 flex items-center justify-between gap-3.5 flex-wrap sm:flex-nowrap shadow-2xs"
                            >
                                <div class="flex items-center gap-3 min-w-0">
                                    <div
                                        class="w-12 h-12 rounded-xl flex items-center justify-center font-bold text-sm shrink-0 shadow-2xs"
                                        :class="selectedAnak.jenis_kelamin === 'L' ? 'bg-blue-100 text-blue-700' : 'bg-rose-100 text-rose-700'"
                                    >
                                        {{ getInitials(selectedAnak.nama) }}
                                    </div>
                                    <div class="min-w-0">
                                        <div class="flex items-center gap-2 flex-wrap">
                                            <span class="text-sm font-bold text-slate-800 truncate">{{ selectedAnak.nama }}</span>
                                            <span
                                                class="text-[11px] px-2 py-0.5 rounded-md font-semibold shrink-0"
                                                :class="selectedAnak.jenis_kelamin === 'L' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-rose-50 text-rose-700 border border-rose-200'"
                                            >
                                                {{ selectedAnak.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}
                                            </span>
                                        </div>
                                        <p class="text-xs text-slate-500 mt-1 mb-0 truncate">
                                            <span class="text-slate-600 font-medium">Orang Tua:</span> {{ selectedAnak.nama_orang_tua || '—' }}
                                        </p>
                                    </div>
                                </div>
                                <button
                                    type="button"
                                    class="text-xs font-semibold px-3 py-1.5 rounded-lg bg-white border border-slate-200 hover:bg-slate-100 text-slate-600 transition-colors shrink-0 cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                                    title="Ganti anak yang dipilih"
                                    @click="handleGantiAnak"
                                >
                                    <i class="pi pi-sync text-[10px]" />
                                    <span>Ganti</span>
                                </button>
                            </div>
                        </div>

                        <!-- State: Tidak Ada Data Anak -->
                        <div v-else class="p-6 rounded-xl border border-dashed border-slate-200 text-center bg-slate-50/50">
                            <i
                                class="pi pi-users text-3xl text-slate-300"
                                aria-hidden="true"
                            />
                            <p class="text-xs font-medium text-slate-500 mt-2 mb-0">
                                Belum ada data anak yang dapat dibuatkan laporan.
                            </p>
                        </div>

                        <!-- Bagian Bawah: Pesan & Tombol Unduh -->
                        <div class="space-y-3 pt-2 mt-auto">
                            <!-- Alert Feedback Individual -->
                            <div
                                v-if="individualMessage.text"
                                id="individual-message"
                                class="flex items-center gap-2 p-3 rounded-xl text-xs"
                                :class="individualMessage.type === 'success' ? 'text-emerald-800 bg-emerald-50 border border-emerald-200' : 'text-red-700 bg-red-50 border border-red-200'"
                                role="status"
                            >
                                <i
                                    class="shrink-0"
                                    :class="individualMessage.type === 'success'
                                        ? 'pi pi-check-circle text-emerald-600'
                                        : 'pi pi-exclamation-circle text-red-500'"
                                    aria-hidden="true"
                                />
                                <span>{{ individualMessage.text }}</span>
                            </div>

                            <!-- Tombol Unduh Individual -->
                            <button
                                type="submit"
                                class="btn-primary w-full rounded-xl px-4 py-3 text-sm font-semibold text-white flex items-center justify-center gap-2 shadow-sm transition-all"
                                :aria-busy="downloading.individual"
                            >
                                <i
                                    class="pi"
                                    :class="downloading.individual
                                        ? 'pi-spinner pi-spin'
                                        : 'pi-download'"
                                    aria-hidden="true"
                                />
                                <span>
                                    {{ downloading.individual
                                        ? "Menyiapkan laporan..."
                                        : "Unduh Laporan Individual" }}
                                </span>
                            </button>
                        </div>
                    </form>
                </div>
            </section>

            <!-- ── Kolom Kanan: Laporan Rekap Periode ────────────── -->
            <section class="card rounded-2xl p-5 md:p-6 flex flex-col justify-between h-full">
                <div class="space-y-5 flex flex-col flex-1">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center shrink-0">
                            <i class="pi pi-chart-bar text-base" />
                        </div>
                        <h2 class="text-base sm:text-lg font-bold text-slate-800 m-0">
                            Laporan Rekap Periode
                        </h2>
                    </div>

                    <!-- Form Laporan Rekap -->
                    <form class="flex flex-col justify-between flex-1 space-y-4" @submit.prevent="downloadRekap">
                        <div class="space-y-3.5">
                            <!-- Quick Preset Rentang Waktu -->
                            <div class="space-y-1.5">
                                <label class="block text-xs font-semibold text-slate-700">
                                    Pilihan Rentang Cepat
                                </label>
                                <div class="flex items-center gap-1.5 flex-wrap">
                                    <button
                                        type="button"
                                        class="px-2.5 py-1 rounded-lg text-xs font-medium border transition-colors cursor-pointer"
                                        :class="isPresetActive('bulan_ini') ? 'bg-emerald-50 text-emerald-700 border-emerald-300 font-semibold' : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'"
                                        @click="setPresetPeriode('bulan_ini')"
                                    >
                                        Bulan Ini
                                    </button>
                                    <button
                                        type="button"
                                        class="px-2.5 py-1 rounded-lg text-xs font-medium border transition-colors cursor-pointer"
                                        :class="isPresetActive('bulan_lalu') ? 'bg-emerald-50 text-emerald-700 border-emerald-300 font-semibold' : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'"
                                        @click="setPresetPeriode('bulan_lalu')"
                                    >
                                        Bulan Lalu
                                    </button>
                                    <button
                                        type="button"
                                        class="px-2.5 py-1 rounded-lg text-xs font-medium border transition-colors cursor-pointer"
                                        :class="isPresetActive('3_bulan') ? 'bg-emerald-50 text-emerald-700 border-emerald-300 font-semibold' : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'"
                                        @click="setPresetPeriode('3_bulan')"
                                    >
                                        3 Bulan Terakhir
                                    </button>
                                    <button
                                        type="button"
                                        class="px-2.5 py-1 rounded-lg text-xs font-medium border transition-colors cursor-pointer"
                                        :class="isPresetActive('tahun_ini') ? 'bg-emerald-50 text-emerald-700 border-emerald-300 font-semibold' : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'"
                                        @click="setPresetPeriode('tahun_ini')"
                                    >
                                        Tahun Ini
                                    </button>
                                </div>
                            </div>

                            <!-- Input Rentang Tanggal -->
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                                <div>
                                    <label class="block text-xs font-semibold text-slate-700 mb-1.5" for="tanggal-mulai">
                                        Tanggal Mulai
                                    </label>
                                    <input
                                        id="tanggal-mulai"
                                        v-model="periode.tanggalMulai"
                                        class="input-field w-full px-3.5 py-2.5 rounded-xl text-sm"
                                        type="date"
                                        :max="today"
                                        required
                                    />
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-slate-700 mb-1.5" for="tanggal-selesai">
                                        Tanggal Selesai
                                    </label>
                                    <input
                                        id="tanggal-selesai"
                                        v-model="periode.tanggalSelesai"
                                        class="input-field w-full px-3.5 py-2.5 rounded-xl text-sm"
                                        type="date"
                                        :min="periode.tanggalMulai"
                                        :max="today"
                                        required
                                    />
                                </div>
                            </div>

                            <!-- Indikator Durasi & Ketentuan -->
                            <div class="flex items-center justify-between text-xs text-slate-500 pt-0.5">
                                <span class="inline-flex items-center gap-1.5">
                                    <i class="pi pi-calendar-times text-slate-400" />
                                    <span>Maksimal rentang: 366 hari</span>
                                </span>
                                <span
                                    v-if="rentangHari > 0"
                                    class="px-2 py-0.5 rounded-md font-semibold text-[11px]"
                                    :class="rentangHari > 366 ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'"
                                >
                                    {{ rentangHari }} hari terpilih
                                </span>
                            </div>
                        </div>

                        <!-- Bagian Bawah: Pesan & Tombol Unduh -->
                        <div class="space-y-3 pt-2 mt-auto">
                            <!-- Alert Feedback Rekap -->
                            <div
                                v-if="rekapMessage.text"
                                id="rekap-message"
                                class="flex items-center gap-2 p-3 rounded-xl text-xs"
                                :class="rekapMessage.type === 'success' ? 'text-emerald-800 bg-emerald-50 border border-emerald-200' : 'text-red-700 bg-red-50 border border-red-200'"
                                role="status"
                            >
                                <i
                                    class="shrink-0"
                                    :class="rekapMessage.type === 'success'
                                        ? 'pi pi-check-circle text-emerald-600'
                                        : 'pi pi-exclamation-circle text-red-500'"
                                    aria-hidden="true"
                                />
                                <span>{{ rekapMessage.text }}</span>
                            </div>

                            <!-- Tombol Unduh Rekap -->
                            <button
                                type="submit"
                                class="btn-primary w-full rounded-xl px-4 py-3 text-sm font-semibold text-white flex items-center justify-center gap-2 shadow-sm transition-all"
                                :aria-busy="downloading.rekap"
                            >
                                <i
                                    class="pi"
                                    :class="downloading.rekap
                                        ? 'pi-spinner pi-spin'
                                        : 'pi-download'"
                                    aria-hidden="true"
                                />
                                <span>
                                    {{ downloading.rekap
                                        ? "Menyiapkan rekap..."
                                        : "Unduh Laporan Rekap" }}
                                </span>
                            </button>
                        </div>
                    </form>
                </div>
            </section>
        </div>
    </div>
</template>

<script setup>
import { computed, nextTick, onMounted, reactive, ref } from "vue";
import { useAuthStore } from "@/stores/authStore";
import AnakSearchSelect from "@/components/forms/AnakSearchSelect.vue";
import kaderService from "@/services/kaderService";
import puskesmasService from "@/services/puskesmasService";
import laporanService, {
    getDownloadErrorMessage,
    savePdfResponse,
} from "@/services/laporanService";
import { extractPaginatedData } from "@/utils/apiResponse";
import { formatTanggal, toLocalDateStr } from "@/utils/format.js";

const authStore = useAuthStore();

const formatInputDate = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
};

const todayDate = new Date();
const monthStart = new Date(todayDate.getFullYear(), todayDate.getMonth(), 1);
const today = formatInputDate(todayDate);

const anakOptions = ref([]);
const loadingAnak = ref(false);
const anakError = ref("");
const selectedAnakId = ref("");
const individualSelect = ref(null);
const downloading = reactive({ individual: false, rekap: false });
const individualMessage = reactive({ type: "error", text: "" });
const rekapMessage = reactive({ type: "error", text: "" });
const periode = reactive({
    tanggalMulai: formatInputDate(monthStart),
    tanggalSelesai: today,
});

const selectedAnak = computed(() =>
    anakOptions.value.find((item) => item.id === selectedAnakId.value) || null,
);

const getInitials = (nama) => {
    if (!nama) return "?";
    return nama
        .split(" ")
        .filter(Boolean)
        .slice(0, 2)
        .map((n) => n[0])
        .join("")
        .toUpperCase();
};

const handleGantiAnak = () => {
    selectedAnakId.value = "";
    individualMessage.text = "";
};

const handleAnakSelected = (id) => {
    selectedAnakId.value = id;
    clearIndividualSelectionError();
};

const getAnakService = () =>
    authStore.isKader ? kaderService : puskesmasService;

const loadAnak = async () => {
    loadingAnak.value = true;
    anakError.value = "";
    selectedAnakId.value = "";

    try {
        const anakService = getAnakService();
        const first = extractPaginatedData(
            await anakService.getAllAnak({ page: 1, limit: 100 }),
        );
        const items = [...first.items];

        for (let page = 2; page <= first.pagination.total_pages; page += 1) {
            const next = extractPaginatedData(
                await anakService.getAllAnak({ page, limit: 100 }),
            );
            items.push(...next.items);
        }

        anakOptions.value = items.sort((a, b) =>
            String(a.nama || "").localeCompare(String(b.nama || ""), "id"),
        );
    } catch (error) {
        anakOptions.value = [];
        anakError.value =
            error.response?.data?.message ||
            error.message ||
            "Gagal memuat daftar anak";
    } finally {
        loadingAnak.value = false;
    }
};

const downloadIndividual = async () => {
    if (downloading.individual) return;
    if (!selectedAnakId.value) {
        individualMessage.type = "error";
        individualMessage.text = anakOptions.value.length
            ? "Pilih anak yang akan dibuatkan laporan terlebih dahulu."
            : "Belum ada data anak yang dapat dibuatkan laporan.";
        await nextTick();
        individualSelect.value?.focus();
        return;
    }

    downloading.individual = true;
    individualMessage.text = "";
    try {
        const response = await laporanService.downloadIndividual(
            selectedAnakId.value,
        );
        const anak = anakOptions.value.find(
            (item) => item.id === selectedAnakId.value,
        );
        const filename = savePdfResponse(
            response,
            `laporan-teknis-${anak?.nama || "anak"}.pdf`,
        );
        individualMessage.type = "success";
        individualMessage.text = `${filename} berhasil diunduh.`;
    } catch (error) {
        individualMessage.type = "error";
        individualMessage.text = await getDownloadErrorMessage(
            error,
            "Gagal mengunduh laporan individual",
        );
    } finally {
        downloading.individual = false;
    }
};

const individualSelectionError = computed(
    () =>
        !selectedAnakId.value &&
        individualMessage.type === "error" &&
        Boolean(individualMessage.text),
);

const clearIndividualSelectionError = () => {
    if (selectedAnakId.value && individualSelectionError.value) {
        individualMessage.text = "";
    }
};

const setPresetPeriode = (preset) => {
    const cur = new Date();
    if (preset === "bulan_ini") {
        periode.tanggalMulai = formatInputDate(new Date(cur.getFullYear(), cur.getMonth(), 1));
        periode.tanggalSelesai = today;
    } else if (preset === "bulan_lalu") {
        periode.tanggalMulai = formatInputDate(new Date(cur.getFullYear(), cur.getMonth() - 1, 1));
        periode.tanggalSelesai = formatInputDate(new Date(cur.getFullYear(), cur.getMonth(), 0));
    } else if (preset === "3_bulan") {
        periode.tanggalMulai = formatInputDate(new Date(cur.getFullYear(), cur.getMonth() - 2, 1));
        periode.tanggalSelesai = today;
    } else if (preset === "tahun_ini") {
        periode.tanggalMulai = formatInputDate(new Date(cur.getFullYear(), 0, 1));
        periode.tanggalSelesai = today;
    }
    rekapMessage.text = "";
};

const isPresetActive = (preset) => {
    const cur = new Date();
    if (preset === "bulan_ini") {
        return periode.tanggalMulai === formatInputDate(new Date(cur.getFullYear(), cur.getMonth(), 1)) &&
               periode.tanggalSelesai === today;
    }
    if (preset === "bulan_lalu") {
        return periode.tanggalMulai === formatInputDate(new Date(cur.getFullYear(), cur.getMonth() - 1, 1)) &&
               periode.tanggalSelesai === formatInputDate(new Date(cur.getFullYear(), cur.getMonth(), 0));
    }
    if (preset === "3_bulan") {
        return periode.tanggalMulai === formatInputDate(new Date(cur.getFullYear(), cur.getMonth() - 2, 1)) &&
               periode.tanggalSelesai === today;
    }
    if (preset === "tahun_ini") {
        return periode.tanggalMulai === formatInputDate(new Date(cur.getFullYear(), 0, 1)) &&
               periode.tanggalSelesai === today;
    }
    return false;
};

const rentangHari = computed(() => {
    if (!periode.tanggalMulai || !periode.tanggalSelesai) return 0;
    const start = new Date(`${periode.tanggalMulai}T00:00:00Z`);
    const end = new Date(`${periode.tanggalSelesai}T00:00:00Z`);
    const diff = Math.floor((end - start) / 86_400_000) + 1;
    return diff > 0 ? diff : 0;
});

const validatePeriode = () => {
    const { tanggalMulai, tanggalSelesai } = periode;
    if (!tanggalMulai || !tanggalSelesai) {
        return "Tanggal mulai dan tanggal selesai wajib diisi.";
    }
    if (tanggalMulai > tanggalSelesai) {
        return "Tanggal selesai tidak boleh sebelum tanggal mulai.";
    }
    if (tanggalSelesai > today) {
        return "Periode laporan tidak boleh melewati hari ini.";
    }

    const start = new Date(`${tanggalMulai}T00:00:00Z`);
    const end = new Date(`${tanggalSelesai}T00:00:00Z`);
    const inclusiveDays = Math.floor((end - start) / 86_400_000) + 1;
    if (inclusiveDays > 366) {
        return "Rentang laporan maksimal 366 hari.";
    }

    return "";
};

const downloadRekap = async () => {
    if (downloading.rekap) return;

    rekapMessage.text = "";
    const validationError = validatePeriode();
    if (validationError) {
        rekapMessage.type = "error";
        rekapMessage.text = validationError;
        return;
    }

    downloading.rekap = true;
    try {
        const response = await laporanService.downloadRekap(
            periode.tanggalMulai,
            periode.tanggalSelesai,
        );
        const filename = savePdfResponse(
            response,
            `laporan-rekap-${periode.tanggalMulai}-${periode.tanggalSelesai}.pdf`,
        );
        rekapMessage.type = "success";
        rekapMessage.text = `${filename} berhasil diunduh.`;
    } catch (error) {
        rekapMessage.type = "error";
        rekapMessage.text = await getDownloadErrorMessage(
            error,
            "Gagal mengunduh laporan rekap",
        );
    } finally {
        downloading.rekap = false;
    }
};

onMounted(loadAnak);
</script>

<style scoped>
.card {
    background: #ffffff;
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

.input-field {
    background: #ffffff;
    border: 1px solid #cbd5e1;
    color: #1e293b;
    outline: none;
    font-family: inherit;
    transition: border-color 0.2s, box-shadow 0.2s;
}

.input-field:focus {
    border-color: #059669;
    box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.15);
}

.btn-primary {
    border: 0;
    background: #059669;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-primary:hover {
    background: #047857;
}

.btn-primary:active {
    transform: scale(0.99);
}

.skeleton {
    background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 50%, #f1f5f9 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}

@keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}
</style>
