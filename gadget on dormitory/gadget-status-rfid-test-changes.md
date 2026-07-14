# Gadget Status and RFID Scan Changes

## FileZilla Paths

These paths are FileZilla-relative paths for the current remote folder, not local temp paths:

- `/assign_student_gadget.php`
- `/assign_student_gadget_edit.php`

## Summary

Documented the recent small behavior changes:

- `Deposit` is now the first status option and the default.
- QR/RFID/cancel reset flows now default status back to `deposit`.
- Unknown RFID scans now show `RFID not found` and do not switch back to `Ready for next scan`.
- Removed the `Auto Release when Scanned` checkbox from the RFID controls.

## Changed Code Lines

### `/assign_student_gadget.php`

Line 66 makes `Deposit` the first and default status option:

```php
<span><input type="radio" name="status" value="deposit" checked /> Deposit</span>&nbsp;
```

Lines 470, 637, and 759 reset the selected status to `deposit`:

```javascript
$("input[name='status'][value='deposit']").prop("checked", true);
```

Line 766 shows the unknown RFID message:

```javascript
$("#rfid-status").text("RFID not found").css("color", "red");
```

### `/assign_student_gadget_edit.php`

Line 54 makes `Deposit` the first and default status option:

```php
<span><input type="radio" name="status" value="deposit" checked /> Deposit</span>&nbsp;
```

Line 443 resets the selected status to `deposit`:

```javascript
$("input[name='status'][value='deposit']").prop("checked", true);
```

## Verification

PHP syntax checks passed:

```text
php -l assign_student_gadget.php
php -l assign_student_gadget_edit.php
```
