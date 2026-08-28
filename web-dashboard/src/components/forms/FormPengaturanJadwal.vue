<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <div
            v-if="error"
            class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
            role="alert"
        >
            <i class="pi pi-exclamation-circle mt-0.5" aria-hidden="true" />
            <span>{{ error }}</span>
        </div>

        <div class="space-y-1.5">
            <label for="hari_tetap" class="field-label">Tanggal setiap bulan</label>
            <input
                id="hari_tetap"
                v-model.number="form.hari_tetap"
                type="number"
                min="1"
                max="28"
                :disabled="loading"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
            />
            <p class="text-xs m-0" style="color: var(--color-text-muted)">
                Gunakan tanggal 1–28 agar valid pada setiap bulan.
            </p>
        </div>

        <div class="grid grid-cols-2 gap-3">
            <div class="space-y-1.5">
                <label for="pengaturan_mulai" class="field-label">Waktu Mulai</label>
                <input
                    id="pengaturan_mulai"
                    v-model="form.waktu_mulai"
                    type="time"
                    :disabled="loading"
                    class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                />
            </div>
            <div class="space-y-1.5">
                <label for="pengaturan_selesai" class="field-label">Waktu Selesai</label>
                <input
                    id="pengaturan_selesai"
                    v-model="form.waktu_selesai"
                    type="time"
                    :disabled="loading"
                    class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                />
            </div>
        </div>
        <p v-if="waktuTidakValid" class="error-hint">
            Waktu selesai harus setelah waktu mulai
        </p>

        <div class="space-y-1.5">
            <label for="lokasi_default" class="field-label">Lokasi Default</label>
            <input
                id="lokasi_default"
                v-model="form.lokasi_default"
                type="text"
                maxlength="255"
                :disabled="loading"
                placeholder="Contoh: Balai Desa RT 03"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
            />
        </div>

        <div class="flex gap-3 pt-2">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold border"
                style="background: white; color: var(--color-text-body); border-color: var(--color-input-border)"
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                :disabled="loading || !isValid"
                class="btn-submit flex-1 py-2.5 rounded-xl text-sm font-semibold text-white disabled:opacity-60"
            >
                {{ loading ? "Menyimpan..." : "Simpan Pengaturan" }}
            </button>
        </div>
    </form>
</template>

<script setup>
import { computed, reactive, watch } from "vue";

const props = defineProps({
    initialData: { type: Object, default: null },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const form = reactive({
    hari_tetap: 1,
    waktu_mulai: "08:00",
    waktu_selesai: "11:00",
    lokasi_default: "",
});

watch(
    () => props.initialData,
    (data) => {
        form.hari_tetap = Number(data?.hari_tetap ?? 1);
        form.waktu_mulai = data?.waktu_mulai?.slice(0, 5) ?? "08:00";
        form.waktu_selesai = data?.waktu_selesai?.slice(0, 5) ?? "11:00";
        form.lokasi_default = data?.lokasi_default ?? "";
    },
    { immediate: true },
);

const waktuTidakValid = computed(
    () => form.waktu_selesai <= form.waktu_mulai,
);
const isValid = computed(
    () =>
        Number.isInteger(form.hari_tetap) &&
        form.hari_tetap >= 1 &&
        form.hari_tetap <= 28 &&
        form.lokasi_default.trim().length >= 3 &&
        !waktuTidakValid.value,
);

const handleSubmit = () => {
    if (!isValid.value || props.loading) return;
    emit("submit", {
        hari_tetap: form.hari_tetap,
        waktu_mulai: form.waktu_mulai,
        waktu_selesai: form.waktu_selesai,
        lokasi_default: form.lokasi_default.trim(),
    });
};
</script>
