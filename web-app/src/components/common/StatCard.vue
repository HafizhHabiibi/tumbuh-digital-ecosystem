<template>
    <!-- Skeleton -->
    <div
        v-if="loading"
        class="stat-card stat-card--skeleton"
        :style="{ background: bgColor, border: border }"
    >
        <div class="skeleton-icon"></div>
        <div class="skeleton-line skeleton-line--short"></div>
        <div class="skeleton-line skeleton-line--long"></div>
        <div class="skeleton-line skeleton-line--mid"></div>
    </div>

    <!-- Konten -->
    <div
        v-else
        class="stat-card"
        :style="{ background: bgColor, border: border }"
    >
        <div class="stat-card__header">
            <div class="stat-card__icon" :style="{ background: iconBg }">
                <span
                    class="material-symbols-outlined"
                    :class="{ 'icon-filled': iconFill }"
                    :style="{ color: iconColor }"
                    >{{ icon }}</span
                >
            </div>
            <span
                class="stat-card__tag"
                :style="{ color: tagColor, background: tagBg }"
                >{{ tag }}</span
            >
        </div>

        <div>
            <h3 class="stat-card__value" :style="{ color: valueColor }">
                {{ value }}
                <span
                    v-if="valueSuffix"
                    class="stat-card__suffix"
                    :style="{ color: suffixColor }"
                    >{{ valueSuffix }}</span
                >
            </h3>

            <div v-if="showProgress" class="stat-card__progress-track">
                <div
                    class="stat-card__progress-fill"
                    :style="{
                        width: progress + '%',
                        background: progressColor,
                    }"
                ></div>
            </div>

            <p class="stat-card__label" :style="{ color: labelColor }">
                {{ label }}
            </p>
        </div>
    </div>
</template>

<script setup>
defineProps({
    // Konten
    icon: { type: String, default: "info" },
    iconFill: { type: Boolean, default: false },
    tag: { type: String, default: "" },
    value: { type: [String, Number], default: "—" },
    valueSuffix: { type: String, default: "" },
    label: { type: String, default: "" },

    // Warna
    bgColor: { type: String, default: "#ffffff" },
    border: { type: String, default: "none" },
    iconBg: { type: String, default: "rgba(0,110,28,0.1)" },
    iconColor: { type: String, default: "#006e1c" },
    tagColor: { type: String, default: "#006e1c" },
    tagBg: { type: String, default: "transparent" },
    valueColor: { type: String, default: "#171d16" },
    suffixColor: { type: String, default: "#3f4a3c" },
    labelColor: { type: String, default: "#3f4a3c" },

    // Progress bar
    showProgress: { type: Boolean, default: false },
    progress: { type: Number, default: 0 },
    progressColor: { type: String, default: "#006e1c" },

    // State
    loading: { type: Boolean, default: false },
});
</script>

<style scoped>
.stat-card {
    border-radius: 1.5rem;
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    gap: 1rem;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    transition: all 0.2s ease;
    min-height: 160px;
}
.stat-card:not(.stat-card--skeleton):hover {
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.08);
    transform: translateY(-2px);
}

.stat-card__header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
}
.stat-card__icon {
    padding: 0.5rem;
    border-radius: 0.5rem;
}
.stat-card__tag {
    font-size: 12px;
    font-weight: 700;
    padding: 2px 8px;
    border-radius: 999px;
}

.stat-card__value {
    font-size: 32px;
    font-weight: 700;
    line-height: 40px;
}
.stat-card__suffix {
    font-size: 18px;
    font-weight: 400;
}
.stat-card__label {
    font-size: 14px;
    margin-top: 4px;
}

.stat-card__progress-track {
    width: 100%;
    background: #dee4d8;
    height: 6px;
    border-radius: 999px;
    margin-top: 0.5rem;
    overflow: hidden;
}
.stat-card__progress-fill {
    height: 100%;
    border-radius: 999px;
    transition: width 0.6s ease;
}

/* Skeleton */
.stat-card--skeleton {
    pointer-events: none;
}

@keyframes shimmer {
    0% {
        background-position: -400px 0;
    }
    100% {
        background-position: 400px 0;
    }
}
.skeleton-icon,
.skeleton-line {
    border-radius: 8px;
    background: linear-gradient(90deg, #e0e7db 25%, #f0f5ec 50%, #e0e7db 75%);
    background-size: 800px 100%;
    animation: shimmer 1.4s infinite;
}
.skeleton-icon {
    width: 40px;
    height: 40px;
    border-radius: 0.5rem;
}
.skeleton-line {
    height: 14px;
    margin-top: 10px;
}
.skeleton-line--short {
    width: 40%;
}
.skeleton-line--long {
    width: 60%;
    height: 28px;
}
.skeleton-line--mid {
    width: 50%;
}
</style>
