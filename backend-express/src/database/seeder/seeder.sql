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
    ('01a053bb-fb3e-7fcd-bc42-a599a4f4d33c', 'meongterbang22@gmail.com', '$2b$10$2CL2mF39piuIn9FOEjbLd.J42PZKvq8IZRtkBlEOcBjBKI8EPiT4y', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '01a053bb-fb3e-7fcd-bc42-a599a4f4d33c', 'Riri Andayani', '081234567890');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47cac09bdcb', 'budi.kader@gmail.com', '$2b$10$NO8oUnYwA7O.OUGNywYZx.dChWwP7m/c9ar53P183nGtANvKIPpoK', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '01a053bb-fb3f-7b2a-ae2e-e47cac09bdcb', 'Budi Santoso', '082345678901');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47e78397374', 'sari.kader@gmail.com', '$2b$10$xI1RyOUs79p6Wj8fgawiOu4HPIWawYHD7lYcQ8/6TSBqjdLl/IT.y', 'kader', TRUE);
INSERT INTO kader (id, user_id, nama_lengkap, no_hp) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '01a053bb-fb3f-7b2a-ae2e-e47e78397374', 'Sari Dewi', '083456789012');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e480ca12c0b8', 'bullmini123@gmail.com', '$2b$10$UYp.AaHeHX0Qcpq71X2EYuGqYkXIqQWQbZyOj/jv1paSMNOh4epgq', 'puskesmas', TRUE);
INSERT INTO puskesmas (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48116394f55', '01a053bb-fb3f-7b2a-ae2e-e480ca12c0b8', 'Ciko Wijaya', 'Bidan', '081234567891');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4821d9e6f69', 'hana.pertiwi@gmail.com', '$2b$10$W5/6LJojewBZ9PS/cswwIu37jbRQkrAI6.L9hIA/PGrI7Ki9wTHWS', 'puskesmas', TRUE);
INSERT INTO puskesmas (id, user_id, nama_lengkap, jabatan, no_hp) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48307ff8d45', '01a053bb-fb3f-7b2a-ae2e-e4821d9e6f69', 'dr. Hana Pertiwi', 'Dokter', '084567890123');

-- ==========================================================
-- TIER 2: Orang Tua
-- ==========================================================

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48482d1eea2', 'aminah.kusuma@gmail.com', '$2b$10$5Ut5yuD3wvbRPX4upOe7XuQjLflsobaHbM/mPZXFhlePzl89Cx4BC', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e485c9299aff', '01a053bb-fb3f-7b2a-ae2e-e48482d1eea2', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'Aminah Kusuma', '081111111101', 'Jl. Mawar No. 12 RT 01 RW 05', '3201010101870001');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e486b7958eae', 'dewi.susanti@gmail.com', '$2b$10$d0r7FObwGDCqBZVTh/kHseoBnjoZVJW5tM6x1GsL1aLno20bAU/1W', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e487651e0ad0', '01a053bb-fb3f-7b2a-ae2e-e486b7958eae', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'Dewi Susanti', '081111111102', 'Jl. Melati No. 5 RT 02 RW 05', '3201010201890002');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48898cce048', 'fatimah.rahman@gmail.com', '$2b$10$VXJdGXSNSkNM5oT.vtAm1.n1sxG7GqjZJexLsVQB7hA0C55bxaec2', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48974295630', '01a053bb-fb3f-7b2a-ae2e-e48898cce048', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'Fatimah Rahman', '081111111103', 'Jl. Anggrek No. 8 RT 03 RW 05', '3201010301850003');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48ae57ce66d', 'siti.rahayu@gmail.com', '$2b$10$f9BoUdcEFnkkXp1TAi6fuuIlRPuz5PGt0ENCPcfRC.OzxbQ6mTIIm', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48b4cf3b5f5', '01a053bb-fb3f-7b2a-ae2e-e48ae57ce66d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'Siti Rahayu', '081111111104', 'Jl. Dahlia No. 3 RT 01 RW 05', '3201010401900004');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48c00c5a32d', 'kartini.wulandari@gmail.com', '$2b$10$BcIX7sfv04oFXTUZjysdY.CgAER9A0y9UUUrHQQSFK10t5e6TalAu', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48d81ef5b14', '01a053bb-fb3f-7b2a-ae2e-e48c00c5a32d', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'Kartini Wulandari', '081111111105', 'Jl. Kenanga No. 7 RT 04 RW 05', '3201010501880005');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48e30953be0', 'rahayu.lestari@gmail.com', '$2b$10$QzPeaNRSsN31mgrWdWPtg.6k6/aVhTy942rKjqmYkzEsNOPbRmIdi', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48f0f1afec6', '01a053bb-fb3f-7b2a-ae2e-e48e30953be0', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'Rahayu Lestari', '081111111106', 'Jl. Bougenville No. 15 RT 02 RW 05', '3201010601910006');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4900c20a059', 'wulan.sari@gmail.com', '$2b$10$CDwmi/WGZhiJJAmwDk4w.emXWI7e9a/pwdmG4pKwpCpG03X8dQJqu', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e491d98f2c80', '01a053bb-fb3f-7b2a-ae2e-e4900c20a059', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'Wulan Sari', '081111111107', 'Jl. Cempaka No. 4 RT 03 RW 05', '3201010701920007');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4920a40afd0', 'lestari.handayani@gmail.com', '$2b$10$2Ez4EH.0hM.l1Vz3KvwPF.cI7z9vQ00CGKA.0SjxPDF8p7oTnrgw.', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e493bb2fdec4', '01a053bb-fb3f-7b2a-ae2e-e4920a40afd0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'Lestari Handayani', '081111111108', 'Jl. Flamboyan No. 9 RT 05 RW 05', '3201010801860008');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49421a4ee5e', 'nuraini.putri@gmail.com', '$2b$10$Q4rNc/AMeJ1QB/d5Dwg7ZOgM8p9tJAh5KaqglIbQsnO3aV2TowEiO', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e495f9eb23d9', '01a053bb-fb3f-7b2a-ae2e-e49421a4ee5e', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'Nuraini Putri', '081111111109', 'Jl. Kamboja No. 2 RT 01 RW 05', '3201010901930009');

