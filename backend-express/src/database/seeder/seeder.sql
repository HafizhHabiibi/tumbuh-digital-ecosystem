-- ==========================================================
-- FULL RESET — Hapus semua data lama (urutan FK terbalik)
-- ==========================================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notification_outbox;
TRUNCATE TABLE notifikasi;
TRUNCATE TABLE rujukan;
TRUNCATE TABLE pemberian;
TRUNCATE TABLE pengukuran;
TRUNCATE TABLE anak;
TRUNCATE TABLE jadwal_posyandu;
TRUNCATE TABLE pengaturan_jadwal;
TRUNCATE TABLE orang_tua;
TRUNCATE TABLE kader;
TRUNCATE TABLE puskesmas;
TRUNCATE TABLE refresh_tokens;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- TIER 1: Users, Kader, Puskesmas
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc36-7af9-adf5-be17c3abc50d', 'meongterbang22@gmail.com', '$2b$10$UlAqXs8R8u5wl9jG.FbM2.CBukVT2IHTYv/K4iYz4d77Tf4CM3F.G', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('01a03ede-bc37-70f3-847e-a4e57772c1ad', '01a03ede-bc36-7af9-adf5-be17c3abc50d', 'Riri Andayani', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4e646ccbbad', 'budi.kader@gmail.com', '$2b$10$Oewvf3cOQQeoS3evhPwEouU5l4SYM1J8gnOdLQBCDOTpjrlhGbt6a', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('01a03ede-bc37-70f3-847e-a4e7a80126ca', '01a03ede-bc37-70f3-847e-a4e646ccbbad', 'Budi Santoso', '082345678901');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4e8db48c926', 'sari.kader@gmail.com', '$2b$10$VUBaGISozpFFzAZIRic3heTRCBfqYNMXWINEjinSgySP0E7k0qyoG', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('01a03ede-bc37-70f3-847e-a4e95abe1c20', '01a03ede-bc37-70f3-847e-a4e8db48c926', 'Sari Dewi', '083456789012');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4ea61e901fa', 'bullmini123@gmail.com', '$2b$10$iy4T8V5NC7rWRF2bC7Tvz.LDIxGQ6NORMQ6T9uIPdSFQUpqKuATSu', 'puskesmas', TRUE);
INSERT INTO puskesmas (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('01a03ede-bc37-70f3-847e-a4eba14b553c', '01a03ede-bc37-70f3-847e-a4ea61e901fa', 'Ciko Wijaya', 'Bidan', '081234567891');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4ec0b3cbd6e', 'hana.pertiwi@gmail.com', '$2b$10$CeRhEZDUe5g5xUAiZzgwfuvcFfkhW6TAHXirJTPuRsedUDmeehRwa', 'puskesmas', TRUE);
INSERT INTO puskesmas (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('01a03ede-bc37-70f3-847e-a4ed4ebd8ef7', '01a03ede-bc37-70f3-847e-a4ec0b3cbd6e', 'dr. Hana Pertiwi', 'Dokter', '084567890123');

-- ==========================================================
-- TIER 2: Orang Tua
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4eeecb3970a', 'aminah.kusuma@gmail.com', '$2b$10$mzeM0Q4d7v0acFK6hUnXUOBrP9IhTiHk4bFzPWGPcU.Ijb/YuLQVO', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4ef78a3ac14', '01a03ede-bc37-70f3-847e-a4eeecb3970a', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'Aminah Kusuma', '081111111101', 'Jl. Mawar No. 12 RT 01 RW 05', '3201010101870001');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4f0338ac14e', 'dewi.susanti@gmail.com', '$2b$10$bDUBhtkRfV9ovrJEcsjoIezNQTT.Z8ls9tOQS5EbcMGhEIMB1pWky', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4f1f91f8798', '01a03ede-bc37-70f3-847e-a4f0338ac14e', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'Dewi Susanti', '081111111102', 'Jl. Melati No. 5 RT 02 RW 05', '3201010201890002');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4f2e08ecfcf', 'fatimah.rahman@gmail.com', '$2b$10$EnxQc/0Pm7qyCq3QlGUjyeyb5wp5WbtyCZeEFy14taO3IYYFG7SHe', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4f382a89c3a', '01a03ede-bc37-70f3-847e-a4f2e08ecfcf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'Fatimah Rahman', '081111111103', 'Jl. Anggrek No. 8 RT 03 RW 05', '3201010301850003');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4f40fdd4fc7', 'siti.rahayu@gmail.com', '$2b$10$kBkAFYOzKvmrwiYRngKDaOwJoUNx/AsiwRrful0Ykps3dIEgToz36', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4f5b37becbc', '01a03ede-bc37-70f3-847e-a4f40fdd4fc7', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'Siti Rahayu', '081111111104', 'Jl. Dahlia No. 3 RT 01 RW 05', '3201010401900004');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4f63ae90a95', 'kartini.wulandari@gmail.com', '$2b$10$yl2m3BIGUFdWO7c8P2FHguqDAxf95zMvM2sAAcWeIRXAwIvHIwANq', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4f76078c67b', '01a03ede-bc37-70f3-847e-a4f63ae90a95', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'Kartini Wulandari', '081111111105', 'Jl. Kenanga No. 7 RT 04 RW 05', '3201010501880005');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4f8a661f4c7', 'rahayu.lestari@gmail.com', '$2b$10$fMDPeTIKst0d1okn4uQJKODozumsl8wuIjHKI66Iu1x/oXq9oOeNu', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4f98a4a1135', '01a03ede-bc37-70f3-847e-a4f8a661f4c7', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'Rahayu Lestari', '081111111106', 'Jl. Bougenville No. 15 RT 02 RW 05', '3201010601910006');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4fa60abc1f5', 'wulan.sari@gmail.com', '$2b$10$HXVieLT9LdSE6ETKYQxU9.Hf5tqWNLXLwHy/KYmwXsYKSHzPcYD4q', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4fb3df8de7b', '01a03ede-bc37-70f3-847e-a4fa60abc1f5', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'Wulan Sari', '081111111107', 'Jl. Cempaka No. 4 RT 03 RW 05', '3201010701920007');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4fc581a8a95', 'lestari.handayani@gmail.com', '$2b$10$bQfDa5.z42L0ME8RLxDuUOo1/EflOEdIN2Dt8N51YMofKYZqda2MK', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4fd152d72a5', '01a03ede-bc37-70f3-847e-a4fc581a8a95', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'Lestari Handayani', '081111111108', 'Jl. Flamboyan No. 9 RT 05 RW 05', '3201010801860008');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a4fe7a5b4d50', 'nuraini.putri@gmail.com', '$2b$10$Kc.quXja7vkZgWlroy2HC.2XeFV2eErDwRRojNA0ods50TYH1/9Si', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a4ff3f530615', '01a03ede-bc37-70f3-847e-a4fe7a5b4d50', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'Nuraini Putri', '081111111109', 'Jl. Kamboja No. 2 RT 01 RW 05', '3201010901930009');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a03ede-bc37-70f3-847e-a5001fe6a5da', 'sumiati.wahyu@gmail.com', '$2b$10$9/ck4INAa7l85QyvpxTON.RDUj0auLHmpz26QyjUisPJ0VP6hY8R6', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a5010ee42aa6', '01a03ede-bc37-70f3-847e-a5001fe6a5da', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'Sumiati Wahyu', '081111111110', 'Jl. Teratai No. 6 RT 04 RW 05', '3201011001870010');

