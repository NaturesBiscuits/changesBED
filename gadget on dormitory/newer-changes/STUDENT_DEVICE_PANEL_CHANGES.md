# Student Device Panel Changes

FileZilla path: `dormitorydean/hostelroom/assign_student_gadget`

Purpose: manual student search, RFID scan, Dormitory Declared Gadget List clicks, and Released History clicks should all show the same small device table inside the Gadget form when a student has multiple devices.

## View: `assign_student_gadget.php`

### Lines 90-103

The small table stays inside the Gadget form.

```php
<div id="student-gadget-panel-home"></div>
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

### Lines 169-176

Dormitory Declared Gadget List rows were given data attributes for edit mode and panel rendering.

```php
<tr class="gadget-row" style="cursor: pointer;"
    data-id="<?php echo $studenthostelroom['student_hostel_room_gadget_id'] ?>"
    data-student-id="<?php echo $studenthostelroom['student_id'] ?>"
    data-student-name="<?php echo $studenthostelroom['lastname'].', '.$studenthostelroom['firstname'] ?>"
    data-status="<?php echo $studenthostelroom['student_gadget_status'] ?>"
    data-device="<?php echo $studenthostelroom['device'] ?>"
    data-date="<?php echo $studenthostelroom['gadget_created_date'] ?>"
    data-description="<?php echo $studenthostelroom['description'] ?>">
```

### Lines 253-260

Released History rows use the same `gadget-row` data structure. The date uses the first released timestamp.

```php
<tr class="gadget-row" style="cursor: pointer;"
    data-id="<?php echo $s['student_hostel_room_gadget_id'] ?>"
    data-student-id="<?php echo $s['student_id'] ?>"
    data-student-name="<?php echo $s['lastname'].', '.$s['firstname'] ?>"
    data-status="<?php echo $s['student_gadget_status'] ?>"
    data-device="<?php echo $s['device'] ?>"
    data-date="<?php echo $original_release_at ?>"
    data-description="<?php echo $s['description'] ?>">
```

### Lines 566-587

Clicking a row fills edit mode, selects status/device, shows Save as New Device, and renders the panel for the clicked table.

```javascript
$(document).on("click", ".gadget-row", function () {
    var row = $(this);
    var sourceTable = "#" + row.closest("table").attr("id");
    $("#gadget_id").val(row.data("id"));
    $("#student_name").val(row.data("student-name"));
    $("#student_id").val(row.data("student-id"));
    $("input[name='status']").prop("checked", false);
    $("input[name='status'][value='" + row.data("status") + "']").prop("checked", true);
    $("input[name='device']").prop("checked", false);
    $("input[name='device'][value='" + row.data("device") + "']").prop("checked", true);
    $("#description").val(row.data("description"));
    $("#save-btn").text("Save");
    $("#save-as-new-btn").show();
    $("#cancel-edit").show();
    $("#save-as-new-status-error").hide();
    highlightStudentGadgetRows(row.data("student-id"), sourceTable);
    if (row.data("status") && row.data("status") !== "release") {
        $("#release-btn").show();
    } else {
        $("#release-btn").hide();
    }
});
```

### Lines 607-639

The panel renders all rows for the same student from the selected source table. It only appears when there is more than one matching device.

```javascript
function renderStudentGadgetPanel(studentId, tableSelector) {
    selectedStudentForGadgetPanel = studentId;
    selectedGadgetTable = tableSelector;
    var rows = $(tableSelector + " tbody tr.gadget-row").filter(function () {
        return String($(this).data("student-id")) === String(studentId);
    });
    var devices = [];
    var html = "";

    rows.each(function () {
        var row = $(this);
        var device = $.trim(String(row.data("device") || ""));
        var status = $.trim(String(row.data("status") || ""));
        var date = $.trim(String(row.data("date") || ""));
        devices.push(device);
        html += '<tr class="student-gadget-option" data-gadget-id="' + row.data("id") + '" data-source-table="' + escapeHtml(tableSelector) + '" style="cursor: pointer;">';
        html += '<td>' + escapeHtml(device) + '</td>';
        html += '<td>' + escapeHtml(status) + '</td>';
        html += '<td>' + escapeHtml(date) + '</td>';
        html += '</tr>';
    });

    if (rows.length > 1) {
        $("#student-gadget-panel").appendTo("#student-gadget-panel-home");
        $("#student-gadget-summary").text("Devices: " + getDeviceSummary(devices));
        $("#student-gadget-table-body").html(html);
        $("#student-gadget-panel").show();
    } else {
        $("#student-gadget-panel").hide();
        $("#student-gadget-table-body").empty();
        $("#student-gadget-summary").text("");
    }
}
```

### Lines 641-647

Clicking a device in the small panel triggers the original row in the source table.

```javascript
$(document).on("click", ".student-gadget-option", function () {
    var gadgetId = $(this).data("gadget-id");
    var sourceTable = $(this).attr("data-source-table");
    $(sourceTable + " tbody tr.gadget-row").filter(function () {
        return String($(this).data("id")) === String(gadgetId);
    }).first().trigger("click");
});
```

### Lines 658-671

Manual student search uses the same selection event. Invalid/empty student names clear the panel.

```javascript
$(document).on("student:gadget-selection", function (event, studentId) {
    if (studentId) {
        highlightStudentGadgetRows(studentId);
        return;
    }

    selectedStudentForGadgetPanel = null;
    selectedGadgetTable = "#active-gadget-table";
    $("#active-gadget-table tbody tr, #released-history-table tbody tr").removeClass("info");
    $("#student-gadget-panel").appendTo("#student-gadget-panel-home");
    $("#student-gadget-panel").hide();
    $("#student-gadget-table-body").empty();
    $("#student-gadget-summary").text("");
});
```

### Lines 856-858

RFID scan opens the panel when the scanned student has multiple active gadgets.

```javascript
if (parseInt(data.active_gadget_count, 10) > 1) {
    highlightStudentGadgetRows(data.id);
    $("#rfid-status").text(fullName + " has " + data.active_gadget_count + " active gadgets logged. Select a gadget row, then click Release.").css("color", "orange");
}
```



