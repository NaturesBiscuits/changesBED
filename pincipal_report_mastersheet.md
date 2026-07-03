# Principal Master Sheet Changes

This documents the changes made to replicate and fix the Master Sheet feature under Principal Reports without editing the teacher files.

## Files To Upload

```text
Report 2.php
-> application/controllers/principal/Report.php

master_sheet 2.php
-> application/views/principal/reports/master_sheet.php

grade_master_sheet.php
-> application/views/principal/reports/grade_master_sheet.php
```

Teacher files were used only as reference:

```text
Report.php
master_sheet.php
```

## Controller: Principal Report.php

Local file:

```text
Report 2.php
```

### 1. Master Sheet Route

Code area:

```text
Report 2.php around line 5779
function master_sheet()
```

Purpose:

- Handles the Principal Report > Master Sheet page.
- Loads the principal master sheet view.
- Accepts selected School Year, Grade, Section, Term, Semester.
- Handles the `PRINT MASTER SHEET` action.

Important code:

```php
$this->load->view('principal/reports/master_sheet', $data);
```

### 2. School Year Support

Code area:

```text
Report 2.php around lines 5795-5807
```

Added/used:

```php
$session = $this->session_model->getAllSession();
$setting_result = $this->setting_model->get();
$session_id = $setting_result[0]['session_id'];
$session_session_id = $this->session->userdata('grade_set_session');
if( $session_session_id ){
    $session_id = $session_session_id;
}
$data['session_id'] = $session_id;
$data['sessionlist'] = $session;
```

Purpose:

- Shows School Year selection on the principal master sheet.
- Remembers the selected school year after search/print.

### 3. Term Validation Label

Code area:

```text
Report 2.php around line 5810
```

Changed validation label from Quarter to Term:

```php
$this->form_validation->set_rules('quarter', 'Term', 'trim|required|xss_clean');
```

Purpose:

- Validation/error messages now refer to `Term`, matching the UI.

### 4. Faster Print Handling

Code area:

```text
Report 2.php around lines 5818-5822
```

Added direct PDF generation:

```php
if( isset($action) && $action == 'print_master_sheet'){  
    $this->print_master_sheet( $class, $section, $quarter, $semester_id, $session_id );
    return;
}
```

Purpose:

- Prevents timeout by generating the PDF directly.
- Avoids rebuilding the full on-screen table before download.

### 5. Filtered Subject Query

Code area:

```text
Report 2.php around line 5832
```

Changed to match teacher behavior:

```php
$subjectlist = $this->subject_model->getSubjctByClass( $class, true );
```

Purpose:

- Reduces extra subjects/processing.
- Helps principal Master Sheet behave like teacher Master Sheet.

### 6. Section AJAX Endpoint

Code area:

```text
Report 2.php around line 5859
public function getSectionsByClass()
```

Purpose:

- Lets the principal view load Section options after selecting Grade.
- Replaces dependency on teacher route.

Used by:

```text
master_sheet 2.php around lines 574 and 612
principal/report/getSectionsByClass
```

### 7. Strand AJAX Endpoint

Code area:

```text
Report 2.php around line 5872
public function allowStrand()
```

Purpose:

- Lets the principal view check if selected Grade uses Strand/Semester.
- Replaces dependency on teacher route.

Used by:

```text
master_sheet 2.php around lines 591 and 625
principal/report/allowStrand
```

### 8. PDF Generation

Code area:

```text
Report 2.php around line 3571
public function print_master_sheet(...)
```

Updated function signature:

```php
public function print_master_sheet( $class_id, $section_id, $quarter, $semester_id=null, $session_id=null )
```

Purpose:

- Allows selected School Year to be used in PDF.
- Prevents always falling back to current school year.

### 9. Missing Quarter Variable Fix

Code area:

```text
Report 2.php before loading template/master_sheet
```

Added:

```php
$data['quarter'] = $quarter;
```

Purpose:

- Fixes PHP notice:

```text
Undefined variable: quarter
Filename: template/master_sheet.php
```

### 10. PDF Name Color Coding

Code areas:

```text
Report 2.php around lines 3765 and 4286
Report 2.php around lines 4010 and 4482
```

Male names:

```css
color:#0000FF;
```

Female names:

```css
color:#FF00FF;
```

Purpose:

- Matches teacher PDF output.
- Male students display dark blue.
- Female students display dark pink.

### 11. Prepared By Section

Code area:

```text
Report 2.php around line 4659
```

Changed bottom PDF section from:

