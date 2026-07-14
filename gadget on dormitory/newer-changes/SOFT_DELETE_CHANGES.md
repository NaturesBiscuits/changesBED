# Soft Delete Changes

FileZilla path: `dormitorydean/hostelroom/assign_student_gadget`

Purpose: deleting a gadget should not permanently remove the database row. The row should remain in `student_hostel_room_gadget` with `status = 'deleted'`, and `updated_at` should record when the delete happened.

Important note: this temp folder does not contain `Hostelroom.php`; it contains the view and model files only. Controller snippets below are the required support code for the delete route.

## SQL

If `student_hostel_room_gadget.status` is an `ENUM`, run this so `deleted` becomes an allowed value:

```sql
ALTER TABLE student_hostel_room_gadget
MODIFY status ENUM(
    'deposit',
    'confiscated',
    'release',
    'deleted'
) NOT NULL;
```

If `status` is already `VARCHAR`, this SQL is not needed.

## View: `assign_student_gadget.php`

### Lines 17-20

Deleted rows are not counted as active. Released rows are counted separately.

```php
if ($gadget_count_item['student_gadget_status'] == 'release') {
    $released_gadget_count++;
} elseif ($gadget_count_item['student_gadget_status'] != 'deleted') {
    $active_gadget_count++;
}
```

### Line 167

Deleted rows are hidden from the Dormitory Declared Gadget List.

```php
if (in_array($studenthostelroom['student_gadget_status'], array('release', 'deleted'))) continue;
```

### Lines 229-235

Released History only collects rows with `status = release`, so deleted rows are hidden from history too.

```php
$released = array();
if (!empty($studenthostelroomgadget)) {
    foreach ($studenthostelroomgadget as $s) {
        if ($s['student_gadget_status'] == 'release') {
            $released[] = $s;
        }
    }
}
```

## Required Controller Delete Change

Replace hard delete behavior with an update to `status = deleted`.

```php
public function assign_student_gadget_delete($id)
{
    $this->db->where('id', $id);
    $this->db->update('student_hostel_room_gadget', array(
        'status' => 'deleted',
        'updated_at' => date('Y-m-d H:i:s')
    ));

    $this->session->set_flashdata('msg', '<div class="alert alert-success text-left">Gadget deleted successfully</div>');
    redirect('dormitorydean/hostelroom/assign_student_gadget');
}
```

Do not use this for gadget deletes anymore:

```php
$this->db->delete('student_hostel_room_gadget');
```

## Expected Result

- The record remains visible in the database.
- The UI does not show deleted records in active gadgets.
- The UI does not show deleted records in Released History.
- `updated_at` records when the soft delete happened.



