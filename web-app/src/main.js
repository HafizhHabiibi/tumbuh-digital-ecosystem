// src/main.js
import { createApp } from "vue";
import { createPinia } from "pinia";
import PrimeVue from "primevue/config";
import Aura from "@primeuix/themes/aura";
import VueApexCharts from "vue3-apexcharts";

import router from "./router/index.js";
import App from "./App.vue";
import "./assets/main.css";
import "primeicons/primeicons.css";

const app = createApp(App);
const pinia = createPinia();

app.use(pinia);
app.use(router);
app.use(PrimeVue, {
    theme: {
        preset: Aura,
        options: {
            primaryColor: "green",
        },
    },
});
app.component("ApexChart", VueApexCharts);

app.mount("#app");
