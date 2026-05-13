<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <LoginBranding />

        <FormForgotPassword
            v-model:email="email"
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

const email = ref("");
const submitted = ref(false);
const submittedEmail = ref("");

const isEmailValid = computed(() =>
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim()),
);

const handleSubmit = async () => {
    if (authStore.loading.forgotPassword) return;

    const success = await authStore.forgotPassword(email.value.trim());
    if (success) {
        submittedEmail.value = email.value.trim();
        submitted.value = true;
    }
};

/** Kirim ulang — reset flag lalu panggil submit lagi */
const handleResend = () => {
    submitted.value = false;
    handleSubmit();
};
</script>
