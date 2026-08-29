import * as RujukanModel from "../models/rujukanModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as PuskesmasModel from "../models/puskesmasModel.js";
import * as PengukuranModel from "../models/pengukuranModel.js";
import * as pengukuranService from "../services/pengukuranService.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";
import { parsePagination, paginationMeta } from "../utils/pagination.js";

const STATUS_VALID = ["ditangani", "selesai"];

const enrichRujukan = (rujukan, anak = rujukan) => {
    const pengukuran = pengukuranService.enrichPengukuranDenganPrioritas(
        rujukan,
        anak,
    );

    return {
        ...rujukan,
        berat_badan: pengukuran.berat_badan,
        tinggi_badan: pengukuran.tinggi_badan,
        skor_saw: pengukuran.skor_saw,
        kategori_prioritas: pengukuran.kategori_prioritas,
        status_bbu: pengukuran.status_bbu,
        status_tbu: pengukuran.status_tbu,
        status_bbtb: pengukuran.status_bbtb,
        status_imtu: pengukuran.status_imtu,
    };
};

export const createRujukan = async (req, res) => {
    try {
        const { anak_id, pengukuran_id, catatan_kader } = req.body;

        if (!anak_id || !pengukuran_id || !catatan_kader) {
            return error(
                res,
                "anak_id, pengukuran_id, catatan_kader wajib diisi",
                400,
            );
        }
        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const rujukanAktif = await RujukanModel.findAktifByAnak(anak_id);
        if (rujukanAktif) {
            return error(
                res,
                "Anak ini masih memiliki rujukan aktif yang belum selesai",
                409,
            );
        }

        const pengukuran = await PengukuranModel.findById(pengukuran_id);
        if (!pengukuran) {
            return error(res, "Data pengukuran tidak ditemukan", 404);
        }

        if (pengukuran.anak_id !== anak_id) {
            return error(res, "Pengukuran tidak sesuai dengan data anak yang dirujuk", 400);
        }

        // Prioritas SAW dilampirkan sebagai informasi, bukan penentu kelayakan
        // rujukan. Keputusan rujukan tetap dapat dibuat berdasarkan penilaian
        // kader atau tenaga kesehatan.
        const pengukuranEnriched =
            pengukuranService.enrichPengukuranDenganPrioritas(
                pengukuran,
                anak,
            );

        const id = await RujukanModel.create({
            anak_id,
            kader_id: req.kader.id,
            pengukuran_id,
            catatan_kader,
        });
        if (!id) {
            return error(
                res,
                "Anak ini masih memiliki rujukan aktif yang belum selesai",
                409,
            );
        }

        fcmService
            .sendNotification(
                anak.orang_tua_id,
                "Anak Anda Dirujuk ke Puskesmas",
                `${anak.nama} telah dirujuk ke puskesmas. ` +
                "Silahkan datang pada jam kerja untuk pemeriksaan lebih lanjut.",
                "rujukan",
                id,
                { anak_id },
            )
            .catch((err) => console.error("FCM", err.message));

        return success(
            res,
            {
                id,
                anak_id,
                pengukuran_id,
                status: "diajukan",
                catatan_kader,
                skor_saw: pengukuranEnriched.skor_saw,
                kategori_prioritas: pengukuranEnriched.kategori_prioritas,
                status_bbu: pengukuranEnriched.status_bbu,
                status_tbu: pengukuranEnriched.status_tbu,
                status_bbtb: pengukuranEnriched.status_bbtb,
                status_imtu: pengukuranEnriched.status_imtu,
            },
            "Rujukan berhasil diajukan",
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAllRujukan = async (req, res) => {
    try {
        const { page, limit } = parsePagination(req.query);
        const result = await RujukanModel.findAll(page, limit);
        return success(res, {
            items: result.items.map((rujukan) => enrichRujukan(rujukan)),
            pagination: paginationMeta(page, limit, result.total),
        }, "Daftar rujukan berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailRujukan = async (req, res) => {
    try {
        const { id } = req.params;

        const rujukan = await RujukanModel.findById(id);
        if (!rujukan) {
            return error(res, "Rujukan tidak ditemukan", 404);
        }

        return success(
            res,
            enrichRujukan(rujukan),
            "Detail rujukan berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const updateStatusRujukan = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, catatan_puskesmas } = req.body;

        if (!status) {
            return error(res, "Status wajib diisi", 400);
        }

        if (!STATUS_VALID.includes(status)) {
            return error(
                res,
                `Status tidak valid. Pilihan:  ${STATUS_VALID.join(", ")}`,
                400,
            );
        }

        const rujukan = await RujukanModel.findById(id);
        if (!rujukan) {
            return error(res, "Rujukan tidak ditemukan", 404);
        }

        if (rujukan.status === "selesai") {
            return error(
                res,
                "Rujukan yang sudah selesai tidak bisa diupdate",
                400,
            );
        }

        const puskesmas = await PuskesmasModel.findByUserId(req.user.id);
        const puskesmas_id = puskesmas?.id;

        await RujukanModel.updateStatus(id, {
            status,
            catatan_puskesmas,
            puskesmas_id,
        });

        // anak_id didapat dari rujukan (via pengukuran JOIN)
        const anak = await AnakModel.findById(rujukan.anak_id);
        const pesanStatus = {
            ditangani: "Rujukan anak Anda sedang ditangani oleh puskesmas. Silakan datang untuk pemeriksaan.",
            selesai: "Penanganan rujukan anak Anda telah selesai. Silahkan cek hasil di puskesmas.",
        };

        fcmService
            .sendNotification(
                anak.orang_tua_id,
                "Update Status Rujukan",
                pesanStatus[status] || `Status rujukan diupdate: ${status}`,
                "rujukan",
                parseInt(id),
                { anak_id: rujukan.anak_id },
            )
            .catch((err) => console.error("FCM", err.message));

        return success(
            res,
            {
                id: parseInt(id),
                status,
                catatan_puskesmas: catatan_puskesmas || null,
                ditangani_oleh: puskesmas?.nama_lengkap || null,
            },
            "Status rujukan berhasil diupdate",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRujukanByAnak = async (req, res) => {
    try {
        const { anak_id } = req.params;

        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const rujukan = (await RujukanModel.findByAnak(anak_id)).map((item) =>
            enrichRujukan(item, anak),
        );
        return success(
            res,
            {
                anak,
                rujukan,
            },
            "Riwayat rujukan anak berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
