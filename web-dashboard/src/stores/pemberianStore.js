// src/stores/pemberianStore.js
import { defineStore } from "pinia";
import pemberianService from "@/services/pemberianService";

export const JENIS_VALID = [
    "vitamin_a_merah",
    "vitamin_a_biru",
    "obat_cacing",
    "pmt_biskuit",
    "pmt_susu",
    "pmt_lainnya",
];

export const LABEL_JENIS = {
    vitamin_a_merah: "Vitamin A Merah",
    vitamin_a_biru: "Vitamin A Biru",
    obat_cacing: "Obat Cacing",
    pmt_biskuit: "PMT Biskuit",
    pmt_susu: "PMT Susu",
    pmt_lainnya: "PMT Lainnya",
};

export const IKON_JENIS = {
    vitamin_a_merah: "pi-sun",
    vitamin_a_biru: "pi-sun",
    obat_cacing: "pi-heart",
    pmt_biskuit: "pi-box",
    pmt_susu: "pi-inbox",
    pmt_lainnya: "pi-apple",
};

export const WARNA_JENIS = {
    vitamin_a_merah: "#dc2626",
    vitamin_a_biru: "#2563eb",
    obat_cacing: "#15803d",
    pmt_biskuit: "#b45309",
    pmt_susu: "#7c3aed",
    pmt_lainnya: "#0f766e",
};

export const WARNA_BG_JENIS = {
    vitamin_a_merah: "#fee2e2",
    vitamin_a_biru: "#dbeafe",
    obat_cacing: "#dcfce7",
    pmt_biskuit: "#fef3c7",
    pmt_susu: "#ede9fe",
    pmt_lainnya: "#ccfbf1",
};

export const usePemberianStore = defineStore("pemberian", {
    // ========== STATE ==========
    state: () => ({
        // Riwayat pemberian + info anak
        riwayat: {
            anak: null,
            list: [],
            filterAktif: "semua",
        },

        // Hasil create
        createResult: null,
        riwayatRequestId: 0,

        loading: {
            create: false,
            riwayat: false,
        },

        error: {
            create: null,
            riwayat: null,
        },
    }),

    // ========== GETTERS ==========
    getters: {
        riwayatPerJenis: (state) => {
            return JENIS_VALID.reduce((acc, jenis) => {
                acc[jenis] = state.riwayat.list.filter(
                    (r) => r.jenis === jenis,
                );
                return acc;
            }, {});
        },

        jumlahPerJenis: (state) => {
            return JENIS_VALID.reduce((acc, jenis) => {
                acc[jenis] = state.riwayat.list.filter(
                    (r) => r.jenis === jenis,
                ).length;
                return acc;
            }, {});
        },
    },

    // ========== ACTIONS ==========
    actions: {
        async createRiwayat(payload) {
            this.loading.create = true;
            this.error.create = null;
            this.createResult = null;
            try {
                const res = await pemberianService.createRiwayat(payload);
                this.createResult = res.data.data;

                if (
                    this.riwayat.anak &&
                    String(this.riwayat.anak.id) === String(payload.anak_id)
                ) {
                    const filter =
                        this.riwayat.filterAktif === "semua"
                            ? null
                            : this.riwayat.filterAktif;
                    await this.fetchRiwayat(payload.anak_id, filter);
                }

                return true;
            } catch (err) {
                this.error.create = err.response?.data?.message || err.message;
                return false;
            } finally {
                this.loading.create = false;
            }
        },

        async fetchRiwayat(anakId, jenis = null) {
            const requestId = ++this.riwayatRequestId;
            this.loading.riwayat = true;
            this.error.riwayat = null;
            this.riwayat = {
                anak: null,
                list: [],
                filterAktif: jenis || "semua",
            };
            try {
                const res = await pemberianService.getRiwayatByAnak(
                    anakId,
                    jenis,
                );
                if (requestId !== this.riwayatRequestId) return;
                this.riwayat.anak = res.data.data.anak;
                this.riwayat.list = res.data.data.pemberian;
                this.riwayat.filterAktif = res.data.data.filter; // 'semua' atau nama jenis
            } catch (err) {
                if (requestId !== this.riwayatRequestId) return;
                this.error.riwayat = err.response?.data?.message || err.message;
            } finally {
                if (requestId === this.riwayatRequestId) {
                    this.loading.riwayat = false;
                }
            }
        },

        async gantiFilter(anakId, jenis) {
            const filter = jenis === "semua" ? null : jenis;
            await this.fetchRiwayat(anakId, filter);
        },

        resetCreateState() {
            this.createResult = null;
            this.error.create = null;
        },

        resetRiwayat() {
            this.riwayatRequestId++;
            this.riwayat = { anak: null, list: [], filterAktif: "semua" };
            this.loading.riwayat = false;
            this.error.riwayat = null;
        },
    },
});
