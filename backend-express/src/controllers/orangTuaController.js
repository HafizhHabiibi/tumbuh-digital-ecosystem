import * as OrangTuaModel from "../models/orangTuaModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as RiwayatModel from "../models/riwayatPemberianModel.js";
import * as RujukanModel from "../models/rujukanModel.js";
import { success, error } from "../utils/response.js";

const getOrangTua = async (user_id) => {
    return await OrangTuaModel.findByUserId(user_id);
};

export const getProfil = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }
        return success(res, orangTua, "Profil berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAnak = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const anak = await AnakModel.findByOrangTua(orangTua.id);
        return success(res, anak, "Daftar anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAnakById = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const anak = await AnakModel.findById(req.params.id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        if (anak.orang_tua_id !== orangTua.id) {
            return error(res, "Akses ditolak", 403);
        }

        return success(res, anak, "Data anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getPengukuranAnak = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const anak = await AnakModel.findById(req.params.id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        if (anak.orang_tua_id !== orangTua.id) {
            return error(res, "Akses ditolak", 403);
        }

        const riwayat = await PengukuranModel.findByAnak(req.params.id);
        return success(
            res,
            {
                anak,
                riwayat,
            },
            "Riwayat pengukuran berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getPemberianAnak = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const anak = await AnakModel.findById(req.params.id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        if (anak.orang_tua_id !== orangTua.id) {
            return error(res, "Akses ditolak", 403);
        }

        const { jenis } = req.query;
        const riwayat = await RiwayatModel.findByAnak(
            req.params.id,
            jenis || null,
        );

        return success(
            res,
            {
                anak,
                filter: jenis || "semua",
                riwayat,
            },
            "Riwayat pemberian berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRujukanAnak = async (req, res) => {
    try {
        const orangTua = await getOrangTua(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }

        const anak = await AnakModel.findById(req.params.id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        if (anak.orang_tua_id !== orangTua.id) {
            return error(res, "Akses ditolak", 403);
        }

        const rujukan = await RujukanModel.findByAnak(req.params.id);
        return success(
            res,
            {
                anak,
                rujukan,
            },
            "Riwayat rujukan berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
