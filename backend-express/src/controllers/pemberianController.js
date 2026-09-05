import * as PemberianModel from "../models/pemberianModel.js";
import * as AnakModel from "../models/anakModel.js";
import { success, error } from "../utils/response.js";

const JENIS_VALID = [
    "vitamin_a_merah",
    "vitamin_a_biru",
    "obat_cacing",
    "pmt_biskuit",
    "pmt_susu",
    "pmt_lainnya",
];

const toCalendarDateText = (value) => {
    if (typeof value === "string") return value.slice(0, 10);
    if (!(value instanceof Date) || Number.isNaN(value.getTime())) return "";
    const year = value.getFullYear();
    const month = String(value.getMonth() + 1).padStart(2, "0");
    const day = String(value.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
};

export const isTanggalPemberianSebelumLahir = (
    tanggalLahir,
    tanggalPemberian,
) => {
    const lahir = toCalendarDateText(tanggalLahir);
    const pemberian = toCalendarDateText(tanggalPemberian);
    return Boolean(lahir && pemberian && pemberian < lahir);
};

export const create = async (req, res) => {
    try {
        const {
            anak_id,
            jenis,
            dosis,
            tanggal_pemberian,
            keterangan,
        } = req.body;

        if (!anak_id || !jenis || !tanggal_pemberian) {
            return error(
                res,
                "anak_id, jenis, tanggal_pemberian wajib diisi",
                400,
            );
        }

        if (!JENIS_VALID.includes(jenis)) {
            return error(
                res,
                `Jenis tidak valid. Pilihan: ${JENIS_VALID.join(", ")}`,
                400,
            );
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal_pemberian)) {
            return error(res, "format tanggal harus YYYY-MM-DD", 400);
        }

        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        if (
            isTanggalPemberianSebelumLahir(
                anak.tanggal_lahir,
                tanggal_pemberian,
            )
        ) {
            return error(
                res,
                "Tanggal pemberian tidak boleh sebelum tanggal lahir anak",
                400,
            );
        }

        const duplicate = await PemberianModel.findDuplicate(
            anak_id,
            jenis,
            tanggal_pemberian,
        );
        if (duplicate) {
            return error(
                res,
                "Pemberian jenis ini untuk anak dan tanggal tersebut sudah tercatat",
                409,
            );
        }

        const id = await PemberianModel.create({
            anak_id,
            kader_id: req.kader.id,
            jenis,
            dosis,
            tanggal_pemberian,
            keterangan,
        });

        return success(
            res,
            {
                id,
                anak_id,
                jenis,
                dosis: dosis || null,
                tanggal_pemberian,
                keterangan: keterangan || null,
            },
            "Pemberian berhasil dicatat",
            201,
        );
    } catch (err) {
        if (err?.code === "ER_DUP_ENTRY") {
            return error(
                res,
                "Pemberian jenis ini untuk anak dan tanggal tersebut sudah tercatat",
                409,
            );
        }
        return error(res, err.message);
    }
};

export const getByAnak = async (req, res) => {
    try {
        const { anak_id } = req.params;
        const { jenis } = req.query;

        if (jenis && !JENIS_VALID.includes(jenis)) {
            return error(
                res,
                `Jenis filter tidak valid. Pilihan: ${JENIS_VALID.join(", ")}`,
                400,
            );
        }

        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const pemberian = await PemberianModel.findByAnak(anak_id, jenis || null);

        return success(
            res,
            {
                anak,
                filter: jenis || "semua",
                pemberian,
            },
            "Data pemberian berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
