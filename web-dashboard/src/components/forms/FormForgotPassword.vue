<template>
    <section
        class="forgot-form-section flex-1 flex items-center justify-center p-6 md:p-10"
        aria-label="Form lupa password"
    >
        <div class="w-full max-w-md">
            <!-- ─── Logo mobile (hanya tampil < md) ───────────────────── -->
            <div class="md:hidden flex flex-col items-center mb-8">
                <BrandingIllustration
                    image-class="w-24 h-auto mb-3 illustration--green"
                    aria-label="Logo Tumbuh"
                />
                <span class="text-2xl font-bold text-brand-primary"
                    >Tumbuh</span
                >
            </div>

            <!-- ─── Card ──────────────────────────────────────────────── -->
            <div class="form-card rounded-2xl p-8">
                <!-- Back link -->
                <RouterLink
                    :to="{ name: 'Login' }"
                    class="back-link inline-flex items-center gap-1.5 text-sm font-semibold mb-6 transition-opacity hover:opacity-70"
                >
                    <i class="pi pi-arrow-left text-xs" aria-hidden="true" />
                    Kembali ke Login
                </RouterLink>

                <!-- Icon + Heading -->
                <header class="mb-8">
                    <div class="icon-box mb-4" aria-hidden="true">
                        <i class="pi pi-envelope text-xl" />
                    </div>
                    <h1 class="text-2xl font-semibold mb-1 text-heading">
                        Lupa Password?
                    </h1>
                    <p class="text-sm text-body leading-relaxed">
                        Masukkan email yang terdaftar. Kami akan mengirimkan
                        tautan untuk mereset password kamu.
                    </p>
                </header>

                <!-- ── Success state ──────────────────────────────────── -->
                <Transition name="slide-down">
                    <div
                        v-if="submitted"
                        class="success-alert mb-6 flex items-start gap-3 rounded-xl px-4 py-3.5 text-sm"
                        role="status"
                        aria-live="polite"
                    >
                        <i
                            class="pi pi-check-circle mt-0.5 flex-shrink-0"
                            aria-hidden="true"
                        />
                        <div>
                            <p class="font-semibold">Email terkirim!</p>
                            <p class="mt-0.5 opacity-90">
                                Cek inbox kamu di
                                <strong>{{ submittedEmail }}</strong>
                                dan ikuti instruksi di dalamnya.
                            </p>
                        </div>
                    </div>
                </Transition>

                <!-- ── Error alert ────────────────────────────────────── -->
                <Transition name="slide-down">
                    <div
                        v-if="error"
                        class="error-alert mb-5 flex items-start gap-3 rounded-xl px-4 py-3 text-sm"
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

                <!-- ── Turnstile — selalu tampil, baik form maupun resend ── -->
                <!-- [1] Satu instance saja, ditampilkan di luar v-if/v-else  -->
                <!--     agar widget tidak destroy/recreate saat state berubah -->
                <div class="flex justify-center mb-5">
                    <VueTurnstile
                        ref="turnstileRef"
                        :site-key="siteKey"
                        action="forgot-password"
                        theme="light"
                        v-model="token"
                    />
                </div>

                <!-- ── Form (tersembunyi setelah sukses) ──────────────── -->
                <form
                    v-if="!submitted"
                    novalidate
                    @submit.prevent="$emit('submit')"
                >
                    <div class="space-y-5">
                        <div class="space-y-1.5">
                            <label
                                for="forgot-email"
                                class="text-sm font-semibold block ml-1 text-body"
                            >
                                Alamat Email
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-envelope input-icon"
                                    aria-hidden="true"
                                />
                                <input
                                    id="forgot-email"
                                    :value="email"
                                    type="email"
                                    placeholder="nama@instansi.com"
                                    autocomplete="email"
                                    :disabled="loading"
                                    class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!error"
                                    @input="
                                        $emit(
                                            'update:email',
                                            $event.target.value,
                                        )
                                    "
                                />
                            </div>
                        </div>

                        <button
                            type="submit"
                            :disabled="loading || !isValid || !turnstileToken"
                            class="btn-primary w-full text-white font-semibold text-sm py-3.5 rounded-xl transition-all duration-200 active:scale-95 flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed disabled:active:scale-100"
                            :aria-busy="loading"
                        >
                            <template v-if="loading">
                                <i
                                    class="pi pi-spin pi-spinner"
                                    aria-hidden="true"
                                />
                                <span>Mengirim...</span>
                            </template>
                            <template v-else>
                                <span>Kirim Tautan Reset</span>
                                <i class="pi pi-send" aria-hidden="true" />
                            </template>
                        </button>
                    </div>
                </form>

                <!-- ── Kirim ulang (setelah sukses) ───────────────────── -->
                <div v-else class="mt-2">
                    <p class="text-sm text-body text-center">
                        Tidak menerima email?
                        <button
                            type="button"
                            class="font-bold text-brand-primary hover:opacity-70 transition-opacity disabled:opacity-40"
                            :disabled="loading || !turnstileToken"
                            @click="$emit('resend')"
                        >
                            Kirim ulang
                        </button>
                    </p>
                </div>
            </div>
        </div>
    </section>
