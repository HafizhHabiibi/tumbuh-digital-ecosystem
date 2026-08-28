<template>
    <!--
        StatusBadge.vue
        Badge warna untuk status antropometri, prioritas, status rujukan, dll.
        Props: label, variant (green/yellow/red/blue/gray)
        Bisa juga pakai preset lewat prop `type` + `value`
    -->
    <span
        class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold capitalize"
        :style="`background: ${bgColor}; color: ${textColor}`"
        v-bind="$attrs"
    >
        <i v-if="icon" :class="`pi ${icon} text-[10px]`" aria-hidden="true" />
        {{ displayLabel }}
    </span>
</template>

<script setup>
import { computed } from "vue";
import {
    LABEL_STATUS_ANTROPOMETRI,
    VARIANT_STATUS_ANTROPOMETRI,
} from "@/utils/antropometri";

const props = defineProps({
    /** Label teks yang ditampilkan */
    label: { type: String, default: null },

    /**
     * Variant warna manual
     * green | yellow | red | blue | gray | purple
     */
    variant: { type: String, default: null },

    /**
     * Preset otomatis berdasarkan tipe & nilai
     * type: "antropometri" | "prioritas" | "rujukan" | "jk"
     * value: nilai dari backend (misal "normal", "tinggi", "diajukan", "L")
     */
    type: { type: String, default: null },
    value: { type: String, default: null },

    /** Ikon PrimeIcons opsional */
    icon: { type: String, default: null },
});

/* ── Preset mapping ──────────────────────────────────────────────── */
const presetMap = {
    antropometri: Object.fromEntries(
        Object.entries(LABEL_STATUS_ANTROPOMETRI).map(([value, label]) => [
            value,
            { variant: VARIANT_STATUS_ANTROPOMETRI[value], label },
        ]),
    ),
    prioritas: {
        rendah: { variant: "green", label: "Rendah" },
        sedang: { variant: "yellow", label: "Sedang" },
        tinggi: { variant: "red", label: "Tinggi" },
    },
    rujukan: {
        diajukan: { variant: "blue", label: "Diajukan" },
        ditangani: { variant: "yellow", label: "Ditangani" },
        selesai: { variant: "gray", label: "Selesai" },
    },
    jk: {
        L: { variant: "blue", label: "Laki-laki" },
        P: { variant: "pink", label: "Perempuan" },
    },
};

/* ── Resolve preset ──────────────────────────────────────────────── */
const resolved = computed(() => {
    if (props.type && props.value) {
        return presetMap[props.type]?.[props.value] ?? null;
    }
    return null;
});

const displayLabel = computed(
    () => props.label ?? resolved.value?.label ?? props.value ?? "",
);

const activeVariant = computed(
    () => props.variant ?? resolved.value?.variant ?? "gray",
);

/* ── Warna per variant ───────────────────────────────────────────── */
const colorMap = {
    green: { bg: "#dcfce7", text: "#15803d" },
    yellow: { bg: "#fef3c7", text: "#d97706" },
    red: { bg: "#fee2e2", text: "#dc2626" },
    blue: { bg: "#dbeafe", text: "#2563eb" },
    gray: { bg: "#f3f4f6", text: "#6b7280" },
    purple: { bg: "#ede9fe", text: "#7c3aed" },
    pink: { bg: "#fce7f3", text: "#be185d" },
};

const bgColor = computed(() => colorMap[activeVariant.value]?.bg ?? "#f3f4f6");
const textColor = computed(
    () => colorMap[activeVariant.value]?.text ?? "#6b7280",
);
</script>
