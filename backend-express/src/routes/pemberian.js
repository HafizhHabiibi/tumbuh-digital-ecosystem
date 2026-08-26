import express from "express";
import {
    create,
    getByAnak,
} from "../controllers/pemberianController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";
import { validateBody } from "../middlewares/validate.js";
import { pemberianSchema } from "../validation/schemas.js";

const router = express.Router();

router.use(authenticate);

// requireKader per-route karena GET diakses multi-role
router.post(
    "/",
    authorizeRole("kader"),
    requireKader,
    validateBody(pemberianSchema),
    create,
);

router.get(
    "/anak/:anak_id",
    // Orang tua menggunakan /api/orang-tua/anak/:id/pemberian yang
    // memverifikasi kepemilikan anak. Route lintas-anak ini hanya untuk petugas.
    authorizeRole("kader", "puskesmas"),
    getByAnak,
);

export default router;