INSERT INTO users (id, email, password_hash, role, is_active) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49602ad4be0', 'sumiati.wahyu@gmail.com', '$2b$10$14Vw6WTxOjahgxdjXfRmBufOiXpQlo27zW/VYl1sgFiQzkpCqFf2W', 'orang_tua', TRUE);
INSERT INTO orang_tua (id, user_id, dibuat_oleh_kader_id, nama_lengkap, no_hp, alamat, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4974bd52e24', '01a053bb-fb3f-7b2a-ae2e-e49602ad4be0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'Sumiati Wahyu', '081111111110', 'Jl. Teratai No. 6 RT 04 RW 05', '3201011001870010');

-- ==========================================================
-- TIER 2: Jadwal Posyandu (5 lampau + 3 mendatang)
-- ==========================================================

INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-01-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Januari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-02-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Februari 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-03-03', '08:30', '11:30', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Maret 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-04-03', '08:00', '12:00', 'Puskesmas Pembantu Cempaka', 'Posyandu + Pemberian Vitamin A Massal');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-05-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Mei 2026');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-06-03', '08:30', '12:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juni 2026 - Pembagian PMT');
INSERT INTO jadwal_posyandu (kader_id, tanggal, waktu_mulai, waktu_selesai, lokasi, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-07-03', '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', 'Posyandu Rutin Juli 2026');

-- ==========================================================
-- TIER 2: Pengaturan Jadwal (template default)
-- ==========================================================

INSERT INTO pengaturan_jadwal (hari_tetap, waktu_mulai, waktu_selesai, lokasi_default, updated_by) VALUES
    (3, '08:00', '11:00', 'Balai RW 05 Kelurahan Cempaka', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6');

-- ==========================================================
-- TIER 3: Anak (15 anak)
-- ==========================================================

INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e485c9299aff', 'Rizki', 'L', '2025-06-17', '3201011234560001');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e485c9299aff', 'Rafi', 'L', '2023-10-15', '3201011234560002');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e487651e0ad0', 'Nayla', 'P', '2025-10-22', '3201011234560003');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e48974295630', 'Hasan', 'L', '2024-06-03', '3201011234560004');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e48974295630', 'Husein', 'L', '2025-12-03', '3201011234560005');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e48b4cf3b5f5', 'Zahra', 'P', '2024-12-08', '3201011234560006');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e48d81ef5b14', 'Dani', 'L', '2023-12-19', '3201011234560007');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e48d81ef5b14', 'Dina', 'P', '2025-03-14', '3201011234560008');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e48f0f1afec6', 'Bagas', 'L', '2024-10-25', '3201011234560009');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e491d98f2c80', 'Putri', 'P', '2025-08-07', '3201011234560010');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e493bb2fdec4', 'Adi', 'L', '2023-06-20', '3201011234560011');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e493bb2fdec4', 'Ayu', 'P', '2024-08-16', '3201011234560012');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e495f9eb23d9', 'Fauzi', 'L', '2025-04-09', '3201011234560013');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e4974bd52e24', 'Bella', 'P', '2024-02-13', '3201011234560014');
INSERT INTO anak (id, orang_tua_id, nama, jenis_kelamin, tanggal_lahir, nik) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e4974bd52e24', 'Bimo', 'L', '2025-09-21', '3201011234560015');

