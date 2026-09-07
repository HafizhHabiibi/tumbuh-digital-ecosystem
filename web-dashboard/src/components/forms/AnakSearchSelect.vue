<template>
    <div ref="rootRef" class="space-y-2">
        <div class="flex items-center justify-between gap-3">
            <label :for="inputId" class="text-sm font-semibold text-slate-800">
                {{ label }}
            </label>
            <span v-if="options.length > 0" class="text-xs text-slate-400">
                {{ options.length }} anak terdaftar
            </span>
        </div>

        <div class="relative">
            <i
                class="pi pi-search input-icon text-slate-400"
                aria-hidden="true"
            />
            <input
                :id="inputId"
                ref="inputRef"
                v-model="query"
                type="search"
                role="combobox"
                autocomplete="off"
                aria-autocomplete="list"
                :placeholder="placeholder"
                :disabled="disabled || loading"
                :aria-expanded="resultsOpen"
                :aria-controls="listboxId"
                :aria-activedescendant="activeDescendant"
                :aria-invalid="invalid"
                :aria-describedby="describedBy || undefined"
                class="anak-search-input input-field w-full pl-9 pr-9 py-2.5 rounded-xl text-sm"
                @focus="openResults"
                @input="openResults"
                @keydown="handleKeydown"
            />
            <button
                v-if="query"
                type="button"
                class="absolute right-2.5 top-1/2 -translate-y-1/2 w-7 h-7 inline-flex items-center justify-center rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100 cursor-pointer"
                aria-label="Hapus pencarian anak"
                @click="clearQuery"
            >
                <i class="pi pi-times text-xs" aria-hidden="true" />
            </button>

            <div
                v-if="resultsOpen"
                :id="listboxId"
                role="listbox"
                :aria-label="`Hasil ${label.toLowerCase()}`"
                class="absolute z-30 left-0 right-0 mt-1.5 overflow-hidden rounded-xl border border-slate-200 bg-white shadow-xl"
            >
                <div
                    class="px-3 py-2 text-[11px] font-medium text-slate-500 bg-slate-50 border-b border-slate-100"
                    aria-live="polite"
                >
                    {{ resultSummary }}
                </div>

                <div v-if="loading" class="px-3 py-4 text-xs text-slate-500 text-center">
                    <i class="pi pi-spin pi-spinner mr-1.5" aria-hidden="true" />
                    Memuat data anak...
                </div>
                <div
                    v-else-if="filteredOptions.length === 0"
                    class="px-3 py-5 text-xs text-slate-500 text-center"
                >
                    Tidak ada anak yang cocok
                </div>
                <ul v-else class="max-h-64 overflow-y-auto py-1">
                    <li
                        v-for="(anak, index) in visibleOptions"
                        :id="optionDomId(index)"
                        :key="anak.id"
                        role="option"
                        :aria-selected="index === activeIndex"
                        class="px-3 py-2.5 flex items-start gap-3 cursor-pointer transition-colors"
                        :class="index === activeIndex ? 'bg-emerald-50' : 'hover:bg-slate-50'"
                        @mouseenter="activeIndex = index"
                        @mousedown.prevent
                        @click="selectOption(anak)"
                    >
                        <span
                            class="w-8 h-8 rounded-lg flex items-center justify-center text-xs font-bold shrink-0"
                            :class="anak.jenis_kelamin === 'P' ? 'bg-rose-100 text-rose-700' : 'bg-blue-100 text-blue-700'"
                            aria-hidden="true"
                        >
                            {{ initials(anak.nama) }}
                        </span>
                        <span class="min-w-0 flex-1">
                            <span class="block text-sm font-semibold text-slate-800 truncate">
                                {{ anak.nama || "Nama tidak tersedia" }}
                            </span>
                            <span class="block text-xs text-slate-500 truncate mt-0.5">
                                Orang tua: {{ anak.nama_orang_tua || "—" }}
                                <template v-if="anak.nik"> • NIK: {{ anak.nik }}</template>
                            </span>
                        </span>
                        <i
                            v-if="index === activeIndex"
                            class="pi pi-arrow-turn-down-left text-xs text-emerald-600 mt-1"
                            aria-hidden="true"
                        />
                    </li>
                </ul>

                <div
                    v-if="filteredOptions.length > visibleOptions.length"
                    class="px-3 py-2 text-[11px] text-slate-500 bg-slate-50 border-t border-slate-100"
                >
                    Ketik pencarian yang lebih spesifik untuk melihat hasil lainnya.
                </div>
            </div>
        </div>

        <div
            v-if="error"
            class="flex items-center justify-between gap-3 text-xs text-red-700 bg-red-50 p-2.5 rounded-xl border border-red-200"
            role="alert"
        >
            <span>{{ error }}</span>
            <button
                type="button"
                class="font-semibold underline cursor-pointer shrink-0"
                @click="$emit('retry')"
            >
                Coba lagi
            </button>
        </div>
    </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";
