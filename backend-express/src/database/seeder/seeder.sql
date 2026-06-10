USE posyandu_pui;

-- ==========================================================
-- FULL RESET — Hapus semua data lama (urutan FK terbalik)
-- ==========================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notifikasi;
TRUNCATE TABLE ai_insight;
TRUNCATE TABLE rujukan;
TRUNCATE TABLE saw_result_detail;
TRUNCATE TABLE saw_result;
TRUNCATE TABLE riwayat_pemberian;
TRUNCATE TABLE pengukuran;
TRUNCATE TABLE anak;
TRUNCATE TABLE jadwal_posyandu;
TRUNCATE TABLE orang_tua;
TRUNCATE TABLE kader;
TRUNCATE TABLE puskesmas_user;
TRUNCATE TABLE refresh_tokens;
TRUNCATE TABLE login_attempts;
TRUNCATE TABLE password_reset_token;
TRUNCATE TABLE users;
TRUNCATE TABLE saw_kriteria;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- SAW KRITERIA SETUP
-- ==========================================================
INSERT INTO saw_kriteria (nama_kriteria, bobot, keterangan) VALUES
    ('zscore_tbu',      0.4000, 'Tinggi Badan per Umur'),
    ('zscore_bbu',      0.3000, 'Berat Badan per Umur'),
    ('zscore_bbtb',     0.2000, 'Berat Badan per Tinggi Badan'),
    ('frekuensi_hadir', 0.1000, 'Kehadiran rutin ke posyandu');

-- ==========================================================
-- TIER 1: Users, Kader, Puskesmas
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72e-7d23-a1d2-48848fa4f8fe', 'meongterbang22@gmail.com', '$2b$10$2LZ5ypZv8GUef32orl8.r.yvKcfzTe67CCdgI7HstpO5v7JHPH8j.', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019eb2ce-e72f-78ce-b432-a67557ded032', '019eb2ce-e72e-7d23-a1d2-48848fa4f8fe', 'Riri Andayani', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a676b4667392', 'budi.kader@gmail.com', '$2b$10$QKvcEAE49IeamOaaDpconuVhNe3w95naiUfBA2yYcikzNhF0HAVmm', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '019eb2ce-e72f-78ce-b432-a676b4667392', 'Budi Santoso', '082345678901');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a678efeb1cfb', 'sari.kader@gmail.com', '$2b$10$nAHyg26ztUV/jnuzjhlamuSxRqmbLMZ2M52mopAmlT8M55ALBPquK', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('019eb2ce-e72f-78ce-b432-a679426eafd7', '019eb2ce-e72f-78ce-b432-a678efeb1cfb', 'Sari Dewi', '083456789012');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a67a30b4820e', 'bullmini123@gmail.com', '$2b$10$SU1LVq9PLndycQKuICGtkujw83ukDDnZXGO0hqYF1.X/KYKv2EpnW', 'puskesmas', TRUE);
INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019eb2ce-e72f-78ce-b432-a67b582ecea9', '019eb2ce-e72f-78ce-b432-a67a30b4820e', 'Ciko Wijaya', 'Bidan', '081234567891');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a67c9e4d369d', 'hana.pertiwi@gmail.com', '$2b$10$opitTXV0TDRZKA6BRd7b7exT.GP90nwaMLbEwsv3Z99vSdGtLqyH6', 'puskesmas', TRUE);
INSERT INTO puskesmas_user (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('019eb2ce-e72f-78ce-b432-a67d172357d0', '019eb2ce-e72f-78ce-b432-a67c9e4d369d', 'dr. Hana Pertiwi', 'Dokter', '084567890123');

-- ==========================================================
-- TIER 2: Orang Tua
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a67ea8e50176', 'aminah.kusuma@gmail.com', '$2b$10$TuXi/VhKnTj.FNt.5UJBduB0fJFhevxfB8/jRQoB4RGi1cfYIi2IO', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a67fcb8c3c22', '019eb2ce-e72f-78ce-b432-a67ea8e50176', '019eb2ce-e72f-78ce-b432-a67557ded032', 'Aminah Kusuma', '081111111101', 'Jl. Mawar No. 12 RT 01 RW 05', '3201010101870001');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a680700be5b5', 'dewi.susanti@gmail.com', '$2b$10$yoXO4//d47NDKOK6wp4VpengDkKdaci4ArSenguJtFIEL7zT1D08G', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a681b9f4546e', '019eb2ce-e72f-78ce-b432-a680700be5b5', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'Dewi Susanti', '081111111102', 'Jl. Melati No. 5 RT 02 RW 05', '3201010201890002');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a682e4d6df36', 'fatimah.rahman@gmail.com', '$2b$10$p78BvgUGKBjRYHJzUfGMB.wG/DfyMFXzQxyjytqmmsdmy9K9bJU.2', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a683ee87cb78', '019eb2ce-e72f-78ce-b432-a682e4d6df36', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'Fatimah Rahman', '081111111103', 'Jl. Anggrek No. 8 RT 03 RW 05', '3201010301850003');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a6845a658f37', 'siti.rahayu@gmail.com', '$2b$10$Dk.DV46rqGgklm9it4nysuu4NQJIKpMm5OBcPfZbpfIaNK1Lq0Dkq', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a68566dc2381', '019eb2ce-e72f-78ce-b432-a6845a658f37', '019eb2ce-e72f-78ce-b432-a67557ded032', 'Siti Rahayu', '081111111104', 'Jl. Dahlia No. 3 RT 01 RW 05', '3201010401900004');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a6865e3712d9', 'kartini.wulandari@gmail.com', '$2b$10$39EeDV1wXbco6StQsR3UT.tbZbp7gQxogiadsQNs/yr36mOqC.5pO', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a68703f131db', '019eb2ce-e72f-78ce-b432-a6865e3712d9', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'Kartini Wulandari', '081111111105', 'Jl. Kenanga No. 7 RT 04 RW 05', '3201010501880005');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a688e768496c', 'rahayu.lestari@gmail.com', '$2b$10$F2ENBpGuyppQ3t.mkJcG.eENAFYZg0vT1lnvXNdNO.EKHIprzl76e', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a6896f16de42', '019eb2ce-e72f-78ce-b432-a688e768496c', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'Rahayu Lestari', '081111111106', 'Jl. Bougenville No. 15 RT 02 RW 05', '3201010601910006');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a68acc78974f', 'wulan.sari@gmail.com', '$2b$10$CWR9g8Zn2KnzG2Q.ugJE..I6qKMr6m7dz0ZSGoyCQTVGjPtPx3Hb.', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a68b6bf3d550', '019eb2ce-e72f-78ce-b432-a68acc78974f', '019eb2ce-e72f-78ce-b432-a67557ded032', 'Wulan Sari', '081111111107', 'Jl. Cempaka No. 4 RT 03 RW 05', '3201010701920007');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a68c6e7c9d7d', 'lestari.handayani@gmail.com', '$2b$10$E/J5rT5D1HyXeSgao1.zDOgh07VxSXxlxwpC9PvUfNkRcX7QhKj0q', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a68d67a01582', '019eb2ce-e72f-78ce-b432-a68c6e7c9d7d', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'Lestari Handayani', '081111111108', 'Jl. Flamboyan No. 9 RT 05 RW 05', '3201010801860008');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a68e11dfa376', 'nuraini.putri@gmail.com', '$2b$10$ewDkJvgaET./qSTNUwWKiOk/bJt0x5G6eHlyVdGjs4IS6lWit83fC', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a68fabee42db', '019eb2ce-e72f-78ce-b432-a68e11dfa376', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'Nuraini Putri', '081111111109', 'Jl. Kamboja No. 2 RT 01 RW 05', '3201010901930009');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('019eb2ce-e72f-78ce-b432-a69037423d95', 'sumiati.wahyu@gmail.com', '$2b$10$LIKFMWc3UKn7FOJDghJU/eyOdgWySHREiVZy6MoIUJXfCQe9DX0AW', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('019eb2ce-e72f-78ce-b432-a6918f838c19', '019eb2ce-e72f-78ce-b432-a69037423d95', '019eb2ce-e72f-78ce-b432-a67557ded032', 'Sumiati Wahyu', '081111111110', 'Jl. Teratai No. 6 RT 04 RW 05', '3201011001870010');

