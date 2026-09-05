<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <div class="rounded-xl p-3 bg-emerald-50 border border-emerald-100">
            <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400 m-0">Rujukan Anak</p>
            <p class="text-sm font-bold text-slate-800 mt-1 mb-0">{{ rujukan.nama_anak }}</p>
            <div class="flex items-center gap-2 mt-3" aria-label="Perubahan status">
                <StatusBadge type="rujukan" :value="rujukan.status" />
                <i class="pi pi-arrow-right text-xs text-slate-400" aria-hidden="true" />
                <StatusBadge type="rujukan" :value="nextStatus" />
            </div>
        </div>

        <div
            class="flex items-start gap-2 px-3 py-2.5 rounded-xl text-xs leading-relaxed"
            :class="nextStatus === 'selesai' ? 'bg-amber-50 text-amber-800 border border-amber-200' : 'bg-blue-50 text-blue-800 border border-blue-200'"
        >
            <i :class="nextStatus === 'selesai' ? 'pi pi-exclamation-triangle' : 'pi pi-info-circle'" class="mt-0.5" aria-hidden="true" />
            <span v-if="nextStatus === 'selesai'">
                Menyelesaikan rujukan bersifat final. Pastikan hasil penanganan sudah dicatat dengan jelas.
            </span>
            <span v-else>
                Status akan berubah menjadi Ditangani dan orang tua akan menerima pembaruan.
            </span>
        </div>

        <Transition name="slide-down">
            <div v-if="error" class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm" role="alert" aria-live="assertive">
                <i class="pi pi-exclamation-circle mt-0.5" aria-hidden="true" />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <div class="space-y-1.5">
            <div class="flex items-center justify-between gap-3">
                <label for="catatan_puskesmas" class="field-label">
                    {{ nextStatus === "selesai" ? "Hasil Penanganan" : "Catatan Puskesmas" }}
                    <span v-if="nextStatus !== 'selesai'" class="text-xs font-normal text-slate-400">(opsional)</span>
                </label>
                <span class="text-[10px] text-slate-400">{{ form.catatan_puskesmas.length }}/2000</span>
            </div>
            <textarea
                id="catatan_puskesmas"
                v-model="form.catatan_puskesmas"
                rows="4"
                :placeholder="nextStatus === 'selesai' ? 'Tuliskan hasil pemeriksaan, tindakan, dan rencana tindak lanjut...' : 'Catatan awal penanganan jika ada...'"
                :disabled="loading"
                maxlength="2000"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
                :aria-required="nextStatus === 'selesai'"
                :aria-invalid="!!fieldError"
                aria-describedby="catatan_puskesmas_error"
            />
            <p v-if="fieldError" id="catatan_puskesmas_error" class="error-hint">{{ fieldError }}</p>
        </div>

        <div class="flex gap-3 pt-2">
            <button
                v-if="!loading"
                type="button"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold border border-slate-200 bg-white text-slate-700 cursor-pointer"
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
                <i v-else :class="nextStatus === 'selesai' ? 'pi pi-check-circle' : 'pi pi-play'" aria-hidden="true" />
                <span>{{ actionLabel }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { computed, reactive, ref } from "vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";

const props = defineProps({
    rujukan: { type: Object, required: true },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const attemptedSubmit = ref(false);
const form = reactive({ catatan_puskesmas: "" });
const NEXT_STATUS = { diajukan: "ditangani", ditangani: "selesai" };
const nextStatus = computed(() => NEXT_STATUS[props.rujukan.status] || "");
const fieldError = computed(() => {
    if (!attemptedSubmit.value || nextStatus.value !== "selesai") return "";
    return form.catatan_puskesmas.trim().length >= 3
        ? ""
        : "Hasil penanganan wajib diisi minimal 3 karakter";
});
const actionLabel = computed(() => {
    if (props.loading) return "Menyimpan...";
    return nextStatus.value === "selesai" ? "Selesaikan Rujukan" : "Mulai Tangani";
});

const handleSubmit = () => {
    if (props.loading || !nextStatus.value) return;
    attemptedSubmit.value = true;
    if (fieldError.value) return;
    const payload = { status: nextStatus.value };
    if (form.catatan_puskesmas.trim()) {
        payload.catatan_puskesmas = form.catatan_puskesmas.trim();
    }
    emit("submit", payload);
};
</script>
