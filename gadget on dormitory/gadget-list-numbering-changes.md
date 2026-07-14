# Gadget List Numbering Changes

## FileZilla Paths

These paths are FileZilla-relative paths for the current remote folder, not local temp paths:

- `/assign_student_gadget.php`
- `/assign_student_gadget_edit.php`

## Summary

Added record totals to these section titles:

- `Dormitory Declared Gadget List`
- `Released History`

The declared gadget total counts all gadget records where `student_gadget_status` is not `release`.
The released history total counts all gadget records where `student_gadget_status` is `release`.

## Changed Code Lines

### `/assign_student_gadget.php`

Lines 12-24 add the counters:

```php
$active_gadget_count = 0;
$released_gadget_count = 0;

if (!empty($studenthostelroomgadget)) {
    foreach ($studenthostelroomgadget as $gadget_count_item) {
        if ($gadget_count_item['student_gadget_status'] == 'release') {
            $released_gadget_count++;
        } else {
            $active_gadget_count++;
        }
    }
}
```

Line 39 adds an ID to the form title:

```php
<h3 id="gadget-form-title" class="box-title"><?php echo 'Gadget'; ?></h3>
```

Line 124 shows the active declared gadget count:

```php
<h3 id="active-gadget-title" class="box-title titlefix" style="padding: 0px 0px 35px 0px;">Dormitory Declared Gadget List (<?php echo $active_gadget_count; ?>)</h3> <br/>
```

Line 191 shows the released history count:

```php
<h3 id="released-history-title" class="box-title titlefix" style="padding: 0px 0px 35px 0px;">Released History (<?php echo $released_gadget_count; ?>)</h3>
```

Lines 615-620 refresh the title counts after AJAX table updates:

```javascript
var newActiveTitle = $(html).find("#active-gadget-title").html();
var newReleasedTitle = $(html).find("#released-history-title").html();
$("#active-gadget-title").html(newActiveTitle);
$("#released-history-title").html(newReleasedTitle);
```

### `/assign_student_gadget_edit.php`

Lines 12-24 add the counters:

```php
$active_gadget_count = 0;
$released_gadget_count = 0;

if (!empty($studenthostelroomgadget)) {
    foreach ($studenthostelroomgadget as $gadget_count_item) {
        if ($gadget_count_item['student_gadget_status'] == 'release') {
            $released_gadget_count++;
        } else {
            $active_gadget_count++;
        }
    }
}
```

Line 39 adds an ID to the form title:

```php
<h3 id="gadget-form-title" class="box-title"><?php echo $this->lang->line('add_hostel_room'); ?></h3>
```

Line 116 shows the active declared gadget count:

```php
<h3 id="active-gadget-title" class="box-title titlefix">Dormitory Declared Gadget List (<?php echo $active_gadget_count; ?>)</h3> <br/>
```

Line 182 shows the released history count:

```php
<h3 id="released-history-title" class="box-title titlefix">Released History (<?php echo $released_gadget_count; ?>)</h3>
```

Lines 448 and 461 scope title changes to the form title only:

```javascript
$("#gadget-form-title").text("Edit Declared Gadget");
$("#gadget-form-title").text("<?php echo $this->lang->line('add_hostel_room'); ?>");
```
