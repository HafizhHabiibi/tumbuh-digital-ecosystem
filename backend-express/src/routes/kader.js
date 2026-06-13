import express from "express";
import {
    getProfile,
    createOrangTua,
    getOrangTua,
    getOrangTuaById,
    createAnak,
    getAllAnak,
    getAnakById,
    getAnakByOrangTua,
} from "../controllers/kaderController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";

const router = express.Router();

router.use((req, res, next) => {
    console.log(`[KADER ROUTE] ${req.method} ${req.path}`);
    next();
});

router.use(authenticate);
router.use(authorizeRole("kader"));
router.use(requireKader); // inject req.kader ke semua route

router.get("/profile", getProfile);
router.post("/orang-tua", createOrangTua);
router.get("/orang-tua", getOrangTua);
router.get("/orang-tua/:id", getOrangTuaById);
router.get("/orang-tua/:id/anak", getAnakByOrangTua);

router.post("/anak", createAnak);
router.get("/anak", getAllAnak);
router.get("/anak/:id", getAnakById);

export default router;
