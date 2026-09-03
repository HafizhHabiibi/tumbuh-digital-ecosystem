<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <LoginBranding />

        <!-- [1] Tambah ref="loginFormRef" agar bisa akses method dari FormLogin -->
        <LoginForm
            ref="loginFormRef"
            v-model:email="form.email"
            v-model:password="form.password"
            v-model:turnstile-token="form.turnstileToken"
            :is-valid="isFormValid"
            :loading="authStore.loading.login"
            :error="authStore.error.login"
            @submit="handleLogin"
        />
    </main>
</template>

<script setup>
import { ref, computed } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/authStore";
import LoginBranding from "@/components/layout/LoginBranding.vue";
import LoginForm from "@/components/forms/FormLogin.vue";
import { dashboardPathForRole } from "@/utils/authRouting.js";

const router = useRouter();
const authStore = useAuthStore();

// [1] Ref ke komponen FormLogin untuk akses defineExpose-nya
const loginFormRef = ref(null);

const form = ref({
    email: "",
    password: "",
    turnstileToken: "",
});

const isFormValid = computed(
    () =>
        form.value.email.trim() !== "" &&
        form.value.password.length >= 6 &&
        form.value.turnstileToken !== "",
);

const handleLogin = async () => {
    if (authStore.loading.login) return;

    const success = await authStore.login(
        form.value.email,
        form.value.password,
        form.value.turnstileToken,
    );

    if (success) {
        const dashboardPath = dashboardPathForRole(authStore.role);
        if (dashboardPath) {
            router.push(dashboardPath);
        } else {
            authStore.clearAuth();
        }
    } else {
        // [2] Login gagal: kosongkan token lalu reset widget Turnstile
        // Mengosongkan token dulu membuat tombol langsung ke-disable
        // resetTurnstile() membuat widget Cloudflare render ulang dari awal
        form.value.turnstileToken = "";
        loginFormRef.value?.resetTurnstile();
    }
};
</script>