-- ==========================================================
-- TIER 4: Pengukuran (6 titik historis per anak = 90 total)
-- Z-score dihitung otomatis menggunakan WHO tables
-- ==========================================================

-- Anak: Rizki (L, lahir 2025-06-17, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-01-03', 8.8, 71.5, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-02-03', 9.1, 72.8, 43.3, 13.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-03-03', 9.4, 74, 43.7, 13.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-04-03', 9.6, 75.3, 44, 13.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-05-03', 9.9, 76.5, 44.3, 14.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-06-03', 10.2, 77.8, 44.6, 14.2);

-- Anak: Rafi (L, lahir 2023-10-15, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-01-03', 14.2, 93.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-02-03', 14.4, 94.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-03-03', 14.6, 94.9, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-04-03', 14.8, 95.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-05-03', 15, 96.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-06-03', 15.2, 96.9, NULL, NULL);

-- Anak: Nayla (P, lahir 2025-10-22, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-01-03', 6.6, 62.5, 37, 11.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-02-03', 7, 64.4, 38.5, 12.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-03-03', 7.4, 66.3, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-04-03', 7.8, 68.2, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-05-03', 8.2, 70.1, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-06-03', 8.6, 72, 43.3, 13.6);

-- Anak: Hasan (L, lahir 2024-06-03, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-01-03', 8.8, 80.5, 47.3, 15.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-02-03', 9, 81.2, 47.6, 15.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-03-03', 9.2, 81.9, 48, 15.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-04-03', 9.5, 82.7, 48.3, 15.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-05-03', 9.7, 83.4, 48.6, 15.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-06-03', 9.9, 84.1, NULL, NULL);

-- Anak: Husein (L, lahir 2025-12-03, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-01-03', 5.2, 57.5, 35.5, 11.4);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-02-03', 5.9, 60.2, 37, 11.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-03-03', 6.6, 62.9, 38.5, 12.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-04-03', 7.4, 65.6, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-05-03', 8.1, 68.3, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-06-03', 8.8, 71, 43, 13.5);

-- Anak: Zahra (P, lahir 2024-12-08, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-01-03', 7.3, 71, 45, 14.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-02-03', 7.5, 72.1, 45.3, 14.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-03-03', 7.7, 73.2, 45.6, 14.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-04-03', 7.8, 74.3, 46, 14.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-05-03', 8, 75.4, 46.3, 14.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-06-03', 8.2, 76.5, 46.6, 15);

-- Anak: Dani (L, lahir 2023-12-19, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-01-03', 9.3, 82.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-02-03', 9.5, 83.4, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-03-03', 9.7, 84.3, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-04-03', 9.8, 85.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-05-03', 10, 86.1, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-06-03', 10.2, 87, NULL, NULL);

-- Anak: Dina (P, lahir 2025-03-14, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-01-03', 9.3, 74, 44, 13.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-02-03', 9.5, 75.2, 44.3, 14.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-03-03', 9.8, 76.4, 44.6, 14.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-04-03', 10, 77.6, 45, 14.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-05-03', 10.3, 78.8, 45.3, 14.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-06-03', 10.5, 80, 45.6, 14.6);

