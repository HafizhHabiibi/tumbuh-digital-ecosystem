<template>
    <aside class="sidebar">
        <!-- Brand -->
        <div class="sidebar__brand">
            <h1 class="sidebar__title">Tumbuh</h1>
            <p class="sidebar__subtitle">Sistem Informasi Posyandu</p>
        </div>

        <!-- Nav -->
        <nav class="sidebar__nav">
            <a
                v-for="item in navItems"
                :key="item.label"
                href="#"
                class="nav-link"
                :class="{ 'nav-link--active': item.active }"
                @click.prevent="setActive(item)"
            >
                <span
                    class="material-symbols-outlined"
                    :class="item.active ? 'icon-filled' : ''"
                    >{{ item.icon }}</span
                >
                <span>{{ item.label }}</span>
            </a>
        </nav>

        <!-- Logout -->
        <div class="sidebar__footer">
            <button class="btn-logout" @click="$emit('logout')">
                <span class="material-symbols-outlined text-lg">logout</span>
                Keluar
            </button>
        </div>
    </aside>
</template>

<script setup>
import { ref } from "vue";

defineEmits(["logout"]);

const props = defineProps({
    initialActive: {
        type: String,
        default: "Dashboard",
    },
});

const navItems = ref(
    [
        { label: "Dashboard", icon: "dashboard" },
        { label: "Data Orang Tua", icon: "family_restroom" },
        { label: "Data Anak", icon: "child_care" },
        { label: "Input Pengukuran", icon: "straighten" },
        { label: "Riwayat Pemberian", icon: "history_edu" },
        { label: "Rujukan", icon: "emergency_home" },
        { label: "Jadwal Posyandu", icon: "calendar_month" },
        { label: "Profil", icon: "person" },
    ].map((item) => ({ ...item, active: item.label === props.initialActive })),
);

function setActive(selected) {
    navItems.value.forEach((item) => (item.active = item === selected));
}
</script>

<style scoped>
.sidebar {
    position: fixed;
    left: 0;
    top: 0;
    height: 100%;
    width: 256px;
    display: flex;
    flex-direction: column;
    background-color: #eff6e9;
    border-right: 1px solid #becab8;
    padding: 2.5rem 0;
    z-index: 50;
}

.sidebar__brand {
    padding: 0 1rem 2rem 1rem;
}
.sidebar__title {
    font-size: 24px;
    font-weight: 700;
    color: #006e1c;
    line-height: 32px;
}
.sidebar__subtitle {
    font-size: 12px;
    color: #3f4a3c;
    opacity: 0.7;
    font-weight: 500;
}

.sidebar__nav {
    flex: 1;
    padding: 0 0.5rem;
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.nav-link {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1rem;
    border-radius: 0.5rem;
    font-size: 14px;
    font-weight: 600;
    color: #3f4a3c;
    text-decoration: none;
    transition: background 0.15s;
}
.nav-link:hover {
    background: #dee4d8;
}
.nav-link--active {
    background: #72da72;
    color: #005e17;
}

.sidebar__footer {
    padding: 0 1rem;
    margin-top: auto;
}
.btn-logout {
    width: 100%;
    padding: 0.75rem 1rem;
    background: #7b5549;
    color: #fff;
    border-radius: 0.75rem;
    font-size: 14px;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    cursor: pointer;
    border: none;
    transition: opacity 0.2s;
}
.btn-logout:hover {
    opacity: 0.9;
}
</style>
