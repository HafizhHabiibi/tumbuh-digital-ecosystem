<template>
    <!--
        RisikoChart.vue
        Horizontal Rounded Progress Cards untuk Distribusi Prioritas Pemantauan.
        Menyajikan 3 tingkatan prioritas (Rendah, Sedang, Tinggi) secara bersih, simpel, dan profesional.
    -->
    <ChartCard
        title="Distribusi Prioritas Pemantauan"
        :loading="loading"
        :empty="totalAnak === 0"
    >
        <!-- Header Actions: Total Balita -->
        <template #actions>
            <span
                v-if="totalAnak > 0 && !loading"
                class="text-xs font-semibold text-slate-600 bg-slate-100 px-2.5 py-1 rounded-lg"
            >
                Total: {{ totalAnak }} Balita
            </span>
        </template>

        <!-- Skeleton Loading -->
        <div v-if="loading" class="space-y-3.5 py-2">
            <div
                v-for="i in 3"
                :key="i"
                class="p-3.5 rounded-xl border border-slate-100 space-y-2.5"
            >
                <div class="flex items-center justify-between">
                    <div class="skeleton w-36 h-4 rounded" />
                    <div class="skeleton w-20 h-4 rounded" />
                </div>
                <div class="skeleton w-full h-2.5 rounded-full" />
            </div>
        </div>

        <!-- Horizontal Rounded Progress Cards -->
        <div v-else-if="totalAnak > 0" class="space-y-3 py-1">
            <div
                v-for="item in breakdownData"
                :key="item.label"
                class="p-3.5 rounded-xl border border-slate-100 bg-white hover:bg-slate-50/70 hover:border-slate-200 transition-all duration-200"
            >
                <!-- Baris Informasi: Label Kategori, Nilai, dan Persentase -->
                <div class="flex items-center justify-between gap-3 mb-2">
                    <div class="flex items-center gap-2">
                        <span
                            class="w-2.5 h-2.5 rounded-full shrink-0 shadow-xs"
                            :style="{ backgroundColor: item.color }"
                        />
                        <span class="text-xs font-bold text-slate-800">
                            Prioritas {{ item.label }}
                        </span>
                    </div>

                    <div class="flex items-center gap-2">
                        <span class="text-xs font-extrabold text-slate-900">
                            {{ item.value }}
                            <span class="font-normal text-slate-400 text-[11px]">anak</span>
                        </span>
                        <span
                            class="text-[11px] font-bold px-2 py-0.5 rounded-md min-w-[42px] text-right"
                            :style="{
                                backgroundColor: `${item.color}15`,
                                color: item.color,
                            }"
                        >
                            {{ item.percentage }}%
                        </span>
                    </div>
                </div>

                <!-- Progress Bar Horizontal Tebal Membulat -->
                <div class="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
                    <div
                        class="h-full rounded-full transition-all duration-500 ease-out"
                        :style="{
                            width: `${item.percentage}%`,
                            backgroundColor: item.color,
                        }"
                    />
                </div>
            </div>
        </div>
    </ChartCard>
</template>

<script setup>
import { computed } from "vue";
import ChartCard from "./ChartCard.vue";

const props = defineProps({
    data: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
});

const totalAnak = computed(() =>
    props.data.reduce((acc, curr) => acc + (curr.value || 0), 0),
);

const breakdownData = computed(() => {
    const total = totalAnak.value;
    return props.data.map((item) => ({
        ...item,
        percentage:
            total > 0 ? ((item.value / total) * 100).toFixed(1) : "0.0",
    }));
});
</script>

<style scoped>
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
