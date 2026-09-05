<template>
    <div class="space-y-4" aria-live="polite">
        <!-- Banner Sukses -->
        <div
            class="flex items-start gap-3.5 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 shadow-2xs"
            role="status"
        >
            <div class="w-8 h-8 rounded-xl bg-emerald-500 text-white flex items-center justify-center shrink-0 shadow-2xs">
                <i class="pi pi-check text-sm font-bold" aria-hidden="true" />
            </div>
            <div>
                <p class="text-sm font-bold m-0 text-emerald-900">Pengukuran Berhasil Disimpan</p>
                <p class="text-xs mt-1 mb-0 text-emerald-700 leading-relaxed">
                    Hasil antropometri dan Z-Score telah dihitung secara otomatis oleh sistem serta dicatat dalam riwayat anak.
                </p>
            </div>
        </div>

        <!-- Kartu Identitas & Metrik Utama -->
        <section class="card p-5 rounded-2xl space-y-4">
            <header class="flex items-start justify-between flex-wrap gap-3 pb-3 border-b border-slate-100">
                <div class="flex items-center gap-3">
                    <div
                        class="w-11 h-11 rounded-2xl flex items-center justify-center font-bold text-sm shrink-0 shadow-2xs"
                        :class="anak?.jenis_kelamin === 'L' ? 'bg-blue-100 text-blue-700' : 'bg-rose-100 text-rose-700'"
                    >
                        {{ getInitials(anak?.nama) }}
                    </div>
                    <div>
                        <div class="flex items-center gap-2 flex-wrap">
                            <h2 class="text-base font-bold text-slate-800 m-0">
                                {{ anak?.nama || "Anak Terpilih" }}
                            </h2>
                            <span
                                v-if="anak?.jenis_kelamin"
                                class="text-[10px] px-2 py-0.5 rounded-md font-semibold"
                                :class="anak?.jenis_kelamin === 'L' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-rose-50 text-rose-700 border border-rose-200'"
                            >
                                {{ anak?.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}
                            </span>
                        </div>
                        <p class="text-xs text-slate-500 mt-0.5 mb-0">
                            Orang tua: <span class="font-medium text-slate-700">{{ anak?.nama_orang_tua || "—" }}</span>
                            <template v-if="result.usia_bulan !== null && result.usia_bulan !== undefined">
                                • Usia saat ukur: <span class="font-medium text-slate-700">{{ result.usia_bulan }} bulan</span>
                            </template>
                        </p>
                    </div>
                </div>
                <span class="inline-flex items-center gap-1.5 text-xs px-3 py-1 rounded-xl font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                    <i class="pi pi-calendar text-[11px]" />
                    {{ formatTanggal(result.tanggal_ukur) }}
                </span>
            </header>

            <!-- Metrik Pengukuran -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                <div class="stat-box rounded-xl p-3 text-center">
                    <p class="text-xs text-slate-500 m-0">Berat Badan</p>
                    <p class="text-lg font-bold text-slate-800 mt-1 mb-0">
                        {{ formatUkuran(result.berat_badan) }}
                        <span class="text-xs font-normal text-slate-500">kg</span>
                    </p>
                </div>
                <div class="stat-box rounded-xl p-3 text-center">
                    <p class="text-xs text-slate-500 m-0">Panjang / TB</p>
                    <p class="text-lg font-bold text-slate-800 mt-1 mb-0">
                        {{ formatUkuran(result.tinggi_badan) }}
                        <span class="text-xs font-normal text-slate-500">cm</span>
                    </p>
                </div>
                <div class="stat-box rounded-xl p-3 text-center">
                    <p class="text-xs text-slate-500 m-0">Lingkar Kepala</p>
                    <p class="text-lg font-bold text-slate-800 mt-1 mb-0">
                        {{ formatNullable(result.lingkar_kepala) }}
                        <span v-if="result.lingkar_kepala != null" class="text-xs font-normal text-slate-500">cm</span>
                    </p>
                </div>
                <div class="stat-box rounded-xl p-3 text-center">
                    <p class="text-xs text-slate-500 m-0">LiLA</p>
                    <p class="text-lg font-bold text-slate-800 mt-1 mb-0">
                        {{ formatNullable(result.lingkar_lengan) }}
                        <span v-if="result.lingkar_lengan != null" class="text-xs font-normal text-slate-500">cm</span>
                    </p>
                </div>
            </div>

            <!-- IMT & Prioritas -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
                <div class="rounded-xl p-3 bg-slate-50 border border-slate-200/80 flex items-center justify-between">
                    <div>
                        <p class="text-[11px] text-slate-400 font-medium m-0">Indeks Massa Tubuh (IMT)</p>
                        <p class="text-base font-bold text-slate-800 mt-0.5 mb-0">
                            {{ formatNullable(result.nilai_imt, 1) }}
                            <span class="text-xs font-normal text-slate-500">kg/m²</span>
                        </p>
                    </div>
                    <i class="pi pi-chart-bar text-slate-400 text-lg" />
                </div>
                <div class="rounded-xl p-3 bg-slate-50 border border-slate-200/80 flex items-center justify-between">
                    <div>
                        <p class="text-[11px] text-slate-400 font-medium m-0">Prioritas Pemantauan</p>
                        <div class="mt-1">
                            <StatusBadge type="prioritas" :value="result.prioritas_pemantauan?.kategori" />
                        </div>
                    </div>
                    <i class="pi pi-flag text-slate-400 text-lg" />
                </div>
            </div>
        </section>

        <!-- Status Antropometri & Z-Score -->
        <section class="card p-5 rounded-2xl space-y-3.5">
            <div class="flex items-center justify-between">
                <div>
                    <h3 class="text-sm font-bold text-slate-800 m-0">
                        Status Antropometri & Z-Score
                    </h3>
                    <p class="text-xs text-slate-400 mt-0.5 mb-0">
                        Berdasarkan standar WHO Child Growth Standards & Permenkes RI
                    </p>
                </div>
            </div>

            <div class="divide-y divide-slate-100 rounded-xl border border-slate-100 overflow-hidden">
                <div
                    v-for="item in anthropometryResults"
                    :key="item.label"
                    class="p-3 bg-white hover:bg-slate-50/70 transition-colors flex items-center justify-between gap-3"
                >
                    <div class="min-w-0">
                        <div class="flex items-center gap-2">
                            <span class="text-xs font-bold text-slate-800">{{ item.shortLabel }}</span>
                            <span class="text-[11px] text-slate-400 truncate">{{ item.label }}</span>
                        </div>
                    </div>
                    <div class="flex items-center gap-2.5 shrink-0 flex-wrap justify-end">
                        <span class="text-xs font-mono font-semibold px-2 py-0.5 rounded-md bg-slate-100 text-slate-700">
                            Z {{ formatZScore(item.value) }}
                        </span>
                        <StatusBadge type="antropometri" :value="item.status" />
                    </div>
                </div>
            </div>
        </section>

        <!-- Analisis Risiko SAW -->
        <section class="card p-5 rounded-2xl space-y-3">
            <div class="flex items-start justify-between">
                <div>
                    <h3 class="text-sm font-bold text-slate-800 m-0">
                        Analisis Risiko Kekurangan Gizi
                    </h3>
                    <p class="text-[11px] text-slate-400 mt-0.5 mb-0">
                        Metode Simple Additive Weighting (SAW)
                    </p>
                </div>
                <div class="text-right">
                    <span class="text-base font-bold text-slate-800 font-mono">
                        {{ formatSkor(result.skor_saw) }}
                    </span>
                    <p class="text-[10px] text-slate-400 m-0">Skor Akhir</p>
                </div>
            </div>

            <!-- Progress Bar -->
            <div class="space-y-1.5">
                <div class="h-2.5 rounded-full overflow-hidden bg-slate-100 border border-slate-200/60 p-0.5">
                    <div
                        class="h-full rounded-full transition-all duration-700"
                        :style="`width: ${sawPercentage}%; background: ${sawColor}`"
                    />
                </div>
                <div class="flex justify-between text-[10px] text-slate-400">
                    <span>Rendah (0.00)</span>
                    <span>Sedang (0.50)</span>
                    <span>Tinggi (1.00)</span>
                </div>
            </div>

            <p class="text-[11px] text-slate-500 m-0 leading-relaxed bg-slate-50 p-2.5 rounded-xl border border-slate-100">
                <i class="pi pi-info-circle text-slate-400 mr-1" />
                Skor mendekati 1,00 menunjukkan anak memerlukan prioritas pemantauan gizi lebih intensif. Skor ini menjadi acuan rekomendasi intervensi posyandu.
            </p>
        </section>
    </div>
</template>

<script setup>
import { computed } from "vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import { formatUkuran, formatTanggal } from "@/utils/format.js";

const props = defineProps({
    result: { type: Object, required: true },
    anak: { type: Object, default: null },
});

const getInitials = (name) => {
    if (!name) return "A";
    const parts = name.trim().split(" ");
    return parts.length >= 2
        ? (parts[0][0] + parts[1][0]).toUpperCase()
        : name.slice(0, 2).toUpperCase();
};

const anthropometryResults = computed(() => [
    {
        label: "Berat Badan menurut Umur",
        shortLabel: "BB/U",
        value: props.result.zscore_bbu,
        status: props.result.status_bbu,
    },
    {
        label: "Tinggi Badan menurut Umur",
        shortLabel: "TB/U",
        value: props.result.zscore_tbu,
        status: props.result.status_tbu,
    },
    {
        label: "Berat Badan menurut Tinggi Badan",
        shortLabel: "BB/TB",
        value: props.result.zscore_bbtb,
        status: props.result.status_bbtb,
    },
    {
        label: "Indeks Massa Tubuh menurut Umur",
        shortLabel: "IMT/U",
        value: props.result.zscore_imtu,
        status: props.result.status_imtu,
    },
]);

const colorsByPriority = {
    rendah: "#16a34a",
    sedang: "#d97706",
    tinggi: "#dc2626",
};

const sawColor = computed(
    () => colorsByPriority[props.result.prioritas_pemantauan?.kategori || props.result.kategori_prioritas] ?? "#64748b",
);

const sawPercentage = computed(() => {
    const value = Number(props.result.skor_saw);
    if (!Number.isFinite(value)) return 0;
    return Math.min(100, Math.max(0, value * 100));
});

const formatNullable = (value, decimals = 2) => {
    if (value === null || value === undefined || value === "") return "—";
    const number = Number(value);
    return Number.isFinite(number) ? number.toFixed(decimals) : "—";
};

const formatZScore = (value) => {
    if (value === null || value === undefined) return "—";
    const number = Number(value);
    if (!Number.isFinite(number)) return "—";
    return number > 0 ? `+${number.toFixed(2)}` : number.toFixed(2);
};

const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border, #e2e8f0);
    box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.05);
}
.stat-box {
    background: #f8fafc;
    border: 1px solid #f1f5f9;
}
</style>
