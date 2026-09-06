import { defineStore } from "pinia";
import puskesmasService from "@/services/puskesmasService";
import pemberianService from "@/services/pemberianService";
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

export const usePuskesmasStore = defineStore("puskesmas", {
    state: () => ({
        anakList: [],
        anakOptions: [],
        totalAnakSemua: 0,
        anakDetail: null,
        riwayatPengukuran: [],
        riwayatPemberian: [],
        pagination: createPagination(),
        anakListRequestId: 0,
        loading: {
            anakList: false,
            anakOptions: false,
            anakDetail: false,
            pemberian: false,
        },
        error: {
            anakList: null,
            anakOptions: null,
            anakDetail: null,
            pemberian: null,
        },
    }),

    getters: {
        pengukuranTerakhir: (state) => state.riwayatPengukuran[0] || null,
        totalAnak: (state) => {
            if (state.anakOptions.length) {
                return state.anakOptions.length;
            }
            if (state.totalAnakSemua) {
                return state.totalAnakSemua;
            }
            return state.pagination.total;
        },
        anakLaki: (state) =>
            (state.anakOptions.length ? state.anakOptions : state.anakList).filter(
                (a) => a.jenis_kelamin === "L",
            ),
        anakPerempuan: (state) =>
            (state.anakOptions.length ? state.anakOptions : state.anakList).filter(
                (a) => a.jenis_kelamin === "P",
            ),
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
                if (!params.jenis_kelamin && !params.search) {
                    this.totalAnakSemua = data.pagination.total;
                }
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

        async fetchAnakOptions() {
            if (this.loading.anakOptions) return;
            this.loading.anakOptions = true;
            this.error.anakOptions = null;
            try {
                this.anakOptions = await collectAllPages((params) =>
                    puskesmasService.getAllAnak(params),
                );
                this.totalAnakSemua = this.anakOptions.length;
            } catch (error) {
                this.error.anakOptions =
                    error.response?.data?.message ||
                    error.message ||
                    "Gagal memuat ringkasan data anak";
            } finally {
                this.loading.anakOptions = false;
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
