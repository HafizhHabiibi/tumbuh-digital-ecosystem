import { defineStore } from "pinia";
import { ref, computed } from "vue";
import api from "../services/api";

export const useAuthStore = defineStore("auth", () => {
    const token = ref(localStorage.getItem("token") || null);
    const user = ref(JSON.parse(localStorage.getItem("user") || "null"));

    const isLoggedIn = computed(() => !!token.value);
    const role = computed(() => user.value?.role || null);
    const isKader = computed(() => role.value === "kader");
    const isPuskesmas = computed(() => role.value === "puskesmas");

    const login = async (email, password) => {
        const res = await api.post("/auth/login", { email, password });
        const data = res.data.data;

        token.value = data.token;
        user.value = data.user;

        localStorage.setItem("token", data.token);
        localStorage.setItem("user", JSON.stringify(data.user));

        return data;
    };

    const logout = () => {
        token.value = null;
        user.value = null;
        localStorage.removeItem("token");
        localStorage.removeItem("user");
    };

    return {
        token,
        user,
        isLoggedIn,
        role,
        isKader,
        isPuskesmas,
        login,
        logout,
    };
});
