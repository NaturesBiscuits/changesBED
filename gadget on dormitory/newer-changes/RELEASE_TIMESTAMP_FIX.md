# Release Timestamp Fix

Problem: Released History was showing the same value for `Released` and `Last Edited` after editing a released row.

Cause: the view was falling back to `updated_at` when `original_release_at` was empty. Since `updated_at` changes on every edit, the Released column looked overwritten.

## View Fix Applied

File: `assign_student_gadget.php`

Released no longer falls back to `updated_at`. If `original_release_at` is missing or empty, the Released column now displays `Not recorded` instead of copying Last Edited.

```php
$original_release_at = !empty($s['original_release_at'])
    ? $s['original_release_at']
    : '';
$release_span = '';
if (!empty($original_release_at)) {
    $start = new DateTime($s['gadget_created_date']);
    $end = new DateTime($original_release_at);
    $diff = $start->diff($end);
    $release_span = $diff->format('%d days, %h hours, %i minutes');
}
```

```php
<td><?php echo !empty($original_release_at) ? $original_release_at : 'Not recorded' ?></td>
<td><?php echo ($s['updated_at'] != $s['gadget_created_date']) ? $s['updated_at'] : '' ?></td>
<td><?php echo $release_span ?></td>
```

## Database Fix Needed

The best long-term solution is a separate database column that records the first release time only.

```sql
ALTER TABLE student_hostel_room_gadget
ADD COLUMN original_release_at DATETIME NULL AFTER updated_at;
```

Backfill existing released rows:

```sql
UPDATE student_hostel_room_gadget
SET original_release_at = updated_at
WHERE status = 'release'
  AND original_release_at IS NULL;
```

Important: if a released row was already edited before this column existed, the exact first release time may already be lost. In that case, manually update `original_release_at` for records where you know the correct release time.

Example manual correction:

```sql
UPDATE student_hostel_room_gadget
SET original_release_at = '2026-07-10 08:15:00'
WHERE id = 123;
```

## Controller Fix Needed

On first release, set `original_release_at`. On later edits to a released row, never overwrite it.

```php
if (
    $this->input->post('status') === 'release'
    && $this->db->field_exists('original_release_at', 'student_hostel_room_gadget')
) {
    $existing_original_release = null;
    if ($gadget_id) {
        $existing_release = $this->db
            ->select('original_release_at')
            ->from('student_hostel_room_gadget')
            ->where('id', $gadget_id)
            ->limit(1)
            ->get()
            ->row_array();
        $existing_original_release = isset($existing_release['original_release_at'])
            ? $existing_release['original_release_at']
            : null;
    }

    if (empty($existing_original_release)) {
        $data_gadget['original_release_at'] = date('Y-m-d H:i:s');
    }
}
```

## Model/Query Fix Needed

The query that builds `$studenthostelroomgadget` must select `student_hostel_room_gadget.original_release_at`. If it is not selected, the view will show `Not recorded` because it cannot see the database value.

Example select addition:

```php
$this->db->select('student_hostel_room_gadget.original_release_at');
```



