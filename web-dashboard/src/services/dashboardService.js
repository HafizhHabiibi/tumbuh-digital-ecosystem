import api from "./api";

const dashboardService = {
    getStatistik() {
        return api.get("/dashboard/statistik");
    },

    getDistribusiGizi() {
        return api.get("/dashboard/distribusi");
    },

    getTrenGizi(bulan = 6) {
        return api.get("/dashboard/tren", {
            params: { bulan },
        });
    },

    getDistribusiRisiko() {
        return api.get("/dashboard/risiko");
    },
};

export default dashboardService;
