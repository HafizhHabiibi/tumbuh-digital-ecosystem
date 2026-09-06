<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Back Navigation ──────────────────────────────────── -->
        <div class="flex items-center">
            <button
                type="button"
                class="inline-flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-700 bg-white border border-slate-200 hover:bg-slate-50 hover:text-slate-900 transition-all shadow-2xs cursor-pointer"
                @click="router.back()"
            >
                <i class="pi pi-arrow-left text-xs text-slate-400" />
                <span>Kembali ke Data Orang Tua</span>
            </button>
        </div>

        <!-- ─── Loading State ────────────────────────────────────── -->
        <div v-if="kaderStore.loading.orangTuaDetail" class="space-y-4">
            <div class="skeleton h-36 rounded-2xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <!-- ─── Error State ──────────────────────────────────────── -->
        <div
            v-else-if="kaderStore.error.orangTuaDetail"
            class="bg-white p-8 rounded-2xl border border-red-100 flex flex-col items-center gap-3 text-center shadow-xs"
        >
            <i
                class="pi pi-exclamation-circle text-4xl text-red-600"
                aria-hidden="true"
            />
            <p class="text-sm m-0 text-slate-500">
                {{ kaderStore.error.orangTuaDetail }}
            </p>
            <button
                type="button"
                class="btn-primary px-4 py-2 rounded-xl text-xs font-semibold text-white cursor-pointer"
                @click="fetchData"
            >
                Coba Lagi
            </button>
        </div>

        <template v-else-if="kaderStore.orangTuaDetail">
            <!-- ─── Hero Card Info Orang Tua ─────────────────────── -->
            <div
                class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 md:p-6"
            >
                <div
                    class="flex flex-col md:flex-row md:items-center justify-between gap-5"
                >
                    <!-- Sisi Kiri: Avatar & Info Pokok -->
                    <div class="flex items-center gap-4 flex-1 min-w-0">
                        <!-- Avatar Inisial -->
                        <div
                            class="w-16 h-16 rounded-2xl flex items-center justify-center text-2xl font-bold flex-shrink-0 transition-transform shadow-2xs"
                            :style="{
                                backgroundColor: `${avatarColor(kaderStore.orangTuaDetail.nama_lengkap)}18`,
                                color: avatarColor(kaderStore.orangTuaDetail.nama_lengkap),
                                border: `1px solid ${avatarColor(kaderStore.orangTuaDetail.nama_lengkap)}35`,
                            }"
                            aria-hidden="true"
                        >
                            {{
                                kaderStore.orangTuaDetail.nama_lengkap
                                    ?.charAt(0)
                                    .toUpperCase() || "O"
                            }}
                        </div>

                        <!-- Nama & Metadata -->
                        <div class="flex-1 min-w-0">
                            <h1
                                class="text-xl md:text-2xl font-bold text-slate-800 m-0 truncate tracking-tight"
                            >
                                {{ kaderStore.orangTuaDetail.nama_lengkap }}
                            </h1>

                            <!-- Metadata Rows (2 Baris) -->
                            <div class="space-y-1.5 mt-2.5">
                                <!-- Baris 1: NIK & Alamat -->
                                <div
                                    class="flex items-center gap-x-3.5 gap-y-1 flex-wrap text-xs text-slate-500"
                                >
                                    <!-- NIK -->
                                    <span
                                        v-if="kaderStore.orangTuaDetail.nik"
                                        class="inline-flex items-center gap-1.5"
                                    >
                                        <i class="pi pi-id-card text-slate-400 text-xs" />
                                        <span class="text-slate-400">NIK:</span>
                                        <span
                                            class="font-medium font-mono text-slate-700"
                                        >
                                            {{ kaderStore.orangTuaDetail.nik }}
                                        </span>
                                    </span>

                                    <span
                                        v-if="
                                            kaderStore.orangTuaDetail.nik &&
                                            kaderStore.orangTuaDetail.alamat
                                        "
                                        class="text-slate-300 hidden sm:inline"
                                    >
                                        •
                                    </span>

                                    <!-- Alamat -->
                                    <span
                                        v-if="kaderStore.orangTuaDetail.alamat"
                                        class="inline-flex items-center gap-1.5 max-w-md truncate"
                                        :title="kaderStore.orangTuaDetail.alamat"
                                    >
                                        <i
                                            class="pi pi-map-marker text-slate-400 text-xs flex-shrink-0"
                                        />
                                        <span class="text-slate-400">Alamat:</span>
                                        <span class="font-medium text-slate-700 truncate">
                                            {{ kaderStore.orangTuaDetail.alamat }}
                                        </span>
                                    </span>
                                </div>

                                <!-- Baris 2: Email & No. HP -->
                                <div
                                    class="flex items-center gap-x-3.5 gap-y-1 flex-wrap text-xs text-slate-500"
                                >
                                    <!-- Email Akun -->
                                    <span
                                        v-if="kaderStore.orangTuaDetail.email"
                                        class="inline-flex items-center gap-1.5"
                                    >
                                        <i class="pi pi-envelope text-slate-400 text-xs" />
                                        <span class="text-slate-400">Email:</span>
                                        <span class="font-medium text-slate-700">
                                            {{ kaderStore.orangTuaDetail.email }}
                                        </span>
                                    </span>

                                    <span
                                        v-if="
                                            kaderStore.orangTuaDetail.email &&
                                            kaderStore.orangTuaDetail.no_hp
                                        "
                                        class="text-slate-300 hidden sm:inline"
                                    >
                                        •
                                    </span>

                                    <!-- No HP -->
                                    <span
                                        v-if="kaderStore.orangTuaDetail.no_hp"
                                        class="inline-flex items-center gap-1.5"
                                    >
                                        <i class="pi pi-phone text-slate-400 text-xs" />
                                        <span class="text-slate-400">No. HP:</span>
                                        <span class="font-medium text-slate-700">
                                            {{ kaderStore.orangTuaDetail.no_hp }}
                                        </span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Sisi Kanan: Tombol Aksi -->
                    <div
                        class="flex items-center gap-2.5 flex-wrap flex-shrink-0 self-start md:self-center"
                    >
                        <button
                            type="button"
                            class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-xs cursor-pointer"
                            @click="openTambahAnak"
                        >
                            <i class="pi pi-plus text-xs" />
                            <span>Tambah Anak</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- ─── Daftar Anak Asuhan ───────────────────────────── -->
            <div
                class="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden"
            >
                <!-- Header Card -->
                <div
                    class="flex items-center justify-between p-4 border-b border-slate-100 flex-wrap gap-2"
                >
                    <div>
                        <h3 class="text-sm font-bold text-slate-800 m-0">
                            Daftar Anak
                        </h3>
                        <p class="text-xs text-slate-400 mt-1.5 mb-0">
                            Daftar anak yang terdaftar di bawah pengasuhan orang tua ini
                        </p>
                    </div>
                    <div class="flex items-center gap-2">
                        <span
                            class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100"
                        >
                            {{ kaderStore.anakByOrangTua.anak.length }} anak
                        </span>
                    </div>
                </div>

                <!-- Loading anak -->
                <div
                    v-if="kaderStore.loading.anakByOrangTua"
                    class="p-4 space-y-3"
                >
                    <div
                        v-for="i in 3"
                        :key="i"
                        class="skeleton h-14 rounded-xl"
                    />
                </div>

                <!-- Empty State -->
                <div
                    v-else-if="kaderStore.anakByOrangTua.anak.length === 0"
                    class="flex flex-col items-center py-14 gap-2 text-center"
                >
                    <i
                        class="pi pi-users text-4xl text-slate-300"
                        aria-hidden="true"
                    />
                    <p class="text-sm font-medium text-slate-500 m-0">
                        Belum ada anak yang terdaftar untuk orang tua ini
                    </p>
                    <p class="text-xs text-slate-400 m-0">
                        Daftarkan data anak untuk mulai memantau pertumbuhan dan pemberian nutrisi.
                    </p>
                    <button
                        type="button"
                        class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 shadow-xs cursor-pointer mt-2"
                        @click="openTambahAnak"
                    >
                        <i class="pi pi-plus text-xs" />
                        <span>Tambah Anak Sekarang</span>
                    </button>
                </div>

                <!-- Tabel Data Anak -->
                <div v-else class="overflow-x-auto">
                    <table
                        class="w-full text-sm text-left border-collapse"
                        aria-label="Daftar anak"
                    >
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-100">
                                <th class="th-cell">Nama Anak</th>
                                <th class="th-cell">Jenis Kelamin</th>
                                <th class="th-cell hidden md:table-cell">
                                    Tanggal Lahir
                                </th>
                                <th class="th-cell hidden md:table-cell">
                                    Usia
                                </th>
                                <th class="th-cell hidden lg:table-cell">
                                    NIK
                                </th>
                                <th class="th-cell text-center w-20">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 bg-white">
                            <tr
                                v-for="anak in kaderStore.anakByOrangTua.anak"
                                :key="anak.id"
                                class="hover:bg-slate-50/80 transition-colors duration-150 cursor-pointer"
                                @click="lihatDetailAnak(anak.id)"
                            >
                                <!-- Nama & Avatar -->
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
                                            {{
                                                anak.nama
                                                    ?.charAt(0)
                                                    .toUpperCase() || "A"
                                            }}
                                        </div>
                                        <span
                                            class="font-semibold text-slate-800"
                                        >
                                            {{ anak.nama }}
                                        </span>
                                    </div>
                                </td>

                                <!-- Gender Chip -->
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

                                <!-- NIK -->
                                <td
                                    class="px-4 py-3.5 hidden lg:table-cell"
                                >
                                    <span
                                        class="font-mono text-xs text-slate-600 bg-slate-100/70 px-2 py-0.5 rounded border border-slate-200/60 inline-block"
                                    >
                                        {{ anak.nik || "—" }}
                                    </span>
                                </td>

                                <!-- Aksi -->
                                <td class="px-4 py-3.5 text-center" @click.stop>
                                    <button
                                        type="button"
                                        class="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-semibold text-emerald-700 bg-emerald-50 hover:bg-emerald-100 border border-emerald-200/60 transition-colors cursor-pointer"
                                        @click.stop="lihatDetailAnak(anak.id)"
                                    >
                                        <i class="pi pi-eye text-xs" />
                                        <span>Detail</span>
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ─── Dialog Tambah Data Anak ───────────────────────── -->
            <Dialog
                v-model:visible="showTambahAnakModal"
                modal
                :closable="!kaderStore.loading.createAnak"
                header="Tambah Data Anak"
                :style="{ width: '520px', maxWidth: '95vw' }"
            >
                <FormAnak
                    mode="create"
                    :initial-data="{ orang_tua_id: orangTuaId }"
                    :loading="kaderStore.loading.createAnak"
                    :error="kaderStore.error.createAnak"
                    :orang-tua-list="kaderStore.orangTuaOptions"
                    @submit="handleCreateAnak"
                    @cancel="showTambahAnakModal = false"
                />
            </Dialog>
        </template>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useKaderStore } from "@/stores/kaderStore";
