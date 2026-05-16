import api from "./api";

const pemberianService = {
    createRiwayat(payload) {
        return api.post("/riwayat-pemberian", payload);
    },

    getRiwayatByAnak(anakId, jenis = null) {
        return api.get(`/riwayat-pemberian/anak/${anakId}`, {
            params: jenis ? { jenis } : {},
        });
    },
};

export default pemberianService;
