<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Input Pengukuran
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Catat hasil pengukuran berat dan tinggi badan anak
                </p>
            </div>
        </div>

        <!-- ─── Layout dua kolom: Form kiri, Hasil kanan ────────── -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
            <!-- ══ KOLOM KIRI: Form Pengukuran ══════════════════════ -->
            <div class="card space-y-5 p-6 rounded-2xl">
                <h2
                    class="text-base font-semibold m-0"
                    style="color: var(--color-text-heading)"
                >
                    <i
                        class="pi pi-pencil mr-2"
                        style="color: var(--color-green-700)"
                        aria-hidden="true"
                    />
                    Form Pengukuran
                </h2>

                <!-- Error API -->
                <Transition name="slide-down">
                    <div
                        v-if="pengukuranStore.error.create"
                        class="flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                        style="
                            background: #fef2f2;
                            border: 1px solid #fecaca;
                            color: #b91c1c;
                        "
                        role="alert"
                        aria-live="assertive"
                    >
                        <i
                            class="pi pi-exclamation-circle mt-0.5 flex-shrink-0"
                            aria-hidden="true"
                        />
                        <span>{{ pengukuranStore.error.create }}</span>
                    </div>
                </Transition>

                <form
                    novalidate
                    class="space-y-4"
                    @submit.prevent="handleSubmit"
                >
                    <!-- Pilih Anak -->
                    <div class="space-y-1.5">
                        <label for="anak_id" class="field-label"
                            >Pilih Anak</label
                        >
                        <div class="relative">
                            <i
                                class="pi pi-heart input-icon"
                                aria-hidden="true"
                            />
                            <select
                                id="anak_id"
                                v-model="form.anak_id"
                                :disabled="pengukuranStore.loading.create"
                                class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm appearance-none"
                                aria-required="true"
                            >
                                <option value="" disabled>
                                    Pilih nama anak
                                </option>
                                <option
                                    v-for="anak in kaderStore.anakList"
                                    :key="anak.id"
                                    :value="anak.id"
                                >
                                    {{ anak.nama }} — {{ anak.nama_orang_tua }}
                                </option>
                            </select>
                            <i
                                class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                                style="color: var(--color-text-muted)"
                                aria-hidden="true"
                            />
                        </div>
                        <!-- Info anak terpilih -->
                        <div
                            v-if="anakTerpilih"
                            class="flex items-center gap-2 px-3 py-2 rounded-lg text-xs"
                            style="
                                background: var(--color-green-50);
                                color: var(--color-green-700);
                            "
                        >
                            <i class="pi pi-info-circle" aria-hidden="true" />
                            <span>
                                {{
                                    anakTerpilih.jenis_kelamin === "L"
                                        ? "Laki-laki"
                                        : "Perempuan"
                                }}
                                • Usia
                                {{ hitungUsia(anakTerpilih.tanggal_lahir) }}
                            </span>
                        </div>
                    </div>

                    <!-- Tanggal Ukur -->
                    <div class="space-y-1.5">
                        <label for="tanggal_ukur" class="field-label"
                            >Tanggal Pengukuran</label
                        >
                        <div class="relative">
                            <i
                                class="pi pi-calendar input-icon"
                                aria-hidden="true"
                            />
                            <input
                                id="tanggal_ukur"
                                v-model="form.tanggal_ukur"
                                type="date"
                                :max="today"
                                :disabled="pengukuranStore.loading.create"
                                class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                                aria-required="true"
                            />
                        </div>
                    </div>

                    <!-- Berat & Tinggi Badan — 2 kolom -->
                    <div class="grid grid-cols-2 gap-3">
                        <div class="space-y-1.5">
                            <label for="berat_badan" class="field-label">
                                Berat Badan
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(kg)</span
                                >
                            </label>
                            <div class="relative">
                                <input
                                    id="berat_badan"
                                    v-model.number="form.berat_badan"
                                    type="number"
                                    placeholder="0.0"
                                    step="0.1"
                                    min="0.5"
                                    max="30"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                />
                            </div>
                            <p v-if="fieldError.berat_badan" class="error-hint">
                                {{ fieldError.berat_badan }}
                            </p>
                        </div>
                        <div class="space-y-1.5">
                            <label for="tinggi_badan" class="field-label">
                                Tinggi Badan
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(cm)</span
                                >
                            </label>
                            <div class="relative">
                                <input
                                    id="tinggi_badan"
                                    v-model.number="form.tinggi_badan"
                                    type="number"
                                    placeholder="0.0"
                                    step="0.1"
                                    min="10"
                                    max="120"
                                    :disabled="pengukuranStore.loading.create"
                                    class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                                    aria-required="true"
                                />
                            </div>
                            <p
                                v-if="fieldError.tinggi_badan"
                                class="error-hint"
                            >
                                {{ fieldError.tinggi_badan }}
                            </p>
                        </div>
                    </div>

                    <!-- Lingkar Kepala & Lengan — opsional -->
                    <div class="grid grid-cols-2 gap-3">
                        <div class="space-y-1.5">
                            <label for="lingkar_kepala" class="field-label">
                                Lingkar Kepala
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(cm, opsional)</span
                                >
                            </label>
                            <input
                                id="lingkar_kepala"
                                v-model.number="form.lingkar_kepala"
                                type="number"
                                placeholder="—"
                                step="0.1"
                                min="10"
                                max="60"
                                :disabled="pengukuranStore.loading.create"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                            />
                        </div>
                        <div class="space-y-1.5">
                            <label for="lingkar_lengan" class="field-label">
                                Lingkar Lengan
                                <span
                                    class="text-xs font-normal"
                                    style="color: var(--color-text-muted)"
                                    >(cm, opsional)</span
                                >
                            </label>
                            <input
                                id="lingkar_lengan"
                                v-model.number="form.lingkar_lengan"
                                type="number"
                                placeholder="—"
                                step="0.1"
                                min="5"
                                max="30"
                                :disabled="pengukuranStore.loading.create"
                                class="input-field w-full px-4 py-2.5 rounded-xl text-sm"
                            />
                        </div>
                    </div>

                    <!-- Tombol submit -->
                    <button
                        type="submit"
                        :disabled="pengukuranStore.loading.create || !isValid"
                        class="btn-primary w-full py-3 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed mt-2"
                    >
                        <i
                            v-if="pengukuranStore.loading.create"
                            class="pi pi-spin pi-spinner"
                            aria-hidden="true"
                        />
                        <i v-else class="pi pi-check" aria-hidden="true" />
                        <span>{{
                            pengukuranStore.loading.create
                                ? "Memproses..."
                                : "Simpan Pengukuran"
                        }}</span>
                    </button>
                </form>
            </div>

            <!-- ══ KOLOM KANAN: Hasil Pengukuran ════════════════════ -->
            <div class="space-y-4">
                <!-- State: belum ada hasil -->
                <div
                    v-if="!pengukuranStore.createResult"
                    class="card p-6 rounded-2xl flex flex-col items-center justify-center text-center gap-3 min-h-48"
                >
                    <i
                        class="pi pi-chart-line text-4xl"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                    <p
                        class="text-sm m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Hasil pengukuran akan ditampilkan di sini setelah form
                        disimpan
                    </p>
                </div>

                <!-- Hasil pengukuran -->
                <template v-else>
                    <PengukuranResultCard
                        :result="pengukuranStore.createResult"
                    />
                </template>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted } from "vue";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useKaderStore } from "@/stores/kaderStore";
