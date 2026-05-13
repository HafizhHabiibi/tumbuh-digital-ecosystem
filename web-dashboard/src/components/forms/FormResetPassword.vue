<template>
    <section
        class="reset-form-section flex-1 flex items-center justify-center p-6 md:p-10"
        aria-label="Form reset password"
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

            <!-- ─── Card: token tidak valid ───────────────────────────── -->
            <div
                v-if="tokenInvalid"
                class="form-card rounded-2xl p-8 text-center"
            >
                <div
                    class="icon-box icon-box--error mx-auto mb-4"
                    aria-hidden="true"
                >
                    <i class="pi pi-times-circle text-xl" />
                </div>
                <h1 class="text-xl font-semibold mb-2 text-heading">
                    Tautan Tidak Valid
                </h1>
                <p class="text-sm text-body mb-6 leading-relaxed">
                    Tautan reset password ini sudah kedaluwarsa atau tidak
                    valid. Silakan minta tautan baru.
                </p>
                <RouterLink
                    :to="{ name: 'ForgotPassword' }"
                    class="btn-primary inline-flex items-center justify-center gap-2 w-full text-white font-semibold text-sm py-3.5 rounded-xl transition-all duration-200 active:scale-95"
                >
                    <span>Minta Tautan Baru</span>
                    <i class="pi pi-refresh" aria-hidden="true" />
                </RouterLink>
            </div>

            <!-- ─── Card: form reset ───────────────────────────────────── -->
            <div v-else class="form-card rounded-2xl p-8">
                <!-- Heading -->
                <header class="mb-8">
                    <div class="icon-box mb-4" aria-hidden="true">
                        <i class="pi pi-key text-xl" />
                    </div>
                    <h1 class="text-2xl font-semibold mb-1 text-heading">
                        Buat Password Baru
                    </h1>
                    <p class="text-sm text-body leading-relaxed">
                        Password baru harus berbeda dari password sebelumnya dan
                        minimal 8 karakter.
                    </p>
                </header>

                <!-- ── Success state ──────────────────────────────────── -->
                <Transition name="slide-down">
                    <div
                        v-if="succeeded"
                        class="success-alert mb-5 flex items-start gap-3 rounded-xl px-4 py-3.5 text-sm"
                        role="status"
                        aria-live="polite"
                    >
                        <i
                            class="pi pi-check-circle mt-0.5 flex-shrink-0"
                            aria-hidden="true"
                        />
                        <div>
                            <p class="font-semibold">
                                Password berhasil diubah!
                            </p>
                            <p class="mt-0.5 opacity-90">
                                Kamu akan diarahkan ke halaman login...
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

                <!-- ── Form ───────────────────────────────────────────── -->
                <form
                    v-if="!succeeded"
                    novalidate
                    @submit.prevent="$emit('submit')"
                >
                    <div class="space-y-5">
                        <!-- Password baru -->
                        <div class="space-y-1.5">
                            <label
                                for="new-password"
                                class="text-sm font-semibold block ml-1 text-body"
                            >
                                Password Baru
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-lock input-icon"
                                    aria-hidden="true"
                                />
                                <input
                                    id="new-password"
                                    :value="password"
                                    :type="showPassword ? 'text' : 'password'"
                                    placeholder="Min. 8 karakter"
                                    autocomplete="new-password"
                                    :disabled="loading"
                                    class="input-field w-full pl-11 pr-12 py-3 rounded-xl text-sm"
                                    aria-required="true"
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

                            <!-- Strength indicator -->
                            <Transition name="slide-down">
                                <div
                                    v-if="password.length > 0"
                                    class="mt-2 space-y-1"
                                    aria-live="polite"
                                >
                                    <div class="flex gap-1">
                                        <div
                                            v-for="i in 4"
                                            :key="i"
                                            class="h-1 flex-1 rounded-full transition-all duration-300"
                                            :class="
                                                i <= strengthScore
                                                    ? strengthBarColor
                                                    : 'bg-gray-200'
                                            "
                                        />
                                    </div>
                                    <p
                                        class="text-xs ml-1"
                                        :class="strengthTextColor"
                                    >
                                        {{ strengthLabel }}
                                    </p>
                                </div>
                            </Transition>
                        </div>

                        <!-- Konfirmasi password -->
                        <div class="space-y-1.5">
                            <label
                                for="confirm-password"
                                class="text-sm font-semibold block ml-1 text-body"
                            >
                                Konfirmasi Password
                            </label>
                            <div class="relative">
                                <i
                                    class="pi pi-lock input-icon"
                                    aria-hidden="true"
                                />
                                <input
                                    id="confirm-password"
                                    :value="passwordConfirmation"
                                    :type="showConfirm ? 'text' : 'password'"
                                    placeholder="Ulangi password baru"
                                    autocomplete="new-password"
                                    :disabled="loading"
                                    class="input-field w-full pl-11 pr-12 py-3 rounded-xl text-sm"
                                    :class="{
                                        'input-field--error':
                                            passwordConfirmation.length > 0 &&
                                            password !== passwordConfirmation,
                                        'input-field--success':
                                            passwordConfirmation.length > 0 &&
                                            password === passwordConfirmation,
                                    }"
                                    aria-required="true"
                                    @input="
                                        $emit(
                                            'update:passwordConfirmation',
                                            $event.target.value,
                                        )
                                    "
                                />
                                <button
                                    type="button"
                                    class="toggle-password absolute right-4 top-1/2 -translate-y-1/2"
                                    :aria-label="
                                        showConfirm
                                            ? 'Sembunyikan password'
                                            : 'Tampilkan password'
                                    "
                                    :aria-pressed="showConfirm"
                                    @click="showConfirm = !showConfirm"
                                >
                                    <i
                                        :class="
                                            showConfirm
                                                ? 'pi pi-eye-slash'
                                                : 'pi pi-eye'
                                        "
                                        aria-hidden="true"
                                    />
                                </button>
                            </div>

                            <Transition name="slide-down">
                                <p
                                    v-if="
                                        passwordConfirmation.length > 0 &&
                                        password !== passwordConfirmation
                                    "
                                    class="text-xs ml-1 text-red-500"
                                    role="alert"
                                >
                                    Password tidak cocok
                                </p>
                            </Transition>
                        </div>

                        <!-- Submit -->
                        <button
                            type="submit"
                            :disabled="loading || !isValid"
                            class="btn-primary w-full text-white font-semibold text-sm py-3.5 rounded-xl transition-all duration-200 active:scale-95 flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed disabled:active:scale-100"
                            :aria-busy="loading"
                        >
                            <template v-if="loading">
                                <i
                                    class="pi pi-spin pi-spinner"
                                    aria-hidden="true"
                                />
                                <span>Menyimpan...</span>
                            </template>
                            <template v-else>
                                <span>Simpan Password Baru</span>
                                <i class="pi pi-check" aria-hidden="true" />
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
import BrandingIllustration from "@/components/ui/BrandingIllustration.vue";