-- ==========================================================
-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)
-- ==========================================================

INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a67557ded032', '2026-01-19', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Januari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a67557ded032', '2026-02-16', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Februari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-03-15', '08:30', '11:30', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Maret 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-04-20', '08:00', '12:00', 'Puskesmas Pembantu Cempaka', 'Posyandu + Pemberian Vitamin A Massal');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-05-18', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Mei 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a67557ded032', '2026-06-15', '08:30', '12:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juni 2026 - Pembagian PMT');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-07-20', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juli 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-08-17', '08:30', '11:30', 'Puskesmas Pembantu Cempaka', 'Posyandu + Bulan Imunisasi Nasional 2026');

-- ==========================================================
-- TIER 3: Anak (15 anak)
-- ==========================================================

INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67fcb8c3c22', 'Rizki', 'L', '2025-06-11', '3201011234560001');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a67fcb8c3c22', 'Rafi', 'L', '2023-10-11', '3201011234560002');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a681b9f4546e', 'Nayla', 'P', '2025-10-11', '3201011234560003');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a683ee87cb78', 'Hasan', 'L', '2024-06-11', '3201011234560004');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a683ee87cb78', 'Husein', 'L', '2025-12-11', '3201011234560005');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a68566dc2381', 'Zahra', 'P', '2024-12-11', '3201011234560006');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a68703f131db', 'Dani', 'L', '2023-12-11', '3201011234560007');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a68703f131db', 'Dina', 'P', '2025-03-11', '3201011234560008');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a6896f16de42', 'Bagas', 'L', '2024-10-11', '3201011234560009');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a68b6bf3d550', 'Putri', 'P', '2025-08-11', '3201011234560010');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a68d67a01582', 'Adi', 'L', '2023-06-11', '3201011234560011');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a68d67a01582', 'Ayu', 'P', '2024-08-11', '3201011234560012');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a68fabee42db', 'Fauzi', 'L', '2025-04-11', '3201011234560013');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6918f838c19', 'Bella', 'P', '2024-02-11', '3201011234560014');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, no_kk) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a6918f838c19', 'Bimo', 'L', '2025-09-11', '3201011234560015');

-- ==========================================================
-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)
-- Z-score dihitung otomatis menggunakan WHO tables
-- ==========================================================

-- Anak: Rizki (L, lahir 2025-06-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-01-11', 8.8, 71.5, 43.3, 13.6, 0.531, 1.056, 0.056, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-02-11', 9.1, 72.8, 43.7, 13.8, 0.484, 0.956, 0.075, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-03-11', 9.4, 74, 44, 13.9, 0.511, 0.923, 0.132, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-04-11', 9.6, 75.3, 44.3, 14.1, 0.433, 0.898, 0.045, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-05-11', 9.9, 76.5, 44.6, 14.2, 0.469, 0.854, 0.121, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-06-11', 10.2, 77.8, 45, 14.3, 0.514, 0.872, 0.183, 'normal');

-- Anak: Rafi (L, lahir 2023-10-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-01-11', 14.2, 93.5, NULL, NULL, 0.928, 1.188, 0.44, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-02-11', 14.4, 94.2, NULL, NULL, 0.915, 1.138, 0.464, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-03-11', 14.6, 94.9, NULL, NULL, 0.914, 1.113, 0.486, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-04-11', 14.8, 95.5, NULL, NULL, 0.906, 1.049, 0.525, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-05-11', 15, 96.2, NULL, NULL, 0.901, 1.024, 0.541, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-06-11', 15.2, 96.9, NULL, NULL, 0.898, 1.004, 0.552, 'normal');

