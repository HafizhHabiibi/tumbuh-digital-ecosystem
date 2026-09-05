<template>
    <div class="p-4 sm:p-5 md:p-6 w-full max-w-6xl mx-auto space-y-5 min-w-0">
        <!-- ─── Header Modern ────────────────────────────────────── -->
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-800 m-0 tracking-tight">
                    Rujukan Anak
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
                <label id="pilih-anak-title" for="pilih_anak_rujukan" class="text-sm font-semibold text-slate-800">
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
                        id="pilih_anak_rujukan"
                        ref="anakSelect"
                        v-model="anakTerpilihId"
                        :disabled="kaderStore.loading.anakOptions"
                        class="input-field w-full pl-9 pr-8 py-2.5 rounded-xl text-sm appearance-none"
                        :aria-invalid="!!selectionMessage"
                        aria-describedby="rujukan_selection_message"
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
                id="rujukan_selection_message"
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
                <button type="button" class="font-semibold underline cursor-pointer" @click="kaderStore.fetchAnakOptions()">
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
                        <span>Ajukan Rujukan</span>
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
                v-if="rujukanStore.createResult"
                class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 shadow-2xs"
                role="status"
            >
                <div class="flex items-start gap-3">
                    <i class="pi pi-check-circle mt-0.5 text-emerald-600 text-base" aria-hidden="true" />
                    <div>
                        <p class="text-sm font-bold m-0">Rujukan berhasil diajukan</p>
                        <p class="text-xs text-emerald-700 mt-1 mb-0">
                            Pengajuan telah dikirim ke puskesmas dan tercatat di riwayat rujukan anak.
                        </p>
                    </div>
                </div>
                <button
                    type="button"
                    class="p-1 text-emerald-700 hover:text-emerald-900 cursor-pointer"
                    aria-label="Tutup pemberitahuan"
                    @click="rujukanStore.resetCreateState()"
                >
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <!-- ─── Kondisi: Anak Sudah Terpilih ──────────────────────── -->
        <template v-if="anakTerpilihId">
            <Transition name="slide-down">
                <div
                    v-if="rujukanStore.error.fetchByAnak || pengukuranStore.error.riwayat"
                    class="flex items-center justify-between gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700"
                    role="alert"
                >
                    <div class="flex items-center gap-2">
                        <i class="pi pi-exclamation-circle" aria-hidden="true" />
                        <span>{{ rujukanStore.error.fetchByAnak || pengukuranStore.error.riwayat }}</span>
                    </div>
                    <button type="button" class="font-semibold underline cursor-pointer" @click="loadSelectedAnakData">
                        Coba lagi
                    </button>
                </div>
            </Transition>

            <!-- ─── Banner Kartu Rujukan Aktif (Jika Ada) ──────────── -->
            <section
                v-if="activeRujukan"
                class="p-4 rounded-2xl bg-amber-50/70 border border-amber-200/80 shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-4"
                aria-labelledby="active-referral-title"
            >
                <div class="flex items-start gap-3.5 min-w-0">
                    <div class="w-10 h-10 rounded-xl bg-amber-100 border border-amber-200 flex items-center justify-center text-amber-700 shrink-0 shadow-2xs">
                        <i class="pi pi-send text-base" aria-hidden="true" />
                    </div>
                    <div class="min-w-0">
                        <div class="flex items-center gap-2 flex-wrap">
                            <span class="text-[10px] uppercase font-bold tracking-wider text-amber-800 bg-amber-200/60 px-2 py-0.5 rounded-md">
                                Rujukan Aktif
                            </span>
                            <StatusBadge type="rujukan" :value="activeRujukan.status" />
                            <StatusBadge type="prioritas" :value="activeRujukan.prioritas_pemantauan?.kategori" />
                        </div>
                        <p class="text-xs text-slate-600 mt-1 mb-0">
                            Diajukan pada <strong class="text-slate-800">{{ formatTanggal(activeRujukan.created_at) }}</strong>
                            <span v-if="activeRujukan.tanggal_ukur">berdasarkan pengukuran <strong class="text-slate-800">{{ formatTanggal(activeRujukan.tanggal_ukur) }}</strong></span>.
                            <span v-if="activeRujukan.ditangani_oleh" class="block sm:inline mt-0.5 sm:mt-0 sm:ml-1 text-slate-500">
                                Ditangani oleh: <span class="font-medium text-slate-700">{{ activeRujukan.ditangani_oleh }}</span>
                            </span>
                        </p>
                    </div>
                </div>
                <div class="shrink-0 self-end sm:self-center">
                    <button
                        type="button"
                        class="text-xs font-semibold px-3 py-1.5 rounded-lg bg-white border border-amber-300 hover:bg-amber-100 text-amber-900 transition-colors cursor-pointer inline-flex items-center gap-1.5 shadow-2xs"
                        @click="lihatDetail(activeRujukan.id)"
                    >
                        <i class="pi pi-eye text-[11px]" aria-hidden="true" />
                        <span>Lihat Detail</span>
                    </button>
                </div>
            </section>

            <!-- ─── Section Riwayat Rujukan (Satu Card Besar) ──────── -->
            <section class="card p-4 sm:p-5 rounded-2xl space-y-4 w-full min-w-0" aria-labelledby="history-title">
                <div class="flex items-center gap-3.5 sm:gap-4 min-w-0">
                    <h2 id="history-title" class="text-base font-bold text-slate-800 m-0 shrink-0">
                        Riwayat Rujukan
                    </h2>
                    <div class="flex items-center gap-1.5 overflow-x-auto pb-0.5 min-w-0 flex-1 filter-scroll" role="group" aria-label="Filter status rujukan">
                        <button
                            type="button"
                            class="filter-pill"
                            :class="{ 'filter-pill--active': filterStatus === 'semua' }"
                            :aria-pressed="filterStatus === 'semua'"
                            @click="filterStatus = 'semua'"
                        >
                            Semua
                            <span class="ml-1 text-[10px] opacity-75">({{ rujukanStore.riwayatAnak.list.length }})</span>
                        </button>
                        <button
                            type="button"
                            class="filter-pill"
                            :class="{ 'filter-pill--active': filterStatus === 'aktif' }"
                            :aria-pressed="filterStatus === 'aktif'"
                            @click="filterStatus = 'aktif'"
                        >
                            Aktif
                            <span class="ml-1 text-[10px] opacity-75">({{ jumlahAktif }})</span>
                        </button>
                        <button
                            type="button"
                            class="filter-pill"
                            :class="{ 'filter-pill--active': filterStatus === 'selesai' }"
                            :aria-pressed="filterStatus === 'selesai'"
                            @click="filterStatus = 'selesai'"
                        >
                            Selesai
                            <span class="ml-1 text-[10px] opacity-75">({{ jumlahSelesai }})</span>
                        </button>
                    </div>
                </div>

                <!-- Loading State -->
                <div v-if="rujukanStore.loading.fetchByAnak" class="space-y-3 pt-1">
                    <div v-for="i in 3" :key="i" class="skeleton h-14 rounded-xl" />
                </div>

                <!-- Empty State -->
                <div
                    v-else-if="riwayatTampil.length === 0"
                    class="flex flex-col items-center justify-center py-7 sm:py-8 gap-2.5 text-center px-4 bg-slate-50/50 rounded-xl border border-slate-100"
                >
                    <div class="w-10 h-10 rounded-xl bg-white border border-slate-200/80 flex items-center justify-center text-slate-400 shadow-2xs">
                        <i class="pi pi-send text-lg" aria-hidden="true" />
                    </div>
                    <div>
                        <p class="text-xs sm:text-sm font-semibold text-slate-700 m-0">
                            {{ filterStatus === "semua" ? "Belum ada riwayat rujukan" : `Tidak ada rujukan berstatus ${filterStatus}` }}
                        </p>
                        <p class="text-[11px] sm:text-xs text-slate-400 mt-0.5 mb-0">
                            Ajukan rujukan ke puskesmas jika anak membutuhkan pemeriksaan lanjutan atau penanganan khusus.
                        </p>
                    </div>
                    <button
                        v-if="filterStatus === 'semua' && !activeRujukan"
                        type="button"
                        class="btn-primary px-3.5 py-1.5 rounded-lg text-xs font-semibold text-white cursor-pointer mt-0.5 shadow-xs hover:bg-emerald-700 transition-all inline-flex items-center gap-1.5"
                        @click="openForm"
                    >
                        <i class="pi pi-plus text-[10px]" aria-hidden="true" />
                        <span>Ajukan Rujukan</span>
                    </button>
                </div>

                <!-- Table State (Pemantauan Style) -->
                <div v-else class="space-y-2">
                    <p class="sm:hidden text-[11px] text-slate-400 mb-0">
                        Geser tabel ke samping untuk melihat seluruh informasi.
                    </p>
                    <div class="overflow-x-auto w-full max-w-full rounded-xl border border-slate-200/80 overflow-hidden">
                        <table class="w-full min-w-[700px] text-sm" aria-label="Riwayat rujukan anak">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-100">
                                    <th class="th-cell">Tanggal Diajukan</th>
                                    <th class="th-cell">Status Rujukan</th>
                                    <th class="th-cell">Dasar Pengukuran</th>
                                    <th class="th-cell">Prioritas Pemantauan</th>
                                    <th class="th-cell">Ditangani Oleh</th>
                                    <th class="th-cell text-center w-28">Aksi</th>
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
                                            {{ formatTanggal(item.created_at) }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3.5 whitespace-nowrap">
                                        <StatusBadge type="rujukan" :value="item.status" />
                                    </td>
                                    <td class="px-4 py-3.5 whitespace-nowrap text-slate-600">
                                        {{ formatTanggal(item.tanggal_ukur) }}
                                    </td>
                                    <td class="px-4 py-3.5 whitespace-nowrap">
                                        <StatusBadge type="prioritas" :value="item.prioritas_pemantauan?.kategori" />
                                    </td>
                                    <td class="px-4 py-3.5 text-slate-600">
                                        {{ item.ditangani_oleh || "—" }}
                                    </td>
                                    <td class="px-4 py-3.5 text-center whitespace-nowrap">
                                        <button
                                            type="button"
                                            class="px-2.5 py-1.5 rounded-lg text-xs font-semibold bg-emerald-50 text-emerald-700 hover:bg-emerald-100 border border-emerald-200/60 transition-colors cursor-pointer inline-flex items-center gap-1"
                                            @click="lihatDetail(item.id)"
                                        >
                                            <i class="pi pi-eye text-[10px]" aria-hidden="true" />
                                            <span>Detail</span>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </template>

        <!-- ─── Kondisi: Belum Memilih Anak ───────────────────────── -->
        <div v-else class="card p-8 sm:p-10 rounded-2xl flex flex-col items-center justify-center gap-3 text-center bg-white border border-slate-200/80 shadow-2xs">
            <div class="w-12 h-12 rounded-2xl bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-600 shadow-2xs">
                <i class="pi pi-send text-xl" aria-hidden="true" />
            </div>
            <div>
                <p class="text-sm font-bold text-slate-800 m-0">Pilih Anak Terlebih Dahulu</p>
                <p class="text-xs text-slate-500 mt-1 mb-0 max-w-md">
                    Pilih nama anak pada menu di atas untuk melihat status rujukan aktif dan riwayat pengajuan rujukan ke puskesmas.
                </p>
            </div>
        </div>

        <!-- ─── Dialog Detail Rujukan ─────────────────────────────── -->
        <Dialog
            v-model:visible="showDetail"
            modal
            header="Detail Rujukan"
            :style="{ width: '620px', maxWidth: '95vw' }"
        >
            <div v-if="rujukanStore.loading.fetchDetail" class="p-6 space-y-3">
                <div v-for="i in 5" :key="i" class="skeleton h-12 rounded-xl" />
            </div>
            <div
                v-else-if="rujukanStore.error.fetchDetail"
                class="p-4 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm"
                role="alert"
            >
                {{ rujukanStore.error.fetchDetail }}
            </div>
            <RujukanDetailCard
                v-else-if="rujukanStore.rujukanDetail"
                :rujukan="rujukanStore.rujukanDetail"
            />
        </Dialog>

        <!-- ─── Dialog Ajukan Rujukan ─────────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!rujukanStore.loading.create"
            header="Ajukan Rujukan"
            :style="{ width: '520px', maxWidth: '95vw' }"
        >
            <div v-if="selectedAnak" class="mt-3 px-3 py-2.5 rounded-xl bg-emerald-50 border border-emerald-100">
                <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400 m-0">Rujukan untuk</p>
                <p class="text-sm font-bold text-slate-800 mt-1 mb-0">
                    {{ selectedAnak.nama }} ({{ selectedAnak.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }})
                </p>
            </div>
            <FormRujukan
                :loading="rujukanStore.loading.create"
                :error="rujukanStore.error.create"
                :anak-id="anakTerpilihId"
                :riwayat-pengukuran="pengukuranStore.riwayat.list"
                :loading-pengukuran="pengukuranStore.loading.riwayat"
                @submit="reviewSubmission"
                @cancel="closeForm"
            />
        </Dialog>

        <!-- ─── Dialog Konfirmasi Rujukan ─────────────────────────── -->
        <Dialog
            v-model:visible="showConfirmation"
            modal
            :closable="!rujukanStore.loading.create"
            header="Konfirmasi Rujukan"
            :style="{ width: '500px', maxWidth: '95vw' }"
        >
            <div v-if="pendingPayload" class="space-y-4">
                <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed">
                    Pengajuan akan dikirim ke puskesmas dan orang tua akan menerima pemberitahuan. Pastikan data sudah benar.
                </div>
                <dl class="review-grid">
                    <div>
                        <dt>Anak</dt>
                        <dd>{{ selectedAnak?.nama || "—" }}</dd>
                    </div>
                    <div>
                        <dt>Dasar Pengukuran</dt>
                        <dd>{{ formatTanggal(pendingMeasurement?.tanggal_ukur) }}</dd>
                    </div>
                    <div class="sm:col-span-2">
                        <dt>Alasan dan Kondisi Anak</dt>
                        <dd>{{ pendingPayload.catatan_kader }}</dd>
                    </div>
                </dl>
                <div class="flex justify-end gap-2">
                    <button
                        v-if="!rujukanStore.loading.create"
                        type="button"
                        class="px-4 py-2 rounded-xl text-xs font-semibold border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors cursor-pointer"
                        @click="showConfirmation = false"
                    >
                        Periksa Kembali
                    </button>
                    <button
                        type="button"
                        class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white inline-flex items-center gap-2 cursor-pointer shadow-xs hover:bg-emerald-700 transition-all"
                        :aria-busy="rujukanStore.loading.create"
                        @click="confirmSubmission"
                    >
                        <i v-if="rujukanStore.loading.create" class="pi pi-spin pi-spinner" aria-hidden="true" />
                        <i v-else class="pi pi-send" aria-hidden="true" />
                        {{ rujukanStore.loading.create ? "Mengajukan..." : "Ajukan Rujukan" }}
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
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import FormRujukan from "@/components/forms/FormRujukan.vue";
import { useRujukanStore } from "@/stores/rujukanStore";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useKaderStore } from "@/stores/kaderStore";
import { formatTanggal, hitungUsia, toLocalDateStr } from "@/utils/format.js";

