-- ============================================================
-- SCHEMA: Posyandu PUI — 11 Tabel (Simplified)
-- ============================================================

CREATE DATABASE IF NOT EXISTS tumbuh_pp;
USE tumbuh_pp;

-- ==========================================================
-- 1. USERS
-- ==========================================================
CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('kader', 'puskesmas', 'orang_tua') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    reset_password_at DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 2. KADER
-- ==========================================================
CREATE TABLE IF NOT EXISTS kader (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    no_hp VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 3. PUSKESMAS (renamed from puskesmas_user)
-- ==========================================================
CREATE TABLE IF NOT EXISTS puskesmas (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL UNIQUE,
    nama_lengkap VARCHAR(100) NOT NULL,
    jabatan VARCHAR(100),
    no_hp VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 4. ORANG TUA
-- ==========================================================
CREATE TABLE IF NOT EXISTS orang_tua (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL UNIQUE,
    dibuat_oleh_kader_id CHAR(36),
    nama_lengkap VARCHAR(100) NOT NULL,
    no_hp VARCHAR(20),
    alamat TEXT,
    nik VARCHAR(16) UNIQUE,
    fcm_token TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (dibuat_oleh_kader_id) REFERENCES kader(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 5. ANAK
-- ==========================================================
CREATE TABLE IF NOT EXISTS anak (
    id CHAR(36) PRIMARY KEY,
    orang_tua_id CHAR(36) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    jenis_kelamin ENUM('L', 'P') NOT NULL,
    tanggal_lahir DATE NOT NULL,
    nik VARCHAR(16),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orang_tua_id) REFERENCES orang_tua(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 6. PENGUKURAN (+ skor_saw, kategori_risiko, insight_teks)
-- NOTE: zscore_*, status_gizi, skor_saw, kategori_risiko, insight_teks
--       adalah derived/computed values yang disimpan (bukan dihitung ulang)
--       untuk efisiensi query. Ini adalah intentional denormalization.
-- ==========================================================
CREATE TABLE IF NOT EXISTS pengukuran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    anak_id CHAR(36) NOT NULL,
    kader_id CHAR(36) NOT NULL,
    tanggal_ukur DATE NOT NULL,
    berat_badan DECIMAL(5,2) NOT NULL,
    tinggi_badan DECIMAL(5,2) NOT NULL,
    lingkar_kepala DECIMAL(5,2) DEFAULT NULL,
    lingkar_lengan DECIMAL(5,2) DEFAULT NULL,
    -- Derived: dihitung dari berat/tinggi/umur, disimpan untuk performa
    zscore_bbu DECIMAL(6,3) DEFAULT NULL,
    zscore_tbu DECIMAL(6,3) DEFAULT NULL,
    zscore_bbtb DECIMAL(6,3) DEFAULT NULL,
    status_gizi ENUM('buruk', 'kurang', 'normal', 'lebih', 'obesitas') DEFAULT 'normal',
    -- SAW snapshot: disimpan saat pengukuran dibuat, tidak dihitung ulang
    -- tren_bb = selisih BB dari pengukuran sebelumnya (kg), NULL jika pertama kali
    tren_bb DECIMAL(5,3) DEFAULT NULL,
    skor_saw DECIMAL(6,4) DEFAULT NULL,
    kategori_risiko ENUM('rendah', 'sedang', 'tinggi') DEFAULT NULL,
    insight_teks TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (anak_id) REFERENCES anak(id) ON DELETE CASCADE,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE,
    UNIQUE KEY unique_anak_tanggal (anak_id, tanggal_ukur)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 7. RIWAYAT PEMBERIAN
-- NOTE: nama_item dihapus dan digantikan oleh jenis ENUM yang
--       lebih spesifik untuk menjaga konsistensi data (domain integrity).
--       Gunakan kolom keterangan untuk detail tambahan jika diperlukan.
-- ==========================================================
CREATE TABLE IF NOT EXISTS pemberian (
    id INT AUTO_INCREMENT PRIMARY KEY,
    anak_id CHAR(36) NOT NULL,
    kader_id CHAR(36) NOT NULL,
    -- Jenis yang lebih spesifik menggantikan free-text nama_item
    jenis ENUM(
        'vitamin_a_merah',   -- 200.000 IU, usia 12-59 bulan
        'vitamin_a_biru',    -- 100.000 IU, usia 6-11 bulan
        'obat_cacing',       -- Albendazole / Mebendazole
        'pmt_biskuit',       -- PMT berupa biskuit
        'pmt_susu',          -- PMT berupa susu
        'pmt_lainnya'        -- PMT jenis lain (lihat keterangan)
    ) NOT NULL,
    dosis VARCHAR(50),
    tanggal_pemberian DATE NOT NULL,
    keterangan TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (anak_id) REFERENCES anak(id) ON DELETE CASCADE,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 8. RUJUKAN (simplified: 3 status, pengukuran_id, puskesmas_id)
-- NOTE: anak_id secara teknis bisa diambil dari pengukuran.anak_id,
--       namun disimpan di sini sebagai intentional denormalization
--       untuk mempermudah query langsung tanpa JOIN ke pengukuran.
-- ==========================================================
CREATE TABLE IF NOT EXISTS rujukan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    anak_id CHAR(36) NOT NULL,   -- intentional denorm dari pengukuran.anak_id
    kader_id CHAR(36) NOT NULL,
    puskesmas_id CHAR(36) DEFAULT NULL,
    pengukuran_id INT NOT NULL,
    status ENUM('diajukan', 'ditangani', 'selesai') DEFAULT 'diajukan',
    catatan_kader TEXT,
    catatan_puskesmas TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    validated_at DATETIME DEFAULT NULL,
    FOREIGN KEY (anak_id) REFERENCES anak(id) ON DELETE CASCADE,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE,
    FOREIGN KEY (puskesmas_id) REFERENCES puskesmas(id) ON DELETE SET NULL,
    FOREIGN KEY (pengukuran_id) REFERENCES pengukuran(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 9. JADWAL POSYANDU
-- ==========================================================
CREATE TABLE IF NOT EXISTS jadwal_posyandu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kader_id CHAR(36) NOT NULL,
    tanggal DATE NOT NULL,
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    lokasi VARCHAR(255) NOT NULL,
    keterangan TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 10. NOTIFIKASI
-- ==========================================================
CREATE TABLE IF NOT EXISTS notifikasi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_tua_id CHAR(36) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    tipe ENUM('umum', 'jadwal', 'rujukan') DEFAULT 'umum',
    sudah_dibaca BOOLEAN DEFAULT FALSE,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    jadwal_id INT DEFAULT NULL,
    rujukan_id INT DEFAULT NULL,
    FOREIGN KEY (orang_tua_id) REFERENCES orang_tua(id) ON DELETE CASCADE,
    FOREIGN KEY (jadwal_id) REFERENCES jadwal_posyandu(id) ON DELETE SET NULL,
    FOREIGN KEY (rujukan_id) REFERENCES rujukan(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 11. REFRESH TOKENS
-- ==========================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL UNIQUE,
    token TEXT NOT NULL,
    expires_at DATETIME NOT NULL,
    revoked TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