-- Anak: Nayla (P, lahir 2025-10-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-01-11', 6.6, 62.5, 38.5, 12.3, 0.955, 1.268, 0.175, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-02-11', 7, 64.4, 40, 12.7, 0.663, 1.022, 0.089, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-03-11', 7.4, 66.3, 41.5, 13.1, 0.595, 1.063, 0.038, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-04-11', 7.8, 68.2, 43, 13.5, 0.549, 1.096, 0.018, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-05-11', 8.2, 70.1, 43.3, 13.6, 0.59, 1.24, 0.022, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-06-11', 8.6, 72, 43.7, 13.8, 0.644, 1.375, 0.041, 'normal');

-- Anak: Hasan (L, lahir 2024-06-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-01-11', 8.8, 80.5, 47.3, 15.3, -2.113, -0.999, -2.245, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-02-11', 9, 81.2, 47.6, 15.5, -2.071, -1.081, -2.12, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-03-11', 9.2, 81.9, 48, 15.6, -2.012, -1.112, -2.008, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-04-11', 9.5, 82.7, 48.3, 15.7, -1.878, -1.139, -1.796, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-05-11', 9.7, 83.4, 48.6, 15.9, -1.832, -1.172, -1.71, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-06-11', 9.9, 84.1, NULL, NULL, -1.796, -0.991, -1.635, 'normal');

-- Anak: Husein (L, lahir 2025-12-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-01-11', 5.2, 57.5, 35.5, 11.4, 1.144, 1.421, -0.163, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-02-11', 5.9, 60.2, 37, 11.8, 0.423, 0.825, -0.295, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-03-11', 6.6, 62.9, 38.5, 12.3, 0.35, 0.796, -0.28, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-04-11', 7.4, 65.6, 40, 12.7, 0.504, 0.845, -0.015, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-05-11', 8.1, 68.3, 41.5, 13.1, 0.712, 1.178, 0.096, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-06-11', 8.8, 71, 43, 13.5, 0.956, 1.585, 0.211, 'normal');

-- Anak: Zahra (P, lahir 2024-12-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-01-11', 7.3, 71, 45.3, 14.5, -1.907, -1.612, -1.546, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-02-11', 7.5, 72.1, 45.6, 14.6, -1.878, -1.605, -1.538, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-03-11', 7.7, 73.2, 46, 14.8, -1.835, -1.559, -1.525, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-04-11', 7.8, 74.3, 46.3, 14.9, -1.914, -1.529, -1.654, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-05-11', 8, 75.4, 46.6, 15, -1.875, -1.478, -1.625, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-06-11', 8.2, 76.5, 47, 15.2, -1.847, -1.441, -1.592, 'normal');

-- Anak: Dani (L, lahir 2023-12-11, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-01-11', 9.3, 82.5, NULL, NULL, -2.481, -1.765, -2.198, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-02-11', 9.5, 83.4, NULL, NULL, -2.423, -1.712, -2.165, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-03-11', 9.7, 84.3, NULL, NULL, -2.356, -1.64, -2.145, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-04-11', 9.8, 85.2, NULL, NULL, -2.386, -1.579, -2.266, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-05-11', 10, 86.1, NULL, NULL, -2.325, -1.515, -2.256, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-06-11', 10.2, 87, NULL, NULL, -2.265, -1.447, -2.246, 'kurang');

-- Anak: Dina (P, lahir 2025-03-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-01-11', 9.3, 74, 44.3, 14.1, 0.74, 0.998, 0.41, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-02-11', 9.5, 75.2, 44.6, 14.2, 0.678, 0.924, 0.371, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-03-11', 9.8, 76.4, 45, 14.3, 0.738, 0.934, 0.452, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-04-11', 10, 77.6, 45.3, 14.5, 0.695, 0.897, 0.421, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-05-11', 10.3, 78.8, 45.6, 14.6, 0.749, 0.905, 0.491, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-06-11', 10.5, 80, 46, 14.8, 0.715, 0.897, 0.443, 'normal');

-- Anak: Bagas (L, lahir 2024-10-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-01-11', 8.5, 76, 46, 14.8, -1.753, -1.255, -1.632, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-02-11', 8.7, 76.8, 46.3, 14.9, -1.723, -1.332, -1.537, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-03-11', 8.9, 77.6, 46.6, 15, -1.675, -1.36, -1.441, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-04-11', 9.1, 78.5, 47, 15.2, -1.647, -1.385, -1.368, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-05-11', 9.3, 79.3, 47.3, 15.3, -1.609, -1.413, -1.274, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-06-11', 9.4, 80.1, 47.6, 15.5, -1.674, -1.452, -1.318, 'normal');

-- Anak: Putri (P, lahir 2025-08-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-01-11', 7.6, 66.5, 41.5, 13.1, 0.778, 1.098, 0.264, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-02-11', 7.9, 68, 43, 13.5, 0.626, 0.961, 0.217, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-03-11', 8.2, 69.5, 43.3, 13.6, 0.59, 0.981, 0.189, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-04-11', 8.4, 71, 43.7, 13.8, 0.452, 0.952, 0.044, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-05-11', 8.7, 72.5, 44, 13.9, 0.466, 0.992, 0.042, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-06-11', 9, 74, 44.3, 14.1, 0.49, 1.034, 0.049, 'normal');

-- Anak: Adi (L, lahir 2023-06-11, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-01-11', 10, 84.5, NULL, NULL, -2.546, -2.371, -1.807, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-02-11', 10.2, 85.3, NULL, NULL, -2.478, -2.31, -1.775, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-03-11', 10.3, 86.1, NULL, NULL, -2.484, -2.233, -1.87, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-04-11', 10.4, 86.9, NULL, NULL, -2.501, -2.176, -1.964, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-05-11', 10.6, 87.7, NULL, NULL, -2.429, -2.107, -1.93, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-06-11', 10.8, 88.5, NULL, NULL, -2.366, -2.048, -1.894, 'kurang');

