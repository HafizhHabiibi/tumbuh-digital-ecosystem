<template>
    <div class="p-4 sm:p-6 max-w-6xl mx-auto space-y-6">
        <PageHeader title="Pemberian">
            <template #actions>
                <button
                    type="button"
                    class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white cursor-pointer"
                    @click="openForm"
                >
                    <i class="pi pi-plus" aria-hidden="true" />
                    Catat Pemberian
                </button>
            </template>
        </PageHeader>

        <section class="card p-4 rounded-2xl space-y-3" aria-labelledby="pilih-anak-title">
            <div class="flex items-center gap-3 flex-wrap">
                <label
                    id="pilih-anak-title"
                    for="pilih_anak"
                    class="text-sm font-semibold text-slate-700 flex-shrink-0"
                >
                    <i class="pi pi-heart mr-1.5 text-emerald-700" aria-hidden="true" />
                    Pilih Anak
                </label>
                <div class="relative flex-1 min-w-48">
                    <select
                        id="pilih_anak"
                        ref="anakSelect"
                        v-model="anakTerpilihId"
                        :disabled="kaderStore.loading.anakOptions"
                        class="input-field w-full px-4 py-2.5 rounded-xl text-sm appearance-none"
                        :aria-invalid="!!selectionMessage"
                        aria-describedby="pilih_anak_message"
                        @change="onAnakChange"
                    >
                        <option value="">
                            {{ kaderStore.loading.anakOptions ? "Memuat data anak..." : "Pilih nama anak" }}
                        </option>
                        <option v-for="anak in kaderStore.anakOptions" :key="anak.id" :value="anak.id">
                            {{ anak.nama }} — {{ anak.nama_orang_tua }}
                        </option>
                    </select>
                    <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
                </div>
            </div>

            <div
                v-if="selectionMessage"
                id="pilih_anak_message"
                class="flex items-center gap-2 text-xs text-amber-800"
                role="alert"
            >
                <i class="pi pi-info-circle" aria-hidden="true" />
                <span>{{ selectionMessage }}</span>
            </div>

            <div
                v-if="kaderStore.error.anakOptions"
                class="flex items-center justify-between gap-3 text-xs text-red-700"
                role="alert"
            >
                <span>{{ kaderStore.error.anakOptions }}</span>
                <button type="button" class="font-semibold underline cursor-pointer" @click="loadAnakOptions">
                    Coba lagi
                </button>
            </div>

            <div
                v-if="selectedAnak"
                class="grid grid-cols-1 sm:grid-cols-3 gap-3 p-3 rounded-xl bg-emerald-50 border border-emerald-100"
            >
                <div>
                    <p class="context-label">Nama Anak</p>
                    <p class="context-value">{{ selectedAnak.nama }}</p>
                </div>
                <div>
                    <p class="context-label">Orang Tua</p>
                    <p class="context-value">{{ selectedAnak.nama_orang_tua || "—" }}</p>
                </div>
                <div>
                    <p class="context-label">Usia Sekarang</p>
                    <p class="context-value">{{ hitungUsia(selectedAnak.tanggal_lahir) }}</p>
                </div>
            </div>
        </section>

        <Transition name="slide-down">
            <div
                v-if="pemberianStore.createResult"
                class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900"
                role="status"
            >
                <div class="flex items-start gap-3">
                    <i class="pi pi-check-circle mt-0.5 text-emerald-600" aria-hidden="true" />
                    <div>
                        <p class="text-sm font-bold m-0">Pemberian berhasil dicatat</p>
                        <p class="text-xs text-emerald-700 mt-1 mb-0">
                            {{ LABEL_JENIS[pemberianStore.createResult.jenis] }} pada
                            {{ formatTanggal(pemberianStore.createResult.tanggal_pemberian) }}.
                        </p>
                    </div>
                </div>
                <button
                    type="button"
                    class="p-1 text-emerald-700 cursor-pointer"
                    aria-label="Tutup pemberitahuan"
                    @click="pemberianStore.resetCreateState()"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <template v-if="anakTerpilihId">
            <Transition name="slide-down">
                <div
                    v-if="pemberianStore.error.riwayat"
                    class="flex items-center justify-between gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700"
                    role="alert"
                >
                    <div class="flex items-center gap-2">
                        <i class="pi pi-exclamation-circle" aria-hidden="true" />
                        <span>{{ pemberianStore.error.riwayat }}</span>
                    </div>
                    <button type="button" class="font-semibold underline cursor-pointer" @click="reloadRiwayat">
                        Coba lagi
                    </button>
                </div>
            </Transition>

            <section class="grid grid-cols-1 sm:grid-cols-3 gap-3" aria-label="Ringkasan pemberian">
                <div class="summary-card">
                    <p class="summary-label">Total Catatan</p>
                    <p class="summary-value">{{ pemberianStore.riwayat.list.length }}</p>
                </div>
                <div class="summary-card">
                    <p class="summary-label">Jenis Tercatat</p>
                    <p class="summary-value">{{ jumlahJenisTercatat }} <span class="text-sm font-medium">jenis</span></p>
                </div>
                <div class="summary-card">
                    <p class="summary-label">Pemberian Terakhir</p>
                    <p class="text-sm font-bold text-slate-800 mt-1 mb-0">
                        {{ pemberianTerakhir ? formatTanggal(pemberianTerakhir.tanggal_pemberian) : "Belum ada" }}
                    </p>
                </div>
            </section>

            <section class="space-y-3" aria-labelledby="riwayat-pemberian-title">
                <div class="flex items-end justify-between gap-3 flex-wrap">
                    <div>
                        <h2 id="riwayat-pemberian-title" class="text-base font-bold text-slate-800 m-0">
                            Riwayat Pemberian
                        </h2>
                        <p class="text-xs text-slate-500 mt-1 mb-0">Tampilkan catatan berdasarkan jenis pemberian.</p>
                    </div>
                    <div class="filter-scroll" role="group" aria-label="Filter jenis pemberian">
                        <button
                            type="button"
                            class="filter-btn"
                            :class="{ 'filter-btn--active': filterAktif === 'semua' }"
                            :aria-pressed="filterAktif === 'semua'"
                            @click="setFilter('semua')"
                        >
                            Semua
                        </button>
                        <button
                            v-for="jenis in JENIS_VALID"
                            :key="jenis"
                            type="button"
                            class="filter-btn"
                            :class="{ 'filter-btn--active': filterAktif === jenis }"
                            :aria-pressed="filterAktif === jenis"
                            @click="setFilter(jenis)"
                        >
                            {{ LABEL_JENIS[jenis] }}
                        </button>
                    </div>
                </div>

                <div class="card rounded-2xl overflow-hidden">
                    <div v-if="pemberianStore.loading.riwayat" class="p-4 space-y-3">
                        <div v-for="i in 4" :key="i" class="skeleton h-14 rounded-xl" />
                    </div>

                    <div
                        v-else-if="riwayatTampil.length === 0"
                        class="flex flex-col items-center justify-center py-16 gap-3 text-center px-4"
                    >
                        <i class="pi pi-inbox text-4xl text-slate-300" aria-hidden="true" />
                        <p class="text-sm text-slate-500 m-0">
                            Belum ada {{ filterAktif === "semua" ? "catatan pemberian" : LABEL_JENIS[filterAktif] }}.
                        </p>
                        <button
                            type="button"
                            class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white cursor-pointer"
                            @click="openForm"
                        >
                            Catat Sekarang
                        </button>
                    </div>

                    <template v-else>
                        <p class="sm:hidden text-[11px] text-slate-400 px-4 pt-3 mb-0">
                            Geser tabel ke samping untuk melihat seluruh informasi.
                        </p>
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[880px] text-sm" aria-label="Riwayat pemberian anak">
                                <thead>
                                    <tr class="bg-emerald-50 border-b border-slate-200">
                                        <th class="th-cell">Tanggal Pemberian</th>
                                        <th class="th-cell">Jenis Pemberian</th>
                                        <th class="th-cell">Dosis atau Jumlah</th>
                                        <th class="th-cell">Dicatat Oleh</th>
                                        <th class="th-cell">Keterangan</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr
                                        v-for="(item, index) in riwayatTampil"
                                        :key="item.id"
                                        class="table-row"
                                        :class="{ 'bg-slate-50/70': index % 2 !== 0 }"
                                    >
                                        <td class="px-4 py-3 whitespace-nowrap text-slate-700">
                                            {{ formatTanggal(item.tanggal_pemberian) }}
                                        </td>
                                        <td class="px-4 py-3 whitespace-nowrap">
                                            <span
                                                class="text-xs px-2 py-1 rounded-full font-semibold"
                                                :style="`background: ${warnaBgJenis[item.jenis]}; color: ${warnaJenis[item.jenis]}`"
                                            >
                                                {{ LABEL_JENIS[item.jenis] ?? item.jenis }}
                                            </span>
                                        </td>
                                        <td class="px-4 py-3 text-slate-700">{{ item.dosis || "—" }}</td>
                                        <td class="px-4 py-3 text-slate-600">{{ item.dicatat_oleh || "—" }}</td>
                                        <td class="px-4 py-3 text-slate-600 min-w-64 whitespace-normal">
                                            {{ item.keterangan || "—" }}
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </template>
                </div>
            </section>
        </template>

        <div v-else class="card p-10 sm:p-12 rounded-2xl flex flex-col items-center justify-center gap-3 text-center">
            <i class="pi pi-arrow-up text-3xl text-slate-300" aria-hidden="true" />
            <div>
                <p class="text-sm font-semibold text-slate-700 m-0">Pilih anak terlebih dahulu</p>
                <p class="text-xs text-slate-500 mt-1 mb-0">Riwayat dan form pencatatan akan mengikuti anak yang dipilih.</p>
            </div>
        </div>

        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!pemberianStore.loading.create"
            header="Catat Pemberian"
            :style="{ width: '500px', maxWidth: '95vw' }"
            :pt="{ header: { style: 'border-bottom: 1px solid var(--color-input-border)' } }"
        >
            <div class="pt-3">
                <div v-if="selectedAnak" class="px-3 py-2.5 rounded-xl bg-emerald-50 border border-emerald-100">
                    <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400 m-0">Pencatatan untuk</p>
                    <p class="text-sm font-bold text-slate-800 mt-1 mb-0">{{ selectedAnak.nama }}</p>
                </div>
                <FormPemberian
                    :loading="pemberianStore.loading.create"
                    :error="pemberianStore.error.create"
                    :anak-id="anakTerpilihId"
                    :anak="selectedAnak"
                    :anak-list="kaderStore.anakOptions"
                    @submit="reviewSubmission"
                    @cancel="closeForm"
                />
            </div>
        </Dialog>

        <Dialog
            v-model:visible="showConfirmation"
            modal
            :closable="!pemberianStore.loading.create"
            header="Konfirmasi Pemberian"
            :style="{ width: '480px', maxWidth: '95vw' }"
        >
            <div v-if="pendingPayload" class="space-y-4">
                <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed">
                    Pastikan anak, jenis, dan tanggal sudah benar. Data ini akan masuk ke riwayat pemberian.
                </div>
                <dl class="review-grid">
                    <div class="review-item sm:col-span-2">
                        <dt>Anak</dt>
                        <dd>{{ selectedAnak?.nama || "—" }}</dd>
                    </div>
                    <div class="review-item">
                        <dt>Jenis Pemberian</dt>
                        <dd>{{ LABEL_JENIS[pendingPayload.jenis] }}</dd>
                    </div>
                    <div class="review-item">
                        <dt>Tanggal Pemberian</dt>
                        <dd>{{ formatTanggal(pendingPayload.tanggal_pemberian) }}</dd>
                    </div>
                    <div class="review-item">
                        <dt>Dosis atau Jumlah</dt>
                        <dd>{{ pendingPayload.dosis || "Tidak diisi" }}</dd>
                    </div>
                    <div class="review-item">
                        <dt>Keterangan</dt>
                        <dd>{{ pendingPayload.keterangan || "Tidak diisi" }}</dd>
                    </div>
                </dl>
                <div class="flex justify-end gap-2">
                    <button
                        v-if="!pemberianStore.loading.create"
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 cursor-pointer"
                        @click="showConfirmation = false"
                    >
                        Periksa Kembali
                    </button>
                    <button
                        type="button"
                        class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white inline-flex items-center gap-2 cursor-pointer"
                        :aria-busy="pemberianStore.loading.create"
                        @click="confirmSubmission"
                    >
                        <i v-if="pemberianStore.loading.create" class="pi pi-spin pi-spinner" aria-hidden="true" />
                        <i v-else class="pi pi-check" aria-hidden="true" />
                        {{ pemberianStore.loading.create ? "Menyimpan..." : "Simpan Pemberian" }}
                    </button>
                </div>
            </div>
        </Dialog>
    </div>