</template>

<script setup>
import { ref, computed } from "vue";
import VueTurnstile from "vue-turnstile";
import BrandingIllustration from "@/components/ui/BrandingIllustration.vue";

const props = defineProps({
    email: { type: String, required: true },
    turnstileToken: { type: String, default: "" },
    isValid: { type: Boolean, default: false },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    submitted: { type: Boolean, default: false },
    submittedEmail: { type: String, default: "" },
});

const emit = defineEmits([
    "submit",
    "update:email",
    "update:turnstileToken",
    "resend",
]);

const siteKey = import.meta.env.VITE_TURNSTILE_SITE_KEY;

// [2] Ref ke instance VueTurnstile untuk akses method .reset()
const turnstileRef = ref(null);

// [3] Computed writable sebagai jembatan v-model untuk VueTurnstile
const token = computed({
    get: () => props.turnstileToken,
    set: (val) => emit("update:turnstileToken", val),
});

// [4] Expose resetTurnstile agar bisa dipanggil dari parent
defineExpose({
    resetTurnstile: () => turnstileRef.value?.reset(),
});
</script>

<style scoped>
.forgot-form-section {
    background: var(--color-surface);
}

.form-card {
    background: white;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
    border: 1px solid rgba(190, 202, 184, 0.4);
}

/* ─── Icon dekoratif ──────────────────────────────────────────────── */
.icon-box {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 3rem;
    height: 3rem;
    border-radius: 0.875rem;
    background: linear-gradient(
        135deg,
        var(--color-green-600),
        var(--color-green-700)
    );
    color: white;
    box-shadow: 0 4px 12px var(--color-shadow-green);
}

/* ─── Tipografi & link ────────────────────────────────────────────── */
.text-heading {
    color: var(--color-text-heading);
}
.text-body {
    color: var(--color-text-body);
}
.text-brand-primary {
    color: var(--color-green-700);
}
.back-link {
    color: var(--color-green-700);
}

/* ─── Input ───────────────────────────────────────────────────────── */
.input-field {
    background: var(--color-input-bg);
    border: 1px solid var(--color-input-border);
    color: var(--color-text-heading);
    outline: none;
    transition:
        border-color 0.2s,
        box-shadow 0.2s;
}
.input-field::placeholder {
    color: var(--color-text-muted);
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-field:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}

.input-icon {
    position: absolute;
    left: 1rem;
    top: 50%;
    transform: translateY(-50%);
    color: var(--color-text-muted);
    pointer-events: none;
}

/* ─── Tombol ──────────────────────────────────────────────────────── */
.btn-primary {
    background: linear-gradient(
        135deg,
        var(--color-green-600) 0%,
        var(--color-green-700) 60%,
        var(--color-green-900) 100%
    );
    box-shadow: 0 4px 14px var(--color-shadow-green);
}
.btn-primary:hover:not(:disabled) {
    filter: brightness(1.08);
    box-shadow: 0 6px 18px var(--color-shadow-green-hover);
}

/* ─── Alert ───────────────────────────────────────────────────────── */
.error-alert {
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #b91c1c;
}
.success-alert {
    background: #f0fdf4;
    border: 1px solid #bbf7d0;
    color: #15803d;
}

/* ─── Ilustrasi mobile ────────────────────────────────────────────── */
.illustration--green {
    filter: invert(28%) sepia(64%) saturate(620%) hue-rotate(94deg)
        brightness(85%) contrast(101%);
}

/* ─── Transisi ────────────────────────────────────────────────────── */
.slide-down-enter-active,
.slide-down-leave-active {
    transition: all 0.25s ease;
}
.slide-down-enter-from,
.slide-down-leave-to {
    opacity: 0;
    transform: translateY(-8px);
}
</style>
