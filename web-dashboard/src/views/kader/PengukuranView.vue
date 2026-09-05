<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Input Pengukuran
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Catat hasil pengukuran berat dan tinggi badan anak
                </p>
            </div>
        </div>

        <!-- ─── Layout dua kolom: Form kiri, Hasil kanan ────────── -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
            <!-- ══ KOLOM KIRI: Form Pengukuran ══════════════════════ -->
            <div class="card space-y-5 p-6 rounded-2xl">
                <h2
                    class="text-base font-semibold m-0"
                    style="color: var(--color-text-heading)"
                >
                    <i
                        class="pi pi-pencil mr-2"
                        style="color: var(--color-green-700)"
                        aria-hidden="true"
                    />
                    Form Pengukuran
                </h2>

                <!-- Error API -->
                <Transition name="slide-down">
                    <div
                        v-if="pengukuranStore.error.create"
                        class="flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                        style="
                            background: #fef2f2;
                            border: 1px solid #fecaca;
                            color: #b91c1c;
                        "
                        role="alert"
                        aria-live="assertive"
                    >
                        <i
                            class="pi pi-exclamation-circle mt-0.5 flex-shrink-0"
                            aria-hidden="true"
                        />
                        <span>{{ pengukuranStore.error.create }}</span>
                    </div>
                </Transition>

                <form
                    novalidate
                    class="space-y-4"
                    @submit.prevent="handleSubmit"
                >
                    <!-- Pilih Anak -->
                    <div class="space-y-1.5">
                        <label for="anak_id" class="field-label"
                            >Pilih Anak</label
                        >
                        <div class="relative">
                            <i
                                class="pi pi-heart input-icon"
                                aria-hidden="true"
                            />
                            <select
                                id="anak_id"
                                v-model="form.anak_id"
                                :disabled="pengukuranStore.loading.create || kaderStore.loading.anakOptions"
                                class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
                                aria-required="true"
                                :aria-invalid="!!fieldError.anak_id"
                                aria-describedby="anak_id_error"
                            >
                                <option value="" disabled>
                                    {{ kaderStore.loading.anakOptions ? "Memuat data anak..." : "Pilih nama anak" }}
                                </option>
                                <option
                                    v-for="anak in kaderStore.anakOptions"
                                    :key="anak.id"
                                    :value="anak.id"
                                >
                                    {{ anak.nama }} — {{ anak.nama_orang_tua }}
                                </option>
                            </select>
                            <i
                                class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                                style="color: var(--color-text-muted)"
                                aria-hidden="true"
                            />
                        </div>
                        <p id="anak_id_error" v-if="fieldError.anak_id" class="error-hint">
                            {{ fieldError.anak_id }}
                        </p>
                        <div
                            v-if="kaderStore.error.anakOptions"
                            class="flex items-center justify-between gap-3 text-xs text-red-700"
                            role="alert"
                        >
                            <span>{{ kaderStore.error.anakOptions }}</span>
                            <button
                                type="button"
                                class="font-semibold underline cursor-pointer"
                                @click="kaderStore.fetchAnakOptions()"
                            >
                                Coba lagi
                            </button>
                        </div>
                        <!-- Info anak terpilih -->
                        <div
                            v-if="anakTerpilih"
                            class="flex items-center gap-2 px-3 py-2 rounded-lg text-xs"
                            style="
                                background: var(--color-green-50);
                                color: var(--color-green-700);
                            "
                        >
                            <i class="pi pi-info-circle" aria-hidden="true" />
                            <span>
                                {{
                                    anakTerpilih.jenis_kelamin === "L"
                                        ? "Laki-laki"
                                        : "Perempuan"
                                }}
                                • Usia
                                {{ hitungUsia(anakTerpilih.tanggal_lahir) }}
                            </span>
                        </div>
                        <p
                            v-if="currentAgeWarning"
                            class="text-xs m-0 px-3 py-2 rounded-lg"
                            style="background: #fffbeb; color: #92400e"
                            role="status"
                        >
                            <i class="pi pi-exclamation-triangle mr-1" />
                            {{ currentAgeWarning.message }}
                        </p>
                    </div>

                    <!-- Tanggal Ukur -->
                    <div class="space-y-1.5">
                        <label for="tanggal_ukur" class="field-label"
                            >Tanggal Pengukuran</label
                        >
                        <DatePicker
                            id="tanggal_ukur"
                            v-model="form.tanggal_ukur"
                            :min-date="measurementDateLimits.minDate"
                            :max-date="measurementDateLimits.maxDate || todayDate"
                            :disabled="pengukuranStore.loading.create"
                            date-format="dd/mm/yy"
                            placeholder="Pilih tanggal pengukuran"
                            show-icon
                            icon-display="input"
                            fluid
                            class="w-full"
                            aria-required="true"
                            :aria-invalid="!!fieldError.tanggal_ukur"
                            aria-describedby="tanggal_ukur_error"
                        />
                        <p id="tanggal_ukur_error" v-if="fieldError.tanggal_ukur" class="error-hint">
                            {{ fieldError.tanggal_ukur }}
                        </p>
                    </div>

                    <!-- Berat & Tinggi Badan — 2 kolom -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div class="space-y-1.5">
                            <label for="berat_badan" class="field-label">
                                Berat Badan
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(kg)</span
                                >
                            </label>
                            <div class="relative">
                                <input
                                    id="berat_badan"
                                    v-model.number="form.berat_badan"
                                    type="number"
                                    placeholder="0.00"
                                    step="0.01"
                                    min="0.01"
                                    max="30"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!fieldError.berat_badan"
                                    aria-describedby="berat_badan_error"
                                />
                            </div>
                            <p id="berat_badan_error" v-if="fieldError.berat_badan" class="error-hint">
                                {{ fieldError.berat_badan }}
                            </p>
                        </div>
                        <div class="space-y-1.5">
                            <label for="tinggi_badan" class="field-label">
                                Tinggi Badan
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(cm)</span
                                >
                            </label>
                            <div class="relative">
                                <input
                                    id="tinggi_badan"
                                    v-model.number="form.tinggi_badan"
                                    type="number"
                                    placeholder="0.00"
                                    step="0.01"
                                    min="0.01"
                                    max="120"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!fieldError.tinggi_badan"
                                    aria-describedby="tinggi_badan_error"
                                />
                            </div>
                            <p
                                id="tinggi_badan_error"
                                v-if="fieldError.tinggi_badan"
                                class="error-hint"
                            >
                                {{ fieldError.tinggi_badan }}
                            </p>
                        </div>
                    </div>

                    <!-- Lingkar Kepala & Lengan — opsional -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                        <div class="space-y-1.5">
                            <label for="lingkar_kepala" class="field-label">
                                Lingkar Kepala
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(cm, opsional)</span
                                >
                            </label>
                            <input
                                id="lingkar_kepala"
                                v-model.number="form.lingkar_kepala"
                                type="number"
                                placeholder="—"
                                step="0.01"
                                min="1"
                                max="80"
                                :disabled="pengukuranStore.loading.create"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                :aria-invalid="!!fieldError.lingkar_kepala"
                                aria-describedby="lingkar_kepala_error"
                            />
                            <p id="lingkar_kepala_error" v-if="fieldError.lingkar_kepala" class="error-hint">
                                {{ fieldError.lingkar_kepala }}
                            </p>
                        </div>
                        <div class="space-y-1.5">
                            <label for="lingkar_lengan" class="field-label">
                                Lingkar Lengan Atas
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(cm, opsional)</span
                                >
                            </label>
                            <input
                                id="lingkar_lengan"
                                v-model.number="form.lingkar_lengan"
                                type="number"
                                placeholder="—"
                                step="0.01"
                                min="1"
                                max="60"
                                :disabled="pengukuranStore.loading.create"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                :aria-invalid="!!fieldError.lingkar_lengan"
                                aria-describedby="lingkar_lengan_error"
                            />
                            <p id="lingkar_lengan_error" v-if="fieldError.lingkar_lengan" class="error-hint">
                                {{ fieldError.lingkar_lengan }}
                            </p>
                        </div>
                    </div>

                    <!-- Tombol submit -->
                    <button
                        type="submit"
                        :disabled="pengukuranStore.loading.create"
                        class="btn-primary w-full py-3 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed mt-2"
                    >
                        <i
                            v-if="pengukuranStore.loading.create"
                            class="pi pi-spin pi-spinner"
                            aria-hidden="true"
                        />
                        <i v-else class="pi pi-check" aria-hidden="true" />
                        <span>{{
                            pengukuranStore.loading.create
                                ? "Memproses..."
                                : "Simpan Pengukuran"
                        }}</span>
                    </button>
                </form>
            </div>

            <!-- ══ KOLOM KANAN: Hasil Pengukuran ════════════════════ -->
            <div ref="resultSection" class="space-y-4">
                <!-- State: belum ada hasil -->
                <div
                    v-if="!pengukuranStore.createResult"
                    class="card p-6 rounded-2xl flex flex-col items-center justify-center text-center gap-3 min-h-48"
                >
                    <i
                        class="pi pi-chart-line text-4xl"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                    <p
                        class="text-sm m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Hasil pengukuran akan ditampilkan di sini setelah form
                        disimpan
                    </p>
                </div>

                <!-- Hasil pengukuran -->
                <template v-else>
                    <PengukuranResultCard
                        :result="pengukuranStore.createResult"
                        :anak="anakTerpilih"
                    />
                </template>
            </div>
        </div>

        <Dialog
            v-model:visible="showConfirmation"
            modal
            header="Konfirmasi Pengukuran"
            :style="{ width: '520px', maxWidth: '95vw' }"
        >
            <div class="space-y-4">
                <div class="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed">
                    Pastikan identitas anak dan seluruh nilai sudah benar. Pengukuran yang tersimpan akan memengaruhi riwayat dan prioritas pemantauan.
                </div>

                <div class="rounded-xl border border-slate-200 divide-y divide-slate-100">
                    <div class="p-4">
                        <p class="text-[11px] uppercase tracking-wider font-semibold text-slate-400 m-0">Anak</p>
                        <p class="text-sm font-bold text-slate-800 mt-1 mb-0">{{ anakTerpilih?.nama }}</p>
                        <p class="text-xs text-slate-500 mt-1 mb-0">Orang tua: {{ anakTerpilih?.nama_orang_tua || "—" }}</p>
                    </div>
                    <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-3 p-4 text-xs">
                        <div>
                            <dt class="text-slate-400">Tanggal pengukuran</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ formattedMeasurementDate }}</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Berat badan</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ form.berat_badan }} kg</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Tinggi badan</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ form.tinggi_badan }} cm</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Lingkar kepala</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ optionalMeasurementLabel(form.lingkar_kepala) }}</dd>
                        </div>
                        <div>
                            <dt class="text-slate-400">Lingkar lengan atas</dt>
                            <dd class="font-semibold text-slate-700 mt-1 ml-0">{{ optionalMeasurementLabel(form.lingkar_lengan) }}</dd>
                        </div>
                    </dl>
                </div>

                <div class="flex justify-end gap-2">
                    <button
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 cursor-pointer"
                        :disabled="pengukuranStore.loading.create"
                        @click="showConfirmation = false"
                    >
                        Periksa Kembali
                    </button>
                    <button
                        type="button"
                        class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white inline-flex items-center gap-2 cursor-pointer disabled:opacity-60"
                        :disabled="pengukuranStore.loading.create"
                        @click="confirmSubmit"
                    >
                        <i v-if="pengukuranStore.loading.create" class="pi pi-spin pi-spinner" aria-hidden="true" />
                        <i v-else class="pi pi-check" aria-hidden="true" />
                        Simpan Pengukuran
                    </button>
                </div>
            </div>
        </Dialog>
    </div>
