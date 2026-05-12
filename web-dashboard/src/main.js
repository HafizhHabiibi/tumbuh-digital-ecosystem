import { createApp } from "vue";
import App from "./App.vue";

import router from "./router";

import { createPinia } from "pinia";

import PrimeVue from "primevue/config";
import Aura from "@primeuix/themes/aura";

import VueApexCharts from "vue3-apexcharts";

import "primeicons/primeicons.css";
import "./style.css";

const app = createApp(App);

app.use(router);
app.use(createPinia());

app.use(PrimeVue, {
    theme: {
        preset: Aura,
    },
});

app.use(VueApexCharts);

app.mount("#app");
