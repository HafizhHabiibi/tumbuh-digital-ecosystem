import * as RefreshTokenModel from "../models/refreshTokenModel.js";
import {
    generateToken,
    generateRefreshToken,
    verifyRefreshToken,
} from "../utils/jwt.js";
import { success, error } from "../utils/response.js";

export const refreshAccessToken = async (req, res) => {
    try {
        const { refresh_token } = req.body;

        if (!refresh_token) {
            return error(res, "Refresh token wajib disertakan", 400);
        }

        // Verifikasi signature refresh token
        let decoded;
        try {
            decoded = verifyRefreshToken(refresh_token);
        } catch {
            return error(
                res,
                "Refresh token tidak valid atau sudah kedaluwarsa",
                401,
            );
        }

        // Cek token di database — valid, belum expired, belum dicabut
        const tokenData = await RefreshTokenModel.findValid(
            decoded.id,
            refresh_token,
        );
        if (!tokenData) {
            return error(
                res,
                "Refresh token tidak valid atau sudah dicabut",
                401,
            );
        }

        // Gunakan role terbaru dari database, bukan role lama di JWT.
        const newAccessToken = generateToken({
            id: decoded.id,
            role: tokenData.role,
        });
        const newRefreshToken = generateRefreshToken({
            id: decoded.id,
            role: tokenData.role,
        });
        const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

        const rotated = await RefreshTokenModel.rotate(
            decoded.id,
            refresh_token,
            newRefreshToken,
            expiresAt,
        );
        if (!rotated) {
            return error(res, "Refresh token sudah digunakan atau dicabut", 401);
        }

        return success(
            res,
            {
                token: newAccessToken,
                refresh_token: newRefreshToken,
            },
            "Token berhasil diperbarui",
        );
    } catch (err) {
        console.error("[refreshAccessToken]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};

export const revokeRefreshToken = async (req, res) => {
    try {
        // Revoke berdasarkan user_id dari JWT (sudah diverifikasi middleware)
        // Tidak bergantung pada nilai refresh_token di body —
        // mencegah bypass dengan mengirim token palsu
        await RefreshTokenModel.revokeAllByUser(req.user.id);

        return success(res, null, "Logout berhasil");
    } catch (err) {
        console.error("[revokeRefreshToken]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};
