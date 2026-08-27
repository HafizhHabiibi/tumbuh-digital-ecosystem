import * as KaderModel from "../models/kaderModel.js";
import * as OrangTuaModel from "../models/orangTuaModel.js";
import * as PuskesmasModel from "../models/puskesmasModel.js";
import {
    LaporanDataError,
    siapkanLaporanIndividualOrangTua,
    siapkanLaporanIndividualTeknis,
    siapkanLaporanRekap,
} from "../services/laporanService.js";
import {
    renderLaporanIndividualOrangTua,
    renderLaporanIndividualTeknis,
    renderLaporanRekapPetugas,
} from "../services/laporanRendererService.js";
import { error } from "../utils/response.js";

const slugNamaFile = (value) => String(value || "laporan")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60) || "laporan";

const kirimPdf = (res, buffer, namaFile) => {
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
        "Content-Disposition",
        `attachment; filename="${slugNamaFile(namaFile)}.pdf"`,
    );
    res.setHeader("Content-Length", buffer.length);
    res.setHeader("Cache-Control", "private, no-store");
    return res.status(200).send(buffer);
};

const ambilProfilDefault = async (user) => {
    if (user.role === "kader") return KaderModel.findByUserId(user.id);
    if (user.role === "puskesmas") return PuskesmasModel.findByUserId(user.id);
    if (user.role === "orang_tua") return OrangTuaModel.findByUserId(user.id);
    return null;
};

export const buatLaporanController = ({
    siapkanOrangTua = siapkanLaporanIndividualOrangTua,
    siapkanTeknis = siapkanLaporanIndividualTeknis,
    siapkanRekap = siapkanLaporanRekap,
    renderOrangTua = renderLaporanIndividualOrangTua,
    renderTeknis = renderLaporanIndividualTeknis,
    renderRekap = renderLaporanRekapPetugas,
    ambilProfil = ambilProfilDefault,
} = {}) => {
    const namaPembuat = async (user) => {
        const profil = await ambilProfil(user);
        return profil?.nama_lengkap || null;
    };

    return {
        downloadIndividual: async (req, res) => {
            try {
                const anakId = req.validatedParams?.anak_id || req.params.anak_id;
                const pembuat = await namaPembuat(req.user);
                if (!pembuat) {
                    return error(res, "Profil pengguna tidak ditemukan", 404);
                }

                const untukOrangTua = req.user.role === "orang_tua";
                const laporan = untukOrangTua
                    ? await siapkanOrangTua(anakId, pembuat)
                    : await siapkanTeknis(anakId, pembuat);
                if (!laporan) {
                    return error(res, "Laporan anak tidak ditemukan", 404);
                }

                const buffer = untukOrangTua
                    ? await renderOrangTua(laporan)
                    : await renderTeknis(laporan);
                const jenis = untukOrangTua ? "ringkasan" : "teknis";
                return kirimPdf(
                    res,
                    buffer,
                    `laporan-${jenis}-${laporan.anak.nama}`,
                );
            } catch (err) {
                if (err instanceof LaporanDataError &&
                    err.kode === "PENGUKURAN_KOSONG") {
                    return error(res, err.message, 422);
                }
                return error(res, err.message, 500);
            }
        },

        downloadRekap: async (req, res) => {
            try {
                const { tanggal_mulai, tanggal_selesai } = req.validatedQuery;
                const pembuat = await namaPembuat(req.user);
                if (!pembuat) {
                    return error(res, "Profil pengguna tidak ditemukan", 404);
                }

                const laporan = await siapkanRekap(
                    tanggal_mulai,
                    tanggal_selesai,
                    pembuat,
                );
                const buffer = await renderRekap(laporan);
                return kirimPdf(
                    res,
                    buffer,
                    `laporan-rekap-${tanggal_mulai}-${tanggal_selesai}`,
                );
            } catch (err) {
                return error(res, err.message, 500);
            }
        },
    };
};

const laporanController = buatLaporanController();

export const downloadLaporanIndividual = laporanController.downloadIndividual;
export const downloadLaporanRekap = laporanController.downloadRekap;
