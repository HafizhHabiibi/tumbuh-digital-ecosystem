<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <!-- Error dari API -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                role="alert"
                aria-live="assertive"
            >
                <i
                    class="pi pi-exclamation-circle mt-0.5 flex-shrink-0"
                    aria-hidden="true"
                />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- Orang Tua -->
        <div class="space-y-1.5">
            <label for="orang_tua_id" class="field-label"
                >Orang Tua / Wali</label
            >
            <div class="relative">
                <i class="pi pi-users input-icon" aria-hidden="true" />
                <select
                    id="orang_tua_id"
                    v-model="form.orang_tua_id"
                    :disabled="loading || isEdit"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
                    :aria-required="!isEdit"
                    :aria-invalid="!!fieldError.orang_tua_id"
                >
                    <option value="" disabled>Pilih orang tua</option>
                    <option
                        v-for="ot in orangTuaList"
                        :key="ot.id"
                        :value="ot.id"
                    >
                        {{ ot.nama_lengkap }}
                    </option>
                </select>
                <i
                    class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
            </div>
            <p v-if="fieldError.orang_tua_id" class="error-hint">
                {{ fieldError.orang_tua_id }}
            </p>
            <p
                v-else-if="isEdit"
                class="text-xs m-0"
                style="color: var(--color-text-muted)"
            >
                Relasi orang tua tidak dapat dipindahkan dari data master.
            </p>
        </div>

        <!-- Nama Anak -->
        <div class="space-y-1.5">
            <label for="nama_anak" class="field-label">Nama Anak</label>
            <div class="relative">
                <i class="pi pi-heart input-icon" aria-hidden="true" />
                <input
                    id="nama_anak"
                    v-model="form.nama"
                    type="text"
                    placeholder="Masukkan nama anak"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-required="true"
                    :aria-invalid="!!fieldError.nama"
                />
            </div>
            <p v-if="fieldError.nama" class="error-hint">
                {{ fieldError.nama }}
            </p>
        </div>

        <!-- Jenis Kelamin -->
        <div class="space-y-1.5">
            <label class="field-label">Jenis Kelamin</label>
            <div class="flex gap-3">
                <label
                    v-for="opt in jkOptions"
                    :key="opt.value"
                    class="jk-option flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl text-sm font-medium cursor-pointer transition-all border"
                    :class="
                        form.jenis_kelamin === opt.value
                            ? 'jk-option--active'
                            : ''
                    "
                    :style="
                        form.jenis_kelamin === opt.value
                            ? `background: ${opt.bg}; border-color: ${opt.color}; color: ${opt.color}`
                            : 'background: var(--color-input-bg); border-color: var(--color-input-border); color: var(--color-text-muted)'
                    "
                >
                    <input
                        type="radio"
                        :value="opt.value"
                        v-model="form.jenis_kelamin"
                        :disabled="loading"
                        class="sr-only"
                        :aria-label="opt.label"
                    />
                    <i :class="`pi ${opt.icon} text-sm`" aria-hidden="true" />
                    {{ opt.label }}
                </label>
            </div>
            <p v-if="fieldError.jenis_kelamin" class="error-hint">
                {{ fieldError.jenis_kelamin }}
            </p>
        </div>

        <!-- Tanggal Lahir -->
        <div class="space-y-1.5">
            <label for="tanggal_lahir" class="field-label">Tanggal Lahir</label>
                <DatePicker
                    id="tanggal_lahir"
                    v-model="form.tanggal_lahir"
                    :max-date="todayDate"
                    :disabled="loading"
                    date-format="dd/mm/yy"
                    placeholder="Pilih tanggal lahir"
                    show-icon
                    icon-display="input"
                    fluid
                    class="w-full"
                    aria-required="true"
                    :aria-invalid="!!fieldError.tanggal_lahir"
                />
            <!-- Preview usia -->
            <p
                v-if="form.tanggal_lahir && !fieldError.tanggal_lahir"
                class="text-xs ml-1"
                style="color: var(--color-green-700)"
            >
                Usia saat ini: {{ previewUsia }}
            </p>
            <p v-if="fieldError.tanggal_lahir" class="error-hint">
                {{ fieldError.tanggal_lahir }}
            </p>
            <p
                v-if="currentAgeWarning"
                class="text-xs ml-1 px-3 py-2 rounded-lg"
                style="background: #fffbeb; color: #92400e"
                role="status"
            >
                <i class="pi pi-exclamation-triangle mr-1" />
                {{ currentAgeWarning.message }}
            </p>
        </div>

        <!-- NIK Anak -->
        <div class="space-y-1.5">
            <label for="nik_anak" class="field-label">
                NIK Anak
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >{{ isEdit ? "(opsional, 16 digit)" : "(16 digit)" }}</span
                >
            </label>
            <div class="relative">
                <i class="pi pi-id-card input-icon" aria-hidden="true" />
                <input
                    id="nik_anak"
                    v-model="form.nik"
                    type="text"
                    placeholder="1234567890123456"
                    inputmode="numeric"
                    maxlength="16"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm font-mono"
                    :aria-required="!isEdit"
                    :aria-invalid="!!fieldError.nik"
                    @input="form.nik = form.nik.replace(/\D/g, '')"
                />
            </div>
            <p v-if="fieldError.nik" class="error-hint">
                {{ fieldError.nik }}
            </p>
        </div>

        <!-- Tombol aksi -->
        <div class="flex gap-3 pt-2">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold transition-colors border"
                style="
                    background: white;
                    color: var(--color-text-body);
                    border-color: var(--color-input-border);
                "
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                :disabled="loading || !isValid"
                class="btn-submit flex-1 py-2.5 rounded-xl text-sm font-semibold text-white transition-all flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed"
            >
                <i
                    v-if="loading"
                    class="pi pi-spin pi-spinner"
                    aria-hidden="true"
                />
                <span>{{ submitLabel }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { ref, computed, reactive, watch } from "vue";
import { DatePicker } from "primevue";
import { hitungUsia, toLocalDateStr } from "@/utils/format.js";
import { getCurrentAgeMeasurementWarning } from "@/utils/measurementEligibility.js";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    orangTuaList: { type: Array, default: () => [] },
    mode: {
        type: String,
        default: "create",
        validator: (value) => ["create", "edit"].includes(value),
    },
    initialData: { type: Object, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const form = reactive({
    orang_tua_id: "",
    nama: "",
    jenis_kelamin: "",
    tanggal_lahir: "",
    nik: "",
});

const submitted = ref(false);
const isEdit = computed(() => props.mode === "edit");

const parseLocalDate = (value) => {
    if (!value) return "";
    if (value instanceof Date) return value;
    const datePart = String(value).slice(0, 10);
    const parsed = new Date(`${datePart}T00:00:00`);
    return Number.isNaN(parsed.getTime()) ? "" : parsed;
};

watch(
    () => props.initialData,
    (data) => {
        form.orang_tua_id = data?.orang_tua_id || "";
        form.nama = data?.nama || "";
        form.jenis_kelamin = data?.jenis_kelamin || "";
        form.tanggal_lahir = parseLocalDate(data?.tanggal_lahir);
        form.nik = data?.nik || "";
        submitted.value = false;
    },
    { immediate: true },
);

const jkOptions = [
    {
        value: "L",
        label: "Laki-laki",
        icon: "pi-mars",
        color: "#1d4ed8",
        bg: "#dbeafe",
    },
    {
        value: "P",
        label: "Perempuan",
        icon: "pi-venus",
        color: "#be185d",
        bg: "#fce7f3",
    },
];

const todayDate = new Date();

const previewUsia = computed(() => {
    if (!form.tanggal_lahir) return "";
    const hasil = hitungUsia(form.tanggal_lahir);
    return hasil === "-" ? "" : hasil;
});

const currentAgeWarning = computed(() =>
    getCurrentAgeMeasurementWarning(form.tanggal_lahir, todayDate),
);

const fieldError = computed(() => {
    const e = {};
    if (!isEdit.value && submitted.value && !form.orang_tua_id)
        e.orang_tua_id = "Pilih orang tua terlebih dahulu";
    if (form.nama && form.nama.trim().length < 2)
        e.nama = "Nama minimal 2 karakter";
    if (submitted.value && !form.jenis_kelamin)
        e.jenis_kelamin = "Pilih jenis kelamin";
    if (form.tanggal_lahir && form.tanggal_lahir > new Date())
        e.tanggal_lahir = "Tanggal lahir tidak boleh di masa depan";
    if (form.nik && !/^\d{16}$/.test(form.nik))
        e.nik = "NIK harus tepat 16 digit angka";
    if (!isEdit.value && submitted.value && !form.nik)
        e.nik = "NIK anak wajib diisi";
    return e;
});

const isValid = computed(
    () =>
        (isEdit.value || form.orang_tua_id) &&
        form.nama.trim().length >= 2 &&
        ["L", "P"].includes(form.jenis_kelamin) &&
        form.tanggal_lahir &&
        (isEdit.value
            ? !form.nik || /^\d{16}$/.test(form.nik)
            : /^\d{16}$/.test(form.nik)) &&
        Object.keys(fieldError.value).length === 0,
);

const submitLabel = computed(() => {
    if (props.loading) return "Menyimpan...";
    return isEdit.value ? "Perbarui" : "Simpan";
});

const handleSubmit = () => {
    submitted.value = true;
    if (!isValid.value || props.loading) return;

    const payload = {
        nama: form.nama.trim(),
        jenis_kelamin: form.jenis_kelamin,
        tanggal_lahir: toLocalDateStr(form.tanggal_lahir) || "",
        nik: form.nik || undefined,
    };
    if (!isEdit.value) payload.orang_tua_id = form.orang_tua_id;
    emit("submit", payload);
};
</script>
