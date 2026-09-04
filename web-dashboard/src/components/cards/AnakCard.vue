<template>
    <!--
        AnakCard.vue
        Card ringkasan info anak — dipakai di DetailAnakView bagian atas.
        Menampilkan identitas, usia, orang tua, dan status TB/U terakhir.
    -->
    <div class="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-5 md:p-6">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-5">
            <!-- Sisi Kiri: Avatar & Info Pokok -->
            <div class="flex items-start gap-4 flex-1 min-w-0">
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

                <!-- Nama & Badges -->
                <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2.5 flex-wrap mb-1.5">
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

                        <!-- Status TB/U badge -->
                        <StatusBadge
                            v-if="statusTbuTerakhir"
                            type="antropometri"
                            :value="statusTbuTerakhir"
                        />
                    </div>

                    <p class="text-xs text-slate-400 m-0">
                        Terdaftar di sistem Posyandu Digital
                    </p>
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

        <!-- Grid Data Demografi Mini -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-5 mt-5 border-t border-slate-100">
            <!-- Tanggal Lahir -->
            <div
                class="flex items-center gap-2.5 text-xs text-slate-600 bg-slate-50/70 p-3 rounded-xl border border-slate-100"
            >
                <div
                    class="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 flex-shrink-0 shadow-2xs"
                >
                    <i class="pi pi-calendar text-xs" aria-hidden="true" />
                </div>
                <div class="min-w-0">
                    <div class="text-[10px] text-slate-400 font-medium">Tanggal Lahir</div>
                    <div class="font-semibold text-slate-700 truncate">
                        {{ formatTanggal(anak.tanggal_lahir) }}
                    </div>
                </div>
            </div>

            <!-- Usia Saat Ini -->
            <div
                class="flex items-center gap-2.5 text-xs text-slate-600 bg-slate-50/70 p-3 rounded-xl border border-slate-100"
            >
                <div
                    class="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 flex-shrink-0 shadow-2xs"
                >
                    <i class="pi pi-clock text-xs" aria-hidden="true" />
                </div>
                <div class="min-w-0">
                    <div class="text-[10px] text-slate-400 font-medium">Usia Saat Ini</div>
                    <div class="font-semibold text-slate-700 truncate">
                        {{ hitungUsia(anak.tanggal_lahir) }}
                    </div>
                </div>
            </div>

            <!-- Orang Tua -->
            <div
                class="flex items-center gap-2.5 text-xs text-slate-600 bg-slate-50/70 p-3 rounded-xl border border-slate-100"
            >
                <div
                    class="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 flex-shrink-0 shadow-2xs"
                >
                    <i class="pi pi-user text-xs" aria-hidden="true" />
                </div>
                <div class="min-w-0">
                    <div class="text-[10px] text-slate-400 font-medium">Nama Orang Tua</div>
                    <div
                        class="font-semibold text-slate-700 truncate"
                        :title="anak.nama_orang_tua"
                    >
                        {{ anak.nama_orang_tua || "—" }}
                    </div>
                </div>
            </div>

            <!-- NIK / No Identitas -->
            <div
                class="flex items-center gap-2.5 text-xs text-slate-600 bg-slate-50/70 p-3 rounded-xl border border-slate-100"
            >
                <div
                    class="w-8 h-8 rounded-lg bg-white border border-slate-200/60 flex items-center justify-center text-slate-400 flex-shrink-0 shadow-2xs"
                >
                    <i class="pi pi-id-card text-xs" aria-hidden="true" />
                </div>
                <div class="min-w-0">
                    <div class="text-[10px] text-slate-400 font-medium">Nomor NIK</div>
                    <div class="font-semibold text-slate-700 font-mono truncate">
                        {{ anak.nik || "—" }}
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import StatusBadge from "@/components/ui/StatusBadge.vue";
import { hitungUsia, formatTanggal as fmtTgl } from "@/utils/format.js";

defineProps({
    anak: { type: Object, required: true },
    /** Status tinggi badan menurut umur dari pengukuran terakhir */
    statusTbuTerakhir: { type: String, default: null },
});

const formatTanggal = (tgl) => fmtTgl(tgl);
</script>
