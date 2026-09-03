import express from "express";
import {
    createPengukuran,
    getRiwayatPengukuran,
    getDetailPengukuran,
    getRankingAnak,
    getDetailSAW,
    getInsight,
} from "../controllers/pengukuranController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";
import { requireOrangTua } from "../middlewares/requireOrangTua.js";
import { validateBody, validateQuery } from "../middlewares/validate.js";
import {
    pengukuranSchema,
    rankingListQuerySchema,
} from "../validation/schemas.js";

const router = express.Router();

router.use(authenticate);

router.get(
    "/ranking",
    authorizeRole("kader", "puskesmas"),
    validateQuery(rankingListQuerySchema),
    getRankingAnak,
);

// requireKader dipakai per-route karena POST ini hanya untuk kader
router.post(
    "/",
    authorizeRole("kader"),
    requireKader,
    validateBody(pengukuranSchema),
    createPengukuran,
);

router.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas"),
    getRiwayatPengukuran,
);

router.get("/:id/saw", authorizeRole("kader", "puskesmas"), getDetailSAW);

router.get(
    "/:id/insight",
    authorizeRole("orang_tua"),
    requireOrangTua,
    getInsight,
);

router.get("/:id", authorizeRole("kader", "puskesmas"), getDetailPengukuran);

export default router;
