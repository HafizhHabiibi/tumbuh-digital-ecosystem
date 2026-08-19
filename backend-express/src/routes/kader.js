import express from "express";
import {
    getProfile,
    createOrangTua,
    getOrangTua,
    getOrangTuaById,
    updateOrangTua,
    createAnak,
    getAllAnak,
    getAnakById,
    getAnakByOrangTua,
    updateAnak,
} from "../controllers/kaderController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";

const router = express.Router();

router.use(authenticate);
router.use(authorizeRole("kader"));
router.use(requireKader); // inject req.kader ke semua route

router.get("/profile", getProfile);
router.post("/orang-tua", createOrangTua);
router.get("/orang-tua", getOrangTua);
router.get("/orang-tua/:id", getOrangTuaById);
router.put("/orang-tua/:id", updateOrangTua);
router.get("/orang-tua/:id/anak", getAnakByOrangTua);

router.post("/anak", createAnak);
router.get("/anak", getAllAnak);
router.get("/anak/:id", getAnakById);
router.put("/anak/:id", updateAnak);

export default router;
