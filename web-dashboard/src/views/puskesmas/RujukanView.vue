<template>
    <div class="p-4 sm:p-6 max-w-7xl mx-auto space-y-6">
        <PageHeader title="Rujukan" />

        <Transition name="slide-down">
            <div v-if="rujukanStore.updateResult" class="flex items-start justify-between gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900" role="status">
                <div class="flex items-start gap-3">
                    <i class="pi pi-check-circle mt-0.5 text-emerald-600" aria-hidden="true" />
                    <div>
                        <p class="text-sm font-bold m-0">Status rujukan berhasil diperbarui</p>
                        <p class="text-xs text-emerald-700 mt-1 mb-0">Status sekarang {{ LABEL_STATUS[rujukanStore.updateResult.status] }}.</p>
                    </div>
                </div>
                <button type="button" class="p-1 text-emerald-700 cursor-pointer" aria-label="Tutup pemberitahuan" @click="rujukanStore.updateResult = null">
                    <i class="pi pi-times" aria-hidden="true" />
                </button>
            </div>
        </Transition>

        <div v-if="rujukanStore.error.fetchAll" class="flex items-center justify-between gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700" role="alert">
            <div class="flex items-center gap-2"><i class="pi pi-exclamation-circle" aria-hidden="true" /><span>{{ rujukanStore.error.fetchAll }}</span></div>
            <button type="button" class="font-semibold underline cursor-pointer" @click="loadData()">Coba lagi</button>
        </div>

        <section class="grid grid-cols-1 sm:grid-cols-3 gap-3" aria-label="Ringkasan status rujukan">
            <button
                v-for="(label, key) in LABEL_STATUS"
                :key="key"
                type="button"
                class="stat-card text-left cursor-pointer"
                :class="{ 'stat-card--active': filterStatus === key }"
                :style="filterStatus === key ? `border-color: ${warnaHex[key]}; background: ${warnaBg[key]}` : ''"
                :aria-pressed="filterStatus === key"
                @click="handleKlikCard(key)"
            >
                <span class="text-xs font-semibold text-slate-500">{{ label }}</span>
                <span class="block text-2xl font-bold mt-1" :style="`color: ${warnaHex[key]}`">{{ rujukanStore.jumlahPerStatus[key] ?? 0 }}</span>
                <span class="block text-[10px] text-slate-400 mt-1">Klik untuk memfilter antrean</span>
            </button>
        </section>

        <section class="space-y-3" aria-labelledby="queue-title">
            <div class="flex items-end justify-between gap-3 flex-wrap">
                <div>
                    <h2 id="queue-title" class="text-base font-bold text-slate-800 m-0">Antrean Rujukan</h2>
                    <p class="text-xs text-slate-500 mt-1 mb-0">Rujukan yang belum ditangani ditampilkan dari yang paling lama.</p>
                </div>
                <div class="flex gap-1 p-1 rounded-xl bg-emerald-50" role="group" aria-label="Jenis antrean">
                    <button
                        v-for="tab in tabOptions"
                        :key="tab.key"
                        type="button"
                        class="tab-btn"
                        :class="{ 'tab-btn--active': activeTab === tab.key }"
                        :aria-pressed="activeTab === tab.key"
                        @click="selectTab(tab.key)"
                    >
                        {{ tab.label }}
                        <span class="tab-count">{{ tab.key === "aktif" ? rujukanStore.totalRujukanAktif : rujukanStore.totalRujukanArsip }}</span>
                    </button>
                </div>
            </div>

            <div class="relative">
                <i class="pi pi-search absolute left-3 top-1/2 -translate-y-1/2 text-sm pointer-events-none text-slate-400" aria-hidden="true" />
                <input v-model="search" type="search" placeholder="Cari nama anak atau orang tua..." class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm" aria-label="Cari rujukan" />
            </div>

            <div class="card rounded-2xl overflow-hidden">
                <div v-if="rujukanStore.loading.fetchAll" class="p-4 space-y-3"><div v-for="i in 5" :key="i" class="skeleton h-16 rounded-xl" /></div>
                <div v-else-if="rujukanStore.rujukanList.length === 0" class="flex flex-col items-center py-16 gap-3 text-center px-4">
                    <i class="pi pi-send text-4xl text-slate-300" aria-hidden="true" />
                    <div>
                        <p class="text-sm font-semibold text-slate-700 m-0">{{ search ? "Tidak ada hasil pencarian" : `Tidak ada rujukan ${activeTab === "aktif" ? "aktif" : "selesai"}` }}</p>
                        <p class="text-xs text-slate-500 mt-1 mb-0">Coba ubah pencarian atau filter status.</p>
                    </div>
                </div>
                <template v-else>
                    <p class="sm:hidden text-[11px] text-slate-400 px-4 pt-3 mb-0">Geser tabel ke samping untuk melihat seluruh informasi.</p>
                    <div class="overflow-x-auto">
                        <table class="w-full min-w-[1120px] text-sm" aria-label="Antrean rujukan puskesmas">
                            <thead><tr class="bg-emerald-50 border-b border-slate-200">
                                <th class="th-cell">Anak</th>
                                <th class="th-cell">Orang Tua</th>
                                <th class="th-cell">Status Rujukan</th>
                                <th class="th-cell">Prioritas Pemantauan</th>
                                <th class="th-cell">Waktu Menunggu</th>
                                <th class="th-cell">Tanggal Diajukan</th>
                                <th class="th-cell">Ditangani Oleh</th>
                                <th class="th-cell">Aksi</th>
                            </tr></thead>
                            <tbody>
                                <tr v-for="(item, index) in rujukanStore.rujukanList" :key="item.id" class="table-row" :class="{ 'bg-slate-50/70': index % 2 !== 0 }">
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2">
                                            <div class="avatar" aria-hidden="true">{{ item.nama_anak?.charAt(0).toUpperCase() }}</div>
                                            <span class="font-bold text-slate-800">{{ item.nama_anak }}</span>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-slate-600">{{ item.nama_orang_tua }}</td>
                                    <td class="px-4 py-3"><StatusBadge type="rujukan" :value="item.status" /></td>
                                    <td class="px-4 py-3"><StatusBadge type="prioritas" :value="item.prioritas_pemantauan?.kategori" /></td>
                                    <td class="px-4 py-3"><span class="waiting-chip" :class="{ 'waiting-chip--long': waitingDays(item) >= 3 && item.status !== 'selesai' }">{{ waitingLabel(item) }}</span></td>
                                    <td class="px-4 py-3 whitespace-nowrap text-slate-600">{{ formatTanggal(item.created_at) }}</td>
                                    <td class="px-4 py-3 text-slate-600">{{ item.ditangani_oleh || "—" }}</td>
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-2 whitespace-nowrap">
                                            <button type="button" class="action-secondary" @click="lihatDetail(item.id)">Lihat Detail</button>
                                            <button v-if="rujukanStore.bisaDiupdate(item.status)" type="button" class="action-primary" @click="bukaUpdateStatus(item)">
                                                <i :class="item.status === 'diajukan' ? 'pi pi-play' : 'pi pi-check-circle'" aria-hidden="true" />
                                                {{ item.status === "diajukan" ? "Mulai Tangani" : "Selesaikan" }}
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <PaginationControls :pagination="rujukanStore.pagination" :loading="rujukanStore.loading.fetchAll" @change-page="changePage" />
                </template>
            </div>
        </section>

        <Dialog v-model:visible="showDetail" modal header="Detail Rujukan" :style="{ width: '620px', maxWidth: '95vw' }">
            <div v-if="rujukanStore.loading.fetchDetail" class="p-4 space-y-3"><div v-for="i in 5" :key="i" class="skeleton h-12 rounded-xl" /></div>
            <div v-else-if="rujukanStore.error.fetchDetail" class="p-4 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm" role="alert">{{ rujukanStore.error.fetchDetail }}</div>
            <RujukanDetailCard v-else-if="rujukanStore.rujukanDetail" :rujukan="rujukanStore.rujukanDetail" />
        </Dialog>

        <Dialog v-model:visible="showUpdateStatus" modal :closable="!rujukanStore.loading.updateStatus" :header="updateDialogTitle" :style="{ width: '480px', maxWidth: '95vw' }">
            <FormUpdateStatus v-if="rujukanDipilih" :rujukan="rujukanDipilih" :loading="rujukanStore.loading.updateStatus" :error="rujukanStore.error.updateStatus" @submit="handleUpdateStatus" @cancel="closeUpdateStatus" />
        </Dialog>
    </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { Dialog } from "primevue";
