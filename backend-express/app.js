import express from "express";
import cors from "cors";
import "dotenv/config";
import authRoutes from "./src/routes/auth.js";
import kaderRoutes from "./src/routes/kader.js";
import pengukuranRoutes from "./src/routes/pengukuran.js";
import riwayatPemberianRoutes from "./src/routes/riwayatPemberian.js";
import rujukanRoutes from "./src/routes/rujukan.js";
import jadwalRoutes from "./src/routes/jadwal.js";

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/kader", kaderRoutes);
app.use("/api/pengukuran", pengukuranRoutes);
app.use("/api/riwayat-pemberian", riwayatPemberianRoutes);
app.use("/api/rujukan", rujukanRoutes);
app.use("/api/jadwal", jadwalRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
