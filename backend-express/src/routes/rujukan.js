import express from "express";
import {
    createRujukan,
    getAllRujukan,
    getDetailRujukan,
    updateStatusRujukan,
    getRujukanByAnak,
} from "../controllers/rujukanController.js";
import { authenticate } from "../middlewares/auth.js";
import { authorizeRole } from "../middlewares/role.js";
import { requireKader } from "../middlewares/requireKader.js";
import { validateBody } from "../middlewares/validate.js";
import {
    rujukanCreateSchema,
    rujukanStatusSchema,
} from "../validation/schemas.js";

const router = express.Router();

router.use(authenticate);

router.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas"),
    getRujukanByAnak,
);

// requireKader per-route karena hanya POST yang butuh kader data
router.post(
    "/",
    authorizeRole("kader"),
    requireKader,
    validateBody(rujukanCreateSchema),
    createRujukan,
);

router.get("/", authorizeRole("puskesmas"), getAllRujukan);

router.get("/:id", authorizeRole("kader", "puskesmas"), getDetailRujukan);

router.put(
    "/:id/status",
    authorizeRole("puskesmas"),
    validateBody(rujukanStatusSchema),
    updateStatusRujukan,
);

export default router;
