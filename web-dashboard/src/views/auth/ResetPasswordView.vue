<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <LoginBranding />

        <FormResetPassword
            v-model:password="form.password"
            v-model:password-confirmation="form.passwordConfirmation"
            :is-valid="isFormValid"
            :loading="authStore.loading.resetPassword"
            :error="authStore.error.resetPassword"
            :token-invalid="tokenInvalid"
            :succeeded="succeeded"
            @submit="handleSubmit"
        />
    </main>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useAuthStore } from "@/stores/authStore";
import LoginBranding from "@/components/layout/LoginBranding.vue";
import FormResetPassword from "@/components/forms/FormResetPassword.vue";

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const form = ref({ password: "", passwordConfirmation: "" });
const succeeded = ref(false);
const tokenInvalid = ref(false);

/** Token dari query string: /reset-password?token=xxxx */
const token = computed(() => route.query.token ?? "");

onMounted(() => {
    if (!token.value) tokenInvalid.value = true;
});

const isFormValid = computed(() => {
    const { password, passwordConfirmation } = form.value;
    return password.length >= 8 && password === passwordConfirmation;
});

const handleSubmit = async () => {
    if (authStore.loading.resetPassword) return;

    // authStore.resetPassword(token, password_baru) — sesuai signature di store
    const success = await authStore.resetPassword(
        token.value,
        form.value.password,
    );

    if (success) {
        succeeded.value = true;
        setTimeout(() => router.push({ name: "Login" }), 2000);
    }
};
</script>