</template>

<script setup>
import { computed, reactive, ref, watch, nextTick, onMounted } from "vue";
import { useRoute } from "vue-router";
import { DatePicker, Dialog } from "primevue";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useKaderStore } from "@/stores/kaderStore";
import PengukuranResultCard from "@/components/cards/PengukuranResultCard.vue";
import { formatTanggal, hitungUsia, toLocalDateStr } from "@/utils/format.js";
import { validateMeasurement } from "@/utils/measurementValidation.js";
import {
    getCurrentAgeMeasurementWarning,
    getMeasurementDateLimits,
    validateMeasurementDate,
} from "@/utils/measurementEligibility.js";

const pengukuranStore = usePengukuranStore();
const kaderStore = useKaderStore();
const route = useRoute();

const todayDate = new Date();
const showConfirmation = ref(false);
const attemptedSubmit = ref(false);
const resultSection = ref(null);

const form = reactive({
    anak_id: "",
    tanggal_ukur: todayDate,
    berat_badan: null,
    tinggi_badan: null,
    lingkar_kepala: null,
    lingkar_lengan: null,
});

/* ── Info anak terpilih ──────────────────────────────────────────── */
const anakTerpilih = computed(
    () => kaderStore.anakOptions.find((a) => a.id === form.anak_id) || null,
);

