# Released Timestamp Changes

FileZilla path: `dormitorydean/hostelroom/assign_student_gadget`

Purpose: the Released column should show the first time the gadget was released. Later edits to that same released record should only update Last Edited.

Important note: this temp folder does not contain `Hostelroom.php`; controller snippets below are the required save behavior for the route.

## SQL

Add a column for the first release timestamp:

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

Caution: if a released row was already edited before `original_release_at` existed, the exact first release time may already be lost. In that case, the backfill uses the best available timestamp: the row's current `updated_at`.

## View: `assign_student_gadget.php`

### Line 221

The UI column name remains `Released`.

```php
<th>Released</th>
```

### Lines 245-251

The view uses `original_release_at` first and only falls back to `updated_at` if the new column is empty. The Span is calculated from `gadget_created_date` to this first-release timestamp.

```php
$original_release_at = !empty($s['original_release_at'])
    ? $s['original_release_at']
    : $s['updated_at'];
$start = new DateTime($s['gadget_created_date']);
$end = new DateTime($original_release_at);
$diff = $start->diff($end);
$span = $diff->format('%d days, %h hours, %i minutes');
```

### Line 259

Released History row data uses the first-release timestamp. This also feeds the small multi-device table.

```php
data-date="<?php echo $original_release_at ?>"
```

### Lines 267-269

Released and Last Edited are separate values. Released uses `original_release_at`; Last Edited uses `updated_at`.

```php
<td><?php echo $original_release_at ?></td>
<td><?php echo ($s['updated_at'] != $s['gadget_created_date']) ? $s['updated_at'] : '' ?></td>
<td><?php echo $span ?></td>
```

## Required Controller Save Logic

When status is release:

- If `original_release_at` already exists, keep it unchanged.
- If the row is already released but `original_release_at` is empty, copy the old pre-edit `updated_at` as a fallback.
- If this is the first transition to release, set `original_release_at` to the current timestamp.

```php
if (
    $this->input->post('status') === 'release'
    && $this->db->field_exists('original_release_at', 'student_hostel_room_gadget')
) {
    $existing_original_release = null;
    $original_release_fallback = null;
    if ($gadget_id) {
        $existing_release = $this->db
            ->select('original_release_at, status, updated_at')
            ->from('student_hostel_room_gadget')
            ->where('id', $gadget_id)
            ->limit(1)
            ->get()
            ->row_array();
        $existing_original_release = isset($existing_release['original_release_at'])
            ? $existing_release['original_release_at']
            : null;
        if (
            isset($existing_release['status'])
            && $existing_release['status'] === 'release'
            && !empty($existing_release['updated_at'])
        ) {
            $original_release_fallback = $existing_release['updated_at'];
        }
    }

    if (empty($existing_original_release)) {
        $data_gadget['original_release_at'] = $original_release_fallback
            ? $original_release_fallback
            : date('Y-m-d H:i:s');
    }
}
```

## Expected Result

- First release sets `original_release_at`.
- Editing device/description on a released row updates only `updated_at`.
- Released and Last Edited no longer become the same just because the released row was edited.
- If a row moves release -> confiscated/deposit -> release, Released still keeps the first release time.



