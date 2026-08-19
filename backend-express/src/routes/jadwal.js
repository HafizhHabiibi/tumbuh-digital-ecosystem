import express from "express";
import {
    getPengaturan,
    setPengaturan,
    generateJadwal,
    createJadwal,
    getAllJadwal,
    getDetailJadwal,
    updateJadwal,
    deleteJadwal,
} from "../controllers/jadwalController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";

const router = express.Router();
router.use(authenticate);

// ── Pengaturan template (Kader only) ─────────────────────────────
router.get("/pengaturan", authorizeRole("kader"), requireKader, getPengaturan);
router.put("/pengaturan", authorizeRole("kader"), requireKader, setPengaturan);

// ── Generate bulk dari template (Kader only) ─────────────────────
router.post("/generate", authorizeRole("kader"), requireKader, generateJadwal);

// ── CRUD Jadwal ──────────────────────────────────────────────────
router.post("/", authorizeRole("kader"), requireKader, createJadwal);
router.get("/", authorizeRole("kader", "puskesmas", "orang_tua"), getAllJadwal);
router.get("/:id", authorizeRole("kader", "puskesmas", "orang_tua"), getDetailJadwal);
router.put("/:id", authorizeRole("kader"), requireKader, updateJadwal);
router.delete("/:id", authorizeRole("kader"), requireKader, deleteJadwal);

export default router;
