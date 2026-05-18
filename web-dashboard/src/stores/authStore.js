// src/stores/authStore.js
import { defineStore } from "pinia";
import { ref, computed } from "vue";
import * as authService from "../services/authService";

export const useAuthStore = defineStore("auth", () => {
    // ========== STATE ==========
    const token = ref(localStorage.getItem("token") || null);
    const user = ref(JSON.parse(localStorage.getItem("user") || "null"));

    // Loading & error per aksi
    const loading = ref({
        login: false,
        forgotPassword: false,
        resetPassword: false,
        changePassword: false,
    });

    const error = ref({
        login: null,
        forgotPassword: null,
        resetPassword: null,
        changePassword: null,
    });

    // ========== COMPUTED ==========
    const isLoggedIn = computed(() => !!token.value);
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

    /**
     * Login dengan email, password, dan token Turnstile
     * @param {string} email
     * @param {string} password
     * @param {string} turnstileToken — token dari widget Cloudflare Turnstile
     * @returns {boolean}
     */
    const login = async (email, password, turnstileToken) => {
        // [DIUBAH] tambah turnstileToken
        loading.value.login = true;
        error.value.login = null;
        try {
            const res = await authService.login(
                email,
                password,
                turnstileToken,
            ); // [DIUBAH]
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

    /**
     * Kirim email reset password
     * @param {string} email
     * @param {string} turnstileToken — token dari widget Cloudflare Turnstile
     * @returns {boolean}
     */
    const forgotPassword = async (email, turnstileToken) => {
        // [DIUBAH] tambah turnstileToken
        loading.value.forgotPassword = true;
        error.value.forgotPassword = null;
        try {
            await authService.forgotPassword(email, turnstileToken); // [DIUBAH]
            return true;
        } catch (err) {
            error.value.forgotPassword =
                err.response?.data?.message || "Gagal mengirim email reset";
            return false;
        } finally {
            loading.value.forgotPassword = false;
        }
    };

    /**
     * Reset password dengan token dari email
     * @param {string} token
     * @param {string} password_baru
     * @returns {boolean}
     */
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

    /**
     * Ganti password dari halaman profil (user sudah login)
     * @param {string} password_lama
     * @param {string} password_baru
     * @returns {boolean}
     */
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

        // Helpers (dipakai jika perlu set auth manual, misal refresh token)
        setAuth,
        clearAuth,
    };
});
