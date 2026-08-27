import express from "express";
import {
    downloadLaporanIndividual,
    downloadLaporanRekap,
} from "../controllers/laporanController.js";
import { authenticate } from "../middlewares/auth.js";
import {
    authorizeLaporanIndividual,
    authorizeLaporanRekap,
} from "../middlewares/laporanAuthorization.js";
import { validateParams, validateQuery } from "../middlewares/validate.js";
import {
    laporanAnakParamsSchema,
    laporanRekapQuerySchema,
} from "../validation/schemas.js";

export const buatLaporanRouter = ({
    authenticateMiddleware = authenticate,
    authorizeIndividual = authorizeLaporanIndividual,
    authorizeRekap = authorizeLaporanRekap,
    downloadIndividual = downloadLaporanIndividual,
    downloadRekap = downloadLaporanRekap,
} = {}) => {
    const router = express.Router();

    router.use(authenticateMiddleware);

    router.get(
        "/anak/:anak_id",
        validateParams(laporanAnakParamsSchema),
        authorizeIndividual,
        downloadIndividual,
    );

    router.get(
        "/rekap",
        authorizeRekap,
        validateQuery(laporanRekapQuerySchema),
        downloadRekap,
    );

    return router;
};

export default buatLaporanRouter();
