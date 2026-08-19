import express from "express";
import {
    getNotifikasi,
    getBelumDibaca,
    tandaiDibaca,
    tandaiSemuaDibaca,
    hapusNotifikasi,
    hapusSudahDibaca,
} from "../controllers/notifikasiController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";

const router = express.Router();

router.use(authenticate);
router.use(authorizeRole("orang_tua"));

router.get("/belum-dibaca", getBelumDibaca);
router.put("/baca-semua", tandaiSemuaDibaca);
router.delete("/sudah-dibaca", hapusSudahDibaca);
router.get("/", getNotifikasi);
router.put("/:id/baca", tandaiDibaca);
router.delete("/:id", hapusNotifikasi);

export default router;
