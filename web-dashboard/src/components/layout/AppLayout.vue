<template>
    <div class="flex min-h-screen bg-gray-100">
        <!-- Sidebar -->
        <AppSidebar />

        <!-- Content Area -->
        <div class="flex flex-col flex-1">
            <!-- Header -->
            <AppHeader />

            <!-- Page Content -->
            <main class="flex-1 p-6">
                <RouterView />
            </main>
        </div>
    </div>
</template>

<script setup>
import { RouterView } from "vue-router";

import AppSidebar from "./AppSidebar.vue";
import AppHeader from "./AppHeader.vue";
</script>
