import express from "express";
import {
    getStatistik,
    getDistribusiGizi,
    getTrenGizi,
    getDistribusiRisiko,
} from "../controllers/dashboardController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";

const router = express.Router();

router.use(authenticate);
router.use(authorizeRole("kader", "puskesmas"));

router.get("/statistik", getStatistik);
router.get("/distribusi", getDistribusiGizi);
router.get("/tren", getTrenGizi);
router.get("/prioritas", getDistribusiRisiko);
// Alias lama dipertahankan sementara untuk kompatibilitas client.
router.get("/risiko", getDistribusiRisiko);

export default router;
