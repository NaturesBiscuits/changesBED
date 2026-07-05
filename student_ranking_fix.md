# Student Ranking Fix Documentation

This documents the Student Ranking fixes made for the Principal report files.

## Files Involved

Local files:

```text
Report 2.php
student_ranking.php
```

Upload targets:

```text
Report 2.php
-> application/controllers/principal/Report.php

student_ranking.php
-> application/views/principal/reports/student_ranking.php
```

## Original Error

The page showed PHP warnings similar to:

```text
Severity: Warning / Notice
Message: Illegal string offset ...
```

The issue happened inside the Student Ranking view when the code expected every item in `$studentlist` to be a student array.

However, ranking data can contain non-student entries or metadata-like values mixed into the result array. When the view tried to read values like:

```php
$student_value["id"]
$student_value["background_color"]
$student_value["name"]
```

from a non-array value, PHP reported an illegal string offset / undefined offset warning.

## Controller Code Area

File:

```text
Report 2.php
```

Code area:

```text
function student_ranking()
around lines 574-618
```

Important flow:

```php
$studentlist = $this->student_model->searchByClassSection($class, $section);
$studentranking = $this->grade_model->getStudentAverage( $studentlist, $quarter, $semester, $combine_category );
$getgraderanking = $this->grade_model->getgraderanking( $studentranking );
$data['studentlist'] = $getgraderanking;
```

What this does:

- Gets students by selected Grade/Section.
- Computes student averages using `grade_model->getStudentAverage(...)`.
- Ranks the students using `grade_model->getgraderanking(...)`.
- Sends the ranking result to the view as `$studentlist`.

The controller flow was kept, but the view was made safer because the ranking result can contain unexpected/non-student entries.

## View Code Area

File:

```text
student_ranking.php
```

Code area:

```text
student_ranking.php around lines 145-166
```

### Main Guard Added

Before reading student fields, the view now checks if the row is really a student array:

```php
if (!is_array($student_value) || empty($student_value["id"])) {
    continue;
}
```

Purpose:

- Skips invalid ranking rows.
- Prevents illegal string offset warnings.
- Ensures the table only renders actual student records.

### Field Access Made Safer

The view now uses guarded field reads like:

```php
$student_final_grade_value = isset($student_value['final_grade']) ? $student_value['final_grade'] : '';
$background_color = isset($student_value["background_color"]) ? $student_value["background_color"] : '';
$text_color = isset($student_value["text_color"]) ? $student_value["text_color"] : '';
$name = isset($student_value["name"]) ? $student_value["name"] : '';
$strand_id = isset($student_value['strand_id']) ? $student_value['strand_id'] : '';
$class = isset($student_value['class']) ? $student_value['class'] : '';
$section = isset($student_value['section']) ? $student_value['section'] : '';
```

Purpose:

- Prevents undefined index notices.
- Keeps the table rendering even if some student fields are missing.

### Final Grade Formatting

The final grade is now checked before formatting:

```php
$student_final_grade = is_numeric($student_final_grade_value)
    ? number_format((float) $student_final_grade_value, 2, '.', ',')
    : '';
```

Purpose:

- Avoids formatting invalid/null values.
- Keeps blank grade fields blank instead of throwing warnings.

## Term / Quarter Selection

File:

```text
student_ranking.php
```

Code area:

```text
around lines 75-90
```

Term 4 is skipped from the dropdown:

```php
if ($key == 4) {
    continue;
}
```

The dropdown label was changed to:

```text
Term
```

Purpose:

- Principal Student Ranking uses Term wording instead of Quarter.
- Only Term 1, Term 2, Term 3, and Final Grade are selectable.

## Semester-Based Term Filtering

File:

```text
student_ranking.php
```

Code area:

```text
around lines 519-525
```

The JavaScript filters term choices based on selected semester:

```javascript
quarterSelect.find('option[value="3"], option[value="4"]').remove();
quarterSelect.find('option[value="1"], option[value="2"]').remove();
```

Purpose:

- For semester-based grades, only the relevant terms are shown.
- Prevents selecting terms that do not belong to the selected semester.

## Result

After the fix:

- The Student Ranking page no longer crashes/warns when ranking data contains non-student entries.
- Missing optional fields no longer produce PHP notices.
- Final grades are safely formatted only when numeric.
- Term 4 is hidden from the main term dropdown.
- The page continues to display valid student ranking rows normally.

## Notes

- The teacher files were not changed for this fix.
- The main fix was defensive rendering in the principal Student Ranking view.
- The controller still uses the existing ranking flow:

```php
getStudentAverage(...)
getgraderanking(...)
```

