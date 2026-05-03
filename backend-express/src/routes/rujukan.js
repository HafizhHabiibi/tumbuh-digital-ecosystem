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
import { getDataConnect } from "firebase-admin/data-connect";

const router = express.Router();

router.use(authenticate);

router.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas"),
    getRujukanByAnak,
);

router.post("/", authorizeRole("kader"), createRujukan);

router.get("/", authorizeRole("puskesmas"), getAllRujukan);

router.get("/:id", authorizeRole("kader", "puskesmas"), getDetailRujukan);

router.put("/:id/status", authorizeRole("puskesmas"), updateStatusRujukan);

export default router;
