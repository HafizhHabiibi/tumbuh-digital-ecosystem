<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-800 m-0 tracking-tight">
                    Input Pemberian
                </h1>
            </div>
            <div class="flex items-center gap-2 self-start sm:self-auto">
                <div class="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-slate-200/80 shadow-2xs text-xs text-slate-600 font-medium">
                    <i class="pi pi-calendar text-emerald-600 text-xs" />
                    <span>Hari ini: <strong class="text-slate-800">{{ formatTanggal(toLocalDateStr(todayDate)) }}</strong></span>
                </div>
            </div>
        </div>

        <!-- ─── Section Pemilihan Anak ────────────────────────────── -->
        <section class="card p-4 sm:p-5 rounded-2xl space-y-3.5 w-full min-w-0" aria-labelledby="pilih-anak-title">
            <div class="flex items-center justify-between">
                <label id="pilih-anak-title" for="pilih_anak" class="text-sm font-semibold text-slate-800">
                    Pilih Anak
                </label>
                <span v-if="kaderStore.anakOptions.length > 0 && !selectedAnak" class="text-xs text-slate-400">
                    {{ kaderStore.anakOptions.length }} anak terdaftar
                </span>
            </div>

            <!-- Pencarian & Dropdown jika anak belum dipilih -->
            <div v-if="!selectedAnak" class="space-y-2.5">
                <!-- Pencarian Cepat Anak -->
                <div class="relative">
                    <i class="pi pi-search input-icon" aria-hidden="true" />
                    <input
                        v-model="searchAnak"
                        type="text"
                        placeholder="Cari nama anak, orang tua, atau NIK..."
                        class="input-field w-full pl-9 pr-8 py-2 text-xs rounded-xl"
                        :disabled="kaderStore.loading.anakOptions"
                    />
                    <button
                        v-if="searchAnak"
                        type="button"
                        class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                        @click="searchAnak = ''"
                    >
                        <i class="pi pi-times text-xs" />
                    </button>
                </div>

                <!-- Dropdown Select Anak -->
                <div class="relative">
                    <i class="pi pi-user input-icon" aria-hidden="true" />
                    <select
                        id="pilih_anak"
                        ref="anakSelect"
                        v-model="anakTerpilihId"
                        :disabled="kaderStore.loading.anakOptions"
                        class="input-field w-full pl-9 pr-8 py-2.5 rounded-xl text-sm appearance-none"
                        :aria-invalid="!!selectionMessage"
                        aria-describedby="pilih_anak_message"
                        @change="onAnakChange"
                    >
                        <option value="">
                            {{ kaderStore.loading.anakOptions ? "Memuat data anak..." : (filteredAnakOptions.length === 0 ? "Tidak ditemukan anak yang cocok" : "Pilih nama anak") }}
                        </option>
                        <option
                            v-for="anak in filteredAnakOptions"
                            :key="anak.id"
                            :value="anak.id"
                        >
                            {{ anak.nama }} ({{ anak.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}) — Ortu: {{ anak.nama_orang_tua || '—' }}
                        </option>
                    </select>
                    <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
                </div>
            </div>

            <!-- Alert Pesan Seleksi -->
            <div
                v-if="selectionMessage"
                id="pilih_anak_message"
                class="flex items-center gap-2 text-xs text-amber-800 bg-amber-50 p-3 rounded-xl border border-amber-200"
                role="alert"
            >
                <i class="pi pi-info-circle shrink-0" aria-hidden="true" />
                <span>{{ selectionMessage }}</span>
            </div>

            <!-- Error Fetching Anak Options -->
            <div
                v-if="kaderStore.error.anakOptions"
                class="flex items-center justify-between gap-3 text-xs text-red-700 bg-red-50 p-3 rounded-xl border border-red-200"
                role="alert"
            >
                <span>{{ kaderStore.error.anakOptions }}</span>
                <button type="button" class="font-semibold underline cursor-pointer" @click="loadAnakOptions">
                    Coba lagi
                </button>
            </div>

            <!-- Kartu Profil Anak Terpilih -->
            <div
                v-if="selectedAnak"
                class="p-3.5 sm:p-4 rounded-xl bg-slate-50/80 border border-slate-200/80 flex items-center justify-between gap-4 flex-wrap sm:flex-nowrap"
            >
                <div class="flex items-center gap-3.5 min-w-0">
                    <div
                        class="w-12 h-12 rounded-xl flex items-center justify-center font-bold text-sm shrink-0 shadow-2xs"
                        :class="selectedAnak.jenis_kelamin === 'L' ? 'bg-blue-100 text-blue-700' : 'bg-rose-100 text-rose-700'"
                    >
                        {{ getInitials(selectedAnak.nama) }}
                    </div>
                    <div class="min-w-0">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="text-sm font-bold text-slate-800 truncate">{{ selectedAnak.nama }}</span>
                            <span
                                class="text-[11px] px-2.5 py-0.5 rounded-md font-semibold shrink-0"
                                :class="selectedAnak.jenis_kelamin === 'L' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-rose-50 text-rose-700 border border-rose-200'"
                            >
                                {{ selectedAnak.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-1 mb-0">
                            <span class="text-slate-600 font-medium">Orang Tua:</span> {{ selectedAnak.nama_orang_tua || '—' }}
                            <span class="mx-1.5 text-slate-300">•</span>
                            <span class="text-slate-600 font-medium">Usia:</span> {{ hitungUsia(selectedAnak.tanggal_lahir) }}
                        </p>
                    </div>
                </div>
                <div class="flex items-center gap-2 shrink-0">
                    <button
                        type="button"
                        class="text-xs font-semibold px-2.5 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white transition-colors shrink-0 cursor-pointer inline-flex items-center gap-1.5"
                        @click="openForm"
                    >
                        <i class="pi pi-plus text-[10px]" aria-hidden="true" />
                        <span>Catat Pemberian</span>
                    </button>
                    <button
                        type="button"
                        class="text-xs font-semibold px-2.5 py-1.5 rounded-lg bg-white border border-slate-200 hover:bg-slate-100 text-slate-600 transition-colors shrink-0 cursor-pointer"
                        title="Ganti anak terpilih"
                        @click="handleGantiAnak"
                    >
                        Ganti
                    </button>
                </div>
            </div>
        </section>

        <!-- ─── Banner Notifikasi Sukses Simpan ───────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="pemberianStore.createResult"
                class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 shadow-2xs"
                role="status"
            >
                <div class="flex items-start gap-3">
                    <i class="pi pi-check-circle mt-0.5 text-emerald-600 text-base" aria-hidden="true" />
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
                    class="p-1 text-emerald-700 hover:text-emerald-900 cursor-pointer"
                    aria-label="Tutup pemberitahuan"
                    @click="pemberianStore.resetCreateState()"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Kondisi 1: Anak Sudah Terpilih ───────────────────── -->
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

            <!-- ─── Section Riwayat Pemberian (Satu Card Besar) ────────── -->
            <section class="card p-4 sm:p-5 rounded-2xl space-y-4 w-full min-w-0" aria-labelledby="riwayat-pemberian-title">
                <div class="flex items-center gap-3.5 sm:gap-4 min-w-0">
                    <h2 id="riwayat-pemberian-title" class="text-base font-bold text-slate-800 m-0 shrink-0">
                        Riwayat Pemberian
                    </h2>
                    <div class="flex items-center gap-1.5 overflow-x-auto pb-0.5 min-w-0 flex-1 filter-scroll" role="group" aria-label="Filter jenis pemberian">
                        <button
                            type="button"
                            class="filter-pill"
                            :class="{ 'filter-pill--active': filterAktif === 'semua' }"
                            :aria-pressed="filterAktif === 'semua'"
                            @click="setFilter('semua')"
                        >
                            Semua
                        </button>
                        <button
                            v-for="jenis in JENIS_VALID"
                            :key="jenis"
                            type="button"
                            class="filter-pill"
                            :class="{ 'filter-pill--active': filterAktif === jenis }"
                            :aria-pressed="filterAktif === jenis"
                            @click="setFilter(jenis)"
                        >
                            {{ LABEL_JENIS[jenis] }}
                        </button>
                    </div>
                </div>

                <div v-if="pemberianStore.loading.riwayat" class="space-y-3 pt-1">
                    <div v-for="i in 4" :key="i" class="skeleton h-14 rounded-xl" />
                </div>

                <div
                    v-else-if="riwayatTampil.length === 0"
                    class="flex flex-col items-center justify-center py-7 sm:py-8 gap-2.5 text-center px-4 bg-slate-50/50 rounded-xl border border-slate-100"
                >
                    <div class="w-10 h-10 rounded-xl bg-white border border-slate-200/80 flex items-center justify-center text-slate-400 shadow-2xs">
                        <i class="pi pi-inbox text-lg" aria-hidden="true" />
                    </div>
                    <div>
                        <p class="text-xs sm:text-sm font-semibold text-slate-700 m-0">
                            Belum ada {{ filterAktif === "semua" ? "catatan pemberian" : LABEL_JENIS[filterAktif] }}
                        </p>
                        <p class="text-[11px] sm:text-xs text-slate-400 mt-0.5 mb-0">Catat pemberian vitamin atau makanan tambahan untuk anak ini.</p>
                    </div>
                    <button
                        type="button"
                        class="btn-primary px-3.5 py-1.5 rounded-lg text-xs font-semibold text-white cursor-pointer mt-0.5 shadow-xs hover:bg-emerald-700 transition-all inline-flex items-center gap-1.5"
                        @click="openForm"
                    >
                        <i class="pi pi-plus text-[10px]" aria-hidden="true" />
                        <span>Catat Sekarang</span>
                    </button>
                </div>

                <div v-else class="space-y-2">
                    <p class="sm:hidden text-[11px] text-slate-400 mb-0">
                        Geser tabel ke samping untuk melihat seluruh informasi.
                    </p>
                    <div class="overflow-x-auto w-full max-w-full rounded-xl border border-slate-200/80 overflow-hidden">
                        <table class="w-full min-w-[700px] text-sm" aria-label="Riwayat pemberian anak">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal Pemberian</th>
                                    <th class="th-cell">Jenis Pemberian</th>
                                    <th class="th-cell">Dosis atau Jumlah</th>
                                    <th class="th-cell">Dicatat Oleh</th>
                                    <th class="th-cell">Keterangan</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100 bg-white">
                                <tr
                                    v-for="item in riwayatTampil"
                                    :key="item.id"
                                    class="hover:bg-slate-50/80 transition-colors duration-150"
                                >
                                    <td class="px-4 py-3.5 whitespace-nowrap">
                                        <div class="font-semibold text-slate-800">
                                            {{ formatTanggal(item.tanggal_pemberian) }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3.5 whitespace-nowrap">
                                        <span
                                            class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                                            :style="`background: ${warnaBgJenis[item.jenis]}; color: ${warnaJenis[item.jenis]}`"
                                        >
                                            <span
                                                class="w-1.5 h-1.5 rounded-full"
                                                :style="`background: ${warnaJenis[item.jenis]}`"
                                            />
                                            {{ LABEL_JENIS[item.jenis] ?? item.jenis }}
                                        </span>
                                    </td>
                                    <td class="px-4 py-3.5">
                                        <div class="font-medium text-slate-800">
                                            {{ item.dosis || "—" }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3.5 text-slate-600">
                                        {{ item.dicatat_oleh || "—" }}
                                    </td>
                                    <td class="px-4 py-3.5 text-slate-600 min-w-48 whitespace-normal">
                                        {{ item.keterangan || "—" }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </template>

        <!-- ─── Kondisi 2: Belum Memilih Anak (Panduan Posyandu) ──── -->
        <div v-else class="space-y-4">
            <div class="card p-6 rounded-2xl bg-white border border-slate-200/80 shadow-2xs">
                <div class="flex items-center gap-3 mb-4">
                    <div class="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600 font-bold text-sm shrink-0">
                        <i class="pi pi-book" />
                    </div>
                    <div>
                        <h2 class="text-base font-bold text-slate-800 m-0">Panduan Intervensi & Suplementasi Posyandu</h2>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-3.5">
                    <div class="p-4 rounded-xl bg-blue-50/50 border border-blue-100/80 space-y-1.5">
                        <div class="flex items-center justify-between">
                            <span class="text-xs font-bold text-blue-800 flex items-center gap-1.5">
                                <i class="pi pi-sun text-blue-600 text-xs" />
                                Vitamin A Biru (100.000 IU)
                            </span>
                            <span class="text-[10px] px-2 py-0.5 rounded-full bg-blue-100 text-blue-700 font-semibold">6 – 11 Bulan</span>
                        </div>
                        <p class="text-xs text-slate-600 m-0 leading-relaxed">
                            Diberikan 1 kali pada Bulan Kapsul Vitamin A (Februari atau Agustus) untuk mendukung daya tahan tubuh & kesehatan kornea mata bayi.
                        </p>
                    </div>

                    <div class="p-4 rounded-xl bg-rose-50/50 border border-rose-100/80 space-y-1.5">
                        <div class="flex items-center justify-between">
                            <span class="text-xs font-bold text-rose-800 flex items-center gap-1.5">
                                <i class="pi pi-sun text-rose-600 text-xs" />
                                Vitamin A Merah (200.000 IU)
                            </span>
                            <span class="text-[10px] px-2 py-0.5 rounded-full bg-rose-100 text-rose-700 font-semibold">12 – 59 Bulan</span>
                        </div>
                        <p class="text-xs text-slate-600 m-0 leading-relaxed">
                            Diberikan 2 kali dalam setahun (Februari dan Agustus) untuk balita usia 1 sampai 5 tahun guna mencegah rabun senja dan infeksi.
                        </p>
                    </div>

                    <div class="p-4 rounded-xl bg-emerald-50/50 border border-emerald-100/80 space-y-1.5">
                        <div class="flex items-center justify-between">
                            <span class="text-xs font-bold text-emerald-800 flex items-center gap-1.5">
                                <i class="pi pi-shield text-emerald-600 text-xs" />
                                Obat Cacing (Albendazole)
                            </span>
                            <span class="text-[10px] px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-700 font-semibold">1 – 5 Tahun</span>
                        </div>
                        <p class="text-xs text-slate-600 m-0 leading-relaxed">
                            Diberikan secara berkala 6 bulan sekali (serentak Februari & Agustus) untuk mencegah kecacingan yang dapat memicu stunting.
                        </p>
                    </div>

                    <div class="p-4 rounded-xl bg-amber-50/50 border border-amber-100/80 space-y-1.5">
                        <div class="flex items-center justify-between">
                            <span class="text-xs font-bold text-amber-800 flex items-center gap-1.5">
                                <i class="pi pi-box text-amber-600 text-xs" />
                                PMT (Pemberian Makanan Tambahan)
                            </span>
                            <span class="text-[10px] px-2 py-0.5 rounded-full bg-amber-100 text-amber-700 font-semibold">Biskuit, Susu, Kudapan</span>
                        </div>
                        <p class="text-xs text-slate-600 m-0 leading-relaxed">
                            Diberikan kepada balita dengan gizi kurang atau balita yang tidak mengalami kenaikan berat badan (T) sebagai asupan energi pemulihan.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- ─── Dialog Catat Pemberian ────────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!pemberianStore.loading.create"
            header="Catat Pemberian"
            :style="{ width: '520px', maxWidth: '95vw' }"
            :pt="{ header: { style: 'border-bottom: 1px solid var(--color-input-border)' } }"
        >
            <div class="pt-2">
                <div v-if="selectedAnak" class="p-3 rounded-xl bg-emerald-50/80 border border-emerald-100 flex items-center gap-3 mb-2">
                    <div
                        class="w-10 h-10 rounded-xl flex items-center justify-center font-bold text-xs shrink-0"
                        :class="selectedAnak.jenis_kelamin === 'L' ? 'bg-blue-100 text-blue-700' : 'bg-rose-100 text-rose-700'"
                    >
                        {{ getInitials(selectedAnak.nama) }}
                    </div>
                    <div class="min-w-0">
                        <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-500 m-0">Pencatatan untuk</p>
                        <p class="text-sm font-bold text-slate-800 m-0 truncate">
                            {{ selectedAnak.nama }} ({{ selectedAnak.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }})
                        </p>
                    </div>
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

        <!-- ─── Dialog Konfirmasi Pemberian ──────────────────────── -->
        <Dialog
            v-model:visible="showConfirmation"
            modal
            :closable="!pemberianStore.loading.create"
            header="Konfirmasi Pemberian"
            :style="{ width: '480px', maxWidth: '95vw' }"
        >
            <div v-if="pendingPayload" class="space-y-4 pt-2">
                <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed flex items-start gap-2">
                    <i class="pi pi-info-circle text-amber-600 mt-0.5 shrink-0" aria-hidden="true" />
                    <span>Pastikan anak, jenis, dan tanggal sudah benar. Data ini akan masuk ke riwayat pemberian.</span>
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
                <div class="flex justify-end gap-2 pt-2">
                    <button
                        v-if="!pemberianStore.loading.create"
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 transition-colors cursor-pointer"
                        @click="showConfirmation = false"
                    >
                        Periksa Kembali
                    </button>
                    <button
                        type="button"
                        class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white inline-flex items-center gap-2 cursor-pointer shadow-xs hover:bg-emerald-700 transition-all"
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
import FormPemberian from "@/components/forms/FormPemberian.vue";
import {
    usePemberianStore,
    JENIS_VALID,
    LABEL_JENIS,
    WARNA_JENIS as warnaJenis,
    WARNA_BG_JENIS as warnaBgJenis,
} from "@/stores/pemberianStore";
import { useKaderStore } from "@/stores/kaderStore";
import { formatTanggal, hitungUsia, toLocalDateStr } from "@/utils/format.js";

const route = useRoute();
const pemberianStore = usePemberianStore();
const kaderStore = useKaderStore();

const todayDate = new Date();
const anakTerpilihId = ref("");
const searchAnak = ref("");
const filterAktif = ref("semua");
const showForm = ref(false);
const showConfirmation = ref(false);
const pendingPayload = ref(null);
const selectionMessage = ref("");
const anakSelect = ref(null);

const filteredAnakOptions = computed(() => {
    const query = searchAnak.value.trim().toLowerCase();
    if (!query) return kaderStore.anakOptions;
    return kaderStore.anakOptions.filter((anak) => {
        const nama = (anak.nama || "").toLowerCase();
        const nik = (anak.nik || "").toLowerCase();
        const orangTua = (anak.nama_orang_tua || "").toLowerCase();
        return nama.includes(query) || nik.includes(query) || orangTua.includes(query);
    });
});

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

const getInitials = (nama) => {
    if (!nama) return "—";
    return nama
        .split(" ")
        .filter(Boolean)
        .slice(0, 2)
        .map((n) => n[0])
        .join("")
        .toUpperCase();
};

const handleGantiAnak = () => {
    anakTerpilihId.value = "";
    searchAnak.value = "";
    onAnakChange();
};

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
.filter-scroll {
    scrollbar-width: none;
    -ms-overflow-style: none;
}
.filter-scroll::-webkit-scrollbar {
    display: none;
}
.filter-pill {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.38rem 0.75rem;
    border-radius: 0.65rem;
    font-size: 0.72rem;
    font-weight: 600;
    white-space: nowrap;
    background: white;
    color: #64748b;
    border: 1px solid #e2e8f0;
    cursor: pointer;
    flex-shrink: 0;
    transition: all 0.15s ease;
}
.filter-pill:hover {
    background: #f8fafc;
    color: #1e293b;
    border-color: #cbd5e1;
}
.filter-pill--active {
    background: #047857;
    color: white;
    border-color: #047857;
    box-shadow: 0 1px 2px rgba(4, 120, 87, 0.2);
}
.filter-pill--active:hover {
    background: #065f46;
    color: white;
    border-color: #065f46;
}
.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #1e293b;
    white-space: nowrap;
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
    background: #f8fafc;
}
.review-item dt {
    color: #64748b;
    font-size: 0.68rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.02em;
}
.review-item dd {
    margin: 0.25rem 0 0;
    color: #1e293b;
    font-size: 0.85rem;
    font-weight: 700;
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
