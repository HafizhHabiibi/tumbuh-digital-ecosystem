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

const routes = express.Router();

routes.use(authenticate);

routes.get(
    "/anak/:anak_id",
    authorizeRole("kader", "puskesmas"),
    getRujukanByAnak,
);

routes.post("/", authorizeRole("kader"), createRujukan);

routes.get("/", authorizeRole("puskesmas"), getAllRujukan);

routes.get("/:id", authorizeRole("kader", "puskesmas"), getDetailRujukan);

routes.put("/:id/status", authorizeRole("puskesmas"), updateStatusRujukan);

export default routes;
