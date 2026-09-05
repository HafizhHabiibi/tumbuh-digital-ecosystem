// src/stores/pengukuranStore.js
import { defineStore } from "pinia";
import pengukuranService from "@/services/pengukuranService";
import {
    createPagination,
    extractPaginatedData,
} from "@/utils/apiResponse";

export const usePengukuranStore = defineStore("pengukuran", {
    state: () => ({
        riwayat: {
            anak: null,
            list: [],
        },
        pengukuranDetail: null,
        createResult: null,
        rankingAnak: [],
        rankingPagination: createPagination(),
        rankingRequestId: 0,
        riwayatRequestId: 0,
        detailSAW: null,

        loading: {
            create: false,
            riwayat: false,
            detail: false,
            ranking: false,
            detailSAW: false,
        },

        error: {
            create: null,
            riwayat: null,
            detail: null,
            ranking: null,
            detailSAW: null,
        },
    }),

    getters: {
        pengukuranTerakhir: (state) => state.riwayat.list[0] || null,

        trenPertumbuhan: (state) => {
            return [...state.riwayat.list].reverse().map((p) => ({
                tanggal: p.tanggal_ukur,
                berat_badan: parseFloat(p.berat_badan),
                tinggi_badan: parseFloat(p.tinggi_badan),
            }));
        },
    },

    actions: {
        async createPengukuran(payload) {
            this.loading.create = true;
            this.error.create = null;
            this.createResult = null;
            try {
                const res = await pengukuranService.createPengukuran(payload);
                this.createResult = res.data.data;
                return true;
            } catch (err) {
                this.error.create = err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.create = false;
            }
        },

        async fetchRiwayat(anakId) {
            const requestId = ++this.riwayatRequestId;
            this.loading.riwayat = true;
            this.error.riwayat = null;
            this.riwayat = { anak: null, list: [] };
            try {
                const res =
                    await pengukuranService.getRiwayatPengukuran(anakId);
                if (requestId !== this.riwayatRequestId) return;
                this.riwayat.anak = res.data.data.anak;
                this.riwayat.list = res.data.data.riwayat;
            } catch (err) {
                if (requestId !== this.riwayatRequestId) return;
                this.error.riwayat = err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.riwayatRequestId) {
                    this.loading.riwayat = false;
                }
            }
        },

        async fetchDetailPengukuran(id) {
            this.loading.detail = true;
            this.error.detail = null;
            this.pengukuranDetail = null;
            try {
                const res = await pengukuranService.getDetailPengukuran(id);
                this.pengukuranDetail = res.data.data;
            } catch (err) {
                this.error.detail = err.response?.data?.message || err.message;
            } finally {
                this.loading.detail = false;
            }
        },

        async fetchRankingAnak(params = {}) {
            const requestId = ++this.rankingRequestId;
            this.loading.ranking = true;
            this.error.ranking = null;
            try {
                const page = params.page ?? this.rankingPagination.page;
                const limit = params.limit ?? this.rankingPagination.limit;
                const res = await pengukuranService.getRankingAnak({
                    ...params,
                    page,
                    limit,
                });
                if (requestId !== this.rankingRequestId) return;
                const data = extractPaginatedData(res);
                this.rankingAnak = data.items;
                this.rankingPagination = data.pagination;
            } catch (err) {
                if (requestId !== this.rankingRequestId) return;
                this.error.ranking = err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.rankingRequestId) {
                    this.loading.ranking = false;
                }
            }
        },

        async fetchDetailSAW(id) {
            this.loading.detailSAW = true;
            this.error.detailSAW = null;
            this.detailSAW = null;
            try {
                const res = await pengukuranService.getDetailSAW(id);
                this.detailSAW = res.data.data;
            } catch (err) {
                this.error.detailSAW =
                    err.response?.data?.message || err.message;
            } finally {
                this.loading.detailSAW = false;
            }
        },

        resetCreateState() {
            this.createResult = null;
            this.error.create = null;
        },

        resetRiwayat() {
            this.riwayatRequestId++;
            this.riwayat = { anak: null, list: [] };
            this.loading.riwayat = false;
            this.error.riwayat = null;
        },
    },
});
