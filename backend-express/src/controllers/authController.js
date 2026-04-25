import bcrypt from "bcrypt";
import * as UserModel from "../models/userModel.js";
import * as PasswordResetModel from "../models/passwordResetMode.js";
import * as mailerService from "../services/mailerService.js";
import { generateToken } from "../utils/jwt.js";
import { success, error } from "../utils/response.js";
import db from "../database/connection.js";

export const login = async (req, res) => {
    try {
        const { email, password, fcm_token } = req.body;

        if (!email || !password) {
            return error(res, "Email dan password wajib diisi", 400);
        }

        const user = await UserModel.findByEmail(email);
        if (!user) {
            return error(res, "Email atau password salah", 400);
        }

        const passwordMatch = await bcrypt.compare(
            password,
            user.password_hash,
        );
        if (!passwordMatch) {
            return error(res, "Email atau password salah", 400);
        }

        const token = generateToken({
            id: user.id,
            role: user.role,
        });

        let profil = null;

        if (user.role === "kader") {
            const [rows] = await db.query(
                `SELECT * FROM kader WHERE user_id = ?`,
                [user.id],
            );
            profil = rows[0];
        } else if (user.role === "puskesmas") {
            const [rows] = await db.query(
                `SELECT * FROM puskesmas_user WHERE user_id = ?`,
                [user.id],
            );
            profil = rows[0];
        } else if (user.role === "orang_tua") {
            if (fcm_token) {
                await db.query(
                    `UPDATE orang_tua SET fcm_token = ? WHERE user_id = ?`,
                    [fcm_token, user.id],
                );
            }
            const [rows] = await db.query(
                `SELECT * FROM orang_tua WHERE user_id =?`,
                [user.id],
            );
            profil = rows[0];
        }

        return success(
            res,
            {
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    role: user.role,
                    profil,
                },
            },
            "Login berhasil",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const changePassword = async (req, res) => {
    try {
        const { password_lama, password_baru } = req.body;
        const userId = req.user.id; // Dari middleware auth

        if (!password_lama || !password_baru) {
            return error(res, "Password lama dan baru wajib diisi", 400);
        }

        if (password_baru.length < 6) {
            return error(res, "Password baru minimal 6 karakter", 400);
        }

        const user = await UserModel.findById(userId);

        const passwordMatch = await bcrypt.compare(
            password_lama,
            user.password_hash,
        );
        if (!passwordMatch) {
            return error(res, "Password lama tidak sesuai", 401);
        }

        const hash = await bcrypt.hash(password_baru, 10);
        await UserModel.updatePassword(userId, hash);

        return success(res, null, "Password berhasil diubah");
    } catch (err) {
        return error(res, err.message);
    }
};

export const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return error(res, "Email wajib diisi", 400);
        }

        const user = await UserModel.findByEmail(email);

        if (!user) {
            return success(
                res,
                null,
                "Jika email terdaftar, link reset password akan dikirimkan",
            );
        }

        const token = await PasswordResetModel.create(user.id);
        await mailerService.kirimEmailResetPassword(user.email, token);

        return success(
            res,
            null,
            "Jika email terdaftar, link reset password akan dirikimkan",
        );
    } catch (err) {
        return error(res, err.message);
    }
};

export const resetPassword = async (req, res) => {
    try {
        const { token, password_baru } = req.body;

        if (!token || !password_baru) {
            return error(res, "Token dan password baru wajib diisi", 400);
        }

        if (password_baru.length < 6) {
            return error(res, "Password baru minimal 6 karakter", 400);
        }

        const resetData = await PasswordResetModel.findValidToken(token);
        if (!resetData) {
            return error(
                res,
                "Link reset tidak valid atau sudah kadaluarsa, silahkan lakukan reques ulang",
                400,
            );
        }

        const hash = await bcrypt.hash(password_baru, 10);

        await UserModel.updatePassword(resetData.user_id, hash);
        await UserModel.updateResetPasswordAt(resetData.user_id);
        await PasswordResetModel.markAsUsed(token);

        return success(
            res,
            null,
            "Password berhasil direset, silahkan login ulang dengan password yang baru",
        );
    } catch (err) {
        return error(res, err.message);
    }
};