import PageHeader from "@/components/ui/PageHeader.vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import FormUpdateStatus from "@/components/forms/FormUpdateStatus.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { useRujukanStore, LABEL_STATUS } from "@/stores/rujukanStore";
import { formatTanggal } from "@/utils/format.js";
import { debounce } from "@/utils/debounce.js";

const rujukanStore = useRujukanStore();
const search = ref("");
const activeTab = ref("aktif");
const filterStatus = ref("semua");
const showDetail = ref(false);
const showUpdateStatus = ref(false);
const rujukanDipilih = ref(null);
const tabOptions = [{ key: "aktif", label: "Aktif" }, { key: "arsip", label: "Selesai" }];
const warnaHex = { diajukan: "#2563eb", ditangani: "#b45309", selesai: "#475569" };
const warnaBg = { diajukan: "#dbeafe", ditangani: "#fef3c7", selesai: "#e2e8f0" };

const selectedStatus = computed(() => {
    if (filterStatus.value !== "semua") return filterStatus.value;
    return activeTab.value === "aktif" ? "aktif" : "selesai";
});
const updateDialogTitle = computed(() => rujukanDipilih.value?.status === "diajukan" ? "Mulai Tangani Rujukan" : "Selesaikan Rujukan");
const loadData = (page = rujukanStore.pagination.page) => rujukanStore.fetchAllRujukan({ page, search: search.value.trim() || undefined, status: selectedStatus.value });
const reloadFromFirstPage = debounce(() => loadData(1));
watch([search, activeTab, filterStatus], reloadFromFirstPage);

