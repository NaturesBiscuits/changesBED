-- Permanent fix for Released date vs Last Edited.
-- Released date must be stored separately from updated_at.
-- Important: do NOT use plain MySQL NOW() if your MySQL timezone differs from PHP/app timezone.
-- This system is showing a 2 hour 30 minute offset, so release time must use the app-written updated_at value.

-- 1) Add the release timestamp column if it does not exist yet.
ALTER TABLE student_hostel_room_gadget
ADD COLUMN original_release_at DATETIME NULL AFTER updated_at;

-- 2) Backfill existing released records with the best currently available value.
-- This is safest for records that were released before original_release_at existed.
UPDATE student_hostel_room_gadget
SET original_release_at = updated_at
WHERE status = 'release'
  AND original_release_at IS NULL;

-- 3) Repair records created while the old trigger used the wrong MySQL timezone.
-- The bad symptom is original_release_at being earlier than created_at, which is impossible.
-- For this system, MySQL was 2 hours 30 minutes behind the PHP/app time.
-- Review rows first:
SELECT id,
       status,
       original_status,
       created_at,
       original_release_at,
       DATE_ADD(original_release_at, INTERVAL 150 MINUTE) AS corrected_original_release_at,
       updated_at
FROM student_hostel_room_gadget
WHERE status = 'release'
  AND original_release_at IS NOT NULL
  AND original_release_at < created_at;

-- If the review result is correct, repair them by shifting the stored release time forward.
-- This preserves the original release moment better than copying Last Edited.
UPDATE student_hostel_room_gadget
SET original_release_at = DATE_ADD(original_release_at, INTERVAL 150 MINUTE)
WHERE status = 'release'
  AND original_release_at IS NOT NULL
  AND original_release_at < created_at;

-- 4) Keep original_release_at immutable after first release.
DROP TRIGGER IF EXISTS trg_student_gadget_original_release_insert;
DROP TRIGGER IF EXISTS trg_student_gadget_original_release_update;

DELIMITER $$

CREATE TRIGGER trg_student_gadget_original_release_insert
BEFORE INSERT ON student_hostel_room_gadget
FOR EACH ROW
BEGIN
    IF NEW.status = 'release' AND NEW.original_release_at IS NULL THEN
        SET NEW.original_release_at = COALESCE(NEW.updated_at, CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+08:00'));
    END IF;
END$$

CREATE TRIGGER trg_student_gadget_original_release_update
BEFORE UPDATE ON student_hostel_room_gadget
FOR EACH ROW
BEGIN
    IF OLD.original_release_at IS NOT NULL THEN
        SET NEW.original_release_at = OLD.original_release_at;
    ELSEIF NEW.status = 'release' AND OLD.status <> 'release' THEN
        SET NEW.original_release_at = COALESCE(NEW.updated_at, CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+08:00'));
    ELSEIF NEW.status = 'release' AND OLD.status = 'release' THEN
        SET NEW.original_release_at = COALESCE(OLD.updated_at, NEW.updated_at, CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+08:00'));
    END IF;
END$$

DELIMITER ;

-- 5) The PHP query that builds $studenthostelroomgadget must also SELECT this column:
-- student_hostel_room_gadget.original_release_at

