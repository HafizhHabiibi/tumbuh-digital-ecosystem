import api from "./api";

const jadwalService = {
    getAllJadwal() {
        return api.get("/jadwal");
    },

    getDetailJadwal(id) {
        return api.get(`/jadwal/${id}`);
    },

    createJadwal(payload) {
        return api.post("/jadwal", payload);
    },
};

export default jadwalService;
