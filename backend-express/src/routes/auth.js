import express from "express";
import {
    login,
    changePassword,
    forgotPassword,
    resetPassword,
} from "../controllers/authController.js";
import {
    refreshAccessToken,
    revokeRefreshToken,
} from "../controllers/refreshTokenController.js";

import { authenticate } from "../middlewares/auth.js";
import {
    ipRateLimit,
    emailRateLimit,
    forgotPasswordIpRateLimit,
    forgotPasswordEmailRateLimit,
} from "../middlewares/loginRateLimit.js";
import { validateBody } from "../middlewares/validate.js";
import {
    loginSchema,
    forgotPasswordSchema,
    resetPasswordSchema,
    changePasswordSchema,
    refreshTokenSchema,
} from "../validation/schemas.js";

const router = express.Router();

router.post("/login", ipRateLimit, emailRateLimit, validateBody(loginSchema), login);
router.post(
    "/forgot-password",
    forgotPasswordIpRateLimit,
    forgotPasswordEmailRateLimit,
    validateBody(forgotPasswordSchema),
    forgotPassword,
);
router.post("/reset-password", ipRateLimit, validateBody(resetPasswordSchema), resetPassword);
router.put("/change-password", authenticate, validateBody(changePasswordSchema), changePassword);
router.post("/refresh", validateBody(refreshTokenSchema), refreshAccessToken);
router.post("/logout", authenticate, revokeRefreshToken);

export default router;
