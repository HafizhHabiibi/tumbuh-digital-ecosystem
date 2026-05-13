<!-- Contoh placeholder untuk semua view yang belum dibuat -->
<template>
    <div class="p-8 space-y-4">
        <h1 class="text-2xl font-bold">Halaman ini sedang dikerjakan</h1>

        <button
            @click="resetAuth"
            class="px-4 py-2 rounded-lg bg-red-500 text-white"
        >
            Reset Auth
        </button>
    </div>
</template>

<script setup>
const resetAuth = () => {
    localStorage.clear();
    window.location.reload();
};
</script>
