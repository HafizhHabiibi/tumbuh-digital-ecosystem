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
