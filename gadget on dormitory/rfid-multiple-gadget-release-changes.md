# RFID Multiple Gadget Release Changes

## FileZilla Paths

These paths are FileZilla-relative paths for the current remote folder, not local temp paths:

- `/Hostelroom.php`
- `/assign_student_gadget.php`

## Summary

Changed RFID/QR release behavior when a student has multiple active gadgets logged.

Before:

- The scan flow could automatically release a gadget when auto-release was enabled.

Now:

- The `Auto Release when Scanned` checkbox has been removed from the UI.
- RFID/QR scans now identify the student only.
- The page shows that the student has multiple active gadgets logged.
- The student's active gadget rows are highlighted in `Dormitory Declared Gadget List`.
- The user can click the correct gadget row and then click `Release`.

## Changed Code Lines

### `/Hostelroom.php`

Lines 374-386 count active gadgets and stop auto-release when more than one active gadget exists:

```php
$gadgets = $query->result_array();
$active_count = count($gadgets);

if ($active_count > 1) {
    echo json_encode(array(
        'success' => false,
        'multiple' => true,
        'active_count' => $active_count,
        'message' => 'Student has multiple active gadgets logged'
    ));
} else if ($active_count == 1) {
```

Lines 411-438 add `active_gadget_count` to the RFID student lookup response:

```php
$active_gadget_count = 0;
...
$active_gadget_count = count($active_gadgets);
...
'active_gadget_count' => $active_gadget_count,
```

Lines 479-524 add `active_gadget_count` to the QR/student ID lookup response:

```php
$active_gadget_count = 0;
...
$active_gadget_count = count($active_gadgets);
...
'active_gadget_count' => $active_gadget_count,
```

### `/assign_student_gadget.php`

Lines 457-458 show a multiple-gadget message after QR scan:

```javascript
highlightStudentGadgetRows(data.id);
$("#qr-result").text(fullName + " has " + data.active_gadget_count + " active gadgets logged. Select a gadget row, then click Release.").css("color", "orange");
```

Lines 619-624 keep the existing highlight and update the compact student gadget panel:

```javascript
function highlightStudentGadgetRows(studentId) {
    $("#active-gadget-table tbody tr").removeClass("info");
    $("#active-gadget-table tbody tr").filter(function () {
        return String($(this).data("student-id")) === String(studentId);
    }).addClass("info");
    renderStudentGadgetPanel(studentId);
}
```

Lines 760-761 show a multiple-gadget message after RFID scan:

```javascript
highlightStudentGadgetRows(data.id);
$("#rfid-status").text(fullName + " has " + data.active_gadget_count + " active gadgets logged. Select a gadget row, then click Release.").css("color", "orange");
```

## Verification

PHP syntax checks passed:

```text
php -l Hostelroom.php
php -l assign_student_gadget.php
```
