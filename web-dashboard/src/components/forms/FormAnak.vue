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
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
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
                    class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
            </div>
            <p v-if="fieldError.orang_tua_id" class="error-hint">
                {{ fieldError.orang_tua_id }}
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
        </div>

        <!-- No KK -->
        <div class="space-y-1.5">
            <label for="no_kk" class="field-label">
                No. Kartu Keluarga
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(16 digit)</span
                >
            </label>
            <div class="relative">
                <i class="pi pi-home input-icon" aria-hidden="true" />
                <input
                    id="no_kk"
                    v-model="form.no_kk"
                    type="text"
                    placeholder="1234567890123456"
                    inputmode="numeric"
                    maxlength="16"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm font-mono"
                    aria-required="true"
                    :aria-invalid="!!fieldError.no_kk"
                    @input="form.no_kk = form.no_kk.replace(/\D/g, '')"
                />
            </div>
            <p v-if="fieldError.no_kk" class="error-hint">
                {{ fieldError.no_kk }}
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
                <span>{{ loading ? "Menyimpan..." : "Simpan" }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { ref, computed, reactive } from "vue";
import { DatePicker } from "primevue";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    orangTuaList: { type: Array, default: () => [] },
});
const emit = defineEmits(["submit", "cancel"]);

const form = reactive({
    orang_tua_id: "",
    nama: "",
    jenis_kelamin: "",
    tanggal_lahir: "",
    no_kk: "",
});

const submitted = ref(false);

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

/* ── Hari ini sebagai max date ───────────────────────────────────── */
const todayDate = new Date();

/* ── Preview usia ────────────────────────────────────────────────── */
const previewUsia = computed(() => {
    if (!form.tanggal_lahir) return "";
    const lahir = new Date(form.tanggal_lahir);
    const now = new Date();
    const bulan =
        (now.getFullYear() - lahir.getFullYear()) * 12 +
        (now.getMonth() - lahir.getMonth());
    if (bulan < 0) return "";
    if (bulan < 24) return `${bulan} bulan`;
    return `${Math.floor(bulan / 12)} tahun ${bulan % 12} bulan`;
});

/* ── Validasi per field ──────────────────────────────────────────── */
const fieldError = computed(() => {
    const e = {};
    if (submitted.value && !form.orang_tua_id)
        e.orang_tua_id = "Pilih orang tua terlebih dahulu";
    if (form.nama && form.nama.trim().length < 2)
        e.nama = "Nama minimal 2 karakter";
    if (submitted.value && !form.jenis_kelamin)
        e.jenis_kelamin = "Pilih jenis kelamin";
    if (form.tanggal_lahir && form.tanggal_lahir > new Date())
        e.tanggal_lahir = "Tanggal lahir tidak boleh di masa depan";
    if (form.no_kk && !/^\d{16}$/.test(form.no_kk))
        e.no_kk = "No. KK harus tepat 16 digit angka";
    return e;
});

/* ── Form valid ──────────────────────────────────────────────────── */
const isValid = computed(
    () =>
        form.orang_tua_id &&
        form.nama.trim().length >= 2 &&
        ["L", "P"].includes(form.jenis_kelamin) &&
        form.tanggal_lahir &&
        /^\d{16}$/.test(form.no_kk) &&
        Object.keys(fieldError.value).length === 0,
);

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    submitted.value = true;
    if (!isValid.value || props.loading) return;
    emit("submit", {
        orang_tua_id: form.orang_tua_id,
        nama: form.nama.trim(),
        jenis_kelamin: form.jenis_kelamin,
        tanggal_lahir: form.tanggal_lahir
            ? form.tanggal_lahir.toISOString().split("T")[0]
            : "",
        no_kk: form.no_kk,
    });
};
</script>
