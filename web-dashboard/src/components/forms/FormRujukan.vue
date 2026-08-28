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

        <!-- Dropdown Pengukuran -->
        <div class="space-y-1.5">
            <label for="pengukuran_id" class="field-label"
                >Berdasarkan Pengukuran</label
            >

            <!-- Loading pengukuran -->
            <div
                v-if="loadingPengukuran"
                class="flex items-center gap-2 px-4 py-3 rounded-xl text-sm"
                style="
                    background: var(--color-input-bg);
                    border: 1px solid var(--color-input-border);
                    color: var(--color-text-muted);
                "
            >
                <i class="pi pi-spin pi-spinner text-xs" aria-hidden="true" />
                <span>Memuat riwayat pengukuran...</span>
            </div>

            <!-- Tidak ada pengukuran -->
            <div
                v-else-if="riwayatPengukuran.length === 0"
                class="flex items-center gap-2 px-4 py-3 rounded-xl text-sm"
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
                <span
                    >Anak ini belum memiliki data pengukuran. Lakukan pengukuran
                    terlebih dahulu.</span
                >
            </div>

            <!-- Dropdown -->
            <div v-else class="relative">
                <i class="pi pi-calendar input-icon" aria-hidden="true" />
                <select
                    id="pengukuran_id"
                    v-model="form.pengukuran_id"
                    :disabled="loading"
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
                    aria-required="true"
                >
                    <option value="" disabled>Pilih hasil pengukuran</option>
                    <option
                        v-for="p in riwayatPengukuran"
                        :key="p.id"
                        :value="p.id"
                    >
                        {{ formatTanggal(p.tanggal_ukur) }} — BB:
                        {{ p.berat_badan }}kg, TB: {{ p.tinggi_badan }}cm
                        (prioritas {{ p.kategori_prioritas ?? "—" }})
                    </option>
                </select>
                <i
                    class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
            </div>

            <!-- Info pengukuran terpilih -->
            <Transition name="slide-down">
                <div
                    v-if="pengukuranTerpilih"
                    class="px-3 py-2.5 rounded-xl space-y-2"
                    style="
                        background: var(--color-green-50);
                        border: 1px solid var(--color-input-border);
                    "
                >
                    <div class="flex items-center gap-1.5 flex-wrap">
                        <span
                            class="text-xs"
                            style="color: var(--color-text-muted)"
                            >Prioritas pemantauan:</span
                        >
                        <span
                            class="text-xs font-semibold capitalize px-2 py-0.5 rounded-full"
                            :style="`background: ${warnaBg[pengukuranTerpilih.kategori_prioritas]}; color: ${warnaHex[pengukuranTerpilih.kategori_prioritas]}`"
                        >
                            {{ pengukuranTerpilih.kategori_prioritas ?? "—" }}
                        </span>
                        <span
                            class="text-xs"
                            style="color: var(--color-text-muted)"
                            >Skor SAW:</span
                        >
                        <span
                            class="text-xs font-mono font-semibold"
                            style="color: var(--color-text-heading)"
                        >
                            {{
                                formatSkor(pengukuranTerpilih.skor_saw)
                            }}
                        </span>
                    </div>
                    <div class="grid grid-cols-2 gap-x-3 gap-y-1 text-xs">
                        <span v-for="item in statusAntropometri" :key="item.label">
                            <span style="color: var(--color-text-muted)">{{ item.label }}:</span>
                            <strong class="ml-1" style="color: var(--color-text-heading)">
                                {{ formatStatus(item.value) }}
                            </strong>
                        </span>
                    </div>
                </div>
            </Transition>
        </div>

        <!-- Catatan Kader -->
        <div class="space-y-1.5">
            <label for="catatan_kader" class="field-label">Catatan Kader</label>
            <textarea
                id="catatan_kader"
                v-model="form.catatan_kader"
                rows="4"
                placeholder="Jelaskan alasan rujukan dan kondisi anak saat ini..."
                :disabled="loading"
                maxlength="2000"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
                aria-required="true"
            />
            <p
                v-if="form.catatan_kader && form.catatan_kader.trim().length < 3"
                class="error-hint"
            >
                Catatan minimal 3 karakter
            </p>
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
                <span>{{ loading ? "Mengajukan..." : "Ajukan Rujukan" }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { reactive, computed } from "vue";

const props = defineProps({
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    anakId: { type: String, required: true },
    riwayatPengukuran: { type: Array, default: () => [] },
    loadingPengukuran: { type: Boolean, default: false },
});
const emit = defineEmits(["submit", "cancel"]);

const form = reactive({
    pengukuran_id: "",
    catatan_kader: "",
});

/* ── Warna prioritas ─────────────────────────────────────────────── */
const warnaHex = { rendah: "#15803d", sedang: "#d97706", tinggi: "#dc2626" };
const warnaBg = { rendah: "#dcfce7", sedang: "#fef3c7", tinggi: "#fee2e2" };

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

/* ── Info pengukuran terpilih ────────────────────────────────────── */
const pengukuranTerpilih = computed(
    () =>
        props.riwayatPengukuran.find((p) => p.id === form.pengukuran_id) ||
        null,
);

const statusAntropometri = computed(() => {
    const item = pengukuranTerpilih.value;
    if (!item) return [];
    return [
        { label: "BB/U", value: item.status_bbu },
        { label: "TB/U", value: item.status_tbu },
        { label: "BB/TB", value: item.status_bbtb },
        { label: "IMT/U", value: item.status_imtu },
    ];
});

const formatStatus = (value) => value?.replaceAll("_", " ") ?? "—";
const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);

/* ── Validasi ────────────────────────────────────────────────────── */
const isValid = computed(
    () => form.pengukuran_id && form.catatan_kader.trim().length >= 3,
);

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    if (!isValid.value || props.loading) return;
    emit("submit", {
        anak_id: props.anakId,
        pengukuran_id: form.pengukuran_id,
        catatan_kader: form.catatan_kader.trim(),
    });
};
</script>
