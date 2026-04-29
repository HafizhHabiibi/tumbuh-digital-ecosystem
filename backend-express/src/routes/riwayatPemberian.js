import express from "express";
import {
    createRiwayat,
    getRiwayatByAnak,
} from "../controllers/riwayatPemberianController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";

const router = express.Router();

router.use(authenticate);

router.post("/", authorizeRole("kader"), createRiwayat);

router.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas", "orang_tua"),
    getRiwayatByAnak,
);

export default router;
