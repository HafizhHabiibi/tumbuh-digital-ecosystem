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
                <form novalidate @submit.prevent="$emit('submit')">
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
                                    :disabled="loading"
                                    class="input-field w-full pl-11 pr-12 py-3 rounded-xl text-sm"
                                    aria-required="true"
                                    :aria-describedby="
                                        error ? 'login-error' : undefined
                                    "
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

                        <!-- Submit -->
                        <button
                            type="submit"
                            :disabled="loading || !isValid"
                            class="btn-login w-full text-white font-semibold text-sm py-3.5 rounded-xl transition-all duration-200 active:scale-95 flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed disabled:active:scale-100"
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
import { ref } from "vue";
import BrandingIllustration from "@/components/ui/BrandingIllustration.vue";

const props = defineProps({
    /** Nilai input email (v-model:email) */
    email: { type: String, required: true },
    /** Nilai input password (v-model:password) */
    password: { type: String, required: true },
    /** Form valid atau tidak — dikontrol parent */
    isValid: { type: Boolean, default: false },
    /** Sedang loading/submit */
    loading: { type: Boolean, default: false },
    /** Pesan error dari store/API */
    error: { type: String, default: null },
});

defineEmits(["submit", "update:email", "update:password"]);

const showPassword = ref(false);
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

/* ─── Tipografi warna ─────────────────────────────────────────────── */
.text-heading {
    color: var(--color-text-heading);
}
.text-body {
    color: var(--color-text-body);
}
.text-brand-primary {
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

/* ─── Toggle password ─────────────────────────────────────────────── */
.toggle-password {
    background: none;
    border: none;
    cursor: pointer;
    color: var(--color-text-muted);
    transition: color 0.2s;
    padding: 0;
    line-height: 1;
}
.toggle-password:hover {
    color: var(--color-text-body);
}

/* ─── Tombol login ────────────────────────────────────────────────── */
.btn-login {
    background: linear-gradient(
        135deg,
        var(--color-green-600) 0%,
        var(--color-green-700) 60%,
        var(--color-green-900) 100%
    );
    box-shadow: 0 4px 14px var(--color-shadow-green);
}
.btn-login:hover:not(:disabled) {
    filter: brightness(1.08);
    box-shadow: 0 6px 18px var(--color-shadow-green-hover);
}

/* ─── Error alert ─────────────────────────────────────────────────── */
.error-alert {
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #b91c1c;
}

/* ─── Ilustrasi mobile (filter hijau) ────────────────────────────── */
.illustration--green {
    /*
        SVG di-load sebagai <img>, tidak bisa pakai currentColor.
        Filter ini mengonversi warna hitam default ke #006e1c (hijau brand).
        Generator: https://codepen.io/sosuke/pen/Pjoqqp
    */
    filter: invert(28%) sepia(64%) saturate(620%) hue-rotate(94deg)
        brightness(85%) contrast(101%);
}

/* ─── Transisi error ──────────────────────────────────────────────── */
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
