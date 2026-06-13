import * as KaderModel from "../models/kaderModel.js";
import { error } from "../utils/response.js";

export const requireKader = async (req, res, next) => {
    try {
        const kader = await KaderModel.findByUserId(req.user.id);
        if (!kader) {
            return error(res, "Data kader tidak ditemukan", 404);
        }
        req.kader = kader;
        next();
    } catch (err) {
        return error(res, err.message);
    }
};
