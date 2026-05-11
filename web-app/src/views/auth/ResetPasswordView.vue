<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <!-- ── Left: Branding (identik dengan LoginPage) ── -->
        <section
            class="hidden md:flex md:w-1/2 relative items-center justify-center p-10"
            style="
                background: linear-gradient(135deg, #008f24, #006e1c, #004d13);
            "
        >
            <div
                class="absolute inset-0 pointer-events-none"
                style="
                    background: radial-gradient(
                        circle at top left,
                        rgba(255, 255, 255, 0.15),
                        transparent 40%
                    );
                "
            ></div>
            <div
                class="absolute inset-0 pointer-events-none"
                style="
                    background: radial-gradient(
                        circle at bottom right,
                        rgba(255, 255, 255, 0.08),
                        transparent 50%
                    );
                "
            ></div>

            <div class="relative z-10 max-w-md text-center text-white">
                <div class="mb-4 flex justify-center">
                    <img
                        alt="Tumbuh Logo"
                        class="w-44 h-auto drop-shadow-2xl"
                        src="https://lh3.googleusercontent.com/aida/ADBb0uh0HYZgn-j2BPS9l6CS0OosBEubY7mrhHbCahhEbR7He7E2Ezw20rFKoop0_cQOULU_6FdNt878tvOHWyYEisqgwqUM7iSYf_TVHBR2pXM9fqexD0qGSfmVIWAg5zSxKMG54os6zH4bAMwu4vYJDwsnrWIaiVVPNcrGSuVfWjsFF3gJy-n-d13cyY50o4Qxvv0L2WiG6kRuIVxZmr6RgtpzPU1QRPACNhcNLk66Cmx-nljAKhjqYwhwOgI3FeBdhArV8tr1LvAPVw"
                    />
                </div>
                <h1
                    class="font-extrabold drop-shadow-sm mb-3"
                    style="
                        font-size: 36px;
                        line-height: 46px;
                        letter-spacing: -0.02em;
                    "
                >
                    Tumbuh
                </h1>
                <p
                    class="text-base leading-relaxed font-medium drop-shadow-sm max-w-sm mx-auto"
                    style="color: rgba(255, 255, 255, 0.9)"
                >
                    Ekosistem digital Posyandu untuk pemantauan tumbuh kembang
                    anak secara presisi dan penuh empati.
                </p>
            </div>
        </section>

        <!-- ── Right ── -->
        <section
            class="flex-1 flex items-center justify-center p-4 md:p-8"
            style="background-color: #ffffff"
        >
            <div class="w-full max-w-md">
                <!-- Mobile logo -->
                <div class="md:hidden flex flex-col items-center mb-6">
                    <div
                        class="p-2 rounded-xl mb-3"
                        style="background-color: #72da72"
                    >
                        <span
                            class="material-symbols-outlined"
                            style="color: #006e1c; font-size: 40px"
                            >vital_signs</span
                        >
                    </div>
                    <h1 class="font-semibold text-2xl" style="color: #006e1c">
                        Tumbuh
                    </h1>
                </div>

                <!-- ── State: Token tidak valid ── -->
                <div
                    v-if="tokenStatus === 'invalid'"
                    class="bg-white rounded-xl p-6 border text-center"
                    style="
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
                        border-color: rgba(190, 202, 184, 0.3);
                    "
                >
                    <div class="flex justify-center mb-4">
                        <div
                            class="rounded-full flex items-center justify-center"
                            style="
                                width: 64px;
                                height: 64px;
                                background: #ffdad6;
                            "
                        >
                            <span
                                class="material-symbols-outlined icon-filled"
                                style="color: #ba1a1a; font-size: 36px"
                            >
                                link_off
                            </span>
                        </div>
                    </div>
                    <h2 class="font-bold text-xl mb-2" style="color: #171d16">
                        Tautan Tidak Valid
                    </h2>
                    <p class="text-sm mb-6" style="color: #3f4a3c">
                        Tautan reset password sudah kedaluwarsa atau tidak
                        valid. Silakan minta tautan baru.
                    </p>
                    <router-link
                        to="/lupa-password"
                        class="w-full text-white text-sm font-semibold py-3 rounded-xl flex items-center justify-center gap-2 transition-all duration-200"
                        style="
                            background-color: #006e1c;
                            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                        "
                    >
                        <span>Minta Tautan Baru</span>
                        <span
                            class="material-symbols-outlined"
                            style="font-size: 20px"
                            >refresh</span
                        >
                    </router-link>
                </div>

                <!-- ── State: Form reset ── -->
                <div
                    v-else-if="tokenStatus === 'valid'"
                    class="bg-white rounded-xl p-6 border"
                    style="
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
                        border-color: rgba(190, 202, 184, 0.3);
                    "
                >
                    <!-- Header -->
                    <div class="mb-5">
                        <div class="flex items-center gap-2 mb-1">
                            <span
                                class="material-symbols-outlined"
                                style="color: #006e1c; font-size: 22px"
                                >lock_reset</span
                            >
                            <h2
                                class="font-bold text-xl"
                                style="color: #171d16"
                            >
                                Buat Password Baru
                            </h2>
                        </div>
                        <p style="color: #3f4a3c; font-size: 14px">
                            Password baru harus minimal 8 karakter.
                        </p>
                    </div>

                    <!-- Error global -->
                    <div
                        v-if="errorMsg"
                        class="mb-4 flex items-center gap-2 p-3 rounded-xl text-sm"
                        style="background: #ffdad6; color: #93000a"
                    >
                        <span
                            class="material-symbols-outlined"
                            style="font-size: 18px"
                            >error</span
                        >
                        {{ errorMsg }}
                    </div>

                    <form class="space-y-4" @submit.prevent="handleSubmit">
                        <!-- Password Baru -->
                        <div class="space-y-1">
                            <label
                                class="block ml-1 text-sm font-semibold"
                                style="color: #3f4a3c"
                                for="password"
                            >
                                Password Baru
                            </label>
                            <div class="relative">
                                <span
                                    class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 transition-colors"
                                    :style="{
                                        color: pwFocused
                                            ? '#006e1c'
                                            : '#6f7a6b',
                                    }"
                                    >lock</span
                                >
                                <input
                                    id="password"
                                    v-model="form.password"
                                    :type="showPw ? 'text' : 'password'"
                                    placeholder="Minimal 8 karakter"
                                    required
                                    class="w-full pl-12 pr-12 py-2.5 rounded-xl border outline-none transition-all text-sm"
                                    :style="fieldStyle(pwFocused, !!pwError)"
                                    @focus="pwFocused = true"
                                    @blur="
                                        pwFocused = false;
                                        validatePw();
                                    "
                                />
                                <button
                                    type="button"
                                    class="absolute right-4 top-1/2 -translate-y-1/2 transition-colors"
                                    style="color: #6f7a6b"
                                    @click="showPw = !showPw"
                                >
                                    <span class="material-symbols-outlined">{{
                                        showPw ? "visibility_off" : "visibility"
                                    }}</span>
                                </button>
                            </div>
                            <!-- Error inline -->
                            <p
                                v-if="pwError"
                                class="ml-1 text-xs"
                                style="color: #ba1a1a"
                            >
                                {{ pwError }}
                            </p>
                            <!-- Strength bar -->
                            <div v-if="form.password" class="mt-1.5 space-y-1">
                                <div class="flex gap-1">
                                    <div
                                        v-for="i in 4"
                                        :key="i"
                                        class="h-1 flex-1 rounded-full transition-all duration-300"
                                        :style="{
                                            background:
                                                i <= strength.level
                                                    ? strength.color
                                                    : '#dee4d8',
                                        }"
                                    ></div>
                                </div>
                                <p
                                    class="text-xs ml-1"
                                    :style="{ color: strength.color }"
                                >
                                    {{ strength.label }}
                                </p>
                            </div>
                        </div>

                        <!-- Konfirmasi Password -->
                        <div class="space-y-1">
                            <label
                                class="block ml-1 text-sm font-semibold"
                                style="color: #3f4a3c"
                                for="confirm"
                            >
                                Konfirmasi Password
                            </label>
                            <div class="relative">
                                <span
                                    class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 transition-colors"
                                    :style="{
                                        color: confirmFocused
                                            ? '#006e1c'
                                            : '#6f7a6b',
                                    }"
                                    >lock_clock</span
                                >
                                <input
                                    id="confirm"
                                    v-model="form.confirm"
                                    :type="showConfirm ? 'text' : 'password'"
                                    placeholder="Ulangi password baru"
                                    required
                                    class="w-full pl-12 pr-12 py-2.5 rounded-xl border outline-none transition-all text-sm"
                                    :style="
                                        fieldStyle(
                                            confirmFocused,
                                            !!confirmError,
                                        )
                                    "
                                    @focus="confirmFocused = true"
                                    @blur="
                                        confirmFocused = false;
                                        validateConfirm();
                                    "
                                />
                                <button
                                    type="button"
                                    class="absolute right-4 top-1/2 -translate-y-1/2 transition-colors"
                                    style="color: #6f7a6b"
                                    @click="showConfirm = !showConfirm"
                                >
                                    <span class="material-symbols-outlined">{{
                                        showConfirm
                                            ? "visibility_off"
                                            : "visibility"
                                    }}</span>
                                </button>
                            </div>
                            <p
                                v-if="confirmError"
                                class="ml-1 text-xs"
                                style="color: #ba1a1a"
                            >
                                {{ confirmError }}
                            </p>
                            <!-- Match indicator -->
                            <p
                                v-if="form.confirm && !confirmError"
                                class="ml-1 text-xs flex items-center gap-1"
                                style="color: #006e1c"
                            >
                                <span
                                    class="material-symbols-outlined icon-filled"
                                    style="font-size: 14px"
                                    >check_circle</span
                                >
                                Password cocok
                            </p>
                        </div>

                        <!-- Submit -->
                        <button
                            type="submit"
                            :disabled="isLoading || !!pwError || !!confirmError"
                            class="w-full text-white text-sm font-semibold py-3 rounded-xl flex items-center justify-center gap-2 transition-all duration-200 active:scale-95"
                            :style="
                                isLoading || !!pwError || !!confirmError
                                    ? 'background-color:#005313; opacity:0.6; box-shadow:0 4px 12px rgba(0,0,0,0.15); cursor:not-allowed;'
                                    : 'background-color:#006e1c; box-shadow:0 4px 12px rgba(0,0,0,0.15);'
                            "
                        >
                            <span>{{
                                isLoading
                                    ? "Menyimpan..."
                                    : "Simpan Password Baru"
                            }}</span>
                            <span
                                class="material-symbols-outlined"
                                style="font-size: 20px"
                            >
                                {{ isLoading ? "hourglass_empty" : "check" }}
                            </span>
                        </button>
                    </form>
                </div>

                <!-- ── State: Sukses ── -->
                <div
                    v-else-if="tokenStatus === 'success'"
                    class="bg-white rounded-xl p-6 border text-center"
                    style="
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
                        border-color: rgba(190, 202, 184, 0.3);
                    "
                >
                    <div class="flex justify-center mb-4">
                        <div
                            class="rounded-full flex items-center justify-center"
                            style="
                                width: 64px;
                                height: 64px;
                                background: #eff6e9;
                            "
                        >
                            <span
                                class="material-symbols-outlined icon-filled"
                                style="color: #006e1c; font-size: 36px"
                            >
                                verified
                            </span>
                        </div>
                    </div>
                    <h2 class="font-bold text-xl mb-2" style="color: #171d16">
                        Password Berhasil Diubah!
                    </h2>
                    <p class="text-sm mb-6" style="color: #3f4a3c">
                        Gunakan password baru Anda untuk masuk ke akun Tumbuh.
                    </p>
                    <!-- Countdown redirect -->
                    <p class="text-xs mb-4" style="color: #6f7a6b">
                        Otomatis kembali ke halaman masuk dalam
                        <strong style="color: #006e1c"
                            >{{ redirectCountdown }}d</strong
                        >...
                    </p>
                    <router-link
                        to="/login"
                        class="w-full text-white text-sm font-semibold py-3 rounded-xl flex items-center justify-center gap-2 transition-all duration-200"
                        style="
                            background-color: #006e1c;
                            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                        "
                    >
                        <span>Masuk Sekarang</span>
                        <span
                            class="material-symbols-outlined"
                            style="font-size: 20px"
                            >login</span
                        >
                    </router-link>
                </div>

                <!-- ── State: Validating (loading awal) ── -->
                <div
                    v-else
                    class="bg-white rounded-xl p-6 border flex flex-col items-center gap-4"
                    style="
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
                        border-color: rgba(190, 202, 184, 0.3);
                        min-height: 180px;
                        justify-content: center;
                    "
                >
                    <div class="spinner"></div>
                    <p class="text-sm" style="color: #3f4a3c">
                        Memverifikasi tautan...
                    </p>
                </div>

                <!-- Footer -->
                <div class="mt-6 flex justify-center gap-4">
                    <a
                        href="#"
                        class="text-xs hover:underline"
                        style="color: #6f7a6b"
                        >Kebijakan Privasi</a
                    >
                    <span style="color: #becab8">•</span>
                    <a
                        href="#"
                        class="text-xs hover:underline"
                        style="color: #6f7a6b"
                        >Bantuan</a
                    >
                </div>
            </div>
        </section>
    </main>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
