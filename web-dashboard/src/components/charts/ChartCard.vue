<template>
    <!--
        ChartCard.vue
        Wrapper shared untuk semua chart di dashboard.
        Menyediakan card styling, header, slot actions, dan empty state.
    -->
    <div
        class="chart-card bg-white rounded-2xl border border-slate-200/80 shadow-xs
               hover:shadow-md hover:border-slate-300/80 transition-all duration-200
               p-5 md:p-6"
    >
        <!-- Header -->
        <header class="flex items-center justify-between gap-4 mb-4 pb-3 border-b border-slate-100">
            <div>
                <h3
                    class="text-base font-bold m-0 tracking-tight text-slate-800"
                >
                    {{ title }}
                </h3>
                <p
                    v-if="subtitle"
                    class="text-xs text-slate-500 mt-1 m-0 leading-relaxed"
                >
                    {{ subtitle }}
                </p>
            </div>

            <!-- Slot untuk filter/aksi (misal: tombol bulan di TrenGizi) -->
            <div v-if="$slots.actions" class="flex-shrink-0">
                <slot name="actions" />
            </div>
        </header>

        <!-- Empty state -->
        <div
            v-if="empty && !loading"
            class="flex flex-col items-center justify-center py-12 gap-3"
        >
            <i
                class="pi pi-chart-bar text-3xl"
                style="color: var(--color-text-muted); opacity: 0.4"
                aria-hidden="true"
            />
            <p
                class="text-sm m-0 text-center text-slate-500"
            >
                Belum ada data untuk ditampilkan
            </p>
        </div>

        <!-- Content (chart / skeleton) -->
        <slot v-else />
    </div>
</template>

<script setup>
defineProps({
    title: { type: String, required: true },
    subtitle: { type: String, default: "" },
    loading: { type: Boolean, default: false },
    empty: { type: Boolean, default: false },
});
</script>

<style scoped>
.chart-card {
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03), 0 1px 2px rgba(0, 0, 0, 0.02);
}
</style>
