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

        const page = Math.max(1, parseInt(req.query.page) || 1);
        const limit = Math.min(50, Math.max(1, parseInt(req.query.limit) || 20));

        const notifikasi = await NotifikasiModel.findByOrangTua(orangTua.id, page, limit);
        const total = await NotifikasiModel.countByOrangTua(orangTua.id);
        const belumDibaca = await NotifikasiModel.countBelumDibaca(orangTua.id);

        return success(
            res,
            {
                total,
                belum_dibaca: belumDibaca,
                halaman: page,
                per_halaman: limit,
                total_halaman: Math.ceil(total / limit),
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
            { belum_dibaca: total },
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

export const hapusNotifikasi = async (req, res) => {
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

        await NotifikasiModel.deleteById(id, orangTua.id);
        return success(res, null, "Notifikasi berhasil dihapus");
    } catch (err) {
        return error(res, err.message);
    }
};

export const hapusSudahDibaca = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const jumlah = await NotifikasiModel.deleteSudahDibaca(orangTua.id);
        return success(
            res,
            { dihapus: jumlah },
            `${jumlah} notifikasi yang sudah dibaca berhasil dihapus`,
        );
    } catch (err) {
        return error(res, err.message);
    }
};
