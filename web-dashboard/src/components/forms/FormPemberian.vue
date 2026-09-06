<template>
    <form class="space-y-4 pt-1" novalidate @submit.prevent="handleSubmit">
        <!-- Error Alert dari API -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="flex items-start gap-2.5 p-3 rounded-xl text-xs bg-red-50 border border-red-200 text-red-700"
                role="alert"
                aria-live="assertive"
            >
                <i class="pi pi-exclamation-circle mt-0.5 shrink-0 text-red-600" aria-hidden="true" />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- Dropdown Pilih Anak (Hanya jika anak belum dipilih dari luar) -->
        <div v-if="!anakId" class="space-y-1.5">
            <label for="form_anak_id" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Nama Anak
            </label>
            <div class="relative">
                <i class="pi pi-user absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none" aria-hidden="true" />
                <select
                    id="form_anak_id"
                    v-model="form.anak_id"
                    :disabled="loading"
                    class="w-full pl-9 pr-8 py-2.5 rounded-xl text-sm appearance-none bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
                    aria-required="true"
                    :aria-invalid="!!fieldErrors.anak_id"
                    aria-describedby="form_anak_id_error"
                >
                    <option value="" disabled>Pilih anak</option>
                    <option v-for="item in anakList" :key="item.id" :value="item.id">
                        {{ item.nama }} — {{ item.nama_orang_tua || '—' }}
                    </option>
                </select>
                <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
            </div>
            <p v-if="fieldErrors.anak_id" id="form_anak_id_error" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldErrors.anak_id }}
            </p>
        </div>

        <!-- Kartu Pilihan Jenis Pemberian -->
        <fieldset class="space-y-2 m-0 p-0 border-0">
            <div class="flex items-center justify-between">
                <legend class="text-xs font-semibold text-slate-700 block ml-0.5">
                    Jenis Pemberian
                </legend>
                <span class="text-[11px] text-slate-400">Pilih salah satu</span>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                <label
                    v-for="jenis in JENIS_VALID"
                    :key="jenis"
                    class="relative flex items-center justify-between p-3 rounded-xl cursor-pointer transition-all border select-none"
                    :class="
                        form.jenis === jenis
                            ? 'border-emerald-500 bg-emerald-50/50 ring-2 ring-emerald-500/20 shadow-2xs'
                            : 'border-slate-200 bg-white hover:border-slate-300 hover:bg-slate-50/60'
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
                        @change="onJenisChange(jenis)"
                    />
                    <div class="flex items-center gap-2.5 min-w-0">
                        <div
                            class="w-8 h-8 rounded-lg flex items-center justify-center text-xs shrink-0"
                            :style="`background: ${warnaBg[jenis]}; color: ${warnaText[jenis]}`"
                        >
                            <i :class="`pi ${customIkonJenis[jenis]}`" aria-hidden="true" />
                        </div>
                        <div class="min-w-0">
                            <p class="font-semibold text-xs text-slate-800 leading-tight m-0 truncate">
                                {{ LABEL_JENIS[jenis] }}
                            </p>
                            <span class="text-[10px] text-slate-400 block mt-0.5">
                                {{ KETERANGAN_USIA[jenis] }}
                            </span>
                        </div>
                    </div>
                </label>
            </div>
            <p v-if="fieldErrors.jenis" id="jenis_pemberian_error" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldErrors.jenis }}
            </p>
        </fieldset>

        <!-- Tanggal Pemberian -->
        <div class="space-y-1.5 pt-3.5">
            <label for="tanggal_pemberian" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Tanggal Pemberian
            </label>
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
                class="text-xs text-red-600 mt-1 ml-0.5"
            >
                {{ fieldErrors.tanggal_pemberian }}
            </p>
            <p
                v-else-if="programNotice"
                id="program_notice"
                class="flex items-start gap-2.5 p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed m-0 shadow-2xs mt-1.5"
            >
                <i class="pi pi-exclamation-triangle mt-0.5 text-amber-600 shrink-0" aria-hidden="true" />
                <span>{{ programNotice }}</span>
            </p>
        </div>

        <!-- Dosis atau Jumlah & Pilihan Cepat -->
        <div class="space-y-1.5 pt-3.5">
            <label for="dosis" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Dosis atau Jumlah
            </label>
            <input
                id="dosis"
                v-model="form.dosis"
                type="text"
                maxlength="50"
                placeholder="Contoh: 1 Kapsul, 1 Tablet, atau 2 bungkus"
                :disabled="loading"
                class="w-full px-3.5 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
            />

            <!-- Quick Chips Pilihan Cepat Dosis -->
            <div v-if="activePresets.length > 0" class="flex items-center gap-1.5 flex-wrap pt-1">
                <span class="text-[11px] text-slate-400 mr-0.5">Pilihan cepat:</span>
                <button
                    v-for="preset in activePresets"
                    :key="preset"
                    type="button"
                    class="text-xs px-2.5 py-1 rounded-lg border transition-all cursor-pointer font-medium"
                    :class="
                        form.dosis === preset
                            ? 'border-emerald-600 bg-emerald-50 text-emerald-700 font-semibold'
                            : 'border-slate-200 bg-white text-slate-600 hover:border-emerald-300 hover:bg-emerald-50/40'
                    "
                    @click="applyPreset(preset)"
                >
                    {{ preset }}
                </button>
            </div>
        </div>

        <!-- Keterangan -->
        <div class="space-y-1.5 pt-3.5">
            <div class="flex items-center justify-between gap-3">
                <label for="keterangan" class="text-xs font-semibold text-slate-700 block ml-0.5">
                    Keterangan
                </label>
                <span class="text-[10px] text-slate-400">{{ form.keterangan.length }}/2000</span>
            </div>
            <textarea
                id="keterangan"
                v-model="form.keterangan"
                rows="2"
                maxlength="2000"
                placeholder="Catatan tambahan jika ada..."
                :disabled="loading"
                class="w-full px-3.5 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none resize-none"
            />
        </div>

        <!-- Tombol Aksi -->
        <div class="flex gap-3 pt-2">
            <button
                v-if="!loading"
                type="button"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer border-0"
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                class="btn-primary flex-1 py-2.5 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 cursor-pointer shadow-sm hover:shadow transition-all"
                :aria-busy="loading"
            >
                <i v-if="loading" class="pi pi-spin pi-spinner text-xs" aria-hidden="true" />
                <i v-else class="pi pi-arrow-right text-xs" aria-hidden="true" />
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
    WARNA_JENIS as warnaText,
    WARNA_BG_JENIS as warnaBg,
} from "@/stores/pemberianStore";
import { toLocalDateStr } from "@/utils/format.js";

