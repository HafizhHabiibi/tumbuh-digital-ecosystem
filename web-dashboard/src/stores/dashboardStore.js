// src/stores/dashboardStore.js
import { defineStore } from "pinia";
import dashboardService from "@/services/dashboardService";

export const useDashboardStore = defineStore("dashboard", {
    // ========== STATE ==========
    state: () => ({
        // Data statistik kartu ringkasan
        statistik: {
            total_anak: 0,
            total_stunting: 0,
            total_rujukan_aktif: 0,
            total_pengukuran_bulan: 0,
        },

        // Data pie chart distribusi gizi
        distribusiGizi: {
            normal: 0,
            kurang: 0,
            buruk: 0,
            lebih: 0,
        },

        // Data line chart tren gizi [{periode, normal, kurang, buruk, lebih}]
        trenGizi: [],

        // Data distribusi risiko stunting
        distribusiRisiko: {
            rendah: 0,
            sedang: 0,
            tinggi: 0,
        },

        // Loading state per section (biar bisa skeleton per kartu)
        loading: {
            statistik: false,
            distribusiGizi: false,
            trenGizi: false,
            distribusiRisiko: false,
        },

        // Error state
        error: {
            statistik: null,
            distribusiGizi: null,
            trenGizi: null,
            distribusiRisiko: null,
        },
    }),

    // ========== GETTERS ==========
    getters: {
        /**
         * Persentase stunting dari total anak
         */
        persentaseStunting: (state) => {
            if (state.statistik.total_anak === 0) return 0;
            return (
                (state.statistik.total_stunting / state.statistik.total_anak) *
                100
            ).toFixed(1);
        },

        /**
         * Format data distribusi gizi untuk chart (array of {label, value})
         */
        distribusiGiziChart: (state) => [
            {
                label: "Normal",
                value: state.distribusiGizi.normal,
                color: "#22c55e",
            },
            {
                label: "Kurang",
                value: state.distribusiGizi.kurang,
                color: "#f59e0b",
            },
            {
                label: "Buruk",
                value: state.distribusiGizi.buruk,
                color: "#ef4444",
            },
            {
                label: "Lebih",
                value: state.distribusiGizi.lebih,
                color: "#3b82f6",
            },
        ],

        /**
         * Format data distribusi risiko untuk chart
         */
        distribusiRisikoChart: (state) => [
            {
                label: "Rendah",
                value: state.distribusiRisiko.rendah,
                color: "#22c55e",
            },
            {
                label: "Sedang",
                value: state.distribusiRisiko.sedang,
                color: "#f59e0b",
            },
            {
                label: "Tinggi",
                value: state.distribusiRisiko.tinggi,
                color: "#ef4444",
            },
        ],

        /**
         * Cek apakah semua data sedang loading
         */
        isAnyLoading: (state) => Object.values(state.loading).some(Boolean),
    },

    // ========== ACTIONS ==========
    actions: {
        async fetchStatistik() {
            this.loading.statistik = true;
            this.error.statistik = null;
            try {
                const res = await dashboardService.getStatistik();
                this.statistik = res.data.data; // sesuai format response.js kamu
            } catch (err) {
                this.error.statistik = err.message;
            } finally {
                this.loading.statistik = false;
            }
        },

        async fetchDistribusiGizi() {
            this.loading.distribusiGizi = true;
            this.error.distribusiGizi = null;
            try {
                const res = await dashboardService.getDistribusiGizi();
                this.distribusiGizi = res.data.data;
            } catch (err) {
                this.error.distribusiGizi = err.message;
            } finally {
                this.loading.distribusiGizi = false;
            }
        },

        async fetchTrenGizi(bulan = 6) {
            this.loading.trenGizi = true;
            this.error.trenGizi = null;
            try {
                const res = await dashboardService.getTrenGizi(bulan);
                this.trenGizi = res.data.data;
            } catch (err) {
                this.error.trenGizi = err.message;
            } finally {
                this.loading.trenGizi = false;
            }
        },

        async fetchDistribusiRisiko() {
            this.loading.distribusiRisiko = true;
            this.error.distribusiRisiko = null;
            try {
                const res = await dashboardService.getDistribusiRisiko();
                this.distribusiRisiko = res.data.data;
            } catch (err) {
                this.error.distribusiRisiko = err.message;
            } finally {
                this.loading.distribusiRisiko = false;
            }
        },

        /**
         * Load semua data dashboard sekaligus (dipanggil di onMounted)
         * Pakai Promise.all agar semua request jalan paralel, lebih cepat
         */
        async fetchAll(bulan = 6) {
            await Promise.all([
                this.fetchStatistik(),
                this.fetchDistribusiGizi(),
                this.fetchTrenGizi(bulan),
                this.fetchDistribusiRisiko(),
            ]);
        },
    },
});
