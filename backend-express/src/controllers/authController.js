import bcrypt from "bcrypt";
import * as UserModel from "../models/userModel.js";
import * as PasswordResetModel from "../models/passwordResetModel.js";
import * as LoginAttemptModel from "../models/loginAttemptModel.js";
import * as RefreshTokenModel from "../models/refreshTokenModel.js";
import * as KaderModel from "../models/kaderModel.js";
import * as PuskesmasModel from "../models/puskesmasModel.js";
import * as OrangTuaModel from "../models/orangTuaModel.js";
import * as mailerService from "../services/mailerService.js";
import { generateToken, generateRefreshToken } from "../utils/jwt.js";
import { verifyTurnstile } from "../utils/turnstile.js";
import { success, error } from "../utils/response.js";
import db from "../database/connection.js";

export const login = async (req, res) => {
    try {
        const { email, password, fcm_token, turnstileToken } = req.body;

        if (!email || !password) {
            return error(res, "Email dan password wajib diisi", 400);
        }

        if (!turnstileToken) {
            return error(res, "turnstileToken wajib disertakan", 400);
        }

        try {
            const ts = await verifyTurnstile(turnstileToken, req.ip);
            if (!ts.success || (ts.action && ts.action !== "login")) {
                return error(res, "Turnstile verification failed", 400);
            }
        } catch (err) {
            return error(res, "Error saat verifikasi Turnstile", 500);
        }

        const lockout = await LoginAttemptModel.checkAccountLockout(email);
        if (lockout.locked) {
            return error(
                res,
                `Akun sementara dikunci karena ${lockout.attemptCount}x percobaan gagal. ` +
                `Coba lagi dalam ${lockout.remainingMinutes} menit atau reset password Anda.`,
                429,
            );
        }

        const user = await UserModel.findByEmail(email);
        if (!user) {
            await LoginAttemptModel.recordFailedAttempt(email);
            return error(res, "Email atau password salah", 400);
        }

        const passwordMatch = await bcrypt.compare(
            password,
            user.password_hash,
        );
        if (!passwordMatch) {
            await LoginAttemptModel.recordFailedAttempt(email);

            const updated = await LoginAttemptModel.checkAccountLockout(email);
            const sisaPercobaan = Math.max(0, 5 - updated.attemptCount);

            if (sisaPercobaan === 0) {
                return error(
                    res,
                    "Akun dikunci karena terlalu banyak percobaan gagal. Coba lagi dalam 15 menit.",
                    429,
                );
            }

            return error(
                res,
                `Email atau password salah. Sisa percobaan: ${sisaPercobaan}`,
                400,
            );
        }

        await LoginAttemptModel.clearFailedAttempts(email);

        const token = generateToken({ id: user.id, role: user.role });

        let profil = null;

        if (user.role === "kader") {
            profil = await KaderModel.findByUserId(user.id);
        } else if (user.role === "puskesmas") {
            profil = await PuskesmasModel.findByUserId(user.id);
        } else if (user.role === "orang_tua") {
            if (
                fcm_token &&
                typeof fcm_token === "string" &&
                fcm_token.length < 256
            ) {
                await db.query(
                    `UPDATE orang_tua SET fcm_token = ? WHERE user_id = ?`,
                    [fcm_token, user.id],
                );
            }
            profil = await OrangTuaModel.findByUserId(user.id);

            const refreshToken = generateRefreshToken({
                id: user.id,
                role: user.role,
            });
            const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
            await RefreshTokenModel.save(user.id, refreshToken, expiresAt);

            return success(
                res,
                {
                    token,
                    refresh_token: refreshToken,
                    user: {
                        id: user.id,
                        email: user.email,
                        role: user.role,
                        profil,
                    },
                },
                "Login berhasil",
            );
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
        console.error("[login]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};

export const loginMobile = async (req, res) => {
    try {
        const { email, password, fcm_token } = req.body;

        if (!email || !password) {
            return error(res, "Email dan password wajib diisi", 400);
        }

        // [1] Cek lockout
        const lockout = await LoginAttemptModel.checkAccountLockout(email);
        if (lockout.locked) {
            return error(
                res,
                `Akun sementara dikunci karena ${lockout.attemptCount}x percobaan gagal. ` +
                `Coba lagi dalam ${lockout.remainingMinutes} menit atau reset password Anda.`,
                429,
            );
        }

        // [2] Cek user & pastikan role orang_tua
        const user = await UserModel.findByEmail(email);
        if (!user) {
            await LoginAttemptModel.recordFailedAttempt(email);
            return error(res, "Email atau password salah", 400);
        }

        if (user.role !== "orang_tua") {
            return error(res, "Akses ditolak", 403);
        }

        // [3] Cek password
        const passwordMatch = await bcrypt.compare(
            password,
            user.password_hash,
        );
        if (!passwordMatch) {
            await LoginAttemptModel.recordFailedAttempt(email);

            const updated = await LoginAttemptModel.checkAccountLockout(email);
            const sisaPercobaan = Math.max(0, 5 - updated.attemptCount);

            if (sisaPercobaan === 0) {
                return error(
                    res,
                    "Akun dikunci karena terlalu banyak percobaan gagal. Coba lagi dalam 15 menit.",
                    429,
                );
            }

            return error(
                res,
                `Email atau password salah. Sisa percobaan: ${sisaPercobaan}`,
                400,
            );
        }

        await LoginAttemptModel.clearFailedAttempts(email);

        // [4] Generate token
        const token = generateToken({ id: user.id, role: user.role });
        const refreshToken = generateRefreshToken({
            id: user.id,
            role: user.role,
        });
        const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
        await RefreshTokenModel.save(user.id, refreshToken, expiresAt);

        // [5] Update FCM token kalau ada
        if (
            fcm_token &&
            typeof fcm_token === "string" &&
            fcm_token.length < 256
        ) {
            await db.query(
                `UPDATE orang_tua SET fcm_token = ? WHERE user_id = ?`,
                [fcm_token, user.id],
            );
        }

        // [6] Ambil profil via model (konsisten dengan OrangTuaModel.findByUserId)
        const profil = await OrangTuaModel.findByUserId(user.id);

        return success(
            res,
            {
                token,
                refresh_token: refreshToken,
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
        console.error("[loginMobile]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};

export const changePassword = async (req, res) => {
    try {
        const { password_lama, password_baru } = req.body;
        const userId = req.user.id;

        if (!password_lama || !password_baru) {
            return error(res, "Password lama dan baru wajib diisi", 400);
        }

        if (password_baru.length < 6) {
            return error(res, "Password baru minimal 6 karakter", 400);
        }
        if (password_baru.length > 72) {
            return error(res, "Password baru maksimal 72 karakter", 400);
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
        await RefreshTokenModel.revokeAllByUser(userId);

        return success(res, null, "Password berhasil diubah");
    } catch (err) {
        console.error("[changePassword]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};

export const forgotPassword = async (req, res) => {
    try {
        const { email, turnstileToken } = req.body;

        if (!email) {
            return error(res, "Email wajib diisi", 400);
        }

        if (!turnstileToken) {
            return error(res, "turnstileToken wajib disertakan", 400);
        }

        try {
            const ts = await verifyTurnstile(turnstileToken, req.ip);
            if (!ts.success || (ts.action && ts.action !== "forgot-password")) {
                return error(res, "Turnstile verification failed", 400);
            }
        } catch (err) {
            return error(res, "Error saat verifikasi Turnstile", 500);
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
            "Jika email terdaftar, link reset password akan dikirimkan",
        );
    } catch (err) {
        console.error("[forgotPassword]", err);
        return error(res, "Terjadi kesalahan server", 500);
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
        if (password_baru.length > 72) {
            return error(res, "Password baru maksimal 72 karakter", 400);
        }

        const resetData = await PasswordResetModel.findValidToken(token);
        if (!resetData) {
            return error(
                res,
                "Link reset tidak valid atau sudah kedaluwarsa, silakan request ulang",
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
            "Password berhasil direset, silakan login ulang",
        );
    } catch (err) {
        console.error("[resetPassword]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};
