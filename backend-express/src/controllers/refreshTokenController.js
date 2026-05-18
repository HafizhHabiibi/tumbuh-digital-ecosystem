import * as RefreshTokenModel from "../models/refreshTokenModel.js";
import { generateToken, verifyRefreshToken } from "../utils/jwt.js";
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

        // Buat access token baru
        const newAccessToken = generateToken({
            id: decoded.id,
            role: decoded.role,
        });

        return success(
            res,
            { token: newAccessToken },
            "Token berhasil diperbarui",
        );
    } catch (err) {
        console.error("[refreshAccessToken]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};

export const revokeRefreshToken = async (req, res) => {
    try {
        const { refresh_token } = req.body;

        if (!refresh_token) {
            return error(res, "Refresh token wajib disertakan", 400);
        }

        await RefreshTokenModel.revoke(refresh_token);

        return success(res, null, "Logout berhasil");
    } catch (err) {
        console.error("[revokeRefreshToken]", err);
        return error(res, "Terjadi kesalahan server", 500);
    }
};
