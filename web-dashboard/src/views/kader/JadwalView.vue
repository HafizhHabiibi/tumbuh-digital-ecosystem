<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Jadwal Posyandu
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Kelola dan pantau jadwal kegiatan posyandu
                </p>
            </div>
            <button
                class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white"
                @click="openForm"
            >
                <i class="pi pi-plus" aria-hidden="true" />
                Tambah Jadwal
            </button>
        </div>

        <!-- ─── Error ────────────────────────────────────────────── -->
        <Transition name="slide-down">
            <div
                v-if="jadwalStore.error.fetchAll"
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
                <span>{{ jadwalStore.error.fetchAll }}</span>
            </div>
        </Transition>

        <!-- ─── Jadwal Terdekat ──────────────────────────────────── -->
        <div
            v-if="jadwalStore.jadwalTerdekat"
            class="card-terdekat p-5 rounded-2xl"
        >
            <div class="flex items-start justify-between gap-3 flex-wrap">
                <div>
                    <p
                        class="text-xs font-semibold uppercase tracking-wider m-0 mb-1"
                        style="color: rgba(255, 255, 255, 0.7)"
                    >
                        <i
                            class="pi pi-calendar-clock mr-1"
                            aria-hidden="true"
                        />
                        Jadwal Terdekat
                    </p>
                    <h2 class="text-xl font-bold text-white m-0">
                        {{
                            formatTanggalPanjang(
                                jadwalStore.jadwalTerdekat.tanggal,
                            )
                        }}
                    </h2>
                    <p class="text-sm text-white/80 m-0 mt-1">
                        {{ jadwalStore.jadwalTerdekat.waktu_mulai }} –
                        {{ jadwalStore.jadwalTerdekat.waktu_selesai }} WIB
                    </p>
                </div>
                <div class="text-right">
                    <p class="text-xs text-white/70 m-0 mb-1">Lokasi</p>
                    <p class="text-sm font-semibold text-white m-0">
                        {{ jadwalStore.jadwalTerdekat.lokasi }}
                    </p>
                    <p class="text-xs text-white/60 m-0 mt-1">
                        {{ sisaHari(jadwalStore.jadwalTerdekat.tanggal) }}
                    </p>
                </div>
            </div>
        </div>

        <!-- ─── Filter tab ───────────────────────────────────────── -->
        <div
            class="flex gap-1 p-1 rounded-xl w-fit"
            style="background: var(--color-green-50)"
        >
            <button
                v-for="tab in filterTabs"
                :key="tab.key"
                class="flex items-center gap-1.5 px-4 py-2 rounded-lg text-xs font-medium transition-all"
                :class="activeFilter === tab.key ? 'text-white' : ''"
                :style="
                    activeFilter === tab.key
                        ? 'background: var(--color-green-700)'
                        : 'background: transparent; color: var(--color-text-muted)'
                "
                :aria-pressed="activeFilter === tab.key"
                @click="activeFilter = tab.key"
            >
                {{ tab.label }}
                <span
                    class="px-1.5 py-0.5 rounded-full text-[10px] font-bold"
                    :style="
                        activeFilter === tab.key
                            ? 'background: rgba(255,255,255,0.25); color: white'
                            : 'background: var(--color-green-100); color: var(--color-green-700)'
                    "
                >
                    {{
                        tab.key === "mendatang"
                            ? jadwalStore.jadwalMendatang.length
                            : jadwalStore.jadwalLewat.length
                    }}
                </span>
            </button>
        </div>

        <!-- ─── Loading skeleton ─────────────────────────────────── -->
        <div v-if="jadwalStore.loading.fetchAll" class="space-y-3">
            <div v-for="i in 4" :key="i" class="skeleton h-24 rounded-2xl" />
        </div>

        <!-- ─── Empty state ──────────────────────────────────────── -->
        <div
            v-else-if="jadwalTampil.length === 0"
            class="card p-12 rounded-2xl flex flex-col items-center gap-3 text-center"
        >
            <i
                class="pi pi-calendar text-4xl"
                style="color: var(--color-text-muted)"
                aria-hidden="true"
            />
            <p class="text-sm m-0" style="color: var(--color-text-muted)">
                {{
                    activeFilter === "mendatang"
                        ? "Belum ada jadwal mendatang"
                        : "Belum ada jadwal yang lewat"
                }}
            </p>
            <button
                v-if="activeFilter === 'mendatang'"
                class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                @click="openForm"
            >
                Buat Jadwal Sekarang
            </button>
        </div>

        <!-- ─── List jadwal ──────────────────────────────────────── -->
        <div v-else class="space-y-3">
            <div
                v-for="jadwal in jadwalTampil"
                :key="jadwal.id"
                class="card p-4 rounded-2xl flex items-center gap-4 flex-wrap cursor-pointer transition-all hover:shadow-md"
                @click="lihatDetail(jadwal.id)"
            >
                <!-- Tanggal kotak -->
                <div
                    class="date-box rounded-xl p-3 text-center flex-shrink-0 w-16"
                    :style="
                        isLewat(jadwal.tanggal)
                            ? 'background: #f3f4f6'
                            : 'background: var(--color-green-100)'
                    "
                >
                    <p
                        class="text-xl font-bold m-0 leading-none"
                        :style="
                            isLewat(jadwal.tanggal)
                                ? 'color: #6b7280'
                                : 'color: var(--color-green-700)'
                        "
                    >
                        {{ new Date(jadwal.tanggal).getDate() }}
                    </p>
                    <p
                        class="text-xs m-0 mt-0.5 font-medium"
                        :style="
                            isLewat(jadwal.tanggal)
                                ? 'color: #9ca3af'
                                : 'color: var(--color-green-600)'
                        "
                    >
                        {{ bulanSingkat(jadwal.tanggal) }}
                    </p>
                </div>

                <!-- Info jadwal -->
                <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 flex-wrap mb-1">
                        <h3
                            class="text-sm font-semibold m-0 truncate"
                            style="color: var(--color-text-heading)"
                        >
                            {{ jadwal.lokasi }}
                        </h3>
                        <span
                            v-if="isLewat(jadwal.tanggal)"
                            class="text-xs px-2 py-0.5 rounded-full font-medium"
                            style="background: #f3f4f6; color: #6b7280"
                        >
                            Selesai
                        </span>
                        <span
                            v-else
                            class="text-xs px-2 py-0.5 rounded-full font-medium"
                            style="
                                background: var(--color-green-100);
                                color: var(--color-green-700);
                            "
                        >
                            Mendatang
                        </span>
                    </div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        <i class="pi pi-clock mr-1" aria-hidden="true" />
                        {{ jadwal.waktu_mulai }} –
                        {{ jadwal.waktu_selesai }} WIB
                        <span class="mx-2">•</span>
                        <i class="pi pi-user mr-1" aria-hidden="true" />
                        {{ jadwal.dibuat_oleh }}
                    </p>
                    <p
                        v-if="jadwal.keterangan"
                        class="text-xs m-0 mt-1 truncate"
                        style="color: var(--color-text-muted)"
                    >
                        {{ jadwal.keterangan }}
                    </p>
                </div>

                <!-- Arrow -->
                <i
                    class="pi pi-chevron-right text-sm flex-shrink-0"
                    style="color: var(--color-text-muted)"
                    aria-hidden="true"
                />
            </div>
        </div>

        <!-- ─── Dialog Detail ────────────────────────────────────── -->
        <Dialog
            v-model:visible="showDetail"
            modal
            header="Detail Jadwal"
            :style="{ width: '440px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <div v-if="jadwalStore.loading.fetchDetail" class="p-4 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-10 rounded-xl" />
            </div>
            <div v-else-if="jadwalStore.jadwalDetail" class="space-y-4 pt-4">
                <div class="grid grid-cols-2 gap-3">
                    <div
                        v-for="item in detailItems"
                        :key="item.label"
                        class="rounded-xl p-3"
                        style="
                            background: var(--color-green-50);
                            border: 1px solid var(--color-input-border);
                        "
                    >
                        <p
                            class="text-xs m-0"
                            style="color: var(--color-text-muted)"
                        >
                            {{ item.label }}
                        </p>
                        <p
                            class="text-sm font-semibold m-0 mt-0.5"
                            style="color: var(--color-text-heading)"
                        >
                            {{ item.value }}
                        </p>
                    </div>
                </div>
                <div
                    v-if="jadwalStore.jadwalDetail.keterangan"
                    class="rounded-xl p-3"
                    style="
                        background: var(--color-green-50);
                        border: 1px solid var(--color-input-border);
                    "
                >
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Keterangan
                    </p>
                    <p
                        class="text-sm m-0 mt-0.5"
                        style="color: var(--color-text-body)"
                    >
                        {{ jadwalStore.jadwalDetail.keterangan }}
                    </p>
                </div>
            </div>
        </Dialog>

        <!-- ─── Dialog Form Buat Jadwal ──────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!jadwalStore.loading.create"
            header="Buat Jadwal Posyandu"
            :style="{ width: '460px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormJadwal
                :loading="jadwalStore.loading.create"
                :error="jadwalStore.error.create"
                @submit="handleSubmit"
                @cancel="closeForm"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Dialog } from "primevue";
