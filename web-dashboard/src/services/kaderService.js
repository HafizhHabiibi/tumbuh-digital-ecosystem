import api from "./api";

const kaderService = {
    // PROFIL
    getProfil() {
        return api.get("/kader/profile");
    },

    // ORANG TUA
    getAllOrangTua() {
        return api.get("/kader/orang-tua");
    },
    getOrangTuaById(id) {
        return api.get(`/kader/orang-tua/${id}`);
    },
    createOrangTua(payload) {
        return api.post("/kader/orang-tua", payload);
    },

    // ANAK
    getAllAnak() {
        return api.get("/kader/anak");
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
};

export default kaderService;