```text
Signature
Approved by: PRINCIPAL PRINCIPAL
Principal
```

To:

```text
Prepared by:

Mrs./Mr. Adviser Name
Class Adviser
```

Purpose:

- Matches teacher Master Sheet PDF.
- Uses adviser data from:

```php
$teacher_details = $this->classsection_model->get_teacher_advisory(...);
```

### 12. Conduct Print Fix

Code area:

```text
Report 2.php around line 3554
private function getMasterSheetConductValue(...)
```

Added helper:

```php
private function getMasterSheetConductValue( $student_id, $class_id, $section_id, $quarter, $session_id=null )
```

Purpose:

- Makes PDF Conduct use the same source as the visible master sheet page.
- Prevents Conduct grades appearing in print when the page shows blank.

Uses same lookup as view:

```php
$this->conductsession_model->getDetailByclassAndSection(...)
$this->conductimportbatchdetail_model->getAllDetailsConductByStudentPerQuarter(...)
```

Replaced Conduct print blocks around:

```text
Report 2.php around lines 3918, 4162, 4412, 4608
Report 2.php around lines 6234, 6478, 6728, 6924
```

### 13. Numeric Grade Output

Code areas:

```text
Report 2.php master sheet PDF output blocks
grade_master_sheet.php master sheet view output blocks
```

Removed master sheet display conversion using:

```php
$this->grade_model->get_letter_grade_special(...)
```

Purpose:

- Principal Master Sheet should display numeric values like:

```text
89, 90, 80
```

instead of letter values like:

```text
O, FS
```

Note:

- Other report card related letter-grade calls remain in `Report 2.php`; only Master Sheet output was changed.

## View: Principal master_sheet.php

Local file:

```text
master_sheet 2.php
```

### 1. Principal Form Action

Code areas:

```text
master_sheet 2.php around lines 24 and 126
```

Uses:

```php
site_url('principal/report/master_sheet')
```

Purpose:

- The principal page posts back to the principal controller.
- Does not use teacher routes.

### 2. School Year Field

Code area:

```text
master_sheet 2.php around line 30
```

Added label and dropdown:

```text
School Year
```

Uses:

```php
$sessionlist
$session_id
```

Purpose:

- Principal can select which school year/session to load.

### 3. Grade, Section, Term Labels

Code areas:

```text
master_sheet 2.php around lines 47, 68, 93
```

Visible labels:

```text
Grade
Section
Term
```

Purpose:

- Matches requested principal UI.
- `quarter` remains the internal field name because controller/model logic expects it.

### 4. Term Dropdown

Code area:

```text
master_sheet 2.php around lines 96-103
```

Term 4 is skipped:

```php
if ($key == 4) {
    continue;
}
```

Dropdown text:

```php
Term <?php echo $key; ?>
```

Visible options:

```text
Term 1
Term 2
Term 3
Final
```

### 5. Section AJAX

Code areas:

```text
master_sheet 2.php around lines 574 and 612
```

Uses:

```javascript
principal/report/getSectionsByClass
```

Purpose:

- Section dropdown populates after selecting Grade.
- No dependency on teacher section controller.

### 6. Strand AJAX

Code areas:

```text
master_sheet 2.php around lines 591 and 625
```

Uses:

```javascript
principal/report/allowStrand
```

Purpose:

- Shows/hides Semester field when the selected Grade requires Strand/Semester.

### 7. Print Form

Code area:

```text
master_sheet 2.php around lines 124-129
```

Hidden fields include:

```php
class_id
section_id
quarter
semester_id
session_id
action = print_master_sheet
```

Purpose:

- Sends all selected filters to the print function.
- Ensures selected School Year is used in PDF.

## View: Principal grade_master_sheet.php

Local file:

```text
grade_master_sheet.php
```

### Numeric Grade Display

Removed Master Sheet letter-grade conversion:

```php
$this->grade_model->get_letter_grade_special(...)
```

Purpose:

- Prevents alphabetic output like `O`, `FS`.
- Displays numeric grade values.

## Upload Checklist

Upload these after changes:

```text
Report 2.php
-> application/controllers/principal/Report.php

master_sheet 2.php
-> application/views/principal/reports/master_sheet.php

grade_master_sheet.php
-> application/views/principal/reports/grade_master_sheet.php
```

Do not overwrite teacher files:

```text
application/controllers/teacher/Report.php
application/views/teacher/reports/master_sheet.php
```

## Verification Done

Syntax checks passed for edited files:

```text
Report 2.php
master_sheet 2.php
grade_master_sheet.php
```