</template>

<script setup>
import { computed, nextTick, onMounted, ref } from "vue";
import { useRoute } from "vue-router";
import { Dialog } from "primevue";
import PageHeader from "@/components/ui/PageHeader.vue";
import FormPemberian from "@/components/forms/FormPemberian.vue";
import {
    usePemberianStore,
    JENIS_VALID,
    LABEL_JENIS,
    WARNA_JENIS as warnaJenis,
    WARNA_BG_JENIS as warnaBgJenis,
} from "@/stores/pemberianStore";
import { useKaderStore } from "@/stores/kaderStore";
import { formatTanggal, hitungUsia } from "@/utils/format.js";

const route = useRoute();
const pemberianStore = usePemberianStore();
const kaderStore = useKaderStore();

const anakTerpilihId = ref("");
const filterAktif = ref("semua");
const showForm = ref(false);
const showConfirmation = ref(false);
const pendingPayload = ref(null);
const selectionMessage = ref("");
const anakSelect = ref(null);

const selectedAnak = computed(() => {
    if (
        pemberianStore.riwayat.anak &&
        String(pemberianStore.riwayat.anak.id) === String(anakTerpilihId.value)
    ) {
        return pemberianStore.riwayat.anak;
    }
    return (
        kaderStore.anakOptions.find(
            (anak) => String(anak.id) === String(anakTerpilihId.value),
        ) || null
    );
});

