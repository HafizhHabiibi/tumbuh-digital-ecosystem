<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <!-- Left Section: Branding -->
        <section
            class="hidden md:flex md:w-1/2 relative bg-primary items-center justify-center p-margin-desktop"
            style="
                background: linear-gradient(135deg, #008f24, #006e1c, #004d13);
            "
        >
            <!-- Decorative overlays -->
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

        <!-- Right Section: Login Form -->
        <section
            class="flex-1 flex items-center justify-center p-4 md:p-8"
            style="background-color: #ffffff"
        >
            <div class="w-full max-w-md">
                <!-- Mobile Logo -->
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

                <!-- Login Card -->
                <div
                    class="bg-white rounded-xl p-6 border"
                    style="
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
                        border-color: rgba(190, 202, 184, 0.3);
                    "
                >
                    <div class="mb-5">
                        <h2
                            class="font-bold text-xl mb-1"
                            style="color: #171d16"
                        >
                            Selamat Datang
                        </h2>
                        <p style="color: #3f4a3c; font-size: 14px">
                            Platform Digital Posyandu untuk Pemantauan dan
                            Edukasi Balita
                        </p>
                    </div>

                    <form class="space-y-4" @submit.prevent="handleSubmit">
                        <!-- Email Field -->
                        <div class="space-y-1">
                            <label
                                class="block ml-1 text-sm font-semibold"
                                style="color: #3f4a3c"
                                for="email"
                                >Email</label
                            >
                            <div class="relative group">
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
                                    v-model="form.email"
                                    type="email"
                                    placeholder="nama@instansi.com"
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

                        <!-- Password Field -->
                        <div class="space-y-1">
                            <label
                                class="block ml-1 text-sm font-semibold"
                                style="color: #3f4a3c"
                                for="password"
                                >Password</label
                            >
                            <div class="relative group">
                                <span
                                    class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 transition-colors"
                                    :style="{
                                        color: passwordFocused
                                            ? '#006e1c'
                                            : '#6f7a6b',
                                    }"
                                    >lock</span
                                >
                                <input
                                    id="password"
                                    v-model="form.password"
                                    :type="showPassword ? 'text' : 'password'"
                                    placeholder="••••••••"
                                    class="w-full pl-12 pr-12 py-2.5 rounded-xl border outline-none transition-all text-sm"
                                    :style="
                                        passwordFocused
                                            ? 'background-color:#eff6e9; border-color:#006e1c; box-shadow:0 0 0 2px rgba(0,110,28,0.2); color:#171d16;'
                                            : 'background-color:#eff6e9; border-color:#becab8; color:#171d16;'
                                    "
                                    @focus="passwordFocused = true"
                                    @blur="passwordFocused = false"
                                />
                                <button
                                    type="button"
                                    class="absolute right-4 top-1/2 -translate-y-1/2 transition-colors"
                                    style="color: #6f7a6b"
                                    @click="showPassword = !showPassword"
                                >
                                    <span class="material-symbols-outlined">{{
                                        showPassword
                                            ? "visibility_off"
                                            : "visibility"
                                    }}</span>
                                </button>
                            </div>
                        </div>

                        <!-- Forgot Password -->
                        <div class="flex items-center justify-end">
                            <a
                                href="#"
                                class="text-sm font-bold hover:underline transition-colors"
                                style="color: #006e1c"
                                >Lupa Password?</a
                            >
                        </div>

                        <!-- Submit Button -->
                        <button
                            type="submit"
                            class="w-full text-white text-sm font-semibold py-3 rounded-xl flex items-center justify-center gap-2 transition-all duration-200 active:scale-95"
                            :style="
                                isLoading
                                    ? 'background-color:#005313; box-shadow:0 4px 12px rgba(0,0,0,0.15); opacity:0.8;'
                                    : 'background-color:#006e1c; box-shadow:0 4px 12px rgba(0,0,0,0.15);'
                            "
                            :disabled="isLoading"
                            @mouseenter="btnHover = true"
                            @mouseleave="btnHover = false"
                        >
                            <span v-if="!isLoading">Masuk</span>
                            <span v-else>Memproses...</span>
                            <span
                                class="material-symbols-outlined"
                                style="font-size: 20px"
                            >
                                {{ isLoading ? "hourglass_empty" : "login" }}
                            </span>
                        </button>
                    </form>
                </div>

                <!-- Footer Links -->
                <p class="mt-5 text-center text-xs" style="color: #6f7a6b">
                    Belum punya akun?
                    <a
                        href="#"
                        class="font-bold hover:underline"
                        style="color: #006e1c"
                        >Hubungi Admin Puskesmas</a
                    >
                </p>
                <div class="mt-6 flex justify-center gap-4">
                    <a
                        href="#"
                        class="text-xs hover:underline transition-colors"
                        style="color: #6f7a6b"
                        >Kebijakan Privasi</a
                    >
                    <span style="color: #becab8">•</span>
                    <a
                        href="#"
                        class="text-xs hover:underline transition-colors"
                        style="color: #6f7a6b"
                        >Bantuan</a
                    >
                </div>
            </div>
        </section>
    </main>
</template>

<script setup>
import { ref, reactive } from "vue";

// Form state
const form = reactive({
    email: "",
    password: "",
});

// UI state
const showPassword = ref(false);
const emailFocused = ref(false);
const passwordFocused = ref(false);
const btnHover = ref(false);
const isLoading = ref(false);

// Submit handler
async function handleSubmit() {
    if (!form.email || !form.password) return;

    isLoading.value = true;
    try {
        // Replace with your actual API call
        await new Promise((resolve) => setTimeout(resolve, 1500));
        console.log("Login submitted:", form.email);
        // e.g. router.push('/dashboard')
    } catch (error) {
        console.error("Login failed:", error);
    } finally {
        isLoading.value = false;
    }
}
</script>

<style>
@import url("https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap");

* {
    font-family: "Manrope", sans-serif;
    box-sizing: border-box;
}

.material-symbols-outlined {
    font-variation-settings:
        "FILL" 0,
        "wght" 400,
        "GRAD" 0,
        "opsz" 24;
    display: inline-block;
    vertical-align: middle;
}

::selection {
    background-color: #72da72;
    color: #005e17;
}
</style>
