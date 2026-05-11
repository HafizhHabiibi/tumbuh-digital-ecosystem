<template>
    <div class="layout">
        <AppSidebar :initial-active="activeMenu" @logout="handleLogout" />

        <div class="layout__main">
            <AppHeader
                :title="pageTitle"
                :user-name="user.name"
                :user-role="user.role"
                :posyandu="user.posyandu"
                :has-notification="hasNotification"
                @notification="handleNotification"
                @settings="handleSettings"
            />

            <!-- Konten halaman masuk di sini -->
            <div class="layout__content">
                <slot />
            </div>
        </div>
    </div>
</template>

<script setup>
import AppSidebar from "@/components/AppSidebar.vue";
import AppHeader from "@/components/AppHeader.vue";

defineProps({
    // Judul yang muncul di header — dikirim dari tiap halaman
    pageTitle: {
        type: String,
        default: "Dashboard",
    },
    // Menu mana yang aktif di sidebar
    activeMenu: {
        type: String,
        default: "Dashboard",
    },
    // Data user — idealnya dari auth store (Pinia)
    user: {
        type: Object,
        default: () => ({
            name: "Pengguna",
            role: "Kader Posyandu",
            posyandu: "Posyandu",
        }),
    },
    hasNotification: {
        type: Boolean,
        default: false,
    },
});

const emit = defineEmits(["logout", "notification", "settings"]);

function handleLogout() {
    emit("logout");
}
function handleNotification() {
    emit("notification");
}
function handleSettings() {
    emit("settings");
}
</script>

<style scoped>
.layout {
    min-height: 100vh;
    background-color: #f5fbef;
    font-family: "Manrope", sans-serif;
}

.layout__main {
    padding-left: 256px; /* lebar sidebar */
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

.layout__content {
    padding: 2.5rem;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}
</style>
