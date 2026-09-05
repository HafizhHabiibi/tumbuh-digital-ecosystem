<template>
    <div class="p-4 sm:p-6 max-w-6xl mx-auto space-y-6">
        <PageHeader title="Rujukan">
            <template #actions>
                <button type="button" class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white cursor-pointer" @click="openForm">
                    <i class="pi pi-plus" aria-hidden="true" />
                    Ajukan Rujukan
                </button>
            </template>
        </PageHeader>

        <section class="card p-4 rounded-2xl space-y-3">
            <div class="flex items-center gap-3 flex-wrap">
                <label for="pilih_anak_rujukan" class="text-sm font-semibold text-slate-700 flex-shrink-0">
                    <i class="pi pi-heart mr-1.5 text-emerald-700" aria-hidden="true" />
                    Pilih Anak
                </label>
                <div class="relative flex-1 min-w-48">
                    <select
                        id="pilih_anak_rujukan"
                        ref="anakSelect"
                        v-model="anakTerpilihId"
                        :disabled="kaderStore.loading.anakOptions"
                        class="input-field w-full px-4 py-2.5 rounded-xl text-sm appearance-none"
                        :aria-invalid="!!selectionMessage"
                        aria-describedby="rujukan_selection_message"
                        @change="onAnakChange"
                    >
                        <option value="">{{ kaderStore.loading.anakOptions ? "Memuat data anak..." : "Pilih nama anak" }}</option>
                        <option v-for="anak in kaderStore.anakOptions" :key="anak.id" :value="anak.id">
                            {{ anak.nama }} — {{ anak.nama_orang_tua }}
                        </option>
                    </select>
                    <i class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none text-slate-400" aria-hidden="true" />
                </div>
            </div>

            <p v-if="selectionMessage" id="rujukan_selection_message" class="flex items-center gap-2 text-xs text-amber-800 m-0" role="alert">
                <i class="pi pi-info-circle" aria-hidden="true" />
                {{ selectionMessage }}
            </p>

            <div v-if="kaderStore.error.anakOptions" class="flex items-center justify-between gap-3 text-xs text-red-700" role="alert">
                <span>{{ kaderStore.error.anakOptions }}</span>
                <button type="button" class="font-semibold underline cursor-pointer" @click="kaderStore.fetchAnakOptions()">Coba lagi</button>
            </div>

            <div v-if="selectedAnak" class="grid grid-cols-1 sm:grid-cols-3 gap-3 p-3 rounded-xl bg-emerald-50 border border-emerald-100">
                <div><p class="context-label">Nama Anak</p><p class="context-value">{{ selectedAnak.nama }}</p></div>
                <div><p class="context-label">Orang Tua</p><p class="context-value">{{ selectedAnak.nama_orang_tua || "—" }}</p></div>
                <div><p class="context-label">Usia Sekarang</p><p class="context-value">{{ hitungUsia(selectedAnak.tanggal_lahir) }}</p></div>
            </div>
        </section>

        <Transition name="slide-down">
            <div v-if="rujukanStore.createResult" class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900" role="status">
                <div class="flex items-start gap-3">
                    <i class="pi pi-check-circle mt-0.5 text-emerald-600" aria-hidden="true" />
                    <div>
                        <p class="text-sm font-bold m-0">Rujukan berhasil diajukan</p>
                        <p class="text-xs text-emerald-700 mt-1 mb-0">Puskesmas dan orang tua dapat mengikuti perkembangan status rujukan ini.</p>
                    </div>
                </div>
                <button type="button" class="p-1 text-emerald-700 cursor-pointer" aria-label="Tutup pemberitahuan" @click="rujukanStore.resetCreateState()">
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <template v-if="anakTerpilihId">
            <div v-if="rujukanStore.error.fetchByAnak || pengukuranStore.error.riwayat" class="flex items-center justify-between gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700" role="alert">
                <div class="flex items-center gap-2">
                    <i class="pi pi-exclamation-circle" aria-hidden="true" />
                    <span>{{ rujukanStore.error.fetchByAnak || pengukuranStore.error.riwayat }}</span>
                </div>
                <button type="button" class="font-semibold underline cursor-pointer" @click="loadSelectedAnakData">Coba lagi</button>
            </div>

            <section v-if="activeRujukan" class="active-referral" aria-labelledby="active-referral-title">
                <div class="flex items-start gap-3">
                    <div class="active-icon"><i class="pi pi-send" aria-hidden="true" /></div>
                    <div>
                        <p class="eyebrow">Rujukan Aktif</p>
                        <h2 id="active-referral-title" class="text-base font-bold text-slate-800 mt-1 mb-0">
                            {{ LABEL_STATUS[activeRujukan.status] }}
                        </h2>
                        <p class="text-xs text-slate-500 mt-1 mb-0">
                            Diajukan {{ formatTanggal(activeRujukan.created_at) }} berdasarkan pengukuran {{ formatTanggal(activeRujukan.tanggal_ukur) }}.
                        </p>
                    </div>
                </div>
                <div class="flex items-center gap-2 flex-wrap">
                    <span class="text-xs px-2.5 py-1 rounded-full font-semibold capitalize" :style="priorityStyle(activeRujukan)">
                        Prioritas {{ activeRujukan.prioritas_pemantauan?.kategori ?? "—" }}
                    </span>
                    <button type="button" class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 text-slate-700 cursor-pointer" @click="lihatDetail(activeRujukan.id)">
                        Lihat Rujukan Aktif
                    </button>
                </div>
            </section>

            <section class="space-y-3" aria-labelledby="history-title">
                <div class="flex items-end justify-between gap-3 flex-wrap">
                    <div>
                        <h2 id="history-title" class="text-base font-bold text-slate-800 m-0">Riwayat Rujukan</h2>
                        <p class="text-xs text-slate-500 mt-1 mb-0">Seluruh rujukan dan perkembangan status untuk anak ini.</p>
                    </div>
                    <div class="flex gap-2 text-xs text-slate-500">
                        <span class="count-chip">Aktif {{ jumlahAktif }}</span>
                        <span class="count-chip">Selesai {{ jumlahSelesai }}</span>
                    </div>
                </div>

                <div class="card rounded-2xl overflow-hidden">
                    <div v-if="rujukanStore.loading.fetchByAnak" class="p-4 space-y-3">
                        <div v-for="i in 3" :key="i" class="skeleton h-16 rounded-xl" />
                    </div>
                    <div v-else-if="rujukanStore.riwayatAnak.list.length === 0" class="flex flex-col items-center justify-center py-16 gap-3 text-center px-4">
                        <i class="pi pi-send text-4xl text-slate-300" aria-hidden="true" />
                        <div>
                            <p class="text-sm font-semibold text-slate-700 m-0">Belum ada riwayat rujukan</p>
                            <p class="text-xs text-slate-500 mt-1 mb-0">Ajukan rujukan jika anak membutuhkan pemeriksaan lanjutan.</p>
                        </div>
                        <button type="button" class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white cursor-pointer" @click="openForm">Ajukan Rujukan</button>
                    </div>
                    <template v-else>
                        <p class="sm:hidden text-[11px] text-slate-400 px-4 pt-3 mb-0">Geser tabel ke samping untuk melihat seluruh informasi.</p>
                        <div class="overflow-x-auto">
                            <table class="w-full min-w-[900px] text-sm" aria-label="Riwayat rujukan anak">
                                <thead><tr class="bg-emerald-50 border-b border-slate-200">
                                    <th class="th-cell">Tanggal Diajukan</th>
                                    <th class="th-cell">Status Rujukan</th>
                                    <th class="th-cell">Dasar Pengukuran</th>
                                    <th class="th-cell">Prioritas Pemantauan</th>
                                    <th class="th-cell">Ditangani Oleh</th>
                                    <th class="th-cell">Aksi</th>
                                </tr></thead>
                                <tbody>
                                    <tr v-for="(item, index) in rujukanStore.riwayatAnak.list" :key="item.id" class="table-row" :class="{ 'bg-slate-50/70': index % 2 !== 0 }">
                                        <td class="px-4 py-3 whitespace-nowrap text-slate-700">{{ formatTanggal(item.created_at) }}</td>
                                        <td class="px-4 py-3"><StatusBadge type="rujukan" :value="item.status" /></td>
                                        <td class="px-4 py-3 whitespace-nowrap text-slate-600">{{ formatTanggal(item.tanggal_ukur) }}</td>
                                        <td class="px-4 py-3"><StatusBadge type="prioritas" :value="item.prioritas_pemantauan?.kategori" /></td>
                                        <td class="px-4 py-3 text-slate-600">{{ item.ditangani_oleh || "—" }}</td>
                                        <td class="px-4 py-3">
                                            <button type="button" class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-emerald-50 text-emerald-700 cursor-pointer" @click="lihatDetail(item.id)">
                                                Lihat Detail
                                            </button>
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
            <div><p class="text-sm font-semibold text-slate-700 m-0">Pilih anak terlebih dahulu</p><p class="text-xs text-slate-500 mt-1 mb-0">Rujukan aktif dan riwayat akan ditampilkan sesuai anak yang dipilih.</p></div>
        </div>

        <Dialog v-model:visible="showDetail" modal header="Detail Rujukan" :style="{ width: '620px', maxWidth: '95vw' }">
            <div v-if="rujukanStore.loading.fetchDetail" class="p-6 space-y-3"><div v-for="i in 5" :key="i" class="skeleton h-12 rounded-xl" /></div>
            <div v-else-if="rujukanStore.error.fetchDetail" class="p-4 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm" role="alert">
                {{ rujukanStore.error.fetchDetail }}
            </div>
            <RujukanDetailCard v-else-if="rujukanStore.rujukanDetail" :rujukan="rujukanStore.rujukanDetail" />
        </Dialog>

        <Dialog v-model:visible="showForm" modal :closable="!rujukanStore.loading.create" header="Ajukan Rujukan" :style="{ width: '520px', maxWidth: '95vw' }">
            <div v-if="selectedAnak" class="mt-3 px-3 py-2.5 rounded-xl bg-emerald-50 border border-emerald-100">
                <p class="text-[10px] uppercase tracking-wider font-semibold text-slate-400 m-0">Rujukan untuk</p>
                <p class="text-sm font-bold text-slate-800 mt-1 mb-0">{{ selectedAnak.nama }}</p>
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

        <Dialog v-model:visible="showConfirmation" modal :closable="!rujukanStore.loading.create" header="Konfirmasi Rujukan" :style="{ width: '500px', maxWidth: '95vw' }">
            <div v-if="pendingPayload" class="space-y-4">
                <div class="p-3 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs leading-relaxed">Pengajuan akan dikirim ke puskesmas dan orang tua akan menerima pemberitahuan. Pastikan data sudah benar.</div>
                <dl class="review-grid">
                    <div><dt>Anak</dt><dd>{{ selectedAnak?.nama || "—" }}</dd></div>
                    <div><dt>Dasar Pengukuran</dt><dd>{{ formatTanggal(pendingMeasurement?.tanggal_ukur) }}</dd></div>
                    <div class="sm:col-span-2"><dt>Alasan dan Kondisi Anak</dt><dd>{{ pendingPayload.catatan_kader }}</dd></div>
                </dl>
                <div class="flex justify-end gap-2">
                    <button v-if="!rujukanStore.loading.create" type="button" class="px-4 py-2 rounded-xl text-xs font-semibold border border-slate-200 bg-white text-slate-700 cursor-pointer" @click="showConfirmation = false">Periksa Kembali</button>
                    <button type="button" class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white inline-flex items-center gap-2 cursor-pointer" :aria-busy="rujukanStore.loading.create" @click="confirmSubmission">
                        <i v-if="rujukanStore.loading.create" class="pi pi-spin pi-spinner" aria-hidden="true" /><i v-else class="pi pi-send" aria-hidden="true" />
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
import PageHeader from "@/components/ui/PageHeader.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import FormRujukan from "@/components/forms/FormRujukan.vue";
import { useRujukanStore, LABEL_STATUS } from "@/stores/rujukanStore";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useKaderStore } from "@/stores/kaderStore";
import { formatTanggal, hitungUsia } from "@/utils/format.js";

