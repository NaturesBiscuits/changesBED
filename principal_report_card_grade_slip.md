# Principal Report Card / Grade Slip Documentation

This documents the changes made to the Principal Report Card tab so it follows the Registrar Report Card PDF generation flow.

## Files Involved

Registrar reference files:

```text
Report 2.php
report_card 2.php
students_detail.php
```

Principal files changed locally:

```text
Report.php
report_card.php
```

Upload targets:

```text
Report.php
-> application/controllers/principal/Report.php

report_card.php
-> application/views/principal/reports/report_card.php
```

## Purpose

The Principal Report Card tab needed to behave like Registrar for Form 138 and Grade Slip generation.

Required changes:

- Use `Term` instead of `Quarter`.
- Allow only 3 terms in the selection.
- Add School Year selection.
- Pass selected School Year into Form 138 and Grade Slip generation.
- Make Principal Form 138 / Grade Slip PDF generation fetch and display the same data as Registrar.
- Keep these changes on `report_card`, not `principal_list`.

## View: principal/reports/report_card.php

### 1. Added School Year Selection

Added a `School Year` dropdown before Grade/Section.

The dropdown uses:

```php
$sessionlist
$session_id
```

The selected value is submitted as:

```php
name="session_id"
```

This lets the Report Card tab search students by selected school year.

### 2. Changed Quarter to Term

Changed the visible label from:

```text
Quarter
```

to:

```text
Term
```

Changed the options to:

```text
Term 1
Term 2
Term 3
Final Grade
```

The field name remains:

```php
name="quarter"
```

Reason: the existing controller/model logic still expects the posted key `quarter`, but the UI now displays it as `Term`.

### 3. Added School Year to PDF Forms

Added hidden `session_id` inputs to the PDF submit forms:

```php
principal/report/show_report_card
principal/report/show_grade_slip
```

This applies to:

- Single Form 138
- Batch Form 138
- Single Grade Slip
- Batch Grade Slip

### 4. Copied Registrar-Style Form 138 Modal Flow

Principal Form 138 generation now follows Registrar behavior:

- Clicking `Generate Form 138` opens the customization modal.
- Clicking `Generate Batch Form 138` opens the same modal.
- The modal posts these values:

```php
gdisplay_signature
gdisplay_psignature
gdisplay_attendance
```

These control:

- Teacher signature display
- Principal signature display
- Attendance data display

### 5. Section Loading Uses School Year

The section dropdown now sends both Grade and School Year:

```php
class_id
session_id
```

Endpoint used:

```text
principal/sections/getByClassBySession
```

This matches the Registrar pattern:

```text
registrar/sections/getByClassBySession
```

## Controller: principal/Report.php

### 1. report_card()

Updated the Report Card controller flow to support School Year and Term.

Changes:

- Builds 3-term options for the view.
- Validation label changed from `Quarter` to `Term`.
- Reads posted `session_id`.
- Defaults to the current session if no session is posted.
- Searches students using the selected session:

```php
$this->student_model->searchByClassSectionGender($class, $section, 'Male', $session_id);
$this->student_model->searchByClassSectionGender($class, $section, 'Female', $session_id);
```

### 2. show_report_card()

Updated Principal Form 138 generation to match Registrar behavior.

Changes:

- Reads `session_id` from POST.
- Defaults to current session when blank.
- Reads modal values:

```php
gdisplay_attendance
gdisplay_signature
gdisplay_psignature
```

- Passes modal values to the Form 138 template data.
- Gets teacher advisory using selected session:

```php
$this->classsection_model->get_teacher_advisory($class_id, $section_id, $session_id);
```

- Gets HERN attendance using selected session:

```php
$this->stuattendencecustom_model->get_hern_attendance($student_id, $session_id);
```

- Outputs Form 138 as a download, same as Registrar:

```php
$this->m_pdf->pdf->Output($pdfFilePath, "D");
```

### 3. get_report_card()

Updated Form 138 data generation.

Changes:

- Gets student information by selected session:

```php
$this->student_model->getBySession($student_id, $session_id);
```

- Generates grade layout using:

```php
$this->get_layout_grade($data);
```

- Keeps Principal template selection:

```php
template/form138/Form138Template
template/form138/Form138Template_shs
```

## Grade Slip Alignment With Registrar

The Principal Grade Slip was still using older logic, which caused different results from Registrar.

Observed mismatch:

