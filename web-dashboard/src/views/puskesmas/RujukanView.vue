<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div>
            <h1
                class="text-2xl font-bold m-0"
                style="color: var(--color-text-heading)"
            >
                Manajemen Rujukan
            </h1>
            <p class="text-sm mt-1 m-0" style="color: var(--color-text-muted)">
                Kelola dan update status rujukan dari kader posyandu
            </p>
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="rujukanStore.error.fetchAll"
                class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm"
                style="
                    background: #fef2f2;
                    border: 1px solid #fecaca;
                    color: #b91c1c;
                "
                role="alert"
            >
                <i
                    class="pi pi-exclamation-circle flex-shrink-0"
                    aria-hidden="true"
                />
                <span>{{ rujukanStore.error.fetchAll }}</span>
            </div>
        </Transition>

        <!-- ─── Ringkasan status ─────────────────────────────────── -->
        <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
            <div
                v-for="(label, key) in LABEL_STATUS"
                :key="key"
                class="stat-mini rounded-xl p-3 text-center cursor-pointer transition-all"
                :class="{ 'stat-mini--active': filterStatus === key }"
                :style="
                    filterStatus === key
                        ? `border-color: ${warnaHex[key]}; background: ${warnaBg[key]}`
                        : ''
                "
                @click="handleKlikCard(key)"
            >
                <p
                    class="text-2xl font-bold m-0"
                    :style="`color: ${warnaHex[key]}`"
                >
                    {{ rujukanStore.jumlahPerStatus[key] ?? 0 }}
                </p>
                <p
                    class="text-xs m-0 mt-0.5"
                    style="color: var(--color-text-muted)"
                >
                    {{ label }}
                </p>
            </div>
        </div>

        <!-- ─── Filter & Search ──────────────────────────────────── -->
        <div class="flex items-center gap-3 flex-wrap">
            <div class="relative flex-1 min-w-52">
                <i
                    class="pi pi-search absolute left-3 top-1/2 -translate-y-1/2 text-sm pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
                <input
                    v-model="search"
                    type="search"
                    placeholder="Cari nama anak atau orang tua..."
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-label="Cari rujukan"
                />
            </div>
            <!-- Filter tab aktif/arsip -->
            <div
                class="flex gap-1 p-1 rounded-xl"
                style="background: var(--color-green-50)"
            >
                <button
                    v-for="tab in tabOptions"
                    :key="tab.key"
                    class="px-3 py-1.5 rounded-lg text-xs font-medium transition-all"
                    :class="activeTab === tab.key ? 'text-white' : ''"
                    :style="
                        activeTab === tab.key
                            ? 'background: var(--color-green-700)'
                            : 'background: transparent; color: var(--color-text-muted)'
                    "
                    :aria-pressed="activeTab === tab.key"
                    @click="activeTab = tab.key"
                >
                    {{ tab.label }}
                    <span
                        class="ml-1 px-1.5 py-0.5 rounded-full text-[10px] font-bold"
                        :style="
                            activeTab === tab.key
                                ? 'background: rgba(255,255,255,0.25); color: white'
                                : 'background: var(--color-green-100); color: var(--color-green-700)'
                        "
                    >
                        {{
                            tab.key === "aktif"
                                ? rujukanStore.rujukanAktif.length
                                : rujukanStore.rujukanArsip.length
                        }}
                    </span>
                </button>
            </div>
        </div>

        <!-- ─── Tabel rujukan ────────────────────────────────────── -->
        <div class="card rounded-2xl overflow-hidden">
            <!-- Loading -->
            <div v-if="rujukanStore.loading.fetchAll" class="p-4 space-y-3">
                <div v-for="i in 5" :key="i" class="skeleton h-16 rounded-xl" />
            </div>

            <!-- Empty -->
            <div
                v-else-if="rujukanTampil.length === 0"
                class="flex flex-col items-center py-16 gap-3"
            >
                <i
                    class="pi pi-send text-4xl"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
                <p class="text-sm m-0" style="color: var(--color-text-muted)">
                    {{
                        search
                            ? "Tidak ada hasil pencarian"
                            : `Tidak ada rujukan ${activeTab === "aktif" ? "aktif" : "arsip"}`
                    }}
                </p>
            </div>

            <!-- Tabel -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar rujukan">
                    <thead>
                        <tr
                            style="
                                background: var(--color-green-50);
                                border-bottom: 1px solid
                                    var(--color-input-border);
                            "
                        >
                            <th class="th-cell">Anak</th>
                            <th class="th-cell hidden md:table-cell">
                                Orang Tua
                            </th>
                            <th class="th-cell">Status</th>
                            <th class="th-cell hidden md:table-cell">
                                Prioritas
                            </th>
                            <th class="th-cell hidden lg:table-cell">
                                Skor SAW
                            </th>
                            <th class="th-cell hidden lg:table-cell">
                                Tanggal
                            </th>
                            <th class="th-cell">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(r, index) in rujukanTampil"
                            :key="r.id"
                            class="table-row"
                            :style="
                                index % 2 !== 0
                                    ? 'background: var(--color-green-50)'
                                    : ''
                            "
                        >
                            <!-- Nama anak -->
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-2">
                                    <div
                                        class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0"
                                        style="
                                            background: var(--color-green-700);
                                        "
                                        aria-hidden="true"
                                    >
                                        {{
                                            r.nama_anak?.charAt(0).toUpperCase()
                                        }}
                                    </div>
                                    <span
                                        class="font-semibold"
                                        style="color: var(--color-text-heading)"
                                    >
                                        {{ r.nama_anak }}
                                    </span>
                                </div>
                            </td>

                            <!-- Orang tua -->
                            <td
                                class="px-4 py-3 hidden md:table-cell"
                                style="color: var(--color-text-body)"
                            >
                                {{ r.nama_orang_tua }}
                            </td>

                            <!-- Status -->
                            <td class="px-4 py-3">
                                <StatusBadge type="rujukan" :value="r.status" />
                            </td>

                            <!-- Prioritas pemantauan -->
                            <td class="px-4 py-3 hidden md:table-cell">
                                <StatusBadge
                                    type="prioritas"
                                    :value="r.kategori_prioritas"
                                />
                            </td>

                            <!-- Skor SAW -->
                            <td
                                class="px-4 py-3 hidden lg:table-cell font-mono text-xs"
                                style="color: var(--color-text-body)"
                            >
                                {{
                                    formatSkor(r.skor_saw)
                                }}
                            </td>

                            <!-- Tanggal -->
                            <td
                                class="px-4 py-3 hidden lg:table-cell text-xs"
                                style="
                                    color: var(--color-text-muted);
                                    white-space: nowrap;
                                "
                            >
                                {{ formatTanggal(r.created_at) }}
                            </td>

                            <!-- Aksi -->
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-2">
                                    <button
                                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                        style="
                                            background: var(--color-green-100);
                                            color: var(--color-green-700);
                                        "
                                        @click="lihatDetail(r.id)"
                                    >
                                        <i
                                            class="pi pi-eye text-xs"
                                            aria-hidden="true"
                                        />
                                        Detail
                                    </button>
                                    <button
                                        v-if="
                                            rujukanStore.bisaDiupdate(r.status)
                                        "
                                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                        style="
                                            background: #dbeafe;
                                            color: #2563eb;
                                        "
                                        @click="bukaUpdateStatus(r)"
                                    >
                                        <i
                                            class="pi pi-pencil text-xs"
                                            aria-hidden="true"
                                        />
                                        Update
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <PaginationControls
                :pagination="rujukanStore.pagination"
                :loading="rujukanStore.loading.fetchAll"
                @change-page="changePage"
            />
        </div>

        <!-- ─── Dialog Detail ────────────────────────────────────── -->
        <Dialog
            v-model:visible="showDetail"
            modal
            header="Detail Rujukan"
            :style="{ width: '520px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <div v-if="rujukanStore.loading.fetchDetail" class="p-4 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-10 rounded-xl" />
            </div>
            <RujukanDetailCard
                v-else-if="rujukanStore.rujukanDetail"
                :rujukan="rujukanStore.rujukanDetail"
            />
        </Dialog>

        <!-- ─── Dialog Update Status ─────────────────────────────── -->
        <Dialog
            v-model:visible="showUpdateStatus"
            modal
            :closable="!rujukanStore.loading.updateStatus"
            header="Update Status Rujukan"
            :style="{ width: '440px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormUpdateStatus
                v-if="rujukanDipilih"
                :rujukan="rujukanDipilih"
                :loading="rujukanStore.loading.updateStatus"
                :error="rujukanStore.error.updateStatus"
                @submit="handleUpdateStatus"
                @cancel="showUpdateStatus = false"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Dialog } from "primevue";
