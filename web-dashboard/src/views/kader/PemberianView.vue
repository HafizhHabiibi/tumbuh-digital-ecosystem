<template>
    <div class="p-6 max-w-5xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="flex items-start justify-between gap-4 flex-wrap">
            <div>
                <h1
                    class="text-2xl font-bold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Pemberian
                </h1>
                <p
                    class="text-sm mt-1 m-0"
                    style="color: var(--color-text-muted)"
                >
                    Catat dan pantau vitamin dan pemberian lainnya
                </p>
            </div>
            <button
                class="btn-primary flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold text-white"
                :disabled="!anakTerpilihId"
                @click="openForm"
            >
                <i class="pi pi-plus" aria-hidden="true" />
                Catat Pemberian
            </button>
        </div>

        <!-- ─── Pilih Anak ───────────────────────────────────────── -->
        <div class="card p-4 rounded-2xl">
            <div class="flex items-center gap-3 flex-wrap">
                <label
                    for="pilih_anak"
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
                        id="pilih_anak"
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

                <!-- Info anak terpilih -->
                <div
                    v-if="pemberianStore.riwayat.anak"
                    class="flex items-center gap-2 px-3 py-2 rounded-lg text-xs flex-shrink-0"
                    style="
                        background: var(--color-green-50);
                        color: var(--color-green-700);
                    "
                >
                    <i class="pi pi-user" aria-hidden="true" />
                    <span>{{
                        hitungUsia(pemberianStore.riwayat.anak.tanggal_lahir)
                    }}</span>
                </div>
            </div>
        </div>

        <!-- ─── Konten utama (muncul setelah anak dipilih) ──────── -->
        <template v-if="anakTerpilihId">
            <!-- Error -->
            <Transition name="slide-down">
                <div
                    v-if="pemberianStore.error.riwayat"
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
                    <span>{{ pemberianStore.error.riwayat }}</span>
                </div>
            </Transition>

            <!-- ─── Ringkasan per jenis ────────────────────────── -->
            <div class="grid grid-cols-2 md:grid-cols-3 gap-3">
                <div
                    v-for="jenis in JENIS_VALID"
                    :key="jenis"
                    class="card-jenis rounded-xl p-3 cursor-pointer transition-all"
                    :class="{ 'card-jenis--active': filterAktif === jenis }"
                    @click="setFilter(jenis)"
                >
                    <div class="flex items-center gap-2 mb-1">
                        <i
                            :class="`pi ${ikonJenis[jenis]} text-sm`"
                            :style="`color: ${filterAktif === jenis ? 'var(--color-green-700)' : 'var(--color-text-muted)'}`"
                            aria-hidden="true"
                        />
                        <span
                            class="text-xs font-semibold truncate"
                            :style="`color: ${filterAktif === jenis ? 'var(--color-green-700)' : 'var(--color-text-body)'}`"
                        >
                            {{ LABEL_JENIS[jenis] }}
                        </span>
                    </div>
                    <p
                        class="text-2xl font-bold m-0"
                        :style="`color: ${filterAktif === jenis ? 'var(--color-green-700)' : 'var(--color-text-heading)'}`"
                    >
                        {{ pemberianStore.jumlahPerJenis[jenis] ?? 0 }}
                    </p>
                </div>
            </div>

            <!-- ─── Filter tab ────────────────────────────────── -->
            <div
                class="flex gap-1 flex-wrap p-1 rounded-xl w-fit"
                style="background: var(--color-green-50)"
            >
                <button
                    class="filter-btn px-3 py-1.5 rounded-lg text-xs font-medium transition-all"
                    :class="{ 'filter-btn--active': filterAktif === 'semua' }"
                    @click="setFilter('semua')"
                >
                    Semua
                </button>
                <button
                    v-for="jenis in JENIS_VALID"
                    :key="jenis"
                    class="filter-btn px-3 py-1.5 rounded-lg text-xs font-medium transition-all"
                    :class="{ 'filter-btn--active': filterAktif === jenis }"
                    @click="setFilter(jenis)"
                >
                    {{ LABEL_JENIS[jenis] }}
                </button>
            </div>

            <!-- ─── Tabel riwayat ─────────────────────────────── -->
            <div class="card rounded-2xl overflow-hidden">
                <!-- Skeleton -->
                <div
                    v-if="pemberianStore.loading.riwayat"
                    class="p-4 space-y-3"
                >
                    <div
                        v-for="i in 4"
                        :key="i"
                        class="skeleton h-14 rounded-xl"
                    />
                </div>

                <!-- Empty -->
                <div
                    v-else-if="riwayatTampil.length === 0"
                    class="flex flex-col items-center justify-center py-16 gap-3"
                >
                    <i
                        class="pi pi-inbox text-4xl"
                        style="color: var(--color-text-muted)"
                        aria-hidden="true"
                    />
                    <p
                        class="text-sm m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Belum ada
                        {{
                            filterAktif !== "semua"
                                ? LABEL_JENIS[filterAktif]
                                : "pemberian"
                        }}
                    </p>
                    <button
                        class="btn-primary px-4 py-2 rounded-lg text-sm font-semibold text-white"
                        @click="openForm"
                    >
                        Catat Sekarang
                    </button>
                </div>

                <!-- Tabel -->
                <div v-else class="overflow-x-auto">
                    <table
                        class="w-full text-sm"
                        aria-label="Pemberian"
                    >
                        <thead>
                            <tr
                                style="
                                    background: var(--color-green-50);
                                    border-bottom: 1px solid
                                        var(--color-input-border);
                                "
                            >
                                <th class="th-cell">Tanggal</th>
                                <th class="th-cell">Jenis</th>
                                <th class="th-cell">Nama Item</th>
                                <th class="th-cell hidden md:table-cell">
                                    Dosis
                                </th>
                                <th class="th-cell hidden lg:table-cell">
                                    Dicatat Oleh
                                </th>
                                <th class="th-cell hidden lg:table-cell">
                                    Keterangan
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="(item, index) in riwayatTampil"
                                :key="item.id"
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
                                    {{ formatTanggal(item.tanggal_pemberian) }}
                                </td>
                                <td class="px-4 py-3">
                                    <span
                                        class="text-xs px-2 py-1 rounded-full font-medium capitalize"
                                        :style="`background: ${warnaBgJenis[item.jenis]}; color: ${warnaJenis[item.jenis]}`"
                                    >
                                        {{
                                            LABEL_JENIS[item.jenis] ??
                                            item.jenis
                                        }}
                                    </span>
                                </td>
                                <td
                                    class="px-4 py-3 font-medium"
                                    style="color: var(--color-text-heading)"
                                >
                                    {{ item.nama_item }}
                                </td>
                                <td
                                    class="px-4 py-3 hidden md:table-cell"
                                    style="color: var(--color-text-body)"
                                >
                                    {{ item.dosis ?? "—" }}
                                </td>
                                <td
                                    class="px-4 py-3 hidden lg:table-cell text-sm"
                                    style="color: var(--color-text-muted)"
                                >
                                    {{ item.dicatat_oleh }}
                                </td>
                                <td
                                    class="px-4 py-3 hidden lg:table-cell text-sm max-w-xs truncate"
                                    style="color: var(--color-text-muted)"
                                >
                                    {{ item.keterangan ?? "—" }}
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </template>

        <!-- ─── State awal: belum pilih anak ────────────────────── -->
        <div
            v-else
            class="card p-12 rounded-2xl flex flex-col items-center justify-center gap-3 text-center"
        >
            <i
                class="pi pi-arrow-up text-3xl"
                style="color: var(--color-text-muted)"
                aria-hidden="true"
            />
            <p class="text-sm m-0" style="color: var(--color-text-muted)">
                Pilih anak terlebih dahulu untuk melihat pemberian
            </p>
        </div>

        <!-- ─── Dialog Form ──────────────────────────────────────── -->
        <Dialog
            v-model:visible="showForm"
            modal
            :closable="!pemberianStore.loading.create"
            header="Catat Pemberian"
            :style="{ width: '460px', maxWidth: '95vw' }"
            :pt="{
                header: {
                    style: 'border-bottom: 1px solid var(--color-input-border)',
                },
            }"
        >
            <FormPemberian
                :loading="pemberianStore.loading.create"
                :error="pemberianStore.error.create"
                :anak-id="anakTerpilihId"
                :anak-list="kaderStore.anakList"
                @submit="handleSubmit"
                @cancel="closeForm"
            />
        </Dialog>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { Dialog } from "primevue";