import { Dialog } from "primevue";
import FormAnak from "@/components/forms/FormAnak.vue";
import { hitungUsia } from "@/utils/format.js";

const route = useRoute();
const router = useRouter();
const kaderStore = useKaderStore();

const orangTuaId = route.params.id;
const showTambahAnakModal = ref(false);

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

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) => {
    if (!tgl) return "—";
    return new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });
};

/* ── Navigasi ────────────────────────────────────────────────────── */
const lihatDetailAnak = (id) =>
    router.push({ name: "KaderDetailAnak", params: { id } });

/* ── Modal Handlers ──────────────────────────────────────────────── */
const openTambahAnak = () => {
    kaderStore.resetCreateAnak();
    showTambahAnakModal.value = true;
};

const handleCreateAnak = async (payload) => {
    const success = await kaderStore.createAnak(payload);
    if (success) {
        showTambahAnakModal.value = false;
        await Promise.all([
            kaderStore.fetchAnakByOrangTua(orangTuaId),
            kaderStore.fetchAnakOptions(),
        ]);
    }
};

/* ── Fetch Data ──────────────────────────────────────────────────── */
const fetchData = () => {
    Promise.all([
        kaderStore.fetchOrangTuaById(orangTuaId),
        kaderStore.fetchAnakByOrangTua(orangTuaId),
        kaderStore.fetchOrangTuaOptions(),
    ]);
};

onMounted(fetchData);
</script>

<style scoped>
.th-cell {
    text-align: left;
    padding: 0.75rem 1rem;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #1e293b;
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
</style>
