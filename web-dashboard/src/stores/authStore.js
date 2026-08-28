// src/stores/authStore.js
import { defineStore } from "pinia";
import { ref, computed } from "vue";
import * as authService from "../services/authService";

export const useAuthStore = defineStore("auth", () => {
    // ========== STATE ==========
    const token = ref(localStorage.getItem("token") || null);
    const parseStoredUser = () => {
        try {
            return JSON.parse(localStorage.getItem("user") || "null");
        } catch {
            localStorage.removeItem("user");
            localStorage.removeItem("token");
            return null;
        }
    };
    const user = ref(parseStoredUser());

    // Loading & error per aksi
    const loading = ref({
        login: false,
        forgotPassword: false,
        resetPassword: false,
        changePassword: false,
        profile: false,
    });

    const error = ref({
        login: null,
        forgotPassword: null,
        resetPassword: null,
        changePassword: null,
        profile: null,
    });

    // ========== COMPUTED ==========
    const isLoggedIn = computed(() => !!token.value && !!user.value);
    const role = computed(() => user.value?.role || null);
    const isKader = computed(() => role.value === "kader");
    const isPuskesmas = computed(() => role.value === "puskesmas");
    const profil = computed(() => user.value?.profil || null);
    const namaLengkap = computed(
        () => profil.value?.nama_lengkap || "Pengguna",
    );

    // ========== HELPERS ==========
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

    // ========== ACTIONS ==========

    const login = async (email, password, turnstileToken) => {
        loading.value.login = true;
        error.value.login = null;
        try {
            const res = await authService.login(
                email,
                password,
                turnstileToken,
            );
            setAuth(res.data);
            return true;
        } catch (err) {
            error.value.login = err.response?.data?.message || "Login gagal";
            return false;
        } finally {
            loading.value.login = false;
        }
    };

    const logout = () => {
        clearAuth();
    };

    const forgotPassword = async (email, turnstileToken) => {
        loading.value.forgotPassword = true;
        error.value.forgotPassword = null;
        try {
            await authService.forgotPassword(email, turnstileToken);
            return true;
        } catch (err) {
            error.value.forgotPassword =
                err.response?.data?.message || "Gagal mengirim email reset";
            return false;
        } finally {
            loading.value.forgotPassword = false;
        }
    };

    const resetPassword = async (token, password_baru) => {
        loading.value.resetPassword = true;
        error.value.resetPassword = null;
        try {
            await authService.resetPassword(token, password_baru);
            return true;
        } catch (err) {
            error.value.resetPassword =
                err.response?.data?.message || "Gagal reset password";
            return false;
        } finally {
            loading.value.resetPassword = false;
        }
    };

    const changePassword = async (password_lama, password_baru) => {
        loading.value.changePassword = true;
        error.value.changePassword = null;
        try {
            await authService.changePassword(password_lama, password_baru);
            return true;
        } catch (err) {
            error.value.changePassword =
                err.response?.data?.message || "Gagal mengganti password";
            return false;
        } finally {
            loading.value.changePassword = false;
        }
    };

    const refreshProfile = async () => {
        if (!role.value || !["kader", "puskesmas"].includes(role.value)) {
            return false;
        }

        loading.value.profile = true;
        error.value.profile = null;
        try {
            const res = await authService.getProfile(role.value);
            user.value = { ...user.value, profil: res.data };
            localStorage.setItem("user", JSON.stringify(user.value));
            return true;
        } catch (err) {
            error.value.profile =
                err.response?.data?.message || "Gagal memuat profil";
            return false;
        } finally {
            loading.value.profile = false;
        }
    };

    return {
        // State
        token,
        user,
        loading,
        error,

        // Computed
        isLoggedIn,
        role,
        isKader,
        isPuskesmas,
        profil,
        namaLengkap,

        // Actions
        login,
        logout,
        forgotPassword,
        resetPassword,
        changePassword,
        refreshProfile,

        // Helpers
        setAuth,
        clearAuth,
    };
});
