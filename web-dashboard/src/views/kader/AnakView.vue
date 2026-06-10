<template>
    <div class="p-6 max-w-6xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Data Anak
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Daftar seluruh anak yang terdaftar di posyandu
                </p>
            </div>
            <button
                class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white transition-all"
                @click="openForm"
            >
                <i class="pi pi-plus" aria-hidden="true" />
                Tambah Anak
            </button>
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="kaderStore.error.anakList"
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
                <span>{{ kaderStore.error.anakList }}</span>
            </div>
        </Transition>

        <!-- ─── Filter & Stats ───────────────────────────────────── -->
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
                    placeholder="Cari nama anak atau orang tua..."
                    class="input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm"
                    aria-label="Cari anak"
                />
            </div>

            <!-- Filter jenis kelamin -->
            <div
                class="flex gap-1 p-1 rounded-xl"
                style="background: var(--color-green-50)"
            >
                <button
                    v-for="opt in filterOptions"
                    :key="opt.value"
                    class="px-3 py-1.5 rounded-lg text-xs font-medium transition-all"
                    :class="filterJK === opt.value ? 'text-white' : ''"
                    :style="
                        filterJK === opt.value
                            ? 'background: var(--color-green-700)'
                            : 'background: transparent; color: var(--color-text-muted)'
                    "
                    :aria-pressed="filterJK === opt.value"
                    @click="filterJK = opt.value"
                >
                    {{ opt.label }}
                </button>
            </div>

            <!-- Badge total -->
            <span
                class="px-3 py-2 rounded-xl text-sm font-medium flex-shrink-0"
                style="
                    background: var(--color-green-100);
                    color: var(--color-green-700);
                "
            >
                {{ filteredList.length }} dari {{ kaderStore.totalAnak }} anak
            </span>
        </div>

        <!-- ─── Stat mini ─────────────────────────────────────────── -->
        <div class="grid grid-cols-3 gap-3">
            <div class="stat-mini rounded-xl p-3 text-center">
                <p
                    class="text-xl font-bold m-0"
                    style="color: var(--color-green-700)"
                >
                    {{ kaderStore.totalAnak }}
                </p>
                <p
                    class="text-xs m-0 mt-0.5"
                    style="color: var(--color-text-muted)"
                >
                    Total Anak
                </p>
            </div>
            <div class="stat-mini rounded-xl p-3 text-center">
                <p class="text-xl font-bold m-0" style="color: #0284c7">
                    {{ kaderStore.anakLaki.length }}
                </p>
                <p
                    class="text-xs m-0 mt-0.5"
                    style="color: var(--color-text-muted)"
                >
                    Laki-laki
                </p>
            </div>
            <div class="stat-mini rounded-xl p-3 text-center">
                <p class="text-xl font-bold m-0" style="color: #db2777">
                    {{ kaderStore.anakPerempuan.length }}
                </p>
                <p
                    class="text-xs m-0 mt-0.5"
                    style="color: var(--color-text-muted)"
                >
                    Perempuan
                </p>
            </div>
        </div>

        <!-- ─── Tabel ────────────────────────────────────────────── -->
        <div class="table-card rounded-2xl overflow-hidden">
            <!-- Skeleton -->
            <div v-if="kaderStore.loading.anakList" class="p-4 space-y-3">
                <div v-for="i in 6" :key="i" class="skeleton h-14 rounded-xl" />
            </div>

            <!-- Empty state -->
            <div
                v-else-if="filteredList.length === 0"
                class="flex flex-col items-center justify-center py-16 gap-3"
            >
                <i
                    class="pi pi-heart text-4xl"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
                <p
                    class="text-sm font-medium m-0"
                    style="color: var(--color-text-muted)"
                >
                    {{
                        search || filterJK !== "semua"
                            ? "Tidak ada hasil yang cocok"
                            : "Belum ada anak terdaftar"
                    }}
                </p>
                <button
                    v-if="!search && filterJK === 'semua'"
                    class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                    @click="openForm"
                >
                    Tambah Sekarang
                </button>
            </div>

            <!-- Tabel -->
            <div v-else class="overflow-x-auto">
                <table class="w-full text-sm" aria-label="Daftar anak">
                    <thead>
                        <tr
                            style="
                                background: var(--color-green-50);
                                border-bottom: 1px solid
                                    var(--color-input-border);
                            "
                        >
                            <th class="th-cell">Nama Anak</th>
                            <th class="th-cell">JENIS KELAMIN</th>
                            <th class="th-cell hidden md:table-cell">
                                Tanggal Lahir
                            </th>
                            <th class="th-cell hidden md:table-cell">Usia</th>
                            <th class="th-cell hidden lg:table-cell">
                                Orang Tua
                            </th>
                            <th class="th-cell">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="(anak, index) in filteredList"
                            :key="anak.id"
                            class="table-row transition-colors cursor-pointer"
                            :style="
                                index % 2 !== 0
                                    ? 'background: var(--color-green-50)'
                                    : ''
                            "
                            @click="lihatDetail(anak.id)"
                        >
                            <!-- Nama -->
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0"
                                        :style="`background: ${anak.jenis_kelamin === 'L' ? '#0284c7' : '#db2777'}`"
                                        aria-hidden="true"
                                    >
                                        {{ anak.nama.charAt(0).toUpperCase() }}
                                    </div>
                                    <span
                                        class="font-semibold"
                                        style="color: var(--color-text-heading)"
                                        >{{ anak.nama }}</span
                                    >
                                </div>
                            </td>

                            <!-- JK -->
                            <td class="px-4 py-3">
                                <span
                                    class="px-2 py-1 rounded-full text-xs font-semibold"
                                    :style="
                                        anak.jenis_kelamin === 'L'
                                            ? 'background:#dbeafe; color:#1d4ed8'
                                            : 'background:#fce7f3; color:#be185d'
                                    "
                                >
                                    {{
                                        anak.jenis_kelamin === "L"
                                            ? "Laki-laki"
                                            : "Perempuan"
                                    }}
                                </span>
                            </td>

                            <!-- Tanggal Lahir -->
                            <td
                                class="px-4 py-3 hidden md:table-cell"
                                style="color: var(--color-text-body)"
                            >
                                {{ formatTanggal(anak.tanggal_lahir) }}
                            </td>

                            <!-- Usia -->
                            <td class="px-4 py-3 hidden md:table-cell">
                                <span
                                    class="text-sm font-medium"
                                    style="color: var(--color-text-body)"
                                >
                                    {{ hitungUsia(anak.tanggal_lahir) }}
                                </span>
                            </td>

                            <!-- Orang Tua -->
                            <td class="px-4 py-3 hidden lg:table-cell">
                                <p
                                    class="m-0 text-sm"
                                    style="color: var(--color-text-body)"
                                >
                                    {{ anak.nama_orang_tua }}
                                </p>
                            </td>

                            <!-- Aksi -->
                            <td class="px-4 py-3" @click.stop>
                                <button
                                    class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors"
                                    style="
                                        background: var(--color-green-100);
                                        color: var(--color-green-700);
                                    "
                                    :aria-label="`Lihat detail ${anak.nama}`"
                                    @click="lihatDetail(anak.id)"
                                >
                                    <i
                                        class="pi pi-eye text-xs"
                                        aria-hidden="true"
                                    />
                                    Detail
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ─── Dialog Form Tambah Anak ──────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!kaderStore.loading.createAnak"
            header="Tambah Data Anak"
            :style="{ width: '480px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormAnak
                :loading="kaderStore.loading.createAnak"
                :error="kaderStore.error.createAnak"
                :orang-tua-list="kaderStore.orangTuaList"
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
import FormAnak from "@/components/forms/FormAnak.vue";

