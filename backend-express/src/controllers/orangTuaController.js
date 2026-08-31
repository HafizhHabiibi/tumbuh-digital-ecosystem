import * as AnakModel from "../models/anakModel.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as PemberianModel from "../models/pemberianModel.js";
import * as RujukanModel from "../models/rujukanModel.js";
import * as OrangTuaModel from "../models/orangTuaModel.js";
import * as pengukuranService from "../services/pengukuranService.js";
import { toOrangTuaPengukuran } from "../serializers/orangTuaPengukuranSerializer.js";
import { toOrangTuaRujukan } from "../serializers/orangTuaRujukanSerializer.js";
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

        const rawRiwayat = await PengukuranModel.findByAnak(req.params.id);
        // Enrich raw data dengan z-score dan SAW on-the-fly
        const riwayat = pengukuranService
            .enrichPengukuranList(rawRiwayat, anak)
            .map(toOrangTuaPengukuran);

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
        const pemberian = await PemberianModel.findByAnak(
            req.params.id,
            jenis || null,
        );

        return success(
            res,
            { anak, filter: jenis || "semua", pemberian },
            "Data pemberian berhasil diambil",
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

        const rawRujukan = await RujukanModel.findByAnak(req.params.id);
        const rujukan = rawRujukan.map(toOrangTuaRujukan);
        return success(
            res,
            { anak, rujukan },
            "Riwayat rujukan berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const updateFcmToken = async (req, res) => {
    try {
        const { fcm_token } = req.body;
        if (!fcm_token || typeof fcm_token !== "string") {
            return error(res, "fcm_token wajib diisi", 400);
        }
        await OrangTuaModel.updateFcmToken(req.orangTua.user_id, fcm_token);
        return success(res, null, "FCM token berhasil diperbarui");
    } catch (err) {
        return error(res, err.message);
    }
};
