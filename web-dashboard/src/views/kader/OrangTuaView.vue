<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Data Orang Tua
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Daftar orang tua / wali yang terdaftar di posyandu
                </p>
            </div>
            <button
                class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white transition-all"
                @click="openForm"
            >
                <i class="pi pi-plus" aria-hidden="true" />
                Tambah Orang Tua
            </button>
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="kaderStore.error.orangTuaList || kaderStore.error.deleteOrangTua"
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
                <span>{{ kaderStore.error.orangTuaList || kaderStore.error.deleteOrangTua }}</span>
            </div>
        </Transition>

        <!-- ─── Search + Stats ───────────────────────────────────── -->
        <div class="flex items-center gap-3 flex-wrap">
            <!-- Search -->
            <div class="relative flex-1 min-w-52">
                <i
                    class="pi pi-search absolute left-3 top-1/2 -translate-y-1/2 text-sm pointer-events-none"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
                <input
                    v-model="search"
                    type="search"
                    placeholder="Cari nama, NIK, atau alamat..."
                    class="w-full pl-9 pr-4 py-2.5 rounded-xl text-sm outline-none transition-all"
                    style="
                        background: white;
                        border: 1px solid var(--color-input-border);
                        color: var(--color-text-heading);
                    "
                    aria-label="Cari orang tua"
                />
            </div>
            <!-- Total badge -->
            <span
                class="px-3 py-2 rounded-xl text-sm font-medium flex-shrink-0"
                style="
                    background: var(--color-green-100);
                    color: var(--color-green-700);
                "
            >
                {{ filteredList.length }} dari
                {{ kaderStore.totalOrangTua }} data
            </span>
        </div>

        <!-- ─── Tabel ────────────────────────────────────────────── -->
        <div class="table-card rounded-2xl overflow-hidden">
            <!-- Loading skeleton -->
            <div v-if="kaderStore.loading.orangTuaList" class="p-4 space-y-3">
                <div v-for="i in 5" :key="i" class="skeleton h-14 rounded-xl" />
            </div>

            <!-- Empty state -->
            <div
                v-else-if="filteredList.length === 0"
                class="flex flex-col items-center justify-center py-16 gap-3"
            >
                <i
                    class="pi pi-users text-4xl"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
                <p
                    class="text-sm font-medium m-0"
                    style="color: var(--color-text-muted)"
                >
                    {{
                        search
                            ? "Tidak ada hasil pencarian"
                            : "Belum ada orang tua terdaftar"
                    }}
                </p>
                <button
                    v-if="!search"
                    class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                    @click="openForm"
                >
                    Tambah Sekarang
                </button>
            </div>

            <!-- Tabel data -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar orang tua">
                    <thead>
                        <tr
                            style="
                                background: var(--color-green-50);
                                border-bottom: 1px solid
                                    var(--color-input-border);
                            "
                        >
                            <th
                                class="text-left px-4 py-3 font-semibold text-xs uppercase tracking-wider"
                                style="color: var(--color-text-muted)"
                            >
                                Nama Lengkap
                            </th>
                            <th
                                class="text-left px-4 py-3 font-semibold text-xs uppercase tracking-wider"
                                style="color: var(--color-text-muted)"
                            >
                                NIK
                            </th>
                            <th
                                class="text-left px-4 py-3 font-semibold text-xs uppercase tracking-wider hidden md:table-cell"
                                style="color: var(--color-text-muted)"
                            >
                                No. HP
                            </th>
                            <th
                                class="text-left px-4 py-3 font-semibold text-xs uppercase tracking-wider hidden lg:table-cell"
                                style="color: var(--color-text-muted)"
                            >
                                Alamat
                            </th>
                            <th
                                class="text-left px-4 py-3 font-semibold text-xs uppercase tracking-wider"
                                style="color: var(--color-text-muted)"
                            >
                                Aksi
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(ot, index) in filteredList"
                            :key="ot.id"
                            class="table-row transition-colors"
                            :style="
                                index % 2 === 0
                                    ? ''
                                    : 'background: var(--color-green-50)'
                            "
                        >
                            <!-- Nama -->
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="avatar flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white"
                                        :style="`background: ${avatarColor(ot.nama_lengkap)}`"
                                        aria-hidden="true"
                                    >
                                        {{
                                            ot.nama_lengkap
                                                .charAt(0)
                                                .toUpperCase()
                                        }}
                                    </div>
                                    <div>
                                        <p
                                            class="font-semibold m-0"
                                            style="
                                                color: var(
                                                    --color-text-heading
                                                );
                                            "
                                        >
                                            {{ ot.nama_lengkap }}
                                        </p>
                                        <p
                                            class="text-xs m-0"
                                            style="
                                                color: var(--color-text-muted);
                                            "
                                        >
                                            {{ ot.email }}
                                        </p>
                                    </div>
                                </div>
                            </td>
                            <!-- NIK -->
                            <td
                                class="px-4 py-3 font-mono text-xs"
                                style="color: var(--color-text-body)"
                            >
                                {{ ot.nik }}
                            </td>
                            <!-- No HP -->
                            <td
                                class="px-4 py-3 hidden md:table-cell"
                                style="color: var(--color-text-body)"
                            >
                                {{ ot.no_hp }}
                            </td>
                            <!-- Alamat -->
                            <td
                                class="px-4 py-3 hidden lg:table-cell max-w-xs truncate"
                                style="color: var(--color-text-body)"
                            >
                                {{ ot.alamat }}
                            </td>
                            <!-- Aksi -->
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-2 flex-wrap">
                                    <button
                                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                        style="
                                            background: var(--color-green-100);
                                            color: var(--color-green-700);
                                        "
                                        :aria-label="`Lihat detail ${ot.nama_lengkap}`"
                                        @click="lihatDetail(ot.id)"
                                    >
                                        <i class="pi pi-eye text-xs" aria-hidden="true" />
                                        Detail
                                    </button>
                                    <button
                                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors bg-amber-100 text-amber-700"
                                        :aria-label="`Edit ${ot.nama_lengkap}`"
                                        @click="openEditForm(ot)"
                                    >
                                        <i class="pi pi-pencil text-xs" aria-hidden="true" />
                                        Edit
                                    </button>
                                    <button
                                        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors bg-red-100 text-red-700 disabled:opacity-60"
                                        :aria-label="`Hapus ${ot.nama_lengkap}`"
                                        :disabled="deletingOrangTuaId === ot.id"
                                        @click="hapusOrangTua(ot)"
                                    >
                                        <i
                                            :class="deletingOrangTuaId === ot.id ? 'pi pi-spin pi-spinner' : 'pi pi-trash'"
                                            class="text-xs"
                                            aria-hidden="true"
                                        />
                                        Hapus
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
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
            :header="editingOrangTua ? 'Edit Orang Tua' : 'Tambah Orang Tua'"
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
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useKaderStore } from "@/stores/kaderStore";
import { Dialog } from "primevue";
import FormOrangTua from "@/components/forms/FormOrangTua.vue";
import PaginationControls from "@/components/ui/PaginationControls.vue";

