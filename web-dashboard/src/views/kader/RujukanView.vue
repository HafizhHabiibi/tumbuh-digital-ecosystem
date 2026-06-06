<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Rujukan
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Ajukan dan pantau rujukan anak ke puskesmas
                </p>
            </div>
            <button
                class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white"
                :disabled="!anakTerpilihId || rujukanStore.punyaRujukanAktif"
                @click="openForm"
            >
                <i class="pi pi-plus" aria-hidden="true" />
                Ajukan Rujukan
            </button>
        </div>

        <!-- ─── Pilih Anak ───────────────────────────────────────── -->
        <div class="card p-4 rounded-2xl">
            <div class="flex items-center gap-3 flex-wrap">
                <label
                    for="pilih_anak_rujukan"
                    class="text-sm font-semibold flex-shrink-0"
                    style="color: var(--color-text-body)"
                >
                    <i
                        class="pi pi-heart mr-1.5"
                        style="color: var(--color-green-700)"
                        aria-hidden="true"
                    />
                    Pilih Anak
                </label>
                <div class="relative flex-1 min-w-48">
                    <select
                        id="pilih_anak_rujukan"
                        v-model="anakTerpilihId"
                        class="input-field w-full px-4 py-2.5 rounded-xl text-sm appearance-none"
                        @change="onAnakChange"
                    >
                        <option value="">-- Pilih nama anak --</option>
                        <option
                            v-for="anak in kaderStore.anakList"
                            :key="anak.id"
                            :value="anak.id"
                        >
                            {{ anak.nama }} — {{ anak.nama_orang_tua }}
                        </option>
                    </select>
                    <i
                        class="pi pi-chevron-down absolute right-3 top-1/2 -translate-y-1/2 text-xs pointer-events-none"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                </div>
            </div>

            <!-- Warning rujukan aktif -->
            <Transition name="slide-down">
                <div
                    v-if="anakTerpilihId && rujukanStore.punyaRujukanAktif"
                    class="mt-3 flex items-center gap-2 px-3 py-2.5 rounded-xl text-sm"
                    style="
                        background: #fef3c7;
                        border: 1px solid #fcd34d;
                        color: #92400e;
                    "
                    role="alert"
                >
                    <i
                        class="pi pi-exclamation-triangle flex-shrink-0"
                        aria-hidden="true"
                    />
                    <span
                        >Anak ini masih memiliki rujukan aktif yang belum
                        selesai</span
                    >
                </div>
            </Transition>
        </div>

        <!-- ─── Konten (setelah anak dipilih) ───────────────────── -->
        <template v-if="anakTerpilihId">
            <!-- Error -->
            <Transition name="slide-down">
                <div
                    v-if="rujukanStore.error.fetchByAnak"
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
                    <span>{{ rujukanStore.error.fetchByAnak }}</span>
                </div>
            </Transition>

            <!-- ─── Ringkasan status ───────────────────────────── -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                <div
                    v-for="(status, key) in LABEL_STATUS"
                    :key="key"
                    class="card rounded-xl p-3 text-center"
                >
                    <p
                        class="text-2xl font-bold m-0"
                        :style="`color: ${warnaHex[key]}`"
                    >
                        {{ jumlahPerStatus[key] ?? 0 }}
                    </p>
                    <p
                        class="text-xs m-0 mt-0.5"
                        style="color: var(--color-text-muted)"
                    >
                        {{ status }}
                    </p>
                </div>
            </div>

            <!-- ─── Tabel riwayat rujukan ─────────────────────── -->
            <div class="card rounded-2xl overflow-hidden">
                <!-- Skeleton -->
                <div
                    v-if="rujukanStore.loading.fetchByAnak"
                    class="p-4 space-y-3"
                >
                    <div
                        v-for="i in 3"
                        :key="i"
                        class="skeleton h-16 rounded-xl"
                    />
                </div>

                <!-- Empty -->
                <div
                    v-else-if="rujukanStore.riwayatAnak.list.length === 0"
                    class="flex flex-col items-center justify-center py-16 gap-3"
                >
                    <i
                        class="pi pi-send text-4xl"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                    <p
                        class="text-sm m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Belum ada riwayat rujukan untuk anak ini
                    </p>
                    <button
                        class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                        :disabled="rujukanStore.punyaRujukanAktif"
                        @click="openForm"
                    >
                        Ajukan Rujukan
                    </button>
                </div>

                <!-- Tabel -->
                <div v-else class="overflow-x-auto">
                    <table class="w-full text-sm" aria-label="Riwayat rujukan">
                        <thead>
                            <tr
                                style="
                                    background: var(--color-green-50);
                                    border-bottom: 1px solid
                                        var(--color-input-border);
                                "
                            >
                                <th class="th-cell">Tanggal</th>
                                <th class="th-cell">Status</th>
                                <th class="th-cell hidden md:table-cell">
                                    Risiko SAW
                                </th>
                                <th class="th-cell hidden md:table-cell">
                                    Skor
                                </th>
                                <th class="th-cell hidden lg:table-cell">
                                    Ditangani Oleh
                                </th>
                                <th class="th-cell">Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(r, index) in rujukanStore.riwayatAnak
                                    .list"
                                :key="r.id"
                                class="table-row"
                                :style="
                                    index % 2 !== 0
                                        ? 'background: var(--color-green-50)'
                                        : ''
                                "
                            >
                                <td
                                    class="px-4 py-3 text-sm"
                                    style="
                                        color: var(--color-text-body);
                                        white-space: nowrap;
                                    "
                                >
                                    {{ formatTanggal(r.created_at) }}
                                </td>
                                <td class="px-4 py-3">
                                    <span
                                        class="text-xs px-2 py-1 rounded-full font-semibold"
                                        :style="`background: ${warnaBg[r.status]}; color: ${warnaHex[r.status]}`"
                                    >
                                        {{ LABEL_STATUS[r.status] ?? r.status }}
                                    </span>
                                </td>
                                <td class="px-4 py-3 hidden md:table-cell">
                                    <span
                                        class="text-xs px-2 py-1 rounded-full font-medium capitalize"
                                        :style="`background: ${warnaBg[r.kategori_risiko]}; color: ${warnaHex[r.kategori_risiko]}`"
                                    >
                                        {{ r.kategori_risiko }}
                                    </span>
                                </td>
                                <td
                                    class="px-4 py-3 hidden md:table-cell font-mono text-xs"
                                    style="color: var(--color-text-body)"
                                >
                                    {{ r.skor_akhir?.toFixed(4) ?? "—" }}
                                </td>
                                <td
                                    class="px-4 py-3 hidden lg:table-cell text-sm"
                                    style="color: var(--color-text-muted)"
                                >
                                    {{ r.ditangani_oleh ?? "—" }}
                                </td>
                                <td class="px-4 py-3">
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
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </template>

        <!-- State awal -->
        <div
            v-else
            class="card p-12 rounded-2xl flex flex-col items-center justify-center gap-3 text-center"
        >
            <i
                class="pi pi-send text-3xl"
                style="color: var(--color-text-muted)"
                aria-hidden="true"
            />
            <p class="text-sm m-0" style="color: var(--color-text-muted)">
                Pilih anak terlebih dahulu untuk melihat riwayat rujukan
            </p>
        </div>

        <!-- ─── Dialog Detail Rujukan ────────────────────────────── -->
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
            <div v-if="rujukanStore.loading.fetchDetail" class="p-6 space-y-3">
                <div v-for="i in 4" :key="i" class="skeleton h-10 rounded-xl" />
            </div>
            <RujukanDetail
                v-else-if="rujukanStore.rujukanDetail"
                :rujukan="rujukanStore.rujukanDetail"
            />
        </Dialog>

        <!-- ─── Dialog Form Ajukan Rujukan ───────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!rujukanStore.loading.create"
            header="Ajukan Rujukan"
            :style="{ width: '460px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormRujukan
                :loading="rujukanStore.loading.create"
                :error="rujukanStore.error.create"
                :anak-id="anakTerpilihId"
                :riwayat-pengukuran="pengukuranStore.riwayat.list"
                :loading-pengukuran="pengukuranStore.loading.riwayat"
                @submit="handleSubmit"
                @cancel="closeForm"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import { Dialog } from "primevue";
