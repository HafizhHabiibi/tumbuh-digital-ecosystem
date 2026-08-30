ALTER TABLE pengukuran
    MODIFY COLUMN insight_status
        ENUM('pending', 'processing', 'completed', 'failed', 'superseded')
        NOT NULL DEFAULT 'pending';

UPDATE pengukuran p
JOIN pengukuran terbaru
  ON terbaru.anak_id = p.anak_id
 AND (
      terbaru.tanggal_ukur > p.tanggal_ukur
      OR (
          terbaru.tanggal_ukur = p.tanggal_ukur
          AND terbaru.id > p.id
      )
 )
SET p.insight_status = 'superseded',
    p.insight_available_at = NULL,
    p.insight_last_error = NULL
WHERE p.insight_teks IS NULL
  AND p.insight_status IN ('pending', 'processing');