import {
    usePemberianStore,
    JENIS_VALID,
    LABEL_JENIS,
} from "@/stores/pemberianStore";
import { useKaderStore } from "@/stores/kaderStore";
import FormPemberian from "@/components/forms/FormPemberian.vue";

const pemberianStore = usePemberianStore();
const kaderStore = useKaderStore();

const anakTerpilihId = ref("");
const filterAktif = ref("semua");
const showForm = ref(false);

/* ── Ikon per jenis ──────────────────────────────────────────────── */
const ikonJenis = {
    vitamin_a: "pi-sun",
    obat_cacing: "pi-heart",
    pmt: "pi-apple",
};

/* ── Warna badge jenis ───────────────────────────────────────────── */
const warnaJenis = {
    vitamin_a: "#d97706",
    obat_cacing: "#15803d",
    pmt: "#7c3aed",
};
const warnaBgJenis = {
    vitamin_a: "#fef3c7",
    obat_cacing: "#dcfce7",
    pmt: "#ede9fe",
};

/* ── Riwayat yang ditampilkan sesuai filter ──────────────────────── */
const riwayatTampil = computed(() => {
    if (filterAktif.value === "semua") return pemberianStore.riwayat.list;
    return pemberianStore.riwayat.list.filter(
        (r) => r.jenis === filterAktif.value,
    );
});

