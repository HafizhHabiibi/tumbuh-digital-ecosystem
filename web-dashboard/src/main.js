import { createApp } from "vue";
import { createPinia } from "pinia";

import PrimeVue from "primevue/config";
import Aura from "@primeuix/themes/aura";

import VueApexCharts from "vue3-apexcharts";
import ToastService from "primevue/toastservice";

import router from "./router";
import App from "./App.vue";

import "./assets/main.css";
import "primeicons/primeicons.css";

const app = createApp(App);

app.use(createPinia());

app.use(router);

app.use(PrimeVue, {
    ripple: true,
    theme: {
        preset: Aura,
    },
});

app.use(ToastService);

app.component("apexchart", VueApexCharts);

app.mount("#app");
