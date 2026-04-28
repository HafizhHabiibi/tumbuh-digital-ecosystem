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

const router = express.Router();

router.use(authenticate);

router.get("/ranking", authorizeRole("kader", "puskesmas"), getRankingAnak);

router.post("/", authorizeRole("kader"), createPengukuran);

router.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas"),
    getRiwayatPengukuran,
);

router.get("/:id/saw", authorizeRole("kader", "puskesmas"), getDetailSAW);

router.get("/:id/insight", authorizeRole("orang_tua"), getInsight);

router.get("/:id", authorizeRole("kader", "puskesmas"), getDetailPengukuran);

export default router;
