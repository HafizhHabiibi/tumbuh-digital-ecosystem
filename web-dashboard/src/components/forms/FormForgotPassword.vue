<template>
    <section
        class="login-form-section flex-1 flex items-center justify-center p-6 md:p-10"
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

            <!-- ─── Card Form ─────────────────────────────────────────── -->
            <div class="form-card rounded-2xl p-8">
                <!-- Back link -->
                <div class="mb-6">
                    <RouterLink
                        :to="{ name: 'Login' }"
                        class="inline-flex items-center gap-2 text-xs font-semibold text-emerald-700 hover:text-emerald-800 transition-colors group"
                    >
                        <span
                            class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center group-hover:bg-emerald-100 transition-colors"
                        >
                            <i class="pi pi-arrow-left text-xs" aria-hidden="true" />
                        </span>
                        <span>Kembali ke Login</span>
                    </RouterLink>
                </div>

                <!-- Header / Deskripsi -->
                <header class="mb-6">
                    <h1 class="sr-only">Lupa Password</h1>
                    <p class="text-sm text-body leading-relaxed">
                        Masukkan email yang terdaftar. Kami akan mengirimkan tautan untuk mereset password akun Anda.
                    </p>
                </header>

                <!-- Error alert -->
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

                <!-- ── State Sukses (Setelah email terkirim) ───────────── -->
                <Transition name="slide-down">
                    <div v-if="submitted" class="space-y-6">
                        <div
                            class="p-5 rounded-2xl bg-emerald-50/70 border border-emerald-100 flex items-start gap-4"
                            role="status"
                            aria-live="polite"
                        >
                            <div class="w-10 h-10 rounded-xl bg-emerald-600 text-white flex items-center justify-center flex-shrink-0 shadow-sm shadow-emerald-600/30">
                                <i class="pi pi-check text-base" aria-hidden="true" />
                            </div>
                            <div class="space-y-1">
                                <h3 class="text-sm font-semibold text-emerald-950">
                                    Email Berhasil Terkirim!
                                </h3>
                                <p class="text-xs text-emerald-800 leading-relaxed">
                                    Instruksi reset password telah dikirimkan ke:
                                </p>
                                <div class="inline-flex items-center gap-1.5 px-2.5 py-1 bg-white/80 rounded-lg text-xs font-semibold text-emerald-900 border border-emerald-200/60 mt-1">
                                    <i class="pi pi-envelope text-[11px] text-emerald-600" aria-hidden="true" />
                                    <span>{{ submittedEmail }}</span>
                                </div>
                            </div>
                        </div>

                        <p class="text-xs text-body leading-relaxed">
                            Silakan periksa folder kotak masuk atau spam email Anda dan ikuti petunjuk yang tertera untuk membuat password baru.
                        </p>

                        <div class="pt-2 flex flex-col gap-3">
                            <RouterLink
                                :to="{ name: 'Login' }"
                                class="btn-primary w-full text-white font-semibold text-sm py-3.5 rounded-xl shadow-sm transition-all flex items-center justify-center gap-2 text-center cursor-pointer"
                            >
                                <span>Kembali ke Halaman Login</span>
                                <i class="pi pi-sign-in" aria-hidden="true" />
                            </RouterLink>

                            <div class="text-center pt-1">
                                <p class="text-xs text-muted">
                                    Tidak menerima email?
                                    <button
                                        type="button"
                                        class="font-semibold text-emerald-700 hover:text-emerald-800 hover:underline transition-colors cursor-pointer ml-1"
                                        @click="handleResend"
                                    >
                                        Kirim ulang
                                    </button>
                                </p>
                            </div>
                        </div>
                    </div>
                </Transition>

                <!-- ── Form (tersembunyi setelah sukses) ──────────────── -->
                <form
                    v-if="!submitted"
                    novalidate
                    @submit.prevent="handleSubmit"
                >
                    <div class="space-y-5">
                        <!-- Email input -->
                        <div class="space-y-1.5">
                            <label
                                for="forgot-email"
                                class="text-sm font-semibold block ml-1 text-body"
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

                        <!-- Turnstile widget -->
                        <div class="flex justify-center">
                            <VueTurnstile
                                ref="turnstileRef"
                                :site-key="siteKey"
                                action="forgot-password"
                                theme="light"
                                v-model="token"
                            />
                        </div>
                        <p v-if="fieldErrors.turnstile" class="field-error text-center" role="alert">
                            {{ fieldErrors.turnstile }}
                        </p>

                        <!-- Submit button -->
                        <button
                            type="submit"
                            class="btn-primary w-full text-white font-semibold text-sm py-3.5 rounded-xl shadow-sm transition-all flex items-center justify-center gap-2 cursor-pointer"
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
/* ─── Section background ──────────────────────────────────────────── */
.login-form-section {
    background: var(--color-surface);
}

/* ─── Card ────────────────────────────────────────────────────────── */
.form-card {
    background: white;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
    border: 1px solid rgba(190, 202, 184, 0.4);
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

/* ─── Tombol Submit (senada dengan Login & Profil) ─────────────────── */
.btn-primary {
    border: 0;
    background: #059669;
    cursor: pointer;
    transition: all 0.2s;
}

.btn-primary:hover {
    background: #047857;
}

.btn-primary:active {
    transform: scale(0.99);
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
