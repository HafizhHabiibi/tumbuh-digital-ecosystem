import * as PengukuranModel from "../models/pengukuranModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as zscoreService from "../services/zscoreService.js";
import * as sawService from "../services/sawService.js";
import * as pengukuranService from "../services/pengukuranService.js";
import * as insightService from "../services/insightService.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";
import { parsePagination, paginationMeta } from "../utils/pagination.js";
import {
    MeasurementValidationError,
    normalizeMeasurement,
} from "../utils/measurement.js";

export const buatCreatePengukuran = ({
    findAnakById = AnakModel.findById,
    findDuplicate = PengukuranModel.findDuplicate,
    savePengukuran = PengukuranModel.createPengukuran,
    hitungZScore = zscoreService.hitungSemuaZScore,
    hitungSAW = sawService.hitungSAW,
    hitungPrioritas = pengukuranService.hitungPrioritasPemantauan,
    sendNotification = fcmService.sendNotification,
    processInsight = insightService.processInsight,
} = {}) => async (req, res) => {
    try {
        const {
            anak_id,
            tanggal_ukur,
            berat_badan,
            tinggi_badan,
            lingkar_kepala,
            lingkar_lengan,
        } = req.body;

        if (
            !anak_id ||
            !tanggal_ukur ||
            berat_badan === undefined ||
            berat_badan === null ||
            tinggi_badan === undefined ||
            tinggi_badan === null
        ) {
            return error(
                res,
                "anak_id, tanggal_ukur, berat_badan, tinggi_badan wajib diisi",
                400,
            );
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal_ukur)) {
            return error(res, "Format tanggal harus YYYY-MM-DD", 400);
        }

        const berat = normalizeMeasurement(berat_badan, {
            min: 0.01,
            max: 30,
            label: "Berat badan",
        });
        const tinggi = normalizeMeasurement(tinggi_badan, {
            min: 0.01,
            max: 120,
            label: "Tinggi badan",
        });
        const lingkarKepala = normalizeMeasurement(lingkar_kepala, {
            required: false,
            min: 1,
            max: 80,
            label: "Lingkar kepala",
        });
        const lingkarLengan = normalizeMeasurement(lingkar_lengan, {
            required: false,
            min: 1,
            max: 60,
            label: "Lingkar lengan",
        });

        const anak = await findAnakById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const duplicate = await findDuplicate(
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
        const zscores = hitungZScore({
            berat_badan: berat,
            tinggi_badan: tinggi,
            tanggal_lahir: anak.tanggal_lahir,
            tanggal_ukur,
            jenis_kelamin: anak.jenis_kelamin,
        });

        const sawResult = hitungSAW({
            zscore_bbu: zscores.zscore_bbu,
            zscore_tbu: zscores.zscore_tbu,
            zscore_bbtb: zscores.zscore_bbtb,
            zscore_imtu: zscores.zscore_imtu,
        });
        const prioritasPemantauan =
            hitungPrioritas(zscores, sawResult);

        // Simpan HANYA raw data ke database (3NF).
        const pengukuran_id = await savePengukuran({
            anak_id,
            kader_id: req.kader.id,
            tanggal_ukur,
            berat_badan: berat,
            tinggi_badan: tinggi,
            lingkar_kepala: lingkarKepala,
            lingkar_lengan: lingkarLengan,
        });

        // Notifikasi ke orang tua bahwa anak sudah diukur
        sendNotification(
            anak.orang_tua_id,
            `Hasil Pengukuran ${anak.nama}`,
            `${anak.nama} telah diukur pada ${tanggal_ukur}. ` +
                `BB: ${berat} kg, TB: ${tinggi} cm. ` +
                `Prioritas pemantauan: ${prioritasPemantauan.kategori}. ` +
                `Cek detail lengkap di aplikasi.`,
            "pengukuran",
            pengukuran_id,
            { anak_id },
        )
            .catch((err) => console.error("[FCM PENGUKURAN]", err.message));

        // Generate AI insight async (fire-and-forget)
        processInsight(pengukuran_id)
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
                lingkar_kepala: lingkarKepala,
                lingkar_lengan: lingkarLengan,
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
        if (
            err instanceof zscoreService.ZScoreValidationError ||
            err instanceof MeasurementValidationError
        ) {
            return error(res, err.message, 400, err.code);
        }
        return error(res, err.message);
    }
};

export const createPengukuran = buatCreatePengukuran();

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
        const query = req.validatedQuery ?? req.query;
        const { page, limit } = parsePagination(query);
        const result = await pengukuranService.getRankingAllAnak({
            page,
            limit,
            search: query.search,
            prioritas: query.prioritas,
        });
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
