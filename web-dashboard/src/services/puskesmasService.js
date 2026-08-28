import api from "./api";

const puskesmasService = {
    getProfil() {
        return api.get("/puskesmas/profile");
    },

    getAllAnak(params = {}) {
        return api.get("/puskesmas/anak", { params });
    },

    getAnakById(id) {
        return api.get(`/puskesmas/anak/${id}`);
    },

    getPengukuranAnak(id) {
        return api.get(`/puskesmas/anak/${id}/pengukuran`);
    },
};

export default puskesmasService;
