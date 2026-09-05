<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <Transition name="slide-down">
            <div v-if="error" class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm" role="alert" aria-live="assertive">
                <i class="pi pi-exclamation-circle mt-0.5" aria-hidden="true" />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <div class="space-y-1.5">
            <label for="pengukuran_id" class="field-label">Dasar Pengukuran</label>

            <div v-if="loadingPengukuran" class="flex items-center gap-2 px-4 py-3 rounded-xl text-sm bg-slate-50 border border-slate-200 text-slate-500" role="status">
                <i class="pi pi-spin pi-spinner text-xs" aria-hidden="true" />
                <span>Memuat riwayat pengukuran...</span>
            </div>

            <div v-else-if="riwayatPengukuran.length === 0" class="flex items-start gap-2 px-4 py-3 rounded-xl text-sm bg-amber-50 border border-amber-200 text-amber-800" role="alert">
                <i class="pi pi-exclamation-triangle mt-0.5" aria-hidden="true" />
                <span>Anak belum memiliki pengukuran. Catat pengukuran terlebih dahulu sebelum mengajukan rujukan.</span>
            </div>

            <template v-else>
                <div class="relative">
                    <i class="pi pi-calendar input-icon" aria-hidden="true" />
                    <select
                        id="pengukuran_id"
                        v-model="form.pengukuran_id"
                        :disabled="loading"
                        class="input-field w-full pl-9 pr-8 py-2.5 rounded-xl text-sm appearance-none"
                        aria-required="true"
                        :aria-invalid="!!fieldErrors.pengukuran_id"
                        aria-describedby="pengukuran_id_error pengukuran_hint"
                    >
                        <option value="" disabled>Pilih hasil pengukuran</option>
                        <option v-for="pengukuran in riwayatPengukuran" :key="pengukuran.id" :value="pengukuran.id">
                            {{ formatTanggal(pengukuran.tanggal_ukur) }} — prioritas {{ pengukuran.prioritas_pemantauan?.kategori ?? "—" }}
                        </option>
                    </select>
                    <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
                </div>
                <p id="pengukuran_hint" class="text-[11px] text-slate-400 m-0">
                    Pengukuran terbaru dipilih otomatis. Pilih tanggal lain bila rujukan didasarkan pada pemeriksaan sebelumnya.
                </p>
            </template>

            <p v-if="fieldErrors.pengukuran_id" id="pengukuran_id_error" class="error-hint">
                {{ fieldErrors.pengukuran_id }}
            </p>

            <Transition name="slide-down">
                <section v-if="pengukuranTerpilih" class="rounded-xl bg-emerald-50 border border-emerald-100 p-3 space-y-3">
                    <div class="flex items-start justify-between gap-3 flex-wrap">
                        <div>
                            <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400 m-0">Pengukuran Terpilih</p>
                            <p class="text-xs font-bold text-slate-700 mt-1 mb-0">{{ formatTanggal(pengukuranTerpilih.tanggal_ukur) }}</p>
                        </div>
                        <span class="text-xs font-semibold capitalize px-2 py-1 rounded-full" :style="`background: ${warnaBg[pengukuranTerpilih.prioritas_pemantauan?.kategori]}; color: ${warnaHex[pengukuranTerpilih.prioritas_pemantauan?.kategori]}`">
                            Prioritas {{ pengukuranTerpilih.prioritas_pemantauan?.kategori ?? "—" }}
                        </span>
                    </div>
                    <div class="grid grid-cols-2 gap-2 text-xs">
                        <div class="metric"><span>Berat Badan</span><strong>{{ formatUkuran(pengukuranTerpilih.berat_badan) }} kg</strong></div>
                        <div class="metric"><span>Tinggi Badan</span><strong>{{ formatUkuran(pengukuranTerpilih.tinggi_badan) }} cm</strong></div>
                    </div>
                    <div class="divide-y divide-emerald-100">
                        <div v-for="item in statusAntropometri" :key="item.label" class="flex items-center justify-between gap-3 py-1.5 text-xs">
                            <span class="text-slate-500">{{ item.label }}</span>
                            <strong class="text-slate-700 capitalize text-right">{{ formatStatus(item.value) }}</strong>
                        </div>
                    </div>
                </section>
            </Transition>
        </div>

        <div class="space-y-1.5">
            <div class="flex items-center justify-between gap-3">
                <label for="catatan_kader" class="field-label">Alasan dan Kondisi Anak</label>
                <span class="text-[10px] text-slate-400">{{ form.catatan_kader.length }}/2000</span>
            </div>
            <textarea
                id="catatan_kader"
                v-model="form.catatan_kader"
                rows="5"
                placeholder="Jelaskan alasan rujukan, kondisi yang ditemukan, dan tindakan awal yang sudah dilakukan..."
                :disabled="loading"
                maxlength="2000"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
                aria-required="true"
                :aria-invalid="!!fieldErrors.catatan_kader"
                aria-describedby="catatan_kader_error"
            />
            <p v-if="fieldErrors.catatan_kader" id="catatan_kader_error" class="error-hint">
                {{ fieldErrors.catatan_kader }}
            </p>
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
                <i v-else class="pi pi-arrow-right" aria-hidden="true" />
                <span>{{ loading ? "Mengajukan..." : "Tinjau Rujukan" }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { computed, reactive, ref, watch } from "vue";
import { formatTanggal, formatUkuran } from "@/utils/format.js";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    anakId: { type: String, required: true },
    riwayatPengukuran: { type: Array, default: () => [] },
    loadingPengukuran: { type: Boolean, default: false },
});
const emit = defineEmits(["submit", "cancel"]);

