import express from "express";
import {
    login,
    loginMobile,
    changePassword,
    forgotPassword,
    resetPassword,
} from "../controllers/authController.js";

import { authenticate } from "../middlewares/auth.js";
import { ipRateLimit, emailRateLimit } from "../middlewares/loginRateLimit.js";

const router = express.Router();

router.post("/login", ipRateLimit, emailRateLimit, login);
router.post("/login/mobile", ipRateLimit, emailRateLimit, loginMobile);
router.post("/forgot-password", ipRateLimit, forgotPassword);
router.post("/reset-password", ipRateLimit, resetPassword);
router.put("/change-password", authenticate, changePassword);

export default router;
