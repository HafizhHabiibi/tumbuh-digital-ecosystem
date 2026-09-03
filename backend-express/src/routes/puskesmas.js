import express from "express";
import {
    getProfile,
    getAllAnak,
    getAnakById,
    getPengukuranAnak,
} from "../controllers/puskesmasController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requirePuskesmas } from "../middlewares/requirePuskesmas.js";
import { validateQuery } from "../middlewares/validate.js";
import { anakListQuerySchema } from "../validation/schemas.js";

const router = express.Router();

router.use(authenticate);
router.use(authorizeRole("puskesmas"));
router.use(requirePuskesmas); // inject req.puskesmas ke semua route

router.get("/profile", getProfile);
router.get("/anak", validateQuery(anakListQuerySchema), getAllAnak);
router.get("/anak/:id", getAnakById);
router.get("/anak/:id/pengukuran", getPengukuranAnak);

export default router;