-- Anak: Ayu (P, lahir 2024-08-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-01-11', 8.4, 77, 46.6, 15, -1.469, -0.939, -1.424, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-02-11', 8.6, 78, 47, 15.2, -1.451, -0.946, -1.376, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-03-11', 8.8, 79, 47.3, 15.3, -1.411, -0.902, -1.336, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-04-11', 9, 80, 47.6, 15.5, -1.393, -0.892, -1.306, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-05-11', 9.2, 81, 48, 15.6, -1.364, -0.856, -1.289, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-06-11', 9.3, 82, 48.3, 15.7, -1.438, -0.832, -1.409, 'normal');

-- Anak: Fauzi (L, lahir 2025-04-11, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-01-11', 9.8, 75, 44, 13.9, 0.878, 1.329, 0.369, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-02-11', 10, 76.3, 44.3, 14.1, 0.793, 1.297, 0.289, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-03-11', 10.2, 77.7, 44.6, 14.2, 0.744, 1.369, 0.205, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-04-11', 10.5, 79, 45, 14.3, 0.78, 1.377, 0.271, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-05-11', 10.7, 80.4, 45.3, 14.5, 0.737, 1.442, 0.202, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', '2026-06-11', 10.9, 81.8, 45.6, 14.6, 0.702, 1.518, 0.12, 'normal');

-- Anak: Bella (P, lahir 2024-02-11, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-01-11', 9.5, 83, 48.6, 15.9, -1.415, -0.793, -1.411, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-02-11', 9.7, 83.6, NULL, NULL, -1.397, -0.664, -1.319, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-03-11', 9.9, 84.2, NULL, NULL, -1.361, -0.714, -1.415, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-04-11', 10.1, 84.8, NULL, NULL, -1.339, -0.781, -1.335, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-05-11', 10.3, 85.4, NULL, NULL, -1.317, -0.84, -1.259, 'normal');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', '2026-06-11', 10.4, 86, NULL, NULL, -1.374, -0.893, -1.299, 'normal');

-- Anak: Bimo (L, lahir 2025-09-11, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-01-11', 5.5, 60.5, 40, 12.7, -2.106, -1.643, -1.325, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-02-11', 5.7, 61.8, 41.5, 13.1, -2.453, -1.959, -1.571, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-03-11', 5.9, 63.1, 43, 13.5, -2.632, -2.08, -1.771, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-04-11', 6.2, 64.4, 43.3, 13.6, -2.614, -2.17, -1.727, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-05-11', 6.4, 65.7, 43.7, 13.8, -2.678, -2.2, -1.869, 'kurang');
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan, zscore_bbu, zscore_tbu, zscore_bbtb, status_gizi) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '2026-06-11', 6.6, 67, 44, 13.9, -2.703, -2.199, -1.991, 'kurang');

-- ==========================================================
-- TIER 4: Riwayat Pemberian Vitamin A, Obat Cacing & PMT
-- ==========================================================