-- ==========================================================
-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)
-- ==========================================================

INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-01-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Januari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-02-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Februari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-03-03', '08:30', '11:30', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Maret 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-04-03', '08:00', '12:00', 'Puskesmas Pembantu Cempaka', 'Posyandu + Pemberian Vitamin A Massal');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-05-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Mei 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-06-03', '08:30', '12:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juni 2026 - Pembagian PMT');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-07-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juli 2026');

-- ==========================================================
-- TIER 2: Pengaturan Jadwal (template default)
-- ==========================================================

INSERT INTO pengaturan_jadwal (hari_tetap, waktu_mulai, waktu_selesai, lokasi_default, updated_by) VALUES
    (3, '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', '01a03ede-bc37-70f3-847e-a4e57772c1ad');

-- ==========================================================
-- TIER 3: Anak (15 anak)
-- ==========================================================

INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4ef78a3ac14', 'Rizki', 'L', '2025-06-17', '3201011234560001');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4ef78a3ac14', 'Rafi', 'L', '2023-10-15', '3201011234560002');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4f1f91f8798', 'Nayla', 'P', '2025-10-22', '3201011234560003');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4f382a89c3a', 'Hasan', 'L', '2024-06-03', '3201011234560004');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4f382a89c3a', 'Husein', 'L', '2025-12-03', '3201011234560005');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4f5b37becbc', 'Zahra', 'P', '2024-12-08', '3201011234560006');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4f76078c67b', 'Dani', 'L', '2023-12-19', '3201011234560007');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4f76078c67b', 'Dina', 'P', '2025-03-14', '3201011234560008');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4f98a4a1135', 'Bagas', 'L', '2024-10-25', '3201011234560009');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4fb3df8de7b', 'Putri', 'P', '2025-08-07', '3201011234560010');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4fd152d72a5', 'Adi', 'L', '2023-06-20', '3201011234560011');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4fd152d72a5', 'Ayu', 'P', '2024-08-16', '3201011234560012');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4ff3f530615', 'Fauzi', 'L', '2025-04-09', '3201011234560013');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a5010ee42aa6', 'Bella', 'P', '2024-02-13', '3201011234560014');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a5010ee42aa6', 'Bimo', 'L', '2025-09-21', '3201011234560015');

