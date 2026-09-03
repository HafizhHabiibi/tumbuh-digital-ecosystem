// src/stores/kaderStore.js
import { defineStore } from "pinia";
import kaderService from "@/services/kaderService";
import {
    createPagination,
    extractPaginatedData,
} from "@/utils/apiResponse";

const collectAllPages = async (request) => {
    const firstResponse = await request({ page: 1, limit: 100 });
    const firstPage = extractPaginatedData(firstResponse);
    const totalPages = firstPage.pagination.total_pages;

    if (totalPages <= 1) return firstPage.items;

    const remainingResponses = await Promise.all(
        Array.from({ length: totalPages - 1 }, (_, index) =>
            request({ page: index + 2, limit: 100 }),
        ),
    );

    return [
        ...firstPage.items,
        ...remainingResponses.flatMap(
            (response) => extractPaginatedData(response).items,
        ),
    ];
};

export const useKaderStore = defineStore("kader", {
    // ========== STATE ==========
    state: () => ({
        // Profil kader yang sedang login
        profil: null,

        // ==================
        // ORANG TUA
        // ==================
        orangTuaList: [],
        orangTuaOptions: [],
        orangTuaDetail: null,
        createOrangTuaResult: null,

        // ==================
        // ANAK
        // ==================
        anakList: [], // semua anak (halaman daftar anak)
        anakOptions: [],
        anakDetail: null, // detail satu anak

        pagination: {
            orangTua: createPagination(),
            anak: createPagination(),
        },
        listRequestId: {
            orangTua: 0,
            anak: 0,
        },

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
            orangTuaOptions: false,
            orangTuaDetail: false,
            createOrangTua: false,
            updateOrangTua: false,
            deleteOrangTua: false,
            anakList: false,
            anakOptions: false,
            anakDetail: false,
            anakByOrangTua: false,
            createAnak: false,
            updateAnak: false,
            deleteAnak: false,
        },

        error: {
            profil: null,
            orangTuaList: null,
            orangTuaOptions: null,
            orangTuaDetail: null,
            createOrangTua: null,
            updateOrangTua: null,
            deleteOrangTua: null,
            anakList: null,
            anakOptions: null,
            anakDetail: null,
            anakByOrangTua: null,
            createAnak: null,
            updateAnak: null,
            deleteAnak: null,
        },
    }),

    // ========== GETTERS ==========
    getters: {
        /**
         * Cari orang tua di list berdasarkan id
         * Berguna untuk tampilkan nama orang tua di tabel anak
         */
        orangTuaById: (state) => (id) => {
            return (
                state.orangTuaOptions.find((ot) => ot.id === id) ||
                state.orangTuaList.find((ot) => ot.id === id) ||
                null
            );
        },

        /**
         * Total anak yang terdaftar
         */
        totalAnak: (state) => state.pagination.anak.total,

        /**
         * Total orang tua yang terdaftar
         */
        totalOrangTua: (state) => state.pagination.orangTua.total,

        /**
         * Filter anak berdasarkan jenis kelamin
         */
        anakLaki: (state) =>
            (state.anakOptions.length ? state.anakOptions : state.anakList).filter(
                (a) => a.jenis_kelamin === "L",
            ),
        anakPerempuan: (state) =>
            (state.anakOptions.length ? state.anakOptions : state.anakList).filter(
                (a) => a.jenis_kelamin === "P",
            ),
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
        async fetchAllOrangTua(params = {}) {
            const requestId = ++this.listRequestId.orangTua;
            this.loading.orangTuaList = true;
            this.error.orangTuaList = null;
            try {
                const page = params.page ?? this.pagination.orangTua.page;
                const limit = params.limit ?? this.pagination.orangTua.limit;
                const res = await kaderService.getAllOrangTua({
                    ...params,
                    page,
                    limit,
                });
                if (requestId !== this.listRequestId.orangTua) return;
                const data = extractPaginatedData(res);
                this.orangTuaList = data.items;
                this.pagination.orangTua = data.pagination;
            } catch (err) {
                if (requestId !== this.listRequestId.orangTua) return;
                this.error.orangTuaList =
                    err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.listRequestId.orangTua) {
                    this.loading.orangTuaList = false;
                }
            }
        },

        async fetchOrangTuaOptions() {
            if (this.loading.orangTuaOptions) return;
            this.loading.orangTuaOptions = true;
            this.error.orangTuaOptions = null;
            try {
                this.orangTuaOptions = await collectAllPages((params) =>
                    kaderService.getAllOrangTua(params),
                );
            } catch (err) {
                this.error.orangTuaOptions =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.orangTuaOptions = false;
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
                await Promise.all([
                    this.fetchAllOrangTua({
                        page: this.pagination.orangTua.page,
                        limit: this.pagination.orangTua.limit,
                    }),
                    this.fetchOrangTuaOptions(),
                ]);
                return true;
            } catch (err) {
                this.error.createOrangTua =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.createOrangTua = false;
            }
        },

        async updateOrangTua(id, payload) {
            this.loading.updateOrangTua = true;
            this.error.updateOrangTua = null;
            try {
                const res = await kaderService.updateOrangTua(id, payload);
                const updated = res.data.data;

                if (this.orangTuaDetail?.id === id) {
                    this.orangTuaDetail = {
                        ...this.orangTuaDetail,
                        ...updated,
                    };
                }
                if (this.anakByOrangTua.orang_tua?.id === id) {
                    this.anakByOrangTua.orang_tua = {
                        ...this.anakByOrangTua.orang_tua,
                        ...updated,
                    };
                }

                await Promise.all([
                    this.fetchAllOrangTua({
                        page: this.pagination.orangTua.page,
                        limit: this.pagination.orangTua.limit,
                    }),
                    this.fetchOrangTuaOptions(),
                ]);
                return true;
            } catch (err) {
                this.error.updateOrangTua =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.updateOrangTua = false;
            }
        },

        async deleteOrangTua(id) {
            this.loading.deleteOrangTua = true;
            this.error.deleteOrangTua = null;
            try {
                await kaderService.deleteOrangTua(id);
                const page =
                    this.orangTuaList.length === 1 &&
                    this.pagination.orangTua.page > 1
                        ? this.pagination.orangTua.page - 1
                        : this.pagination.orangTua.page;
                await Promise.all([
                    this.fetchAllOrangTua({
                        page,
                        limit: this.pagination.orangTua.limit,
                    }),
                    this.fetchOrangTuaOptions(),
                ]);
                return true;
            } catch (err) {
                this.error.deleteOrangTua =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.deleteOrangTua = false;
            }
        },

        // --------------------------------------------------
        // ANAK
        // --------------------------------------------------
        async fetchAllAnak(params = {}) {
            const requestId = ++this.listRequestId.anak;
            this.loading.anakList = true;
            this.error.anakList = null;
            try {
                const page = params.page ?? this.pagination.anak.page;
                const limit = params.limit ?? this.pagination.anak.limit;
                const res = await kaderService.getAllAnak({
                    ...params,
                    page,
                    limit,
                });
                if (requestId !== this.listRequestId.anak) return;
                const data = extractPaginatedData(res);
                this.anakList = data.items;
                this.pagination.anak = data.pagination;
            } catch (err) {
                if (requestId !== this.listRequestId.anak) return;
                this.error.anakList =
                    err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.listRequestId.anak) {
                    this.loading.anakList = false;
                }
            }
        },

        async fetchAnakOptions() {
            if (this.loading.anakOptions) return;
            this.loading.anakOptions = true;
            this.error.anakOptions = null;
            try {
                this.anakOptions = await collectAllPages((params) =>
                    kaderService.getAllAnak(params),
                );
            } catch (err) {
                this.error.anakOptions =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.anakOptions = false;
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
                await Promise.all([
                    this.fetchAllAnak({
                        page: this.pagination.anak.page,
                        limit: this.pagination.anak.limit,
                    }),
                    this.fetchAnakOptions(),
                ]);

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

        async updateAnak(id, payload) {
            this.loading.updateAnak = true;
            this.error.updateAnak = null;
            try {
                const res = await kaderService.updateAnak(id, payload);
                const updated = res.data.data;

                if (this.anakDetail?.id === id) {
                    this.anakDetail = { ...this.anakDetail, ...updated };
                }
                this.anakByOrangTua.anak = this.anakByOrangTua.anak.map(
                    (anak) => anak.id === id ? { ...anak, ...updated } : anak,
                );

                await Promise.all([
                    this.fetchAllAnak({
                        page: this.pagination.anak.page,
                        limit: this.pagination.anak.limit,
                    }),
                    this.fetchAnakOptions(),
                ]);
                return true;
            } catch (err) {
                this.error.updateAnak =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.updateAnak = false;
            }
        },

        async deleteAnak(id) {
            this.loading.deleteAnak = true;
            this.error.deleteAnak = null;
            try {
                await kaderService.deleteAnak(id);
                const page =
                    this.anakList.length === 1 &&
                    this.pagination.anak.page > 1
                        ? this.pagination.anak.page - 1
                        : this.pagination.anak.page;
                await Promise.all([
                    this.fetchAllAnak({
                        page,
                        limit: this.pagination.anak.limit,
                    }),
                    this.fetchAnakOptions(),
                ]);
                return true;
            } catch (err) {
                this.error.deleteAnak =
                    err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.deleteAnak = false;
            }
        },

        // --------------------------------------------------
        // RESET
        // --------------------------------------------------
        resetCreateOrangTua() {
            this.createOrangTuaResult = null;
            this.error.createOrangTua = null;
        },

        resetUpdateOrangTua() {
            this.error.updateOrangTua = null;
        },

        resetDeleteOrangTua() {
            this.error.deleteOrangTua = null;
        },

        resetCreateAnak() {
            this.createAnakResult = null;
            this.error.createAnak = null;
        },

        resetUpdateAnak() {
            this.error.updateAnak = null;
        },

        resetDeleteAnak() {
            this.error.deleteAnak = null;
        },

        resetAnakByOrangTua() {
            this.anakByOrangTua = { orang_tua: null, anak: [] };
        },
    },
});