const measurementDateLimits = computed(() =>
    getMeasurementDateLimits(anakTerpilih.value?.tanggal_lahir, todayDate),
);

const currentAgeWarning = computed(() =>
    getCurrentAgeMeasurementWarning(
        anakTerpilih.value?.tanggal_lahir,
        todayDate,
    ),
);


/* ── Validasi ────────────────────────────────────────────────────── */
const fieldError = computed(() => {
    const errors = validateMeasurement(form);
    if (attemptedSubmit.value) {
        if (!form.anak_id) errors.anak_id = "Anak wajib dipilih";
        if (!form.tanggal_ukur) {
            errors.tanggal_ukur = "Tanggal pengukuran wajib dipilih";
        }
        if (form.berat_badan === null || form.berat_badan === "") {
            errors.berat_badan = "Berat badan wajib diisi";
        }
        if (form.tinggi_badan === null || form.tinggi_badan === "") {
            errors.tinggi_badan = "Tinggi badan wajib diisi";
        }
    }
    if (anakTerpilih.value && form.tanggal_ukur) {
        const eligibility = validateMeasurementDate(
            anakTerpilih.value.tanggal_lahir,
            form.tanggal_ukur,
            todayDate,
        );
        if (!eligibility.eligible) {
            errors.tanggal_ukur = eligibility.message;
        }
    }
    return errors;
});

