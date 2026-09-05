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
        // Reset token dan widget setelah submit sukses.
        turnstileToken.value = "";
        forgotFormRef.value?.resetTurnstile();
    } else {
        // Verifikasi keamanan harus diulang jika permintaan gagal.
        turnstileToken.value = "";
        forgotFormRef.value?.resetTurnstile();
    }
};

const handleResend = async () => {
    if (authStore.loading.forgotPassword) return;

    // Kembali ke form agar pengguna dapat meminta tautan baru.
    submitted.value = false;
    turnstileToken.value = "";
    forgotFormRef.value?.resetTurnstile();
};
</script>
