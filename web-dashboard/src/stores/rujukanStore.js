// src/stores/rujukanStore.js
import { defineStore } from "pinia";
import rujukanService from "@/services/rujukanService";
import {
    createPagination,
    extractPaginatedData,
} from "@/utils/apiResponse";

/**
 * Konstanta status, duplikasi dari backend
 * Dipakai untuk validasi form + render label/warna UI
 */
export const STATUS_VALID = ["ditangani", "selesai"];

export const LABEL_STATUS = {
    diajukan: "Diajukan",
    ditangani: "Ditangani",
    selesai: "Selesai",
};

export const WARNA_STATUS = {
    diajukan: "blue",
    ditangani: "yellow",
    selesai: "gray",
};

export const useRujukanStore = defineStore("rujukan", {
    // ========== STATE ==========
    state: () => ({
        // Semua rujukan (dipakai halaman puskesmas)
        rujukanList: [],
        pagination: createPagination(),
        summary: { diajukan: 0, ditangani: 0, selesai: 0 },
        listRequestId: 0,
        detailRequestId: 0,
        riwayatRequestId: 0,

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
         * Filter rujukan aktif (belum selesai)
         * Dipakai puskesmas untuk lihat antrian masuk
         */
        rujukanAktif: (state) => {
            return state.rujukanList.filter((r) => r.status !== "selesai");
        },

        /**
         * Filter rujukan selesai (arsip)
         */
        rujukanArsip: (state) => {
            return state.rujukanList.filter((r) => r.status === "selesai");
        },

        /**
         * Hitung jumlah per status (untuk badge/summary puskesmas)
         * { diajukan: 2, ditangani: 3, selesai: 10 }
         */
        jumlahPerStatus: (state) => {
            return state.summary;
        },

        totalRujukanAktif: (state) =>
            state.summary.diajukan + state.summary.ditangani,

        totalRujukanArsip: (state) => state.summary.selesai,

        /**
         * Cek apakah anak masih punya rujukan aktif
         * Dipakai kader sebelum bisa ajukan rujukan baru
         */
        punyaRujukanAktif: (state) => {
            return state.riwayatAnak.list.some((r) => r.status !== "selesai");
        },

        /**
         * Status bisa di-update atau tidak
         * Backend menolak perubahan jika status sudah 'selesai'
         */
        bisaDiupdate: () => (status) => {
            return status !== "selesai";
        },
    },

    // ========== ACTIONS ==========
    actions: {
        // --------------------------------------------------
        // KADER: Ajukan rujukan baru
        // --------------------------------------------------
        /**
         * @param {Object} payload - { anak_id, pengukuran_id, catatan_kader }
         * @returns {boolean}
         */
        async createRujukan(payload) {
            this.loading.create = true;
            this.error.create = null;
            this.createResult = null;
            try {
                const res = await rujukanService.createRujukan(payload);
                this.createResult = res.data.data;

                // Ambil ulang agar baris baru memiliki tanggal dan data relasi
                // lengkap, bukan hanya response ringkas dari endpoint create.
                if (
                    this.riwayatAnak.anak &&
                    String(this.riwayatAnak.anak.id) === String(payload.anak_id)
                ) {
                    await this.fetchRujukanByAnak(payload.anak_id);
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
        async fetchAllRujukan(params = {}) {
            const requestId = ++this.listRequestId;
            this.loading.fetchAll = true;
            this.error.fetchAll = null;
            try {
                const page = params.page ?? this.pagination.page;
                const limit = params.limit ?? this.pagination.limit;
                const res = await rujukanService.getAllRujukan({
                    ...params,
                    page,
                    limit,
                });
                if (requestId !== this.listRequestId) return;
                const data = extractPaginatedData(res);
                this.rujukanList = data.items;
                this.pagination = data.pagination;
                this.summary = {
                    diajukan: 0,
                    ditangani: 0,
                    selesai: 0,
                    ...res.data.data.summary,
                };
            } catch (err) {
                if (requestId !== this.listRequestId) return;
                this.error.fetchAll =
                    err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.listRequestId) {
                    this.loading.fetchAll = false;
                }
            }
        },

        // --------------------------------------------------
        // KADER & PUSKESMAS: Detail rujukan
        // --------------------------------------------------
        async fetchDetailRujukan(id) {
            const requestId = ++this.detailRequestId;
            this.loading.fetchDetail = true;
            this.error.fetchDetail = null;
            this.rujukanDetail = null;
            try {
                const res = await rujukanService.getDetailRujukan(id);
                if (requestId !== this.detailRequestId) return;
                this.rujukanDetail = res.data.data;
            } catch (err) {
                if (requestId !== this.detailRequestId) return;
                this.error.fetchDetail =
                    err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.detailRequestId) {
                    this.loading.fetchDetail = false;
                }
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
                const updated = res.data.data;

                // Update status di list tanpa fetch ulang
                const idx = this.rujukanList.findIndex((r) => r.id === id);
                if (idx !== -1) {
                    this.rujukanList[idx] = {
                        ...this.rujukanList[idx],
                        ...updated,
                    };
                }

                // Update juga di detail jika sedang dibuka
                if (this.rujukanDetail?.id === id) {
                    this.rujukanDetail = {
                        ...this.rujukanDetail,
                        ...updated,
                    };
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
            const requestId = ++this.riwayatRequestId;
            this.loading.fetchByAnak = true;
            this.error.fetchByAnak = null;
            this.riwayatAnak = { anak: null, list: [] };
            try {
                const res = await rujukanService.getRujukanByAnak(anakId);
                if (requestId !== this.riwayatRequestId) return;
                this.riwayatAnak.anak = res.data.data.anak;
                this.riwayatAnak.list = res.data.data.rujukan;
            } catch (err) {
                if (requestId !== this.riwayatRequestId) return;
                this.error.fetchByAnak =
                    err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.riwayatRequestId) {
                    this.loading.fetchByAnak = false;
                }
            }
        },

        resetCreateState() {
            this.createResult = null;
            this.error.create = null;
        },

        resetRiwayatAnak() {
            this.riwayatRequestId++;
            this.riwayatAnak = { anak: null, list: [] };
            this.loading.fetchByAnak = false;
            this.error.fetchByAnak = null;
        },
    },
});
