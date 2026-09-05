<template>
    <div class="p-6 max-w-2xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <PageHeader title="Profil" />

        <!-- ─── Info akun ────────────────────────────────────────── -->
        <div class="card p-5 rounded-2xl flex items-center gap-4">
            <div
                class="w-14 h-14 rounded-2xl flex items-center justify-center text-xl font-bold text-white flex-shrink-0"
                style="
                    background: linear-gradient(
                        135deg,
                        var(--color-green-600),
                        var(--color-green-800)
                    );
                "
            >
                {{ userInitial }}
            </div>
            <div>
                <p
                    class="text-base font-semibold m-0"
                    style="color: var(--color-text-heading)"
                >
                    {{ authStore.namaLengkap }}
                </p>
                <p
                    class="text-sm m-0 mt-0.5"
                    style="color: var(--color-text-muted)"
                >
                    {{ authStore.user?.email ?? "—" }}
                </p>
                <span
                    class="text-xs px-2 py-0.5 rounded-full font-medium mt-1 inline-block"
                    style="
                        background: var(--color-green-100);
                        color: var(--color-green-700);
                    "
                >
                    Kader Posyandu
                </span>
            </div>
        </div>

        <!-- ─── Form Ubah Password ───────────────────────────────── -->
        <div class="card p-6 rounded-2xl space-y-5">
            <h2
                class="text-base font-semibold m-0"
                style="color: var(--color-text-heading)"
            >
                <i
                    class="pi pi-lock mr-2"
                    style="color: var(--color-green-700)"
                    aria-hidden="true"
                />
                Ubah Password
            </h2>

            <!-- Success alert -->
            <Transition name="slide-down">
                <div
                    v-if="successMsg"
                    class="flex items-center gap-2 px-3 py-2.5 rounded-xl text-sm"
                    style="
                        background: #dcfce7;
                        border: 1px solid #86efac;
                        color: #15803d;
                    "
                    role="status"
                >
                    <i
                        class="pi pi-check-circle flex-shrink-0"
                        aria-hidden="true"
                    />
                    <span>{{ successMsg }}</span>
                </div>
            </Transition>

            <!-- Error alert -->
            <Transition name="slide-down">
                <div
                    v-if="authStore.error.changePassword"
                    class="flex items-center gap-2 px-3 py-2.5 rounded-xl text-sm"
                    style="
                        background: #fef2f2;
                        border: 1px solid #fecaca;
                        color: #b91c1c;
                    "
                    role="alert"
                    aria-live="assertive"
                >
                    <i
                        class="pi pi-exclamation-circle flex-shrink-0"
                        aria-hidden="true"
                    />
                    <span>{{ authStore.error.changePassword }}</span>
                </div>
            </Transition>

            <form novalidate class="space-y-4" @submit.prevent="handleSubmit">
                <!-- Password lama -->
                <div class="space-y-1.5">
                    <label for="password_lama" class="field-label"
                        >Password Lama</label
                    >
                    <div class="relative">
                        <i class="pi pi-lock input-icon" aria-hidden="true" />
                        <input
                            id="password_lama"
                            v-model="form.password_lama"
                            :type="show.lama ? 'text' : 'password'"
                            placeholder="••••••••"
                            autocomplete="current-password"
                            maxlength="72"
                            :disabled="authStore.loading.changePassword"
                            class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                            aria-required="true"
                            :aria-invalid="!!validationErrors.password_lama"
                            aria-describedby="password_lama_error"
                        />
                        <button
                            type="button"
                            class="toggle-pass absolute right-3 top-1/2 -translate-y-1/2"
                            :aria-label="
                                show.lama ? 'Sembunyikan' : 'Tampilkan'
                            "
                            @click="show.lama = !show.lama"
                        >
                            <i
                                :class="
                                    show.lama ? 'pi pi-eye-slash' : 'pi pi-eye'
                                "
                                aria-hidden="true"
                            />
                        </button>
                    </div>
                    <p v-if="validationErrors.password_lama" id="password_lama_error" class="error-hint">
                        {{ validationErrors.password_lama }}
                    </p>
                </div>

                <!-- Password baru -->
                <div class="space-y-1.5">
                    <label for="password_baru" class="field-label"
                        >Password Baru
                        <span
                            class="text-xs font-normal"
                            style="color: var(--color-text-muted)"
                            >(min. 6 karakter)</span
                        >
                    </label>
                    <div class="relative">
                        <i class="pi pi-lock input-icon" aria-hidden="true" />
                        <input
                            id="password_baru"
                            v-model="form.password_baru"
                            :type="show.baru ? 'text' : 'password'"
                            placeholder="••••••••"
                            autocomplete="new-password"
                            maxlength="72"
                            :disabled="authStore.loading.changePassword"
                            class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                            aria-required="true"
                            :aria-invalid="!!validationErrors.password_baru"
                            aria-describedby="password_baru_error"
                        />
                        <button
                            type="button"
                            class="toggle-pass absolute right-3 top-1/2 -translate-y-1/2"
                            :aria-label="
                                show.baru ? 'Sembunyikan' : 'Tampilkan'
                            "
                            @click="show.baru = !show.baru"
                        >
                            <i
                                :class="
                                    show.baru ? 'pi pi-eye-slash' : 'pi pi-eye'
                                "
                                aria-hidden="true"
                            />
                        </button>
                    </div>
                    <p v-if="validationErrors.password_baru" id="password_baru_error" class="error-hint">
                        {{ validationErrors.password_baru }}
                    </p>
                </div>

                <!-- Konfirmasi password baru -->
                <div class="space-y-1.5">
                    <label for="konfirmasi_password" class="field-label"
                        >Konfirmasi Password Baru</label
                    >
                    <div class="relative">
                        <i class="pi pi-lock input-icon" aria-hidden="true" />
                        <input
                            id="konfirmasi_password"
                            v-model="form.konfirmasi"
                            :type="show.konfirmasi ? 'text' : 'password'"
                            placeholder="••••••••"
                            autocomplete="new-password"
                            maxlength="72"
                            :disabled="authStore.loading.changePassword"
                            class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                            aria-required="true"
                            :aria-invalid="!!validationErrors.konfirmasi"
                            aria-describedby="konfirmasi_password_error"
                        />
                        <button
                            type="button"
                            class="toggle-pass absolute right-3 top-1/2 -translate-y-1/2"
                            :aria-label="
                                show.konfirmasi ? 'Sembunyikan' : 'Tampilkan'
                            "
                            @click="show.konfirmasi = !show.konfirmasi"
                        >
                            <i
                                :class="
                                    show.konfirmasi
                                        ? 'pi pi-eye-slash'
                                        : 'pi pi-eye'
                                "
                                aria-hidden="true"
                            />
                        </button>
                    </div>
                    <p v-if="validationErrors.konfirmasi" id="konfirmasi_password_error" class="error-hint">
                        {{ validationErrors.konfirmasi }}
                    </p>
                </div>

                <!-- Submit -->
                <button
                    type="submit"
                    class="btn-primary w-full py-3 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 cursor-pointer mt-2"
                    :aria-busy="authStore.loading.changePassword"
                >
                    <i
                        v-if="authStore.loading.changePassword"
                        class="pi pi-spin pi-spinner"
                        aria-hidden="true"
                    />
                    <span>{{
                        authStore.loading.changePassword
                            ? "Menyimpan..."
                            : "Simpan Password"
                    }}</span>
                </button>

                <!-- Lupa password -->
                <div class="text-center pt-1">
                    <button
                        type="button"
                        class="text-sm font-medium transition-colors hover:opacity-75 bg-transparent border-0 cursor-pointer"
                        style="color: var(--color-green-700)"
                        @click="handleLupaPassword"
                    >
                        Lupa password lama?
                    </button>
                </div>
            </form>
        </div>

        <!-- ─── Sesi Akun / Keluar ───────────────────────────────── -->
        <div class="card p-5 rounded-2xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border border-red-100 bg-red-50/20">
            <div>
                <h2 class="text-base font-semibold text-slate-800 m-0 flex items-center gap-2">
                    <i class="pi pi-sign-out text-red-600" aria-hidden="true" />
                    Sesi Akun
                </h2>
                <p class="text-xs text-slate-500 m-0 mt-1">
                    Keluar dari aplikasi pada sesi browser saat ini
                </p>
            </div>
            <button
                type="button"
                class="px-4 py-2.5 rounded-xl text-sm font-semibold text-red-600 bg-red-50 hover:bg-red-100 hover:text-red-700 transition-colors border border-red-200 cursor-pointer flex items-center gap-2 flex-shrink-0"
                aria-label="Keluar dari akun"
                @click="handleLogout"
            >
                <i class="pi pi-sign-out text-sm" />
                <span>Keluar dari Akun</span>
            </button>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import PageHeader from "@/components/ui/PageHeader.vue";
