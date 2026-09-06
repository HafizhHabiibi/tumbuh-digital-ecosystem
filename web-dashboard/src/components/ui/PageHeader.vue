<template>
    <div class="page-header flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-1">
        <div>
            <h1 class="page-header__title text-2xl font-bold tracking-tight m-0 text-slate-800">
                {{ title }}
            </h1>
        </div>

        <div class="page-header__actions flex items-center gap-2.5 flex-wrap self-start sm:self-auto">
            <!-- Badge Tanggal Hari Ini (Senada dengan Pengukuran & Pemberian) -->
            <div
                v-if="showDate"
                class="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-slate-200/80 shadow-2xs text-xs text-slate-600 font-medium"
            >
                <i class="pi pi-calendar text-emerald-600 text-xs" aria-hidden="true" />
                <span>Hari ini: <strong class="text-slate-800">{{ formatTanggal(toLocalDateStr(todayDate)) }}</strong></span>
            </div>

            <slot name="actions">
                <slot />
            </slot>
        </div>
    </div>
</template>

<script setup>
import { formatTanggal, toLocalDateStr } from "@/utils/format.js";

defineProps({
    title: {
        type: String,
        required: true,
    },
    showDate: {
        type: Boolean,
        default: true,
    },
});

const todayDate = new Date();
</script>

<style scoped>
.page-header__title {
    color: var(--color-text-heading, #1e293b);
}
</style>
