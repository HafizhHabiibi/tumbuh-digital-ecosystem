import * as RujukanModel from "../models/rujukanModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as PuskesmasModel from "../models/puskesmasModel.js";
import * as sawService from "../services/sawService.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";

const STATUS_VALID = ["diterima", "dalam_penanganan", "selesai", "ditolak"];

export const createRujukan = async (req, res) => {
    try {
        const { anak_id, saw_result_id, catatan_kader } = req.body;

        if (!anak_id || !saw_result_id || !catatan_kader) {
            return error(
                res,
                "anak_id, saw_result_id, catatan_kader wajib diisi",
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

        const sawDetail = await sawService.getDetailSAW(saw_result_id);
        if (!sawDetail) {
            return error(res, "Data SAW tidak ditemukan", 404);
        }

        if (sawDetail.kategori_risiko === "rendah") {
            return error(
                res,
                "Rujukan hanya bisa diajukan untuk anak dengan risiko sedang atau tinggi",
                400,
            );
        }
        const id = await RujukanModel.create({
            anak_id,
            kader_id: req.kader.id,
            saw_result_id,
            catatan_kader,
        });

        fcmService
            .sendNotification(
                anak.orang_tua_id,
                "Anak Anda Dirujuk ke Puskesmas",
                `${anak.nama} telah dirujuk ke puskesmas. ` +
                "Silahkan datang pada jam kerja untuk pemeriksaan lebih lanjut.",
                "rujukan",
                id,
            )
            .catch((err) => console.error("FCM", err.message));

        return success(
            res,
            {
                id,
                anak_id,
                saw_result_id,
                status: "diajukan",
                catatan_kader,
                kategori_risiko: sawDetail.kategori_risiko,
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
        const rujukan = await RujukanModel.findAll();
        return success(res, rujukan, "Daftar rujukan berhasil diambil");
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

        return success(res, rujukan, "Detail rujukan berhasil diambil");
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

        if (rujukan.status === "selesai" || rujukan.status === "ditolak") {
            return error(
                res,
                "Rujukan yang sudah selesai atau ditolak tidak bisa diupdate",
                400,
            );
        }

        const puskesmas = await PuskesmasModel.findByUserId(req.user.id);
        // console.log("[DEBUG] req.user.id:", req.user.id);
        // console.log("[DEBUG] puskesmas:", puskesmas);
        const puskesmas_user_id = puskesmas?.id;

        await RujukanModel.updateStatus(id, {
            status,
            catatan_puskesmas,
            puskesmas_user_id,
        });

        const anak = await AnakModel.findById(rujukan.anak_id);
        const pesanStatus = {
            diterima: "Rujukan anak Anda telah diterima oleh puskesmas.",
            dalam_penanganan:
                "Rujukan anak Anda sedang dalam penanganan di puskesmas.",
            selesai:
                "Rujukan anak Anda telah selesai. Silahkan cek hasil pemeriksaan di puskesmas.",
            ditolak:
                "Rujukan anak Anda tidak dapat diproses oleh puskesmas. Silahkan konsultasi kembali dengan kader untuk langkah selanjutnya.",
        };

        fcmService
            .sendNotification(
                anak.orang_tua_id,
                "Update Status Rujukan",
                pesanStatus[status] || `Status rujukan diupdate: ${status}`,
                "rujukan",
                parseInt(id),
            )
            .catch((err) => console.error("FCM", err.message));

        return success(
            res,
            {
                id: parseInt(id),
                status,
                catatan_puskesmas: catatan_puskesmas || null,
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

        const rujukan = await RujukanModel.findByAnak(anak_id);
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
