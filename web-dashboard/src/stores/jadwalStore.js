// src/stores/jadwalStore.js
import { defineStore } from "pinia";
import jadwalService from "@/services/jadwalService";

export const useJadwalStore = defineStore("jadwal", {
    // ========== STATE ==========
    state: () => ({
        // List semua jadwal
        jadwalList: [],

        // Detail jadwal yang sedang dilihat
        jadwalDetail: null,

        // Loading state per aksi
        loading: {
            fetchAll: false,
            fetchDetail: false,
            create: false,
        },

        // Error state per aksi
        error: {
            fetchAll: null,
            fetchDetail: null,
            create: null,
        },

        // Hasil create (untuk menampilkan info notifikasi)
        createResult: null,
    }),

    // ========== GETTERS ==========
    getters: {
        /**
         * Jadwal yang akan datang (tanggal >= hari ini)
         */
        jadwalMendatang: (state) => {
            const today = new Date().toISOString().split("T")[0]; // YYYY-MM-DD
            return state.jadwalList
                .filter((j) => j.tanggal >= today)
                .sort((a, b) => a.tanggal.localeCompare(b.tanggal));
        },

        /**
         * Jadwal yang sudah lewat
         */
        jadwalLewat: (state) => {
            const today = new Date().toISOString().split("T")[0];
            return state.jadwalList
                .filter((j) => j.tanggal < today)
                .sort((a, b) => b.tanggal.localeCompare(a.tanggal)); // desc
        },

        /**
         * Jadwal terdekat (paling pertama dari jadwal mendatang)
         */
        jadwalTerdekat: (state) => {
            const today = new Date().toISOString().split("T")[0];
            return (
                state.jadwalList
                    .filter((j) => j.tanggal >= today)
                    .sort((a, b) => a.tanggal.localeCompare(b.tanggal))[0] ||
                null
            );
        },
    },

    // ========== ACTIONS ==========
    actions: {
        /**
         * Ambil semua jadwal
         */
        async fetchAllJadwal() {
            this.loading.fetchAll = true;
            this.error.fetchAll = null;
            try {
                const res = await jadwalService.getAllJadwal();
                this.jadwalList = res.data.data;
            } catch (err) {
                this.error.fetchAll =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.fetchAll = false;
            }
        },

        /**
         * Ambil detail jadwal berdasarkan ID
         * @param {number} id
         */
        async fetchDetailJadwal(id) {
            this.loading.fetchDetail = true;
            this.error.fetchDetail = null;
            this.jadwalDetail = null; // reset dulu biar tidak tampil data lama
            try {
                const res = await jadwalService.getDetailJadwal(id);
                this.jadwalDetail = res.data.data;
            } catch (err) {
                this.error.fetchDetail =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.fetchDetail = false;
            }
        },

        /**
         * Buat jadwal baru (khusus role kader)
         * @param {Object} payload - { tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan }
         * @returns {boolean} true jika berhasil
         */
        async createJadwal(payload) {
            this.loading.create = true;
            this.error.create = null;
            this.createResult = null;
            try {
                const res = await jadwalService.createJadwal(payload);
                this.createResult = res.data.data;
                // Langsung tambah ke list tanpa fetch ulang
                this.jadwalList.push({
                    id: res.data.data.id,
                    tanggal: payload.tanggal,
                    waktu_mulai: payload.waktu_mulai,
                    waktu_selesai: payload.waktu_selesai,
                    lokasi: payload.lokasi,
                    keterangan: payload.keterangan || null,
                });
                return true;
            } catch (err) {
                // Tangkap pesan error dari backend (misal: jadwal sudah ada / 409)
                this.error.create = err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.create = false;
            }
        },

        /**
         * Reset error & result (dipanggil saat modal form ditutup)
         */
        resetCreateState() {
            this.error.create = null;
            this.createResult = null;
        },
    },
});