import { useRujukanStore, LABEL_STATUS } from "@/stores/rujukanStore";
import { usePengukuranStore } from "@/stores/pengukuranStore";
import { useKaderStore } from "@/stores/kaderStore";
import RujukanDetail from "@/components/cards/RujukanDetailCard.vue";
import FormRujukan from "@/components/forms/FormRujukan.vue";

const route = useRoute();
const rujukanStore = useRujukanStore();
const kaderStore = useKaderStore();
const pengukuranStore = usePengukuranStore();

const anakTerpilihId = ref("");
const showForm = ref(false);
const showDetail = ref(false);

/* ── Warna status & risiko ───────────────────────────────────────── */
const warnaHex = {
    diajukan: "#2563eb",
    diterima: "#15803d",
    dalam_penanganan: "#d97706",
    selesai: "#6b7280",
    ditolak: "#dc2626",
    rendah: "#15803d",
    sedang: "#d97706",
    tinggi: "#dc2626",
};
const warnaBg = {
    diajukan: "#dbeafe",
    diterima: "#dcfce7",
    dalam_penanganan: "#fef3c7",
    selesai: "#f3f4f6",
    ditolak: "#fee2e2",
    rendah: "#dcfce7",
    sedang: "#fef3c7",
    tinggi: "#fee2e2",
};

/* ── Jumlah per status ───────────────────────────────────────────── */
const jumlahPerStatus = computed(() => {
    const list = rujukanStore.riwayatAnak.list;
    return Object.keys(LABEL_STATUS).reduce((acc, key) => {
        acc[key] = list.filter((r) => r.status === key).length;
        return acc;
    }, {});
});

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

/* ── Ganti anak ──────────────────────────────────────────────────── */
const onAnakChange = () => {
    if (anakTerpilihId.value) {
        rujukanStore.fetchRujukanByAnak(anakTerpilihId.value);
        pengukuranStore.fetchRiwayat(anakTerpilihId.value);
    } else {
        rujukanStore.resetRiwayatAnak();
        pengukuranStore.resetRiwayat();
    }
};

/* ── Detail ──────────────────────────────────────────────────────── */
const lihatDetail = async (id) => {
    showDetail.value = true;
    await rujukanStore.fetchDetailRujukan(id);
};

/* ── Form ────────────────────────────────────────────────────────── */
const openForm = () => {
    rujukanStore.resetCreateState();
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
};

const handleSubmit = async (payload) => {
    const ok = await rujukanStore.createRujukan({
        ...payload,
        anak_id: anakTerpilihId.value,
    });
    if (ok) closeForm();
};

onMounted(() => {
    if (kaderStore.anakList.length === 0) {
        kaderStore.fetchAllAnak().then(() => {
            if (route.query.anakId) {
                anakTerpilihId.value = route.query.anakId;
                onAnakChange();
            }
        });
    } else if (route.query.anakId) {
        anakTerpilihId.value = route.query.anakId;
        onAnakChange();
    }
});
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
