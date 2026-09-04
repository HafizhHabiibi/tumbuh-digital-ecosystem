<template>
    <!--
        StatCard.vue
        Kartu ringkasan statistik dashboard yang minimalis, simpel, dan profesional.
        Ikon berwarna khas sesuai kategori tanpa kotak latar yang mencolok.
    -->
    <div class="stat-card group" :class="`stat-card--${color}`">
        <!-- Skeleton loading -->
        <template v-if="loading">
            <div class="flex items-center justify-between">
                <div class="skeleton w-24 h-3.5 rounded-md" aria-hidden="true" />
                <div class="skeleton w-6 h-6 rounded-md" aria-hidden="true" />
            </div>
            <div class="skeleton w-24 h-7 rounded-lg mt-3" aria-hidden="true" />
            <div class="skeleton w-32 h-4 rounded-md mt-2" aria-hidden="true" />
        </template>

        <template v-else>
            <!-- Header baris atas: Label & Ikon Berwarna Kategori -->
            <div class="flex items-start justify-between gap-3">
                <p class="stat-label">{{ label }}</p>
                <span
                    class="stat-icon"
                    :class="`stat-icon--${color}`"
                    aria-hidden="true"
                >
                    <i :class="`pi ${icon}`" />
                </span>
            </div>

            <!-- Nilai utama -->
            <div class="mt-2">
                <p class="stat-value">{{ formattedValue }}</p>
            </div>

            <!-- Sub info opsional -->
            <div v-if="sub" class="mt-2.5 flex items-center">
                <span class="stat-badge">
                    {{ sub }}
                </span>
            </div>
        </template>
    </div>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
    label: { type: String, required: true },
    value: { type: Number, default: 0 },
    icon: { type: String, default: "pi-chart-bar" },
    color: {
        type: String,
        default: "green",
        validator: (v) => ["green", "amber", "red", "blue"].includes(v),
    },
    sub: { type: String, default: null },
    loading: { type: Boolean, default: false },
});

const formattedValue = computed(() => props.value.toLocaleString("id-ID"));
</script>

<style scoped>
/* ─── Card base ───────────────────────────────────────────────────── */
.stat-card {
    background: #ffffff;
    border-radius: 1rem;
    padding: 1.25rem 1.35rem;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    min-height: 7.75rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03), 0 1px 2px rgba(0, 0, 0, 0.02);
    border: 1px solid rgba(226, 232, 240, 0.85);
    transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px -4px rgba(0, 0, 0, 0.06), 0 2px 6px -2px rgba(0, 0, 0, 0.02);
    border-color: rgba(203, 213, 225, 0.9);
}

/* ─── Icon: Ikon berwarna sesuai kategori tanpa kotak latar belakang ── */
.stat-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.35rem;
    transition: transform 0.2s ease, filter 0.2s ease;
    flex-shrink: 0;
    padding-top: 0.1rem;
}

.stat-card:hover .stat-icon {
    transform: scale(1.12);
}

.stat-icon--green {
    color: #059669; /* Emerald */
}

.stat-icon--amber {
    color: #d97706; /* Amber */
}

.stat-icon--red {
    color: #dc2626; /* Rose / Red */
}

.stat-icon--blue {
    color: #2563eb; /* Sky / Royal Blue */
}

/* ─── Typography ──────────────────────────────────────────────────── */
.stat-label {
    font-size: 0.775rem;
    font-weight: 700;
    color: #1e293b; /* slate-800 */
    margin: 0;
    line-height: 1.35;
    letter-spacing: 0.01em;
}

.stat-value {
    font-size: 1.875rem;
    font-weight: 800;
    color: #0f172a; /* slate-900 */
    margin: 0;
    line-height: 1.15;
    letter-spacing: -0.02em;
}

/* ─── Badge sub info netral ───────────────────────────────────────── */
.stat-badge {
    display: inline-flex;
    align-items: center;
    font-size: 0.725rem;
    font-weight: 600;
    padding: 0.2rem 0.55rem;
    border-radius: 0.5rem;
    line-height: 1.2;
    background: #f1f5f9;
    color: #475569;
}

/* ─── Skeleton ────────────────────────────────────────────────────── */
.skeleton {
    background: linear-gradient(90deg, #f1f5f9 25%, #e2e8f0 50%, #f1f5f9 75%);
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
