import bcrypt from "bcrypt";
import * as UserModel from "../models/userModel.js";
import * as RefreshTokenModel from "../models/refreshTokenModel.js";
import * as KaderModel from "../models/kaderModel.js";
import * as PuskesmasModel from "../models/puskesmasModel.js";
import * as OrangTuaModel from "../models/orangTuaModel.js";
import * as mailerService from "../services/mailerService.js";
import {
    generateToken,
    generateRefreshToken,
    generateResetToken,
    verifyResetToken,
} from "../utils/jwt.js";
import { verifyTurnstile } from "../utils/turnstile.js";
import { success, error } from "../utils/response.js";

// Unified login: web (with turnstile) & mobile (orang_tua only)
export const login = async (req, res) => {
    try {
        const { email, password, fcm_token, turnstileToken, platform } =
            req.body;

        if (!email || !password) {
            return error(res, "Email dan password wajib diisi", 400);
        }

        const isMobile = platform === "mobile";

        const isDev = process.env.NODE_ENV === "development";

        // Web login: require Turnstile CAPTCHA (skip di development)
        if (!isMobile && !isDev) {
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
        }

        const user = await UserModel.findByEmail(email);
        if (!user) {
            return error(res, "Email atau password salah", 400);
        }

        // Mobile login: hanya orang_tua yang boleh
        if (isMobile && user.role !== "orang_tua") {
            return error(res, "Akses ditolak", 403);
        }

        const passwordMatch = await bcrypt.compare(
            password,
            user.password_hash,
        );
        if (!passwordMatch) {
            return error(res, "Email atau password salah", 400);
        }

        const token = generateToken({ id: user.id, role: user.role });

        let profil = null;

        if (user.role === "kader") {
            profil = await KaderModel.findByUserId(user.id);
        } else if (user.role === "puskesmas") {
            profil = await PuskesmasModel.findByUserId(user.id);
        } else if (user.role === "orang_tua") {
            // Update FCM token if provided
            if (
                fcm_token &&
                typeof fcm_token === "string" &&
                fcm_token.length < 4096
            ) {
                await OrangTuaModel.updateFcmToken(user.id, fcm_token);
            }
            profil = await OrangTuaModel.findByUserId(user.id);
        }

        // Mobile: issue refresh token
        if (isMobile || user.role === "orang_tua") {
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

        // Web: no refresh token
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

        const isDev = process.env.NODE_ENV === "development";

        if (!isDev) {
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
        }

        const user = await UserModel.findByEmail(email);

        if (!user) {
            return success(
                res,
                null,
                "Jika email terdaftar, link reset password akan dikirimkan",
            );
        }

        // JWT-based reset token (stateless)
        const token = generateResetToken(user.id);
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

        // Verify JWT reset token
        const decoded = verifyResetToken(token);
        if (!decoded) {
            return error(
                res,
                "Link reset tidak valid atau sudah kedaluwarsa, silakan request ulang",
                400,
            );
        }

        // Check one-time use via reset_password_at
        const user = await UserModel.findByIdWithResetCheck(decoded.id);
        if (!user) {
            return error(res, "User tidak ditemukan", 404);
        }

        // If reset_password_at is after token was issued, token already used
        if (user.reset_password_at) {
            const tokenIssuedAt = new Date(decoded.iat * 1000);
            if (user.reset_password_at >= tokenIssuedAt) {
                return error(
                    res,
                    "Link reset sudah digunakan, silakan request ulang",
                    400,
                );
            }
        }

        const hash = await bcrypt.hash(password_baru, 10);
        await UserModel.updatePassword(user.id, hash);
        await UserModel.updateResetPasswordAt(user.id);

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
