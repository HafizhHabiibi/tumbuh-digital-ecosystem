<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <Transition name="slide-down">
            <div
                v-if="error"
                class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                role="alert"
                aria-live="assertive"
            >
                <i class="pi pi-exclamation-circle mt-0.5 flex-shrink-0" aria-hidden="true" />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <div v-if="!anakId" class="space-y-1.5">
            <label for="form_anak_id" class="field-label">Anak</label>
            <div class="relative">
                <i class="pi pi-heart input-icon" aria-hidden="true" />
                <select
                    id="form_anak_id"
                    v-model="form.anak_id"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
                    aria-required="true"
                    :aria-invalid="!!fieldErrors.anak_id"
                    aria-describedby="form_anak_id_error"
                >
                    <option value="" disabled>Pilih anak</option>
                    <option v-for="item in anakList" :key="item.id" :value="item.id">
                        {{ item.nama }} — {{ item.nama_orang_tua }}
                    </option>
                </select>
                <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
            </div>
            <p v-if="fieldErrors.anak_id" id="form_anak_id_error" class="error-hint">
                {{ fieldErrors.anak_id }}
            </p>
        </div>

        <fieldset class="space-y-1.5 m-0 p-0 border-0">
            <legend class="field-label mb-1.5">Jenis Pemberian</legend>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <label
                    v-for="jenis in JENIS_VALID"
                    :key="jenis"
                    class="jenis-option flex items-center gap-2 px-3 py-2.5 rounded-xl cursor-pointer transition-all border text-sm"
                    :class="{ 'jenis-option--active': form.jenis === jenis }"
                    :style="
                        form.jenis === jenis
                            ? `background: ${warnaBg[jenis]}; border-color: ${warnaText[jenis]}; color: ${warnaText[jenis]}`
                            : 'background: var(--color-input-bg); border-color: var(--color-input-border); color: var(--color-text-body)'
                    "
                >
                    <input
                        v-model="form.jenis"
                        type="radio"
                        name="jenis_pemberian"
                        :value="jenis"
                        :disabled="loading"
                        class="sr-only"
                        :aria-invalid="!!fieldErrors.jenis"
                        aria-describedby="jenis_pemberian_error"
                    />
                    <i :class="`pi ${ikonJenis[jenis]} text-sm`" aria-hidden="true" />
                    <span class="font-medium text-xs">{{ LABEL_JENIS[jenis] }}</span>
                </label>
            </div>
            <p v-if="fieldErrors.jenis" id="jenis_pemberian_error" class="error-hint">
                {{ fieldErrors.jenis }}
            </p>
        </fieldset>

        <div class="space-y-1.5">
            <label for="tanggal_pemberian" class="field-label">Tanggal Pemberian</label>
            <DatePicker
                id="tanggal_pemberian"
                v-model="form.tanggal_pemberian"
                :min-date="minimumDate"
                :max-date="todayDate"
                :disabled="loading"
                date-format="dd/mm/yy"
                placeholder="Pilih tanggal pemberian"
                show-icon
                icon-display="input"
                fluid
                class="w-full"
                aria-required="true"
                :aria-invalid="!!fieldErrors.tanggal_pemberian"
                aria-describedby="tanggal_pemberian_error program_notice"
            />
            <p
                v-if="fieldErrors.tanggal_pemberian"
                id="tanggal_pemberian_error"
                class="error-hint"
            >
                {{ fieldErrors.tanggal_pemberian }}
            </p>
            <p
                v-else-if="programNotice"
                id="program_notice"
                class="flex items-start gap-2 px-3 py-2 rounded-lg bg-amber-50 text-amber-800 text-xs leading-relaxed m-0"
            >
                <i class="pi pi-info-circle mt-0.5" aria-hidden="true" />
                <span>{{ programNotice }}</span>
            </p>
        </div>

        <div class="space-y-1.5">
            <label for="dosis" class="field-label">
                Dosis atau Jumlah
                <span class="text-xs font-normal text-slate-400">(opsional)</span>
            </label>
            <div class="relative">
                <i class="pi pi-bookmark input-icon" aria-hidden="true" />
                <input
                    id="dosis"
                    v-model="form.dosis"
                    type="text"
                    maxlength="50"
                    placeholder="Contoh: 0,5 ml, 1 tablet, atau 2 bungkus"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                />
            </div>
        </div>

        <div class="space-y-1.5">
            <div class="flex items-center justify-between gap-3">
                <label for="keterangan" class="field-label">
                    Keterangan
                    <span class="text-xs font-normal text-slate-400">(opsional)</span>
                </label>
                <span class="text-[10px] text-slate-400">{{ form.keterangan.length }}/2000</span>
            </div>
            <textarea
                id="keterangan"
                v-model="form.keterangan"
                rows="3"
                maxlength="2000"
                placeholder="Catatan tambahan jika ada..."
                :disabled="loading"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
            />
        </div>

        <div class="flex gap-3 pt-2">
            <button
                v-if="!loading"
                type="button"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold border transition-colors cursor-pointer"
                style="background: white; color: var(--color-text-body); border-color: var(--color-input-border)"
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                class="btn-submit flex-1 py-2.5 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 cursor-pointer"
                :aria-busy="loading"
            >
                <i v-if="loading" class="pi pi-spin pi-spinner" aria-hidden="true" />
                <i v-else class="pi pi-arrow-right" aria-hidden="true" />
                <span>{{ loading ? "Menyimpan..." : "Tinjau & Simpan" }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { DatePicker } from "primevue";
import {
    JENIS_VALID,
    LABEL_JENIS,
    IKON_JENIS as ikonJenis,
    WARNA_JENIS as warnaText,
    WARNA_BG_JENIS as warnaBg,
} from "@/stores/pemberianStore";
import { toLocalDateStr } from "@/utils/format.js";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    anakId: { type: String, default: "" },
    anak: { type: Object, default: null },
    anakList: { type: Array, default: () => [] },
});
const emit = defineEmits(["submit", "cancel"]);

