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

        <!-- Dasar Pengukuran -->
        <div class="space-y-1.5">
            <label for="pengukuran_id" class="text-xs font-semibold text-slate-700 block ml-0.5">
                Dasar Pengukuran
            </label>

            <div
                v-if="loadingPengukuran"
                class="flex items-center gap-2 px-3.5 py-3 rounded-xl text-xs bg-slate-50 border border-slate-200 text-slate-500"
                role="status"
            >
                <i class="pi pi-spin pi-spinner text-xs" aria-hidden="true" />
                <span>Memuat riwayat pengukuran...</span>
            </div>

            <div
                v-else-if="riwayatPengukuran.length === 0"
                class="flex items-start gap-2.5 p-3.5 rounded-xl text-xs bg-amber-50 border border-amber-200 text-amber-800"
                role="alert"
            >
                <i class="pi pi-exclamation-triangle mt-0.5 shrink-0 text-amber-600" aria-hidden="true" />
                <span>Anak belum memiliki riwayat pengukuran. Catat pengukuran terlebih dahulu sebelum mengajukan rujukan.</span>
            </div>

            <template v-else>
                <div class="relative">
                    <i class="pi pi-calendar absolute left-3.5 top-1/2 -translate-y-1/2 text-xs text-slate-400 pointer-events-none" aria-hidden="true" />
                    <select
                        id="pengukuran_id"
                        v-model="form.pengukuran_id"
                        :disabled="loading"
                        class="w-full pl-9 pr-8 py-2.5 rounded-xl text-sm appearance-none bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none"
                        aria-required="true"
                        :aria-invalid="!!fieldErrors.pengukuran_id"
                        aria-describedby="pengukuran_id_error pengukuran_hint"
                    >
                        <option value="" disabled>Pilih tanggal pengukuran</option>
                        <option v-for="pengukuran in riwayatPengukuran" :key="pengukuran.id" :value="pengukuran.id">
                            {{ formatTanggal(pengukuran.tanggal_ukur) }}
                        </option>
                    </select>
                    <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
                </div>
                <p id="pengukuran_hint" class="text-[11px] text-slate-400 mt-2 mb-1 ml-0.5 leading-relaxed">
                    Pengukuran terbaru dipilih otomatis. Pilih tanggal lain bila rujukan didasarkan pada pemeriksaan sebelumnya.
                </p>
            </template>

            <p v-if="fieldErrors.pengukuran_id" id="pengukuran_id_error" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldErrors.pengukuran_id }}
            </p>

            <!-- Card Ringkasan Pengukuran Terpilih -->
            <Transition name="slide-down">
                <section
                    v-if="pengukuranTerpilih"
                    class="rounded-xl bg-slate-50 border border-slate-200/80 p-3.5 space-y-3 mt-2.5"
                >
                    <div class="flex items-center justify-between gap-2 flex-wrap">
                        <div>
                            <span class="text-[10px] uppercase tracking-wider font-semibold text-slate-400 block">
                                Rincian Hasil Ukur
                            </span>
                            <span class="text-xs font-bold text-slate-800">
                                {{ formatTanggal(pengukuranTerpilih.tanggal_ukur) }}
                            </span>
                        </div>
                        <span
                            class="text-[11px] font-semibold px-2.5 py-0.5 rounded-full capitalize"
                            :style="`background: ${warnaBg[pengukuranTerpilih.prioritas_pemantauan?.kategori] || '#f1f5f9'}; color: ${warnaHex[pengukuranTerpilih.prioritas_pemantauan?.kategori] || '#475569'}`"
                        >
                            Prioritas {{ pengukuranTerpilih.prioritas_pemantauan?.kategori ?? "—" }}
                        </span>
                    </div>

                    <!-- Metrik BB, TB, LK, LL -->
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs">
                        <div class="p-2.5 rounded-lg bg-white border border-slate-200/80 shadow-2xs">
                            <span class="text-[10px] text-slate-400 block">Berat Badan</span>
                            <strong class="text-xs font-bold text-slate-800">{{ formatUkuran(pengukuranTerpilih.berat_badan) }} kg</strong>
                        </div>
                        <div class="p-2.5 rounded-lg bg-white border border-slate-200/80 shadow-2xs">
                            <span class="text-[10px] text-slate-400 block">Tinggi Badan</span>
                            <strong class="text-xs font-bold text-slate-800">{{ formatUkuran(pengukuranTerpilih.tinggi_badan) }} cm</strong>
                        </div>
                        <div class="p-2.5 rounded-lg bg-white border border-slate-200/80 shadow-2xs">
                            <span class="text-[10px] text-slate-400 block">Lingkar Kepala</span>
                            <strong class="text-xs font-bold text-slate-800">
                                {{ pengukuranTerpilih.lingkar_kepala != null && pengukuranTerpilih.lingkar_kepala !== "" ? `${formatUkuran(pengukuranTerpilih.lingkar_kepala)} cm` : "—" }}
                            </strong>
                        </div>
                        <div class="p-2.5 rounded-lg bg-white border border-slate-200/80 shadow-2xs">
                            <span class="text-[10px] text-slate-400 block">Lingkar Lengan</span>
                            <strong class="text-xs font-bold text-slate-800">
                                {{ pengukuranTerpilih.lingkar_lengan != null && pengukuranTerpilih.lingkar_lengan !== "" ? `${formatUkuran(pengukuranTerpilih.lingkar_lengan)} cm` : "—" }}
                            </strong>
                        </div>
                    </div>

                    <!-- Rincian Status Antropometri -->
                    <div class="bg-white rounded-lg border border-slate-200/80 p-2.5 divide-y divide-slate-100">
                        <div
                            v-for="item in statusAntropometri"
                            :key="item.label"
                            class="flex items-center justify-between gap-3 py-1.5 first:pt-0 last:pb-0 text-xs"
                        >
                            <span class="text-slate-500 text-[11px]">{{ item.label }}</span>
                            <span
                                class="text-[11px] font-semibold capitalize text-right px-2 py-0.5 rounded-md"
                                :class="getStatusBadgeClass(item.value)"
                            >
                                {{ formatStatus(item.value) }}
                            </span>
                        </div>
                    </div>
                </section>
            </Transition>
        </div>

        <!-- Alasan dan Kondisi Anak -->
        <div class="space-y-1.5 pt-3.5">
            <div class="flex items-center justify-between gap-3">
                <label for="catatan_kader" class="text-xs font-semibold text-slate-700 block ml-0.5">
                    Alasan dan Kondisi Anak
                </label>
                <span class="text-[10px] text-slate-400">{{ form.catatan_kader.length }}/2000</span>
            </div>
            <textarea
                id="catatan_kader"
                v-model="form.catatan_kader"
                rows="4"
                placeholder="Jelaskan alasan rujukan, kondisi yang ditemukan, dan tindakan awal yang sudah dilakukan..."
                :disabled="loading"
                maxlength="2000"
                class="w-full px-3.5 py-2.5 rounded-xl text-sm bg-white border border-slate-200 focus:border-emerald-500 focus:ring-4 focus:ring-emerald-500/10 transition-all text-slate-800 outline-none resize-none"
                aria-required="true"
                :aria-invalid="!!fieldErrors.catatan_kader"
                aria-describedby="catatan_kader_error"
            />
            <p v-if="fieldErrors.catatan_kader" id="catatan_kader_error" class="text-xs text-red-600 mt-1 ml-0.5">
                {{ fieldErrors.catatan_kader }}
            </p>
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

const getStatusBadgeClass = (value) => {
    if (!value) return "bg-slate-100 text-slate-600";
    const v = String(value).toLowerCase();
    if (v.includes("sangat") || v.includes("buruk") || v.includes("obesitas")) {
        return "bg-rose-50 text-rose-700 border border-rose-100";
    }
    if (v.includes("kurang") || v.includes("pendek") || v.includes("risiko") || v.includes("lebih")) {
        return "bg-amber-50 text-amber-700 border border-amber-100";
    }
    if (v.includes("normal") || v.includes("baik")) {
        return "bg-emerald-50 text-emerald-700 border border-emerald-100";
    }
    return "bg-slate-100 text-slate-700";
};

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
