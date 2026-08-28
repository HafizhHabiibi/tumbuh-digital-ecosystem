import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

export default defineConfig({
    plugins: [vue(), tailwindcss()],
    resolve: {
        alias: {
            "@": path.resolve(import.meta.dirname, "./src"),
        },
    },
    optimizeDeps: {
        include: [
            "apexcharts/core",
            "apexcharts/line",
            "apexcharts/bar",
            "apexcharts/donut",
            "apexcharts/features/legend",
        ],
    },
});