const router = useRouter();
const kaderStore = useKaderStore();

const search = ref("");
const filterJK = ref("semua");
const showForm = ref(false);

const filterOptions = [
    { label: "Semua", value: "semua" },
    { label: "Laki-laki", value: "L" },
    { label: "Perempuan", value: "P" },
];

/* ── Filter ──────────────────────────────────────────────────────── */
const filteredList = computed(() => {
    let list = kaderStore.anakList;
    if (filterJK.value !== "semua")
        list = list.filter((a) => a.jenis_kelamin === filterJK.value);
    const q = search.value.toLowerCase().trim();
    if (q)
        list = list.filter(
            (a) =>
                a.nama.toLowerCase().includes(q) ||
                a.nama_orang_tua?.toLowerCase().includes(q),
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

/* ── Hitung usia dalam bulan / tahun ────────────────────────────── */
const hitungUsia = (tgl) => {
    const lahir = new Date(tgl);
    const now = new Date();
    const bulan =
        (now.getFullYear() - lahir.getFullYear()) * 12 +
        (now.getMonth() - lahir.getMonth());
    if (bulan < 24) return `${bulan} bln`;
    return `${Math.floor(bulan / 12)} thn ${bulan % 12} bln`;
};

/* ── Dialog ──────────────────────────────────────────────────────── */
const openForm = () => {
    kaderStore.resetCreateAnak();
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
};

const handleSubmit = async (payload) => {
    const ok = await kaderStore.createAnak(payload);
    if (ok) closeForm();
};

/* ── Navigasi ────────────────────────────────────────────────────── */
const lihatDetail = (id) =>
    router.push({ name: "KaderDetailAnak", params: { id } });

onMounted(async () => {
    await Promise.all([
        kaderStore.fetchAllAnak(),
        // Fetch orang tua juga supaya dropdown di FormAnak terisi
        kaderStore.orangTuaList.length === 0 && kaderStore.fetchAllOrangTua(),
    ]);
});
</script>

<style scoped>


.table-card {
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
    color: var(--color-text-muted);
}
.table-row:hover {
    background: var(--color-green-50) !important;
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

.stat-mini {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
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
