import { verifyToken } from "../utils/jwt.js";
import { error } from "../utils/response.js";
import * as UserModel from "../models/userModel.js";

export const buatAuthenticate = ({
    verifyTokenFn = verifyToken,
    findActiveById = UserModel.findActiveById,
} = {}) => async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return error(res, "Token tidak ditemukan", 401);
        }

        const token = authHeader.split(" ")[1];

        const decoded = verifyTokenFn(token);

        const user = await findActiveById(decoded.id);
        if (!user) {
            return error(res, "Akun tidak aktif atau tidak ditemukan", 401);
        }

        if (!decoded.iat) {
            return error(res, "Token tidak valid", 401);
        }
        const userUpdatedAtEpoch = Number(user.updated_at_epoch);
        if (
            Number.isFinite(userUpdatedAtEpoch) &&
            decoded.iat < userUpdatedAtEpoch
        ) {
            return error(res, "Sesi sudah tidak berlaku, silakan login ulang", 401);
        }

        req.user = { id: user.id, role: user.role };
        next();
    } catch (err) {
        return error(res, "Token tidak valid atau sudah kadaluarsa", 401);
    }
};

export const authenticate = buatAuthenticate();
