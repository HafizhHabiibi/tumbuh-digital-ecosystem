// src/stores/kaderStore.js
import { defineStore } from "pinia";
import kaderService from "@/services/kaderService";

export const useKaderStore = defineStore("kader", {
    // ========== STATE ==========
    state: () => ({
        // Profil kader yang sedang login
        profil: null,

        // ==================
        // ORANG TUA
        // ==================
        orangTuaList: [],
        orangTuaDetail: null,
        createOrangTuaResult: null,

        // ==================
        // ANAK
        // ==================
        anakList: [], // semua anak (halaman daftar anak)
        anakDetail: null, // detail satu anak

        // Anak milik satu orang tua + info orang tuanya
        anakByOrangTua: {
            orang_tua: null,
            anak: [],
        },

        createAnakResult: null,

        // ==================
        // LOADING & ERROR
        // ==================
        loading: {
            profil: false,
            orangTuaList: false,
            orangTuaDetail: false,
            createOrangTua: false,
            anakList: false,
            anakDetail: false,
            anakByOrangTua: false,
            createAnak: false,
        },

        error: {
            profil: null,
            orangTuaList: null,
            orangTuaDetail: null,
            createOrangTua: null,
            anakList: null,
            anakDetail: null,
            anakByOrangTua: null,
            createAnak: null,
        },
    }),

    // ========== GETTERS ==========
    getters: {
        /**
         * Cari orang tua di list berdasarkan id
         * Berguna untuk tampilkan nama orang tua di tabel anak
         */
        orangTuaById: (state) => (id) => {
            return state.orangTuaList.find((ot) => ot.id === id) || null;
        },

        /**
         * Total anak yang terdaftar
         */
        totalAnak: (state) => state.anakList.length,

        /**
         * Total orang tua yang terdaftar
         */
        totalOrangTua: (state) => state.orangTuaList.length,

        /**
         * Filter anak berdasarkan jenis kelamin
         */
        anakLaki: (state) =>
            state.anakList.filter((a) => a.jenis_kelamin === "L"),
        anakPerempuan: (state) =>
            state.anakList.filter((a) => a.jenis_kelamin === "P"),
    },

    // ========== ACTIONS ==========
    actions: {
        // --------------------------------------------------
        // PROFIL
        // --------------------------------------------------
        async fetchProfil() {
            this.loading.profil = true;
            this.error.profil = null;
            try {
                const res = await kaderService.getProfil();
                this.profil = res.data.data;
            } catch (err) {
                this.error.profil = err.response?.data?.message || err.message;
            } finally {
                this.loading.profil = false;
            }
        },

        // --------------------------------------------------
        // ORANG TUA
        // --------------------------------------------------
        async fetchAllOrangTua() {
            this.loading.orangTuaList = true;
            this.error.orangTuaList = null;
            try {
                const res = await kaderService.getAllOrangTua();
                this.orangTuaList = res.data.data;
            } catch (err) {
                this.error.orangTuaList =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.orangTuaList = false;
            }
        },

        async fetchOrangTuaById(id) {
            this.loading.orangTuaDetail = true;
            this.error.orangTuaDetail = null;
            this.orangTuaDetail = null;
            try {
                const res = await kaderService.getOrangTuaById(id);
                this.orangTuaDetail = res.data.data;
            } catch (err) {
                this.error.orangTuaDetail =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.orangTuaDetail = false;
            }
        },

        /**
         * Daftarkan orang tua baru sekaligus buatkan akun loginnya
         * @param {Object} payload
         * @returns {boolean}
         */
        async createOrangTua(payload) {
            this.loading.createOrangTua = true;
            this.error.createOrangTua = null;
            this.createOrangTuaResult = null;
            try {
                const res = await kaderService.createOrangTua(payload);
                this.createOrangTuaResult = res.data.data;

                // Tambah ke list tanpa fetch ulang
                this.orangTuaList.unshift(res.data.data);
                return true;
            } catch (err) {
                this.error.createOrangTua =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.createOrangTua = false;
            }
        },

        // --------------------------------------------------
        // ANAK
        // --------------------------------------------------
        async fetchAllAnak() {
            this.loading.anakList = true;
            this.error.anakList = null;
            try {
                const res = await kaderService.getAllAnak();
                this.anakList = res.data.data;
            } catch (err) {
                this.error.anakList =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.anakList = false;
            }
        },

        async fetchAnakById(id) {
            this.loading.anakDetail = true;
            this.error.anakDetail = null;
            this.anakDetail = null;
            try {
                const res = await kaderService.getAnakById(id);
                this.anakDetail = res.data.data;
            } catch (err) {
                this.error.anakDetail =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.anakDetail = false;
            }
        },

        /**
         * Ambil anak berdasarkan orang tua
         * Dipanggil di halaman detail orang tua
         * @param {number} orangTuaId
         */
        async fetchAnakByOrangTua(orangTuaId) {
            this.loading.anakByOrangTua = true;
            this.error.anakByOrangTua = null;
            try {
                const res = await kaderService.getAnakByOrangTua(orangTuaId);
                this.anakByOrangTua.orang_tua = res.data.data.orang_tua;
                this.anakByOrangTua.anak = res.data.data.anak;
            } catch (err) {
                this.error.anakByOrangTua =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.anakByOrangTua = false;
            }
        },

        /**
         * Tambah data anak baru
         * @param {Object} payload
         * @returns {boolean}
         */
        async createAnak(payload) {
            this.loading.createAnak = true;
            this.error.createAnak = null;
            this.createAnakResult = null;
            try {
                const res = await kaderService.createAnak(payload);
                this.createAnakResult = res.data.data;

                // Tambah ke anakList
                this.anakList.unshift(res.data.data);

                // Tambah ke anakByOrangTua jika orang tua yang sama sedang ditampilkan
                if (
                    this.anakByOrangTua.orang_tua?.id === payload.orang_tua_id
                ) {
                    this.anakByOrangTua.anak.unshift(res.data.data);
                }

                return true;
            } catch (err) {
                this.error.createAnak =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.createAnak = false;
            }
        },

        // --------------------------------------------------
        // RESET
        // --------------------------------------------------
        resetCreateOrangTua() {
            this.createOrangTuaResult = null;
            this.error.createOrangTua = null;
        },

        resetCreateAnak() {
            this.createAnakResult = null;
            this.error.createAnak = null;
        },

        resetAnakByOrangTua() {
            this.anakByOrangTua = { orang_tua: null, anak: [] };
        },
    },
});