const attemptedSubmit = ref(false);
const form = reactive({ pengukuran_id: "", catatan_kader: "" });
const warnaHex = { rendah: "#15803d", sedang: "#b45309", tinggi: "#dc2626" };
const warnaBg = { rendah: "#dcfce7", sedang: "#fef3c7", tinggi: "#fee2e2" };

const pengukuranTerpilih = computed(
    () =>
        props.riwayatPengukuran.find(
            (item) => String(item.id) === String(form.pengukuran_id),
        ) || null,
);

const statusAntropometri = computed(() => {
    const item = pengukuranTerpilih.value;
    if (!item) return [];
    return [
        { label: "Berat Badan menurut Umur (BB/U)", value: item.status_bbu },
        { label: "Tinggi Badan menurut Umur (TB/U)", value: item.status_tbu },
        { label: "Berat Badan menurut Tinggi Badan (BB/TB)", value: item.status_bbtb },
        { label: "Indeks Massa Tubuh menurut Umur (IMT/U)", value: item.status_imtu },
    ];
});

const fieldErrors = computed(() => {
    if (!attemptedSubmit.value) return {};
    const errors = {};
    if (!form.pengukuran_id) errors.pengukuran_id = "Dasar pengukuran wajib dipilih";
    const noteLength = form.catatan_kader.trim().length;
    if (!noteLength) {
        errors.catatan_kader = "Alasan dan kondisi anak wajib dijelaskan";
    } else if (noteLength < 3) {
        errors.catatan_kader = "Catatan minimal 3 karakter";
    }
    return errors;
});

const formatStatus = (value) => value?.replaceAll("_", " ") ?? "—";

const handleSubmit = () => {
    if (props.loading) return;
    attemptedSubmit.value = true;
    if (Object.keys(fieldErrors.value).length > 0) return;
    emit("submit", {
        anak_id: props.anakId,
        pengukuran_id: form.pengukuran_id,
        catatan_kader: form.catatan_kader.trim(),
    });
};

watch(
    () => props.riwayatPengukuran,
    (list) => {
        if (
            list.length > 0 &&
            !list.some((item) => String(item.id) === String(form.pengukuran_id))
        ) {
            form.pengukuran_id = list[0].id;
        }
    },
    { immediate: true },
);
</script>

<style scoped>
.metric {
    display: flex;
    flex-direction: column;
    gap: 0.2rem;
    padding: 0.6rem;
    border-radius: 0.65rem;
    background: rgba(255, 255, 255, 0.75);
}
.metric span { color: #64748b; font-size: 0.65rem; }
.metric strong { color: #334155; font-size: 0.75rem; }
</style>
