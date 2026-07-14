# Student Gadget Panel Changes

## FileZilla Path

This path is a FileZilla-relative path for the current remote folder, not a local temp path:

- `/assign_student_gadget.php`

## Summary

Added a small vertical scrollable table below the `Description` field.

The panel appears when the selected or scanned student has multiple active gadgets in `Dormitory Declared Gadget List`.

Behavior:

- Keeps the existing highlight on matching rows in the main gadget table.
- Shows a summary like `Devices: phone(2), laptop, tablet(2), others`.
- Lists the student's active gadget rows in a compact table.
- Clicking a row in the compact table selects the matching gadget row for release.
- The panel refreshes after table reloads if a student is still selected.

## Changed Code Lines

### `/assign_student_gadget.php`

Lines 91-108 add the scrollable student gadget panel under `Description`:

```php
<div id="student-gadget-panel" class="form-group" style="display: none;">
    <label id="student-gadget-summary" style="font-weight: normal;"></label>
    <div class="table-responsive" style="max-height: 160px; overflow-y: auto; border: 1px solid #ddd;">
        <table class="table table-striped table-bordered table-hover" style="margin-bottom: 0;">
            <thead>
                <tr>
                    <th>Device</th>
                    <th>Status</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody id="student-gadget-table-body"></tbody>
        </table>
    </div>
</div>
```

Line 365 stores which student's gadget panel is currently active:

```javascript
var selectedStudentForGadgetPanel = null;
```

Line 567 refreshes the panel when a main gadget row is selected:

```javascript
renderStudentGadgetPanel(row.data("student-id"));
```

Lines 575-587 build the device summary text:

```javascript
function getDeviceSummary(devices) {
    var counts = {};
    var parts = [];
    $.each(devices, function (_, device) {
        device = $.trim(String(device || "").toLowerCase());
        if (!device) return;
        counts[device] = (counts[device] || 0) + 1;
    });
    $.each(counts, function (device, count) {
        parts.push(count > 1 ? device + "(" + count + ")" : device);
    });
    return parts.join(", ");
}
```

Lines 589-591 escape copied table values before inserting them into the compact table:

```javascript
function escapeHtml(value) {
    return $("<div>").text(value).html();
}
```

Lines 593-623 render and show/hide the compact table:

```javascript
function renderStudentGadgetPanel(studentId) {
    selectedStudentForGadgetPanel = studentId;
    var rows = $("#active-gadget-table tbody tr.gadget-row").filter(function () {
        return String($(this).data("student-id")) === String(studentId);
    });
    ...
}
```

Lines 626-631 let a compact-table row select the matching main gadget row:

```javascript
$(document).on("click", ".student-gadget-option", function () {
    var gadgetId = $(this).data("gadget-id");
    $("#active-gadget-table tbody tr.gadget-row").filter(function () {
        return String($(this).data("id")) === String(gadgetId);
    }).first().trigger("click");
});
```

Lines 633-638 keep the existing highlight and update the compact panel together:

```javascript
function highlightStudentGadgetRows(studentId) {
    $("#active-gadget-table tbody tr").removeClass("info");
    $("#active-gadget-table tbody tr").filter(function () {
        return String($(this).data("student-id")) === String(studentId);
    }).addClass("info");
    renderStudentGadgetPanel(studentId);
}
```

Lines 672-675 clear the compact panel when `Cancel` is clicked:

```javascript
selectedStudentForGadgetPanel = null;
$("#student-gadget-panel").hide();
$("#student-gadget-table-body").empty();
$("#student-gadget-summary").text("");
```

Lines 736-737 rebuild the compact panel after table refresh:

```javascript
if (selectedStudentForGadgetPanel) {
    highlightStudentGadgetRows(selectedStudentForGadgetPanel);
}
```

## Verification

PHP syntax check passed:

```text
php -l assign_student_gadget.php
```
