# Status Controls And Message Placement Changes

FileZilla path: `dormitorydean/hostelroom/assign_student_gadget`

Purpose: remove the visible Release option because the page already has a Release button, keep add mode clean, and show success/error messages below the RFID Scan box.

## View: `assign_student_gadget.php`

### Lines 64-69

Only Deposit and Confiscated are visible. Release remains as a hidden internal radio so the Release button can still submit `status = release`.

```php
<span><input type="radio" name="status" value="deposit" checked /> Deposit</span>&nbsp;
<span><input type="radio" name="status" value="confiscated" /> Confiscated</span>&nbsp;
<input type="radio" name="status" value="release" style="display: none;" aria-hidden="true" />
<span class="text-danger"><?php echo form_error('status'); ?></span>
<span id="save-as-new-status-error" class="text-danger" style="display: none;">Release is selected. Choose Deposit or Confiscated before saving as a new device.</span>
```

### Lines 109-112

The footer contains normal Add/Save, Save as New Device, Release, and Cancel. Edit-only buttons are hidden until a row is selected.

```php
<button type="submit" id="save-btn" class="btn btn-info pull-right">Add & Save</button>
<button type="button" id="save-as-new-btn" class="btn btn-success pull-right" style="margin-right: 5px; display: none;"><i class="fa fa-copy"></i> Save as New Device</button>
<button type="button" id="release-btn" class="btn btn-warning pull-right" style="margin-right: 5px; display: none;"><i class="fa fa-check"></i> Release</button>
<button type="button" id="cancel-edit" class="btn btn-default pull-right" style="margin-right: 5px; display: none;">Cancel</button>
```

### Lines 131-134

Flash messages and AJAX gadget messages were moved below the RFID Scan button box.

```php
<?php if ($this->session->flashdata('msg')) { ?>
    <?php echo $this->session->flashdata('msg') ?>
<?php } ?>
<div id="gadget-action-message"></div>
```

### Lines 582-585

The Release button is shown only for records that are not already released.

```javascript
if (row.data("status") && row.data("status") !== "release") {
    $("#release-btn").show();
} else {
    $("#release-btn").hide();
}
```

### Lines 673-677

Clicking Release checks the hidden release radio and submits the form.

```javascript
$("#release-btn").click(function () {
    $("input[name='status']").prop("checked", false);
    $("input[name='status'][value='release']").prop("checked", true);
    $("#form1").submit();
});
```

### Lines 731-751

Cancel returns the form to add mode, resets status to Deposit, hides Release and Save as New Device, and clears the small device panel.

```javascript
$("#cancel-edit").click(function () {
    $("#gadget_id").val("");
    $("#student_name").val("");
    $("#student_id").val("");
    $("input[name='status']").prop("checked", false);
    $("input[name='status'][value='deposit']").prop("checked", true);
    $("input[name='device']").prop("checked", false);
    $("input[name='device'][value='phone']").prop("checked", true);
    $("#description").val("");
    $("#hostel_room_id").val("");
    $("#save-btn").text("Add & Save");
    $("#save-as-new-btn").hide();
    $("#cancel-edit").hide();
    $("#release-btn").hide();
    $("#save-as-new-status-error").hide();
    selectedStudentForGadgetPanel = null;
    selectedGadgetTable = "#active-gadget-table";
    $("#student-gadget-panel").appendTo("#student-gadget-panel-home");
    $("#student-gadget-panel").hide();
    $("#student-gadget-table-body").empty();
    $("#student-gadget-summary").text("");
});
```

## Expected Result

- Add mode does not show Release.
- Edit mode shows Release only for active deposit/confiscated records.
- Released rows can still save internally as release because the hidden radio exists.
- Save as New Device cannot save a new released record.
- Success messages appear below the RFID Scan box.

## Release History Status Read-only Update

When a row is opened from Released History, the status controls are hidden and replaced with a read-only display of the current status. The hidden `release` radio remains checked and enabled so saving device/description edits still submits the correct status.

### View lines 63-68

```php
<span id="status-radio-options">
    <span><input type="radio" name="status" value="deposit" checked /> Deposit</span>&nbsp;
    <span><input type="radio" name="status" value="confiscated" /> Confiscated</span>&nbsp;
    <input type="radio" name="status" value="release" style="display: none;" aria-hidden="true" />
</span>
<span id="status-readonly-label" class="text-muted" style="display: none;"></span>
```

### View lines 453-462

```javascript
function setStatusReadonly(isReadonly, statusText) {
    $("input[name='status'][value='deposit'], input[name='status'][value='confiscated']").prop("disabled", isReadonly);
    if (isReadonly) {
        $("#status-radio-options").hide();
        $("#status-readonly-label").text(statusText).show();
    } else {
        $("#status-radio-options").show();
        $("#status-readonly-label").hide().text("");
    }
}
```