// Custom ikon jenis untuk menghindari penggunaan pi-heart
const customIkonJenis = {
    vitamin_a_merah: "pi-sun",
    vitamin_a_biru: "pi-sun",
    obat_cacing: "pi-shield",
    pmt_biskuit: "pi-box",
    pmt_susu: "pi-inbox",
    pmt_lainnya: "pi-apple",
};

const KETERANGAN_USIA = {
    vitamin_a_biru: "6–11 bln",
    vitamin_a_merah: "12–59 bln",
    obat_cacing: "1–5 thn",
    pmt_biskuit: "Balita",
    pmt_susu: "Balita",
    pmt_lainnya: "Balita",
};

const PRESET_DOSIS = {
    vitamin_a_biru: ["1 Kapsul (100.000 IU)"],
    vitamin_a_merah: ["1 Kapsul (200.000 IU)"],
    obat_cacing: ["1 Tablet (400 mg)", "½ Tablet (200 mg)"],
    pmt_biskuit: ["1 Bungkus", "2 Bungkus", "1 Dus"],
    pmt_susu: ["1 Kotak", "1 Gelas (200 ml)"],
    pmt_lainnya: ["1 Porsi", "1 Paket"],
};

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

const activePresets = computed(() => {
    if (!form.jenis) return [];
    return PRESET_DOSIS[form.jenis] || [];
});

const applyPreset = (preset) => {
    form.dosis = preset;
};

const onJenisChange = (jenis) => {
    form.jenis = jenis;
    const presets = PRESET_DOSIS[jenis] || [];
    if (presets.length === 1) {
        form.dosis = presets[0];
    } else {
        form.dosis = "";
    }
};

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
