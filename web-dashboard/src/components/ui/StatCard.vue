<template>
    <!--
        StatCard.vue
        Kartu ringkasan statistik dashboard.
        Mendukung loading skeleton, trend indicator, dan warna aksen.
    -->
    <div class="stat-card" :class="`stat-card--${color}`">
        <!-- Skeleton loading -->
        <template v-if="loading">
            <div class="skeleton skeleton--icon" aria-hidden="true" />
            <div class="skeleton skeleton--label" aria-hidden="true" />
            <div class="skeleton skeleton--value" aria-hidden="true" />
        </template>

        <template v-else>
            <!-- Icon -->
            <div
                class="stat-icon"
                :class="`stat-icon--${color}`"
                aria-hidden="true"
            >
                <i :class="`pi ${icon}`" />
            </div>

            <!-- Label -->
            <p class="stat-label">{{ label }}</p>

            <!-- Nilai utama -->
            <p class="stat-value">{{ formattedValue }}</p>

            <!-- Sub info opsional -->
            <p v-if="sub" class="stat-sub">{{ sub }}</p>
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
    background: white;
    border-radius: 1rem;
    padding: 1.25rem 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
    border: 1px solid rgba(190, 202, 184, 0.3);
    transition:
        transform 0.2s,
        box-shadow 0.2s;
    position: relative;
    overflow: hidden;
}
.stat-card::before {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    width: 4px;
    height: 100%;
    border-radius: 1rem 0 0 1rem;
}
.stat-card--green::before {
    background: var(--color-green-600);
}
.stat-card--amber::before {
    background: #f59e0b;
}
.stat-card--red::before {
    background: #ef4444;
}
.stat-card--blue::before {
    background: #3b82f6;
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

/* ─── Icon ────────────────────────────────────────────────────────── */
.stat-icon {
    width: 2.5rem;
    height: 2.5rem;
    border-radius: 0.625rem;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.1rem;
}
.stat-icon--green {
    background: #dcfce7;
    color: var(--color-green-700);
}
.stat-icon--amber {
    background: #fef3c7;
    color: #d97706;
}
.stat-icon--red {
    background: #fee2e2;
    color: #dc2626;
}
.stat-icon--blue {
    background: #dbeafe;
    color: #2563eb;
}

/* ─── Teks ────────────────────────────────────────────────────────── */
.stat-label {
    font-size: 0.75rem;
    font-weight: 500;
    color: var(--color-text-muted);
    margin: 0;
    text-transform: uppercase;
    letter-spacing: 0.04em;
}
.stat-value {
    font-size: 1.875rem;
    font-weight: 700;
    color: var(--color-text-heading);
    margin: 0;
    line-height: 1.1;
}
.stat-sub {
    font-size: 0.75rem;
    color: var(--color-text-muted);
    margin: 0;
}

/* ─── Skeleton ────────────────────────────────────────────────────── */
.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
    border-radius: 0.375rem;
}
.skeleton--icon {
    width: 2.5rem;
    height: 2.5rem;
    border-radius: 0.625rem;
}
.skeleton--label {
    width: 60%;
    height: 0.75rem;
}
.skeleton--value {
    width: 40%;
    height: 1.875rem;
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
