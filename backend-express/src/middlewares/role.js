import { error } from "../utils/response.js";

export const authorizeRole = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return error(
                res,
                `Akses ditolak. Hanya ${roles.join(" atau")} yang diizinkan`,
                403,
            );
        }
        next();
    };
};
