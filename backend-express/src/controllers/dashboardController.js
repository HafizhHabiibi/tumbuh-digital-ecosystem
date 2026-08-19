import * as pengukuranService from "../services/pengukuranService.js";
import { success, error } from "../utils/response.js";

export const getStatistik = async (req, res) => {
    try {
        const statistik = await pengukuranService.getStatistik();
        return success(res, statistik, "Statistik berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDistribusiGizi = async (req, res) => {
    try {
        const distribusi = await pengukuranService.getDistribusiGizi();
        return success(res, distribusi, "Distribusi gizi berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getTrenGizi = async (req, res) => {
    try {
        const bulan = parseInt(req.query.bulan) || 6;
        const tren = await pengukuranService.getTrenGizi(bulan);
        return success(
            res,
            tren,
            `Tren ${bulan} bulan terakhir berhasil diambil`,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDistribusiRisiko = async (req, res) => {
    try {
        const distribusi = await pengukuranService.getDistribusiRisiko();
        return success(
            res,
            distribusi,
            "Distribusi risiko stunting berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
