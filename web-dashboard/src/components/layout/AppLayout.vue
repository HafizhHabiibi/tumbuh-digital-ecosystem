<template>
    <div class="flex min-h-dvh bg-[#f5fbef]">
        <!-- Sidebar -->
        <AppSidebar
            id="app-sidebar"
            :open="sidebarOpen"
            @close="sidebarOpen = false"
        />

        <!-- Area konten kanan -->
        <div class="flex flex-col flex-1 min-w-0 overflow-x-hidden">
            <!-- Header mobile only -->
            <AppHeader
                :sidebar-open="sidebarOpen"
                @toggle-sidebar="sidebarOpen = !sidebarOpen"
            />

            <!-- Konten halaman -->
            <main
                id="main-content"
                class="flex-1 overflow-y-auto"
                tabindex="-1"
            >
                <RouterView />
            </main>
        </div>
    </div>
</template>

<script setup>
import { ref } from "vue";
import AppSidebar from "@/components/layout/AppSidebar.vue";
import AppHeader from "@/components/layout/AppHeader.vue";

const sidebarOpen = ref(false);
</script>
