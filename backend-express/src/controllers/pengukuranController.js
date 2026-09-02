import * as PengukuranModel from "../models/pengukuranModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as zscoreService from "../services/zscoreService.js";
import * as sawService from "../services/sawService.js";
import * as pengukuranService from "../services/pengukuranService.js";
import * as insightService from "../services/insightService.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";
import { parsePagination, paginationMeta } from "../utils/pagination.js";

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

        const berat = Number(berat_badan);
        const tinggi = Number(tinggi_badan);

        if (!Number.isFinite(berat) || berat <= 0 || berat > 30) {
            return error(
                res,
                "Berat badan tidak valid, harus antara 0-30 kg",
                400,
            );
        }

        if (!Number.isFinite(tinggi) || tinggi <= 0 || tinggi > 120) {
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

        // Validasi domain dan hitung sebelum insert agar data invalid tidak tersimpan.
        const zscores = zscoreService.hitungSemuaZScore({
            berat_badan: berat,
            tinggi_badan: tinggi,
            tanggal_lahir: anak.tanggal_lahir,
            tanggal_ukur,
            jenis_kelamin: anak.jenis_kelamin,
        });

        const sawResult = sawService.hitungSAW({
            zscore_bbu: zscores.zscore_bbu,
            zscore_tbu: zscores.zscore_tbu,
            zscore_bbtb: zscores.zscore_bbtb,
            zscore_imtu: zscores.zscore_imtu,
        });
        const prioritasPemantauan =
            pengukuranService.hitungPrioritasPemantauan(zscores, sawResult);

        // Simpan HANYA raw data ke database (3NF).
        const pengukuran_id = await PengukuranModel.createPengukuran({
            anak_id,
            kader_id: req.kader.id,
            tanggal_ukur,
            berat_badan: berat,
            tinggi_badan: tinggi,
            lingkar_kepala,
            lingkar_lengan,
        });

        // Notifikasi ke orang tua bahwa anak sudah diukur
        fcmService
            .sendNotification(
                anak.orang_tua_id,
                `Hasil Pengukuran ${anak.nama}`,
                `${anak.nama} telah diukur pada ${tanggal_ukur}. ` +
                `BB: ${berat} KG, TB: ${tinggi} CM. ` +
                `Prioritas pemantauan: ${prioritasPemantauan.kategori}. ` +
                `Cek detail lengkap di aplikasi.`,
                "pengukuran",
                pengukuran_id,
                { anak_id },
            )
            .catch((err) => console.error("[FCM PENGUKURAN]", err.message));

        // Generate AI insight async (fire-and-forget)
        insightService
            .processInsight(pengukuran_id)
            .catch((err) => {
                console.error("[GEMINI ASYNC ERROR]", err.message);
            });

        return success(
            res,
            {
                pengukuran_id,
                anak_id,
                tanggal_ukur,
                berat_badan: berat,
                tinggi_badan: tinggi,
                usia_bulan: zscores.usia_bulan,
                usia_hari: zscores.usia_hari,
                nilai_imt: zscores.nilai_imt,
                zscore_bbu: zscores.zscore_bbu,
                zscore_tbu: zscores.zscore_tbu,
                zscore_bbtb: zscores.zscore_bbtb,
                zscore_imtu: zscores.zscore_imtu,
                status_bbu: zscores.status_bbu,
                status_tbu: zscores.status_tbu,
                status_bbtb: zscores.status_bbtb,
                status_imtu: zscores.status_imtu,
                skor_saw: sawResult.skor_akhir,
                kategori_prioritas: sawResult.kategori_prioritas,
                prioritas_pemantauan: prioritasPemantauan,
                detail_saw: sawResult.detail,
                ai_insight_status: "pending",
                ai_insight: "Sedang diproses, tersedia dalam beberapa detik",
            },
            "Pengukuran berhasil disimpan",
            201,
        );
    } catch (err) {
        if (err instanceof zscoreService.ZScoreValidationError) {
            return error(res, err.message, 400);
        }
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

        const rawRiwayat = await PengukuranModel.findByAnak(anak_id);
        const riwayat = pengukuranService.enrichPengukuranList(rawRiwayat, anak);

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

export const buatGetDetailPengukuran = ({
    findPengukuranById = PengukuranModel.findById,
    enrichPengukuran = pengukuranService.enrichPengukuranDenganPrioritas,
} = {}) => async (req, res) => {
    try {
        const { id } = req.params;

        const raw = await findPengukuranById(id);
        if (!raw) {
            return error(res, "Data pengukuran tidak ditemukan", 404);
        }

        const enriched = enrichPengukuran(raw, {
            tanggal_lahir: raw.tanggal_lahir,
            jenis_kelamin: raw.jenis_kelamin,
        });

        return success(res, enriched, "Detail pengukuran berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailPengukuran = buatGetDetailPengukuran();

export const getRankingAnak = async (req, res) => {
    try {
        const { page, limit } = parsePagination(req.query);
        const result = await pengukuranService.getRankingAllAnak(page, limit);
        return success(res, {
            items: result.items,
            pagination: paginationMeta(page, limit, result.total),
        }, "Ranking anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const buatGetDetailSAW = ({
    getDetailSAW = pengukuranService.getDetailSAW,
} = {}) => async (req, res) => {
    try {
        const { id } = req.params;

        const detail = await getDetailSAW(id);
        if (!detail) {
            return error(res, "Data SAW tidak ditemukan", 404);
        }
        return success(res, detail, "Detail SAW berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailSAW = buatGetDetailSAW();

export const getInsight = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await insightService.getInsightForOrangTua(
            id,
            req.orangTua.id,
        );
        if (!result) {
            return error(res, "Data pengukuran tidak ditemukan", 404);
        }

        if (result.insight_status === "failed") {
            return success(
                res,
                { insight_status: "failed", insight_teks: null },
                "Insight belum dapat tersedia saat ini",
            );
        }

        if (result.insight_status === "superseded") {
            return success(
                res,
                { insight_status: "superseded", insight_teks: null },
                "Insight tidak dibuat untuk pengukuran historis ini",
            );
        }

        if (!result.insight_teks) {
            return success(
                res,
                {
                    insight_status: result.insight_status,
                    insight_teks: null,
                },
                "Insight sedang diproses",
            );
        }

        return success(res, result, "Insight berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};
