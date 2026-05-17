<template>
    <form class="space-y-4 pt-4" novalidate @submit.prevent="handleSubmit">
        <!-- Info rujukan -->
        <div
            class="rounded-xl p-3 space-y-1"
            style="
                background: var(--color-green-50);
                border: 1px solid var(--color-input-border);
            "
        >
            <div class="flex items-center justify-between">
                <span class="text-xs" style="color: var(--color-text-muted)"
                    >Anak</span
                >
                <span
                    class="text-sm font-semibold"
                    style="color: var(--color-text-heading)"
                    >{{ rujukan.nama_anak }}</span
                >
            </div>
            <div class="flex items-center justify-between">
                <span class="text-xs" style="color: var(--color-text-muted)"
                    >Status saat ini</span
                >
                <StatusBadge type="rujukan" :value="rujukan.status" />
            </div>
            <div class="flex items-center justify-between">
                <span class="text-xs" style="color: var(--color-text-muted)"
                    >Risiko</span
                >
                <StatusBadge type="risiko" :value="rujukan.kategori_risiko" />
            </div>
        </div>

        <!-- Error -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                style="
                    background: #fef2f2;
                    border: 1px solid #fecaca;
                    color: #b91c1c;
                "
                role="alert"
            >
                <i
                    class="pi pi-exclamation-circle mt-0.5 flex-shrink-0"
                    aria-hidden="true"
                />
                <span>{{ error }}</span>
            </div>
        </Transition>

        <!-- Pilih status baru -->
        <div class="space-y-1.5">
            <label class="field-label">Status Baru</label>
            <div class="grid grid-cols-2 gap-2">
                <label
                    v-for="s in statusOptions"
                    :key="s.value"
                    class="flex items-center gap-2 px-3 py-2.5 rounded-xl cursor-pointer border text-sm transition-all"
                    :style="
                        form.status === s.value
                            ? `background: ${warnaBg[s.value]}; border-color: ${warnaHex[s.value]}; color: ${warnaHex[s.value]}`
                            : 'background: var(--color-input-bg); border-color: var(--color-input-border); color: var(--color-text-body)'
                    "
                >
                    <input
                        type="radio"
                        :value="s.value"
                        v-model="form.status"
                        :disabled="loading"
                        class="sr-only"
                    />
                    <i :class="`pi ${s.icon} text-sm`" aria-hidden="true" />
                    <span class="font-medium text-xs">{{ s.label }}</span>
                </label>
            </div>
        </div>

        <!-- Catatan puskesmas -->
        <div class="space-y-1.5">
            <label for="catatan_puskesmas" class="field-label">
                Catatan Puskesmas
                <span
                    class="text-xs font-normal"
                    style="color: var(--color-text-muted)"
                    >(opsional)</span
                >
            </label>
            <textarea
                id="catatan_puskesmas"
                v-model="form.catatan_puskesmas"
                rows="3"
                placeholder="Hasil pemeriksaan, tindakan yang dilakukan, dll..."
                :disabled="loading"
                class="input-field w-full px-4 py-2.5 rounded-xl text-sm resize-none"
            />
        </div>

        <!-- Tombol aksi -->
        <div class="flex gap-3 pt-2">
            <button
                type="button"
                :disabled="loading"
                class="flex-1 py-2.5 rounded-xl text-sm font-semibold border"
                style="
                    background: white;
                    color: var(--color-text-body);
                    border-color: var(--color-input-border);
                "
                @click="$emit('cancel')"
            >
                Batal
            </button>
            <button
                type="submit"
                :disabled="loading || !form.status"
                class="btn-submit flex-1 py-2.5 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed"
            >
                <i
                    v-if="loading"
                    class="pi pi-spin pi-spinner"
                    aria-hidden="true"
                />
                <span>{{ loading ? "Menyimpan..." : "Simpan" }}</span>
            </button>
        </div>
    </form>
</template>

<script setup>
import { reactive } from "vue";
import { LABEL_STATUS } from "@/stores/rujukanStore";
import StatusBadge from "@/components/ui/StatusBadge.vue";

const props = defineProps({
    rujukan: { type: Object, required: true },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
});
const emit = defineEmits(["submit", "cancel"]);

const form = reactive({
    status: "",
    catatan_puskesmas: "",
});

/* ── Status yang bisa dipilih (exclude status saat ini & yang tidak valid) */
const STATUS_OPTIONS = ["diterima", "dalam_penanganan", "selesai", "ditolak"];
const ikonStatus = {
    diterima: "pi-check",
    dalam_penanganan: "pi-sync",
    selesai: "pi-check-circle",
    ditolak: "pi-times-circle",
};
const statusOptions = STATUS_OPTIONS.filter(
    (s) => s !== props.rujukan.status,
).map((s) => ({ value: s, label: LABEL_STATUS[s], icon: ikonStatus[s] }));

/* ── Warna ───────────────────────────────────────────────────────── */
const warnaHex = {
    diterima: "#15803d",
    dalam_penanganan: "#d97706",
    selesai: "#6b7280",
    ditolak: "#dc2626",
};
const warnaBg = {
    diterima: "#dcfce7",
    dalam_penanganan: "#fef3c7",
    selesai: "#f3f4f6",
    ditolak: "#fee2e2",
};

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = () => {
    if (!form.status || props.loading) return;
    const payload = { status: form.status };
    if (form.catatan_puskesmas.trim())
        payload.catatan_puskesmas = form.catatan_puskesmas.trim();
    emit("submit", payload);
};
</script>

<style scoped>
.field-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    margin-left: 0.25rem;
    color: var(--color-text-body);
}
.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
    font-family: "Poppins", sans-serif;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-field:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
.btn-submit {
    background: linear-gradient(
        135deg,
        var(--color-green-600),
        var(--color-green-800)
    );
    box-shadow: 0 2px 8px var(--color-shadow-green);
    border: none;
    cursor: pointer;
}
.btn-submit:hover:not(:disabled) {
    filter: brightness(1.08);
}
.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.25s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-6px);
}
</style>
