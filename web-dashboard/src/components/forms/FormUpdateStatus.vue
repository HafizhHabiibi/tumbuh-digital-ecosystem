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
                    >Prioritas pemantauan</span
                >
                <StatusBadge
                    type="prioritas"
                    :value="rujukan.kategori_prioritas"
                />
            </div>
        </div>

        <!-- Error -->
        <Transition name="slide-down">
            <div
                v-if="error"
                class="error-alert flex items-start gap-2 px-3 py-2.5 rounded-xl text-sm"
                role="alert"
                aria-live="assertive"
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
                maxlength="2000"
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
import { computed, reactive } from "vue";
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
const STATUS_OPTIONS = ["ditangani", "selesai"];
const ikonStatus = {
    ditangani: "pi-sync",
    selesai: "pi-check-circle",
};
const statusOptions = computed(() =>
    STATUS_OPTIONS.filter((s) => s !== props.rujukan.status).map((s) => ({
        value: s,
        label: LABEL_STATUS[s],
        icon: ikonStatus[s],
    })),
);

/* ── Warna ───────────────────────────────────────────────────────── */
const warnaHex = {
    ditangani: "#d97706",
    selesai: "#6b7280",
};
const warnaBg = {
    ditangani: "#fef3c7",
    selesai: "#f3f4f6",
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
