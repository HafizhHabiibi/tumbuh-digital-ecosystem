<template>
    <form class="space-y-4 pt-3" novalidate @submit.prevent="handleSubmit">
        <!-- ─── Ringkasan Pasien & Transisi Status ────────────────── -->
        <div class="rounded-xl p-3.5 bg-slate-50 border border-slate-200/80 space-y-2.5">
            <div class="flex items-center justify-between gap-2">
                <span class="text-[10px] uppercase tracking-wider font-semibold text-slate-400">
                    Pasien Rujukan
                </span>
                <span v-if="rujukan.nama_orang_tua" class="text-xs text-slate-600 font-medium">
                    Ortu: <strong class="text-slate-700">{{ rujukan.nama_orang_tua }}</strong>
                </span>
            </div>
            <p class="text-sm font-bold text-slate-800 m-0">
                {{ rujukan.nama_anak }}
            </p>
            <div class="flex items-center gap-2 pt-2 border-t border-slate-200/60" aria-label="Perubahan status">
                <span class="text-[11px] text-slate-500 font-medium">Status:</span>
                <StatusBadge type="rujukan" :value="rujukan.status" />
                <i class="pi pi-arrow-right text-xs text-slate-400" aria-hidden="true" />
                <StatusBadge type="rujukan" :value="nextStatus" />
            </div>
        </div>

        <!-- ─── Callout Peringatan / Petunjuk Klinis ──────────────── -->
        <div
            class="flex items-start gap-2.5 px-3.5 py-2.5 rounded-xl text-xs leading-relaxed"
            :class="nextStatus === 'selesai' ? 'bg-amber-50 text-amber-800 border border-amber-200/80' : 'bg-blue-50 text-blue-800 border border-blue-200/80'"
        >
            <i :class="nextStatus === 'selesai' ? 'pi pi-exclamation-triangle' : 'pi pi-info-circle'" class="mt-0.5 shrink-0" aria-hidden="true" />
            <span v-if="nextStatus === 'selesai'">
                Menyelesaikan rujukan bersifat final. Pastikan hasil penanganan medis dan rekomendasi tindak lanjut sudah dicatat dengan lengkap.
            </span>
            <span v-else>
                Status rujukan akan berubah menjadi <strong>Ditangani</strong> dan Posyandu/orang tua dapat memantau proses pemeriksaan.
            </span>
        </div>

        <!-- ─── Alert Error ───────────────────────────────────────── -->
        <Transition name="slide-down">
            <div v-if="error" class="error-alert flex items-start gap-2 px-3.5 py-2.5 rounded-xl text-xs bg-red-50 border border-red-200 text-red-700" role="alert" aria-live="assertive">
                <i class="pi pi-exclamation-circle mt-0.5 shrink-0" aria-hidden="true" />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- ─── Form Textarea Catatan / Hasil Penanganan ─────────── -->
        <div class="space-y-1.5">
            <div class="flex items-center justify-between gap-3">
                <label for="catatan_puskesmas" class="text-xs font-semibold text-slate-700">
                    {{ nextStatus === "selesai" ? "Hasil Penanganan Medis" : "Catatan Awal Puskesmas" }}
                    <span v-if="nextStatus !== 'selesai'" class="text-xs font-normal text-slate-400">(opsional)</span>
                </label>
                <span class="text-[10px] text-slate-400 font-mono">{{ form.catatan_puskesmas.length }}/2000</span>
            </div>
            <textarea
                id="catatan_puskesmas"
                v-model="form.catatan_puskesmas"
                rows="4"
                :placeholder="nextStatus === 'selesai' ? 'Tuliskan hasil pemeriksaan, diagnosa, tindakan, obat/PMT, dan rencana tindak lanjut...' : 'Tuliskan catatan awal persiapan penanganan jika ada...'"
                :disabled="loading"
                maxlength="2000"
                class="w-full px-3.5 py-2.5 rounded-xl text-xs bg-white border border-slate-200/90 text-slate-800 placeholder-slate-400 focus:outline-none focus:border-emerald-600 focus:ring-2 focus:ring-emerald-500/20 transition-all resize-none"
                :aria-required="nextStatus === 'selesai'"
                :aria-invalid="!!fieldError"
                aria-describedby="catatan_puskesmas_error"
            />
            <p v-if="fieldError" id="catatan_puskesmas_error" class="text-xs text-red-600 font-medium m-0">{{ fieldError }}</p>
        </div>

        <!-- ─── Tombol Aksi ──────────────────────────────────────── -->
        <div class="flex gap-2.5 pt-2">
            <button
                v-if="!loading"
                type="button"
                class="flex-1 py-2.5 rounded-xl text-xs font-semibold border border-slate-200/80 bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer"
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                class="flex-1 py-2.5 rounded-xl text-xs font-semibold text-white flex items-center justify-center gap-2 cursor-pointer transition-all shadow-2xs"
                :class="nextStatus === 'selesai' ? 'bg-emerald-600 hover:bg-emerald-700' : 'bg-blue-600 hover:bg-blue-700'"
                :aria-busy="loading"
            >
                <i v-if="loading" class="pi pi-spin pi-spinner text-xs" aria-hidden="true" />
                <i v-else :class="nextStatus === 'selesai' ? 'pi pi-check-circle text-xs' : 'pi pi-play text-xs'" aria-hidden="true" />
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

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.2s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-6px);
}
</style>
