import api from "./api";

const jadwalService = {
    getAllJadwal(params = {}) {
        return api.get("/jadwal", { params });
    },

    getDetailJadwal(id) {
        return api.get(`/jadwal/${id}`);
    },

    createJadwal(payload) {
        return api.post("/jadwal", payload);
    },
    updateJadwal(id, payload) {
        return api.put(`/jadwal/${id}`, payload);
    },
    deleteJadwal(id) {
        return api.delete(`/jadwal/${id}`);
    },
    getPengaturan() {
        return api.get("/jadwal/pengaturan");
    },
    setPengaturan(payload) {
        return api.put("/jadwal/pengaturan", payload);
    },
    generateJadwal(jumlahBulan = 6) {
        return api.post("/jadwal/generate", { jumlah_bulan: jumlahBulan });
    },
};

export default jadwalService;