const lihatDetail = async (id) => { showDetail.value = true; await rujukanStore.fetchDetailRujukan(id); };
const bukaUpdateStatus = (item) => {
    rujukanDipilih.value = item;
    rujukanStore.error.updateStatus = null;
    rujukanStore.updateResult = null;
    showUpdateStatus.value = true;
};
const closeUpdateStatus = () => { showUpdateStatus.value = false; rujukanDipilih.value = null; };
const handleUpdateStatus = async (payload) => {
    if (!rujukanDipilih.value || rujukanStore.loading.updateStatus) return;
    const ok = await rujukanStore.updateStatusRujukan(rujukanDipilih.value.id, payload);
    if (ok) { closeUpdateStatus(); await loadData(); }
};
const handleKlikCard = (key) => {
    if (filterStatus.value === key) filterStatus.value = "semua";
    else {
        filterStatus.value = key;
        activeTab.value = key === "selesai" ? "arsip" : "aktif";
    }
};
const selectTab = (key) => { activeTab.value = key; filterStatus.value = "semua"; };
const changePage = (page) => loadData(page);
const waitingDays = (item) => {
    const start = new Date(item.created_at);
    const end = item.completed_at ? new Date(item.completed_at) : new Date();
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) return 0;
    return Math.max(0, Math.floor((end - start) / 86400000));
};
const waitingLabel = (item) => item.status === "selesai" ? `Selesai dalam ${waitingDays(item)} hari` : waitingDays(item) === 0 ? "Hari ini" : `${waitingDays(item)} hari`;

onMounted(() => loadData());
onBeforeUnmount(reloadFromFirstPage.cancel);
</script>

<style scoped>
.card,.stat-card { background: white; border: 1px solid var(--color-card-border); box-shadow: 0 1px 4px rgba(0,0,0,.05); }
.stat-card { padding: 1rem; border-radius: .9rem; font-family: "Poppins",sans-serif; }
.stat-card:hover { border-color: var(--color-green-300); }
.stat-card--active { box-shadow: 0 2px 8px rgba(0,0,0,.08); }
.input-field { background: white; border: 1px solid var(--color-input-border); color: var(--color-text-heading); outline: none; font-family: "Poppins",sans-serif; }
.input-field:focus { border-color: var(--color-green-700); box-shadow: 0 0 0 2px var(--color-focus-ring); }
.tab-btn { padding: .4rem .7rem; border: 0; border-radius: .55rem; background: transparent; color: #64748b; font-size: .72rem; font-weight: 600; cursor: pointer; }
.tab-btn--active { background: var(--color-green-700); color: white; }
.tab-count { margin-left: .3rem; padding: .1rem .35rem; border-radius: 999px; background: rgba(148,163,184,.18); font-size: .62rem; }
.tab-btn--active .tab-count { background: rgba(255,255,255,.22); }
.th-cell { padding: .75rem 1rem; color: #334155; font-size: .7rem; font-weight: 700; letter-spacing: .04em; text-align: left; text-transform: uppercase; white-space: nowrap; }
.table-row { border-bottom: 1px solid #f1f5f9; }
.table-row:hover { background: var(--color-green-50) !important; }
.avatar { display: grid; flex: 0 0 2rem; width: 2rem; height: 2rem; place-items: center; border-radius: 999px; background: var(--color-green-700); color: white; font-size: .7rem; font-weight: 700; }
.waiting-chip { padding: .3rem .55rem; border-radius: .5rem; background: #f1f5f9; color: #475569; font-size: .7rem; font-weight: 600; white-space: nowrap; }
.waiting-chip--long { background: #fee2e2; color: #b91c1c; }
.action-secondary,.action-primary { display: inline-flex; align-items: center; gap: .35rem; padding: .4rem .65rem; border: 0; border-radius: .5rem; font-size: .7rem; font-weight: 700; cursor: pointer; }
.action-secondary { background: #ecfdf5; color: #047857; }
.action-primary { background: #dbeafe; color: #1d4ed8; }
.skeleton { background: linear-gradient(90deg,#f0f0f0 25%,#e0e0e0 50%,#f0f0f0 75%); background-size: 200% 100%; animation: shimmer 1.5s infinite; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
.slide-down-enter-active,.slide-down-leave-active { transition: all .25s ease; }
.slide-down-enter-from,.slide-down-leave-to { opacity: 0; transform: translateY(-8px); }
</style>
