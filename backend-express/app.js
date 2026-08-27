import express from "express";
import cors from "cors";
import { randomUUID } from "node:crypto";
import { pathToFileURL } from "node:url";
import { validateEnvironment } from "./src/config.js";
import db from "./src/database/connection.js";
import { processPendingNotifications } from "./src/services/fcmService.js";
import {
    INSIGHT_PROCESSING_CONFIG,
    processPendingInsights,
} from "./src/services/insightService.js";
import authRoutes from "./src/routes/auth.js";
import kaderRoutes from "./src/routes/kader.js";
import puskesmasRoutes from "./src/routes/puskesmas.js";
import pengukuranRoutes from "./src/routes/pengukuran.js";
import pemberianRoutes from "./src/routes/pemberian.js";
import rujukanRoutes from "./src/routes/rujukan.js";
import jadwalRoutes from "./src/routes/jadwal.js";
import notifikasiRoutes from "./src/routes/notifikasi.js";
import orangTuaRoutes from "./src/routes/orangTua.js";
import dashboardRoutes from "./src/routes/dashboard.js";
import laporanRoutes from "./src/routes/laporan.js";

const app = express();
const { port: PORT, trustProxyHops } = validateEnvironment();

app.set("trust proxy", trustProxyHops === 0 ? false : trustProxyHops);

app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use((req, res, next) => {
    req.id = req.headers["x-request-id"] || randomUUID();
    res.setHeader("X-Request-Id", req.id);
    next();
});
app.use(express.json({ limit: "100kb" }));

app.get("/api/health/live", (req, res) => {
    res.json({ success: true, message: "Service aktif", data: null });
});

app.get("/api/health/ready", async (req, res) => {
    try {
        await db.query("SELECT 1");
        res.json({ success: true, message: "Service siap", data: null });
    } catch (err) {
        console.error(`[${req.id}] Readiness gagal: ${err.message}`);
        res.status(503).json({
            success: false,
            message: "Service belum siap",
            data: null,
        });
    }
});

app.use("/api/auth", authRoutes);
app.use("/api/kader", kaderRoutes);
app.use("/api/puskesmas", puskesmasRoutes);
app.use("/api/pengukuran", pengukuranRoutes);
app.use("/api/pemberian", pemberianRoutes);
app.use("/api/rujukan", rujukanRoutes);
app.use("/api/jadwal", jadwalRoutes);
app.use("/api/notifikasi", notifikasiRoutes);
app.use("/api/orang-tua", orangTuaRoutes);
app.use("/api/dashboard", dashboardRoutes);
app.use("/api/laporan", laporanRoutes);

app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: "Endpoint tidak ditemukan",
        data: null,
    });
});

// Global error handler — tangkap SyntaxError dari body-parser (body kosong/invalid JSON)
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
        return res.status(400).json({
            success: false,
            message: "Body request tidak valid atau bukan JSON yang benar",
            data: null,
        });
    }
    console.error(`[${req.id}]`, err);
    return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan server",
        data: null,
    });
});

const isMainModule = process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;

if (isMainModule) {
    const server = app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
    });

    const outboxInterval = setInterval(() => {
        processPendingNotifications().catch((err) =>
            console.error(`[OUTBOX] ${err.message}`),
        );
    }, 30_000);
    outboxInterval.unref();

    let insightWorkerRunning = false;
    const runInsightWorker = async () => {
        if (insightWorkerRunning) return;
        insightWorkerRunning = true;
        try {
            await processPendingInsights();
        } catch (err) {
            console.error(`[INSIGHT WORKER] ${err.message}`);
        } finally {
            insightWorkerRunning = false;
        }
    };
    void runInsightWorker();
    const insightInterval = setInterval(
        runInsightWorker,
        INSIGHT_PROCESSING_CONFIG.workerIntervalMs,
    );
    insightInterval.unref();

    const shutdown = (signal) => {
        console.log(`${signal} diterima, menghentikan server...`);
        clearInterval(outboxInterval);
        clearInterval(insightInterval);
        server.close(async () => {
            await db.end();
            process.exit(0);
        });
        setTimeout(() => process.exit(1), 10_000).unref();
    };

    process.once("SIGTERM", () => shutdown("SIGTERM"));
    process.once("SIGINT", () => shutdown("SIGINT"));
}

export default app;
