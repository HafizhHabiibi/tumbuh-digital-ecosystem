ALTER TABLE chat_messages
    ADD COLUMN request_status ENUM('processing', 'completed') DEFAULT NULL AFTER response_type,
    ADD COLUMN request_token CHAR(36) DEFAULT NULL AFTER request_status,
    ADD COLUMN request_expires_at DATETIME DEFAULT NULL AFTER request_token,
    ADD INDEX idx_chat_request_lease (request_status, request_expires_at);

UPDATE chat_messages
SET request_status = 'completed'
WHERE role = 'orang_tua' AND request_status IS NULL;
