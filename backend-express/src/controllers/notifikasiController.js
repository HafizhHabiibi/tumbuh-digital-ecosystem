import * as NotifikasiModel from "../models/notifikasiModel.js";
import * as OrangTuaModel from "../models/orangTuaModel.js";
import { success, error } from "../utils/response.js";

const getOrangTua = async (user_id) => {
    return await OrangTuaModel.findByUserId(user_id);
};

export const getNotifikasi = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const notifikasi = await NotifikasiModel.findByOrangTua(orangTua.id);
        const belumDibaca = await NotifikasiModel.countBelumDibaca(orangTua.id);

        return success(
            res,
            {
                total: notifikasi.length,
                belumDibaca: belumDibaca,
                notifikasi,
            },
            "Notifikasi berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getBelumDibaca = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const total = await NotifikasiModel.countBelumDibaca(orangTua.id);
        return success(
            res,
            { belumdibaca: total },
            "Jumlah notifikasi belum dibaca berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const tandaiDibaca = async (req, res) => {
    try {
        const { id } = req.params;
        const orangTua = await getOrangTua(req.user.id);

        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const notif = await NotifikasiModel.findById(id, orangTua.id);
        if (!notif) {
            return error(res, "Notifikasi tidak ditemukan", 404);
        }

        await NotifikasiModel.tandaiDibaca(id, orangTua.id);
        return success(res, null, "Notifikasi berhasil ditandai sudah dibaca");
    } catch (err) {
        return error(res, err.message);
    }
};

export const tandaiSemuaDibaca = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const jumlah = await NotifikasiModel.tandaiSemuaDibaca(orangTua.id);
        return success(
            res,
            {
                ditandai: jumlah,
            },
            `${jumlah} notifikasi berhasil ditandai sudah dibaca`,
        );
    } catch (err) {
        return error(res, err.message);
    }
};
