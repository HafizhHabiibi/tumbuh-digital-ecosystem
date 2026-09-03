import { defineStore } from "pinia";
import puskesmasService from "@/services/puskesmasService";
import pemberianService from "@/services/pemberianService";
import {
    createPagination,
    extractPaginatedData,
} from "@/utils/apiResponse";

export const usePuskesmasStore = defineStore("puskesmas", {
    state: () => ({
        anakList: [],
        anakDetail: null,
        riwayatPengukuran: [],
        riwayatPemberian: [],
        pagination: createPagination(),
        anakListRequestId: 0,
        loading: {
            anakList: false,
            anakDetail: false,
            pemberian: false,
        },
        error: {
            anakList: null,
            anakDetail: null,
            pemberian: null,
        },
    }),

    getters: {
        pengukuranTerakhir: (state) => state.riwayatPengukuran[0] || null,
    },

    actions: {
        async fetchAllAnak(params = {}) {
            const requestId = ++this.anakListRequestId;
            this.loading.anakList = true;
            this.error.anakList = null;
            try {
                const page = params.page ?? this.pagination.page;
                const limit = params.limit ?? this.pagination.limit;
                const response = await puskesmasService.getAllAnak({
                    ...params,
                    page,
                    limit,
                });
                if (requestId !== this.anakListRequestId) return;
                const data = extractPaginatedData(response);
                this.anakList = data.items;
                this.pagination = data.pagination;
            } catch (error) {
                if (requestId !== this.anakListRequestId) return;
                this.error.anakList =
                    error.response?.data?.message ||
                    error.message ||
                    "Gagal memuat daftar anak";
            } finally {
                if (requestId === this.anakListRequestId) {
                    this.loading.anakList = false;
                }
            }
        },

        async fetchDetailAnak(id) {
            this.loading.anakDetail = true;
            this.error.anakDetail = null;
            this.anakDetail = null;
            this.riwayatPengukuran = [];
            try {
                const response = await puskesmasService.getPengukuranAnak(id);
                this.anakDetail = response.data.data.anak;
                this.riwayatPengukuran = response.data.data.riwayat || [];
            } catch (error) {
                this.error.anakDetail =
                    error.response?.data?.message ||
                    error.message ||
                    "Gagal memuat detail anak";
            } finally {
                this.loading.anakDetail = false;
            }
        },

        async fetchPemberian(id) {
            this.loading.pemberian = true;
            this.error.pemberian = null;
            this.riwayatPemberian = [];
            try {
                const response = await pemberianService.getRiwayatByAnak(id);
                this.riwayatPemberian = response.data.data.pemberian || [];
            } catch (error) {
                this.error.pemberian =
                    error.response?.data?.message ||
                    error.message ||
                    "Gagal memuat riwayat pemberian";
            } finally {
                this.loading.pemberian = false;
            }
        },
    },
});
