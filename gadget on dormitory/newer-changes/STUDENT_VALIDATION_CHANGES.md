# Student Validation Changes

FileZilla path: `dormitorydean/hostelroom/assign_student_gadget`

Purpose: when a user manually types a student name that does not exist, the form should show an error instead of reloading the page and saving nothing.

Important note: this temp folder does not contain `Hostelroom.php`; it contains the view and model files only. Controller snippets below are the required support code for the `dormitorydean/hostelroom/assign_student_gadget` route.

## View: `assign_student_gadget.php`

### Lines 53-56

Added/used the hidden `student_id` field and inline validation message beside the Name input.

```php
<input type="text" list="student_list" class="form-control" id="student_name" name="student_name" autocomplete="off" value="<?php echo html_escape($student_fullname); ?>">
<datalist id="student_list"></datalist>
<input type="hidden" id="student_id" name="student_id"  value="<?php echo $student_result_id; ?>">
<span id="student-error" class="text-danger" style="display: none;">Student does not exist. Please select a student from the suggestions.</span>
```

### Lines 397-407

Typing in the field checks the datalist. If the name is not a valid option, `student_id` is cleared. This prevents stale IDs from a previous selected student.

```javascript
$("#student_name").bind('input', function () {
    var x = checkExists( $('#student_name').val() );
    $('#student_id').val(x || '');
    $("#student-error").hide();
    $(document).trigger("student:gadget-selection", [x || null]);
    if ($('#student_name').val().trim() !== '') {
        $("#cancel-edit").show();
    } else {
        $("#cancel-edit").hide();
    }
});
```

### Lines 409-423

`checkExists()` returns the matching student id from the datalist.

```javascript
function checkExists(inputValue) {
    console.log(inputValue);

    var x = document.getElementById("student_list");
    var i;
    var flag;
    var flagx;
    for (i = 0; i < x.options.length; i++) {
        if(inputValue == x.options[i].value){
            flag = true;
            flagx = $( x.options[i] ).attr('data-id');
        }
    }
    return flagx;
}
```

### Lines 425-436

Submit is blocked when `student_id` is empty. The error text changes depending on whether the field is blank or contains an invalid name.

```javascript
$("#form1").on("submit", function (event) {
    var studentId = $("#student_id").val();
    var studentName = $("#student_name").val().trim();

    if (!studentId) {
        event.preventDefault();
        $("#student-error")
            .text(studentName ? "Student does not exist. Please select a student from the suggestions." : "Student name is required.")
            .show();
        $("#student_name").focus();
    }
});
```

## Required Controller Validation

The controller should also validate the posted student because client-side checks can be bypassed.

```php
if ($this->input->post('action') === 'assign_student') {
    $student_id = $this->input->post('student_id');
    $student = null;

    if ($student_id) {
        $student = $this->db
            ->select('id')
            ->from('students')
            ->where('id', $student_id)
            ->limit(1)
            ->get()
            ->row_array();
    }

    if (empty($student)) {
        $message = 'Student does not exist. Please select a student from the suggestions.';

        if ($this->input->is_ajax_request()) {
            echo json_encode(array(
                'success' => false,
                'message' => $message,
                'csrf_name' => $this->security->get_csrf_token_name(),
                'csrf_hash' => $this->security->get_csrf_hash()
            ));
            return;
        }

        $data['error_message'] = $message;
    }
}
```



