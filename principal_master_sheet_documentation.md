# Principal Master Sheet Changes

This documents the changes made to replicate and fix the Master Sheet feature under Principal Reports without editing the teacher files.

## Files To Upload

```text
Report 2.php
-> -controllers/principal/Report.php

master_sheet 2.php
-> -views/principal/reports/master_sheet.php

grade_master_sheet.php
-> -views/principal/reports/grade_master_sheet.php
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

## Changed Code Lines

Use these snippets as the concrete lines changed for the Principal Report Master Sheet upload.

### Report 2.php

School Year support, selected session persistence, and Term validation:

```php
// Report 2.php lines 5792-5805
$session = $this->session_model->getAllSession();
$setting_result = $this->setting_model->get();
$session_id = $setting_result[0]['session_id'];
$session_session_id = $this->session->userdata('grade_set_session');
if( $session_session_id ){
    $session_id = $session_session_id;
}
$data['current_session_id'] =  $setting_result[0]['session_id'];
$data['session_id'] = $session_id;
$data['current_session'] = $this->setting_model->getCurrentSessionName();
$data['sessionlist'] = $session;
$this->form_validation->set_rules('quarter', 'Term', 'trim|required|xss_clean');
```

Print action now goes directly to PDF and keeps the selected School Year:

```php
// Report 2.php lines 5818-5822
$session_id = $this->input->post('session_id');
$this->session->set_userdata(array('grade_set_session'=>$session_id));
if( isset($action) && $action == 'print_master_sheet'){  
    $this->print_master_sheet( $class, $section, $quarter, $semester_id, $session_id );
    return;
}
```

Filtered subject query:

```php
// Report 2.php line 5832
$subjectlist = $this->subject_model->getSubjctByClass( $class, true );
```

Principal-only AJAX endpoints:

```php
// Report 2.php lines 5859-5880
public function getSectionsByClass(){
    $class_id = $this->input->get('class_id');
    $section_list = array();

    if (!empty($class_id) && method_exists($this->section_model, 'getClassBySection')) {
        $section_list = $this->section_model->getClassBySection($class_id);
    } elseif (!empty($class_id) && method_exists($this->section_model, 'getByClass')) {
        $section_list = $this->section_model->getByClass($class_id);
    }

    echo json_encode($section_list);
}

