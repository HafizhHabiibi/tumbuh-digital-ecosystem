<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header Halaman ─────────────────────────────────────── -->
        <PageHeader title="Data Anak" />

        <!-- ─── Action Toolbar: Search + Filter Pills ──────────────── -->
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
                    class="input-field w-full pl-10 pr-9 py-2 rounded-xl text-sm"
                    type="search"
                    placeholder="Cari nama anak atau orang tua..."
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

            <!-- Segmented Filter Pills -->
            <div class="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0">
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 cursor-pointer"
                    :class="
                        filterJenisKelamin === 'semua'
                            ? 'bg-slate-900 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-slate-200/80'
                    "
                    @click="filterJenisKelamin = 'semua'"
                >
                    Semua
                </button>
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 cursor-pointer"
                    :class="
                        filterJenisKelamin === 'L'
                            ? 'bg-sky-600 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-sky-50 hover:text-sky-700'
                    "
                    @click="filterJenisKelamin = 'L'"
                >
                    <span class="w-1.5 h-1.5 rounded-full bg-sky-400" />
                    Laki-laki
                </button>
                <button
                    type="button"
                    class="px-3 py-1.5 rounded-xl text-xs font-semibold transition-all duration-150 flex items-center gap-1.5 cursor-pointer"
                    :class="
                        filterJenisKelamin === 'P'
                            ? 'bg-rose-600 text-white shadow-xs'
                            : 'bg-slate-100 text-slate-600 hover:bg-rose-50 hover:text-rose-700'
                    "
                    @click="filterJenisKelamin = 'P'"
                >
                    <span class="w-1.5 h-1.5 rounded-full bg-rose-400" />
                    Perempuan
                </button>
            </div>
        </div>

        <!-- ─── Tabel Data Anak ───────────────────────────────────── -->
        <div class="card rounded-2xl overflow-hidden">
            <!-- Skeleton -->
            <div v-if="store.loading.anakList" class="p-6 space-y-4">
                <div v-for="item in 5" :key="item" class="skeleton h-14 rounded-xl" />
            </div>

            <!-- Error -->
            <div
                v-else-if="store.error.anakList"
                class="p-12 flex flex-col items-center gap-3 text-center"
                role="alert"
            >
                <i class="pi pi-exclamation-circle text-4xl text-red-600" />
                <p class="text-sm m-0 text-slate-500">
                    {{ store.error.anakList }}
                </p>
                <button class="btn-primary cursor-pointer px-4 py-2 rounded-lg text-sm font-semibold text-white" @click="loadData()">
                    Coba Lagi
                </button>
            </div>

            <!-- Empty -->
            <div
                v-else-if="filteredAnak.length === 0"
                class="p-16 flex flex-col items-center gap-3 text-center"
            >
                <i class="pi pi-users text-4xl text-slate-300" />
                <p class="text-sm m-0 text-slate-500">
                    {{
                        search || filterJenisKelamin !== "semua"
                            ? "Tidak ada data yang cocok."
                            : "Belum ada anak terdaftar."
                    }}
                </p>
            </div>

            <!-- Table -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar anak Puskesmas">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-100">
                            <th class="th-cell">Nama Anak</th>
                            <th class="th-cell">Jenis Kelamin</th>
                            <th class="th-cell hidden md:table-cell">Tanggal Lahir</th>
                            <th class="th-cell hidden lg:table-cell">Usia</th>
                            <th class="th-cell">Orang Tua</th>
                            <th class="th-cell text-center w-14">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 bg-white">
                        <tr
                            v-for="anak in filteredAnak"
                            :key="anak.id"
                            class="hover:bg-slate-50/80 transition-colors duration-150 cursor-pointer"
                            @click="lihatDetail(anak.id)"
                        >
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
                                    <div>
                                        <div class="font-semibold text-slate-800">
                                            {{ anak.nama }}
                                        </div>
                                        <div class="text-xs md:hidden text-slate-400">
                                            {{ hitungUsia(anak.tanggal_lahir) }}
                                        </div>
                                    </div>
                                </div>
                            </td>
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
                            <td class="px-4 py-3.5 hidden md:table-cell text-slate-600">
                                {{ formatTanggal(anak.tanggal_lahir) }}
                            </td>
                            <td class="px-4 py-3.5 hidden lg:table-cell text-slate-600 font-medium">
                                {{ hitungUsia(anak.tanggal_lahir) }}
                            </td>
                            <td class="px-4 py-3.5 text-slate-700">
                                {{ anak.nama_orang_tua || "—" }}
                            </td>
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
                :pagination="store.pagination"
                :loading="store.loading.anakList"
                @change-page="loadData"
            />
        </div>
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
import PageHeader from "@/components/ui/PageHeader.vue";
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import { useRouter } from "vue-router";
import Menu from "primevue/menu";
import { usePuskesmasStore } from "@/stores/puskesmasStore";
import { formatTanggal, hitungUsia } from "@/utils/format";
import PaginationControls from "@/components/ui/PaginationControls.vue";
import { debounce } from "@/utils/debounce.js";

const router = useRouter();
const store = usePuskesmasStore();
const search = ref("");
const filterJenisKelamin = ref("semua");
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
            label: "Detail Riwayat",
            icon: "pi pi-eye",
            command: () => {
                lihatDetail(selectedAnak.value.id);
            },
        },
    ];
});

const filteredAnak = computed(() => store.anakList);

const loadData = (page = store.pagination.page) =>
    store.fetchAllAnak({
        page,
        search: search.value.trim() || undefined,
        jenis_kelamin:
            filterJenisKelamin.value === "semua"
                ? undefined
                : filterJenisKelamin.value,
    });
const reloadFromFirstPage = debounce(() => loadData(1));
watch([search, filterJenisKelamin], reloadFromFirstPage);

const lihatDetail = (id) =>
    router.push({ name: "PuskesmasDetailAnak", params: { id } });

onMounted(() => loadData());
onBeforeUnmount(reloadFromFirstPage.cancel);
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
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.th-cell {
    padding: 0.75rem 1rem;
    text-align: left;
    color: #1e293b;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}
.btn-primary {
    border: 0;
    background: var(--color-green-700);
    color: white;
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
</style>
