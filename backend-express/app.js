import express from "express";
import cors from "cors";
import "dotenv/config";
import authRoutes from "./src/routes/auth.js";
import kaderRoutes from "./src/routes/kader.js";
import pengukuranRoutes from "./src/routes/pengukuran.js";

const app = express();

app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/kader", kaderRoutes);
app.use("/api/pengukuran", pengukuranRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
