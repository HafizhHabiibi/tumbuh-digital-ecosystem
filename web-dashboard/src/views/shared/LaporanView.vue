<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <header>
            <h1
                class="text-2xl font-bold m-0"
                style="color: var(--color-text-heading)"
            >
                Laporan Pertumbuhan
            </h1>
            <p class="text-sm mt-1 m-0" style="color: var(--color-text-muted)">
                Unduh laporan teknis seorang anak atau rekap pemantauan dalam
                format PDF.
            </p>
        </header>

        <div
            class="info-panel rounded-2xl p-4 flex items-start gap-3"
            role="note"
        >
            <i class="pi pi-info-circle mt-0.5" aria-hidden="true" />
            <p class="text-sm m-0 leading-relaxed">
                Dokumen berisi data kesehatan anak. Simpan dan bagikan hanya
                untuk keperluan pelayanan yang berwenang.
            </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
            <section class="card rounded-2xl p-5 md:p-6 space-y-5">
                <div class="flex items-start gap-3">
                    <span class="section-icon" aria-hidden="true">
                        <i class="pi pi-user" />
                    </span>
                    <div>
                        <h2
                            class="text-lg font-bold m-0"
                            style="color: var(--color-text-heading)"
                        >
                            Laporan Individual
                        </h2>
                        <p
                            class="text-xs mt-1 m-0"
                            style="color: var(--color-text-muted)"
                        >
                            Riwayat pengukuran, status antropometri, prioritas
                            SAW, dan rujukan seorang anak.
                        </p>
                    </div>
                </div>

                <div v-if="loadingAnak" class="space-y-3" aria-live="polite">
                    <div class="skeleton h-10 rounded-xl" />
                    <div class="skeleton h-10 rounded-xl" />
                    <span class="sr-only">Memuat daftar anak</span>
                </div>

                <div
                    v-else-if="anakError"
                    class="message message-error"
                    role="alert"
                >
                    <div class="flex items-start gap-2">
                        <i class="pi pi-exclamation-circle mt-0.5" />
                        <span>{{ anakError }}</span>
                    </div>
                    <button
                        type="button"
                        class="text-xs font-semibold underline mt-2"
                        @click="loadAnak"
                    >
                        Coba muat kembali
                    </button>
                </div>

                <form v-else class="space-y-4" @submit.prevent="downloadIndividual">
                    <div v-if="anakOptions.length" class="space-y-4">
                        <div>
                            <label class="field-label" for="cari-anak">
                                Cari anak
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-search field-icon"
                                    aria-hidden="true"
                                />
                                <input
                                    id="cari-anak"
                                    v-model="searchAnak"
                                    class="input-field w-full pl-10 pr-4 py-2.5 rounded-xl text-sm"
                                    type="search"
                                    placeholder="Nama anak atau orang tua"
                                    autocomplete="off"
                                />
                            </div>
                        </div>

                        <div>
                            <label class="field-label" for="pilih-anak">
                                Anak <span class="text-red-600">*</span>
                            </label>
                            <select
                                id="pilih-anak"
                                v-model="selectedAnakId"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                required
                            >
                                <option value="" disabled>Pilih anak</option>
                                <option
                                    v-for="anak in filteredAnakOptions"
                                    :key="anak.id"
                                    :value="anak.id"
                                >
                                    {{ labelAnak(anak) }}
                                </option>
                            </select>
                            <p
                                v-if="filteredAnakOptions.length === 0"
                                class="text-xs mt-2 mb-0"
                                style="color: var(--color-text-muted)"
                            >
                                Tidak ada anak yang cocok dengan pencarian.
                            </p>
                        </div>
                    </div>

                    <div v-else class="empty-panel rounded-xl p-5 text-center">
                        <i
                            class="pi pi-users text-2xl"
                            style="color: var(--color-text-muted)"
                            aria-hidden="true"
                        />
                        <p
                            class="text-sm mt-2 mb-0"
                            style="color: var(--color-text-muted)"
                        >
                            Belum ada data anak yang dapat dibuatkan laporan.
                        </p>
                    </div>

                    <div
                        v-if="individualMessage.text"
                        class="message"
                        :class="`message-${individualMessage.type}`"
                        role="status"
                    >
                        <i
                            :class="individualMessage.type === 'success'
                                ? 'pi pi-check-circle'
                                : 'pi pi-exclamation-circle'"
                            aria-hidden="true"
                        />
                        <span>{{ individualMessage.text }}</span>
                    </div>

                    <button
                        type="submit"
                        class="btn-primary w-full rounded-xl px-4 py-2.5 text-sm font-semibold text-white flex items-center justify-center gap-2"
                        :disabled="!selectedAnakId || downloading.individual"
                    >
                        <i
                            class="pi"
                            :class="downloading.individual
                                ? 'pi-spinner pi-spin'
                                : 'pi-download'"
                            aria-hidden="true"
                        />
                        {{ downloading.individual
                            ? "Menyiapkan laporan..."
                            : "Unduh Laporan Individual" }}
                    </button>
                </form>
            </section>

            <section class="card rounded-2xl p-5 md:p-6 space-y-5">
                <div class="flex items-start gap-3">
                    <span class="section-icon" aria-hidden="true">
                        <i class="pi pi-chart-bar" />
                    </span>
                    <div>
                        <h2
                            class="text-lg font-bold m-0"
                            style="color: var(--color-text-heading)"
                        >
                            Laporan Rekap Periode
                        </h2>
                        <p
                            class="text-xs mt-1 m-0"
                            style="color: var(--color-text-muted)"
                        >
                            Ringkasan kunjungan, distribusi antropometri, dan
                            daftar prioritas tindak lanjut.
                        </p>
                    </div>
                </div>

                <form class="space-y-4" @submit.prevent="downloadRekap">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="field-label" for="tanggal-mulai">
                                Tanggal mulai <span class="text-red-600">*</span>
                            </label>
                            <input
                                id="tanggal-mulai"
                                v-model="periode.tanggalMulai"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                type="date"
                                :max="today"
                                required
                            />
                        </div>
                        <div>
                            <label class="field-label" for="tanggal-selesai">
                                Tanggal selesai <span class="text-red-600">*</span>
                            </label>
                            <input
                                id="tanggal-selesai"
                                v-model="periode.tanggalSelesai"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                type="date"
                                :min="periode.tanggalMulai"
                                :max="today"
                                required
                            />
                        </div>
                    </div>

                    <p class="text-xs m-0" style="color: var(--color-text-muted)">
                        Rentang laporan maksimal 366 hari dan tidak boleh
                        melewati hari ini.
                    </p>

                    <div
                        v-if="rekapMessage.text"
                        class="message"
                        :class="`message-${rekapMessage.type}`"
                        role="status"
                    >
                        <i
                            :class="rekapMessage.type === 'success'
                                ? 'pi pi-check-circle'
                                : 'pi pi-exclamation-circle'"
                            aria-hidden="true"
                        />
                        <span>{{ rekapMessage.text }}</span>
                    </div>

                    <button
                        type="submit"
                        class="btn-primary w-full rounded-xl px-4 py-2.5 text-sm font-semibold text-white flex items-center justify-center gap-2"
                        :disabled="downloading.rekap"
                    >
                        <i
                            class="pi"
                            :class="downloading.rekap
                                ? 'pi-spinner pi-spin'
                                : 'pi-download'"
                            aria-hidden="true"
                        />
                        {{ downloading.rekap
                            ? "Menyiapkan rekap..."
                            : "Unduh Laporan Rekap" }}
                    </button>
                </form>
            </section>
        </div>
    </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from "vue";