// import { useRouter, useRoute } from 'vue-router'

// const router = useRouter()
// const route  = useRoute()
const BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000/api";

// ── Token dari URL ─────────────────────────────────────────────────────
// Dengan Vue Router: const token = route.query.token
// Tanpa Vue Router (fallback):
const token = new URLSearchParams(window.location.search).get("token") ?? "";

// ── State mesin ───────────────────────────────────────────────────────
// 'validating' | 'valid' | 'invalid' | 'success'
const tokenStatus = ref("validating");

// ── Form ──────────────────────────────────────────────────────────────
const form = reactive({ password: "", confirm: "" });

const showPw = ref(false);
const showConfirm = ref(false);
const pwFocused = ref(false);
const confirmFocused = ref(false);
const pwError = ref("");
const confirmError = ref("");
const errorMsg = ref("");
const isLoading = ref(false);
const redirectCountdown = ref(5);

// ── Validasi ──────────────────────────────────────────────────────────
function validatePw() {
    if (!form.password) {
        pwError.value = "Password tidak boleh kosong.";
        return;
    }
    if (form.password.length < 8) {
        pwError.value = "Minimal 8 karakter.";
        return;
    }
    pwError.value = "";
}

function validateConfirm() {
    if (!form.confirm) {
        confirmError.value = "Konfirmasi password tidak boleh kosong.";
        return;
    }
    if (form.confirm !== form.password) {
        confirmError.value = "Password tidak cocok.";
        return;
    }
    confirmError.value = "";
}

