import { defineConfig, loadEnv } from "vite";
import vue from "@vitejs/plugin-vue";
import tailwindcss from "@tailwindcss/vite";
import path from "path";

const createContentSecurityPolicy = (apiUrl, { includeFrameAncestors }) => {
    let apiOrigin;
    try {
        apiOrigin = new URL(apiUrl).origin;
    } catch {
        throw new Error("VITE_API_URL harus berupa URL HTTP(S) absolut");
    }

    const directives = [
        "default-src 'self'",
        "base-uri 'self'",
        "object-src 'none'",
        "form-action 'self'",
        "script-src 'self' https://challenges.cloudflare.com",
        "style-src 'self' 'unsafe-inline'",
        "img-src 'self' data: blob:",
        "font-src 'self' data:",
        `connect-src 'self' ${apiOrigin} https://challenges.cloudflare.com ws://localhost:* ws://127.0.0.1:*`,
        "frame-src https://challenges.cloudflare.com",
        "worker-src 'self' blob:",
        ...(includeFrameAncestors ? ["frame-ancestors 'none'"] : []),
    ];
    return directives.join("; ");
};

const cspMetaPlugin = (policy) => ({
    name: "tumbuh-csp-meta",
    transformIndexHtml: {
        order: "pre",
        handler(html) {
            return html.replace(
                "<head>",
                `<head>\n    <meta http-equiv="Content-Security-Policy" content="${policy}" />`,
            );
        },
    },
});

export default defineConfig(({ mode }) => {
    const env = loadEnv(mode, import.meta.dirname, "");
    const apiUrl = env.VITE_API_URL || "http://localhost:3000/api";
    const metaPolicy = createContentSecurityPolicy(apiUrl, {
        includeFrameAncestors: false,
    });
    const headerPolicy = createContentSecurityPolicy(apiUrl, {
        includeFrameAncestors: true,
    });

    return {
        plugins: [cspMetaPlugin(metaPolicy), vue(), tailwindcss()],
        resolve: {
            alias: {
                "@": path.resolve(import.meta.dirname, "./src"),
            },
        },
        server: {
            headers: {
                "Content-Security-Policy": headerPolicy,
                "Referrer-Policy": "no-referrer",
                "X-Content-Type-Options": "nosniff",
                "X-Frame-Options": "DENY",
            },
        },
        preview: {
            headers: {
                "Content-Security-Policy": headerPolicy,
                "Referrer-Policy": "no-referrer",
                "X-Content-Type-Options": "nosniff",
                "X-Frame-Options": "DENY",
            },
        },
        optimizeDeps: {
            include: [
                "apexcharts/core",
                "apexcharts/line",
                "apexcharts/bar",
                "apexcharts/donut",
                "apexcharts/features/legend",
            ],
        },
    };
});