import { useAuthStore } from "@/stores/authStore";
import { useRouter } from "vue-router";

const authStore = useAuthStore();
const router = useRouter();

const successMsg = ref("");
const attemptedSubmit = ref(false);

const form = reactive({
    password_lama: "",
    password_baru: "",
    konfirmasi: "",
});

const show = reactive({
    lama: false,
    baru: false,
    konfirmasi: false,
});

/* ── Initial user ────────────────────────────────────────────────── */
const userInitial = computed(
    () => authStore.namaLengkap?.charAt(0).toUpperCase() ?? "K",
);

/* ── Validasi ────────────────────────────────────────────────────── */
const isValid = computed(
    () =>
        Boolean(form.password_lama.trim()) &&
        form.password_baru.length >= 6 &&
        form.konfirmasi === form.password_baru,
);

const validationErrors = computed(() => {
    if (!attemptedSubmit.value) return {};
    const errors = {};
    if (!form.password_lama.trim()) errors.password_lama = "Password lama wajib diisi";
    if (!form.password_baru) errors.password_baru = "Password baru wajib diisi";
    else if (form.password_baru.length < 6) errors.password_baru = "Password minimal 6 karakter";
    if (!form.konfirmasi) errors.konfirmasi = "Konfirmasi password wajib diisi";
    else if (form.konfirmasi !== form.password_baru) errors.konfirmasi = "Password tidak cocok";
    return errors;
});

