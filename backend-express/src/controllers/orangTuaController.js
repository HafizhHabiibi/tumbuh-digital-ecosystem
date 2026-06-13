import * as AnakModel from "../models/anakModel.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as RiwayatModel from "../models/riwayatPemberianModel.js";
import * as RujukanModel from "../models/rujukanModel.js";
import { success, error } from "../utils/response.js";


export const getProfil = async (req, res) => {
    try {
        return success(res, req.orangTua, "Profil berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAnak = async (req, res) => {
    try {
        const anak = await AnakModel.findByOrangTua(req.orangTua.id);
        return success(res, anak, "Daftar anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

const getAnakMilikOrangTua = async (res, anakId, orangTuaId) => {
    const anak = await AnakModel.findById(anakId);
    if (!anak) {
        error(res, "Data anak tidak ditemukan", 404);
        return null;
    }
    if (anak.orang_tua_id !== orangTuaId) {
        error(res, "Akses ditolak", 403);
        return null;
    }
    return anak;
};

export const getAnakById = async (req, res) => {
    try {
        const anak = await getAnakMilikOrangTua(
            res,
            req.params.id,
            req.orangTua.id,
        );
        if (!anak) return;

        return success(res, anak, "Data anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getPengukuranAnak = async (req, res) => {
    try {
        const anak = await getAnakMilikOrangTua(
            res,
            req.params.id,
            req.orangTua.id,
        );
        if (!anak) return;

        const riwayat = await PengukuranModel.findByAnak(req.params.id);
        return success(
            res,
            { anak, riwayat },
            "Riwayat pengukuran berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getPemberianAnak = async (req, res) => {
    try {
        const anak = await getAnakMilikOrangTua(
            res,
            req.params.id,
            req.orangTua.id,
        );
        if (!anak) return;

        const { jenis } = req.query;
        const riwayat = await RiwayatModel.findByAnak(
            req.params.id,
            jenis || null,
        );

        return success(
            res,
            { anak, filter: jenis || "semua", riwayat },
            "Riwayat pemberian berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRujukanAnak = async (req, res) => {
    try {
        const anak = await getAnakMilikOrangTua(
            res,
            req.params.id,
            req.orangTua.id,
        );
        if (!anak) return;

        const rujukan = await RujukanModel.findByAnak(req.params.id);
        return success(
            res,
            { anak, rujukan },
            "Riwayat rujukan berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