-- ==========================================================
-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)
-- Z-score dihitung otomatis menggunakan WHO tables
-- ==========================================================

-- Anak: Rizki (L, lahir 2025-06-17, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-01-03', 8.8, 71.5, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-02-03', 9.1, 72.8, 43.3, 13.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-03-03', 9.4, 74, 43.7, 13.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-04-03', 9.6, 75.3, 44, 13.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-05-03', 9.9, 76.5, 44.3, 14.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-06-03', 10.2, 77.8, 44.6, 14.2);

-- Anak: Rafi (L, lahir 2023-10-15, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-01-03', 14.2, 93.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-02-03', 14.4, 94.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-03-03', 14.6, 94.9, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-04-03', 14.8, 95.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-05-03', 15, 96.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-06-03', 15.2, 96.9, NULL, NULL);

-- Anak: Nayla (P, lahir 2025-10-22, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-01-03', 6.6, 62.5, 37, 11.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-02-03', 7, 64.4, 38.5, 12.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-03-03', 7.4, 66.3, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-04-03', 7.8, 68.2, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-05-03', 8.2, 70.1, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-06-03', 8.6, 72, 43.3, 13.6);

-- Anak: Hasan (L, lahir 2024-06-03, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-01-03', 8.8, 80.5, 47.3, 15.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-02-03', 9, 81.2, 47.6, 15.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-03-03', 9.2, 81.9, 48, 15.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-04-03', 9.5, 82.7, 48.3, 15.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-05-03', 9.7, 83.4, 48.6, 15.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-06-03', 9.9, 84.1, NULL, NULL);

-- Anak: Husein (L, lahir 2025-12-03, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-01-03', 5.2, 57.5, 35.5, 11.4);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-02-03', 5.9, 60.2, 37, 11.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-03-03', 6.6, 62.9, 38.5, 12.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-04-03', 7.4, 65.6, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-05-03', 8.1, 68.3, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-06-03', 8.8, 71, 43, 13.5);

-- Anak: Zahra (P, lahir 2024-12-08, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-01-03', 7.3, 71, 45, 14.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-02-03', 7.5, 72.1, 45.3, 14.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-03-03', 7.7, 73.2, 45.6, 14.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-04-03', 7.8, 74.3, 46, 14.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-05-03', 8, 75.4, 46.3, 14.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-06-03', 8.2, 76.5, 46.6, 15);

-- Anak: Dani (L, lahir 2023-12-19, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-01-03', 9.3, 82.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-02-03', 9.5, 83.4, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-03-03', 9.7, 84.3, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-04-03', 9.8, 85.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-05-03', 10, 86.1, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-06-03', 10.2, 87, NULL, NULL);

-- Anak: Dina (P, lahir 2025-03-14, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-01-03', 9.3, 74, 44, 13.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-02-03', 9.5, 75.2, 44.3, 14.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-03-03', 9.8, 76.4, 44.6, 14.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-04-03', 10, 77.6, 45, 14.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-05-03', 10.3, 78.8, 45.3, 14.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-06-03', 10.5, 80, 45.6, 14.6);

-- Anak: Bagas (L, lahir 2024-10-25, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-01-03', 8.5, 76, 45.6, 14.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-02-03', 8.7, 76.8, 46, 14.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-03-03', 8.9, 77.6, 46.3, 14.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-04-03', 9.1, 78.5, 46.6, 15);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-05-03', 9.3, 79.3, 47, 15.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-06-03', 9.4, 80.1, 47.3, 15.3);

-- Anak: Putri (P, lahir 2025-08-07, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-01-03', 7.6, 66.5, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-02-03', 7.9, 68, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-03-03', 8.2, 69.5, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-04-03', 8.4, 71, 43.3, 13.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-05-03', 8.7, 72.5, 43.7, 13.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-06-03', 9, 74, 44, 13.9);

-- Anak: Adi (L, lahir 2023-06-20, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-01-03', 10, 84.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-02-03', 10.2, 85.3, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-03-03', 10.3, 86.1, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-04-03', 10.4, 86.9, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-05-03', 10.6, 87.7, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-06-03', 10.8, 88.5, NULL, NULL);

-- Anak: Ayu (P, lahir 2024-08-16, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-01-03', 8.4, 77, 46.3, 14.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-02-03', 8.6, 78, 46.6, 15);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-03-03', 8.8, 79, 47, 15.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-04-03', 9, 80, 47.3, 15.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-05-03', 9.2, 81, 47.6, 15.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-06-03', 9.3, 82, 48, 15.6);

