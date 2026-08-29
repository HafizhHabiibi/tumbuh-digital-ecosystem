-- ============================================================
-- SCHEMA: Posyandu PUI — tabel inti + notification outbox
-- ============================================================

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
    fcm_token VARCHAR(512) DEFAULT NULL,
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
    nik VARCHAR(16) UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (orang_tua_id) REFERENCES orang_tua(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 6. PENGUKURAN
-- NOTE: Hanya menyimpan data mentah hasil pengukuran (3NF).
--       Z-Score, status gizi, SAW, dan kategori risiko dihitung
--       on-the-fly di application layer.
--       insight_teks bukan derived data — ini konten yang
--       digenerate AI (non-deterministic), sehingga harus disimpan.
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
    -- AI-generated content (non-deterministic, disimpan karena tidak bisa direproduksi)
    insight_teks TEXT DEFAULT NULL,
    insight_status ENUM('pending', 'processing', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    insight_attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
    -- Dipakai sebagai jadwal retry atau batas lease ketika sedang diproses.
    insight_available_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    insight_generated_at DATETIME DEFAULT NULL,
    insight_model VARCHAR(100) DEFAULT NULL,
    insight_last_error VARCHAR(500) DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (anak_id) REFERENCES anak(id) ON DELETE CASCADE,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE,
    UNIQUE KEY unique_anak_tanggal (anak_id, tanggal_ukur),
    INDEX idx_pengukuran_tanggal (tanggal_ukur),
    INDEX idx_pengukuran_insight_queue (insight_status, insight_available_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 7. CHAT MESSAGES
-- Satu rangkaian percakapan untuk setiap pengukuran. Tidak ada
-- chat_sessions karena pengukuran_id sudah menjadi batas sesi.
-- anak_id dan orang_tua_id diperoleh melalui relasi pengukuran.
-- ==========================================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    pengukuran_id INT NOT NULL,
    -- UUID dari frontend untuk idempotensi pesan orang tua.
    client_message_id CHAR(36) DEFAULT NULL,
    -- Balasan assistant menunjuk langsung ke pesan orang tua yang dijawab.
    reply_to_message_id BIGINT DEFAULT NULL,
    role ENUM('orang_tua', 'assistant') NOT NULL,
    content TEXT NOT NULL,
    response_type ENUM(
        'answered',
        'out_of_scope',
        'medical_advice_refused'
    ) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pengukuran_id) REFERENCES pengukuran(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_message_id) REFERENCES chat_messages(id) ON DELETE CASCADE,
    UNIQUE KEY unique_chat_client_message (client_message_id),
    UNIQUE KEY unique_chat_reply (reply_to_message_id),
    INDEX idx_chat_messages_history (pengukuran_id, created_at, id),
    CONSTRAINT chk_chat_message_metadata CHECK (
        (role = 'orang_tua' AND client_message_id IS NOT NULL AND reply_to_message_id IS NULL AND response_type IS NULL)
        OR
        (role = 'assistant' AND client_message_id IS NULL AND reply_to_message_id IS NOT NULL AND response_type IS NOT NULL)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 8. RIWAYAT PEMBERIAN
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
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE,
    -- Mencegah duplikasi: kader tidak bisa input jenis yang sama 2x pada hari yang sama
    UNIQUE KEY unique_pemberian (anak_id, jenis, tanggal_pemberian),
    INDEX idx_pemberian_anak (anak_id, tanggal_pemberian)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 9. RUJUKAN (simplified: 3 status, pengukuran_id, puskesmas_id)
-- NOTE: anak_id dihapus untuk 3NF — didapat via
--       pengukuran_id → pengukuran.anak_id (JOIN).
-- ==========================================================
CREATE TABLE IF NOT EXISTS rujukan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kader_id CHAR(36) NOT NULL,
    puskesmas_id CHAR(36) DEFAULT NULL,
    pengukuran_id INT NOT NULL,
    status ENUM('diajukan', 'ditangani', 'selesai') DEFAULT 'diajukan',
    catatan_kader TEXT,
    catatan_puskesmas TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    validated_at DATETIME DEFAULT NULL,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE,
    FOREIGN KEY (puskesmas_id) REFERENCES puskesmas(id) ON DELETE SET NULL,
    FOREIGN KEY (pengukuran_id) REFERENCES pengukuran(id) ON DELETE CASCADE,
    INDEX idx_rujukan_pengukuran (pengukuran_id),
    INDEX idx_rujukan_puskesmas (puskesmas_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 10a. PENGATURAN JADWAL (template default — singleton, max 1 row)
-- ==========================================================
CREATE TABLE IF NOT EXISTS pengaturan_jadwal (
    id INT AUTO_INCREMENT PRIMARY KEY,
    singleton_key TINYINT NOT NULL DEFAULT 1 UNIQUE CHECK (singleton_key = 1),
    hari_tetap TINYINT NOT NULL CHECK (hari_tetap BETWEEN 1 AND 28),
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    lokasi_default VARCHAR(255) NOT NULL,
    updated_by CHAR(36) DEFAULT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES kader(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 10b. JADWAL POSYANDU
-- ==========================================================
CREATE TABLE IF NOT EXISTS jadwal_posyandu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    kader_id CHAR(36) NOT NULL,
    tanggal DATE NOT NULL UNIQUE,
    waktu_mulai TIME NOT NULL,
    waktu_selesai TIME NOT NULL,
    lokasi VARCHAR(255) NOT NULL,
    keterangan TEXT DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kader_id) REFERENCES kader(id) ON DELETE CASCADE,
    INDEX idx_jadwal_tanggal (tanggal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 11. NOTIFIKASI
-- ==========================================================
CREATE TABLE IF NOT EXISTS notifikasi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orang_tua_id CHAR(36) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    tipe ENUM('jadwal', 'rujukan', 'pengukuran') NOT NULL,
    sudah_dibaca BOOLEAN DEFAULT FALSE,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    jadwal_id INT DEFAULT NULL,
    rujukan_id INT DEFAULT NULL,
    pengukuran_id INT DEFAULT NULL,
    FOREIGN KEY (orang_tua_id) REFERENCES orang_tua(id) ON DELETE CASCADE,
    FOREIGN KEY (jadwal_id) REFERENCES jadwal_posyandu(id) ON DELETE SET NULL,
    FOREIGN KEY (rujukan_id) REFERENCES rujukan(id) ON DELETE SET NULL,
    FOREIGN KEY (pengukuran_id) REFERENCES pengukuran(id) ON DELETE SET NULL,
    -- Mempercepat query inbox & badge count per orang tua
    INDEX idx_notifikasi_inbox (orang_tua_id, sudah_dibaca)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 12. REFRESH TOKENS
-- NOTE: user_id TIDAK UNIQUE — satu user bisa punya banyak refresh token
--       aktif secara bersamaan (multi-device login).
--       Yang UNIQUE adalah hash token itu sendiri; token mentah tidak disimpan.
--       Cleanup token expired dapat dilakukan via scheduled job:
--         DELETE FROM refresh_tokens WHERE expires_at < NOW();
-- ==========================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    revoked TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_refresh_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================================
-- 13. NOTIFICATION OUTBOX
-- Menjamin push notification dapat di-retry bila provider gagal.
-- ==========================================================
CREATE TABLE IF NOT EXISTS notification_outbox (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    notification_id INT NOT NULL,
    orang_tua_id CHAR(36) NOT NULL,
    fcm_token VARCHAR(512) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    data_payload JSON DEFAULT NULL,
    status ENUM('pending', 'processing', 'sent', 'failed') NOT NULL DEFAULT 'pending',
    attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
    available_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_error VARCHAR(500) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    sent_at DATETIME DEFAULT NULL,
    FOREIGN KEY (notification_id) REFERENCES notifikasi(id) ON DELETE CASCADE,
    FOREIGN KEY (orang_tua_id) REFERENCES orang_tua(id) ON DELETE CASCADE,
    INDEX idx_outbox_pending (status, available_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE notification_outbox
    ADD COLUMN IF NOT EXISTS data_payload JSON DEFAULT NULL AFTER pesan;
