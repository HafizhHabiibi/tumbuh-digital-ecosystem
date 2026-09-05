<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header Halaman (Bersih tanpa tombol sejajar) ──────────── -->
        <PageHeader title="Data Orang Tua" />

        <!-- ─── Error Alert ────────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="kaderStore.error.orangTuaList || kaderStore.error.deleteOrangTua"
                class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm bg-red-50 border border-red-200 text-red-700"
                role="alert"
            >
                <i
                    class="pi pi-exclamation-circle flex-shrink-0"
                    aria-hidden="true"
                />
                <span>{{
                    kaderStore.error.orangTuaList || kaderStore.error.deleteOrangTua
                }}</span>
            </div>
        </Transition>

        <!-- ─── Action Toolbar: Search + Info Badge + Tombol Tambah ── -->
        <div
            class="card p-3.5 rounded-2xl flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between"
        >
            <!-- Search Input -->
            <div class="relative flex-1 max-w-md">
                <i
                    class="pi pi-search absolute left-3.5 top-1/2 -translate-y-1/2 text-sm text-slate-400"
                    aria-hidden="true"
                />
                <input
                    v-model="search"
                    type="search"
                    placeholder="Cari nama, NIK, no. HP, atau alamat..."
                    class="input-field w-full pl-10 pr-9 py-2 rounded-xl text-sm"
                    aria-label="Cari orang tua"
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

            <!-- Group Kanan: Counter Badge + Tombol Tambah Orang Tua -->
            <div
                class="flex items-center gap-3 justify-between md:justify-end flex-wrap"
            >
                <!-- Data Counter Badge -->
                <div
                    class="text-xs font-medium text-slate-500 bg-slate-100/80 px-3 py-2 rounded-xl border border-slate-200/60 flex items-center gap-1.5"
                >
                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                    <span>{{ filteredList.length }} dari {{ kaderStore.totalOrangTua }} data</span>
                </div>

                <!-- Tombol Tambah Orang Tua -->
                <button
                    type="button"
                    class="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-xs cursor-pointer flex-shrink-0"
                    @click="openForm"
                >
                    <i class="pi pi-plus text-xs" aria-hidden="true" />
                    <span>Tambah Orang Tua</span>
                </button>
            </div>
        </div>

        <!-- ─── Tabel Data Orang Tua ───────────────────────────────── -->
        <div class="card rounded-2xl overflow-hidden">
            <!-- Skeleton Loader -->
            <div v-if="kaderStore.loading.orangTuaList" class="p-6 space-y-4">
                <div v-for="i in 6" :key="i" class="skeleton h-14 rounded-xl" />
            </div>

            <!-- Empty State -->
            <div
                v-else-if="filteredList.length === 0"
                class="flex flex-col items-center justify-center py-16 gap-3 text-center"
            >
                <i
                    class="pi pi-users text-4xl text-slate-300"
                    aria-hidden="true"
                />
                <p class="text-sm font-medium m-0 text-slate-500">
                    {{
                        search
                            ? "Tidak ada hasil pencarian yang cocok"
                            : "Belum ada orang tua terdaftar"
                    }}
                </p>
                <button
                    v-if="!search"
                    class="px-4 py-2 rounded-lg text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-700 cursor-pointer mt-1"
                    @click="openForm"
                >
                    Tambah Sekarang
                </button>
            </div>

            <!-- Tabel Data -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar orang tua">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-100">
                            <th class="th-cell">Nama Lengkap</th>
                            <th class="th-cell">NIK</th>
                            <th class="th-cell hidden md:table-cell">
                                No. Handphone
                            </th>
                            <th class="th-cell hidden lg:table-cell">
                                Alamat
                            </th>
                            <th class="th-cell hidden sm:table-cell text-center">
                                Anak Terdaftar
                            </th>
                            <th class="th-cell text-center w-14">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 bg-white">
                        <tr
                            v-for="ot in filteredList"
                            :key="ot.id"
                            class="hover:bg-slate-50/80 transition-colors duration-150 cursor-pointer"
                            @click="lihatDetail(ot.id)"
                        >
                            <!-- Nama Lengkap & Email -->
                            <td class="px-4 py-3.5">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0"
                                        :style="{
                                            backgroundColor: `${avatarColor(ot.nama_lengkap)}18`,
                                            color: avatarColor(ot.nama_lengkap),
                                            border: `1px solid ${avatarColor(ot.nama_lengkap)}35`,
                                        }"
                                        aria-hidden="true"
                                    >
                                        {{
                                            ot.nama_lengkap
                                                .charAt(0)
                                                .toUpperCase()
                                        }}
                                    </div>
                                    <div class="min-w-0">
                                        <span class="font-semibold text-slate-800 block truncate">
                                            {{ ot.nama_lengkap }}
                                        </span>
                                        <span
                                            v-if="ot.email"
                                            class="text-xs text-slate-400 block truncate"
                                        >
                                            {{ ot.email }}
                                        </span>
                                    </div>
                                </div>
                            </td>

                            <!-- NIK -->
                            <td class="px-4 py-3.5">
                                <span
                                    class="font-mono text-xs text-slate-600 bg-slate-100/70 px-2 py-0.5 rounded border border-slate-200/60 inline-block"
                                >
                                    {{ ot.nik || "—" }}
                                </span>
                            </td>

                            <!-- No. HP -->
                            <td class="px-4 py-3.5 hidden md:table-cell text-slate-600">
                                {{ ot.no_hp || "—" }}
                            </td>

                            <!-- Alamat -->
                            <td
                                class="px-4 py-3.5 hidden lg:table-cell text-slate-600 max-w-xs truncate"
                                :title="ot.alamat"
                            >
                                {{ ot.alamat || "—" }}
                            </td>

                            <!-- Anak Terdaftar -->
                            <td class="px-4 py-3.5 hidden sm:table-cell text-center font-medium text-slate-700">
                                {{ getJumlahAnak(ot.id) }}
                            </td>

                            <!-- Aksi (3-titik) -->
                            <td class="px-4 py-3.5 text-center" @click.stop>
                                <button
                                    type="button"
                                    class="w-8 h-8 rounded-lg inline-flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors mx-auto cursor-pointer"
                                    title="Menu Aksi"
                                    aria-label="Menu Aksi"
                                    @click.stop="toggleMenu($event, ot)"
                                >
                                    <i class="pi pi-ellipsis-v text-xs" />
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Paginasi -->
            <PaginationControls
                :pagination="kaderStore.pagination.orangTua"
                :loading="kaderStore.loading.orangTuaList"
                @change-page="changePage"
            />
        </div>

        <!-- ─── Dialog Form Orang Tua ───────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!formLoading"
            :header="editingOrangTua ? 'Edit Data Orang Tua' : 'Tambah Data Orang Tua'"
            :style="{ width: '480px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormOrangTua
                :key="editingOrangTua?.id || 'create'"
                :mode="editingOrangTua ? 'edit' : 'create'"
                :initial-data="editingOrangTua"
                :loading="formLoading"
                :error="formError"
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
import FormOrangTua from "@/components/forms/FormOrangTua.vue";
import PageHeader from "@/components/ui/PageHeader.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { debounce } from "@/utils/debounce.js";