const route = useRoute();
const rujukanStore = useRujukanStore();
const pengukuranStore = usePengukuranStore();
const kaderStore = useKaderStore();

const anakTerpilihId = ref("");
const showForm = ref(false);
const showDetail = ref(false);
const showConfirmation = ref(false);
const pendingPayload = ref(null);
const selectionMessage = ref("");
const anakSelect = ref(null);

const selectedAnak = computed(() => {
    if (rujukanStore.riwayatAnak.anak && String(rujukanStore.riwayatAnak.anak.id) === String(anakTerpilihId.value)) return rujukanStore.riwayatAnak.anak;
    return kaderStore.anakOptions.find((item) => String(item.id) === String(anakTerpilihId.value)) || null;
});
const activeRujukan = computed(() => rujukanStore.riwayatAnak.list.find((item) => item.status !== "selesai") || null);
const jumlahAktif = computed(() => rujukanStore.riwayatAnak.list.filter((item) => item.status !== "selesai").length);
const jumlahSelesai = computed(() => rujukanStore.riwayatAnak.list.filter((item) => item.status === "selesai").length);
const pendingMeasurement = computed(() => pengukuranStore.riwayat.list.find((item) => String(item.id) === String(pendingPayload.value?.pengukuran_id)) || null);

const priorityStyle = (item) => {
    const colors = { rendah: ["#dcfce7", "#15803d"], sedang: ["#fef3c7", "#b45309"], tinggi: ["#fee2e2", "#dc2626"] };
    const [background, color] = colors[item.prioritas_pemantauan?.kategori] || ["#f1f5f9", "#64748b"];
    return { background, color };
};