const todayDate = new Date();
const attemptedSubmit = ref(false);
const form = reactive({
    anak_id: props.anakId || "",
    jenis: "",
    tanggal_pemberian: new Date(),
    dosis: "",
    keterangan: "",
});

const activeAnak = computed(() => {
    if (props.anak) return props.anak;
    const selectedId = props.anakId || form.anak_id;
    return props.anakList.find((item) => String(item.id) === String(selectedId)) || null;
});

const parseLocalDate = (value) => {
    if (!value) return null;
    if (value instanceof Date) return Number.isNaN(value.getTime()) ? null : value;
    const text = String(value).slice(0, 10);
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(text);
    if (!match) return null;
    return new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]));
};

const minimumDate = computed(() => parseLocalDate(activeAnak.value?.tanggal_lahir));

const fieldErrors = computed(() => {
    if (!attemptedSubmit.value) return {};
    const errors = {};
    if (!(props.anakId || form.anak_id)) errors.anak_id = "Anak wajib dipilih";
    if (!form.jenis) errors.jenis = "Jenis pemberian wajib dipilih";
    if (!form.tanggal_pemberian) {
        errors.tanggal_pemberian = "Tanggal pemberian wajib dipilih";
    } else {
        const selected = toLocalDateStr(form.tanggal_pemberian);
        const birthDate = activeAnak.value?.tanggal_lahir
            ? toLocalDateStr(parseLocalDate(activeAnak.value.tanggal_lahir))
            : "";
        if (selected > toLocalDateStr(todayDate)) {
            errors.tanggal_pemberian = "Tanggal pemberian tidak boleh di masa depan";
        } else if (birthDate && selected < birthDate) {
            errors.tanggal_pemberian = "Tanggal pemberian tidak boleh sebelum tanggal lahir";
        }
    }
    return errors;
});

const ageInMonthsAtDate = computed(() => {
    const birth = minimumDate.value;
    const eventDate = parseLocalDate(form.tanggal_pemberian);
    if (!birth || !eventDate || eventDate < birth) return null;
    let months =
        (eventDate.getFullYear() - birth.getFullYear()) * 12 +
        eventDate.getMonth() -
        birth.getMonth();
    if (eventDate.getDate() < birth.getDate()) months--;
    return Math.max(0, months);
});

const programNotice = computed(() => {
    const age = ageInMonthsAtDate.value;
    if (age === null) return "";
    if (form.jenis === "vitamin_a_biru" && (age < 6 || age > 11)) {
        return `Usia anak pada tanggal tersebut ${age} bulan. Periksa kembali pilihan Vitamin A Biru yang dicatat untuk kelompok usia 6–11 bulan.`;
    }
    if (form.jenis === "vitamin_a_merah" && (age < 12 || age > 59)) {
        return `Usia anak pada tanggal tersebut ${age} bulan. Periksa kembali pilihan Vitamin A Merah yang dicatat untuk kelompok usia 12–59 bulan.`;
    }
    return "";
});

const handleSubmit = () => {
    if (props.loading) return;
    attemptedSubmit.value = true;
    if (Object.keys(fieldErrors.value).length > 0) return;

    const payload = {
        anak_id: props.anakId || form.anak_id,
        jenis: form.jenis,
        tanggal_pemberian: toLocalDateStr(form.tanggal_pemberian),
    };
    if (form.dosis.trim()) payload.dosis = form.dosis.trim();
    if (form.keterangan.trim()) payload.keterangan = form.keterangan.trim();
    emit("submit", payload);
};

watch(
    () => props.anakId,
    (value) => {
        form.anak_id = value || "";
        attemptedSubmit.value = false;
    },
);
</script>
