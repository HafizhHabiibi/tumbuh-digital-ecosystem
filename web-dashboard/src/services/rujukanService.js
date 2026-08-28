// src/services/rujukanService.js
import api from "./api";

const rujukanService = {
    createRujukan(payload) {
        return api.post("/rujukan", payload);
    },

    getAllRujukan(params = {}) {
        return api.get("/rujukan", { params });
    },

    getDetailRujukan(id) {
        return api.get(`/rujukan/${id}`);
    },

    updateStatusRujukan(id, payload) {
        return api.put(`/rujukan/${id}/status`, payload);
    },

    getRujukanByAnak(anakId) {
        return api.get(`/rujukan/anak/${anakId}`);
    },
};

export default rujukanService;
