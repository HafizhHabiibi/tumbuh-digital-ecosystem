import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../stores/authStore.js";

const routes = [
    // ── Auth ────────────────────────────────
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

    // ── Kader ───────────────────────────────
    {
        path: "/kader",
        redirect: "/kader/dashboard",
        component: () => import("../components/layout/AppLayout.vue"),
        meta: { requiresAuth: true, role: "kader" },
        children: [
            {
                path: "dashboard",
                name: "KaderDashboard",
                component: () => import("../views/kader/DashboardView.vue"),
            },
            {
                path: "prioritas",
                name: "KaderRanking",
                component: () => import("../views/kader/RankingView.vue"),
            },
            {
                path: "orang-tua",
                name: "KaderOrangTua",
                component: () => import("../views/kader/OrangTuaView.vue"),
            },
            {
                path: "orang-tua/:id",
                name: "KaderDetailOrangTua",
                component: () =>
                    import("../views/kader/DetailOrangTuaView.vue"),
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
                    import("../views/kader/PemberianView.vue"),
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

    // ── Puskesmas ───────────────────────────
    {
        path: "/puskesmas",
        redirect: "/puskesmas/dashboard",
        component: () => import("../components/layout/AppLayout.vue"),
        meta: { requiresAuth: true, role: "puskesmas" },
        children: [
            {
                path: "dashboard",
                name: "PuskesmasDashboard",
                component: () => import("../views/puskesmas/DashboardView.vue"),
            },
            {
                path: "prioritas",
                name: "PuskesmasRanking",
                component: () => import("../views/puskesmas/RankingView.vue"),
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

    // ── Redirect ────────────────────────────
    { path: "/", redirect: "/login" },
    { path: "/:pathMatch(.*)*", redirect: "/login" },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach((to, from, next) => {
    const auth = useAuthStore();

    if (to.meta.requiresAuth && !auth.isLoggedIn) {
        return next("/login");
    }

    if (to.meta.requiresGuest && auth.isLoggedIn) {
        return next(auth.isKader ? "/kader/dashboard" : "/puskesmas/dashboard");
    }

    if (to.meta.role && auth.role !== to.meta.role) {
        return next(auth.isKader ? "/kader/dashboard" : "/puskesmas/dashboard");
    }

    next();
});

export default router;
