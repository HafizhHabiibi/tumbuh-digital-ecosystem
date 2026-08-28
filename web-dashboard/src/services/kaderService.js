import api from "./api";

const kaderService = {
    // PROFIL
    getProfil() {
        return api.get("/kader/profile");
    },

    // ORANG TUA
    getAllOrangTua(params = {}) {
        return api.get("/kader/orang-tua", { params });
    },
    getOrangTuaById(id) {
        return api.get(`/kader/orang-tua/${id}`);
    },
    createOrangTua(payload) {
        return api.post("/kader/orang-tua", payload);
    },
    updateOrangTua(id, payload) {
        return api.put(`/kader/orang-tua/${id}`, payload);
    },
    deleteOrangTua(id) {
        return api.delete(`/kader/orang-tua/${id}`);
    },

    // ANAK
    getAllAnak(params = {}) {
        return api.get("/kader/anak", { params });
    },
    getAnakById(id) {
        return api.get(`/kader/anak/${id}`);
    },
    getAnakByOrangTua(orangTuaId) {
        return api.get(`/kader/orang-tua/${orangTuaId}/anak`);
    },
    createAnak(payload) {
        return api.post("/kader/anak", payload);
    },
    updateAnak(id, payload) {
        return api.put(`/kader/anak/${id}`, payload);
    },
    deleteAnak(id) {
        return api.delete(`/kader/anak/${id}`);
    },
};

export default kaderService;