import { useJadwalStore } from "@/stores/jadwalStore";
import FormJadwal from "@/components/forms/FormJadwal.vue";

const jadwalStore = useJadwalStore();

const activeFilter = ref("mendatang");
const showDetail = ref(false);
const showForm = ref(false);

const filterTabs = [
    { key: "mendatang", label: "Mendatang" },
    { key: "lewat", label: "Lewat" },
];

/* ── Jadwal yang ditampilkan sesuai filter ───────────────────────── */
const jadwalTampil = computed(() =>
    activeFilter.value === "mendatang"
        ? jadwalStore.jadwalMendatang
        : jadwalStore.jadwalLewat,
);

/* ── Cek apakah tanggal sudah lewat ────────────────────────────── */
const _now = new Date();
const today = `${_now.getFullYear()}-${String(_now.getMonth() + 1).padStart(2, '0')}-${String(_now.getDate()).padStart(2, '0')}`;
const isLewat = (tgl) => tgl < today;

/* ── Sisa hari (perbandingan string tanggal, aman lintas timezone) ── */
const sisaHari = (tgl) => {
    if (tgl === today) return "Hari ini!";
    // Hitung selisih hari dengan membandingkan date-only string
    const tglDate = new Date(tgl + "T00:00:00");
    const todayDate = new Date(today + "T00:00:00");
    const diff = Math.round((tglDate - todayDate) / (1000 * 60 * 60 * 24));
    if (diff === 1) return "Besok";
    return `${diff} hari lagi`;
};

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggalPanjang = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    });

const bulanSingkat = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", { month: "short" });

/* ── Detail items untuk dialog ───────────────────────────────────── */
const detailItems = computed(() => {
    const j = jadwalStore.jadwalDetail;
    if (!j) return [];
    return [
        { label: "Tanggal", value: formatTanggalPanjang(j.tanggal) },
        { label: "Waktu", value: `${j.waktu_mulai} – ${j.waktu_selesai} WIB` },
        { label: "Lokasi", value: j.lokasi },
        { label: "Dibuat Oleh", value: j.dibuat_oleh },
    ];
});

/* ── Dialog ──────────────────────────────────────────────────────── */
const lihatDetail = async (id) => {
    showDetail.value = true;
    await jadwalStore.fetchDetailJadwal(id);
};

const openForm = () => {
    jadwalStore.resetCreateState();
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
};

const handleSubmit = async (payload) => {
    const ok = await jadwalStore.createJadwal(payload);
    if (ok) closeForm();
};

onMounted(() => jadwalStore.fetchAllJadwal());
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.card-terdekat {
    background: linear-gradient(
        135deg,
        var(--color-green-600),
        var(--color-green-800)
    );
    box-shadow: 0 4px 16px var(--color-shadow-green);
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
