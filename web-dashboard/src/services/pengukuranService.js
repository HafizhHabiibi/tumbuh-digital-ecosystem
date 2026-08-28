// src/services/pengukuranService.js
import api from "./api";

const pengukuranService = {
    createPengukuran(payload) {
        return api.post("/pengukuran", payload);
    },
    getRiwayatPengukuran(anakId) {
        return api.get(`/pengukuran/anak/${anakId}`);
    },
    getDetailPengukuran(id) {
        return api.get(`/pengukuran/${id}`);
    },
    getRankingAnak(params = {}) {
        return api.get("/pengukuran/ranking", { params });
    },
    getDetailSAW(id) {
        return api.get(`/pengukuran/${id}/saw`);
    },
};

export default pengukuranService;
