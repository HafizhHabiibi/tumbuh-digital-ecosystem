import { defineStore } from "pinia";
import { ref, computed } from "vue";

import * as authService from "../services/authService";

export const useAuthStore = defineStore("auth", () => {
    const token = ref(localStorage.getItem("token") || null);

    const user = ref(JSON.parse(localStorage.getItem("user") || "null"));

    const isLoggedIn = computed(() => !!token.value);

    const role = computed(() => user.value?.role || null);

    const isKader = computed(() => role.value === "kader");

    const isPuskesmas = computed(() => role.value === "puskesmas");

    const profil = computed(() => user.value?.profil || null);

    const namaLengkap = computed(
        () => profil.value?.nama_lengkap || "Pengguna",
    );

    const setAuth = (data) => {
        token.value = data.token;
        user.value = data.user;

        localStorage.setItem("token", data.token);

        localStorage.setItem("user", JSON.stringify(data.user));
    };

    const clearAuth = () => {
        token.value = null;
        user.value = null;

        localStorage.removeItem("token");
        localStorage.removeItem("user");
    };

    const login = async (email, password) => {
        try {
            const res = await authService.login(email, password);

            setAuth(res.data);

            return res;
        } catch (error) {
            throw error.response?.data || error;
        }
    };

    const logout = () => {
        clearAuth();
    };

    return {
        token,
        user,

        isLoggedIn,
        role,
        isKader,
        isPuskesmas,

        profil,
        namaLengkap,

        login,
        logout,

        setAuth,
        clearAuth,
    };
});
