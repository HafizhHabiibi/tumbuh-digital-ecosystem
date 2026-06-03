<template>
    <div class="p-6 max-w-4xl mx-auto space-y-6">
        <!-- ─── Back button ──────────────────────────────────────── -->
        <button
            class="flex items-center gap-2 text-sm font-medium transition-colors hover:opacity-70"
            style="
                color: var(--color-green-700);
                background: none;
                border: none;
                cursor: pointer;
                padding: 0;
            "
            @click="router.back()"
        >
            <i class="pi pi-arrow-left" aria-hidden="true" />
            Kembali ke Daftar Orang Tua
        </button>

        <!-- ─── Loading ──────────────────────────────────────────── -->
        <div v-if="kaderStore.loading.orangTuaDetail" class="space-y-4">
            <div class="skeleton h-32 rounded-2xl" />
            <div class="skeleton h-64 rounded-2xl" />
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
        <div
            v-else-if="kaderStore.error.orangTuaDetail"
            class="card p-8 rounded-2xl flex flex-col items-center gap-3 text-center"
        >
            <i
                class="pi pi-exclamation-circle text-4xl"
                style="color: #dc2626"
                aria-hidden="true"
            />
            <p class="text-sm m-0" style="color: var(--color-text-muted)">
                {{ kaderStore.error.orangTuaDetail }}
            </p>
            <button
                class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                @click="fetchData"
            >
                Coba Lagi
            </button>
        </div>

        <template v-else-if="kaderStore.orangTuaDetail">
            <!-- ─── Card info orang tua ──────────────────────────── -->
            <div class="card p-5 rounded-2xl">
                <div class="flex items-start gap-4 flex-wrap">
                    <!-- Avatar -->
                    <div
                        class="w-14 h-14 rounded-2xl flex items-center justify-center text-xl font-bold text-white flex-shrink-0"
                        :style="`background: ${avatarColor(kaderStore.orangTuaDetail.nama_lengkap)}`"
                        aria-hidden="true"
                    >
                        {{
                            kaderStore.orangTuaDetail.nama_lengkap
                                .charAt(0)
                                .toUpperCase()
                        }}
                    </div>

                    <!-- Info -->
                    <div class="flex-1 min-w-0">
                        <h1
                            class="text-xl font-bold m-0 mb-1"
                            style="color: var(--color-text-heading)"
                        >
                            {{ kaderStore.orangTuaDetail.nama_lengkap }}
                        </h1>
                        <div class="flex flex-wrap gap-x-4 gap-y-1 text-sm">
                            <span style="color: var(--color-text-muted)">
                                <i
                                    class="pi pi-envelope mr-1 text-xs"
                                    aria-hidden="true"
                                />
                                {{ kaderStore.orangTuaDetail.email }}
                            </span>
                            <span style="color: var(--color-text-muted)">
                                <i
                                    class="pi pi-phone mr-1 text-xs"
                                    aria-hidden="true"
                                />
                                {{ kaderStore.orangTuaDetail.no_hp }}
                            </span>
                        </div>
                        <div
                            class="flex flex-wrap gap-x-4 gap-y-1 text-sm mt-1"
                        >
                            <span style="color: var(--color-text-muted)">
                                <i
                                    class="pi pi-id-card mr-1 text-xs"
                                    aria-hidden="true"
                                />
                                NIK: {{ kaderStore.orangTuaDetail.nik }}
                            </span>
                            <span style="color: var(--color-text-muted)">
                                <i
                                    class="pi pi-map-marker mr-1 text-xs"
                                    aria-hidden="true"
                                />
                                {{ kaderStore.orangTuaDetail.alamat }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ─── Daftar anak ──────────────────────────────────── -->
            <div class="card rounded-2xl overflow-hidden">
                <div class="flex items-center justify-between p-4">
                    <h2
                        class="text-base font-semibold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        <i
                            class="pi pi-heart mr-1.5"
                            style="color: var(--color-green-700)"
                            aria-hidden="true"
                        />
                        Daftar Anak
                    </h2>
                    <span
                        class="text-xs px-2 py-1 rounded-full font-medium"
                        style="
                            background: var(--color-green-100);
                            color: var(--color-green-700);
                        "
                    >
                        {{ kaderStore.anakByOrangTua.anak.length }} anak
                    </span>
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

                <!-- Empty -->
                <div
                    v-else-if="kaderStore.anakByOrangTua.anak.length === 0"
                    class="flex flex-col items-center py-12 gap-3"
                >
                    <i
                        class="pi pi-heart text-4xl"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                    <p
                        class="text-sm m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Belum ada anak terdaftar untuk orang tua ini
                    </p>
                </div>

                <!-- Tabel anak -->
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
                                <th class="th-cell">JK</th>
                                <th class="th-cell hidden md:table-cell">
                                    Tanggal Lahir
                                </th>
                                <th class="th-cell hidden md:table-cell">
                                    Usia
                                </th>
                                <th class="th-cell">Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(anak, index) in kaderStore
                                    .anakByOrangTua.anak"
                                :key="anak.id"
                                class="table-row cursor-pointer"
                                :style="
                                    index % 2 !== 0
                                        ? 'background: var(--color-green-50)'
                                        : ''
                                "
                                @click="lihatDetailAnak(anak.id)"
                            >
                                <!-- Nama -->
                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-3">
                                        <div
                                            class="w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold text-white flex-shrink-0"
                                            :style="`background: ${anak.jenis_kelamin === 'L' ? '#0284c7' : '#db2777'}`"
                                            aria-hidden="true"
                                        >
                                            {{
                                                anak.nama
                                                    .charAt(0)
                                                    .toUpperCase()
                                            }}
                                        </div>
                                        <span
                                            class="font-semibold"
                                            style="
                                                color: var(
                                                    --color-text-heading
                                                );
                                            "
                                        >
                                            {{ anak.nama }}
                                        </span>
                                    </div>
                                </td>

                                <!-- JK -->
                                <td class="px-4 py-3">
                                    <StatusBadge
                                        type="jk"
                                        :value="anak.jenis_kelamin"
                                    />
                                </td>

                                <!-- Tanggal lahir -->
                                <td
                                    class="px-4 py-3 hidden md:table-cell"
                                    style="color: var(--color-text-body)"
                                >
                                    {{ formatTanggal(anak.tanggal_lahir) }}
                                </td>

                                <!-- Usia -->
                                <td
                                    class="px-4 py-3 hidden md:table-cell"
                                    style="color: var(--color-text-body)"
                                >
                                    {{ hitungUsia(anak.tanggal_lahir) }}
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
                                        @click="lihatDetailAnak(anak.id)"
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
        </template>
    </div>
</template>

<script setup>
import { onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useKaderStore } from "@/stores/kaderStore";
import StatusBadge from "@/components/ui/StatusBadge.vue";

const route = useRoute();
const router = useRouter();
const kaderStore = useKaderStore();

const orangTuaId = route.params.id;

/* ── Avatar warna ────────────────────────────────────────────────── */
const avatarColors = [
    "#006e1c",
    "#0284c7",
    "#7c3aed",
    "#db2777",
    "#d97706",
    "#0891b2",
];
const avatarColor = (nama) =>
    avatarColors[nama.charCodeAt(0) % avatarColors.length];

/* ── Format & usia ───────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

const hitungUsia = (tgl) => {
    const bulan = Math.floor(
        (new Date() - new Date(tgl)) / (1000 * 60 * 60 * 24 * 30.44),
    );
    if (bulan < 24) return `${bulan} bulan`;
    return `${Math.floor(bulan / 12)} thn ${bulan % 12} bln`;
};

/* ── Navigasi ────────────────────────────────────────────────────── */
const lihatDetailAnak = (id) =>
    router.push({ name: "KaderDetailAnak", params: { id } });

/* ── Fetch ───────────────────────────────────────────────────────── */
const fetchData = () => {
    Promise.all([
        kaderStore.fetchOrangTuaById(orangTuaId),
        kaderStore.fetchAnakByOrangTua(orangTuaId),
    ]);
};

onMounted(fetchData);
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
</style>