const loadSelectedAnakData = () => {
    if (!anakTerpilihId.value) return;
    rujukanStore.fetchRujukanByAnak(anakTerpilihId.value);
    pengukuranStore.fetchRiwayat(anakTerpilihId.value);
};
const onAnakChange = () => {
    selectionMessage.value = "";
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
    } else showConfirmation.value = false;
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
.card { background: white; border: 1px solid var(--color-card-border); box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06); }
.input-field { background: var(--color-input-bg); border: 1px solid var(--color-input-border); color: var(--color-text-heading); outline: none; font-family: "Poppins", sans-serif; }
.input-field:focus { border-color: var(--color-green-700); box-shadow: 0 0 0 2px var(--color-focus-ring); }
.context-label,.eyebrow { margin: 0; color: #64748b; font-size: .68rem; font-weight: 700; letter-spacing: .05em; text-transform: uppercase; }
.context-value { margin: .25rem 0 0; color: #1e293b; font-size: .82rem; font-weight: 700; }
.active-referral { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; padding: 1rem; border: 1px solid #fcd34d; border-radius: 1rem; background: #fffbeb; }
.active-icon { display: grid; flex: 0 0 2.5rem; width: 2.5rem; height: 2.5rem; place-items: center; border-radius: .75rem; background: #fef3c7; color: #b45309; }
.count-chip { padding: .35rem .6rem; border-radius: .5rem; background: #f1f5f9; font-weight: 600; }
.th-cell { padding: .75rem 1rem; color: #334155; font-size: .7rem; font-weight: 700; letter-spacing: .04em; text-align: left; text-transform: uppercase; white-space: nowrap; }
.table-row { border-bottom: 1px solid #f1f5f9; }
.table-row:hover { background: var(--color-green-50) !important; }
.review-grid { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: .75rem; margin: 0; }
.review-grid > div { padding: .75rem; border: 1px solid #e2e8f0; border-radius: .75rem; }
.review-grid dt { color: #94a3b8; font-size: .68rem; }
.review-grid dd { margin: .25rem 0 0; color: #334155; font-size: .78rem; font-weight: 600; white-space: pre-wrap; }
.skeleton { background: linear-gradient(90deg,#f0f0f0 25%,#e0e0e0 50%,#f0f0f0 75%); background-size: 200% 100%; animation: shimmer 1.5s infinite; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.slide-down-enter-active,.slide-down-leave-active { transition: all .25s ease; }
.slide-down-enter-from,.slide-down-leave-to { opacity: 0; transform: translateY(-8px); }
@media(max-width:639px) { .review-grid { grid-template-columns: 1fr; } }
</style>