-- Anak: Bagas (L, lahir 2024-10-25, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-01-03', 8.5, 76, 45.6, 14.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-02-03', 8.7, 76.8, 46, 14.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-03-03', 8.9, 77.6, 46.3, 14.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-04-03', 9.1, 78.5, 46.6, 15);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-05-03', 9.3, 79.3, 47, 15.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-06-03', 9.4, 80.1, 47.3, 15.3);

-- Anak: Putri (P, lahir 2025-08-07, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-01-03', 7.6, 66.5, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-02-03', 7.9, 68, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-03-03', 8.2, 69.5, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-04-03', 8.4, 71, 43.3, 13.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-05-03', 8.7, 72.5, 43.7, 13.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-06-03', 9, 74, 44, 13.9);

-- Anak: Adi (L, lahir 2023-06-20, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-01-03', 10, 84.5, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-02-03', 10.2, 85.3, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-03-03', 10.3, 86.1, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-04-03', 10.4, 86.9, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-05-03', 10.6, 87.7, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-06-03', 10.8, 88.5, NULL, NULL);

-- Anak: Ayu (P, lahir 2024-08-16, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-01-03', 8.4, 77, 46.3, 14.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-02-03', 8.6, 78, 46.6, 15);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-03-03', 8.8, 79, 47, 15.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-04-03', 9, 80, 47.3, 15.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-05-03', 9.2, 81, 47.6, 15.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-06-03', 9.3, 82, 48, 15.6);

-- Anak: Fauzi (L, lahir 2025-04-09, scenario: normal)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-01-03', 9.8, 75, 43.7, 13.8);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-02-03', 10, 76.3, 44, 13.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-03-03', 10.2, 77.7, 44.3, 14.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-04-03', 10.5, 79, 44.6, 14.2);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-05-03', 10.7, 80.4, 45, 14.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', '2026-06-03', 10.9, 81.8, 45.3, 14.5);

-- Anak: Bella (P, lahir 2024-02-13, scenario: kurang)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-01-03', 9.5, 83, 48.3, 15.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-02-03', 9.7, 83.6, 48.6, 15.9);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-03-03', 9.9, 84.2, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-04-03', 10.1, 84.8, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-05-03', 10.3, 85.4, NULL, NULL);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', '2026-06-03', 10.4, 86, NULL, NULL);

-- Anak: Bimo (L, lahir 2025-09-21, scenario: buruk)
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-01-03', 5.5, 60.5, 38.5, 12.3);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-02-03', 5.7, 61.8, 40, 12.7);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-03-03', 5.9, 63.1, 41.5, 13.1);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-04-03', 6.2, 64.4, 43, 13.5);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-05-03', 6.4, 65.7, 43.3, 13.6);
INSERT INTO pengukuran (anak_id, kader_id, tanggal_ukur, berat_badan, tinggi_badan, lingkar_kepala, lingkar_lengan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '2026-06-03', 6.6, 67, 43.7, 13.8);

-- ==========================================================
-- TIER 4: Pemberian Vitamin A, Obat Cacing & PMT
-- ==========================================================

