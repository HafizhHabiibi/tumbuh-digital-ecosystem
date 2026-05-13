// src/stores/rujukanStore.js
import { defineStore } from "pinia";
import rujukanService from "@/services/rujukanService";

/**
 * Konstanta status, duplikasi dari backend
 * Dipakai untuk validasi form + render label/warna UI
 */
export const STATUS_VALID = [
    "diterima",
    "dalam_penanganan",
    "selesai",
    "ditolak",
];

export const LABEL_STATUS = {
    diajukan: "Diajukan",
    diterima: "Diterima",
    dalam_penanganan: "Dalam Penanganan",
    selesai: "Selesai",
    ditolak: "Ditolak",
};

export const WARNA_STATUS = {
    diajukan: "blue",
    diterima: "green",
    dalam_penanganan: "yellow",
    selesai: "gray",
    ditolak: "red",
};

export const useRujukanStore = defineStore("rujukan", {
    // ========== STATE ==========
    state: () => ({
        // Semua rujukan (dipakai halaman puskesmas)
        rujukanList: [],

        // Detail satu rujukan
        rujukanDetail: null,

        // Riwayat rujukan per anak + info anak (dipakai kader)
        riwayatAnak: {
            anak: null,
            list: [],
        },

        // Hasil create rujukan
        createResult: null,

        // Hasil update status
        updateResult: null,

        loading: {
            create: false,
            fetchAll: false,
            fetchDetail: false,
            fetchByAnak: false,
            updateStatus: false,
        },

        error: {
            create: null,
            fetchAll: null,
            fetchDetail: null,
            fetchByAnak: null,
            updateStatus: null,
        },
    }),

    // ========== GETTERS ==========
    getters: {
        /**
         * Filter rujukan aktif (belum selesai/ditolak)
         * Dipakai puskesmas untuk lihat antrian masuk
         */
        rujukanAktif: (state) => {
            return state.rujukanList.filter(
                (r) => r.status !== "selesai" && r.status !== "ditolak",
            );
        },

        /**
         * Filter rujukan selesai/ditolak (arsip)
         */
        rujukanArsip: (state) => {
            return state.rujukanList.filter(
                (r) => r.status === "selesai" || r.status === "ditolak",
            );
        },

        /**
         * Hitung jumlah per status (untuk badge/summary puskesmas)
         * { diajukan: 2, diterima: 1, dalam_penanganan: 3, selesai: 10, ditolak: 1 }
         */
        jumlahPerStatus: (state) => {
            const semua = ["diajukan", ...STATUS_VALID];
            return semua.reduce((acc, status) => {
                acc[status] = state.rujukanList.filter(
                    (r) => r.status === status,
                ).length;
                return acc;
            }, {});
        },

        /**
         * Cek apakah anak masih punya rujukan aktif
         * Dipakai kader sebelum bisa ajukan rujukan baru
         */
        punyaRujukanAktif: (state) => {
            return state.riwayatAnak.list.some(
                (r) => r.status !== "selesai" && r.status !== "ditolak",
            );
        },

        /**
         * Status bisa di-update atau tidak
         * Backend tolak jika sudah 'selesai' atau 'ditolak'
         */
        bisaDiupdate: () => (status) => {
            return status !== "selesai" && status !== "ditolak";
        },
    },

    // ========== ACTIONS ==========
    actions: {
        // --------------------------------------------------
        // KADER: Ajukan rujukan baru
        // --------------------------------------------------
        /**
         * @param {Object} payload - { anak_id, saw_result_id, catatan_kader }
         * @returns {boolean}
         */
        async createRujukan(payload) {
            this.loading.create = true;
            this.error.create = null;
            this.createResult = null;
            try {
                const res = await rujukanService.createRujukan(payload);
                this.createResult = res.data.data;

                // Tambahkan ke riwayat anak jika sedang ditampilkan
                if (
                    this.riwayatAnak.anak &&
                    this.riwayatAnak.anak.id === payload.anak_id
                ) {
                    this.riwayatAnak.list.unshift(res.data.data);
                }

                return true;
            } catch (err) {
                this.error.create = err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.create = false;
            }
        },

        // --------------------------------------------------
        // PUSKESMAS: Ambil semua rujukan
        // --------------------------------------------------
        async fetchAllRujukan() {
            this.loading.fetchAll = true;
            this.error.fetchAll = null;
            try {
                const res = await rujukanService.getAllRujukan();
                this.rujukanList = res.data.data;
            } catch (err) {
                this.error.fetchAll =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.fetchAll = false;
            }
        },

        // --------------------------------------------------
        // KADER & PUSKESMAS: Detail rujukan
        // --------------------------------------------------
        async fetchDetailRujukan(id) {
            this.loading.fetchDetail = true;
            this.error.fetchDetail = null;
            this.rujukanDetail = null;
            try {
                const res = await rujukanService.getDetailRujukan(id);
                this.rujukanDetail = res.data.data;
            } catch (err) {
                this.error.fetchDetail =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.fetchDetail = false;
            }
        },

        // --------------------------------------------------
        // PUSKESMAS: Update status rujukan
        // --------------------------------------------------
        /**
         * @param {number} id
         * @param {Object} payload - { status, catatan_puskesmas? }
         * @returns {boolean}
         */
        async updateStatusRujukan(id, payload) {
            this.loading.updateStatus = true;
            this.error.updateStatus = null;
            this.updateResult = null;
            try {
                const res = await rujukanService.updateStatusRujukan(
                    id,
                    payload,
                );
                this.updateResult = res.data.data;

                // Update status di list tanpa fetch ulang
                const idx = this.rujukanList.findIndex((r) => r.id === id);
                if (idx !== -1) {
                    this.rujukanList[idx] = {
                        ...this.rujukanList[idx],
                        status: payload.status,
                        catatan_puskesmas: payload.catatan_puskesmas || null,
                    };
                }

                // Update juga di detail jika sedang dibuka
                if (this.rujukanDetail?.id === id) {
                    this.rujukanDetail.status = payload.status;
                    this.rujukanDetail.catatan_puskesmas =
                        payload.catatan_puskesmas || null;
                }

                return true;
            } catch (err) {
                this.error.updateStatus =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.updateStatus = false;
            }
        },

        // --------------------------------------------------
        // KADER: Riwayat rujukan per anak
        // --------------------------------------------------
        async fetchRujukanByAnak(anakId) {
            this.loading.fetchByAnak = true;
            this.error.fetchByAnak = null;
            try {
                const res = await rujukanService.getRujukanByAnak(anakId);
                this.riwayatAnak.anak = res.data.data.anak;
                this.riwayatAnak.list = res.data.data.rujukan;
            } catch (err) {
                this.error.fetchByAnak =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.fetchByAnak = false;
            }
        },

        resetCreateState() {
            this.createResult = null;
            this.error.create = null;
        },

        resetRiwayatAnak() {
            this.riwayatAnak = { anak: null, list: [] };
        },
    },
});
