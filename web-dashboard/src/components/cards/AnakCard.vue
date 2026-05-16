<template>
    <!--
        AnakCard.vue
        Card ringkasan info anak — dipakai di DetailAnakView bagian atas.
        Menampilkan identitas, usia, orang tua, dan status gizi terakhir.
    -->
    <div class="card p-5 rounded-2xl">
        <div class="flex items-start gap-4 flex-wrap">
            <!-- Avatar -->
            <div
                class="w-14 h-14 rounded-2xl flex items-center justify-center text-xl font-bold text-white flex-shrink-0"
                :style="`background: ${anak.jenis_kelamin === 'L' ? '#0284c7' : '#db2777'}`"
                aria-hidden="true"
            >
                {{ anak.nama.charAt(0).toUpperCase() }}
            </div>

            <!-- Info utama -->
            <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 flex-wrap mb-1">
                    <h2
                        class="text-lg font-bold m-0 truncate"
                        style="color: var(--color-text-heading)"
                    >
                        {{ anak.nama }}
                    </h2>
                    <StatusBadge type="jk" :value="anak.jenis_kelamin" />
                    <StatusBadge
                        v-if="statusGiziTerakhir"
                        type="gizi"
                        :value="statusGiziTerakhir"
                    />
                </div>

                <!-- Detail info -->
                <div class="flex flex-wrap gap-x-4 gap-y-1 text-sm">
                    <span style="color: var(--color-text-muted)">
                        <i
                            class="pi pi-calendar mr-1 text-xs"
                            aria-hidden="true"
                        />
                        {{ formatTanggal(anak.tanggal_lahir) }}
                    </span>
                    <span style="color: var(--color-text-muted)">
                        <i
                            class="pi pi-clock mr-1 text-xs"
                            aria-hidden="true"
                        />
                        {{ hitungUsia(anak.tanggal_lahir) }}
                    </span>
                    <span
                        v-if="anak.nama_orang_tua"
                        style="color: var(--color-text-muted)"
                    >
                        <i class="pi pi-user mr-1 text-xs" aria-hidden="true" />
                        {{ anak.nama_orang_tua }}
                    </span>
                    <span
                        v-if="anak.no_kk"
                        style="color: var(--color-text-muted)"
                    >
                        <i
                            class="pi pi-id-card mr-1 text-xs"
                            aria-hidden="true"
                        />
                        No. KK: {{ anak.no_kk }}
                    </span>
                </div>
            </div>

            <!-- Slot aksi opsional (misal tombol edit) -->
            <slot name="actions" />
        </div>
    </div>
</template>

<script setup>
import StatusBadge from "@/components/ui/StatusBadge.vue";

const props = defineProps({
    anak: { type: Object, required: true },
    /** Status gizi dari pengukuran terakhir */
    statusGiziTerakhir: { type: String, default: null },
});

const formatTanggal = (tgl) =>
    new Date(tgl).toLocaleDateString("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
    });

const hitungUsia = (tgl) => {
    const bulan = Math.floor(
        (new Date() - new Date(tgl)) / (1000 * 60 * 60 * 24 * 30.44),
    );
    if (bulan < 24) return `${bulan} bulan`;
    return `${Math.floor(bulan / 12)} thn ${bulan % 12} bln`;
};
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
</style>