import { useAuthStore } from "@/stores/authStore";
import kaderService from "@/services/kaderService";
import puskesmasService from "@/services/puskesmasService";
import laporanService, {
    getDownloadErrorMessage,
    savePdfResponse,
} from "@/services/laporanService";
import { extractPaginatedData } from "@/utils/apiResponse";

const authStore = useAuthStore();

const formatInputDate = (date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
};

const now = new Date();
const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
const today = formatInputDate(now);

const anakOptions = ref([]);
const loadingAnak = ref(false);
const anakError = ref("");
const searchAnak = ref("");
const selectedAnakId = ref("");
const downloading = reactive({ individual: false, rekap: false });
const individualMessage = reactive({ type: "error", text: "" });
const rekapMessage = reactive({ type: "error", text: "" });
const periode = reactive({
    tanggalMulai: formatInputDate(monthStart),
    tanggalSelesai: today,
});

const filteredAnakOptions = computed(() => {
    const query = searchAnak.value.trim().toLocaleLowerCase("id-ID");
    if (!query) return anakOptions.value;

    return anakOptions.value.filter((anak) =>
        [anak.nama, anak.nama_orang_tua]
            .filter(Boolean)
            .some((value) =>
                String(value).toLocaleLowerCase("id-ID").includes(query),
            ),
    );
});

const labelAnak = (anak) =>
    anak.nama_orang_tua
        ? `${anak.nama} — ${anak.nama_orang_tua}`
        : anak.nama;

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
    if (!selectedAnakId.value || downloading.individual) return;

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
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.info-panel {
    color: var(--color-green-700);
    background: var(--color-green-50);
    border: 1px solid var(--color-green-100);
}

.section-icon {
    width: 2.5rem;
    height: 2.5rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    color: var(--color-green-700);
    background: var(--color-green-50);
    border-radius: 0.75rem;
}

.field-label {
    display: block;
    margin-bottom: 0.375rem;
    color: var(--color-text-body);
    font-size: 0.75rem;
    font-weight: 600;
}

.field-icon {
    position: absolute;
    left: 0.875rem;
    top: 50%;
    transform: translateY(-50%);
    color: var(--color-text-muted);
    font-size: 0.875rem;
}

.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    font-family: "Poppins", sans-serif;
    transition: border-color 0.2s, box-shadow 0.2s;
}

.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}

.btn-primary {
    border: 0;
    background: var(--color-green-700);
    cursor: pointer;
    transition: opacity 0.2s, transform 0.2s;
}

.btn-primary:hover:not(:disabled) {
    opacity: 0.92;
}

.btn-primary:disabled {
    cursor: not-allowed;
    opacity: 0.55;
}

.empty-panel {
    background: var(--color-input-bg);
    border: 1px dashed var(--color-input-border);
}

.message {
    display: flex;
    align-items: flex-start;
    gap: 0.5rem;
    padding: 0.75rem;
    border-radius: 0.75rem;
    font-size: 0.75rem;
    line-height: 1.5;
}

.message-error {
    color: #b91c1c;
    background: #fef2f2;
    border: 1px solid #fecaca;
}

.message-success {
    color: #166534;
    background: #f0fdf4;
    border: 1px solid #bbf7d0;
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
