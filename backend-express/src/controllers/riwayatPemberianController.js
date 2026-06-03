import * as RiwayatModel from "../models/riwayatPemberianModel.js";
import * as AnakModel from "../models/anakModel.js";
import * as KaderModel from "../models/kaderModel.js";
import { success, error } from "../utils/response.js";

const PILIHAN = {
    vitamin_a: ["Vitamin A Biru 100.000 IU", "Vitamin A Merah 200.000 IU"],
    obat_cacing: ["Albendazole 400mg"],
    pmt: ["Biskuit PMT Balita"],
};

const JENIS_VALID = ["vitamin_a", "obat_cacing", "pmt"];

export const createRiwayat = async (req, res) => {
    try {
        const {
            anak_id,
            jenis,
            nama_item,
            dosis,
            tanggal_pemberian,
            keterangan,
        } = req.body;

        if (!anak_id || !jenis || !nama_item || !tanggal_pemberian) {
            return error(
                res,
                "anak_id, jenis, nama_jenis, tanggal_pemberian wajib diisi",
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

        if (jenis !== "lainnya" && PILIHAN[jenis]) {
            if (!PILIHAN[jenis].includes(nama_item)) {
                return error(
                    res,
                    `nama item tidak valid untuk jenis ${jenis}.` +
                        `Pilihan: ${PILIHAN[jenis].join(", ")}`,
                    400,
                );
            }
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal_pemberian)) {
            return error(res, "format tanggal harus YYYY-MM-DD", 400);
        }

        const anak = await AnakModel.findById(anak_id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        const kader = await KaderModel.findByUserId(req.user.id);
        if (!kader) {
            return error(res, "Data kader tidak ditemukan", 404);
        }

        const id = await RiwayatModel.create({
            anak_id,
            kader_id: kader.id,
            jenis,
            nama_item,
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
                nama_item,
                dosis: dosis || null,
                tanggal_pemberian,
                keterangan: keterangan || null,
            },
            "Riwayat pemberian berhasil dicatat",
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getRiwayatByAnak = async (req, res) => {
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

        const riwayat = await RiwayatModel.findByAnak(anak_id, jenis || null);

        return success(
            res,
            {
                anak,
                filter: jenis || "semua",
                riwayat,
            },
            "Riwayat pemberian berhasil diambil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
