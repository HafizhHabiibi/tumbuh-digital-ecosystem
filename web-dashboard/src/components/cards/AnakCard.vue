<template>
    <!--
        AnakCard.vue
        Card ringkasan info anak — dipakai di DetailAnakView bagian atas.
        Menampilkan identitas, usia, orang tua, dan status TB/U terakhir.
    -->
    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 md:p-6">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-5">
            <!-- Sisi Kiri: Avatar & Info Pokok -->
            <div class="flex items-center gap-4 flex-1 min-w-0">
                <!-- Avatar Inisial Berdasarkan Gender -->
                <div
                    class="w-16 h-16 rounded-2xl flex items-center justify-center text-2xl font-bold flex-shrink-0 transition-transform shadow-2xs"
                    :class="
                        anak.jenis_kelamin === 'L'
                            ? 'bg-sky-50 text-sky-700 border border-sky-200/80'
                            : 'bg-rose-50 text-rose-700 border border-rose-200/80'
                    "
                    aria-hidden="true"
                >
                    {{ anak.nama ? anak.nama.charAt(0).toUpperCase() : "A" }}
                </div>

                <!-- Nama & Gender -->
                <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2.5 flex-wrap">
                        <h1
                            class="text-xl md:text-2xl font-bold text-slate-800 m-0 truncate tracking-tight"
                        >
                            {{ anak.nama }}
                        </h1>

                        <!-- Modern Gender Chip -->
                        <span
                            class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold"
                            :class="
                                anak.jenis_kelamin === 'L'
                                    ? 'bg-sky-50 text-sky-700 border border-sky-200/80'
                                    : 'bg-rose-50 text-rose-700 border border-rose-200/80'
                            "
                        >
                            <span
                                class="w-1.5 h-1.5 rounded-full"
                                :class="
                                    anak.jenis_kelamin === 'L'
                                        ? 'bg-sky-500'
                                        : 'bg-rose-500'
                                "
                            />
                            {{
                                anak.jenis_kelamin === "L"
                                    ? "Laki-laki"
                                    : "Perempuan"
                            }}
                        </span>
                    </div>

                    <!-- Clean Metadata Strip (Pengganti 4 kartu mini) -->
                    <div class="flex items-center gap-y-1.5 gap-x-3.5 flex-wrap text-xs text-slate-500 mt-2">
                        <!-- Tanggal Lahir & Usia -->
                        <span class="inline-flex items-center gap-1.5">
                            <i class="pi pi-calendar text-slate-400 text-xs" />
                            <span class="font-medium text-slate-700">{{ formatTanggal(anak.tanggal_lahir) }}</span>
                            <span class="text-slate-400">({{ hitungUsia(anak.tanggal_lahir) }})</span>
                        </span>

                        <span class="text-slate-300 hidden sm:inline">•</span>

                        <!-- Orang Tua -->
                        <span class="inline-flex items-center gap-1.5">
                            <i class="pi pi-user text-slate-400 text-xs" />
                            <span class="text-slate-400">Orang Tua:</span>
                            <span class="font-medium text-slate-700">{{ anak.nama_orang_tua || "—" }}</span>
                        </span>

                        <template v-if="anak.nik">
                            <span class="text-slate-300 hidden sm:inline">•</span>

                            <!-- NIK -->
                            <span class="inline-flex items-center gap-1.5">
                                <i class="pi pi-id-card text-slate-400 text-xs" />
                                <span class="text-slate-400">NIK:</span>
                                <span class="font-medium font-mono text-slate-700">{{ anak.nik }}</span>
                            </span>
                        </template>
                    </div>
                </div>
            </div>

            <!-- Sisi Kanan: Slot Aksi Opsional -->
            <div
                v-if="$slots.actions"
                class="flex items-center gap-2 flex-wrap flex-shrink-0 self-start md:self-center"
            >
                <slot name="actions" />
            </div>
        </div>
    </div>
</template>

<script setup>
import { hitungUsia, formatTanggal as fmtTgl } from "@/utils/format.js";

defineProps({
    anak: { type: Object, required: true },
    /** Status tinggi badan menurut umur dari pengukuran terakhir */
    statusTbuTerakhir: { type: String, default: null },
});

const formatTanggal = (tgl) => fmtTgl(tgl);
</script>
