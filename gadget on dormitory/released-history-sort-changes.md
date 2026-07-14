# Released History Sort Changes

## FileZilla Paths

These paths are FileZilla-relative paths for the current remote folder, not local temp paths:

- `/assign_student_gadget.php`
- `/assign_student_gadget_edit.php`

## Summary

Updated the `Released History` table so the latest released gadget appears at the top of the table.

The sort uses `updated_at` in descending order:

- newest `updated_at` first
- oldest `updated_at` last

## Changed Code Lines

### `/assign_student_gadget.php`

Lines 220-222 sort released rows before displaying them:

```php
usort($released, function ($a, $b) {
    return strtotime($b['updated_at']) - strtotime($a['updated_at']);
});
```

### `/assign_student_gadget_edit.php`

Lines 193-195 sort released rows before displaying them:

```php
usort($released, function ($a, $b) {
    return strtotime($b['updated_at']) - strtotime($a['updated_at']);
});
```

## Verification

PHP syntax checks passed for both changed files:

```text
php -l assign_student_gadget.php
php -l assign_student_gadget_edit.php
```