-- Rizki (usia: 11 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e498baf112dc', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Rafi (usia: 31 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49940494cf0', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Nayla (usia: 7 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ac0638cec', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Hasan (usia: 24 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49bad1a0c9d', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Husein (usia: 6 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49ce7a30816', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Zahra (usia: 17 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49d67bc88ec', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Dani (usia: 29 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49e3ac549a0', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Dina (usia: 14 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e49fdadd27e6', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Bagas (usia: 19 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a050ca6759', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Putri (usia: 9 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a1e3f0b3a9', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Adi (usia: 35 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a2a5d247f5', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Ayu (usia: 21 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a3a2f28add', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Fauzi (usia: 13 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a49b7f45da', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- Bella (usia: 27 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_merah', '1 Kapsul Merah', '2026-01-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'obat_cacing', '1 Tablet', '2026-03-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a53584fa05', '01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', 'pmt_biskuit', '2 Kotak', '2026-05-03', NULL);

-- Bimo (usia: 8 bulan)
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47b383706e6', 'vitamin_a_biru', '1 Kapsul Biru', '2026-02-03', NULL);
INSERT INTO pemberian (anak_id, kader_id, jenis, dosis, tanggal_pemberian, keterangan) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4a666b50efe', '01a053bb-fb3f-7b2a-ae2e-e47d59244e78', 'pmt_biskuit', '1 Kotak', '2026-05-03', NULL);

-- ==========================================================
-- TIER 6: Rujukan (anak kategori risiko tinggi)
-- ==========================================================

-- Rujukan untuk: Bimo | Status: selesai
INSERT INTO rujukan (kader_id, puskesmas_id, pengukuran_id, status, catatan_kader, catatan_puskesmas, validated_at, completed_at) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e47f466c1ac2', '01a053bb-fb3f-7b2a-ae2e-e48116394f55', 90, 'selesai', 'Anak memerlukan penanganan lebih lanjut. Hasil penilaian SAW menunjukkan kategori risiko tinggi dengan skor 0.696.', 'Pasien telah diperiksa. Diberikan edukasi gizi intensif dan program PMT selama 3 bulan ke depan.', '2026-05-15', '2026-05-18');

-- ==========================================================
-- TIER 6: AI Insight — pengukuran terakhir setiap anak
-- ==========================================================

-- Rizki (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 6;

-- Rafi (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 12;

-- Nayla (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 18;

-- Hasan (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong sedang.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 24;

-- Husein (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 30;

-- Zahra (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong sedang.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 36;

-- Dani (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Pemeringkatan sistem menempatkan anak pada prioritas pemantauan tinggi; hasil ini bukan diagnosis dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.' WHERE id = 42;

-- Dina (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 48;

-- Bagas (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong sedang.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 54;

-- Putri (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 60;

-- Adi (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Pemeringkatan sistem menempatkan anak pada prioritas pemantauan tinggi; hasil ini bukan diagnosis dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.' WHERE id = 66;

-- Ayu (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong sedang.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 72;

-- Fauzi (normal)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Kabar baik! Tumbuh kembang si kecil saat ini berjalan dengan sangat baik. Berat badan dan tinggi badannya sesuai dengan standar anak seusianya menurut WHO. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong rendah, sehingga Bunda tidak perlu khawatir berlebihan.

**Yang Bisa Dilakukan**
1. Lanjutkan pola makan bergizi seimbang yang sudah berjalan dengan baik — variasikan sayur, buah, protein hewani seperti telur, ikan, dan daging ayam, serta karbohidrat.
2. Pastikan si kecil cukup bermain aktif di luar ruangan dan mendapat paparan sinar matahari pagi minimal 15 menit setiap hari untuk mendukung penyerapan vitamin D.
3. Tetap rutin bawa ke posyandu setiap bulan agar tumbuh kembang terus terpantau dengan baik dan intervensi dapat dilakukan sedini mungkin jika diperlukan.

**Kapan Perlu ke Dokter**
Segera konsultasikan ke tenaga kesehatan jika berat badan tidak naik sama sekali dalam 2 bulan berturut-turut, atau jika si kecil tampak lesu, tidak aktif seperti biasanya, atau nafsu makan menurun drastis dan tidak membaik dalam beberapa hari.' WHERE id = 78;

-- Bella (kurang)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berat badan dan tinggi badan si kecil saat ini sedikit di bawah rata-rata anak seusianya berdasarkan standar WHO. Kondisi ini perlu mendapat perhatian lebih agar tumbuh kembangnya dapat kembali ke jalur yang tepat. Prioritas pemantauan berdasarkan pemeringkatan sistem tergolong sedang.

**Yang Bisa Dilakukan**
1. Tingkatkan asupan protein hewani setiap hari — telur, ikan, ayam, atau hati ayam bisa menjadi pilihan yang bergizi, mudah dicerna, dan terjangkau untuk mendukung pertumbuhan optimal.
2. Berikan makanan lebih sering dalam porsi kecil, setidaknya 5 hingga 6 kali sehari termasuk selingan bergizi seperti bubur kacang hijau, pisang, atau biskuit bayi berfortifikasi.
3. Jika si kecil sulit makan, coba variasikan tampilan, tekstur, dan rasa makanan agar lebih menarik dan nafsu makan meningkat secara perlahan.

**Kapan Perlu ke Dokter**
Segera bawa ke puskesmas jika berat badan tidak bertambah dalam sebulan penuh, atau jika si kecil sering sakit berulang, rewel terus-menerus, tampak sangat lemas, atau ada tanda-tanda anemia seperti wajah pucat dan mudah lelah.' WHERE id = 84;

-- Bimo (buruk)
UPDATE pengukuran SET insight_teks = '**Kondisi Saat Ini**
Berdasarkan hasil pengukuran terbaru, berat badan dan tinggi badan si kecil berada di bawah batas normal yang direkomendasikan WHO. Pemeringkatan sistem menempatkan anak pada prioritas pemantauan tinggi; hasil ini bukan diagnosis dan memerlukan perhatian segera dari tenaga kesehatan. Bunda perlu segera mengambil tindakan nyata agar kondisi tidak semakin memburuk.

**Yang Bisa Dilakukan**
1. Segera konsultasikan kondisi si kecil ke dokter atau bidan di puskesmas untuk mendapatkan penanganan gizi yang tepat, termasuk kemungkinan masuk dalam program PMT (Pemberian Makanan Tambahan) yang disediakan pemerintah.
2. Berikan makanan tinggi kalori dan tinggi protein di setiap waktu makan — nasi tim dengan hati ayam cincang, bubur kacang hijau dengan santan, atau makanan yang diperkaya sedikit minyak kelapa atau mentega untuk menambah kalori.
3. Pastikan si kecil tidak melewatkan satu pun waktu makan dan selalu tawarkan makanan tambahan di antara waktu makan utama untuk mendukung proses kejar tumbuh.

**Kapan Perlu ke Dokter**
Si kecil sangat disarankan untuk segera dirujuk ke dokter spesialis anak. Jangan tunda kunjungan jika si kecil mengalami penurunan berat badan, menolak makan sama sekali selama lebih dari 2 hari, tampak sangat lemas dan tidak responsif, atau terdapat pembengkakan pada kaki dan tangan yang bisa menjadi tanda kekurangan protein berat.' WHERE id = 90;

-- Tandai seluruh insight statis sebagai hasil demo yang sudah selesai
UPDATE pengukuran SET insight_status = 'completed', insight_attempts = 1, insight_available_at = NULL, insight_generated_at = created_at, insight_model = 'demo-seeder' WHERE insight_teks IS NOT NULL;

-- Pengukuran historis tanpa insight tidak masuk antrean AI
UPDATE pengukuran p JOIN pengukuran terbaru ON terbaru.anak_id = p.anak_id AND (terbaru.tanggal_ukur > p.tanggal_ukur OR (terbaru.tanggal_ukur = p.tanggal_ukur AND terbaru.id > p.id)) SET p.insight_status = 'superseded', insight_available_at = NULL, insight_last_error = NULL WHERE p.insight_teks IS NULL AND p.insight_status IN ('pending', 'processing');

-- ==========================================================
-- TIER 7: Notifikasi
-- Jadwal ID 7 = Posyandu Juli 2026 (jadwal mendatang = hari demo)
-- ==========================================================

-- Notifikasi jadwal posyandu Juli 2026
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e485c9299aff', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e487651e0ad0', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48974295630', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48b4cf3b5f5', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48d81ef5b14', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e48f0f1afec6', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e491d98f2c80', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e493bb2fdec4', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e495f9eb23d9', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4974bd52e24', 'Jadwal Posyandu Juli 2026', 'Posyandu rutin Juli 2026 akan dilaksanakan pada 3 Juli 2026 pukul 08.00 di Balai RW 05 Kelurahan Cempaka. Harap hadir tepat waktu dan membawa buku KMS.', 'jadwal', FALSE, '2026-06-29 08:00:00', 7, NULL);

-- Notifikasi status rujukan
INSERT INTO notifikasi (orang_tua_id, judul, pesan, tipe, sudah_dibaca, sent_at, jadwal_id, rujukan_id) VALUES
    ('01a053bb-fb3f-7b2a-ae2e-e4974bd52e24', 'Rujukan Selesai Ditangani', 'Proses rujukan anak Anda telah selesai ditangani. Terus pantau tumbuh kembang si kecil dan rutin bawa ke posyandu setiap bulan agar kondisi tetap terpantau.', 'rujukan', TRUE, '2026-06-01 10:00:00', NULL, 1);
