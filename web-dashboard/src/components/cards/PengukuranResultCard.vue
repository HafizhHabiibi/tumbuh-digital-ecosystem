<template>
    <div class="space-y-4">
        <!-- ─── Status utama ─────────────────────────────────────── -->
        <div class="card p-5 rounded-2xl space-y-4">
            <div class="flex items-center justify-between flex-wrap gap-3">
                <h3
                    class="text-sm font-semibold m-0"
                    style="color: var(--color-text-heading)"
                >
                    Hasil Pengukuran
                </h3>
                <span
                    class="text-xs px-2 py-1 rounded-full font-medium"
                    style="
                        background: var(--color-green-100);
                        color: var(--color-green-700);
                    "
                >
                    {{ formatTanggal(result.tanggal_ukur) }}
                </span>
            </div>

            <!-- BB & TB -->
            <div class="grid grid-cols-2 gap-3">
                <div class="stat-box rounded-xl p-3 text-center">
                    <p
                        class="text-xl font-bold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        {{ result.berat_badan }}
                        <span class="text-sm font-normal">kg</span>
                    </p>
                    <p
                        class="text-xs m-0 mt-0.5"
                        style="color: var(--color-text-muted)"
                    >
                        Berat Badan
                    </p>
                </div>
                <div class="stat-box rounded-xl p-3 text-center">
                    <p
                        class="text-xl font-bold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        {{ result.tinggi_badan }}
                        <span class="text-sm font-normal">cm</span>
                    </p>
                    <p
                        class="text-xs m-0 mt-0.5"
                        style="color: var(--color-text-muted)"
                    >
                        Tinggi Badan
                    </p>
                </div>
            </div>

            <!-- Status Gizi & Risiko -->
            <div class="grid grid-cols-2 gap-3">
                <div
                    class="rounded-xl p-3 text-center"
                    :style="`background: ${statusGiziBg}; border: 1px solid ${statusGiziBorder}`"
                >
                    <p
                        class="text-xs font-medium m-0 mb-1"
                        style="color: var(--color-text-muted)"
                    >
                        Status Gizi
                    </p>
                    <span
                        class="text-sm font-bold capitalize"
                        :style="`color: ${statusGiziColor}`"
                    >
                        {{ result.status_gizi }}
                    </span>
                </div>
                <div
                    class="rounded-xl p-3 text-center"
                    :style="`background: ${risikoBg}; border: 1px solid ${risikoBorder}`"
                >
                    <p
                        class="text-xs font-medium m-0 mb-1"
                        style="color: var(--color-text-muted)"
                    >
                        Risiko Stunting
                    </p>
                    <span
                        class="text-sm font-bold capitalize"
                        :style="`color: ${risikoColor}`"
                    >
                        {{ result.kategori_risiko }}
                    </span>
                </div>
            </div>
        </div>

        <!-- ─── Z-Score ──────────────────────────────────────────── -->
        <div class="card p-5 rounded-2xl space-y-3">
            <h3
                class="text-sm font-semibold m-0"
                style="color: var(--color-text-heading)"
            >
                <i
                    class="pi pi-chart-bar mr-1.5"
                    style="color: var(--color-green-700)"
                    aria-hidden="true"
                />
                Hasil Z-Score
            </h3>
            <div class="space-y-3">
                <div v-for="zs in zscores" :key="zs.label">
                    <div class="flex items-center justify-between mb-1">
                        <span
                            class="text-xs"
                            style="color: var(--color-text-body)"
                            >{{ zs.label }}</span
                        >
                        <div class="flex items-center gap-2">
                            <span
                                class="text-xs font-mono font-semibold"
                                style="color: var(--color-text-heading)"
                            >
                                {{ zs.value?.toFixed(2) ?? "—" }}
                            </span>
                            <span
                                class="text-xs px-1.5 py-0.5 rounded font-medium capitalize"
                                :style="`background: ${zs.bg}; color: ${zs.color}`"
                            >
                                {{ zs.status ?? "—" }}
                            </span>
                        </div>
                    </div>
                    <!-- Bar Z-score: range -4 sampai +4, tengah = 0 -->
                    <div
                        class="relative h-1.5 rounded-full overflow-hidden"
                        style="background: var(--color-input-border)"
                    >
                        <div
                            class="absolute h-full rounded-full transition-all duration-700"
                            :style="`left: ${zscoreLeft(zs.value)}%; width: ${zscoreWidth(zs.value)}%; background: ${zs.color}`"
                        />
                        <!-- Garis tengah (zscore = 0) -->
                        <div
                            class="absolute top-0 bottom-0 w-px"
                            style="left: 50%; background: #9ca3af"
                        />
                    </div>
                </div>
            </div>
        </div>

        <!-- ─── Skor SAW ─────────────────────────────────────────── -->
        <div class="card p-5 rounded-2xl space-y-3">
            <h3
                class="text-sm font-semibold m-0"
                style="color: var(--color-text-heading)"
            >
                <i
                    class="pi pi-calculator mr-1.5"
                    style="color: var(--color-green-700)"
                    aria-hidden="true"
                />
                Analisis SAW
            </h3>
            <div class="flex items-center justify-between">
                <span class="text-sm" style="color: var(--color-text-body)"
                    >Skor Akhir</span
                >
                <span
                    class="text-lg font-bold"
                    style="color: var(--color-text-heading)"
                >
                    {{ result.skor_saw?.toFixed(4) ?? "—" }}
                </span>
            </div>
            <div
                class="h-2 rounded-full overflow-hidden"
                style="background: var(--color-input-border)"
            >
                <div
                    class="h-full rounded-full transition-all duration-700"
                    :style="`width: ${(result.skor_saw || 0) * 100}%; background: ${risikoColor}`"
                />
            </div>
            <p class="text-xs m-0" style="color: var(--color-text-muted)">
                Skor mendekati 1 menunjukkan risiko stunting lebih tinggi
            </p>
        </div>

        <!-- ─── AI Insight ───────────────────────────────────────── -->
        <div class="card p-5 rounded-2xl space-y-3">
            <h3
                class="text-sm font-semibold m-0 flex items-center gap-2"
                style="color: var(--color-text-heading)"
            >
                <i
                    class="pi pi-sparkles"
                    style="color: var(--color-green-700)"
                    aria-hidden="true"
                />
                Rekomendasi AI
            </h3>
            <div
                class="flex items-start gap-2 text-sm p-3 rounded-xl"
                style="
                    background: var(--color-green-50);
                    color: var(--color-text-body);
                "
            >
                <i
                    class="pi pi-info-circle mt-0.5 flex-shrink-0"
                    style="color: var(--color-green-700)"
                    aria-hidden="true"
                />
                <span>{{ result.ai_insight }}</span>
            </div>
        </div>
    </div>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
    result: { type: Object, required: true },
});

