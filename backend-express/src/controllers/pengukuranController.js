import * as PengukuranModel from "../models/pengukuranModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as zscoreService from "../services/zscoreService.js";
import * as sawService from "../services/sawService.js";
import * as pengukuranService from "../services/pengukuranService.js";
import * as geminiService from "../services/geminiService.js";
import * as fcmService from "../services/fcmService.js";
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

        // Hitung SAW on-the-fly untuk response
        const previous = await PengukuranModel.findPrevious(anak_id, tanggal_ukur);
        const tren_bb = previous
            ? sawService.hitungTrenBBPerBulan(
                berat,
                previous.berat_badan,
                tanggal_ukur,
                previous.tanggal_ukur,
            )
            : null;

        const sawResult = sawService.hitungSAW(
            { zscore_bbu: zscores.zscore_bbu, zscore_tbu: zscores.zscore_tbu, zscore_bbtb: zscores.zscore_bbtb },
            tren_bb,
        );

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
        const STATUS_LABEL = {
            buruk: "gizi buruk",
            kurang: "gizi kurang",
            normal: "gizi normal",
            lebih: "gizi lebih",
            obesitas: "obesitas",
        };
        const statusLabel = STATUS_LABEL[zscores.status_gizi] || zscores.status_gizi;

        fcmService
            .sendNotification(
                anak.orang_tua_id,
                `Hasil Pengukuran ${anak.nama}`,
                `${anak.nama} telah diukur pada ${tanggal_ukur}. ` +
                `BB: ${berat}kg, TB: ${tinggi}cm. ` +
                `Status gizi: ${statusLabel}. ` +
                `Cek detail lengkap di aplikasi.`,
                "pengukuran",
                pengukuran_id,
            )
            .catch((err) => console.error("[FCM PENGUKURAN]", err.message));

        // Generate AI insight async (fire-and-forget)
        geminiService
            .generateInsight(anak_id, pengukuran_id, {
                jenis_kelamin: anak.jenis_kelamin,
                usia_bulan: zscores.usia_bulan,
                berat_badan: berat,
                tinggi_badan: tinggi,
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
                berat_badan: berat,
                tinggi_badan: tinggi,
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

export const getDetailPengukuran = async (req, res) => {
    try {
        const { id } = req.params;

        const raw = await PengukuranModel.findById(id);
        if (!raw) {
            return error(res, "Data pengukuran tidak ditemukan", 404);
        }

        const enriched = pengukuranService.enrichPengukuran(raw, {
            tanggal_lahir: raw.tanggal_lahir,
            jenis_kelamin: raw.jenis_kelamin,
        });

        return success(res, enriched, "Detail pengukuran berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRankingAnak = async (req, res) => {
    try {
        const ranking = await pengukuranService.getRankingAllAnak();
        return success(res, ranking, "Ranking anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailSAW = async (req, res) => {
    try {
        const { id } = req.params;

        const detail = await pengukuranService.getDetailSAW(id);
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

        const result = await geminiService.getInsightForOrangTua(
            id,
            req.orangTua.id,
        );
        if (!result) {
            return error(res, "Data pengukuran tidak ditemukan", 404);
        }

        if (!result.insight_teks) {
            return success(
                res,
                null,
                "Insight belum tersedia, silahkan coba dalam beberapa waktu kedepan",
            );
        }

        return success(res, result, "Insight berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};
