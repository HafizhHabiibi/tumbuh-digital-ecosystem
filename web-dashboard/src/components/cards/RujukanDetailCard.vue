<template>
    <div class="space-y-4 pt-4">
        <!-- Status badge -->
        <div class="flex items-center justify-between flex-wrap gap-2">
            <span
                class="text-xs px-3 py-1.5 rounded-full font-semibold"
                :style="`background: ${warnaBg[rujukan.status]}; color: ${warnaHex[rujukan.status]}`"
            >
                {{ LABEL_STATUS[rujukan.status] ?? rujukan.status }}
            </span>
            <span class="text-xs" style="color: var(--color-text-muted)">
                {{ formatTanggal(rujukan.created_at) }}
            </span>
        </div>

        <!-- Info anak -->
        <div
            class="rounded-xl p-4 space-y-2"
            style="
                background: var(--color-green-50);
                border: 1px solid var(--color-input-border);
            "
        >
            <p
                class="text-xs font-semibold uppercase tracking-wider m-0"
                style="color: var(--color-text-muted)"
            >
                Info Anak
            </p>
            <div class="grid grid-cols-2 gap-x-4 gap-y-1.5 text-sm">
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Nama
                    </p>
                    <p
                        class="font-semibold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        {{ rujukan.nama_anak }}
                    </p>
                </div>
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Orang Tua
                    </p>
                    <p
                        class="font-medium m-0"
                        style="color: var(--color-text-body)"
                    >
                        {{ rujukan.nama_orang_tua }}
                    </p>
                </div>
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Tanggal Lahir
                    </p>
                    <p
                        class="font-medium m-0"
                        style="color: var(--color-text-body)"
                    >
                        {{ formatTanggal(rujukan.tanggal_lahir) }}
                    </p>
                </div>
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        No. HP Orang Tua
                    </p>
                    <p
                        class="font-medium m-0"
                        style="color: var(--color-text-body)"
                    >
                        {{ rujukan.no_hp_orang_tua }}
                    </p>
                </div>
            </div>
        </div>

        <!-- Hasil pengukuran & SAW -->
        <div
            class="rounded-xl p-4 space-y-2"
            style="
                background: white;
                border: 1px solid var(--color-input-border);
            "
        >
            <p
                class="text-xs font-semibold uppercase tracking-wider m-0"
                style="color: var(--color-text-muted)"
            >
                Hasil Pengukuran
            </p>
            <div class="grid grid-cols-2 gap-x-4 gap-y-1.5 text-sm">
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Berat Badan
                    </p>
                    <p
                        class="font-semibold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        {{ rujukan.berat_badan }} kg
                    </p>
                </div>
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Tinggi Badan
                    </p>
                    <p
                        class="font-semibold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        {{ rujukan.tinggi_badan }} cm
                    </p>
                </div>
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Prioritas Pemantauan
                    </p>
                    <span
                        class="text-xs px-2 py-0.5 rounded-full font-semibold capitalize"
                        :style="`background: ${warnaBg[rujukan.kategori_prioritas]}; color: ${warnaHex[rujukan.kategori_prioritas]}`"
                    >
                        {{ rujukan.kategori_prioritas ?? "—" }}
                    </span>
                </div>
                <div>
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Skor SAW
                    </p>
                    <p
                        class="font-mono font-semibold m-0"
                        style="color: var(--color-text-heading)"
                    >
                        {{ formatSkor(rujukan.skor_saw) }}
                    </p>
                </div>
            </div>
            <div class="grid grid-cols-2 gap-x-4 gap-y-1.5 pt-1">
                <div
                    v-for="item in statusAntropometri"
                    :key="item.label"
                >
                    <p
                        class="text-xs m-0"
                        style="color: var(--color-text-muted)"
                    >
                        Status {{ item.label }}
                    </p>
                    <p
                        class="text-sm font-semibold m-0 capitalize"
                        style="color: var(--color-text-heading)"
                    >
                        {{ formatStatus(item.value) }}
                    </p>
                </div>
            </div>
        </div>

        <!-- Catatan kader -->
        <div
            class="rounded-xl p-4 space-y-1"
            style="
                background: white;
                border: 1px solid var(--color-input-border);
            "
        >
            <p
                class="text-xs font-semibold uppercase tracking-wider m-0"
                style="color: var(--color-text-muted)"
            >
                Catatan Kader
            </p>
            <p class="text-sm m-0" style="color: var(--color-text-body)">
                {{ rujukan.catatan_kader }}
            </p>
            <p class="text-xs m-0" style="color: var(--color-text-muted)">
                Dicatat oleh: {{ rujukan.nama_kader }}
            </p>
        </div>

        <!-- Catatan puskesmas -->
        <div
            v-if="rujukan.catatan_puskesmas"
            class="rounded-xl p-4 space-y-1"
            style="
                background: white;
                border: 1px solid var(--color-input-border);
            "
        >
            <p
                class="text-xs font-semibold uppercase tracking-wider m-0"
                style="color: var(--color-text-muted)"
            >
                Catatan Puskesmas
            </p>
            <p class="text-sm m-0" style="color: var(--color-text-body)">
                {{ rujukan.catatan_puskesmas }}
            </p>
            <p
                v-if="rujukan.ditangani_oleh"
                class="text-xs m-0"
                style="color: var(--color-text-muted)"
            >
                Ditangani oleh: {{ rujukan.ditangani_oleh }}
            </p>
        </div>
    </div>
</template>

<script setup>
import { LABEL_STATUS } from "@/stores/rujukanStore";

const props = defineProps({
    rujukan: { type: Object, required: true },
});

const warnaHex = {
    diajukan: "#2563eb",
    ditangani: "#d97706",
    selesai: "#6b7280",
    rendah: "#15803d",
    sedang: "#d97706",
    tinggi: "#dc2626",
};
const warnaBg = {
    diajukan: "#dbeafe",
    ditangani: "#fef3c7",
    selesai: "#f3f4f6",
    rendah: "#dcfce7",
    sedang: "#fef3c7",
    tinggi: "#fee2e2",
};

const formatTanggal = (tgl) =>
    tgl
        ? new Date(tgl).toLocaleDateString("id-ID", {
              day: "numeric",
              month: "long",
              year: "numeric",
          })
        : "—";

const statusAntropometri = [
    { label: "BB/U", value: props.rujukan.status_bbu },
    { label: "TB/U", value: props.rujukan.status_tbu },
    { label: "BB/TB", value: props.rujukan.status_bbtb },
    { label: "IMT/U", value: props.rujukan.status_imtu },
];

const formatStatus = (value) => value?.replaceAll("_", " ") ?? "—";
const formatSkor = (value) =>
    value === null || value === undefined ? "—" : Number(value).toFixed(4);
</script>
