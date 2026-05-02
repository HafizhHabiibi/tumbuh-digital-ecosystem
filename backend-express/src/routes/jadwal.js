import express from "express";
import {
    createJadwal,
    getAllJadwal,
    getDetailJadwal,
} from "../controllers/jadwalController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";

const router = express.Router();
router.use(authenticate);

router.post("/", authorizeRole("kader"), createJadwal);

router.get("/", authorizeRole("kader", "puskesmas", "orang_tua"), getAllJadwal);

router.get(
    "/:id",
    authorizeRole("kader", "puskesmas", "orang_tua"),
    getDetailJadwal,
);

export default router;
