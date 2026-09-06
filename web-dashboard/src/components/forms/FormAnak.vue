<template>
    <form class="space-y-4 pt-1" novalidate @submit.prevent="handleSubmit">
        <!-- Error dari API -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="flex items-start gap-2.5 p-3 rounded-xl text-xs bg-red-50 border border-red-200 text-red-700"
                role="alert"
                aria-live="assertive"
            >
                <i
                    class="pi pi-exclamation-circle mt-0.5 shrink-0 text-red-600"
                    aria-hidden="true"
                />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- Context Card Ringkasan Anak Saat Mode Edit -->
        <div
            v-if="isEdit && initialData"
            class="p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80 flex items-center justify-between gap-3"
        >
            <div class="flex items-center gap-3 min-w-0">
                <div
                    class="w-10 h-10 rounded-xl flex items-center justify-center font-bold text-sm shrink-0 text-white shadow-2xs bg-emerald-600"
                >
                    {{ initialData.nama ? initialData.nama.charAt(0).toUpperCase() : 'A' }}
                </div>
                <div class="min-w-0">
                    <div class="font-bold text-sm text-slate-800 truncate">
                        {{ initialData.nama }}
                    </div>
                    <div class="text-xs text-slate-500 mt-0.5">
                        <span>{{ hitungUsia(initialData.tanggal_lahir) }}</span>
                    </div>
                </div>
            </div>
            <div class="text-[11px] font-semibold px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-700 border border-emerald-200/60 shrink-0">
                Mode Edit
            </div>
        </div>

        <!-- Orang Tua / Wali (Mode Edit: Kartu Read-Only) -->
        <div v-if="isEdit" class="space-y-1.5">
            <span class="text-xs font-semibold text-slate-700 block ml-0.5">
                Orang Tua / Wali
            </span>
            <div class="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-200/80 text-sm">
                <div class="flex items-center gap-2.5 min-w-0">
                    <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-700 flex items-center justify-center shrink-0">
                        <i class="pi pi-users text-xs" aria-hidden="true" />
                    </div>
                    <div class="truncate">
                        <span class="font-semibold text-slate-800 block truncate">
                            {{ parentName }}
                        </span>
                    </div>
                </div>
                <div class="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-slate-200/70 text-[11px] font-medium text-slate-600 shrink-0">
                    <i class="pi pi-lock text-[10px]" aria-hidden="true" />
                    <span>Terkunci</span>
                </div>
            </div>
        </div>

        <!-- Orang Tua / Wali (Mode Create: Dropdown Pilihan) -->
        <div v-else class="space-y-1.5">
            <label for="orang_tua_id" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Orang Tua / Wali
            </label>
            <div class="relative">
                <i class="pi pi-users input-icon text-slate-400" aria-hidden="true" />
                <select
                    id="orang_tua_id"
                    v-model="form.orang_tua_id"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-9 py-2.5 rounded-xl text-sm appearance-none bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800"
                    aria-required="true"
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
                    class="pi pi-chevron-down absolute right-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none"
                    aria-hidden="true"
                />
            </div>
            <p v-if="fieldError.orang_tua_id" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.orang_tua_id }}
            </p>
        </div>

        <!-- Nama Lengkap Anak -->
        <div class="space-y-1.5">
            <label for="nama_anak" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Nama Lengkap Anak
            </label>
            <div class="relative">
                <i class="pi pi-user input-icon text-slate-400" aria-hidden="true" />
                <input
                    id="nama_anak"
                    v-model="form.nama"
                    type="text"
                    placeholder="Masukkan nama lengkap anak"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800"
                    aria-required="true"
                    :aria-invalid="!!fieldError.nama"
                />
            </div>
            <p v-if="fieldError.nama" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.nama }}
            </p>
        </div>

        <!-- Jenis Kelamin -->
        <div class="space-y-1.5">
            <label class="text-xs font-semibold text-slate-700 block ml-0.5">
                Jenis Kelamin
            </label>
            <div class="grid grid-cols-2 gap-3">
                <label
                    class="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl text-sm cursor-pointer transition-all border select-none"
                    :class="
                        form.jenis_kelamin === 'L'
                            ? 'border-blue-500 bg-blue-50/80 text-blue-700 ring-2 ring-blue-500/20 font-semibold shadow-2xs'
                            : 'border-slate-200 bg-white text-slate-600 hover:border-blue-200 hover:bg-blue-50/30 font-medium'
                    "
                >
                    <input
                        type="radio"
                        value="L"
                        v-model="form.jenis_kelamin"
                        :disabled="loading"
                        class="sr-only"
                        aria-label="Laki-laki"
                    />
                    <i class="pi pi-mars text-sm text-blue-600" aria-hidden="true" />
                    <span>Laki-laki</span>
                </label>

                <label
                    class="flex items-center justify-center gap-2 py-2.5 px-3 rounded-xl text-sm cursor-pointer transition-all border select-none"
                    :class="
                        form.jenis_kelamin === 'P'
                            ? 'border-rose-500 bg-rose-50/80 text-rose-700 ring-2 ring-rose-500/20 font-semibold shadow-2xs'
                            : 'border-slate-200 bg-white text-slate-600 hover:border-rose-200 hover:bg-rose-50/30 font-medium'
                    "
                >
                    <input
                        type="radio"
                        value="P"
                        v-model="form.jenis_kelamin"
                        :disabled="loading"
                        class="sr-only"
                        aria-label="Perempuan"
                    />
                    <i class="pi pi-venus text-sm text-rose-600" aria-hidden="true" />
                    <span>Perempuan</span>
                </label>
            </div>
            <p v-if="fieldError.jenis_kelamin" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.jenis_kelamin }}
            </p>
        </div>

        <!-- Tanggal Lahir -->
        <div class="space-y-1.5">
            <label for="tanggal_lahir" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Tanggal Lahir
            </label>
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

            <!-- Preview usia (hanya tampil pada mode tambah data baru) -->
            <div
                v-if="!isEdit && form.tanggal_lahir && !fieldError.tanggal_lahir"
                class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-emerald-50 text-emerald-700 border border-emerald-200/60 text-xs font-medium mt-1"
            >
                <i class="pi pi-calendar text-[11px] text-emerald-600" aria-hidden="true" />
                <span>Usia saat ini: <strong class="text-emerald-800">{{ previewUsia }}</strong></span>
            </div>

            <p v-if="fieldError.tanggal_lahir" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.tanggal_lahir }}
            </p>

            <!-- Peringatan batas usia -->
            <div
                v-if="currentAgeWarning"
                class="flex items-start gap-2 p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs mt-2"
                role="status"
            >
                <i class="pi pi-exclamation-triangle text-amber-600 shrink-0 mt-0.5" aria-hidden="true" />
                <span>{{ currentAgeWarning.message }}</span>
            </div>
        </div>

        <!-- NIK Anak (Label bersih tanpa keterangan tambahan) -->
        <div class="space-y-1.5">
            <label for="nik_anak" class="text-xs font-semibold text-slate-700 block ml-0.5">
                NIK Anak
            </label>
            <div class="relative">
                <i class="pi pi-id-card input-icon text-slate-400" aria-hidden="true" />
                <input
                    id="nik_anak"
                    v-model="form.nik"
                    type="text"
                    placeholder="1234567890123456"
                    inputmode="numeric"
                    maxlength="16"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm font-mono tracking-wider bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800"
                    :aria-required="!isEdit"
                    :aria-invalid="!!fieldError.nik"
                    @input="form.nik = form.nik.replace(/\D/g, '')"
                />
            </div>
            <p v-if="fieldError.nik" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldError.nik }}
            </p>
        </div>

        <!-- Tombol aksi -->
        <div class="flex gap-3 pt-3">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer border-0 disabled:opacity-50"
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                :disabled="loading || !isValid"
                class="btn-primary flex-1 py-2.5 rounded-xl text-sm font-semibold text-white transition-all flex items-center justify-center gap-2 cursor-pointer shadow-sm hover:shadow-md disabled:opacity-50 disabled:cursor-not-allowed"
            >
                <i
                    v-if="loading"
                    class="pi pi-spin pi-spinner text-xs"
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

const parentName = computed(() => {
    if (props.initialData?.nama_orang_tua) {
        return props.initialData.nama_orang_tua;
    }
    const targetId = form.orang_tua_id || props.initialData?.orang_tua_id;
    const found = props.orangTuaList.find((ot) => ot.id === targetId);
    return found ? found.nama_lengkap : "—";
});

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
    return isEdit.value ? "Perbarui Data Anak" : "Simpan";
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

<style scoped>
.btn-primary {
    border: 0;
    background: #059669;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-primary:hover:not(:disabled) {
    background: #047857;
}

.btn-primary:active:not(:disabled) {
    transform: scale(0.99);
}
</style>