-- Rizki (usia: 12 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Rafi (usia: 32 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Nayla (usia: 8 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Hasan (usia: 24 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Husein (usia: 6 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Zahra (usia: 18 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Dani (usia: 30 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Dina (usia: 15 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Bagas (usia: 20 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Putri (usia: 10 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Adi (usia: 36 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Ayu (usia: 22 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Fauzi (usia: 14 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- Bella (usia: 28 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Merah 200.000 IU', '1 Kapsul Merah', '2026-01-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'obat_cacing', 'Albendazole 400mg', '1 Tablet', '2026-03-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', '019eb2ce-e72f-78ce-b432-a679426eafd7', 'pmt', 'Biskuit PMT Balita', '2 Kotak', '2026-05-11', NULL);

-- Bimo (usia: 9 bulan)
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a67557ded032', 'vitamin_a', 'Vitamin A Biru 100.000 IU', '1 Kapsul Biru', '2026-02-11', NULL);
INSERT INTO riwayat_pemberian (anak_id, kader_id, jenis, nama_item, dosis, tanggal_pemberian, keterangan) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', 'pmt', 'Biskuit PMT Balita', '1 Kotak', '2026-05-11', NULL);

-- ==========================================================
-- TIER 5: SAW Result + Detail (1 per pengukuran = 90 total)
-- ==========================================================

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 1, 0.2914, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_bbu', 0.3, 0.2938, 0.0881);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_tbu', 0.4, 0.1888, 0.0755);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'zscore_bbtb', 0.2, 0.3888, 0.0778);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (1, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 2, 0.3015, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_bbu', 0.3, 0.3032, 0.091);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_tbu', 0.4, 0.2088, 0.0835);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'zscore_bbtb', 0.2, 0.385, 0.077);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (2, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 3, 0.3002, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_bbu', 0.3, 0.2978, 0.0893);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_tbu', 0.4, 0.2154, 0.0862);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'zscore_bbtb', 0.2, 0.3736, 0.0747);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (3, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 4, 0.3104, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_bbu', 0.3, 0.3134, 0.094);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_tbu', 0.4, 0.2204, 0.0882);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'zscore_bbtb', 0.2, 0.391, 0.0782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (4, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 5, 0.3087, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_bbu', 0.3, 0.3062, 0.0919);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_tbu', 0.4, 0.2292, 0.0917);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'zscore_bbtb', 0.2, 0.3758, 0.0752);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (5, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 6, 0.3021, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_bbu', 0.3, 0.2972, 0.0892);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_tbu', 0.4, 0.2256, 0.0902);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'zscore_bbtb', 0.2, 0.3634, 0.0727);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (6, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 7, 0.2417, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_bbu', 0.3, 0.2144, 0.0643);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_tbu', 0.4, 0.1624, 0.065);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'zscore_bbtb', 0.2, 0.312, 0.0624);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (7, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 8, 0.2455, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_bbu', 0.3, 0.217, 0.0651);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_tbu', 0.4, 0.1724, 0.069);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'zscore_bbtb', 0.2, 0.3072, 0.0614);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (8, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 9, 0.2467, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_bbu', 0.3, 0.2172, 0.0652);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_tbu', 0.4, 0.1774, 0.071);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'zscore_bbtb', 0.2, 0.3028, 0.0606);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (9, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 10, 0.2507, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_bbu', 0.3, 0.2188, 0.0656);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_tbu', 0.4, 0.1902, 0.0761);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'zscore_bbtb', 0.2, 0.295, 0.059);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (10, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 11, 0.2524, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_bbu', 0.3, 0.2198, 0.0659);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_tbu', 0.4, 0.1952, 0.0781);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'zscore_bbtb', 0.2, 0.2918, 0.0584);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (11, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 12, 0.2537, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_bbu', 0.3, 0.2204, 0.0661);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_tbu', 0.4, 0.1992, 0.0797);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'zscore_bbtb', 0.2, 0.2896, 0.0579);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (12, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 13, 0.2443, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_bbu', 0.3, 0.209, 0.0627);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_tbu', 0.4, 0.1464, 0.0586);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'zscore_bbtb', 0.2, 0.365, 0.073);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (13, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 14, 0.2849, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_bbu', 0.3, 0.2674, 0.0802);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_tbu', 0.4, 0.1956, 0.0782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'zscore_bbtb', 0.2, 0.3822, 0.0764);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (14, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 15, 0.2877, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_bbu', 0.3, 0.281, 0.0843);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_tbu', 0.4, 0.1874, 0.075);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'zscore_bbtb', 0.2, 0.3924, 0.0785);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (15, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 16, 0.2887, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_bbu', 0.3, 0.2902, 0.0871);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_tbu', 0.4, 0.1808, 0.0723);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'zscore_bbtb', 0.2, 0.3964, 0.0793);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (16, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 17, 0.2745, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_bbu', 0.3, 0.282, 0.0846);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_tbu', 0.4, 0.152, 0.0608);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'zscore_bbtb', 0.2, 0.3956, 0.0791);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (17, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 18, 0.2597, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_bbu', 0.3, 0.2712, 0.0814);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_tbu', 0.4, 0.125, 0.05);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'zscore_bbtb', 0.2, 0.3918, 0.0784);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (18, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 19, 0.7065, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_bbu', 0.3, 0.8226, 0.2468);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_tbu', 0.4, 0.5998, 0.2399);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'zscore_bbtb', 0.2, 0.849, 0.1698);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (19, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 20, 0.7055, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_bbu', 0.3, 0.8142, 0.2443);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_tbu', 0.4, 0.6162, 0.2465);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'zscore_bbtb', 0.2, 0.824, 0.1648);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (20, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 21, 0.7, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_bbu', 0.3, 0.8024, 0.2407);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_tbu', 0.4, 0.6224, 0.249);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'zscore_bbtb', 0.2, 0.8016, 0.1603);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (21, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 22, 0.6856, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_bbu', 0.3, 0.7756, 0.2327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_tbu', 0.4, 0.6278, 0.2511);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'zscore_bbtb', 0.2, 0.7592, 0.1518);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (22, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 23, 0.6821, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_bbu', 0.3, 0.7664, 0.2299);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_tbu', 0.4, 0.6344, 0.2538);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'zscore_bbtb', 0.2, 0.742, 0.1484);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (23, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 24, 0.6624, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_bbu', 0.3, 0.7592, 0.2278);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_tbu', 0.4, 0.5982, 0.2393);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'zscore_bbtb', 0.2, 0.727, 0.1454);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (24, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 25, 0.2342, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_bbu', 0.3, 0.1712, 0.0514);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_tbu', 0.4, 0.1158, 0.0463);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'zscore_bbtb', 0.2, 0.4326, 0.0865);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (25, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 26, 0.3304, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_bbu', 0.3, 0.3154, 0.0946);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_tbu', 0.4, 0.235, 0.094);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'zscore_bbtb', 0.2, 0.459, 0.0918);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (26, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 27, 0.3365, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_bbu', 0.3, 0.33, 0.099);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_tbu', 0.4, 0.2408, 0.0963);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'zscore_bbtb', 0.2, 0.456, 0.0912);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (27, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 28, 0.3128, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_bbu', 0.3, 0.2992, 0.0898);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_tbu', 0.4, 0.231, 0.0924);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'zscore_bbtb', 0.2, 0.403, 0.0806);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (28, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 29, 0.2692, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_bbu', 0.3, 0.2576, 0.0773);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_tbu', 0.4, 0.1644, 0.0658);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'zscore_bbtb', 0.2, 0.3808, 0.0762);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (29, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 30, 0.2174, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_bbu', 0.3, 0.2088, 0.0626);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_tbu', 0.4, 0.083, 0.0332);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'zscore_bbtb', 0.2, 0.3578, 0.0716);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (30, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 31, 0.7152, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_bbu', 0.3, 0.7814, 0.2344);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_tbu', 0.4, 0.7224, 0.289);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'zscore_bbtb', 0.2, 0.7092, 0.1418);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (31, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 32, 0.7126, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_bbu', 0.3, 0.7756, 0.2327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_tbu', 0.4, 0.721, 0.2884);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'zscore_bbtb', 0.2, 0.7076, 0.1415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (32, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 33, 0.7058, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_bbu', 0.3, 0.767, 0.2301);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_tbu', 0.4, 0.7118, 0.2847);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'zscore_bbtb', 0.2, 0.705, 0.141);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (33, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 34, 0.7133, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_bbu', 0.3, 0.7828, 0.2348);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_tbu', 0.4, 0.7058, 0.2823);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'zscore_bbtb', 0.2, 0.7308, 0.1462);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (34, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 35, 0.7057, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_bbu', 0.3, 0.775, 0.2325);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_tbu', 0.4, 0.6956, 0.2782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'zscore_bbtb', 0.2, 0.725, 0.145);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (35, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 36, 0.6998, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_bbu', 0.3, 0.7694, 0.2308);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_tbu', 0.4, 0.6882, 0.2753);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'zscore_bbtb', 0.2, 0.7184, 0.1437);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (36, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 37, 0.788, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_bbu', 0.3, 0.8962, 0.2689);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_tbu', 0.4, 0.753, 0.3012);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'zscore_bbtb', 0.2, 0.8396, 0.1679);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (37, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 38, 0.7789, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_bbu', 0.3, 0.8846, 0.2654);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_tbu', 0.4, 0.7424, 0.297);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'zscore_bbtb', 0.2, 0.833, 0.1666);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (38, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 39, 0.7684, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_bbu', 0.3, 0.8712, 0.2614);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_tbu', 0.4, 0.728, 0.2912);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'zscore_bbtb', 0.2, 0.829, 0.1658);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (39, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 40, 0.7701, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_bbu', 0.3, 0.8772, 0.2632);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_tbu', 0.4, 0.7158, 0.2863);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'zscore_bbtb', 0.2, 0.8532, 0.1706);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (40, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 41, 0.7609, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_bbu', 0.3, 0.865, 0.2595);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_tbu', 0.4, 0.703, 0.2812);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'zscore_bbtb', 0.2, 0.8512, 0.1702);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (41, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 42, 0.7515, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_bbu', 0.3, 0.853, 0.2559);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_tbu', 0.4, 0.6894, 0.2758);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'zscore_bbtb', 0.2, 0.8492, 0.1698);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (42, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 43, 0.2694, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_bbu', 0.3, 0.252, 0.0756);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_tbu', 0.4, 0.2004, 0.0802);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'zscore_bbtb', 0.2, 0.318, 0.0636);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (43, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 44, 0.2806, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_bbu', 0.3, 0.2644, 0.0793);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_tbu', 0.4, 0.2152, 0.0861);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'zscore_bbtb', 0.2, 0.3258, 0.0652);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (44, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 45, 0.2729, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_bbu', 0.3, 0.2524, 0.0757);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_tbu', 0.4, 0.2132, 0.0853);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'zscore_bbtb', 0.2, 0.3096, 0.0619);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (45, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 46, 0.2797, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_bbu', 0.3, 0.261, 0.0783);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_tbu', 0.4, 0.2206, 0.0882);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'zscore_bbtb', 0.2, 0.3158, 0.0632);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (46, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 47, 0.273, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_bbu', 0.3, 0.2502, 0.0751);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_tbu', 0.4, 0.219, 0.0876);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'zscore_bbtb', 0.2, 0.3018, 0.0604);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (47, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 48, 0.2776, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_bbu', 0.3, 0.257, 0.0771);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_tbu', 0.4, 0.2206, 0.0882);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'zscore_bbtb', 0.2, 0.3114, 0.0623);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (48, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 49, 0.6809, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_bbu', 0.3, 0.7506, 0.2252);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_tbu', 0.4, 0.651, 0.2604);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'zscore_bbtb', 0.2, 0.7264, 0.1453);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (49, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 50, 0.6814, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_bbu', 0.3, 0.7446, 0.2234);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_tbu', 0.4, 0.6664, 0.2666);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'zscore_bbtb', 0.2, 0.7074, 0.1415);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (50, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 51, 0.6769, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_bbu', 0.3, 0.735, 0.2205);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_tbu', 0.4, 0.672, 0.2688);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'zscore_bbtb', 0.2, 0.6882, 0.1376);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (51, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 52, 0.6743, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_bbu', 0.3, 0.7294, 0.2188);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_tbu', 0.4, 0.677, 0.2708);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'zscore_bbtb', 0.2, 0.6736, 0.1347);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (52, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 53, 0.6705, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_bbu', 0.3, 0.7218, 0.2165);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_tbu', 0.4, 0.6826, 0.273);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'zscore_bbtb', 0.2, 0.6548, 0.131);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (53, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 54, 0.6793, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_bbu', 0.3, 0.7348, 0.2204);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_tbu', 0.4, 0.6904, 0.2762);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'zscore_bbtb', 0.2, 0.6636, 0.1327);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (54, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 55, 0.2649, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_bbu', 0.3, 0.2444, 0.0733);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_tbu', 0.4, 0.1804, 0.0722);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'zscore_bbtb', 0.2, 0.3472, 0.0694);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (55, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 56, 0.2869, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_bbu', 0.3, 0.2748, 0.0824);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_tbu', 0.4, 0.2078, 0.0831);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'zscore_bbtb', 0.2, 0.3566, 0.0713);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (56, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 57, 0.2886, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_bbu', 0.3, 0.282, 0.0846);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_tbu', 0.4, 0.2038, 0.0815);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'zscore_bbtb', 0.2, 0.3622, 0.0724);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (57, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 58, 0.305, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_bbu', 0.3, 0.3096, 0.0929);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_tbu', 0.4, 0.2096, 0.0838);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'zscore_bbtb', 0.2, 0.3912, 0.0782);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (58, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 59, 0.301, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_bbu', 0.3, 0.3068, 0.092);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_tbu', 0.4, 0.2016, 0.0806);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'zscore_bbtb', 0.2, 0.3916, 0.0783);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (59, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 60, 0.2959, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_bbu', 0.3, 0.302, 0.0906);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_tbu', 0.4, 0.1932, 0.0773);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'zscore_bbtb', 0.2, 0.3902, 0.078);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (60, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 61, 0.8247, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_bbu', 0.3, 0.9092, 0.2728);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_tbu', 0.4, 0.8742, 0.3497);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'zscore_bbtb', 0.2, 0.7614, 0.1523);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (61, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 62, 0.8145, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_bbu', 0.3, 0.8956, 0.2687);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_tbu', 0.4, 0.862, 0.3448);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'zscore_bbtb', 0.2, 0.755, 0.151);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (62, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 63, 0.8125, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_bbu', 0.3, 0.8968, 0.269);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_tbu', 0.4, 0.8466, 0.3386);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'zscore_bbtb', 0.2, 0.774, 0.1548);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (63, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 64, 0.8127, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_bbu', 0.3, 0.9002, 0.2701);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_tbu', 0.4, 0.8352, 0.3341);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'zscore_bbtb', 0.2, 0.7928, 0.1586);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (64, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 65, 0.8015, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_bbu', 0.3, 0.8858, 0.2657);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_tbu', 0.4, 0.8214, 0.3286);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'zscore_bbtb', 0.2, 0.786, 0.1572);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (65, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 66, 0.7916, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_bbu', 0.3, 0.8732, 0.262);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_tbu', 0.4, 0.8096, 0.3238);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'zscore_bbtb', 0.2, 0.7788, 0.1558);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (66, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 67, 0.6302, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_bbu', 0.3, 0.6938, 0.2081);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_tbu', 0.4, 0.5878, 0.2351);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'zscore_bbtb', 0.2, 0.6848, 0.137);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (67, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 68, 0.6278, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_bbu', 0.3, 0.6902, 0.2071);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_tbu', 0.4, 0.5892, 0.2357);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'zscore_bbtb', 0.2, 0.6752, 0.135);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (68, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 69, 0.6203, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_bbu', 0.3, 0.6822, 0.2047);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_tbu', 0.4, 0.5804, 0.2322);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'zscore_bbtb', 0.2, 0.6672, 0.1334);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (69, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 70, 0.6172, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_bbu', 0.3, 0.6786, 0.2036);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_tbu', 0.4, 0.5784, 0.2314);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'zscore_bbtb', 0.2, 0.6612, 0.1322);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (70, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 71, 0.6119, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_bbu', 0.3, 0.6728, 0.2018);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_tbu', 0.4, 0.5712, 0.2285);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'zscore_bbtb', 0.2, 0.6578, 0.1316);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (71, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 72, 0.6192, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_bbu', 0.3, 0.6876, 0.2063);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_tbu', 0.4, 0.5664, 0.2266);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'zscore_bbtb', 0.2, 0.6818, 0.1364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (72, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 73, 0.2362, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_bbu', 0.3, 0.2244, 0.0673);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_tbu', 0.4, 0.1342, 0.0537);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'zscore_bbtb', 0.2, 0.3262, 0.0652);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (73, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 74, 0.2471, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_bbu', 0.3, 0.2414, 0.0724);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_tbu', 0.4, 0.1406, 0.0562);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'zscore_bbtb', 0.2, 0.3422, 0.0684);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (74, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 75, 0.2476, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_bbu', 0.3, 0.2512, 0.0754);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_tbu', 0.4, 0.1262, 0.0505);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'zscore_bbtb', 0.2, 0.359, 0.0718);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (75, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 76, 0.2422, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_bbu', 0.3, 0.244, 0.0732);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_tbu', 0.4, 0.1246, 0.0498);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'zscore_bbtb', 0.2, 0.3458, 0.0692);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (76, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 77, 0.2423, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_bbu', 0.3, 0.2526, 0.0758);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_tbu', 0.4, 0.1116, 0.0446);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'zscore_bbtb', 0.2, 0.3596, 0.0719);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (77, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 78, 0.2416, 'rendah');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_bbu', 0.3, 0.2596, 0.0779);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_tbu', 0.4, 0.0964, 0.0386);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'zscore_bbtb', 0.2, 0.376, 0.0752);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (78, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 79, 0.6148, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_bbu', 0.3, 0.683, 0.2049);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_tbu', 0.4, 0.5586, 0.2234);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'zscore_bbtb', 0.2, 0.6822, 0.1364);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (79, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 80, 0.5997, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_bbu', 0.3, 0.6794, 0.2038);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_tbu', 0.4, 0.5328, 0.2131);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'zscore_bbtb', 0.2, 0.6638, 0.1328);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (80, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 81, 0.6054, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_bbu', 0.3, 0.6722, 0.2017);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_tbu', 0.4, 0.5428, 0.2171);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'zscore_bbtb', 0.2, 0.683, 0.1366);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (81, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 82, 0.6062, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_bbu', 0.3, 0.6678, 0.2003);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_tbu', 0.4, 0.5562, 0.2225);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'zscore_bbtb', 0.2, 0.667, 0.1334);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (82, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 83, 0.6066, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_bbu', 0.3, 0.6634, 0.199);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_tbu', 0.4, 0.568, 0.2272);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'zscore_bbtb', 0.2, 0.6518, 0.1304);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (83, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 84, 0.6158, 'sedang');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_bbu', 0.3, 0.6748, 0.2024);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_tbu', 0.4, 0.5786, 0.2314);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'zscore_bbtb', 0.2, 0.6598, 0.132);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (84, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 85, 0.7208, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_bbu', 0.3, 0.8212, 0.2464);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_tbu', 0.4, 0.7286, 0.2914);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'zscore_bbtb', 0.2, 0.665, 0.133);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (85, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 86, 0.7767, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_bbu', 0.3, 0.8906, 0.2672);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_tbu', 0.4, 0.7918, 0.3167);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'zscore_bbtb', 0.2, 0.7142, 0.1428);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (86, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 87, 0.8052, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_bbu', 0.3, 0.9264, 0.2779);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_tbu', 0.4, 0.816, 0.3264);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'zscore_bbtb', 0.2, 0.7542, 0.1508);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (87, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 88, 0.8095, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_bbu', 0.3, 0.9228, 0.2768);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_tbu', 0.4, 0.834, 0.3336);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'zscore_bbtb', 0.2, 0.7454, 0.1491);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (88, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 89, 0.8214, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_bbu', 0.3, 0.9356, 0.2807);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_tbu', 0.4, 0.84, 0.336);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'zscore_bbtb', 0.2, 0.7738, 0.1548);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (89, 'frekuensi_hadir', 0.1, 0.5, 0.05);

