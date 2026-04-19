import bcrypt from 'bcrypt';
import * as KaderModel from '../models/kaderModel.js';
import * as OrangTuaModel from '../models/orangTuaModel.js';
import { success, error } from '../utils/response.js';

export const getProfile = async (req, res) => {
    try {
        const profile = await KaderModel.findByUserId(req.user.id)
        if (!profile) {
            return error(res, 'Profil kader tidak ditemukan', 404)
        }
        return success(res, profile, 'Profil kader berhasil diambil')
    } catch (err) {
        return error(res, err.message)
    }
}

export const createOrangTua = async (req, res) => {
    try {
        const { nama_lengkap, email, password, no_hp, alamat, nik} = req.body

        if (!nama_lengkap || !email || !password || !no_hp || !alamat || !nik) {
            return error(res, 'Semua field wajib diisi', 400)
        }

        if (!/^\d{16}$/.test(nik)) {
            return error(res, 'NIK harus terdiri dari 16 digit angka', 400)
        }

        if (password.length < 6) {
            return error(res, 'Password harus berisi minimal 6 karakter', 400)
        }

        const emailExists = await OrangTuaModel.findByEmail(email)
        if (emailExists) {
            return error(res, 'Email ini sudah terdaftar', 409)
        }

        const nikExists = await OrangTuaModel.findByNik(nik)
        if (nikExists) {
            return error(res, 'Nik ini sudah terdaftar', 409)
        }

        const kader = await KaderModel.findByUserId(req.user.id)

        const password_hash = await bcrypt.hash(password, 10)

        const orangTua = await OrangTuaModel.create(
            { nama_lengkap, email, password_hash, no_hp, alamat, nik }, kader.id
        )

        return success(res, {
            id: orangTua.id,
            nama_lengkap,
            email,
            alamat,
            nik
        }, 'Akun orang tua berhasil dibuat', 200)

    } catch (err) {
        return error(res, err.message)
    }
}

export const getOrangTua = async (req, res) => {
    try {
        const daftar = await OrangTuaModel.findAll()
        return success(res, daftar, 'Daftar orang tua berhasil diambil')
    } catch (err) {
        return error(res, err.message)
    }
}

export const getOrangTuaById = async (req, res) => {
    try {
        const { id } = req.params
        const orangTua = await OrangTuaModel.findById(id)

        if (!orangTua) {
            return error(res, 'Orang tua tidak ditemukan', 404)
        }

        return success(res, orangTua, 'Data orang tua berhasil diambil')
    } catch (err) {
        return error(res, err.message)
    }
}