-- Anak: Fauzi (L, lahir 2025-04-09, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-01-03', 9.8, 75, 43.7, 13.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-02-03', 10, 76.3, 44, 13.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-03-03', 10.2, 77.7, 44.3, 14.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-04-03', 10.5, 79, 44.6, 14.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-05-03', 10.7, 80.4, 45, 14.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', '2026-06-03', 10.9, 81.8, 45.3, 14.5);

-- Anak: Bella (P, lahir 2024-02-13, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-01-03', 9.5, 83, 48.3, 15.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-02-03', 9.7, 83.6, 48.6, 15.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-03-03', 9.9, 84.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-04-03', 10.1, 84.8, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-05-03', 10.3, 85.4, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', '2026-06-03', 10.4, 86, NULL, NULL);

-- Anak: Bimo (L, lahir 2025-09-21, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-01-03', 5.5, 60.5, 38.5, 12.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-02-03', 5.7, 61.8, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-03-03', 5.9, 63.1, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-04-03', 6.2, 64.4, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-05-03', 6.4, 65.7, 43.3, 13.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e95abe1c20', '2026-06-03', 6.6, 67, 43.7, 13.8);

-- ==========================================================
-- TIER 4: Pemberian Vitamin A, Obat Cacing & PMT
-- ==========================================================

-- Rizki (usia: 11 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a502683abbca', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Rafi (usia: 31 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a503b01fe176', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Nayla (usia: 7 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a504203811fb', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Hasan (usia: 24 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5054d5168d2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Husein (usia: 6 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5068a3b2c73', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Zahra (usia: 17 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50729c1e7f2', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Dani (usia: 29 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a5089dc92ec9', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Dina (usia: 14 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a509a2743b2b', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Bagas (usia: 19 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50a32c632bf', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Putri (usia: 9 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50b654868a3', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Adi (usia: 35 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50c99ae9731', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Ayu (usia: 21 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50da04922dd', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Fauzi (usia: 13 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50e6cc7f3b1', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Bella (usia: 27 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a50fd12869ee', '01a03ede-bc37-70f3-847e-a4e95abe1c20', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Bimo (usia: 8 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e57772c1ad', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a03ede-bc37-70f3-847e-a51020c65688', '01a03ede-bc37-70f3-847e-a4e7a80126ca', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- ==========================================================
-- TIER 6: Rujukan (anak kategori risiko tinggi)
-- ==========================================================

-- Rujukan untuk: Adi | Status: selesai
INSERT INTO rujukan (kader_id, puskesmas_id, pengukuran_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('01a03ede-bc37-70f3-847e-a4e7a80126ca', '01a03ede-bc37-70f3-847e-a4eba14b553c', 66, 'selesai', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.7071.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-15');

-- Rujukan untuk: Bimo | Status: ditangani
INSERT INTO rujukan (kader_id, puskesmas_id, pengukuran_id, status, catatan_kader, catatan_puskesmas, validated_at) VALUES
    ('01a03ede-bc37-70f3-847e-a4e95abe1c20', '01a03ede-bc37-70f3-847e-a4eba14b553c', 90, 'ditangani', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.6951.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-16');

-- ==========================================================
-- TIER 6: AI Insight — UPDATE pengukuran.insight_teks (1 per anak)
-- ==========================================================

-- Rizki (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 6;

-- Rafi (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 12;

-- Nayla (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 18;

-- Hasan (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 24;

-- Husein (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 30;

-- Zahra (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 36;

-- Dani (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.' WHERE id = 42;

-- Dina (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 48;

-- Bagas (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 54;

-- Putri (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 60;

-- Adi (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.' WHERE id = 66;

-- Ayu (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 72;

-- Fauzi (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Risiko stunting tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 78;

-- Bella (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Risiko stunting tergolong sedang dan perlu diwaspadai sejak dini.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 84;

-- Bimo (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Kondisi ini menunjukkan risiko stunting yang tinggi dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.' WHERE id = 90;

-- ==========================================================
-- TIER 7: Notifikasi
-- Jadwal ID 7 = Posyandu Juli 2026 (jadwal mendatang = hari demo)
-- ==========================================================

-- Notifikasi jadwal posyandu Juli 2026
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4ef78a3ac14', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4f1f91f8798', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4f382a89c3a', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4f5b37becbc', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4f76078c67b', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4f98a4a1135', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4fb3df8de7b', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4fd152d72a5', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4ff3f530615', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a5010ee42aa6', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);

-- Notifikasi status rujukan
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a4fd152d72a5', 'Rujukan Selesai Ditangani', 'Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.', 'rujukan', TRUE, '2026-06-01 10:00:00', NULL, 1);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a03ede-bc37-70f3-847e-a5010ee42aa6', 'Rujukan Sedang Ditangani', 'Rujukan anak Anda sedang ditangani oleh puskesmas. Silakan datang untuk pemeriksaan.', 'rujukan', FALSE, '2026-06-01 10:00:00', NULL, 2);
