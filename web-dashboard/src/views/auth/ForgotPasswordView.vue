<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <LoginBranding />

        <!-- [1] Tambah ref="forgotFormRef" agar bisa akses method dari FormForgotPassword -->
        <FormForgotPassword
            ref="forgotFormRef"
            v-model:email="email"
            v-model:turnstile-token="turnstileToken"
            :is-valid="isEmailValid"
            :loading="authStore.loading.forgotPassword"
            :error="authStore.error.forgotPassword"
            :submitted="submitted"
            :submitted-email="submittedEmail"
            @submit="handleSubmit"
            @resend="handleResend"
        />
    </main>
</template>

<script setup>
import { ref, computed } from "vue";
import { useAuthStore } from "@/stores/authStore";
import LoginBranding from "@/components/layout/LoginBranding.vue";
import FormForgotPassword from "@/components/forms/FormForgotPassword.vue";

const authStore = useAuthStore();

// [1] Ref ke komponen FormForgotPassword untuk akses defineExpose-nya
const forgotFormRef = ref(null);

const email = ref("");
const submitted = ref(false);
const submittedEmail = ref("");
const turnstileToken = ref("");

const isEmailValid = computed(
    () =>
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim()) &&
        turnstileToken.value !== "",
);

const handleSubmit = async () => {
    if (authStore.loading.forgotPassword) return;

    const success = await authStore.forgotPassword(
        email.value.trim(),
        turnstileToken.value,
    );

    if (success) {
        submittedEmail.value = email.value.trim();
        submitted.value = true;
        // [2] Reset token + widget setelah submit sukses
        // Widget tetap tampil untuk keperluan tombol "Kirim ulang"
        turnstileToken.value = "";
        forgotFormRef.value?.resetTurnstile();
    } else {
        // [3] Reset token + widget jika submit gagal
        // Sama seperti Login — user harus verifikasi ulang sebelum coba lagi
        turnstileToken.value = "";
        forgotFormRef.value?.resetTurnstile();
    }
};

const handleResend = async () => {
    if (authStore.loading.forgotPassword) return;

    // [4] Kembali ke state form, token dikosongkan, widget di-reset
    // User harus selesaikan Turnstile dulu sebelum bisa submit lagi
    submitted.value = false;
    turnstileToken.value = "";
    forgotFormRef.value?.resetTurnstile();
};
</script>