INSERT INTO saw_result (anak_id, pengukuran_id, skor_akhir, kategori_risiko) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 90, 0.8277, 'tinggi');
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_bbu', 0.3, 0.9406, 0.2822);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_tbu', 0.4, 0.8398, 0.3359);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'zscore_bbtb', 0.2, 0.7982, 0.1596);
INSERT INTO saw_result_detail (saw_result_id, nama_kriteria, bobot, nilai, skor) VALUES
    (90, 'frekuensi_hadir', 0.1, 0.5, 0.05);

-- ==========================================================
-- TIER 6: Rujukan (anak kategori risiko tinggi)
-- ==========================================================

-- Rujukan untuk: Zahra | Status: selesai
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', '019eb2ce-e72f-78ce-b432-a679426eafd7', '019eb2ce-e72f-78ce-b432-a67b582ecea9', 36, 'selesai', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6998.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-15');

-- Rujukan untuk: Dani | Status: diterima
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', '019eb2ce-e72f-78ce-b432-a67557ded032', '019eb2ce-e72f-78ce-b432-a67b582ecea9', 42, 'diterima', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7515.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-16');

-- Rujukan untuk: Bagas | Status: diajukan
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', '019eb2ce-e72f-78ce-b432-a679426eafd7', NULL, 54, 'diajukan', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6793.', NULL, NULL);

