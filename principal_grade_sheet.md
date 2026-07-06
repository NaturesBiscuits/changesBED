# Principal Grade Sheet Documentation

This documents the changes made to link the copied Grade Sheet view under Principal Reports.

## Files Involved

Teacher reference files:

```text
Report.php
grade_sheet.php
```

Principal files changed locally:

```text
Report.php
grade_sheet.php
header.php
```

Upload targets:

```text
Report.php
-> application/controllers/principal/Report.php

grade_sheet.php
-> application/views/principal/reports/grade_sheet.php

header.php
-> application/views/layout/principal/header.php
```

## Purpose

The teacher Grade Sheet page already existed in:

```text
teacher/report/grade_sheet
teacher/reports/grade_sheet
```

The same view file was copied to the Principal reports folder. The principal controller needed a matching route/action so the copied view can load, search, and print from the Principal tab.

## Controller: Principal Report.php

### 1. Principal Grade Sheet Route

Added:

```php
function grade_sheet()
```

Purpose:

- Opens the Principal Grade Sheet page.
- Loads the copied view:

```php
$this->load->view('principal/reports/grade_sheet', $data);
```

- Uses all principal-accessible classes instead of teacher-assigned classes:

```php
$data['classlist'] = $this->class_model->get();
```

- Requires Grade, Section, and Subject:

```php
$this->form_validation->set_rules('class_id', 'Class', 'trim|required|xss_clean');
$this->form_validation->set_rules('section_id', 'Section', 'trim|required|xss_clean');
$this->form_validation->set_rules('subject_id', 'Subject', 'trim|required|xss_clean');
```

### 2. Grade Sheet Search Data

On search, the principal route loads:

```php
$subjectlist = $this->subject_model->getSubjctByClass($class, true);
$studentlist_male = $this->student_model->searchByClassSectionGender($class, $section, 'Male', $session_id);
$studentlist_female = $this->student_model->searchByClassSectionGender($class, $section, 'Female', $session_id);
```

Purpose:

- Shows the selected subject.
- Lists male and female students separately.
- Keeps the same data shape expected by the copied Grade Sheet view.

### 3. Print Action

Added:

```php
public function print_grade_sheet($class_id, $section_id, $subject_id, $semester_id=NULL, $session_id=NULL)
```

This wrapper calls the existing Grade Sheet PDF generator logic:

```php
return $this->print_failing_grades_summary($class_id, $section_id, $subject_id, $semester_id, $session_id);
```

Reason:

- `Report.php` already had a PDF generator that outputs `template/grade_sheet`.
- The existing function name is `print_failing_grades_summary(...)`, but the output file is a Grade Sheet PDF.
- The wrapper lets the Principal Grade Sheet page use the clearer `print_grade_sheet` action without duplicating the PDF code.

### 4. Subject AJAX Endpoint

Added:

```php
public function getSubjectsByClass()
```

Purpose:

- Lets the copied principal Grade Sheet view load subjects after selecting a Grade or Section.
- Replaces the teacher AJAX route.

Uses:

```php
$this->subject_model->getSubjctByClass($class_id, true);
```

### 5. Existing Principal AJAX Endpoints Used

The copied view now uses the existing principal endpoints:

```text
principal/report/getSectionsByClass
principal/report/allowStrand
```

## View: Principal grade_sheet.php

Local file:

```text
grade_sheet 2.php
```

Upload as:

```text
application/views/principal/reports/grade_sheet.php
```

### Form Action Updated

Changed from:

```php
site_url('teacher/report/grade_sheet')
```

to:

```php
site_url('principal/report/grade_sheet')
```

This was updated in both the search form and the print form.

### AJAX Routes Updated

Changed teacher routes:

```text
teacher/sections/getByClass
teacher/subject/getSubjctByClass
teacher/strand/allowStrand
```

to principal report routes:

```text
principal/report/getSectionsByClass
principal/report/getSubjectsByClass
principal/report/allowStrand
```

Purpose:

- Principal Grade Sheet no longer depends on teacher routes.
- Grade, Section, Subject, and Semester/Strand controls work from the principal controller context.

## Files to Upload

Upload these files:

```text
Report.php -> application/controllers/principal/Report.php
grade_sheet 2.php -> application/views/principal/reports/grade_sheet.php
header.php -> application/views/layout/principal/header.php
```

## Report Tab Menu Link

The controller route and view are now linked, but the visible Principal Report tab list is controlled by a separate layout/menu file, not by the report view files.

The current Principal Report tab list should include:

```text
Principal List
Academic List
Student Ranking
Honor Students
Master Sheet
Grade Sheet
Failing Grades Summary
Report Card
Parent Master Sheet
Student Incident Report
Conduct Master Sheet
```

Added `Grade Sheet` beside the other principal report links in:

```text
application/views/layout/principal/header.php
```

The link was placed between `Master Sheet` and `Failing Grades Summary`, using the same `<li>` pattern as the existing report links. The target route is:

```php
principal/report/grade_sheet
```

Added link:

```php
<li class="<?php echo set_Submenu('report/grade_sheet'); ?>"><a href="<?php echo base_url(); ?>principal/report/grade_sheet"><i class="fa fa-angle-double-right"></i>  Grade Sheet</a></li>
```

This matches the controller active submenu key:

```php
$this->session->set_userdata('sub_menu', 'report/grade_sheet');
```

Do not overwrite teacher files:

```text
Report.php
grade_sheet.php
```

## Verification Done

Syntax checks passed:

```text
php -l Report.php
php -l "grade_sheet 2.php"
php -l header.php
```