import {
    filterAnakOptions,
    nextAnakSearchIndex,
} from "@/utils/anakSearch.js";

const MAX_VISIBLE_OPTIONS = 50;

const props = defineProps({
    modelValue: { type: [String, Number], default: "" },
    options: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    disabled: { type: Boolean, default: false },
    invalid: { type: Boolean, default: false },
    inputId: { type: String, required: true },
    label: { type: String, default: "Pilih Anak" },
    placeholder: {
        type: String,
        default: "Cari nama anak, orang tua, atau NIK...",
    },
    describedBy: { type: String, default: null },
});

const emit = defineEmits(["update:modelValue", "retry"]);
const rootRef = ref(null);
const inputRef = ref(null);
const query = ref("");
const isOpen = ref(false);
const activeIndex = ref(-1);

const listboxId = computed(() => `${props.inputId}-listbox`);
const filteredOptions = computed(() =>
    filterAnakOptions(props.options, query.value),
);
const visibleOptions = computed(() =>
    filteredOptions.value.slice(0, MAX_VISIBLE_OPTIONS),
);
const resultsOpen = computed(() =>
    isOpen.value && !props.disabled,
);
const activeDescendant = computed(() =>
    resultsOpen.value && activeIndex.value >= 0
        ? optionDomId(activeIndex.value)
        : undefined,
);
const resultSummary = computed(() => {
    if (props.loading) return "Memuat data anak...";
    const total = filteredOptions.value.length;
    return total === 1 ? "1 anak ditemukan" : `${total} anak ditemukan`;
});

const optionDomId = (index) => `${props.inputId}-option-${index}`;
const initials = (name) => {
    const words = String(name || "A").trim().split(/\s+/).filter(Boolean);
    return words.slice(0, 2).map((word) => word[0]).join("").toUpperCase();
};

const openResults = () => {
    if (props.disabled) return;
    isOpen.value = true;
    activeIndex.value = visibleOptions.value.length ? 0 : -1;
};

const closeResults = () => {
    isOpen.value = false;
    activeIndex.value = -1;
};

const clearQuery = () => {
    query.value = "";
    openResults();
    inputRef.value?.focus();
};

const selectOption = (anak) => {
    if (!anak) return;
    emit("update:modelValue", anak.id);
    query.value = anak.nama || "";
    closeResults();
};

const handleKeydown = (event) => {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
        event.preventDefault();
        if (!resultsOpen.value) openResults();
        activeIndex.value = nextAnakSearchIndex(
            activeIndex.value,
            visibleOptions.value.length,
            event.key === "ArrowDown" ? 1 : -1,
        );
        return;
    }
    if (event.key === "Enter" && resultsOpen.value && activeIndex.value >= 0) {
        event.preventDefault();
        selectOption(visibleOptions.value[activeIndex.value]);
        return;
    }
    if (event.key === "Escape" && resultsOpen.value) {
        event.preventDefault();
        closeResults();
    }
};

const handleOutsidePointer = (event) => {
    if (!rootRef.value?.contains(event.target)) closeResults();
};

watch(filteredOptions, () => {
    activeIndex.value = visibleOptions.value.length ? 0 : -1;
});

watch(
    () => props.modelValue,
    (value) => {
        if (!value) query.value = "";
    },
);

onMounted(() => document.addEventListener("pointerdown", handleOutsidePointer));
onBeforeUnmount(() =>
    document.removeEventListener("pointerdown", handleOutsidePointer),
);

defineExpose({
    focus: () => inputRef.value?.focus(),
});
</script>

<style scoped>
.anak-search-input::-webkit-search-cancel-button {
    display: none;
    appearance: none;
    -webkit-appearance: none;
}

.anak-search-input::-ms-clear {
    display: none;
}
</style>