public function allowStrand(){
    $class_id = $this->input->get('class_id');
    $allow = false;

    if (!empty($class_id)) {
        $allow = $this->strand_model->checkEnable($class_id);
    }

    echo json_encode($allow);
}
```

Conduct helper used by print:

```php
// Report 2.php lines 3554-3569
private function getMasterSheetConductValue( $student_id, $class_id, $section_id, $quarter, $session_id=null ){
    $student_conduct = '';
    $getConductSubject = $this->conductsession_model->getDetailByclassAndSection( $class_id, $section_id );

    if( $getConductSubject ){
        foreach( $getConductSubject as $getConduct => $conduct ){
            $conduct_id = $conduct['id'];
            $conduct_details = $this->conductimportbatchdetail_model->getAllDetailsConductByStudentPerQuarter( $conduct_id, $student_id, $class_id, $section_id, $quarter );
            if( !empty( $conduct_details ) && $conduct_details ){
                $student_conduct .= $conduct_details['conduct'];
            }
        }
    }

    return $student_conduct;
}
```

PDF function signature, selected session fallback, adviser lookup, and missing quarter variable:

```php
// Report 2.php lines 3571-3603
public function print_master_sheet( $class_id, $section_id, $quarter, $semester_id=null, $session_id=null ){  
    $setting_result = $this->setting_model->get();
    if (empty($session_id)) {
        $session_id = $setting_result[0]['session_id'];
    }
    $session_details = $this->session_model->get( $session_id );
    $session_current = $session_details['session'];

    $teacher_details = $this->classsection_model->get_teacher_advisory($class_id, $section_id, $session_id );
    $teacher_lastname = isset($teacher_details->lastname )?$teacher_details->lastname:'';
    $teacher_name = isset($teacher_details->name )?$teacher_details->name:'';
    $teacher_middlename = isset($teacher_details->middlename )?$teacher_details->middlename:'';

    $data['quarter'] = $quarter;
    $enableStrand =  $this->strand_model->checkEnable( $class_id );     
    $subjectlist = $this->subject_model->getSubjctByClass( $class_id );
```

Conduct print blocks replaced with the helper. Same pattern appears around lines 3918, 4162, 4412, and 4608:

```php
// Report 2.php lines 3918-3923
$getConductSubject = $this->getMasterSheetConductValue( $student_id, $class_id, $section_id, $quarter, $session_id );
if( $getConductSubject ){
    echo '<td style= "border: 1px solid black; font-size: 12px;  padding-left: 6px;  padding-right: 6px;">'.$getConductSubject.'</td>';
} else {
    echo '<td style= "border: 1px solid black; font-size: 12px;  padding-left: 6px;  padding-right: 6px;"></td>';
}
```

PDF student name color coding:

```php
// Report 2.php lines 3765 and 4286, male rows
<td style= "border: 1px solid black; font-size: 12px;  padding-left: 6px;  padding-right: 6px;text-transform:uppercase;width:300px;color:#0000FF;"><?php echo $lastname.', '.$firstname.' '.$suffix.' '.$middlename; ?></td>

// Report 2.php lines 4010 and 4482, female rows
<td style= "border: 1px solid black; font-size: 12px;  padding-left: 6px;  padding-right: 6px;text-transform:uppercase;width:300px;color:#FF00FF;"><?php echo $lastname.', '.$firstname.' '.$suffix.' '.$middlename; ?></td>
```

PDF numeric grade output, replacing letter-grade display. Same pattern appears in the master sheet print blocks:

```php
// Report 2.php lines 3890-3894
if( $grade_per_quarter < 75  ){
    echo '<td style= "color:red;border: 1px solid black; font-size: 12px;  padding-left: 6px;  padding-right: 6px;">'.$grade_per_quarter.'</td>';
} else {
    echo '<td style= "border: 1px solid black; font-size: 12px;  padding-left: 6px;  padding-right: 6px;">'.$grade_per_quarter.'</td>';
}
```

Prepared By section:

```php
// Report 2.php lines 4655-4676
<!-- Prepared by Section -->
<table width="100%" style="font-family: sans-serif; font-size: 13px; margin-top: 20px;">
    <tr>
        <td align="left">
            Prepared by:<br/><br/>
            <span style="color: #008000; font-weight: bold;">
                <?php 
                $teacher_title = "";
                if (isset($teacher_details->sex)) {
                    if (strtolower($teacher_details->sex) == 'female') {
                        $teacher_title = "Mrs. ";
                    } else if (strtolower($teacher_details->sex) == 'male') {
                        $teacher_title = "Mr. ";
                    }
                }
                echo $teacher_title . $teacher_lastname . ', ' . $teacher_name . ($teacher_middlename ? ' ' . $teacher_middlename : ''); 
                ?>
            </span><br/>
            <span style="color: #008000;">Class Adviser</span>
        </td>
    </tr>
</table>
```

### master_sheet 2.php

Principal form route and School Year dropdown:

```php
// master_sheet 2.php lines 24 and 30-43
<form id='form1' action="<?php echo site_url('principal/report/master_sheet') ?>"  method="post" accept-charset="utf-8">

<label for="session_id">School Year</label>
<select id="session_id" name="session_id" class="form-control">
    <option value=""><?php echo $this->lang->line('select'); ?></option>
    <?php
    if (isset($sessionlist)) {
        foreach ($sessionlist as $session) {
            ?>
            <option value="<?php echo $session['id']; ?>" <?php echo $session_id == $session['id'] ? "selected" : ""; ?>><?php echo $session['session']; ?></option>
            <?php
        }
    }
    ?>
</select>
```

Grade, Section, and Term labels:

```php
// master_sheet 2.php lines 47, 68, and 93
<label for="class_id">Grade</label>
<label for="section_id">Section</label>
<label for="quarter">Term</label>
```

Term dropdown skips Quarter 4 and shows `Final` separately:

```php
// master_sheet 2.php lines 96-107
<?php
    foreach ($getquarter as $key => $value) {
        if ($key == 4) {
            continue;
        }
    ?>
    <option  value="<?php echo $key; ?>" <?php if($quarter == $key || $quarter == $value) echo "selected"; ?>>Term <?php echo $key; ?></option>
    <?php
    }
?>
<option  value="final" <?php if($quarter == 'final') echo "selected"; ?>>Final</option>
```

Print form now includes `session_id`:

```php
// master_sheet 2.php lines 126-132
<form id='form1' action="<?php echo site_url('principal/report/master_sheet') ?>"  method="post" accept-charset="utf-8">
    <input type="hidden" name="class_id" value="<?php echo $class_id; ?>">
    <input type="hidden" name="section_id" value="<?php echo $section_id; ?>"> 
    <input type="hidden" name="quarter" value="<?php echo $quarter; ?>">
    <input type="hidden" name="semester_id" value="<?php echo $semester_id; ?>">
    <input type="hidden" name="session_id" value="<?php echo $session_id; ?>">
    <input type="hidden" name="action" value="print_master_sheet">
```

Student report links point to principal report card routes:

```php
// master_sheet 2.php lines 164 and 381
$url = base_url().'principal/report/show_report_card/'.$student_id;
```

AJAX calls now use principal report endpoints:

```javascript
// master_sheet 2.php lines 574, 591, 612, and 625
url: base_url + "principal/report/getSectionsByClass",
url: base_url + "principal/report/allowStrand",
url: base_url + "principal/report/getSectionsByClass",
url: base_url + "principal/report/allowStrand",
```

### grade_master_sheet.php

Print form keeps the selected School Year:

```php
// grade_master_sheet.php lines 247-259
<form id='form1mastersheet' class=" pull-right" action="<?php echo site_url('principal/report/master_sheet') ?>"  method="post" accept-charset="utf-8">
    <input type="hidden" name="class_id" value="<?php echo $class_id; ?>">
    <input type="hidden" name="section_id" value="<?php echo $section_id; ?>"> 
    <input type="hidden" name="session_id" value="<?php echo $session_id; ?>"> 
    <input type="hidden" name="quarter" value="<?php echo $quarter; ?>">
    <input type="hidden" name="semester_id" value="<?php echo $semester_id; ?>">
    <input type="hidden" name="action" value="print_master_sheet"> 
```

Numeric grade output replaces the removed `get_letter_grade_special(...)` conversion. Same pattern appears around lines 727, 1217, 1743, and 2137:

```php
// grade_master_sheet.php lines 727-733
if( $grade_per_quarter < 75 ){
    ?>
    <th style="color:red;"><?php echo $grade_per_quarter;?></th>
    <?php 
} else {
    ?>
    <th><?php echo $grade_per_quarter;?></th>
    <?php
}
```

## Upload Checklist

Upload these after changes:

```text
Report 2.php
-> controllers/principal/Report.php

master_sheet 2.php
-> views/principal/reports/master_sheet.php

grade_master_sheet.php
-> views/principal/reports/grade_master_sheet.php
```

Do not overwrite teacher files:

```text
controllers/teacher/Report.php
views/teacher/reports/master_sheet.php
```

## Verification Done

Syntax checks passed for edited files:

```text
Report 2.php
master_sheet 2.php
grade_master_sheet.php
```
