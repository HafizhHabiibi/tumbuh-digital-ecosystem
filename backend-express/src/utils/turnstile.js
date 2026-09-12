import axios from "axios";

const TURNSTILE_URL =
    "https://challenges.cloudflare.com/turnstile/v0/siteverify";

export const verifyTurnstile = async (token, remoteIp) => {
    const turnstileSecret = process.env.TURNSTILE_SECRET_KEY;
    if (!turnstileSecret) {
        throw new Error(
            "TURNSTILE_SECRET_KEY is not configured in environment",
        );
    }

    if (!token || typeof token !== "string") {
        return {
            success: false,
            action: null,
            hostname: null,
            challenge_ts: null,
            raw: {},
        };
    }

    const params = new URLSearchParams();
    params.append("secret", turnstileSecret);
    params.append("response", token);
    if (remoteIp) params.append("remoteip", remoteIp);

    try {
        const res = await axios.post(TURNSTILE_URL, params.toString(), {
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            timeout: 5000,
        });

        const data = res.data || {};

        return {
            success: !!data.success,
            action: data.action || null,
            hostname: data.hostname || null,
            challenge_ts: data.challenge_ts || null,
            raw: data,
        };
    } catch (err) {
        throw new Error(`Turnstile request failed: ${err.message}`);
    }
};

export const getAllowedTurnstileHostnames = (env = process.env) =>
    (env.TURNSTILE_ALLOWED_HOSTNAMES || "")
        .split(",")
        .map((hostname) => hostname.trim().toLowerCase())
        .filter(Boolean);

export const isTurnstileResultAccepted = (
    result,
    expectedAction,
    allowedHostnames,
) => Boolean(
    result?.success &&
    result.action === expectedAction &&
    typeof result.hostname === "string" &&
    allowedHostnames.includes(result.hostname.toLowerCase()),
);
