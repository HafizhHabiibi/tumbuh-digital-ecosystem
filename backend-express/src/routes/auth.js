import express from "express";
import {
    login,
    changePassword,
    forgotPassword,
    resetPassword,
} from "../controllers/authController.js";

import { authenticate } from "../middlewares/auth.js";

const router = express.Router();

router.post("/login", login);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.put("/change-password", authenticate, changePassword);

export default router;
