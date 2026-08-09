import * as JadwalModel from "../models/jadwalModel.js";
import * as KaderModel from "../models/kaderModel.js";
import * as fcmService from "../services/fcmService.js";
import { success, error } from "../utils/response.js";

export const createJadwal = async (req, res) => {
    try {
        const { tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan } =
            req.body;

        if (!tanggal || !waktu_mulai || !waktu_selesai || !lokasi) {
            return error(
                res,
                "tanggal, waktu_mulai, waktu_selesai, dan lokasi harus diisi",
                400,
            );
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal)) {
            return error(res, "Format tanggal harus YYYY-MM-DD", 400);
        }

        const tglJadwal = new Date(tanggal);
        const hariIni = new Date();
        hariIni.setHours(0, 0, 0, 0);
        if (tglJadwal < hariIni) {
            return error(res, "Tanggal jadwal tidak boleh di masa lampau", 400);
        }

        if (
            !/^\d{2}:\d{2}$/.test(waktu_mulai) ||
            !/^\d{2}:\d{2}$/.test(waktu_selesai)
        ) {
            return error(res, "Format waktu harus HH:MM", 400);
        }

        if (waktu_selesai <= waktu_mulai) {
            return error(res, "waktu selesai harus setelah waktu mulai", 400);
        }

        const kader = await KaderModel.findByUserId(req.user.id);
        if (!kader) {
            return error(res, "Data kader tidak ditemukan", 404);
        }

        const existing = await JadwalModel.findByTanggal(tanggal);
        if (existing) {
            return error(
                res,
                "Sudah ada jadwal posyandu pada tanggal tersebut",
                409,
            );
        }

        const id = await JadwalModel.create({
            kader_id: kader.id,
            tanggal,
            waktu_mulai,
            waktu_selesai,
            lokasi,
            keterangan,
        });

        const semuaOrangTua = await JadwalModel.findAllOrangTua();

        const pesanNotifikasi =
            `Posyandu akan dilaksanakan pada ${tanggal} ` +
            `pukul ${waktu_mulai} - ${waktu_selesai} ` +
            `di ${lokasi}. Harap hadir tepat waktu.`;

        Promise.all(
            semuaOrangTua.map((ot) =>
                fcmService.sendNotification(
                    ot.id,
                    "Jadwal Posyandu Baru",
                    pesanNotifikasi,
                    "jadwal",
                    id,
                ),
            ),
        ).catch((err) => console.error("[FCM JADWAL]", err.message));

        return success(
            res,
            {
                id,
                tanggal,
                waktu_mulai,
                waktu_selesai,
                lokasi,
                keterangan: keterangan || null,
                notifikasi_ke: `${semuaOrangTua.length} orang tua`,
            },
            "Jadwal posyandu berhasil dibuat",
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAllJadwal = async (req, res) => {
    try {
        const jadwal = await JadwalModel.findAll();
        return success(res, jadwal, "Daftar jadwal berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getDetailJadwal = async (req, res) => {
    try {
        const { id } = req.params;

        const jadwal = await JadwalModel.findById(id);
        if (!jadwal) {
            return error(res, "Jadwal tidak ditemukan", 404);
        }

        return success(res, jadwal, "Detail jadwal berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};
