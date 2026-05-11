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

        <!-- ── Right: Form ── -->
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

                <!-- ── State: Form ── -->
                <div
                    v-if="!isSuccess"
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
                                Lupa Password
                            </h2>
                        </div>
                        <p style="color: #3f4a3c; font-size: 14px">
                            Masukkan email akun Anda. Kami akan mengirimkan
                            tautan untuk mereset password.
                        </p>
                    </div>

                    <!-- Error -->
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
                        <!-- Email -->
                        <div class="space-y-1">
                            <label
                                class="block ml-1 text-sm font-semibold"
                                style="color: #3f4a3c"
                                for="email"
                            >
                                Email
                            </label>
                            <div class="relative">
                                <span
                                    class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 transition-colors"
                                    :style="{
                                        color: emailFocused
                                            ? '#006e1c'
                                            : '#6f7a6b',
                                    }"
                                    >mail</span
                                >
                                <input
                                    id="email"
                                    v-model="email"
                                    type="email"
                                    placeholder="nama@instansi.com"
                                    required
                                    class="w-full pl-12 pr-4 py-2.5 rounded-xl border outline-none transition-all text-sm"
                                    :style="
                                        emailFocused
                                            ? 'background-color:#eff6e9; border-color:#006e1c; box-shadow:0 0 0 2px rgba(0,110,28,0.2); color:#171d16;'
                                            : 'background-color:#eff6e9; border-color:#becab8; color:#171d16;'
                                    "
                                    @focus="emailFocused = true"
                                    @blur="emailFocused = false"
                                />
                            </div>
                        </div>

                        <!-- Submit -->
                        <button
                            type="submit"
                            :disabled="isLoading"
                            class="w-full text-white text-sm font-semibold py-3 rounded-xl flex items-center justify-center gap-2 transition-all duration-200 active:scale-95"
                            :style="
                                isLoading
                                    ? 'background-color:#005313; opacity:0.8; box-shadow:0 4px 12px rgba(0,0,0,0.15);'
                                    : 'background-color:#006e1c; box-shadow:0 4px 12px rgba(0,0,0,0.15);'
                            "
                        >
                            <span>{{
                                isLoading ? "Mengirim..." : "Kirim Tautan Reset"
                            }}</span>
                            <span
                                class="material-symbols-outlined"
                                style="font-size: 20px"
                            >
                                {{ isLoading ? "hourglass_empty" : "send" }}
                            </span>
                        </button>
                    </form>
                </div>

                <!-- ── State: Sukses ── -->
                <div
                    v-else
                    class="bg-white rounded-xl p-6 border text-center"
                    style="
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
                        border-color: rgba(190, 202, 184, 0.3);
                    "
                >
                    <!-- Ikon sukses -->
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
                                mark_email_read
                            </span>
                        </div>
                    </div>

                    <h2 class="font-bold text-xl mb-2" style="color: #171d16">
                        Email Terkirim!
                    </h2>
                    <p class="text-sm mb-1" style="color: #3f4a3c">
                        Tautan reset password telah dikirim ke:
                    </p>
                    <p class="text-sm font-bold mb-5" style="color: #006e1c">
                        {{ email }}
                    </p>
                    <p class="text-xs mb-6" style="color: #6f7a6b">
                        Periksa folder <strong>Spam</strong> jika email tidak
                        masuk dalam beberapa menit. Tautan berlaku selama
                        <strong>30 menit</strong>.
                    </p>

                    <!-- Kirim ulang -->
                    <button
                        :disabled="resendCooldown > 0"
                        class="w-full text-sm font-semibold py-3 rounded-xl border transition-all duration-200"
                        :style="
                            resendCooldown > 0
                                ? 'color:#6f7a6b; border-color:#becab8; cursor:not-allowed;'
                                : 'color:#006e1c; border-color:#006e1c; cursor:pointer;'
                        "
                        @click="handleResend"
                    >
                        {{
                            resendCooldown > 0
                                ? `Kirim ulang dalam ${resendCooldown}d`
                                : "Kirim Ulang Email"
                        }}
                    </button>

                    <div class="mt-4">
                        <router-link
                            to="/login"
                            class="text-sm font-bold hover:underline"
                            style="color: #006e1c"
                            >← Kembali ke Halaman Masuk</router-link
                        >
                    </div>
                </div>

                <!-- Footer -->
                <div class="mt-5 text-center">
                    <router-link
                        v-if="!isSuccess"
                        to="/login"
                        class="text-xs font-bold hover:underline"
                        style="color: #006e1c"
                        >← Kembali ke Halaman Masuk</router-link
                    >
                </div>
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
import { ref } from "vue";
// import { useRouter } from 'vue-router'

// const router = useRouter()
const BASE_URL = import.meta.env.VITE_API_URL ?? "http://localhost:8000/api";

const email = ref("");
const emailFocused = ref(false);
const isLoading = ref(false);
const isSuccess = ref(false);
const errorMsg = ref("");
const resendCooldown = ref(0);

let cooldownTimer = null;

async function handleSubmit() {
    errorMsg.value = "";
    if (!email.value) return;

    isLoading.value = true;
    try {
        // POST /api/auth/forgot-password  { email }
        const res = await fetch(`${BASE_URL}/auth/forgot-password`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: email.value }),
        });
        if (!res.ok) {
            const data = await res.json().catch(() => ({}));
            throw new Error(data.message ?? "Gagal mengirim email. Coba lagi.");
        }
        isSuccess.value = true;
        startCooldown();
    } catch (e) {
        errorMsg.value = e.message;
    } finally {
        isLoading.value = false;
    }
}

async function handleResend() {
    if (resendCooldown.value > 0) return;
    isLoading.value = true;
    try {
        await fetch(`${BASE_URL}/auth/forgot-password`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email: email.value }),
        });
        startCooldown();
    } catch {
        // silent — user bisa coba lagi
    } finally {
        isLoading.value = false;
    }
}

function startCooldown(seconds = 60) {
    resendCooldown.value = seconds;
    clearInterval(cooldownTimer);
    cooldownTimer = setInterval(() => {
        resendCooldown.value--;
        if (resendCooldown.value <= 0) clearInterval(cooldownTimer);
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