-- Rujukan untuk: Adi | Status: diajukan
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', '019eb2ce-e72f-78ce-b432-a6776ffa1e0c', NULL, 66, 'diajukan', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7916.', NULL, NULL);

-- Rujukan untuk: Bimo | Status: ditolak
INSERT INTO rujukan (anak_id, kader_id, puskesmas_user_id, saw_result_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', '019eb2ce-e72f-78ce-b432-a679426eafd7', '019eb2ce-e72f-78ce-b432-a67b582ecea9', 90, 'ditolak', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.8277.', 'Kondisi anak tidak memenuhi kriteria rujukan saat ini. Disarankan kontrol rutin di posyandu setiap bulan.', '2026-05-19');

-- ==========================================================
-- TIER 6: AI Insight — teks statis (1 per anak)
-- ==========================================================

-- Rizki (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a692773e875a', 6, '[Seeder] Anak: Rizki, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Rafi (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69399906db1', 12, '[Seeder] Anak: Rafi, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Nayla (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69450e768c1', 18, '[Seeder] Anak: Nayla, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Hasan (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a695cd255cdf', 24, '[Seeder] Anak: Hasan, JK: L, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Husein (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a696d040ba6f', 30, '[Seeder] Anak: Husein, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Zahra (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69728f62c82', 36, '[Seeder] Anak: Zahra, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Dani (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a6988c33da76', 42, '[Seeder] Anak: Dani, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- Dina (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69935e67d7a', 48, '[Seeder] Anak: Dina, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Bagas (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69a7d09ec97', 54, '[Seeder] Anak: Bagas, JK: L, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Putri (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69b747fb431', 60, '[Seeder] Anak: Putri, JK: P, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Adi (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69cf93fb963', 66, '[Seeder] Anak: Adi, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- Ayu (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69d440f8d0d', 72, '[Seeder] Anak: Ayu, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Fauzi (normal)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69eed413088', 78, '[Seeder] Anak: Fauzi, JK: L, Scenario: normal, Status Gizi: normal', '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.');

-- Bella (kurang)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a69f12e20712', 84, '[Seeder] Anak: Bella, JK: P, Scenario: kurang, Status Gizi: normal', '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.');

-- Bimo (buruk)
INSERT INTO ai_insight (anak_id, pengukuran_id, prompt_konteks, insight_teks) VALUES
    ('019eb2ce-e72f-78ce-b432-a6a0aa24208a', 90, '[Seeder] Anak: Bimo, JK: L, Scenario: buruk, Status Gizi: kurang', '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.');

-- ==========================================================
-- TIER 7: Notifikasi
-- Jadwal ID 6 = Posyandu Juni 2026 (jadwal mendatang pertama)
-- ==========================================================

-- Notifikasi jadwal posyandu Juni 2026
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a67fcb8c3c22', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a681b9f4546e', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a683ee87cb78', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68566dc2381', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68703f131db', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a6896f16de42', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68b6bf3d550', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68d67a01582', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68fabee42db', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a6918f838c19', 'Jadwal Posyandu Juni 2026', 'Posyandu rutin Juni 2026 akan dilaksanakan pada 15 Juni 2026 pukul 08.30 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-08 08:00:00', 6, NULL);

-- Notifikasi status rujukan
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68566dc2381', 'Rujukan Selesai Ditangani', 'Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.', 'rujukan', TRUE, '2026-06-01 10:00:00', NULL, 1);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68703f131db', 'Rujukan Diterima Puskesmas', 'Rujukan anak Anda telah diterima oleh puskesmas. Silakan datang untuk menjalani pemeriksaan dan program intervensi gizi yang telah disiapkan.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 2);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a6896f16de42', 'Rujukan Baru Telah Diajukan', 'Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 3);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a68d67a01582', 'Rujukan Baru Telah Diajukan', 'Kader telah mengajukan rujukan untuk anak Anda ke puskesmas. Harap segera datang ke puskesmas terdekat untuk pemeriksaan dan penanganan lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 4);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('019eb2ce-e72f-78ce-b432-a6918f838c19', 'Update Status Rujukan', 'Status rujukan anak Anda telah diperbarui. Silakan hubungi kader atau puskesmas untuk informasi lebih lanjut.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 5);