const router = useRouter();
const kaderStore = useKaderStore();

const search = ref("");
const showForm = ref(false);
const editingOrangTua = ref(null);
const deletingOrangTuaId = ref(null);
const actionMenu = ref(null);
const selectedOrangTua = ref(null);

const toggleMenu = (event, ot) => {
    selectedOrangTua.value = ot;
    actionMenu.value.toggle(event);
};

const handleMenuItemClick = (item) => {
    actionMenu.value.hide();
    if (item.command) {
        item.command();
    }
};

const menuItems = computed(() => {
    if (!selectedOrangTua.value) return [];
    return [
        {
            label: "Detail Orang Tua",
            icon: "pi pi-eye",
            command: () => {
                lihatDetail(selectedOrangTua.value.id);
            },
        },
        {
            label: "Edit Data",
            icon: "pi pi-pencil",
            command: () => {
                openEditForm(selectedOrangTua.value);
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
                hapusOrangTua(selectedOrangTua.value);
            },
        },
    ];
});

const formLoading = computed(() =>
    editingOrangTua.value
        ? kaderStore.loading.updateOrangTua
        : kaderStore.loading.createOrangTua,
);
const formError = computed(() =>
    editingOrangTua.value
        ? kaderStore.error.updateOrangTua
        : kaderStore.error.createOrangTua,
);

const filteredList = computed(() => kaderStore.orangTuaList);

/* ── Jumlah Anak per Orang Tua dari Cache Store ──────────────────── */
const anakCountMap = computed(() => {
    const map = {};
    for (const anak of kaderStore.anakOptions) {
        if (anak.orang_tua_id) {
            map[anak.orang_tua_id] = (map[anak.orang_tua_id] || 0) + 1;
        }
    }
    return map;
});

const getJumlahAnak = (orangTuaId) => anakCountMap.value[orangTuaId] || 0;

const loadData = (page = kaderStore.pagination.orangTua.page) =>
    kaderStore.fetchAllOrangTua({
        page,
        search: search.value.trim() || undefined,
    });
const reloadFromFirstPage = debounce(() => loadData(1));
watch(search, reloadFromFirstPage);

/* ── Avatar warna dari nama ──────────────────────────────────────── */
const avatarColors = [
    "#059669",
    "#0284c7",
    "#7c3aed",
    "#db2777",
    "#d97706",
    "#0891b2",
    "#10b981",
    "#6366f1",
];
const avatarColor = (nama) => {
    if (!nama) return avatarColors[0];
    const idx = nama.charCodeAt(0) % avatarColors.length;
    return avatarColors[idx];
};

/* ── Dialog Form ─────────────────────────────────────────────────── */
const openForm = () => {
    editingOrangTua.value = null;
    kaderStore.resetCreateOrangTua();
    showForm.value = true;
};
const openEditForm = (orangTua) => {
    kaderStore.resetUpdateOrangTua();
    editingOrangTua.value = { ...orangTua };
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
    editingOrangTua.value = null;
};

/* ── Submit Form ─────────────────────────────────────────────────── */
const handleSubmit = async (payload) => {
    const success = editingOrangTua.value
        ? await kaderStore.updateOrangTua(editingOrangTua.value.id, payload)
        : await kaderStore.createOrangTua(payload);
    if (success) closeForm();
};

/* ── Navigasi Detail & Aksi ──────────────────────────────────────── */
const lihatDetail = (id) => {
    router.push({ name: "KaderDetailOrangTua", params: { id } });
};

const hapusOrangTua = async (orangTua) => {
    kaderStore.resetDeleteOrangTua();
    const confirmed = window.confirm(
        `Hapus data ${orangTua.nama_lengkap} beserta akun loginnya? Data hanya dapat dihapus jika belum memiliki anak terdaftar.`,
    );
    if (!confirmed) return;

    deletingOrangTuaId.value = orangTua.id;
    await kaderStore.deleteOrangTua(orangTua.id);
    deletingOrangTuaId.value = null;
};

const changePage = (page) => loadData(page);

onMounted(async () => {
    await Promise.all([
        loadData(),
        kaderStore.fetchOrangTuaOptions(),
        kaderStore.fetchAnakOptions(),
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
    color: #1e293b;
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
