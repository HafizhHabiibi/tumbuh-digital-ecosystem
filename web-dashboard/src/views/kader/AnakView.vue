<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header Halaman (Bersih tanpa tombol sejajar) ──────────── -->
        <PageHeader title="Data Anak" />

        <!-- ─── 3 Kartu Ringkasan Gender Interaktif ─────────────────── -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <!-- Total Anak -->
            <button
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    filterJK === 'semua'
                        ? 'border-emerald-500 bg-emerald-50/70 ring-2 ring-emerald-500/20 shadow-xs'
                        : 'border-slate-100 bg-white hover:border-emerald-200 hover:bg-emerald-50/30'
                "
                @click="filterJK = 'semua'"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold text-emerald-700 flex items-center gap-1.5"
                    >
                        <span class="w-2 h-2 rounded-full bg-emerald-500" />
                        Total Anak Terdaftar
                    </span>
                    <i class="pi pi-users text-emerald-600 text-sm" />
                </div>
                <div
                    class="text-2xl font-extrabold text-slate-900 tracking-tight"
                >
                    {{ kaderStore.totalAnak }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
                <p class="text-[11px] font-medium text-emerald-700/80 mt-1">
                    Semua balita dalam pantauan posyandu
                </p>
            </button>

            <!-- Laki-laki -->
            <button
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    filterJK === 'L'
                        ? 'border-sky-500 bg-sky-50/70 ring-2 ring-sky-500/20 shadow-xs'
                        : 'border-slate-100 bg-white hover:border-sky-200 hover:bg-sky-50/30'
                "
                @click="toggleFilterJK('L')"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold text-sky-700 flex items-center gap-1.5"
                    >
                        <span class="w-2 h-2 rounded-full bg-sky-500" />
                        Laki-laki
                    </span>
                    <i class="pi pi-user text-sky-600 text-sm" />
                </div>
                <div
                    class="text-2xl font-extrabold text-slate-900 tracking-tight"
                >
                    {{ kaderStore.anakLaki.length }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
                <p class="text-[11px] font-medium text-sky-700/80 mt-1">
                    Klik untuk filter balita laki-laki
                </p>
            </button>

            <!-- Perempuan -->
            <button
                type="button"
                class="p-4 rounded-2xl border text-left transition-all duration-200 cursor-pointer"
                :class="
                    filterJK === 'P'
                        ? 'border-rose-500 bg-rose-50/70 ring-2 ring-rose-500/20 shadow-xs'
                        : 'border-slate-100 bg-white hover:border-rose-200 hover:bg-rose-50/30'
                "
                @click="toggleFilterJK('P')"
            >
                <div class="flex items-center justify-between mb-2">
                    <span
                        class="text-xs font-bold text-rose-700 flex items-center gap-1.5"
                    >
                        <span class="w-2 h-2 rounded-full bg-rose-500" />
                        Perempuan
                    </span>
                    <i class="pi pi-user text-rose-600 text-sm" />
                </div>
                <div
                    class="text-2xl font-extrabold text-slate-900 tracking-tight"
                >
                    {{ kaderStore.anakPerempuan.length }}
                    <span class="text-xs font-normal text-slate-400">anak</span>
                </div>
                <p class="text-[11px] font-medium text-rose-700/80 mt-1">
                    Klik untuk filter balita perempuan
                </p>
            </button>
        </div>

        <!-- ─── Error Alert ────────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="kaderStore.error.anakList || kaderStore.error.deleteAnak"
                class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700"
                role="alert"
            >
                <i
                    class="pi pi-exclamation-circle flex-shrink-0"
                    aria-hidden="true"
                />
                <span>{{
                    kaderStore.error.anakList || kaderStore.error.deleteAnak
                }}</span>
            </div>
        </Transition>

        <!-- ─── Action Toolbar: Search + Filter Pills + Tombol Tambah Anak ─ -->
        <div
            class="card p-3.5 rounded-2xl flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between"
        >
            <!-- Search -->
            <div class="relative flex-1 max-w-md">
                <i
                    class="pi pi-search absolute left-3.5 top-1/2 -translate-y-1/2 text-sm text-slate-400"
                    aria-hidden="true"
                />
                <input
                    v-model="search"
                    type="search"
                    placeholder="Cari nama anak atau orang tua..."
                    class="input-field w-full pl-10 pr-9 py-2 rounded-xl text-sm"
                    aria-label="Cari anak"
                />
                <button
                    v-if="search"
                    type="button"
                    class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1 cursor-pointer"
                    aria-label="Hapus pencarian"
                    @click="search = ''"
                >
                    <i class="pi pi-times text-xs" />
                </button>
            </div>

            <!-- Group Kanan: Filter Pills + Tombol Tambah Anak -->
            <div
                class="flex items-center gap-3 justify-between md:justify-end flex-wrap"
            >
                <!-- Segmented Filter Pills -->
                <div class="flex items-center gap-1.5">
                    <button
                        type="button"
                        class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 cursor-pointer"
                        :class="
                            filterJK === 'semua'
                                ? 'bg-slate-900 text-white shadow-xs'
                                : 'bg-slate-100 text-slate-600 hover:bg-slate-200/80'
                        "
                        @click="filterJK = 'semua'"
                    >
                        Semua
                    </button>
                    <button
                        type="button"
                        class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 cursor-pointer"
                        :class="
                            filterJK === 'L'
                                ? 'bg-sky-600 text-white shadow-xs'
                                : 'bg-slate-100 text-slate-600 hover:bg-sky-50 hover:text-sky-700'
                        "
                        @click="filterJK = 'L'"
                    >
                        <span class="w-1.5 h-1.5 rounded-full bg-sky-400" />
                        Laki-laki
                    </button>
                    <button
                        type="button"
                        class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 cursor-pointer"
                        :class="
                            filterJK === 'P'
                                ? 'bg-rose-600 text-white shadow-xs'
                                : 'bg-slate-100 text-slate-600 hover:bg-rose-50 hover:text-rose-700'
                        "
                        @click="filterJK = 'P'"
                    >
                        <span class="w-1.5 h-1.5 rounded-full bg-rose-400" />
                        Perempuan
                    </button>
                </div>

                <!-- Tombol Tambah Anak (Berpindah ke Action Toolbar) -->
                <button
                    type="button"
                    class="btn-primary flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold text-white transition-all shadow-xs cursor-pointer flex-shrink-0"
                    @click="openForm"
                >
                    <i class="pi pi-plus text-xs" aria-hidden="true" />
                    <span>Tambah Anak</span>
                </button>
            </div>
        </div>

        <!-- ─── Tabel Data Anak ───────────────────────────────────── -->
        <div class="card rounded-2xl overflow-hidden">
            <!-- Skeleton -->
            <div v-if="kaderStore.loading.anakList" class="p-6 space-y-4">
                <div v-for="i in 6" :key="i" class="skeleton h-14 rounded-xl" />
            </div>

            <!-- Empty state -->
            <div
                v-else-if="filteredList.length === 0"
                class="flex flex-col items-center justify-center py-16 gap-3 text-center"
            >
                <i
                    class="pi pi-heart text-4xl text-slate-300"
                    aria-hidden="true"
                />
                <p class="text-sm font-medium m-0 text-slate-500">
                    {{
                        search || filterJK !== "semua"
                            ? "Tidak ada hasil yang cocok"
                            : "Belum ada anak terdaftar"
                    }}
                </p>
                <button
                    v-if="!search && filterJK === 'semua'"
                    class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white cursor-pointer mt-1"
                    @click="openForm"
                >
                    Tambah Sekarang
                </button>
            </div>

            <!-- Tabel -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar anak">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-100">
                            <th class="th-cell">Nama Anak</th>
                            <th class="th-cell">Jenis Kelamin</th>
                            <th class="th-cell hidden md:table-cell">
                                Tanggal Lahir
                            </th>
                            <th class="th-cell hidden md:table-cell">Usia</th>
                            <th class="th-cell hidden lg:table-cell">
                                Orang Tua
                            </th>
                            <th class="th-cell text-center w-14">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 bg-white">
                        <tr
                            v-for="anak in filteredList"
                            :key="anak.id"
                            class="hover:bg-slate-50/80 transition-colors duration-150 cursor-pointer"
                            @click="lihatDetail(anak.id)"
                        >
                            <!-- Nama -->
                            <td class="px-4 py-3.5">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0"
                                        :class="
                                            anak.jenis_kelamin === 'L'
                                                ? 'bg-sky-50 text-sky-700 border border-sky-200'
                                                : 'bg-rose-50 text-rose-700 border border-rose-200'
                                        "
                                        aria-hidden="true"
                                    >
                                        {{ anak.nama.charAt(0).toUpperCase() }}
                                    </div>
                                    <span class="font-semibold text-slate-800">
                                        {{ anak.nama }}
                                    </span>
                                </div>
                            </td>

                            <!-- JK -->
                            <td class="px-4 py-3.5">
                                <span
                                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                                    :class="
                                        anak.jenis_kelamin === 'L'
                                            ? 'bg-sky-50 text-sky-700 border border-sky-200/80'
                                            : 'bg-rose-50 text-rose-700 border border-rose-200/80'
                                    "
                                >
                                    <span
                                        class="w-1.5 h-1.5 rounded-full"
                                        :class="
                                            anak.jenis_kelamin === 'L'
                                                ? 'bg-sky-500'
                                                : 'bg-rose-500'
                                        "
                                    />
                                    {{
                                        anak.jenis_kelamin === "L"
                                            ? "Laki-laki"
                                            : "Perempuan"
                                    }}
                                </span>
                            </td>

                            <!-- Tanggal Lahir -->
                            <td
                                class="px-4 py-3.5 hidden md:table-cell text-slate-600"
                            >
                                {{ formatTanggal(anak.tanggal_lahir) }}
                            </td>

                            <!-- Usia -->
                            <td
                                class="px-4 py-3.5 hidden md:table-cell text-slate-600 font-medium"
                            >
                                {{ hitungUsia(anak.tanggal_lahir) }}
                            </td>

                            <!-- Orang Tua -->
                            <td
                                class="px-4 py-3.5 hidden lg:table-cell text-slate-700"
                            >
                                {{ anak.nama_orang_tua || "—" }}
                            </td>

                            <!-- Aksi -->
                            <td class="px-4 py-3.5 text-center" @click.stop>
                                <button
                                    type="button"
                                    class="w-8 h-8 rounded-lg inline-flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors mx-auto cursor-pointer"
                                    title="Menu Aksi"
                                    aria-label="Menu Aksi"
                                    @click.stop="toggleMenu($event, anak)"
                                >
                                    <i class="pi pi-ellipsis-v text-xs" />
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <PaginationControls
                :pagination="kaderStore.pagination.anak"
                :loading="kaderStore.loading.anakList"
                @change-page="changePage"
            />
        </div>

        <!-- ─── Dialog Form Anak ────────────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!formLoading"
            :header="editingAnak ? 'Edit Data Anak' : 'Tambah Data Anak'"
            :style="{ width: '480px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormAnak
                :key="editingAnak?.id || 'create'"
                :mode="editingAnak ? 'edit' : 'create'"
                :initial-data="editingAnak"
                :loading="formLoading"
                :error="formError"
                :orang-tua-list="kaderStore.orangTuaOptions"
                @submit="handleSubmit"
                @cancel="closeForm"
            />
        </Dialog>

        <!-- ─── Action Menu Popover ────────────────────────────────── -->
        <Menu ref="actionMenu" :model="menuItems" :popup="true">
            <template #item="{ item }">
                <button
                    v-if="!item.separator"
                    type="button"
                    class="w-full flex items-center gap-2.5 px-3 py-2 text-xs font-medium rounded-lg transition-colors cursor-pointer text-left"
                    :class="
                        item.danger
                            ? 'text-red-600 hover:bg-red-50'
                            : 'text-slate-700 hover:bg-slate-100'
                    "
                    @click="handleMenuItemClick(item)"
                >
                    <i
                        :class="item.icon"
                        class="text-xs"
                        :style="item.danger ? 'color: #dc2626' : 'color: #64748b'"
                    />
                    <span>{{ item.label }}</span>
                </button>
                <div v-else class="my-1 border-t border-slate-100" />
            </template>
        </Menu>
    </div>
</template>

<script setup>
import { ref, computed, onBeforeUnmount, onMounted, watch } from "vue";
import { useRouter } from "vue-router";
import { useKaderStore } from "@/stores/kaderStore";
import { Dialog } from "primevue";
import Menu from "primevue/menu";
import FormAnak from "@/components/forms/FormAnak.vue";
import PageHeader from "@/components/ui/PageHeader.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { hitungUsia } from "@/utils/format.js";
import { debounce } from "@/utils/debounce.js";

const router = useRouter();
const kaderStore = useKaderStore();

const search = ref("");
const filterJK = ref("semua");
const showForm = ref(false);
const editingAnak = ref(null);
const deletingAnakId = ref(null);
const actionMenu = ref(null);
const selectedAnak = ref(null);

const toggleMenu = (event, anak) => {
    selectedAnak.value = anak;
    actionMenu.value.toggle(event);
};

const handleMenuItemClick = (item) => {
    actionMenu.value.hide();
    if (item.command) {
        item.command();
    }
};

const menuItems = computed(() => {
    if (!selectedAnak.value) return [];
    return [
        {
            label: "Detail Balita",
            icon: "pi pi-eye",
            command: () => {
                lihatDetail(selectedAnak.value.id);
            },
        },
        {
            label: "Edit Data",
            icon: "pi pi-pencil",
            command: () => {
                openEditForm(selectedAnak.value);
            },
        },
        {
            separator: true,
        },
        {
            label: "Hapus Data",
            icon: "pi pi-trash",
            danger: true,
            command: () => {
                hapusAnak(selectedAnak.value);
            },
        },
    ];
});

const formLoading = computed(() =>
    editingAnak.value
        ? kaderStore.loading.updateAnak
        : kaderStore.loading.createAnak,
);
const formError = computed(() =>
    editingAnak.value
        ? kaderStore.error.updateAnak
        : kaderStore.error.createAnak,
);

/* ── Toggle Filter JK dari Kartu Stat ───────────────────────────── */
const toggleFilterJK = (val) => {
    filterJK.value = filterJK.value === val ? "semua" : val;
};

const filteredList = computed(() => kaderStore.anakList);

const loadData = (page = kaderStore.pagination.anak.page) =>
    kaderStore.fetchAllAnak({
        page,
        search: search.value.trim() || undefined,
        jenis_kelamin:
            filterJK.value === "semua" ? undefined : filterJK.value,
    });
const reloadFromFirstPage = debounce(() => loadData(1));
watch([search, filterJK], reloadFromFirstPage);

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

/* ── Dialog ──────────────────────────────────────────────────────── */
const openForm = () => {
    editingAnak.value = null;
    kaderStore.resetCreateAnak();
    showForm.value = true;
};
const openEditForm = (anak) => {
    kaderStore.resetUpdateAnak();
    editingAnak.value = { ...anak };
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
    editingAnak.value = null;
};

const handleSubmit = async (payload) => {
    const ok = editingAnak.value
        ? await kaderStore.updateAnak(editingAnak.value.id, payload)
        : await kaderStore.createAnak(payload);
    if (ok) closeForm();
};

/* ── Navigasi ────────────────────────────────────────────────────── */
const lihatDetail = (id) =>
    router.push({ name: "KaderDetailAnak", params: { id } });

const hapusAnak = async (anak) => {
    kaderStore.resetDeleteAnak();
    const confirmed = window.confirm(
        `Hapus data ${anak.nama}? Data hanya dapat dihapus jika belum memiliki riwayat pengukuran atau pemberian.`,
    );
    if (!confirmed) return;

    deletingAnakId.value = anak.id;
    await kaderStore.deleteAnak(anak.id);
    deletingAnakId.value = null;
};

const changePage = (page) => loadData(page);

onMounted(async () => {
    await Promise.all([
        loadData(),
        kaderStore.fetchAnakOptions(),
        kaderStore.fetchOrangTuaOptions(),
    ]);
});

onBeforeUnmount(reloadFromFirstPage.cancel);
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #64748b;
}

.input-field {
    background: white;
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
    font-family: "Poppins", sans-serif;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
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
