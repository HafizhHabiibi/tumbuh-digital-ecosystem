<template>
    <section
        class="flex-1 flex items-center justify-center p-6 md:p-10"
        style="background: var(--color-surface)"
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
            <div class="form-card">
                <!-- Back link -->
                <RouterLink
                    :to="{ name: 'Login' }"
                    class="back-link group"
                >
                    <span class="back-link__icon">
                        <i class="pi pi-arrow-left text-xs" aria-hidden="true" />
                    </span>
                    <span>Kembali ke Login</span>
                </RouterLink>

                <!-- Icon + Heading -->
                <header class="mb-8 text-center">
                    <div class="icon-box mx-auto mb-5" aria-hidden="true">
                        <i class="pi pi-envelope text-xl" />
                    </div>
                    <h1
                        class="text-2xl font-bold mb-2"
                        style="color: var(--color-text-heading)"
                    >
                        Lupa Password?
                    </h1>
                    <p
                        class="text-sm leading-relaxed max-w-xs mx-auto"
                        style="color: var(--color-text-muted)"
                    >
                        Masukkan email yang terdaftar. Kami akan mengirimkan
                        tautan untuk mereset password kamu.
                    </p>
                </header>

                <!-- ── Success state ──────────────────────────────────── -->
                <Transition name="slide-down">
                    <div
                        v-if="submitted"
                        class="success-card"
                        role="status"
                        aria-live="polite"
                    >
                        <div class="success-card__icon-wrap">
                            <i class="pi pi-check text-lg" aria-hidden="true" />
                        </div>
                        <p class="font-semibold text-sm mt-4 mb-1">
                            Email terkirim!
                        </p>
                        <p class="text-xs opacity-80 leading-relaxed">
                            Cek inbox kamu di
                            <strong>{{ submittedEmail }}</strong>
                            dan ikuti instruksi di dalamnya.
                        </p>
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

                <!-- ── Turnstile ── -->
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
                    @submit.prevent="handleSubmit"
                >
                    <div class="space-y-5">
                        <div class="space-y-1.5">
                            <label
                                for="forgot-email"
                                class="text-sm font-semibold block ml-1"
                                style="color: var(--color-text-body)"
                            >
                                Alamat Email
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-envelope auth-input-icon"
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
                                    :aria-invalid="!!fieldErrors.email"
                                    aria-describedby="forgot-email-error"
                                    @input="
                                        $emit(
                                            'update:email',
                                            $event.target.value,
                                        )
                                    "
                                />
                            </div>
                            <p v-if="fieldErrors.email" id="forgot-email-error" class="field-error">
                                {{ fieldErrors.email }}
                            </p>
                        </div>

                        <p v-if="fieldErrors.turnstile" class="field-error text-center" role="alert">
                            {{ fieldErrors.turnstile }}
                        </p>

                        <button
                            type="submit"
                            class="btn-primary w-full text-white font-semibold text-sm py-3.5 rounded-xl transition-all duration-200 active:scale-95 flex items-center justify-center gap-2 cursor-pointer"
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
                <div v-else class="mt-2 text-center">
                    <p
                        class="text-sm"
                        style="color: var(--color-text-body)"
                    >
                        Tidak menerima email?
                        <button
                            type="button"
                            class="font-bold text-brand-primary hover:opacity-70 transition-opacity cursor-pointer"
                            @click="handleResend"
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

const turnstileRef = ref(null);
const attemptedSubmit = ref(false);

const fieldErrors = computed(() => {
    if (!attemptedSubmit.value) return {};
    const errors = {};
    const email = props.email.trim();
    if (!email) errors.email = "Email wajib diisi";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        errors.email = "Format email belum valid";
    }
    if (!props.turnstileToken) {
        errors.turnstile = "Selesaikan verifikasi keamanan terlebih dahulu";
    }
    return errors;
});

const handleSubmit = () => {
    if (props.loading) return;
    attemptedSubmit.value = true;
    if (!props.isValid || Object.keys(fieldErrors.value).length > 0) return;
    emit("submit");
};

const handleResend = () => {
    if (props.loading) return;
    attemptedSubmit.value = false;
    emit("resend");
};

const token = computed({
    get: () => props.turnstileToken,
    set: (val) => emit("update:turnstileToken", val),
});

defineExpose({
    resetTurnstile: () => turnstileRef.value?.reset(),
});
</script>

<style scoped>
/* ─── Card ────────────────────────────────────────────────────────── */
.form-card {
    background: white;
    border-radius: 1.25rem;
    padding: 2.5rem;
    box-shadow:
        0 4px 24px rgba(0, 0, 0, 0.05),
        0 1px 3px rgba(0, 0, 0, 0.04);
    border: 1px solid rgba(190, 202, 184, 0.3);
}

/* ─── Back link ──────────────────────────────────────────────────── */
.back-link {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.8rem;
    font-weight: 600;
    color: var(--color-green-700);
    text-decoration: none;
    margin-bottom: 1.75rem;
    transition: all 0.2s;
}
.back-link:hover {
    opacity: 0.75;
}
.back-link__icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 1.75rem;
    height: 1.75rem;
    border-radius: 0.5rem;
    background: var(--color-green-50);
    transition: background 0.2s;
}
.back-link:hover .back-link__icon {
    background: var(--color-green-100);
}

/* ─── Icon dekoratif ──────────────────────────────────────────────── */
.icon-box {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 3.5rem;
    height: 3.5rem;
    border-radius: 1rem;
    background: linear-gradient(
        135deg,
        var(--color-green-500),
        var(--color-green-700)
    );
    color: white;
    box-shadow:
        0 8px 20px var(--color-shadow-green),
        0 2px 6px rgba(0, 0, 0, 0.06);
}

/* ─── Success card ───────────────────────────────────────────────── */
.success-card {
    text-align: center;
    padding: 1.5rem;
    margin-bottom: 1.25rem;
    border-radius: 1rem;
    background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
    border: 1px solid #bbf7d0;
    color: #15803d;
}
.success-card__icon-wrap {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2.75rem;
    height: 2.75rem;
    border-radius: 50%;
    background: #22c55e;
    color: white;
    box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
}

/* ─── Input icon (auth layout) ────────────────────────────────────── */
.auth-input-icon {
    position: absolute;
    left: 1rem;
    top: 50%;
    transform: translateY(-50%);
    color: var(--color-text-muted);
    pointer-events: none;
}

/* ─── Ilustrasi mobile ────────────────────────────────────────────── */
.illustration--green {
    filter: invert(28%) sepia(64%) saturate(620%) hue-rotate(94deg)
        brightness(85%) contrast(101%);
}
.field-error {
    margin: 0.35rem 0 0 0.25rem;
    color: #dc2626;
    font-size: 0.72rem;
}
</style>