const route = useRoute();
const rujukanStore = useRujukanStore();
const pengukuranStore = usePengukuranStore();
const kaderStore = useKaderStore();

const todayDate = new Date();
const anakTerpilihId = ref("");
const searchAnak = ref("");
const filterStatus = ref("semua");
const showForm = ref(false);
const showDetail = ref(false);
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
    if (rujukanStore.riwayatAnak.anak && String(rujukanStore.riwayatAnak.anak.id) === String(anakTerpilihId.value)) {
        return rujukanStore.riwayatAnak.anak;
    }
    return kaderStore.anakOptions.find((item) => String(item.id) === String(anakTerpilihId.value)) || null;
});

const activeRujukan = computed(() => rujukanStore.riwayatAnak.list.find((item) => item.status !== "selesai") || null);
const jumlahAktif = computed(() => rujukanStore.riwayatAnak.list.filter((item) => item.status !== "selesai").length);
const jumlahSelesai = computed(() => rujukanStore.riwayatAnak.list.filter((item) => item.status === "selesai").length);

const riwayatTampil = computed(() => {
    const list = rujukanStore.riwayatAnak.list;
    if (filterStatus.value === "aktif") return list.filter((item) => item.status !== "selesai");
    if (filterStatus.value === "selesai") return list.filter((item) => item.status === "selesai");
    return list;
});

