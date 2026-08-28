<template>
    <div
        v-if="pagination.total > 0"
        class="flex items-center justify-between gap-3 px-4 py-3 border-t flex-wrap"
        style="border-color: var(--color-input-border)"
        aria-label="Navigasi halaman"
    >
        <p class="text-xs m-0" style="color: var(--color-text-muted)">
            Menampilkan {{ itemStart }}–{{ itemEnd }} dari
            {{ pagination.total }} data
        </p>

        <div class="flex items-center gap-2">
            <button
                type="button"
                class="pagination-button"
                :disabled="loading || pagination.page <= 1"
                aria-label="Halaman sebelumnya"
                @click="$emit('change-page', pagination.page - 1)"
            >
                <i class="pi pi-chevron-left text-xs" aria-hidden="true" />
                <span>Sebelumnya</span>
            </button>

            <span
                class="text-xs font-semibold px-2"
                style="color: var(--color-text-body)"
            >
                {{ pagination.page }} / {{ totalPages }}
            </span>

            <button
                type="button"
                class="pagination-button"
                :disabled="loading || pagination.page >= totalPages"
                aria-label="Halaman berikutnya"
                @click="$emit('change-page', pagination.page + 1)"
            >
                <span>Berikutnya</span>
                <i class="pi pi-chevron-right text-xs" aria-hidden="true" />
            </button>
        </div>
    </div>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
    pagination: {
        type: Object,
        default: () => ({
            page: 1,
            limit: 20,
            total: 0,
            total_pages: 0,
        }),
    },
    loading: { type: Boolean, default: false },
});

defineEmits(["change-page"]);

const totalPages = computed(() => Math.max(props.pagination.total_pages, 1));
const itemStart = computed(
    () => (props.pagination.page - 1) * props.pagination.limit + 1,
);
const itemEnd = computed(() =>
    Math.min(
        props.pagination.page * props.pagination.limit,
        props.pagination.total,
    ),
);
</script>

<style scoped>
.pagination-button {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.45rem 0.7rem;
    border: 1px solid var(--color-input-border);
    border-radius: 0.625rem;
    background: white;
    color: var(--color-text-body);
    font-family: "Poppins", sans-serif;
    font-size: 0.72rem;
    font-weight: 500;
    cursor: pointer;
    transition:
        border-color 0.15s,
        background 0.15s,
        color 0.15s;
}

.pagination-button:hover:not(:disabled) {
    background: var(--color-green-50);
    border-color: var(--color-green-700);
    color: var(--color-green-700);
}

.pagination-button:disabled {
    opacity: 0.45;
    cursor: not-allowed;
}
</style>
