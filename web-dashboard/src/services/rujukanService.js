// src/services/rujukanService.js
import api from "./api";

const rujukanService = {
    createRujukan(payload) {
        return api.post("/rujukan", payload);
    },

    getAllRujukan() {
        return api.get("/rujukan");
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
