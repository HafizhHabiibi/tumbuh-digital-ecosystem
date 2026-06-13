import express from "express";
import {
    createRiwayat,
    getRiwayatByAnak,
} from "../controllers/riwayatPemberianController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";

const router = express.Router();

router.use(authenticate);

// requireKader per-route karena GET diakses multi-role
router.post("/", authorizeRole("kader"), requireKader, createRiwayat);

router.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas", "orang_tua"),
    getRiwayatByAnak,
);

export default router;
