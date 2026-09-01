ALTER TABLE rujukan
    ADD COLUMN completed_at DATETIME DEFAULT NULL AFTER validated_at;

UPDATE rujukan
SET completed_at = validated_at
WHERE status = 'selesai'
  AND completed_at IS NULL;