import { useRujukanStore, LABEL_STATUS } from "@/stores/rujukanStore";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import RujukanDetailCard from "@/components/cards/RujukanDetailCard.vue";
import FormUpdateStatus from "@/components/forms/FormUpdateStatus.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";

const rujukanStore = useRujukanStore();

const search = ref("");
const activeTab = ref("aktif");
const filterStatus = ref("semua");
const showDetail = ref(false);
const showUpdateStatus = ref(false);
const rujukanDipilih = ref(null);

const tabOptions = [
    { key: "aktif", label: "Aktif" },
    { key: "arsip", label: "Arsip" },
];

/* ── Warna status ────────────────────────────────────────────────── */
const warnaHex = {
    diajukan: "#2563eb",
    ditangani: "#d97706",
    selesai: "#6b7280",
};
const warnaBg = {
    diajukan: "#dbeafe",
    ditangani: "#fef3c7",
    selesai: "#f3f4f6",
};

/* ── Filter list ─────────────────────────────────────────────────── */
const rujukanTampil = computed(() => {
    let list =
        activeTab.value === "aktif"
            ? rujukanStore.rujukanAktif
            : rujukanStore.rujukanArsip;

    if (filterStatus.value !== "semua")
        list = list.filter((r) => r.status === filterStatus.value);

    const q = search.value.toLowerCase().trim();
    if (q)
        list = list.filter(
            (r) =>
                r.nama_anak?.toLowerCase().includes(q) ||
                r.nama_orang_tua?.toLowerCase().includes(q),
        );
    return list;
});

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);

