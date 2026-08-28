import bcrypt from "bcrypt";
import * as KaderModel from "../models/kaderModel.js";
import * as OrangTuaModel from "../models/orangTuaModel.js";
import * as AnakModel from "../models/anakModel.js";
import { success, error } from "../utils/response.js";
import { parsePagination, paginationMeta } from "../utils/pagination.js";

export const getProfile = async (req, res) => {
    try {
        const profile = await KaderModel.findByUserId(req.user.id);
        if (!profile) {
            return error(res, "Profil kader tidak ditemukan", 404);
        }
        return success(res, profile, "Profil kader berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const createOrangTua = async (req, res) => {
    try {
        const { nama_lengkap, email, password, no_hp, alamat, nik } = req.body;

        if (!nama_lengkap || !email || !password || !no_hp || !alamat || !nik) {
            return error(res, "Semua field wajib diisi", 400);
        }

        if (!/^\d{16}$/.test(nik)) {
            return error(res, "NIK harus terdiri dari 16 digit angka", 400);
        }

        if (password.length < 6) {
            return error(res, "Password harus berisi minimal 6 karakter", 400);
        }

        const emailExists = await OrangTuaModel.findByEmail(email);
        if (emailExists) {
            return error(res, "Email ini sudah terdaftar", 409);
        }

        const nikExists = await OrangTuaModel.findByNik(nik);
        if (nikExists) {
            return error(res, "Nik ini sudah terdaftar", 409);
        }
        const password_hash = await bcrypt.hash(password, 10);

        const orangTua = await OrangTuaModel.create(
            { nama_lengkap, email, password_hash, no_hp, alamat, nik },
            req.kader.id,
        );

        return success(
            res,
            {
                id: orangTua.id,
                nama_lengkap,
                email,
                alamat,
                nik,
            },
            "Akun orang tua berhasil dibuat",
            201,
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const getOrangTua = async (req, res) => {
    try {
        const { page, limit } = parsePagination(req.query);
        const result = await OrangTuaModel.findAll(page, limit);
        return success(res, {
            items: result.items,
            pagination: paginationMeta(page, limit, result.total),
        }, "Daftar orang tua berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getOrangTuaById = async (req, res) => {
    try {
        const { id } = req.params;
        const orangTua = await OrangTuaModel.findById(id);

        if (!orangTua) {
            return error(res, "Orang tua tidak ditemukan", 404);
        }

        return success(res, orangTua, "Data orang tua berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const createAnak = async (req, res) => {
    try {
        const { orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik } =
            req.body;

        if (
            !orang_tua_id ||
            !nama ||
            !jenis_kelamin ||
            !tanggal_lahir ||
            !nik
        ) {
            return error(res, "Semua field wajib diisi", 400);
        }

        if (!["L", "P"].includes(jenis_kelamin)) {
            return error(res, "Jenis kelamin harus L atau P", 400);
        }

        if (!/^\d{16}$/.test(nik)) {
            return error(res, "NIK harus terdiri dari 16 digit angka", 400);
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal_lahir)) {
            return error(res, "Format tanggal lahir harus YYYY-MM-DD", 400);
        }

        const tglLahir = new Date(tanggal_lahir);
        if (isNaN(tglLahir.getTime()) || tglLahir > new Date()) {
            return error(res, "Tanggal lahir tidak valid atau tidak boleh di masa depan", 400);
        }

        const orangTua = await OrangTuaModel.findById(orang_tua_id);
        if (!orangTua) {
            return error(res, "Orang tua tidak ditemukan", 404);
        }

        const duplicate = await AnakModel.findDuplicate(
            orang_tua_id,
            nama,
            tanggal_lahir,
        );
        if (duplicate) {
            return error(
                res,
                "Anak dengan nama dan tanggal lahir yang sama sudah terdaftar",
                409,
            );
        }

        const anak = await AnakModel.create({
            orang_tua_id,
            nama,
            jenis_kelamin,
            tanggal_lahir,
            nik,
        });

        return success(res, anak, "Data anak berhasil ditambahkan", 201);
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAllAnak = async (req, res) => {
    try {
        const { page, limit } = parsePagination(req.query);
        const result = await AnakModel.findAll(page, limit);
        return success(res, {
            items: result.items,
            pagination: paginationMeta(page, limit, result.total),
        }, "Daftar anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAnakById = async (req, res) => {
    try {
        const { id } = req.params;
        const anak = await AnakModel.findById(id);

        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        return success(res, anak, "Detail anak berhasil diambil");
    } catch (err) {
        return error(res, err.message);
    }
};

export const getAnakByOrangTua = async (req, res) => {
    try {
        const { id } = req.params;

        const orangTua = await OrangTuaModel.findById(id);
        if (!orangTua) {
            return error(res, "Orang tua tidak ditemukan", 404);
        }

        const anak = await AnakModel.findByOrangTua(id);
        return success(
            res,
            {
                orang_tua: orangTua,
                anak: anak,
            },
            "Data anak berhasil diambil berdasarkan orang tua",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const updateOrangTua = async (req, res) => {
    try {
        const { id } = req.params;
        const { nama_lengkap, no_hp, alamat, nik } = req.body;

        if (!nama_lengkap || !no_hp || !alamat || !nik) {
            return error(
                res,
                "nama_lengkap, no_hp, alamat, dan nik wajib diisi",
                400,
            );
        }

        if (!/^\d{16}$/.test(nik)) {
            return error(res, "NIK harus terdiri dari 16 digit angka", 400);
        }

        const orangTua = await OrangTuaModel.findById(id);
        if (!orangTua) {
            return error(res, "Orang tua tidak ditemukan", 404);
        }

        // Cek NIK unik (exclude orang tua ini sendiri)
        const nikExists = await OrangTuaModel.findByNikExcluding(nik, id);
        if (nikExists) {
            return error(res, "NIK ini sudah digunakan oleh orang tua lain", 409);
        }

        await OrangTuaModel.update(id, { nama_lengkap, no_hp, alamat, nik });

        return success(
            res,
            { id, nama_lengkap, no_hp, alamat, nik },
            "Data orang tua berhasil diperbarui",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const updateAnak = async (req, res) => {
    try {
        const { id } = req.params;
        const { nama, jenis_kelamin, tanggal_lahir, nik } = req.body;

        if (!nama || !jenis_kelamin || !tanggal_lahir) {
            return error(
                res,
                "nama, jenis_kelamin, dan tanggal_lahir wajib diisi",
                400,
            );
        }

        if (!["L", "P"].includes(jenis_kelamin)) {
            return error(res, "Jenis kelamin harus L atau P", 400);
        }

        if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggal_lahir)) {
            return error(res, "Format tanggal lahir harus YYYY-MM-DD", 400);
        }

        const tglLahir = new Date(tanggal_lahir);
        if (isNaN(tglLahir.getTime()) || tglLahir > new Date()) {
            return error(
                res,
                "Tanggal lahir tidak valid atau tidak boleh di masa depan",
                400,
            );
        }

        if (nik && !/^\d{16}$/.test(nik)) {
            return error(res, "NIK harus terdiri dari 16 digit angka", 400);
        }

        const anak = await AnakModel.findById(id);
        if (!anak) {
            return error(res, "Data anak tidak ditemukan", 404);
        }

        await AnakModel.update(id, {
            nama,
            jenis_kelamin,
            tanggal_lahir,
            nik: nik || null,
        });

        return success(
            res,
            { id, nama, jenis_kelamin, tanggal_lahir, nik: nik || null },
            "Data anak berhasil diperbarui",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const buatDeleteDataMasterHandlers = ({
    deleteOrangTuaModel = OrangTuaModel.deleteIfNoChildren,
    deleteAnakModel = AnakModel.deleteIfEmpty,
} = {}) => ({
    deleteOrangTua: async (req, res) => {
        try {
            const result = await deleteOrangTuaModel(req.params.id);
            if (result.status === "not_found") {
                return error(res, "Orang tua tidak ditemukan", 404);
            }
            if (result.status === "conflict") {
                return error(
                    res,
                    `Orang tua tidak dapat dihapus karena masih memiliki ${result.total_anak} anak`,
                    409,
                );
            }
            return success(res, null, "Data dan akun orang tua berhasil dihapus");
        } catch (err) {
            return error(res, err.message);
        }
    },

    deleteAnak: async (req, res) => {
        try {
            const result = await deleteAnakModel(req.params.id);
            if (result.status === "not_found") {
                return error(res, "Data anak tidak ditemukan", 404);
            }
            if (result.status === "conflict") {
                return error(
                    res,
                    "Data anak tidak dapat dihapus karena sudah memiliki riwayat pengukuran atau pemberian",
                    409,
                );
            }
            return success(res, null, "Data anak berhasil dihapus");
        } catch (err) {
            return error(res, err.message);
        }
    },
});

const deleteDataMasterHandlers = buatDeleteDataMasterHandlers();
export const deleteOrangTua = deleteDataMasterHandlers.deleteOrangTua;
export const deleteAnak = deleteDataMasterHandlers.deleteAnak;
