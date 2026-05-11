<template>
    <header class="header">
        <!-- Kiri: judul halaman + info -->
        <div>
            <h2 class="header__title">{{ title }}</h2>
            <p class="header__subtitle">{{ formattedDate }} • {{ posyandu }}</p>
        </div>

        <!-- Kanan: aksi + profil -->
        <div class="header__actions">
            <button
                class="icon-btn"
                style="position: relative"
                @click="$emit('notification')"
            >
                <span class="material-symbols-outlined">notifications</span>
                <span v-if="hasNotification" class="notif-dot"></span>
            </button>

            <button class="icon-btn" @click="$emit('settings')">
                <span class="material-symbols-outlined">settings</span>
            </button>

            <div class="header__profile">
                <div class="text-right">
                    <p class="profile__name">{{ userName }}</p>
                    <p class="profile__role">{{ userRole }}</p>
                </div>
            </div>
        </div>
    </header>
</template>

<script setup>
import { computed } from "vue";

const props = defineProps({
    // Judul dinamis — tiap halaman bisa kirim judul berbeda
    title: {
        type: String,
        default: "Dashboard",
    },
    userName: {
        type: String,
        default: "Pengguna",
    },
    userRole: {
        type: String,
        default: "Kader Posyandu",
    },
    posyandu: {
        type: String,
        default: "Posyandu",
    },
    hasNotification: {
        type: Boolean,
        default: false,
    },
});

defineEmits(["notification", "settings"]);

const formattedDate = computed(() =>
    new Date().toLocaleDateString("id-ID", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
    }),
);
</script>

<style scoped>
.header {
    position: sticky;
    top: 0;
    z-index: 40;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: #f5fbef;
    padding: 1rem 2.5rem;
    border-bottom: 1px solid #becab8;
}

.header__title {
    font-size: 24px;
    font-weight: 700;
    color: #171d16;
    line-height: 32px;
}
.header__subtitle {
    font-size: 14px;
    color: #3f4a3c;
}

.header__actions {
    display: flex;
    align-items: center;
    gap: 1.5rem;
}

.icon-btn {
    padding: 0.5rem;
    color: #3f4a3c;
    background: none;
    border: none;
    cursor: pointer;
    border-radius: 0.5rem;
    transition: color 0.2s;
}
.icon-btn:hover {
    color: #006e1c;
}

.notif-dot {
    position: absolute;
    top: 6px;
    right: 6px;
    width: 8px;
    height: 8px;
    background: #ba1a1a;
    border-radius: 50%;
}

.header__profile {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding-left: 1rem;
    border-left: 1px solid #becab8;
}
.profile__name {
    font-size: 14px;
    font-weight: 600;
    color: #171d16;
}
.profile__role {
    font-size: 12px;
    color: #3f4a3c;
}
</style>
