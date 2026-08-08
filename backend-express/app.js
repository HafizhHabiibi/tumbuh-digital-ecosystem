import express from "express";
import cors from "cors";
import "dotenv/config";
import authRoutes from "./src/routes/auth.js";
import kaderRoutes from "./src/routes/kader.js";
import pengukuranRoutes from "./src/routes/pengukuran.js";
import pemberianRoutes from "./src/routes/pemberian.js";
import rujukanRoutes from "./src/routes/rujukan.js";
import jadwalRoutes from "./src/routes/jadwal.js";
import notifikasiRoutes from "./src/routes/notifikasi.js";
import orangTuaRoutes from "./src/routes/orangTua.js";
import dashboardRoutes from "./src/routes/dashboard.js";

const app = express();

// Trust satu lapisan proxy (Nginx/Cloudflare) agar req.ip tidak bisa dimanipulasi
// via header X-Forwarded-For palsu dari client
app.set("trust proxy", 1);

app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/kader", kaderRoutes);
app.use("/api/pengukuran", pengukuranRoutes);
app.use("/api/pemberian", pemberianRoutes);
app.use("/api/rujukan", rujukanRoutes);
app.use("/api/jadwal", jadwalRoutes);
app.use("/api/notifikasi", notifikasiRoutes);
app.use("/api/orang-tua", orangTuaRoutes);
app.use("/api/dashboard", dashboardRoutes);

// Global error handler — tangkap SyntaxError dari body-parser (body kosong/invalid JSON)
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
        return res.status(400).json({
            success: false,
            message: "Body request tidak valid atau bukan JSON yang benar",
            data: null,
        });
    }
    next(err);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