const riwayatTampil = computed(() => {
    if (filterAktif.value === "semua") return pemberianStore.riwayat.list;
    return pemberianStore.riwayat.list.filter((item) => item.jenis === filterAktif.value);
});

const jumlahJenisTercatat = computed(
    () => new Set(pemberianStore.riwayat.list.map((item) => item.jenis)).size,
);
const pemberianTerakhir = computed(() => pemberianStore.riwayat.list[0] || null);

const loadAnakOptions = () => kaderStore.fetchAnakOptions();
const reloadRiwayat = () => {
    if (anakTerpilihId.value) pemberianStore.fetchRiwayat(anakTerpilihId.value);
};

const onAnakChange = () => {
    selectionMessage.value = "";
    filterAktif.value = "semua";
    pemberianStore.resetCreateState();
    if (anakTerpilihId.value) reloadRiwayat();
    else pemberianStore.resetRiwayat();
};

const setFilter = (jenis) => {
    filterAktif.value = jenis;
};

const openForm = async () => {
    if (!anakTerpilihId.value) {
        selectionMessage.value = "Pilih anak sebelum mencatat pemberian.";
        await nextTick();
        anakSelect.value?.focus();
        return;
    }
    selectionMessage.value = "";
    pemberianStore.resetCreateState();
    showForm.value = true;
};

