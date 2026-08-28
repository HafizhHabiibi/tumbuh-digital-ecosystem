// src/stores/jadwalStore.js
import { defineStore } from "pinia";
import jadwalService from "@/services/jadwalService";
import {
    createPagination,
    extractPaginatedData,
} from "@/utils/apiResponse";

export const useJadwalStore = defineStore("jadwal", {
    // ========== STATE ==========
    state: () => ({
        // List semua jadwal
        jadwalList: [],
        pagination: createPagination(),

        // Detail jadwal yang sedang dilihat
        jadwalDetail: null,
        pengaturan: null,
        generateResult: null,

        // Loading state per aksi
        loading: {
            fetchAll: false,
            fetchDetail: false,
            create: false,
            update: false,
            delete: false,
            pengaturan: false,
            generate: false,
        },

        // Error state per aksi
        error: {
            fetchAll: null,
            fetchDetail: null,
            create: null,
            update: null,
            delete: null,
            pengaturan: null,
            generate: null,
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
            const now = new Date();
            const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
            return state.jadwalList
                .filter((j) => j.tanggal >= today)
                .sort((a, b) => a.tanggal.localeCompare(b.tanggal));
        },

        /**
         * Jadwal yang sudah lewat
         */
        jadwalLewat: (state) => {
            const now = new Date();
            const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
            return state.jadwalList
                .filter((j) => j.tanggal < today)
                .sort((a, b) => b.tanggal.localeCompare(a.tanggal)); // desc
        },

        /**
         * Jadwal terdekat (paling pertama dari jadwal mendatang)
         */
        jadwalTerdekat: (state) => {
            const now = new Date();
            const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
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
        async fetchAllJadwal(params = {}) {
            this.loading.fetchAll = true;
            this.error.fetchAll = null;
            try {
                const page = params.page ?? this.pagination.page;
                const limit = params.limit ?? this.pagination.limit;
                const res = await jadwalService.getAllJadwal({ page, limit });
                const data = extractPaginatedData(res);
                this.jadwalList = data.items;
                this.pagination = data.pagination;
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
                await this.fetchAllJadwal({
                    page: this.pagination.page,
                    limit: this.pagination.limit,
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

        async updateJadwal(id, payload) {
            this.loading.update = true;
            this.error.update = null;
            try {
                await jadwalService.updateJadwal(id, payload);
                await this.fetchAllJadwal({
                    page: this.pagination.page,
                    limit: this.pagination.limit,
                });
                return true;
            } catch (err) {
                this.error.update = err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.update = false;
            }
        },

        async deleteJadwal(id) {
            this.loading.delete = true;
            this.error.delete = null;
            try {
                await jadwalService.deleteJadwal(id);
                const targetPage =
                    this.jadwalList.length === 1 && this.pagination.page > 1
                        ? this.pagination.page - 1
                        : this.pagination.page;
                await this.fetchAllJadwal({
                    page: targetPage,
                    limit: this.pagination.limit,
                });
                return true;
            } catch (err) {
                this.error.delete = err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.delete = false;
            }
        },

        async fetchPengaturan() {
            this.loading.pengaturan = true;
            this.error.pengaturan = null;
            try {
                const res = await jadwalService.getPengaturan();
                this.pengaturan = res.data.data;
                return true;
            } catch (err) {
                this.error.pengaturan =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.pengaturan = false;
            }
        },

        async savePengaturan(payload) {
            this.loading.pengaturan = true;
            this.error.pengaturan = null;
            try {
                const res = await jadwalService.setPengaturan(payload);
                this.pengaturan = res.data.data;
                return true;
            } catch (err) {
                this.error.pengaturan =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.pengaturan = false;
            }
        },

        async generateJadwal(jumlahBulan = 6) {
            this.loading.generate = true;
            this.error.generate = null;
            this.generateResult = null;
            try {
                const res = await jadwalService.generateJadwal(jumlahBulan);
                this.generateResult = res.data.data;
                await this.fetchAllJadwal({
                    page: 1,
                    limit: this.pagination.limit,
                });
                return true;
            } catch (err) {
                this.error.generate =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.generate = false;
            }
        },

        /**
         * Reset error & result (dipanggil saat modal form ditutup)
         */
        resetCreateState() {
            this.error.create = null;
            this.createResult = null;
        },

        resetMutationErrors() {
            this.error.update = null;
            this.error.delete = null;
            this.error.generate = null;
        },
    },
});