- Registrar showed `SUBJECTS 1 2 3 FR Remark`.
- Principal showed `SUBJECTS 1 2 3 4 FR Remark`.
- Registrar showed numeric grades.
- Principal showed letter output like `O`.
- Registrar conduct showed numeric conduct.
- Principal conduct used a different conduct source.

### 1. show_grade_slip()

Updated Grade Slip generation to use selected School Year.

Changes:

- Reads posted `session_id`.
- Defaults to current session when blank.
- Uses selected session for:

```php
$this->session_model->get($session_id);
$this->classsection_model->get_teacher_advisory($class_id, $section_id, $session_id);
```

### 2. get_grade_slip()

Updated single Grade Slip data fetch.

Changes:

- Gets student data by selected session:

```php
$this->student_model->getBySession($student_id, $session_id);
```

- Passes selected session into grade and conduct layout helpers.

### 3. get_batch_grade_slip()

Updated batch Grade Slip data fetch.

Changes:

- Gets student data by selected session:

```php
$this->student_model->getBySession($student_id, $session_id);
```

- Passes selected session into grade and conduct layout helpers.

### 4. get_layout_grade_slip()

Aligned Principal Grade Slip grade layout with Registrar.

Changes:

- Uses session-specific grading settings:

```php
$this->gradingsetting_model->getBySession($session_id);
```

- Uses session-specific strand lookup:

```php
$this->studentstrand_model->get_latest_strand($student_id, $semester, $session_id);
```

- Uses session-specific subject setup:

```php
$this->specializedsubject_model->getByStrandSemester($strand_id, $semester, $session_id);
$this->customsubject_model->getSubjectbySemester($student_id, $semester, $session_id);
$this->customsubject_model->unsetsubjectdrop($list_of_subjects, $student_id, $semester, $session_id);
$this->subjectmanager_model->getBySubjectSession($subject_id, $session_id);
```

- Uses session-specific computed grades:

```php
$this->subjectcombine_model->getComputedCombinedGrade($student_id, $subject_id, $x, $combine_category, $session_id);
```

- Uses session-specific child-subject checks:

```php
$this->subjectcombine_model->checkifChild($subject_id, $combine_category, $session_id);
```

- JHS Grade Slip now uses only 3 terms:

```php
array('1','2','3')
```

- Removed letter-grade display for Grade Slip. Principal now prints numeric computed grades like Registrar.

### 5. get_layout_conduct_grade_slip()

Aligned Principal conduct output with Registrar.

Old Principal behavior:

```php
$this->conductimportbatchdetail_model->getAllDetailsConductByStudentPerQuarter(...)
```

New Registrar-matching behavior:

```php
$this->conductimportsubject_model->getStudentConduct(...)
```

The helper now also:

- Uses selected `session_id`.
- Uses 3 terms for JHS.
- Uses strand-aware conduct lookup when strand is enabled.
- Prints numeric conduct values.
- Computes final conduct average and remarks on Final Grade.

### 6. generate_batch_slip_data()

Updated batch Grade Slip table output to match Registrar.

Changes:

- Reads session-specific grading settings.
- Uses `display_conduct` setting before showing conduct.
- Uses the same 6-column spacer as Registrar:

```php
<td colspan="6">&nbsp;</td>
```

This matches the 3-term layout:

```text
SUBJECTS | 1 | 2 | 3 | FR | Remark
```

## Principal List Revert

The earlier Principal List changes were removed because the requested change belongs to Report Card.

Confirmed removed from:

```text
principal_list.php
```

No Report Card PDF controls or School Year/Term changes should be on the Principal List tab.

## Validation

Syntax checks passed:

```text
php -l Report.php
php -l report_card.php
php -l principal_list.php
```

## Retest Checklist

In Principal:

1. Open Reports > Report Card.
2. Confirm fields show:

```text
School Year
Grade
Section
Term
```

3. Confirm Term options are:

```text
Term 1
Term 2
Term 3
Final Grade
```

4. Select the same School Year, Grade, Section, and Term as Registrar.
5. Generate Grade Slip for the same student.
6. Confirm Principal and Registrar Grade Slip match for:

- Header term columns
- Subject list
- Numeric grades
- Conduct row
- Adviser name
- Registrar/prepared by name

7. Generate Form 138 and confirm the customization modal appears.
8. Confirm School Year affects both search results and generated PDFs.
