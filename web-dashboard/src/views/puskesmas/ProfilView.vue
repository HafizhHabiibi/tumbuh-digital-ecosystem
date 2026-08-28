<template>
    <div class="p-6 max-w-2xl mx-auto space-y-6">
        <!-- ─── Header ──────────────────────────────────────────── -->
        <div class="text-left">
            <h1
                class="text-2xl font-bold m-0"
                style="color: var(--color-text-heading)"
            >
                Profil
            </h1>
            <p class="text-sm mt-1 m-0" style="color: var(--color-text-muted)">
                Kelola keamanan akun kamu
            </p>
        </div>

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
                    style="background: #dbeafe; color: #2563eb"
                >
                    Puskesmas
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

            <!-- Success -->
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

            <!-- Error -->
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
                    <label for="password_lama_ps" class="field-label"
                        >Password Lama</label
                    >
                    <div class="relative">
                        <i class="pi pi-lock input-icon" aria-hidden="true" />
                        <input
                            id="password_lama_ps"
                            v-model="form.password_lama"
                            :type="show.lama ? 'text' : 'password'"
                            placeholder="••••••••"
                            autocomplete="current-password"
                            maxlength="72"
                            :disabled="authStore.loading.changePassword"
                            class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                            aria-required="true"
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
                </div>

                <!-- Password baru -->
                <div class="space-y-1.5">
                    <label for="password_baru_ps" class="field-label">
                        Password Baru
                        <span
                            class="text-xs font-normal"
                            style="color: var(--color-text-muted)"
                            >(min. 6 karakter)</span
                        >
                    </label>
                    <div class="relative">
                        <i class="pi pi-lock input-icon" aria-hidden="true" />
                        <input
                            id="password_baru_ps"
                            v-model="form.password_baru"
                            :type="show.baru ? 'text' : 'password'"
                            placeholder="••••••••"
                            autocomplete="new-password"
                            maxlength="72"
                            :disabled="authStore.loading.changePassword"
                            class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                            aria-required="true"
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
                    <p
                        v-if="
                            form.password_baru && form.password_baru.length < 6
                        "
                        class="error-hint"
                    >
                        Password minimal 6 karakter
                    </p>
                </div>

                <!-- Konfirmasi -->
                <div class="space-y-1.5">
                    <label for="konfirmasi_ps" class="field-label"
                        >Konfirmasi Password Baru</label
                    >
                    <div class="relative">
                        <i class="pi pi-lock input-icon" aria-hidden="true" />
                        <input
                            id="konfirmasi_ps"
                            v-model="form.konfirmasi"
                            :type="show.konfirmasi ? 'text' : 'password'"
                            placeholder="••••••••"
                            autocomplete="new-password"
                            maxlength="72"
                            :disabled="authStore.loading.changePassword"
                            class="input-field w-full pl-9 pr-10 py-2.5 rounded-xl text-sm"
                            aria-required="true"
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
                    <p
                        v-if="
                            form.konfirmasi &&
                            form.konfirmasi !== form.password_baru
                        "
                        class="error-hint"
                    >
                        Password tidak cocok
                    </p>
                </div>

                <!-- Submit -->
                <button
                    type="submit"
                    :disabled="authStore.loading.changePassword || !isValid"
                    class="btn-primary w-full py-3 rounded-xl text-sm font-semibold text-white flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed mt-2"
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
                        class="text-sm font-medium bg-transparent border-0 cursor-pointer transition-colors hover:opacity-75"
                        style="color: var(--color-green-700)"
                        @click="handleLupaPassword"
                    >
                        Lupa password lama?
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/authStore";

const authStore = useAuthStore();
const router = useRouter();
const successMsg = ref("");

const form = reactive({ password_lama: "", password_baru: "", konfirmasi: "" });
const show = reactive({ lama: false, baru: false, konfirmasi: false });

const userInitial = computed(
    () => authStore.namaLengkap?.charAt(0).toUpperCase() ?? "P",
);

const isValid = computed(
    () =>
        form.password_lama.trim() &&
        form.password_baru.length >= 6 &&
        form.konfirmasi === form.password_baru,
);

const handleSubmit = async () => {
    if (!isValid.value || authStore.loading.changePassword) return;
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
    }
};

const handleLupaPassword = () => {
    authStore.logout();
    router.push({ name: "ForgotPassword" });
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
