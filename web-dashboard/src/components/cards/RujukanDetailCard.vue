<template>
    <article class="space-y-3.5">
        <!-- ─── Tanggal Pengajuan di Pojok Kanan Atas ──────────────────── -->
        <div class="flex items-center justify-end">
            <div class="text-xs text-slate-500 font-medium">
                Diajukan: <span class="text-slate-800 font-semibold">{{ formatTanggal(rujukan.created_at) }}</span>
            </div>
        </div>

        <!-- ─── Profil Pasien & Data Administratif ────────────────────── -->
        <section class="p-4 rounded-xl bg-white border border-slate-200/80 shadow-2xs">
            <div class="flex items-center gap-3">
                <div
                    class="w-11 h-11 rounded-xl flex items-center justify-center font-bold text-xs shrink-0 shadow-2xs"
                    :class="rujukan.jenis_kelamin === 'L' ? 'bg-sky-100 text-sky-700' : 'bg-rose-100 text-rose-700'"
                >
                    {{ getInitials(rujukan.nama_anak) }}
                </div>
                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                        <h3 class="text-sm font-bold text-slate-800 truncate m-0">
                            {{ rujukan.nama_anak || "—" }}
                        </h3>
                        <span
                            class="text-[11px] px-2 py-0.5 rounded-md font-semibold shrink-0"
                            :class="rujukan.jenis_kelamin === 'L' ? 'bg-sky-50 text-sky-700 border border-sky-200' : 'bg-rose-50 text-rose-700 border border-rose-200'"
                        >
                            {{ rujukan.jenis_kelamin === 'L' ? 'Laki-laki' : 'Perempuan' }}
                        </span>
                    </div>
                    <div class="flex items-center flex-nowrap gap-x-2 text-[11px] text-slate-500 mt-1 whitespace-nowrap">
                        <span class="inline-flex items-center shrink-0">
                            <span class="text-slate-400">Orang Tua:</span>
                            <strong class="text-slate-700 ml-1 font-semibold">{{ rujukan.nama_orang_tua || "—" }}</strong>
                        </span>
                        <span class="text-slate-300 shrink-0 select-none">•</span>
                        <span class="inline-flex items-center shrink-0">
                            <span class="text-slate-400">Umur:</span>
                            <strong class="text-slate-700 ml-1 font-semibold">{{ hitungUsia(rujukan.tanggal_lahir) }}</strong>
                        </span>
                        <span class="text-slate-300 shrink-0 select-none">•</span>
                        <span class="inline-flex items-center shrink-0">
                            <span class="text-slate-400">Tanggal Lahir:</span>
                            <strong class="text-slate-700 ml-1 font-semibold">{{ formatTanggal(rujukan.tanggal_lahir) }}</strong>
                        </span>
                    </div>
                </div>
            </div>
        </section>

        <!-- ─── Alur Rujukan ─────────────────────────────────────────── -->
        <section class="p-4 rounded-xl bg-white border border-slate-200/80 shadow-2xs space-y-3.5" aria-labelledby="stepper-title">
            <div class="flex items-center justify-between gap-3 flex-wrap pb-2 border-b border-slate-100">
                <h4 id="stepper-title" class="text-xs font-bold text-slate-800 uppercase tracking-wider m-0">
                    Alur Rujukan
                </h4>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3.5 sm:gap-4">
                <div
                    v-for="(step, index) in timelineSteps"
                    :key="step.key"
                    class="flex items-start gap-2.5 min-w-0 relative"
                    :class="{ 'sm:pr-3': index < 2 }"
                >
                    <div
                        class="w-6 h-6 rounded-full flex items-center justify-center text-[11px] font-bold shrink-0 mt-0.5 transition-colors shadow-2xs"
                        :class="[
                            step.complete
                                ? 'bg-emerald-600 text-white'
                                : 'bg-white border border-slate-200 text-slate-400'
                        ]"
                    >
                        {{ index + 1 }}
                    </div>

                    <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-1.5 flex-wrap">
                            <span
                                class="text-xs font-bold"
                                :class="step.complete ? 'text-slate-800' : 'text-slate-400'"
                            >
                                {{ step.label }}
                            </span>
                            <span
                                v-if="step.current && !step.isFinished"
                                class="text-[9px] px-1.5 py-0.2 rounded font-semibold bg-amber-100 text-amber-800"
                            >
                                Saat ini
                            </span>
                        </div>
                        <p class="text-[11px] text-slate-500 mt-0.5 mb-0">
                            {{ step.date }}
                        </p>
                        <p v-if="step.actor" class="text-[10px] text-slate-400 mt-0.5 mb-0 truncate">
                            {{ step.actor }}
                        </p>
                    </div>

                    <div
                        v-if="index < 2"
                        class="hidden sm:flex items-center justify-center absolute -right-2.5 top-1/2 -translate-y-1/2 text-slate-300 pointer-events-none"
                        aria-hidden="true"
                    >
                        <i class="pi pi-chevron-right text-[11px]" />
                    </div>
                </div>
            </div>
        </section>

        <!-- ─── Dasar Pengukuran & Status Antropometri ────────────────── -->
        <section class="p-4 rounded-xl bg-white border border-slate-200/80 shadow-2xs space-y-3.5">
            <div class="flex items-center justify-between gap-3 flex-wrap pb-2 border-b border-slate-100">
                <h4 class="text-xs font-bold text-slate-800 m-0 flex items-center gap-1.5 flex-wrap">
                    <span class="uppercase tracking-wider">Data Pengukuran:</span>
                    <span class="font-semibold text-slate-600 normal-case">{{ formatTanggal(rujukan.tanggal_ukur) }}</span>
                </h4>
                <div class="flex items-center gap-2 flex-wrap">
                    <StatusBadge
                        v-if="rujukan.prioritas_pemantauan?.kategori"
                        type="prioritas"
                        :value="rujukan.prioritas_pemantauan.kategori"
                    />
                    <div v-if="rujukan.skor_saw" class="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-slate-50 border border-slate-200/70 text-xs">
                        <span class="text-slate-500 font-medium">Skor SAW:</span>
                        <strong class="font-mono text-slate-800">{{ formatSkor(rujukan.skor_saw) }}</strong>
                    </div>
                </div>
            </div>

            <!-- 4 Metrik Utama -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                <div class="p-2.5 rounded-lg bg-slate-50 border border-slate-100">
                    <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Berat Badan</span>
                    <div class="text-base font-bold text-slate-800 mt-0.5">
                        {{ formatUkuran(rujukan.berat_badan) }} <span class="text-xs font-normal text-slate-500">kg</span>
                    </div>
                </div>
                <div class="p-2.5 rounded-lg bg-slate-50 border border-slate-100">
                    <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Tinggi Badan</span>
                    <div class="text-base font-bold text-slate-800 mt-0.5">
                        {{ formatUkuran(rujukan.tinggi_badan) }} <span class="text-xs font-normal text-slate-500">cm</span>
                    </div>
                </div>
                <div class="p-2.5 rounded-lg bg-slate-50 border border-slate-100">
                    <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Lingkar Kepala</span>
                    <div class="text-base font-bold text-slate-800 mt-0.5">
                        {{ measurement(rujukan.lingkar_kepala) }}
                    </div>
                </div>
                <div class="p-2.5 rounded-lg bg-slate-50 border border-slate-100">
                    <span class="text-[10px] font-semibold text-slate-400 uppercase tracking-wider block">Lingkar Lengan</span>
                    <div class="text-base font-bold text-slate-800 mt-0.5">
                        {{ measurement(rujukan.lingkar_lengan) }}
                    </div>
                </div>
            </div>

            <!-- Indikator Status Gizi -->
            <div class="space-y-2 pt-1">
                <span class="text-xs font-semibold text-slate-700 block">Indikator Status Gizi</span>
                <div class="space-y-2">
                    <div
                        v-for="item in statusAntropometri"
                        :key="item.label"
                        class="flex items-center justify-between p-2.5 sm:p-3 rounded-xl bg-slate-50/80 border border-slate-200/60 gap-3 flex-wrap sm:flex-nowrap"
                    >
                        <div class="flex items-center gap-2.5 min-w-0">
                            <span class="w-12 text-center text-xs font-bold text-slate-700 bg-white border border-slate-200/80 py-1 px-1 rounded-lg shadow-2xs shrink-0">
                                {{ item.shortLabel }}
                            </span>
                            <span class="text-xs font-medium text-slate-700 leading-snug">
                                {{ item.label }}
                            </span>
                        </div>
                        <div class="shrink-0 self-end sm:self-center">
                            <StatusBadge
                                v-if="item.value"
                                type="antropometri"
                                :value="item.value"
                            />
                            <span v-else class="text-xs text-slate-400">—</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ─── Catatan & Komunikasi Klinis ───────────────────────────── -->
        <div class="space-y-3">
            <!-- Catatan Pengajuan Kader -->
            <section class="p-3.5 rounded-xl bg-amber-50/60 border border-amber-200/80 space-y-1.5">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold text-amber-800">
                        Catatan Pengajuan Kader
                    </span>
                    <span v-if="rujukan.nama_kader" class="text-[11px] text-amber-700">
                        Oleh: <strong>{{ rujukan.nama_kader }}</strong>
                    </span>
                </div>
                <p class="text-xs text-slate-700 leading-relaxed whitespace-pre-wrap m-0">
                    {{ rujukan.catatan_kader || "Tidak ada catatan khusus dari kader." }}
                </p>
            </section>

            <!-- Catatan Penanganan Puskesmas -->
            <section class="p-3.5 rounded-xl bg-slate-50/80 border border-slate-200/80 space-y-1.5">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-bold text-slate-800">
                        Tindakan & Catatan Puskesmas
                    </span>
                    <span v-if="rujukan.ditangani_oleh" class="text-[11px] text-slate-500">
                        Petugas: <strong class="text-slate-700">{{ rujukan.ditangani_oleh }}</strong>
                    </span>
                </div>
                <p class="text-xs text-slate-700 leading-relaxed whitespace-pre-wrap m-0">
                    {{ rujukan.catatan_puskesmas || "Belum ada catatan atau tindakan dari puskesmas." }}
                </p>
            </section>
        </div>

        <!-- ─── Footer Aksi ──────────────────────────────────────────── -->
        <footer class="pt-2 flex justify-end">
            <button
                type="button"
                class="px-4 py-2 rounded-xl text-xs font-semibold bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer"
                @click="$emit('close')"
            >
                Tutup
            </button>
        </footer>
    </article>
