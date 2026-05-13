<template>
    <img
        :src="illustrationUrl"
        :class="imageClass"
        :style="{ color }"
        alt="Ilustrasi ibu menggendong bayi"
        role="img"
        aria-label="Logo Tumbuh — ilustrasi ibu menggendong bayi"
        loading="eager"
    />
</template>

<script setup>
import illustrationUrl from "@/assets/tumbuh.png";

defineProps({
    imageClass: {
        type: String,
        default: "w-52 h-auto",
    },

    color: {
        type: String,
        default: "white",
    },
});
</script>
