<template>
    <main class="min-h-screen flex flex-col md:flex-row">
        <LoginBranding />

        <LoginForm
            v-model:email="form.email"
            v-model:password="form.password"
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

const router = useRouter();
const authStore = useAuthStore();

const form = ref({ email: "", password: "" });

const isFormValid = computed(
    () => form.value.email.trim() !== "" && form.value.password.length >= 6,
);

const handleLogin = async () => {
    if (authStore.loading.login) return;

    const success = await authStore.login(
        form.value.email,
        form.value.password,
    );

    if (success) {
        router.push({
            name: authStore.isKader ? "KaderDashboard" : "PuskesmasDashboard",
        });
    }
};
</script>