/* ── Format tanggal ──────────────────────────────────────────────── */
const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
    });

/* ── Hitung usia ─────────────────────────────────────────────────── */
const hitungUsia = (tgl) => {
    const bulan = Math.floor(
        (new Date() - new Date(tgl)) / (1000 * 60 * 60 * 24 * 30.44),
    );
    if (bulan < 24) return `${bulan} bulan`;
    return `${Math.floor(bulan / 12)} thn ${bulan % 12} bln`;
};

/* ── Ganti anak ──────────────────────────────────────────────────── */
const onAnakChange = () => {
    filterAktif.value = "semua";
    if (anakTerpilihId.value) pemberianStore.fetchRiwayat(anakTerpilihId.value);
    else pemberianStore.resetRiwayat();
};

/* ── Ganti filter ────────────────────────────────────────────────── */
const setFilter = (jenis) => {
    filterAktif.value = jenis;
};

/* ── Dialog ──────────────────────────────────────────────────────── */
const openForm = () => {
    pemberianStore.resetCreateState();
    showForm.value = true;
};
const closeForm = () => {
    showForm.value = false;
};

const handleSubmit = async (payload) => {
    const ok = await pemberianStore.createRiwayat({
        ...payload,
        anak_id: anakTerpilihId.value,
    });
    if (ok) closeForm();
};

onMounted(() => {
    if (kaderStore.anakList.length === 0) kaderStore.fetchAllAnak();
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

/* ─── Kartu jenis ─────────────────────────────────────────────── */
.card-jenis {
    background: white;
    border: 1px solid var(--color-card-border);
}
.card-jenis:hover {
    border-color: var(--color-green-300);
}
.card-jenis--active {
    border-color: var(--color-green-600) !important;
    background: var(--color-green-50);
}

/* ─── Filter tab ──────────────────────────────────────────────── */
.filter-btn {
    color: var(--color-text-muted);
    background: transparent;
    border: none;
    cursor: pointer;
}
.filter-btn:hover {
    color: var(--color-green-700);
    background: rgba(0, 110, 28, 0.06);
}
.filter-btn--active {
    background: var(--color-green-700) !important;
    color: white !important;
}

/* ─── Tabel ───────────────────────────────────────────────────── */
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
