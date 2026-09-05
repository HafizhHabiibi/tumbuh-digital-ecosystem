<template>
    <div class="space-y-4" aria-live="polite">
        <div
            class="flex items-start gap-3 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900"
            role="status"
        >
            <i class="pi pi-check-circle mt-0.5 text-emerald-600" aria-hidden="true" />
            <div>
                <p class="text-sm font-bold m-0">Pengukuran berhasil disimpan</p>
                <p class="text-xs mt-1 mb-0 text-emerald-700">
                    Hasil antropometri telah dihitung dan masuk ke riwayat anak.
                </p>
            </div>
        </div>

        <section class="card p-5 rounded-2xl space-y-4">
            <header class="flex items-start justify-between flex-wrap gap-3">
                <div>
                    <p class="text-[11px] font-semibold uppercase tracking-wider text-slate-400 m-0">
                        Hasil Pengukuran
                    </p>
                    <h2 class="text-base font-bold text-slate-800 mt-1 mb-0">
                        {{ anak?.nama || "Anak terpilih" }}
                    </h2>
                    <p v-if="anak?.nama_orang_tua" class="text-xs text-slate-500 mt-1 mb-0">
                        Orang tua: {{ anak.nama_orang_tua }}
                    </p>
                </div>
                <span class="text-xs px-2.5 py-1 rounded-full font-semibold bg-emerald-100 text-emerald-700">
                    {{ formatTanggal(result.tanggal_ukur) }}
                </span>
            </header>

            <div class="flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-500">
                <span v-if="anak?.jenis_kelamin">
                    {{ anak.jenis_kelamin === "L" ? "Laki-laki" : "Perempuan" }}
                </span>
                <span v-if="result.usia_bulan !== null && result.usia_bulan !== undefined">
                    Usia {{ result.usia_bulan }} bulan
                </span>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <MetricBox label="Berat Badan" :value="formatUkuran(result.berat_badan)" unit="kg" />
                <MetricBox label="Tinggi Badan" :value="formatUkuran(result.tinggi_badan)" unit="cm" />
                <MetricBox label="Lingkar Kepala" :value="formatNullable(result.lingkar_kepala)" :unit="result.lingkar_kepala == null ? '' : 'cm'" />
                <MetricBox label="Lingkar Lengan Atas" :value="formatNullable(result.lingkar_lengan)" :unit="result.lingkar_lengan == null ? '' : 'cm'" />
                <MetricBox label="Indeks Massa Tubuh" :value="formatNullable(result.nilai_imt, 1)" unit="kg/m²" class="sm:col-span-2" />
            </div>

            <div class="rounded-xl p-4 bg-slate-50 border border-slate-200">
                <div class="flex items-center justify-between gap-3">
                    <span class="text-xs font-semibold text-slate-700">Prioritas Pemantauan</span>
                    <StatusBadge type="prioritas" :value="result.prioritas_pemantauan?.kategori" />
                </div>
            </div>
        </section>

        <section class="card p-5 rounded-2xl space-y-3">
            <h3 class="text-sm font-bold text-slate-800 m-0">
                Status Antropometri dan Z-Score
            </h3>
            <p class="text-xs text-slate-400 m-0">
                Hasil dihitung oleh server berdasarkan referensi WHO dan ambang Permenkes.
            </p>

            <div class="divide-y divide-slate-100">
                <div
                    v-for="item in anthropometryResults"
                    :key="item.label"
                    class="py-3 first:pt-1 last:pb-0"
                >
                    <div class="flex items-center justify-between gap-3">
                        <div>
                            <p class="text-xs font-semibold text-slate-700 m-0">
                                {{ item.label }}
                            </p>
                            <p class="text-[11px] text-slate-400 mt-1 mb-0">
                                {{ item.shortLabel }}
                            </p>
                        </div>
                        <div class="flex items-center gap-2 flex-wrap justify-end">
                            <span class="text-xs font-mono font-semibold text-slate-700">
                                Z-score {{ formatZScore(item.value) }}
                            </span>
                            <StatusBadge type="antropometri" :value="item.status" />
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="card p-5 rounded-2xl space-y-3">
            <div>
                <h3 class="text-sm font-bold text-slate-800 m-0">
                    Analisis Risiko Kekurangan Gizi
                </h3>
                <p class="text-[11px] text-slate-400 mt-1 mb-0">
                    Metode Simple Additive Weighting
                </p>
            </div>
            <div class="flex items-center justify-between">
                <span class="text-sm text-slate-600">Skor akhir</span>
                <span class="text-lg font-bold text-slate-800">
                    {{ formatSkor(result.skor_saw) }}
                </span>
            </div>
            <div class="h-2 rounded-full overflow-hidden bg-slate-200">
                <div
                    class="h-full rounded-full transition-all duration-700"
                    :style="`width: ${sawPercentage}%; background: ${sawColor}`"
                />
            </div>
            <p class="text-xs text-slate-500 m-0">
                Skor mendekati 1 menunjukkan risiko kekurangan gizi yang lebih perlu diperhatikan. Skor ini bukan diagnosis.
            </p>
        </section>
    </div>
</template>

<script setup>
import { computed, defineComponent, h } from "vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import { formatUkuran, formatTanggal } from "@/utils/format.js";

const props = defineProps({
    result: { type: Object, required: true },
    anak: { type: Object, default: null },
});

const MetricBox = defineComponent({
    props: {
        label: { type: String, required: true },
        value: { type: String, required: true },
        unit: { type: String, default: "" },
    },
    setup(componentProps) {
        return () =>
            h("div", { class: "stat-box rounded-xl p-3 text-center" }, [
                h("p", { class: "text-xl font-bold text-slate-800 m-0" }, [
                    componentProps.value,
                    componentProps.unit
                        ? h("span", { class: "text-sm font-normal text-slate-500" }, ` ${componentProps.unit}`)
                        : null,
                ]),
                h("p", { class: "text-xs text-slate-500 mt-1 mb-0" }, componentProps.label),
            ]);
    },
});

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
    rendah: "#15803d",
    sedang: "#d97706",
    tinggi: "#dc2626",
};

const sawColor = computed(
    () => colorsByPriority[props.result.kategori_prioritas] ?? "#64748b",
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
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.stat-box {
    background: var(--color-green-50);
    border: 1px solid var(--color-input-border);
}
</style>
