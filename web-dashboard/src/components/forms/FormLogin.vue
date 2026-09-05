<template>
    <section
        class="login-form-section flex-1 flex items-center justify-center p-6 md:p-10"
        aria-label="Form masuk akun"
    >
        <div class="w-full max-w-md">
            <!-- ─── Logo mobile (hanya tampil < md) ───────────────────── -->
            <div
                class="md:hidden flex flex-col items-center mb-8"
                aria-hidden="false"
            >
                <BrandingIllustration
                    image-class="w-24 h-auto mb-3 illustration--green"
                    aria-label="Logo Tumbuh"
                />
                <span class="text-2xl font-bold text-brand-primary"
                    >Tumbuh</span
                >
            </div>

            <!-- ─── Card login ────────────────────────────────────────── -->
            <div class="login-card rounded-2xl p-8">
                <!-- Heading -->
                <header class="mb-8">
                    <h1 class="text-2xl font-semibold mb-1 text-heading">
                        Selamat Datang
                    </h1>
                    <p class="text-sm text-body">
                        Platform Digital Posyandu untuk Pemantauan dan Edukasi
                        Risiko Stunting
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

                <!-- Form -->
                <form novalidate @submit.prevent="handleSubmit">
                    <div class="space-y-5">
                        <!-- Email -->
                        <div class="space-y-1.5">
                            <label
                                for="email"
                                class="text-sm font-semibold block ml-1 text-body"
                            >
                                Email
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-envelope input-icon"
                                    aria-hidden="true"
                                />
                                <input
                                    id="email"
                                    :value="email"
                                    type="email"
                                    placeholder="nama@instansi.com"
                                    autocomplete="email"
                                    :disabled="loading"
                                    class="input-field w-full pl-11 pr-4 py-3 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!fieldErrors.email"
                                    aria-describedby="login-email-error"
                                    @input="
                                        $emit(
                                            'update:email',
                                            $event.target.value,
                                        )
                                    "
                                />
                            </div>
                            <p v-if="fieldErrors.email" id="login-email-error" class="field-error">
                                {{ fieldErrors.email }}
                            </p>
                        </div>

                        <!-- Password -->
                        <div class="space-y-1.5">
                            <label
                                for="password"
                                class="text-sm font-semibold block ml-1 text-body"
                            >
                                Password
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-lock input-icon"
                                    aria-hidden="true"
                                />
                                <input
                                    id="password"
                                    :value="password"
                                    :type="showPassword ? 'text' : 'password'"
                                    placeholder="••••••••"
                                    autocomplete="current-password"
                                    maxlength="72"
                                    :disabled="loading"
                                    class="input-field w-full pl-11 pr-12 py-3 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-invalid="!!fieldErrors.password"
                                    aria-describedby="login-password-error"
                                    @input="
                                        $emit(
                                            'update:password',
                                            $event.target.value,
                                        )
                                    "
                                />
                                <button
                                    type="button"
                                    class="toggle-password absolute right-4 top-1/2 -translate-y-1/2"
                                    :aria-label="
                                        showPassword
                                            ? 'Sembunyikan password'
                                            : 'Tampilkan password'
                                    "
                                    :aria-pressed="showPassword"
                                    @click="showPassword = !showPassword"
                                >
                                    <i
                                        :class="
                                            showPassword
                                                ? 'pi pi-eye-slash'
                                                : 'pi pi-eye'
                                        "
                                        aria-hidden="true"
                                    />
                                </button>
                            </div>
                            <p v-if="fieldErrors.password" id="login-password-error" class="field-error">
                                {{ fieldErrors.password }}
                            </p>
                        </div>

                        <!-- Lupa password -->
                        <div class="flex justify-end">
                            <RouterLink
                                :to="{ name: 'ForgotPassword' }"
                                class="text-sm font-bold text-brand-primary transition-colors hover:opacity-80"
                            >
                                Lupa Password?
                            </RouterLink>
                        </div>

                        <!-- Turnstile widget -->
                        <div class="flex justify-center">
                            <!-- [1] Tambah ref="turnstileRef" agar bisa dipanggil .reset() -->
                            <VueTurnstile
                                ref="turnstileRef"
                                :site-key="siteKey"
                                action="login"
                                theme="light"
                                v-model="token"
                            />
                        </div>
                        <p v-if="fieldErrors.turnstile" class="field-error text-center" role="alert">
                            {{ fieldErrors.turnstile }}
                        </p>

                        <!-- Submit -->
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
                                <span>Memverifikasi...</span>
                            </template>
                            <template v-else>
                                <span>Masuk</span>
                                <i class="pi pi-sign-in" aria-hidden="true" />
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
    password: { type: String, required: true },
    turnstileToken: { type: String, default: "" },
    isValid: { type: Boolean, default: false },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
});

const emit = defineEmits([
    "submit",
    "update:email",
    "update:password",
    "update:turnstileToken",
]);

const siteKey = import.meta.env.VITE_TURNSTILE_SITE_KEY;
const showPassword = ref(false);
const attemptedSubmit = ref(false);

const fieldErrors = computed(() => {
    if (!attemptedSubmit.value) return {};
    const errors = {};
    const email = props.email.trim();
    if (!email) errors.email = "Email wajib diisi";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        errors.email = "Format email belum valid";
    }
    if (!props.password) errors.password = "Password wajib diisi";
    else if (props.password.length < 6) {
        errors.password = "Password minimal 6 karakter";
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

// [1] Ref ke instance VueTurnstile untuk akses method .reset()
const turnstileRef = ref(null);

// [2] Computed writable sebagai jembatan v-model untuk VueTurnstile
const token = computed({
    get: () => props.turnstileToken,
    set: (val) => emit("update:turnstileToken", val),
});

// [3] Expose resetTurnstile agar bisa dipanggil dari parent via template ref
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
.login-card {
    background: white;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.06);
    border: 1px solid rgba(190, 202, 184, 0.4);
}

/* ─── Input icon (auth layout, wider spacing) ─────────────────────── */
.input-icon {
    left: 1rem;
    font-size: unset;
}


/* ─── Ilustrasi mobile (filter hijau) ────────────────────────────── */
.illustration--green {
    filter: invert(28%) sepia(64%) saturate(620%) hue-rotate(94deg)
        brightness(85%) contrast(101%);
}
.field-error {
    margin: 0.35rem 0 0 0.25rem;
    color: #dc2626;
    font-size: 0.72rem;
}

/* ─── Tombol Masuk (senada dengan tombol Simpan Password di Profil) ── */
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
</style>