// Password strength meter
const strength = computed(() => {
    const p = form.password;
    if (!p) return { level: 0, label: "", color: "#dee4d8" };
    let score = 0;
    if (p.length >= 8) score++;
    if (p.length >= 12) score++;
    if (/[A-Z]/.test(p) && /[a-z]/.test(p)) score++;
    if (/[0-9]/.test(p) && /[^A-Za-z0-9]/.test(p)) score++;
    const map = [
        { level: 1, label: "Lemah", color: "#ba1a1a" },
        { level: 2, label: "Cukup", color: "#e65c00" },
        { level: 3, label: "Kuat", color: "#f0a500" },
        { level: 4, label: "Sangat Kuat", color: "#006e1c" },
    ];
    return map[Math.max(0, score - 1)] ?? map[0];
});

// Field style helper (sama persis dengan LoginPage)
function fieldStyle(focused, hasError) {
    if (hasError)
        return "background-color:#eff6e9; border-color:#ba1a1a; box-shadow:0 0 0 2px rgba(186,26,26,0.15); color:#171d16;";
    if (focused)
        return "background-color:#eff6e9; border-color:#006e1c; box-shadow:0 0 0 2px rgba(0,110,28,0.2); color:#171d16;";
    return "background-color:#eff6e9; border-color:#becab8; color:#171d16;";
}

