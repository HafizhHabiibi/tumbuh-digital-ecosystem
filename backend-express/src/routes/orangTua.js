import express from "express";
import {
    getProfil,
    getAnak,
    getAnakById,
    getPengukuranAnak,
    getPemberianAnak,
    getRujukanAnak,
} from "../controllers/orangTuaController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";

const router = express.Router();

router.use(authenticate);
router.use(authorizeRole("orang_tua"));

router.get("/profil", getProfil);
router.get("/anak", getAnak);
router.get("/anak/:id", getAnakById);
router.get("/anak/:id/pengukuran", getPengukuranAnak);
router.get("/anak/:id/pemberian", getPemberianAnak);
router.get("/anak/:id/rujukan", getRujukanAnak);

export default router;
