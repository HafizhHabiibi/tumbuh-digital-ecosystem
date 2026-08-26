import { verifyToken } from "../utils/jwt.js";
import { error } from "../utils/response.js";
import * as UserModel from "../models/userModel.js";

export const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return error(res, "Token tidak ditemukan", 401);
        }

        const token = authHeader.split(" ")[1];

        const decoded = verifyToken(token);

        const user = await UserModel.findActiveById(decoded.id);
        if (!user) {
            return error(res, "Akun tidak aktif atau tidak ditemukan", 401);
        }

        if (!decoded.iat) {
            return error(res, "Token tidak valid", 401);
        }
        const tokenIssuedAt = new Date(decoded.iat * 1000);
        const userUpdatedAt = user.updated_at
            ? new Date(user.updated_at)
            : null;
        if (
            userUpdatedAt &&
            !Number.isNaN(userUpdatedAt.getTime()) &&
            tokenIssuedAt < userUpdatedAt
        ) {
            return error(res, "Sesi sudah tidak berlaku, silakan login ulang", 401);
        }

        req.user = { id: user.id, role: user.role };
        next();
    } catch (err) {
        return error(res, "Token tidak valid atau sudah kadaluarsa", 401);
    }
};
