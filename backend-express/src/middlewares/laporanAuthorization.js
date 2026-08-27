import * as laporanModel from "../models/laporanModel.js";
import { error } from "../utils/response.js";

const ROLE_PETUGAS = new Set(["kader", "puskesmas"]);

/**
 * Factory dependency-injection untuk memudahkan pengujian kebijakan akses
 * tanpa membutuhkan database sungguhan.
 */
export const buatOtorisasiLaporan = ({
    cekKepemilikan = laporanModel.isAnakMilikUserOrangTua,
} = {}) => ({
    individual: async (req, res, next) => {
        try {
            if (!req.user) {
                return error(res, "Autentikasi diperlukan", 401);
            }

            if (ROLE_PETUGAS.has(req.user.role)) {
                return next();
            }

            if (req.user.role !== "orang_tua") {
                return error(res, "Akses laporan ditolak", 403);
            }

            const anakId = req.params?.anak_id;
            const milikOrangTua = anakId && await cekKepemilikan(
                anakId,
                req.user.id,
            );

            // Tidak membedakan ID yang tidak ada dengan ID milik akun lain.
            if (!milikOrangTua) {
                return error(res, "Laporan anak tidak ditemukan", 404);
            }

            return next();
        } catch (err) {
            return error(res, err.message, 500);
        }
    },

    rekap: (req, res, next) => {
        if (!req.user) {
            return error(res, "Autentikasi diperlukan", 401);
        }
        if (!ROLE_PETUGAS.has(req.user.role)) {
            return error(res, "Akses laporan rekap ditolak", 403);
        }
        return next();
    },
});

const otorisasiLaporan = buatOtorisasiLaporan();

export const authorizeLaporanIndividual = otorisasiLaporan.individual;
export const authorizeLaporanRekap = otorisasiLaporan.rekap;