const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
    });

/* ── Warna status gizi ───────────────────────────────────────────── */
const statusGiziMap = {
    normal: { color: "#15803d", bg: "#dcfce7", border: "#86efac" },
    kurang: { color: "#d97706", bg: "#fef3c7", border: "#fcd34d" },
    buruk: { color: "#dc2626", bg: "#fee2e2", border: "#fca5a5" },
    lebih: { color: "#2563eb", bg: "#dbeafe", border: "#93c5fd" },
};
const statusGiziColor = computed(
    () => statusGiziMap[props.result.status_gizi]?.color ?? "#6b7280",
);
const statusGiziBg = computed(
    () => statusGiziMap[props.result.status_gizi]?.bg ?? "#f3f4f6",
);
const statusGiziBorder = computed(
    () => statusGiziMap[props.result.status_gizi]?.border ?? "#e5e7eb",
);

/* ── Warna risiko ────────────────────────────────────────────────── */
const risikoMap = {
    rendah: { color: "#15803d", bg: "#dcfce7", border: "#86efac" },
    sedang: { color: "#d97706", bg: "#fef3c7", border: "#fcd34d" },
    tinggi: { color: "#dc2626", bg: "#fee2e2", border: "#fca5a5" },
};
const risikoColor = computed(
    () => risikoMap[props.result.kategori_risiko]?.color ?? "#6b7280",
);
const risikoBg = computed(
    () => risikoMap[props.result.kategori_risiko]?.bg ?? "#f3f4f6",
);
const risikoBorder = computed(
    () => risikoMap[props.result.kategori_risiko]?.border ?? "#e5e7eb",
);

/* ── Z-Score bars ────────────────────────────────────────────────── */
const getZsColor = (val) => {
    if (val === null || val === undefined) return "#9ca3af";
    if (val < -3) return "#dc2626";
    if (val < -2) return "#f59e0b";
    if (val > 2) return "#2563eb";
    return "#15803d";
};
const getZsBg = (val) => {
    if (val === null || val === undefined) return "#f3f4f6";
    if (val < -3) return "#fee2e2";
    if (val < -2) return "#fef3c7";
    if (val > 2) return "#dbeafe";
    return "#dcfce7";
};

const zscores = computed(() => [
    {
        label: "BB/U  (Berat per Usia)",
        value: props.result.zscore_bbu,
        status: props.result.status_bbu,
        color: getZsColor(props.result.zscore_bbu),
        bg: getZsBg(props.result.zscore_bbu),
    },
    {
        label: "TB/U  (Tinggi per Usia)",
        value: props.result.zscore_tbu,
        status: props.result.status_tbu,
        color: getZsColor(props.result.zscore_tbu),
        bg: getZsBg(props.result.zscore_tbu),
    },
    {
        label: "BB/TB (Berat per Tinggi)",
        value: props.result.zscore_bbtb,
        status: props.result.status_bbtb,
        color: getZsColor(props.result.zscore_bbtb),
        bg: getZsBg(props.result.zscore_bbtb),
    },
]);

/* ── Posisi bar Z-score: range -4..+4 → 0..100% ────────────────── */
const zscoreLeft = (val) =>
    val === null ? 50 : Math.max(0, ((val + 4) / 8) * 100);
const zscoreWidth = () => 4; // lebar marker 4%
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
