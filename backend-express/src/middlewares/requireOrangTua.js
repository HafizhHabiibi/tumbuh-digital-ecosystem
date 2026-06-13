import * as OrangTuaModel from "../models/orangTuaModel.js";
import { error } from "../utils/response.js";

export const requireOrangTua = async (req, res, next) => {
    try {
        const orangTua = await OrangTuaModel.findByUserId(req.user.id);
        if (!orangTua) {
            return error(res, "Data orang tua tidak ditemukan", 404);
        }
        req.orangTua = orangTua;
        next();
    } catch (err) {
        return error(res, err.message);
    }
};
