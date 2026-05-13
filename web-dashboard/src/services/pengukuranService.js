// src/services/pengukuranService.js
import api from "./api";

const pengukuranService = {
    createPengukuran(payload) {
        return api.post("/pengukuran", payload);
    },
    getRiwayatPengukuran(anakId) {
        return api.get(`/pengukuran/anak/${anakId}/riwayat`);
    },
    getDetailPengukuran(id) {
        return api.get(`/pengukuran/${id}`);
    },
    getRankingAnak() {
        return api.get("/pengukuran/ranking");
    },
    getDetailSAW(id) {
        return api.get(`/pengukuran/saw/${id}`);
    },
};

export default pengukuranService;
