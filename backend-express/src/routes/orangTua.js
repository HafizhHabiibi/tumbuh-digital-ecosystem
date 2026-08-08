import express from "express";
import {
    getProfil,
    getAnak,
    getAnakById,
    getPengukuranAnak,
    getPemberianAnak,
    getRujukanAnak,
    updateFcmToken,
} from "../controllers/orangTuaController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireOrangTua } from "../middlewares/requireOrangTua.js";

const router = express.Router();

router.use(authenticate);
router.use(authorizeRole("orang_tua"));
router.use(requireOrangTua); // inject req.orangTua ke semua route

router.get("/profile", getProfil);
router.get("/anak", getAnak);
router.get("/anak/:id", getAnakById);
router.get("/anak/:id/pengukuran", getPengukuranAnak);
router.get("/anak/:id/pemberian", getPemberianAnak);
router.get("/anak/:id/rujukan", getRujukanAnak);
router.put("/update-fcm-token", updateFcmToken);

export default router;