const props = defineProps({
    password: { type: String, required: true },
    passwordConfirmation: { type: String, required: true },
    isValid: { type: Boolean, default: false },
    loading: { type: Boolean, default: false },
    error: { type: String, default: null },
    /** Token tidak valid / kedaluwarsa */
    tokenInvalid: { type: Boolean, default: false },
    /** Reset berhasil */
    succeeded: { type: Boolean, default: false },
});

defineEmits(["submit", "update:password", "update:passwordConfirmation"]);

const showPassword = ref(false);
const showConfirm = ref(false);

/* ─── Password strength ──────────────────────────────────────────── */
const strengthScore = computed(() => {
    const p = props.password;
    if (!p) return 0;
    let s = 0;
    if (p.length >= 8) s++;
    if (p.length >= 12) s++;
    if (/[A-Z]/.test(p) && /[a-z]/.test(p)) s++;
    if (/[0-9]/.test(p)) s++;
    if (/[^A-Za-z0-9]/.test(p)) s++;
    return Math.min(s, 4);
});

const strengthBarColor = computed(
    () =>
        ({
            1: "bg-red-400",
            2: "bg-yellow-400",
            3: "bg-blue-500",
            4: "bg-green-500",
        })[strengthScore.value] ?? "bg-gray-200",
);

const strengthTextColor = computed(
    () =>
        ({
            1: "text-red-500",
            2: "text-yellow-500",
            3: "text-blue-600",
            4: "text-green-600",
        })[strengthScore.value] ?? "",
);

const strengthLabel = computed(
    () =>
        ({
            1: "Lemah",
            2: "Cukup",
            3: "Kuat",
            4: "Sangat Kuat",
        })[strengthScore.value] ?? "",
);
</script>

<style scoped>
.reset-form-section {
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
.icon-box--error {
    background: linear-gradient(135deg, #f87171, #dc2626);
    box-shadow: 0 4px 12px rgba(220, 38, 38, 0.25);
}

/* ─── Tipografi ───────────────────────────────────────────────────── */
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

.input-field--error {
    border-color: #fca5a5 !important;
    box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.15) !important;
}
.input-field--success {
    border-color: #86efac !important;
    box-shadow: 0 0 0 2px rgba(34, 197, 94, 0.15) !important;
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
