<template>
    <section
        class="login-branding hidden md:flex md:w-1/2 relative items-center justify-center p-10"
        aria-label="Branding Tumbuh — Platform Digital Posyandu"
    >
        <!-- Overlay cahaya kiri atas -->
        <div class="overlay overlay--top-left" aria-hidden="true" />
        <!-- Overlay cahaya kanan bawah -->
        <div class="overlay overlay--bottom-right" aria-hidden="true" />

        <div
            class="relative z-10 text-center text-white flex flex-col items-center"
        >
            <BrandingIllustration
                image-class="w-44 h-auto mb-2"
                aria-label="Ilustrasi ibu menggendong bayi"
            />

            <h1 class="branding-title text-3xl font-bold tracking-tight mb-2">
                Tumbuh
            </h1>

            <p
                class="branding-tagline text-base leading-relaxed max-w-xs mx-auto font-medium"
            >
                Ekosistem digital Posyandu untuk pemantauan tumbuh kembang anak
                dan pencegahan stunting
            </p>
        </div>
    </section>
</template>

<script setup>
import BrandingIllustration from "@/components/ui/BrandingIllustration.vue";
</script>

<style scoped>
/* ─── Panel background gradient ──────────────────────────────────── */
.login-branding {
    background: linear-gradient(
        135deg,
        var(--color-green-600) 0%,
        var(--color-green-700) 50%,
        var(--color-green-900) 100%
    );
}

/* ─── Overlay dekoratif ───────────────────────────────────────────── */
.overlay {
    position: absolute;
    inset: 0;
    pointer-events: none;
}

.overlay--top-left {
    background: radial-gradient(
        circle at top left,
        rgba(255, 255, 255, 0.15),
        transparent 40%
    );
}

.overlay--bottom-right {
    background: radial-gradient(
        circle at bottom right,
        rgba(255, 255, 255, 0.08),
        transparent 50%
    );
}

/* ─── Tipografi ───────────────────────────────────────────────────── */
.branding-title {
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.branding-tagline {
    color: rgba(255, 255, 255, 0.9);
}
</style>