const router = useRouter();
const kaderStore = useKaderStore();

const search = ref("");
const showForm = ref(false);
const editingOrangTua = ref(null);
const deletingOrangTuaId = ref(null);
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

/* ── Filter pencarian ────────────────────────────────────────────── */
const filteredList = computed(() => {
    const q = search.value.toLowerCase().trim();
    if (!q) return kaderStore.orangTuaList;
    return kaderStore.orangTuaList.filter(
        (ot) =>
            ot.nama_lengkap.toLowerCase().includes(q) ||
            ot.nik.includes(q) ||
            ot.alamat?.toLowerCase().includes(q),
    );
});

/* ── Avatar warna dari nama ──────────────────────────────────────── */
const avatarColors = [
    "#006e1c",
    "#0284c7",
    "#7c3aed",
    "#db2777",
    "#d97706",
    "#0891b2",
    "#059669",
    "#dc2626",
];
const avatarColor = (nama) => {
    const idx = nama.charCodeAt(0) % avatarColors.length;
    return avatarColors[idx];
};

/* ── Dialog ──────────────────────────────────────────────────────── */
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

/* ── Submit form ─────────────────────────────────────────────────── */
const handleSubmit = async (payload) => {
    const success = editingOrangTua.value
        ? await kaderStore.updateOrangTua(editingOrangTua.value.id, payload)
        : await kaderStore.createOrangTua(payload);
    if (success) closeForm();
};

/* ── Navigasi detail ─────────────────────────────────────────────── */
const lihatDetail = (id) => {
    router.push({ name: "KaderDetailOrangTua", params: { id } });
};

const hapusOrangTua = async (orangTua) => {
    kaderStore.resetDeleteOrangTua();
    const confirmed = window.confirm(
        `Hapus ${orangTua.nama_lengkap} beserta akun loginnya? Data hanya dapat dihapus jika belum memiliki anak.`,
    );
    if (!confirmed) return;

    deletingOrangTuaId.value = orangTua.id;
    await kaderStore.deleteOrangTua(orangTua.id);
    deletingOrangTuaId.value = null;
};

const changePage = (page) => kaderStore.fetchAllOrangTua({ page });

onMounted(() =>
    Promise.all([
        kaderStore.fetchAllOrangTua(),
        kaderStore.fetchOrangTuaOptions(),
    ]),
);
</script>

<style scoped>


.table-card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
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

input:focus {
    border-color: var(--color-green-700) !important;
    box-shadow: 0 0 0 2px var(--color-focus-ring);
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
