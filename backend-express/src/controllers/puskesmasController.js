import * as AnakModel from "../models/anakModel.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as pengukuranService from "../services/pengukuranService.js";
import { success, error } from "../utils/response.js";

export const getProfile = async (req, res) => {
    try {
        return success(res, req.puskesmas, "Profil puskesmas berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAllAnak = async (req, res) => {
    try {
        const anak = await AnakModel.findAll();
        return success(res, anak, "Daftar anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAnakById = async (req, res) => {
    try {
        const { id } = req.params;
        const anak = await AnakModel.findById(id);

        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        return success(res, anak, "Detail anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getPengukuranAnak = async (req, res) => {
    try {
        const { id } = req.params;
        const anak = await AnakModel.findById(id);

        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const rawRiwayat = await PengukuranModel.findByAnak(id);
        const riwayat = pengukuranService.enrichPengukuranList(rawRiwayat, anak);

        return success(
            res,
            { anak, riwayat },
            "Riwayat pengukuran berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
