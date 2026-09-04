<template>
    <div class="page-header flex items-center justify-between gap-4 flex-wrap pb-1">
        <h1 class="page-header__title text-2xl font-bold tracking-tight m-0">
            {{ title }}
        </h1>

        <div
            v-if="$slots.actions || $slots.default"
            class="page-header__actions flex items-center gap-2.5 flex-wrap"
        >
            <slot name="actions">
                <slot />
            </slot>
        </div>
    </div>
</template>

<script setup>
defineProps({
    title: {
        type: String,
        required: true,
    },
});
</script>

<style scoped>
.page-header__title {
    color: var(--color-text-heading, #171d16);
}
</style>
