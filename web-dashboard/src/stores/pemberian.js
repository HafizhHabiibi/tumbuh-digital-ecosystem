// src/stores/pemberianStore.js
import { defineStore } from "pinia";
import pemberianService from "@/services/pemberianService";

export const JENIS_VALID = ["imunisasi", "vitamin_a", "obat_cacing", "pmt"];

export const PILIHAN = {
    imunisasi: [
        "BCG",
        "Hepatitis B 1",
        "Hepatitis B 2",
        "Polio 1",
        "Polio 2",
        "Polio 3",
        "Polio 4",
        "DPT-HB-Hib 1",
        "DPT-HB-Hib 2",
        "DPT-HB-Hib 3",
        "Campak Rubella (MR)",
        "IPV",
    ],
    vitamin_a: ["Vitamin A Biru 100.000 IU", "Vitamin A Merah 200.000 IU"],
    obat_cacing: ["Albendazole 400mg"],
    pmt: ["Biskuit PMT Balita"],
};

export const LABEL_JENIS = {
    imunisasi: "Imunisasi",
    vitamin_a: "Vitamin A",
    obat_cacing: "Obat Cacing",
    pmt: "PMT (Pemberian Makanan Tambahan)",
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
        pilihanByJenis: () => (jenis) => {
            return PILIHAN[jenis] || [];
        },

        riwayatPerJenis: (state) => {
            return JENIS_VALID.reduce((acc, jenis) => {
                acc[jenis] = state.riwayat.list.filter(
                    (r) => r.jenis === jenis,
                );
                return acc;
            }, {});
        },

        imunisasiSudahDiterima: (state) => {
            return state.riwayat.list
                .filter((r) => r.jenis === "imunisasi")
                .map((r) => r.nama_item);
        },

        imunisasiBelumDiterima: (state, getters) => {
            return PILIHAN.imunisasi.filter(
                (item) => !getters.imunisasiSudahDiterima.includes(item),
            );
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

                // Jika riwayat anak yang sama sedang ditampilkan,
                // langsung tambahkan ke list tanpa fetch ulang
                if (
                    this.riwayat.anak &&
                    this.riwayat.anak.id === payload.anak_id &&
                    (this.riwayat.filterAktif === "semua" ||
                        this.riwayat.filterAktif === payload.jenis)
                ) {
                    this.riwayat.list.unshift(res.data.data); // tambah ke paling atas
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
            this.loading.riwayat = true;
            this.error.riwayat = null;
            try {
                const res = await pemberianService.getRiwayatByAnak(
                    anakId,
                    jenis,
                );
                this.riwayat.anak = res.data.data.anak;
                this.riwayat.list = res.data.data.riwayat;
                this.riwayat.filterAktif = res.data.data.filter; // 'semua' atau nama jenis
            } catch (err) {
                this.error.riwayat = err.response?.data?.message || err.message;
            } finally {
                this.loading.riwayat = false;
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
            this.riwayat = { anak: null, list: [], filterAktif: "semua" };
        },
    },
});
