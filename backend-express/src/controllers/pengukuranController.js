import * as PengukuranModel from "../models/pengukuranModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as KaderModel from "../models/kaderModel.js";
import * as zscoreService from "../services/zscoreService.js";
import * as sawService from "../services/sawService.js";
import * as geminiService from "../services/geminiService.js";
import { success, error } from "../utils/response.js";

export const createPengukuran = async (req, res) => {
    try {
        const {
            anak_id,
            tanggal_ukur,
            berat_badan,
            tinggi_badan,
            lingkar_kepala,
            lingkar_lengan,
        } = req.body;

        if (!anak_id || !tanggal_ukur || !berat_badan || !tinggi_badan) {
            return error(
                res,
                "anak_id, tanggal_ukur, berat_badan, tinggi_badan wajib diisi",
                400,
            );
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal_ukur)) {
            return error(res, "Format tanggal harus YYYY-MM-DD", 400);
        }

        if (berat_badan <= 0 || berat_badan > 30) {
            return error(
                res,
                "Berat badan tidak valid, harus antara 0-30 kg",
                400,
            );
        }

        if (tinggi_badan <= 0 || tinggi_badan > 120) {
            return error(
                res,
                "Tinggi badan tidak valid, harus antara 0-120 cm",
                400,
            );
        }

        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const duplicate = await PengukuranModel.findDuplicate(
            anak_id,
            tanggal_ukur,
        );
        if (duplicate) {
            return error(
                res,
                "Pengukuran untuk anak dan tanggal tersebut sudah ada",
                409,
            );
        }

        const kader = await KaderModel.findByUserId(req.user.id);
        if (!kader) {
            return error(res, "Data kader tidak ditemukan", 404);
        }

        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan,
            tinggi_badan,
            tanggal_lahir: anak.tanggal_lahir,
            tanggal_ukur,
            jenis_kelamin: anak.jenis_kelamin,
        });

        const pengukuran_id = await PengukuranModel.createPengukuran({
            anak_id,
            kader_id: kader.id,
            tanggal_ukur,
            berat_badan,
            tinggi_badan,
            lingkar_kepala,
            lingkar_lengan,
            zscore_bbu: zscores.zscore_bbu,
            zscore_tbu: zscores.zscore_tbu,
            zscore_bbtb: zscores.zscore_bbtb,
            status_gizi: zscores.status_gizi,
        });

        const sawResult = await sawService.hitungSAW(
            anak_id,
            pengukuran_id,
            zscores,
        );

        geminiService
            .generateInsight(anak_id, pengukuran_id, {
                jenis_kelamin: anak.jenis_kelamin,
                usia_bulan: zscores.usia_bulan,
                berat_badan,
                tinggi_badan,
                zscore_bbu: zscores.zscore_bbu,
                zscore_tbu: zscores.zscore_tbu,
                zscore_bbtb: zscores.zscore_bbtb,
                status_bbu: zscores.status_bbu,
                status_tbu: zscores.status_tbu,
                status_bbtb: zscores.status_bbtb,
                status_gizi: zscores.status_gizi,
                kategori_risiko: sawResult.kategori_risiko,
            })
            .catch((err) => {
                console.error("[GEMINI ASYNC ERROR]", err.message);
            });

        return success(
            res,
            {
                pengukuran_id,
                anak_id,
                tanggal_ukur,
                berat_badan,
                tinggi_badan,
                usia_bulan: zscores.usia_bulan,
                zscore_bbu: zscores.zscore_bbu,
                zscore_tbu: zscores.zscore_tbu,
                zscore_bbtb: zscores.zscore_bbtb,
                status_bbu: zscores.status_bbu,
                status_tbu: zscores.status_tbu,
                status_bbtb: zscores.status_bbtb,
                status_gizi: zscores.status_gizi,
                skor_saw: sawResult.skor_akhir,
                kategori_risiko: sawResult.kategori_risiko,
                detail_saw: sawResult.detail,
                ai_insight: "Sedang diproses, tersedia dalam beberapa detik",
            },
            "Pengukuran berhasil disimpan",
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRiwayatPengukuran = async (req, res) => {
    try {
        const { anak_id } = req.params;

        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const riwayat = await PengukuranModel.findByAnak(anak_id);

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

export const getDetailPengukuran = async (req, res) => {
    try {
        const { id } = req.params;

        const pengukuran = await PengukuranModel.findById(id);
        if (!pengukuran) {
            return error(res, "Data pengukuran tidak ditemukan", 404);
        }

        return success(res, pengukuran, "Detail pengukuran berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRankingAnak = async (req, res) => {
    try {
        const ranking = await sawService.getRankingSAW();
        return success(res, ranking, "Ranking anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailSAW = async (req, res) => {
    try {
        const { id } = req.params;

        const detail = await sawService.getDetailSAW(id);
        if (!detail) {
            return error(res, "Data SAW tidak ditemukan", 404);
        }
        return success(res, detail, "Detail SAW berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getInsight = async (req, res) => {
    try {
        const { id } = req.params;

        const insight = await geminiService.getInsight(id);
        if (!insight) {
            return success(
                res,
                null,
                "Insight belum tersedia, silahkan coba dalam beberapa waktu kedepan",
            );
        }

        return success(res, insight, "Insight berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};