import PengukuranResultCard from "@/components/cards/PengukuranResultCard.vue";

const pengukuranStore = usePengukuranStore();
const kaderStore = useKaderStore();

const today = new Date().toISOString().split("T")[0];

const form = reactive({
    anak_id: "",
    tanggal_ukur: today,
    berat_badan: null,
    tinggi_badan: null,
    lingkar_kepala: null,
    lingkar_lengan: null,
});

/* ── Info anak terpilih ──────────────────────────────────────────── */
const anakTerpilih = computed(
    () => kaderStore.anakList.find((a) => a.id === form.anak_id) || null,
);

/* ── Hitung usia ─────────────────────────────────────────────────── */
const hitungUsia = (tgl) => {
    const bulan = Math.floor(
        (new Date() - new Date(tgl)) / (1000 * 60 * 60 * 24 * 30.44),
    );
    if (bulan < 24) return `${bulan} bulan`;
    return `${Math.floor(bulan / 12)} thn ${bulan % 12} bln`;
};

/* ── Validasi ────────────────────────────────────────────────────── */
const fieldError = computed(() => {
    const e = {};
    if (
        form.berat_badan !== null &&
        (form.berat_badan <= 0 || form.berat_badan > 30)
    )
        e.berat_badan = "Berat badan harus antara 0–30 kg";
    if (
        form.tinggi_badan !== null &&
        (form.tinggi_badan <= 0 || form.tinggi_badan > 120)
    )
        e.tinggi_badan = "Tinggi badan harus antara 0–120 cm";
    return e;
});

const isValid = computed(
    () =>
        form.anak_id &&
        form.tanggal_ukur &&
        form.berat_badan > 0 &&
        form.tinggi_badan > 0 &&
        Object.keys(fieldError.value).length === 0,
);

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = async () => {
    if (!isValid.value || pengukuranStore.loading.create) return;
    pengukuranStore.resetCreateState();

    const payload = {
        anak_id: form.anak_id,
        tanggal_ukur: form.tanggal_ukur,
        berat_badan: form.berat_badan,
        tinggi_badan: form.tinggi_badan,
    };
    if (form.lingkar_kepala) payload.lingkar_kepala = form.lingkar_kepala;
    if (form.lingkar_lengan) payload.lingkar_lengan = form.lingkar_lengan;

    await pengukuranStore.createPengukuran(payload);
};

onMounted(() => {
    if (kaderStore.anakList.length === 0) kaderStore.fetchAllAnak();
});
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.field-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    margin-left: 0.25rem;
    color: var(--color-text-body);
}
.input-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.85rem;
    color: var(--color-text-muted);
    pointer-events: none;
}
.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
    font-family: "Poppins", sans-serif;
}
.input-field::placeholder {
    color: var(--color-text-muted);
    font-size: 0.82rem;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-field:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
.error-hint {
    font-size: 0.72rem;
    color: #dc2626;
    margin: 0 0 0 0.25rem;
}

.btn-primary {
    background: linear-gradient(
        135deg,
        var(--color-green-600),
        var(--color-green-800)
    );
    box-shadow: 0 2px 8px var(--color-shadow-green);
    transition:
        filter 0.15s,
        transform 0.15s;
}
.btn-primary:hover:not(:disabled) {
    filter: brightness(1.08);
}
.btn-primary:active:not(:disabled) {
    transform: scale(0.98);
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