### View line 599

```javascript
setStatusReadonly(sourceTable === "#released-history-table", formatStatusText(row.data("status")));
```

Add mode, Cancel, QR, and RFID reset paths call `setStatusReadonly(false)` so Deposit/Confiscated become editable again outside Released History editing.

## Interactive Release Button Label

When an active gadget row is selected for editing, the Release button starts as `Release`. The form stores a snapshot of the selected row. If the user changes the selected student, status, device, or description before clicking Release, the button label changes to `Save & Release`.

The button has a fixed width so changing from `Release` to `Save & Release` does not resize the footer buttons.

```php
<button type="button" id="release-btn" class="btn btn-warning pull-right" style="margin-right: 5px; display: none; width: 132px; white-space: nowrap;"><i class="fa fa-check"></i> <span class="release-btn-text">Release</span></button>
```

```javascript
function setReleaseButtonChanged(hasChanges) {
    var label = hasChanges ? "Save & Release" : "Release";
    var icon = hasChanges ? "fa-save" : "fa-check";
    $("#release-btn i").removeClass("fa-check fa-save").addClass(icon);
    $("#release-btn .release-btn-text").text(label);
}
```

## Gadget Panel Stable Footer Layout

The Gadget box now has scoped responsive CSS under `#gadget-box` so action buttons do not resize the panel when edit-mode buttons appear or when `Release` changes to `Save & Release`.

The footer uses flex wrapping with fixed button widths on desktop and full-width buttons on very small screens.

```css
#gadget-box .box-footer {
    min-height: 96px;
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-end;
    align-items: flex-start;
    gap: 6px;
}

#gadget-box .gadget-action-btn {
    float: none !important;
    width: 132px;
    min-width: 132px;
    max-width: 132px;
    margin: 0 !important;
    white-space: nowrap;
}
```

## Fixed Action Button Slots

The Gadget form footer now uses CSS grid slots so showing `Release` does not push `Cancel` to another position. Desktop/tablet uses two columns:

```css
grid-template-areas:
    "new release"
    "cancel save";
```

Each button sits inside a stable slot:

```html
<div class="gadget-action-slot gadget-action-slot-new">...</div>
<div class="gadget-action-slot gadget-action-slot-release">...</div>
<div class="gadget-action-slot gadget-action-slot-cancel">...</div>
<div class="gadget-action-slot gadget-action-slot-save">...</div>
```

On very small screens the slots stack vertically, so the layout remains flexible without buttons overlapping or forcing horizontal overflow.

## Save Edit And Cancel Changes Labels

The edit form now stores the selected gadget row as its original state. When the user changes student, status, device, or description:

- `Save` changes to `Save Edit`.
- `Release` changes to `Save & Release` when Release is available.
- `Cancel` changes to `Cancel Changes`.

Clicking `Cancel Changes` restores the selected gadget's original values instead of clearing the form. The selected student and the small gadget panel remain visible, so the user does not need to click the student/device row again.

```javascript
function updateEditActionLabels() {
    var hasChanges = hasEditChanges();

    if (!currentGadgetSnapshot) {
        $("#save-btn").text("Add & Save");
        $("#cancel-edit").text("Cancel");
        setReleaseButtonChanged(false);
        return;
    }

    $("#save-btn").text(hasChanges ? "Save Edit" : "Save");
    $("#cancel-edit").text(hasChanges ? "Cancel Changes" : "Cancel");
}
```

## RFID Auto-release Toggle

The RFID panel has an `Auto-release` toggle with clear ON/OFF states.

- OFF: `btn-default`, label `Auto-release: Off`, toggle-off icon.
- ON: `btn-danger`, label `Auto-release: On`, toggle-on icon.

When ON, RFID scan auto-releases only if the scanned student has exactly one active device in the Dormitory Declared Gadget List. If the student has multiple active devices, the system does not auto-release; it highlights the student's devices and requires the user to select one manually from the Devices table.

The temporary RFID test button is labeled `Test RFID(temporary)` and uses RFID `0786350130`.

## Action-specific Success Messages

The page now shows clearer action messages under the RFID box:

- `{Student Name} successfully released.`
- `{Student Name} added on Device list.`
- `{Student Name} gadget edit saved.`

For normal form submissions, the message is stored in `sessionStorage` before reload and displayed after the page returns. For AJAX Save as New Device, the message is shown immediately without a reload.

## Cancel Behavior And Panel Title

The Gadget form title was renamed to `Deposit Information`.

Cancel now has two behaviors:

- `Cancel Changes`: if unsaved edits exist, it restores the selected gadget's original values and keeps the selected student/device panel visible.
- `Cancel`: if there are no unsaved edits, it clears the current selected student/form and hides the device panel.



