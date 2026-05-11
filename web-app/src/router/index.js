// src/router/index.js
import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../stores/auth.js";

const routes = [
    // Auth
    {
        path: "/login",
        name: "Login",
        component: () => import("../views/auth/LoginView.vue"),
        meta: { requiresGuest: true },
    },
    {
        path: "/forgot-password",
        name: "ForgotPassword",
        component: () => import("../views/auth/ForgotPasswordView.vue"),
        meta: { requiresGuest: true },
    },
    {
        path: "/reset-password",
        name: "ResetPassword",
        component: () => import("../views/auth/ResetPasswordView.vue"),
        meta: { requiresGuest: true },
    },

    // Kader
    {
        path: "/kader",
        meta: { requiresAuth: true, role: "kader" },
        component: () => import("../views/kader/KaderLayout.vue"),
        children: [
            {
                path: "dashboard",
                name: "KaderDashboard",
                component: () => import("../views/kader/DashboardView.vue"),
            },
            {
                path: "orang-tua",
                name: "KaderOrangTua",
                component: () => import("../views/kader/OrangTuaView.vue"),
            },
            {
                path: "anak",
                name: "KaderAnak",
                component: () => import("../views/kader/AnakView.vue"),
            },
            {
                path: "anak/:id",
                name: "KaderDetailAnak",
                component: () => import("../views/kader/DetailAnakView.vue"),
            },
            {
                path: "pengukuran",
                name: "KaderPengukuran",
                component: () => import("../views/kader/PengukuranView.vue"),
            },
            {
                path: "pemberian",
                name: "KaderPemberian",
                component: () =>
                    import("../views/kader/RiwayatPemberianView.vue"),
            },
            {
                path: "rujukan",
                name: "KaderRujukan",
                component: () => import("../views/kader/RujukanView.vue"),
            },
            {
                path: "jadwal",
                name: "KaderJadwal",
                component: () => import("../views/kader/JadwalView.vue"),
            },
            {
                path: "profil",
                name: "KaderProfil",
                component: () => import("../views/kader/ProfilView.vue"),
            },
        ],
    },

    // Puskesmas
    {
        path: "/puskesmas",
        meta: { requiresAuth: true, role: "puskesmas" },
        component: () => import("../views/puskesmas/PuskesmasLayout.vue"),
        children: [
            {
                path: "dashboard",
                name: "PuskesmasDashboard",
                component: () => import("../views/puskesmas/DashboardView.vue"),
            },
            {
                path: "rujukan",
                name: "PuskesmasRujukan",
                component: () => import("../views/puskesmas/RujukanView.vue"),
            },
            {
                path: "profil",
                name: "PuskesmasProfil",
                component: () => import("../views/puskesmas/ProfilView.vue"),
            },
        ],
    },

    // Redirect default
    {
        path: "/",
        redirect: "/login",
    },
    {
        path: "/:pathMatch(.*)*",
        redirect: "/login",
    },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

// Navigation guard
router.beforeEach((to, from, next) => {
    const auth = useAuthStore();

    // Halaman yang butuh login
    if (to.meta.requiresAuth && !auth.isLoggedIn) {
        return next("/login");
    }

    // Halaman yang hanya untuk guest (belum login)
    if (to.meta.requiresGuest && auth.isLoggedIn) {
        if (auth.isKader) return next("/kader/dashboard");
        if (auth.isPuskesmas) return next("/puskesmas/dashboard");
    }

    // Cek role
    if (to.meta.role && auth.role !== to.meta.role) {
        if (auth.isKader) return next("/kader/dashboard");
        if (auth.isPuskesmas) return next("/puskesmas/dashboard");
        return next("/login");
    }

    next();
});

export default router;