/* ── Lupa password ──────────────────────────────────────────────── */
const handleLupaPassword = () => {
    authStore.logout();
    router.push({ name: "ForgotPassword" });
};

/* ── Logout ──────────────────────────────────────────────────────── */
const handleLogout = () => {
    authStore.logout();
    router.push({ name: "Login" });
};

/* ── Submit ──────────────────────────────────────────────────────── */
const handleSubmit = async () => {
    if (authStore.loading.changePassword) return;
    attemptedSubmit.value = true;
    if (!isValid.value) return;
    successMsg.value = "";

    const ok = await authStore.changePassword(
        form.password_lama,
        form.password_baru,
    );
    if (ok) {
        successMsg.value = "Password berhasil diubah!";
        form.password_lama = "";
        form.password_baru = "";
        form.konfirmasi = "";
        attemptedSubmit.value = false;
    }
};

onMounted(() => authStore.refreshProfile());
</script>

<style scoped>
.card {
    background: white;
    border: 1px solid var(--color-card-border);
    box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}
.field-label {
    display: block;
    font-size: 0.8rem;
    font-weight: 600;
    margin-left: 0.25rem;
    color: var(--color-text-body);
}
.input-icon {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    font-size: 0.85rem;
    color: var(--color-text-muted);
    pointer-events: none;
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
.input-field::placeholder {
    color: var(--color-text-muted);
    font-size: 0.82rem;
}
.input-field:focus {
    border-color: var(--color-green-700);
    box-shadow: 0 0 0 2px var(--color-focus-ring);
}
.input-field:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
.error-hint {
    font-size: 0.72rem;
    color: #dc2626;
    margin: 0 0 0 0.25rem;
}
.toggle-pass {
    background: none;
    border: none;
    cursor: pointer;
    color: var(--color-text-muted);
    padding: 0;
    line-height: 1;
    transition: color 0.15s;
}
.toggle-pass:hover {
    color: var(--color-text-body);
}

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