/* ── Detail ──────────────────────────────────────────────────────── */
const lihatDetail = async (id) => {
    showDetail.value = true;
    await rujukanStore.fetchDetailRujukan(id);
};

/* ── Update status ───────────────────────────────────────────────── */
const bukaUpdateStatus = (rujukan) => {
    rujukanDipilih.value = rujukan;
    rujukanStore.error.updateStatus = null;
    showUpdateStatus.value = true;
};

const handleUpdateStatus = async (payload) => {
    const ok = await rujukanStore.updateStatusRujukan(
        rujukanDipilih.value.id,
        payload,
    );
    if (ok) showUpdateStatus.value = false;
};

/* ── Klik card status ────────────────────────────────────────────── */
const handleKlikCard = (key) => {
    if (filterStatus.value === key) {
        // Klik lagi → reset
        filterStatus.value = "semua";
    } else {
        filterStatus.value = key;
        // Auto switch tab sesuai status
        const statusArsip = ["selesai"];
        activeTab.value = statusArsip.includes(key) ? "arsip" : "aktif";
    }
};

const changePage = (page) => rujukanStore.fetchAllRujukan({ page });

onMounted(() => rujukanStore.fetchAllRujukan());
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.stat-mini {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
}
.stat-mini:hover {
    border-color: var(--color-green-300);
}
.stat-mini--active {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}
.input-field {
    background: white;
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    font-family: "Poppins", sans-serif;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: var(--color-text-muted);
}
.table-row:hover {
    background: var(--color-green-50) !important;
}
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
    0% {
        background-position: 200% 0;
    }
    100% {
        background-position: -200% 0;
    }
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