// ── Verifikasi token saat mount ───────────────────────────────────────
onMounted(async () => {
    if (!token) {
        tokenStatus.value = "invalid";
        return;
    }

    try {
        // GET /api/auth/verify-reset-token?token=xxx
        const res = await fetch(
            `${BASE_URL}/auth/verify-reset-token?token=${token}`,
        );
        tokenStatus.value = res.ok ? "valid" : "invalid";
    } catch {
        tokenStatus.value = "invalid";
    }
});

// ── Submit ────────────────────────────────────────────────────────────
async function handleSubmit() {
    validatePw();
    validateConfirm();
    if (pwError.value || confirmError.value) return;

    errorMsg.value = "";
    isLoading.value = true;
    try {
        // POST /api/auth/reset-password  { token, password }
        const res = await fetch(`${BASE_URL}/auth/reset-password`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ token, password: form.password }),
        });
        if (!res.ok) {
            const data = await res.json().catch(() => ({}));
            throw new Error(
                data.message ?? "Gagal menyimpan password. Coba lagi.",
            );
        }

        tokenStatus.value = "success";
        startRedirectCountdown();
    } catch (e) {
        errorMsg.value = e.message;
    } finally {
        isLoading.value = false;
    }
}

function startRedirectCountdown() {
    const t = setInterval(() => {
        redirectCountdown.value--;
        if (redirectCountdown.value <= 0) {
            clearInterval(t);
            // router.push('/login')
            window.location.href = "/login"; // fallback tanpa router
        }
    }, 1000);
}
</script>

<style>
@import url("https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap");
* {
    font-family: "Manrope", sans-serif;
    box-sizing: border-box;
}
@layer base {
    .material-symbols-outlined {
        font-variation-settings:
            "FILL" 0,
            "wght" 400,
            "GRAD" 0,
            "opsz" 24;
        display: inline-block;
        vertical-align: middle;
    }
}
::selection {
    background-color: #72da72;
    color: #005e17;
}
</style>

<style scoped>
.spinner {
    width: 36px;
    height: 36px;
    border: 3px solid #eff6e9;
    border-top-color: #006e1c;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
}
@keyframes spin {
    to {
        transform: rotate(360deg);
    }
}
</style>
