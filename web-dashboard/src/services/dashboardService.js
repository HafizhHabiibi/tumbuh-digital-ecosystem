import api from "./api";

const dashboardService = {
    getStatistik() {
        return api.get("/dashboard/statistik");
    },

    getDistribusiGizi() {
        return api.get("/dashboard/distribusi-gizi");
    },

    getTrenGizi(bulan = 6) {
        return api.get("/dashboard/tren-gizi", {
            params: { bulan },
        });
    },

    getDistribusiRisiko() {
        return api.get("/dashboard/distribusi-risiko");
    },
};

export default dashboardService;
