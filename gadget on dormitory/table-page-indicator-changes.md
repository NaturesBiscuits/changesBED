# Table Page Indicator Changes

## FileZilla Path

This path is a FileZilla-relative path for the current remote folder, not a local temp path:

- `/assign_student_gadget.php`

## Summary

Added a top-right page number display in the section header for these tables:

- `Dormitory Declared Gadget List`
- `Released History`

The page display updates when the existing `Previous` and `Next` pagination buttons change the visible table page.

## Changed Code Lines

### `/assign_student_gadget.php`

Line 124 adds the top-right page indicator for `Dormitory Declared Gadget List`:

```php
<span id="active-gadget-page-info" class="text-muted pull-right">Page 1 of 1</span>
```

Line 188 adds the top-right page indicator for `Released History`:

```php
<span id="released-history-page-info" class="text-muted pull-right">Page 1 of 1</span>
```

Line 578 maps each table to its page indicator:

```javascript
var $pageInfo = $(tableId.replace("-table", "-page-info"));
```

Lines 583-588 keep the page indicator correct when a table has one page or fewer:

```javascript
if (rows.length <= perPage) {
    $pageInfo.text("Page 1 of 1");
    $table.find(".pagination-wrap").remove();
    rows.show();
    return;
}
```

Line 595 updates the page indicator whenever the current page changes:

```javascript
$pageInfo.text("Page " + (page + 1) + " of " + totalPages);
```

Lines 597-598 keep the bottom pagination row aligned with the real column header row:

```javascript
var columnCount = $table.find("thead tr:last th").length;
var html = '<tr class="pagination-wrap"><td colspan="' + columnCount + '"><div style="text-align:center;margin-top:8px;">';
```

## Verification

PHP syntax check passed:

```text
php -l assign_student_gadget.php
```