const closeForm = () => {
    showForm.value = false;
    showConfirmation.value = false;
    pendingPayload.value = null;
    pemberianStore.error.create = null;
};

const reviewSubmission = (payload) => {
    if (pemberianStore.loading.create) return;
    pendingPayload.value = payload;
    showConfirmation.value = true;
};

const confirmSubmission = async () => {
    if (!pendingPayload.value || pemberianStore.loading.create) return;
    const ok = await pemberianStore.createRiwayat(pendingPayload.value);
    if (ok) {
        showConfirmation.value = false;
        showForm.value = false;
        pendingPayload.value = null;
        filterAktif.value = "semua";
    } else {
        showConfirmation.value = false;
    }
};

onMounted(async () => {
    pemberianStore.resetCreateState();
    if (kaderStore.anakOptions.length === 0) await loadAnakOptions();
    const queryId = Array.isArray(route.query.anakId)
        ? route.query.anakId[0]
        : route.query.anakId;
    if (queryId) {
        anakTerpilihId.value = queryId;
        onAnakChange();
    }
});
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    font-family: "Poppins", sans-serif;
    transition: border-color 0.2s, box-shadow 0.2s;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.context-label,
.summary-label {
    margin: 0;
    color: #64748b;
    font-size: 0.68rem;
    font-weight: 600;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}
.context-value {
    margin: 0.25rem 0 0;
    color: #1e293b;
    font-size: 0.82rem;
    font-weight: 700;
}
.summary-card {
    padding: 1rem;
    border: 1px solid var(--color-card-border);
    border-radius: 0.9rem;
    background: white;
}
.summary-value {
    margin: 0.25rem 0 0;
    color: #1e293b;
    font-size: 1.5rem;
    font-weight: 700;
}
.filter-scroll {
    display: flex;
    gap: 0.25rem;
    max-width: 100%;
    padding: 0.25rem;
    overflow-x: auto;
    border-radius: 0.75rem;
    background: var(--color-green-50);
}
.filter-btn {
    flex: 0 0 auto;
    padding: 0.4rem 0.75rem;
    border: 0;
    border-radius: 0.5rem;
    background: transparent;
    color: var(--color-text-muted);
    font-size: 0.72rem;
    font-weight: 600;
    cursor: pointer;
}
.filter-btn--active {
    background: var(--color-green-700);
    color: white;
}
.th-cell {
    padding: 0.75rem 1rem;
    color: #334155;
    font-size: 0.7rem;
    font-weight: 700;
    letter-spacing: 0.04em;
    text-align: left;
    text-transform: uppercase;
    white-space: nowrap;
}
.table-row {
    border-bottom: 1px solid #f1f5f9;
}
.table-row:hover {
    background: var(--color-green-50) !important;
}
.review-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0.75rem;
    margin: 0;
}
.review-item {
    padding: 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 0.75rem;
}
.review-item dt {
    color: #94a3b8;
    font-size: 0.68rem;
}
.review-item dd {
    margin: 0.25rem 0 0;
    color: #334155;
    font-size: 0.78rem;
    font-weight: 600;
    overflow-wrap: anywhere;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
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
@media (max-width: 639px) {
    .review-grid { grid-template-columns: 1fr; }
}
</style>
