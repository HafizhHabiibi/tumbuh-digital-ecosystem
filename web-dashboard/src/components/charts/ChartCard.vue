<template>
    <!--
        ChartCard.vue
        Wrapper shared untuk semua chart di dashboard.
        Menyediakan card styling, header, slot actions, dan empty state.
    -->
    <div
        class="bg-white rounded-2xl border border-[rgba(190,202,184,0.3)] shadow-sm
               hover:-translate-y-0.5 hover:shadow-md transition-all duration-200
               px-5 py-4"
    >
        <!-- Header -->
        <header class="flex items-start justify-between gap-4 mb-2">
            <div>
                <h3
                    class="text-sm font-semibold m-0 mb-0.5"
                    style="color: var(--color-text-heading)"
                >
                    {{ title }}
                </h3>
                <p
                    class="text-xs m-0"
                    style="color: var(--color-text-muted)"
                >
                    {{ subtitle }}
                </p>
            </div>

            <!-- Slot untuk filter/aksi (misal: tombol bulan di TrenGizi) -->
            <slot name="actions" />
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
                class="text-sm m-0 text-center"
                style="color: var(--color-text-muted)"
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
