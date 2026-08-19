import * as PuskesmasModel from "../models/puskesmasModel.js";
import { error } from "../utils/response.js";

export const requirePuskesmas = async (req, res, next) => {
    try {
        const puskesmas = await PuskesmasModel.findByUserId(req.user.id);
        if (!puskesmas) {
            return error(res, "Data puskesmas tidak ditemukan", 404);
        }
        req.puskesmas = puskesmas;
        next();
    } catch (err) {
        return error(res, err.message);
    }
};
