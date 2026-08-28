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

        <!-- Tanggal -->
        <div class="space-y-1.5">
            <label for="tanggal_jadwal" class="field-label">Tanggal</label>
            <DatePicker
                id="tanggal_jadwal"
                v-model="form.tanggal"
                :min-date="todayDate"
                :disabled="loading"
                date-format="dd/mm/yy"
                placeholder="Pilih tanggal jadwal"
                show-icon
                icon-display="input"
                fluid
                class="w-full"
                aria-required="true"
            />
            <p v-if="fieldError.tanggal" class="error-hint">
                {{ fieldError.tanggal }}
            </p>
        </div>

        <!-- Waktu mulai & selesai -->
        <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1.5">
                <label for="waktu_mulai" class="field-label">Waktu Mulai</label>
                <div class="relative">
                    <i class="pi pi-clock input-icon" aria-hidden="true" />
                    <input
                        id="waktu_mulai"
                        v-model="form.waktu_mulai"
                        type="time"
                        :disabled="loading"
                        class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                        aria-required="true"
                    />
                </div>
            </div>
            <div class="space-y-1.5">
                <label for="waktu_selesai" class="field-label"
                    >Waktu Selesai</label
                >
                <div class="relative">
                    <i class="pi pi-clock input-icon" aria-hidden="true" />
                    <input
                        id="waktu_selesai"
                        v-model="form.waktu_selesai"
                        type="time"
                        :disabled="loading"
                        class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                        aria-required="true"
                    />
                </div>
            </div>
        </div>
        <p v-if="fieldError.waktu" class="error-hint">{{ fieldError.waktu }}</p>

        <!-- Lokasi -->
        <div class="space-y-1.5">
            <label for="lokasi" class="field-label">Lokasi</label>
            <div class="relative">
                <i class="pi pi-map-marker input-icon" aria-hidden="true" />
                <input
                    id="lokasi"
                    v-model="form.lokasi"
                    type="text"
                    placeholder="contoh: Balai Desa RT 03"
                    :disabled="loading"
                    maxlength="255"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-required="true"
                />
            </div>
            <p v-if="fieldError.lokasi" class="error-hint">
                {{ fieldError.lokasi }}
            </p>
        </div>

        <!-- Keterangan (opsional) -->
        <div class="space-y-1.5">
            <label for="keterangan_jadwal" class="field-label">
                Keterangan
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(opsional)</span
                >
            </label>
            <textarea
                id="keterangan_jadwal"
                v-model="form.keterangan"
                rows="3"
                placeholder="Informasi tambahan untuk peserta posyandu..."
                :disabled="loading"
                maxlength="2000"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
            />
        </div>

        <!-- Info notifikasi -->
        <div
            class="flex items-start gap-2 px-3 py-2.5 rounded-xl text-xs"
            style="
                background: var(--color-green-50);
                border: 1px solid var(--color-input-border);
                color: var(--color-text-body);
            "
        >
            <i
                class="pi pi-bell mt-0.5 flex-shrink-0"
                style="color: var(--color-green-700)"
                aria-hidden="true"
            />
            <span
                >{{
                    mode === "edit"
                        ? "Notifikasi akan dikirim jika tanggal, waktu, atau lokasi berubah."
                        : "Notifikasi akan dikirim otomatis ke semua orang tua yang terdaftar."
                }}</span
            >
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
                <span>{{
                    loading
                        ? "Menyimpan..."
                        : mode === "edit"
                          ? "Simpan Perubahan"
                          : "Buat Jadwal"
                }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { reactive, computed, watch } from "vue";
import { DatePicker } from "primevue";
import { toLocalDateStr } from "@/utils/format.js";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    mode: { type: String, default: "create" },
    initialData: { type: Object, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const todayDate = new Date();
const todayStr = toLocalDateStr(todayDate);

const form = reactive({
    tanggal: "",
    waktu_mulai: "08:00",
    waktu_selesai: "11:00",
    lokasi: "",
    keterangan: "",
});

watch(
    () => props.initialData,
    (data) => {
        form.tanggal = data?.tanggal
            ? new Date(`${data.tanggal}T00:00:00`)
            : "";
        form.waktu_mulai = data?.waktu_mulai?.slice(0, 5) ?? "08:00";
        form.waktu_selesai = data?.waktu_selesai?.slice(0, 5) ?? "11:00";
        form.lokasi = data?.lokasi ?? "";
        form.keterangan = data?.keterangan ?? "";
    },
    { immediate: true },
);

/* ── Validasi ────────────────────────────────────────────────────── */
const fieldError = computed(() => {
    const e = {};
    const tanggalStr = toLocalDateStr(form.tanggal);
    if (tanggalStr && tanggalStr < todayStr)
        e.tanggal = "Tanggal tidak boleh di masa lalu";
    if (
        form.waktu_mulai &&
        form.waktu_selesai &&
        form.waktu_selesai <= form.waktu_mulai
    )
        e.waktu = "Waktu selesai harus setelah waktu mulai";
    if (form.lokasi && form.lokasi.trim().length < 3)
        e.lokasi = "Lokasi minimal 3 karakter";
    return e;
});

const isValid = computed(
    () =>
        form.tanggal &&
        form.waktu_mulai &&
        form.waktu_selesai &&
        form.lokasi.trim().length >= 3 &&
        Object.keys(fieldError.value).length === 0,
);

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    if (!isValid.value || props.loading) return;
    const payload = {
        tanggal: toLocalDateStr(form.tanggal) || "",
        waktu_mulai: form.waktu_mulai,
        waktu_selesai: form.waktu_selesai,
        lokasi: form.lokasi.trim(),
    };
    if (form.keterangan.trim()) payload.keterangan = form.keterangan.trim();
    emit("submit", payload);
};
</script>
