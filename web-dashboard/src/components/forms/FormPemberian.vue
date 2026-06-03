<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <!-- Error API -->
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

        <!-- Pilih Anak (jika anakId tidak di-lock dari parent) -->
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
                >
                    <option value="" disabled>Pilih anak</option>
                    <option v-for="a in anakList" :key="a.id" :value="a.id">
                        {{ a.nama }} — {{ a.nama_orang_tua }}
                    </option>
                </select>
                <i
                    class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
            </div>
        </div>

        <!-- Jenis Pemberian -->
        <div class="space-y-1.5">
            <label class="field-label">Jenis Pemberian</label>
            <div class="grid grid-cols-2 gap-2">
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
                        type="radio"
                        :value="jenis"
                        v-model="form.jenis"
                        :disabled="loading"
                        class="sr-only"
                    />
                    <i
                        :class="`pi ${ikonJenis[jenis]} text-sm`"
                        aria-hidden="true"
                    />
                    <span class="font-medium text-xs">{{
                        LABEL_JENIS[jenis]
                    }}</span>
                </label>
            </div>
        </div>

        <!-- Nama Item — dropdown dinamis sesuai jenis -->
        <div v-if="form.jenis" class="space-y-1.5">
            <label for="nama_item" class="field-label">{{
                labelNamaItem
            }}</label>
            <div class="relative">
                <i class="pi pi-list input-icon" aria-hidden="true" />
                <select
                    id="nama_item"
                    v-model="form.nama_item"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
                    aria-required="true"
                >
                    <option value="" disabled>
                        Pilih {{ labelNamaItem.toLowerCase() }}
                    </option>
                    <option
                        v-for="item in pilihanNamaItem"
                        :key="item"
                        :value="item"
                        :disabled="
                            form.jenis === 'imunisasi' &&
                            imunisasiSudah.includes(item)
                        "
                    >
                        {{ item }}
                        {{
                            form.jenis === "imunisasi" &&
                            imunisasiSudah.includes(item)
                                ? "✓ sudah"
                                : ""
                        }}
                    </option>
                </select>
                <i
                    class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
            </div>

            <!-- Warning imunisasi duplikat -->
            <Transition name="slide-down">
                <div
                    v-if="
                        form.jenis === 'imunisasi' &&
                        imunisasiSudah.includes(form.nama_item)
                    "
                    class="flex items-center gap-2 px-3 py-2 rounded-lg text-xs"
                    style="
                        background: #fef3c7;
                        border: 1px solid #fcd34d;
                        color: #92400e;
                    "
                >
                    <i
                        class="pi pi-exclamation-triangle flex-shrink-0"
                        aria-hidden="true"
                    />
                    <span>Imunisasi ini sudah pernah diberikan sebelumnya</span>
                </div>
            </Transition>
        </div>

        <!-- Tanggal Pemberian -->
        <div class="space-y-1.5">
            <label for="tanggal_pemberian" class="field-label"
                >Tanggal Pemberian</label
            >
            <DatePicker
                id="tanggal_pemberian"
                v-model="form.tanggal_pemberian"
                :max-date="todayDate"
                :disabled="loading"
                date-format="dd/mm/yy"
                placeholder="Pilih tanggal pemberian"
                show-icon
                icon-display="input"
                fluid
                class="w-full"
                aria-required="true"
            />
        </div>

        <!-- Dosis (opsional) -->
        <div class="space-y-1.5">
            <label for="dosis" class="field-label">
                Dosis
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(opsional)</span
                >
            </label>
            <div class="relative">
                <i class="pi pi-bookmark input-icon" aria-hidden="true" />
                <input
                    id="dosis"
                    v-model="form.dosis"
                    type="text"
                    placeholder="contoh: 0.5 ml, 1 tablet"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                />
            </div>
        </div>

        <!-- Keterangan (opsional) -->
        <div class="space-y-1.5">
            <label for="keterangan" class="field-label">
                Keterangan
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(opsional)</span
                >
            </label>
            <textarea
                id="keterangan"
                v-model="form.keterangan"
                rows="2"
                placeholder="Catatan tambahan jika ada..."
                :disabled="loading"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
            />
        </div>

        <!-- Tombol aksi -->
        <div class="flex gap-3 pt-2">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold border transition-colors"
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
                class="btn-submit flex-1 py-2.5 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed"
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
import { reactive, computed, watch } from "vue";
import { DatePicker } from "primevue";
import { JENIS_VALID, LABEL_JENIS, PILIHAN } from "@/stores/pemberianStore";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    anakId: { type: String, default: "" },
    anakList: { type: Array, default: () => [] },
    imunisasiSudah: { type: Array, default: () => [] },
});
const emit = defineEmits(["submit", "cancel"]);

const todayDate = new Date();
const todayStr = todayDate.toISOString().split("T")[0];

const form = reactive({
    anak_id: props.anakId || "",
    jenis: "",
    nama_item: "",
    tanggal_pemberian: todayDate,
    dosis: "",
    keterangan: "",
});

/* ── Ikon & warna per jenis ──────────────────────────────────────── */
const ikonJenis = {
    imunisasi: "pi-shield",
    vitamin_a: "pi-sun",
    obat_cacing: "pi-heart",
    pmt: "pi-apple",
};
const warnaText = {
    imunisasi: "#1d4ed8",
    vitamin_a: "#d97706",
    obat_cacing: "#15803d",
    pmt: "#7c3aed",
};
const warnaBg = {
    imunisasi: "#dbeafe",
    vitamin_a: "#fef3c7",
    obat_cacing: "#dcfce7",
    pmt: "#ede9fe",
};

/* ── Pilihan nama item sesuai jenis ──────────────────────────────── */
const pilihanNamaItem = computed(() => PILIHAN[form.jenis] || []);

const labelNamaItem = computed(() => {
    const map = {
        imunisasi: "Jenis Imunisasi",
        vitamin_a: "Jenis Vitamin A",
        obat_cacing: "Jenis Obat Cacing",
        pmt: "Jenis PMT",
    };
    return map[form.jenis] ?? "Nama Item";
});

/* ── Reset nama_item saat jenis berubah ──────────────────────────── */
watch(
    () => form.jenis,
    () => {
        form.nama_item = "";
    },
);

/* ── Validasi ────────────────────────────────────────────────────── */
const isValid = computed(
    () =>
        (props.anakId || form.anak_id) &&
        form.jenis &&
        form.nama_item &&
        form.tanggal_pemberian,
);

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    if (!isValid.value || props.loading) return;
    const payload = {
        anak_id: props.anakId || form.anak_id,
        jenis: form.jenis,
        nama_item: form.nama_item,
        tanggal_pemberian: form.tanggal_pemberian
            ? form.tanggal_pemberian.toISOString().split("T")[0]
            : todayStr,
    };
    if (form.dosis.trim()) payload.dosis = form.dosis.trim();
    if (form.keterangan.trim()) payload.keterangan = form.keterangan.trim();
    emit("submit", payload);
};
</script>
