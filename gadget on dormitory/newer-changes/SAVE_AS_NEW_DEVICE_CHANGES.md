# Save As New Device Changes

FileZilla path: `dormitorydean/hostelroom/assign_student_gadget`

Purpose: edit mode has a `Save as New Device` button. It creates a separate gadget row instead of updating the selected row.

Important note: this temp folder does not contain `Hostelroom.php`; controller snippets below are the required route behavior.

## View: `assign_student_gadget.php`

### Line 69

Added a red message for attempts to save a released record as a new device.

```php
<span id="save-as-new-status-error" class="text-danger" style="display: none;">Release is selected. Choose Deposit or Confiscated before saving as a new device.</span>
```

### Line 110

Added the Save as New Device button. It is hidden by default.

```php
<button type="button" id="save-as-new-btn" class="btn btn-success pull-right" style="margin-right: 5px; display: none;"><i class="fa fa-copy"></i> Save as New Device</button>
```

### Lines 493-501

When QR/RFID fills a student for add mode, the page resets to Deposit, clears the selected gadget, and hides edit-only buttons.

```javascript
$("#gadget_id").val("");
$("input[name='status']").prop("checked", false);
$("input[name='status'][value='deposit']").prop("checked", true);
$("input[name='device']").prop("checked", false);
$("input[name='device'][value='phone']").prop("checked", true);
$("#description").val("");
$("#save-btn").text("Add & Save");
$("#save-as-new-btn").hide();
$("#release-btn").hide();
$("#save-as-new-status-error").hide();
```

### Lines 578-580

Selecting an existing gadget row shows edit mode and the Save as New Device button.

```javascript
$("#save-btn").text("Save");
$("#save-as-new-btn").show();
$("#cancel-edit").show();
$("#save-as-new-status-error").hide();
```

### Lines 679-723

Save as New Device temporarily clears `gadget_id` only for the serialized AJAX request, then restores it in the visible form. This creates a separate row without leaving edit mode.

```javascript
$("#save-as-new-btn").click(function () {
    if ($("input[name='status']:checked").val() === "release") {
        $("#save-as-new-status-error").show();
        return;
    }

    if (!$("#student_id").val()) {
        $("#form1").trigger("submit");
        return;
    }

    var button = $(this);
    var form = $("#form1");
    var originalGadgetId = $("#gadget_id").val();
    $("#gadget_id").val("");
    var requestData = form.serialize();
    $("#gadget_id").val(originalGadgetId);

    button.prop("disabled", true);
    $.ajax({
        url: form.attr("action"),
        type: "POST",
        data: requestData,
        dataType: "json",
        success: function (data) {
            if (data.csrf_name && data.csrf_hash) {
                form.find('input[name="' + data.csrf_name + '"]').val(data.csrf_hash);
            }

            if (!data.success) {
                $("#gadget-action-message").html('<div class="alert alert-danger text-left">' + escapeHtml(data.message || "Unable to save new device.") + '</div>');
                return;
            }

            $("#gadget-action-message").html('<div class="alert alert-success text-left">' + escapeHtml(data.message) + '</div>');
            refreshTables();
        },
        error: function () {
            $("#gadget-action-message").html('<div class="alert alert-danger text-left">Unable to save new device. Please try again.</div>');
        },
        complete: function () {
            button.prop("disabled", false);
        }
    });
});
```

### Lines 725-729

Changing away from release hides the red warning.

```javascript
$("input[name='status']").change(function () {
    if ($(this).val() !== "release") {
        $("#save-as-new-status-error").hide();
    }
});
```

### Lines 803-818

The tables refresh by AJAX after Save as New Device. This avoids a full reload and keeps the selected table/panel state.

```javascript
function refreshTables() {
    $.get(window.location.href, function (html) {
        var newActive = $(html).find("#active-gadget-table tbody").html();
        var newReleased = $(html).find("#released-history-table tbody").html();
        var newActiveTitle = $(html).find("#active-gadget-title").html();
        var newReleasedTitle = $(html).find("#released-history-title").html();
        $("#active-gadget-table tbody").html(newActive);
        $("#released-history-table tbody").html(newReleased);
        $("#active-gadget-title").html(newActiveTitle);
        $("#released-history-title").html(newReleasedTitle);
        initAllPagination();
        if (selectedStudentForGadgetPanel) {
            highlightStudentGadgetRows(selectedStudentForGadgetPanel, selectedGadgetTable);
        }
    });
}
```

## Required Controller Behavior

Reject AJAX inserts where the new device would be saved with `status = release`.

```php
$is_ajax = $this->input->is_ajax_request();
$gadget_id = $this->input->post('gadget_id');
$status = $this->input->post('status');

if ($is_ajax && empty($gadget_id) && $status === 'release') {
    echo json_encode(array(
        'success' => false,
        'message' => 'Release is selected. Choose Deposit or Confiscated before saving as a new device.',
        'csrf_name' => $this->security->get_csrf_token_name(),
        'csrf_hash' => $this->security->get_csrf_hash()
    ));
    return;
}
```