const isValid = computed(
    () =>
        form.anak_id &&
        form.tanggal_ukur &&
        form.berat_badan !== null &&
        form.berat_badan !== "" &&
        form.tinggi_badan !== null &&
        form.tinggi_badan !== "" &&
        Object.keys(fieldError.value).length === 0,
);

const formattedMeasurementDate = computed(() =>
    form.tanggal_ukur ? formatTanggal(toLocalDateStr(form.tanggal_ukur)) : "—",
);

const optionalMeasurementLabel = (value) =>
    value === null || value === "" ? "Tidak diisi" : `${value} cm`;

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    attemptedSubmit.value = true;
    if (!isValid.value || pengukuranStore.loading.create) return;
    showConfirmation.value = true;
};

const confirmSubmit = async () => {
    if (!isValid.value || pengukuranStore.loading.create) return;
    showConfirmation.value = false;
    pengukuranStore.resetCreateState();

    const payload = {
        anak_id: form.anak_id,
        tanggal_ukur: toLocalDateStr(form.tanggal_ukur || todayDate),
        berat_badan: form.berat_badan,
        tinggi_badan: form.tinggi_badan,
    };
    if (form.lingkar_kepala !== null && form.lingkar_kepala !== "") {
        payload.lingkar_kepala = form.lingkar_kepala;
    }
    if (form.lingkar_lengan !== null && form.lingkar_lengan !== "") {
        payload.lingkar_lengan = form.lingkar_lengan;
    }

    const success = await pengukuranStore.createPengukuran(payload);
    if (success) {
        await nextTick();
        if (window.innerWidth < 1024) {
            resultSection.value?.scrollIntoView({
                behavior: "smooth",
                block: "start",
            });
        }
    }
};

watch(
    () => [
        form.anak_id,
        form.tanggal_ukur,
        form.berat_badan,
        form.tinggi_badan,
        form.lingkar_kepala,
        form.lingkar_lengan,
    ],
    () => {
        if (pengukuranStore.createResult) {
            pengukuranStore.resetCreateState();
        }
    },
);

onMounted(async () => {
    pengukuranStore.resetCreateState();
    await kaderStore.fetchAnakOptions();
    if (route.query.anakId) {
        const queryId = Array.isArray(route.query.anakId)
            ? route.query.anakId[0]
            : route.query.anakId;
        form.anak_id = queryId || "";
    }
});
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.field-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    margin-left: 0.25rem;
    color: var(--color-text-body);
}
.input-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.85rem;
    color: var(--color-text-muted);
    pointer-events: none;
}
.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
    font-family: "Poppins", sans-serif;
}
.input-field::placeholder {
    color: var(--color-text-muted);
    font-size: 0.82rem;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-field:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
.error-hint {
    font-size: 0.72rem;
    color: #dc2626;
    margin: 0 0 0 0.25rem;
}



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