</template>

<script setup>
import { computed } from "vue";
import StatusBadge from "@/components/ui/StatusBadge.vue";
import { formatTanggal, formatUkuran, hitungUsia } from "@/utils/format.js";

const props = defineProps({
    rujukan: { type: Object, required: true },
});

defineEmits(["close"]);

const getInitials = (name) => {
    if (!name) return "A";
    return name
        .split(" ")
        .map((part) => part[0])
        .filter(Boolean)
        .slice(0, 2)
        .join("")
        .toUpperCase();
};

const timelineSteps = computed(() => {
    const statusMap = { diajukan: 0, ditangani: 1, selesai: 2 };
    const currentIndex = statusMap[props.rujukan.status] ?? 0;
    const isFinished = props.rujukan.status === "selesai";

    return [
        {
            key: "diajukan",
            label: "Diajukan",
            timestamp: props.rujukan.created_at,
            actor: props.rujukan.nama_kader ? `Kader: ${props.rujukan.nama_kader}` : "Oleh Kader",
            complete: true,
            current: currentIndex === 0,
            isFinished,
        },
        {
            key: "ditangani",
            label: "Ditangani",
            timestamp: props.rujukan.validated_at,
            actor: props.rujukan.ditangani_oleh ? `Puskesmas: ${props.rujukan.ditangani_oleh}` : "Petugas Puskesmas",
            complete: currentIndex >= 1,
            current: currentIndex === 1,
            isFinished,
        },
        {
            key: "selesai",
            label: "Selesai",
            timestamp: props.rujukan.completed_at,
            actor: props.rujukan.completed_at ? "Penanganan selesai" : "Menunggu penanganan",
            complete: currentIndex >= 2,
            current: currentIndex === 2,
            isFinished,
        },
    ].map((step) => ({
        ...step,
        date: step.timestamp ? formatTanggalWaktu(step.timestamp) : "Menunggu",
    }));
});

const statusAntropometri = computed(() => [
    { label: "Berat Badan menurut Umur", shortLabel: "BB/U", value: props.rujukan.status_bbu },
    { label: "Tinggi Badan menurut Umur", shortLabel: "TB/U", value: props.rujukan.status_tbu },
    { label: "Berat Badan menurut Tinggi Badan", shortLabel: "BB/TB", value: props.rujukan.status_bbtb },
    { label: "Indeks Massa Tubuh menurut Umur", shortLabel: "IMT/U", value: props.rujukan.status_imtu },
]);

const formatTanggalWaktu = (value) => {
    if (!value) return "Menunggu";
    return new Date(value).toLocaleString("id-ID", {
        day: "numeric",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    });
};

const measurement = (value) => {
    if (value === null || value === undefined || value === "") return "—";
    return `${formatUkuran(value)} cm`;
};

const formatSkor = (value) => {
    if (value === null || value === undefined || value === "") return "—";
    return Number(value).toFixed(4);
};
</script>
