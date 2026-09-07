import { createApp, defineAsyncComponent } from "vue";
import { createPinia } from "pinia";

import PrimeVue from "primevue/config";
import Aura from "@primeuix/themes/aura";

import ToastService from "primevue/toastservice";

import router from "./router";
import App from "./App.vue";

import "./assets/main.css";
import "primeicons/primeicons.css";

import "@fontsource/poppins/400.css";
import "@fontsource/poppins/500.css";
import "@fontsource/poppins/600.css";
import "@fontsource/poppins/700.css";

const app = createApp(App);

app.use(createPinia());

app.use(router);

app.use(PrimeVue, {
    ripple: true,
    theme: {
        preset: Aura,
        options: {
            darkModeSelector: false,
            cssLayer: false,
        },
    },
    pt: {
        datepicker: {
            pcInputText: {
                root: {
                    class: "input-field w-full pl-9 pr-4 py-2.5 rounded-xl text-sm",
                },
            },
        },
    },
});

app.use(ToastService);

app.component(
    "apexchart",
    defineAsyncComponent(async () => {
        await Promise.all([
            import("apexcharts/line"),
            import("apexcharts/bar"),
            import("apexcharts/donut"),
            import("apexcharts/features/legend"),
        ]);
        const module = await import("vue3-apexcharts/core");
        return module.default;
    }),
);

app.mount("#app");