const pendingMeasurement = computed(() => {
    return pengukuranStore.riwayat.list.find((item) => String(item.id) === String(pendingPayload.value?.pengukuran_id)) || null;
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

const loadSelectedAnakData = () => {
    if (!anakTerpilihId.value) return;
    rujukanStore.fetchRujukanByAnak(anakTerpilihId.value);
    pengukuranStore.fetchRiwayat(anakTerpilihId.value);
};

const onAnakChange = () => {
    selectionMessage.value = "";
    filterStatus.value = "semua";
    rujukanStore.resetCreateState();
    if (anakTerpilihId.value) loadSelectedAnakData();
    else {
        rujukanStore.resetRiwayatAnak();
        pengukuranStore.resetRiwayat();
    }
};

const lihatDetail = async (id) => {
    showDetail.value = true;
    await rujukanStore.fetchDetailRujukan(id);
};

const openForm = async () => {
    if (!anakTerpilihId.value) {
        selectionMessage.value = "Pilih anak sebelum mengajukan rujukan.";
        await nextTick();
        anakSelect.value?.focus();
        return;
    }
    if (rujukanStore.loading.fetchByAnak) {
        selectionMessage.value = "Tunggu hingga riwayat rujukan selesai dimuat.";
        return;
    }
    if (activeRujukan.value) {
        selectionMessage.value = "Anak masih memiliki rujukan aktif. Selesaikan rujukan tersebut sebelum membuat yang baru.";
        lihatDetail(activeRujukan.value.id);
        return;
    }
    selectionMessage.value = "";
    rujukanStore.resetCreateState();
    showForm.value = true;
};

const closeForm = () => {
    showForm.value = false;
    showConfirmation.value = false;
    pendingPayload.value = null;
    rujukanStore.error.create = null;
};

const reviewSubmission = (payload) => {
    if (rujukanStore.loading.create) return;
    pendingPayload.value = payload;
    showConfirmation.value = true;
};

const confirmSubmission = async () => {
    if (!pendingPayload.value || rujukanStore.loading.create) return;
    const ok = await rujukanStore.createRujukan(pendingPayload.value);
    if (ok) {
        showConfirmation.value = false;
        showForm.value = false;
        pendingPayload.value = null;
    } else {
        showConfirmation.value = false;
    }
};

onMounted(async () => {
    rujukanStore.resetCreateState();
    if (kaderStore.anakOptions.length === 0) await kaderStore.fetchAnakOptions();
    const queryId = Array.isArray(route.query.anakId) ? route.query.anakId[0] : route.query.anakId;
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
.review-grid > div {
    padding: 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 0.75rem;
    background: #f8fafc;
}
.review-grid dt {
    color: #64748b;
    font-size: 0.68rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.02em;
}
.review-grid dd {
    margin: 0.25rem 0 0;
    color: #1e293b;
    font-size: 0.85rem;
    font-weight: 700;
    white-space: pre-wrap;
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
