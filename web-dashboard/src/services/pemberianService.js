import api from "./api";

const pemberianService = {
    createRiwayat(payload) {
        return api.post("/pemberian", payload);
    },

    getRiwayatByAnak(anakId, jenis = null) {
        return api.get(`/pemberian/anak/${anakId}`, {
            params: jenis ? { jenis } : {},
        });
    },
};

export default pemberianService;
