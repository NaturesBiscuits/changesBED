# Three Term UI Change Documentation

## QA Items Covered

This documentation covers the 4-quarter to 3-term UI changes for:

- Imported Grades
- Update Grades
- Grade Requests
- Input Grade
- Related principal grade views

## Important Scope

This was implemented as a UI-level change.

Backend field names such as `quarter`, route parameters, database values, and existing model method names remain unchanged for compatibility.

The UI should show:

```text
First Term
Second Term
Third Term
```

The UI should not show:

```text
Fourth Quarter
Fourth Term
Fourth Q
```

## FileZilla / Project Path

```text
application/controllers/principal
application/views/principal/grade
```

## Files Involved

### `Grade.php`

Path:

```text
application/controllers/principal/Grade.php
```

Purpose:

- Added output filtering for Imported Grades and View Batch where the legacy views still had quarter wording.
- Removed or hid 4th quarter UI output.
- Converted visible quarter labels to term labels.

Key logic:

```php
First Quarter -> First Term
Second Quarter -> Second Term
Third Quarter -> Third Term
Fourth Quarter -> disabled/blank
Quarter: -> Term:
Quarterly Assessment -> Term Assessment
```

### `imported.php`

Path:

```text
application/views/principal/grade/imported.php
```

Changes:

- Checkbox labels changed from `First Q`, `Second Q`, `Third Q` to `First Term`, `Second Term`, `Third Term`.
- 4th quarter checkbox disabled/commented.
- Imported Grades subtabs changed to `First Term`, `Second Term`, `Third Term`.
- 4th quarter subtab disabled/commented.
- Table header changed from `Quarter` to `Term`.
- Table row values convert `1`, `2`, `3` into term labels and blank out `4`.

### `updategrade.php`

Path:

```text
application/views/principal/grade/updategrade.php
```

Changes:

- Dropdown label changed to `Term`.
- Dropdown options convert quarter labels to term labels.
- 4th quarter option skipped.
- Result table header changed to `Term`.
- Row values convert quarter numbers into term labels.

### `updategradestudent.php`

Path:

```text
application/views/principal/grade/updategradestudent.php
```

Changes:

- Dropdown label changed to `Term`.
- Dropdown options convert quarter labels to term labels.
- 4th quarter option skipped.
- Table header changed to `Term`.
- Row values convert quarter numbers into term labels.

### `graderequests.php`

Path:

```text
application/views/principal/grade/graderequests.php
```

Changes:

- Grade Request checkboxes changed to:

```text
First Term
Second Term
Third Term
```

- 4th quarter checkbox disabled/commented.
- Added spacing between checkbox and term text.
- Table header changed to `Term`.
- Row values convert `1`, `2`, and `3` into term labels.

### `approvedrequests.php`

Path:

```text
application/views/principal/grade/approvedrequests.php
```

Changes:

- Table header changed from `Quarter` to `Term`.
- Row values convert `1`, `2`, and `3` into term labels.
- Value `4` displays blank.

### `declinedrequests.php`

Path:

```text
application/views/principal/grade/declinedrequests.php
```

Changes:

- Table header changed from `Quarter` to `Term`.
- Row values convert `1`, `2`, and `3` into term labels.
- Value `4` displays blank.

### `inputGrade.php`

Path:

```text
application/views/principal/grade/inputGrade.php
```

Changes:

- Restored the missing `Term` selection field in the filter form.
- Term dropdown shows `First Term`, `Second Term`, `Third Term`.
- 4th quarter option is skipped.
- Table headers changed to term labels.
- 4th term table header and cells disabled/commented.
- Empty input fallbacks for first, second, and third term were restored.

Important restored visible controls:

- `inputGrade.php` form has `Term` dropdown beside `School Year`.
- `First Term`, `Second Term`, and `Third Term` grade input cells remain visible.
- 4th term is the only disabled term.

### `postgrade.php`

Path:

```text
application/views/principal/grade/postgrade.php
```

Changes:

- Dropdown label changed to `Term`.
- Dropdown options convert quarter labels to term labels.
- 4th quarter option skipped.
- Table header and row values changed to terms.

### `nogrades.php`

Path:

```text
application/views/principal/grade/nogrades.php
```

Changes:

- Dropdown label changed to `Term`.
- 4th quarter option skipped.
- Table header changed to `Term`.

### `viewgradebreakdown.php`

Path:

```text
application/views/principal/grade/viewgradebreakdown.php
```

Changes:

- `Quarter:` changed to `Term:`.
- `Quarterly Assessment:` changed to `Term Assessment:`.
- Displayed quarter label converted to term label.
- 4th quarter label blanked out.

## Verification

Commands used:

```powershell
php -l .\Grade.php
php -l .\imported.php
php -l .\inputGrade.php
php -l .\updategrade.php
php -l .\updategradestudent.php
php -l .\graderequests.php
php -l .\approvedrequests.php
php -l .\declinedrequests.php
php -l .\postgrade.php
php -l .\nogrades.php
php -l .\viewgradebreakdown.php
```

Expected result:

```text
No syntax errors detected
```

## Notes

Some backend code still uses the word `quarter`. That is intentional because the database, existing routes, and model methods still use `quarter` identifiers.

The user-facing UI should use `Term`.

## QA Records Covered

| QA Item | Status | Files |
|---|---|---|
| Imported Grades: 4 Quarters instead of 3 Terms | Covered | `Grade.php`, `imported.php` |
| Update Grades terms option: 4 Quarters instead of 3 Terms | Covered | `updategrade.php`, `updategradestudent.php` |
| Grade Request terms option: 4 Quarters instead of 3 Terms | Covered | `graderequests.php`, `approvedrequests.php`, `declinedrequests.php` |
| Input Grade terms column: 4 Quarters instead of 3 Terms | Covered | `Grade.php`, `inputGrade.php` |

## Code Change Records

### Imported Grades Source Markup

`imported.php` checkbox labels:

```php
<span style="font-size:14px;padding:10px;font-weight:bold;">&nbsp;<input type="checkbox" name="firstq" id="q1" class="quarter_class" <?php echo $firstqsettings=='yes'?'checked':'';?> >&nbsp; First Term</span>
<span style="font-size:14px;padding:10px;font-weight:bold;">&nbsp;<input type="checkbox" name="secondq" id="q2"  class="quarter_class"  <?php echo $secondqsettings=='yes'?'checked':'';?> >&nbsp; Second Term</span>
<span style="font-size:14px;padding:10px;font-weight:bold;">&nbsp;<input type="checkbox" name="thirdq" id="q3"  class="quarter_class"  <?php echo $thirdqsettings=='yes'?'checked':'';?> >&nbsp; Third Term</span>
```

4th checkbox remains disabled/commented:

```php
<!-- Fourth quarter checkbox disabled for 3-term UI. -->
```

`imported.php` subtabs:

```text
First Term
Second Term
Third Term
```

4th subtab remains disabled/commented:

```php
<!-- Fourth quarter tab disabled for 3-term UI. -->
```

### Term Dropdown Pattern

Used in `updategrade.php`, `updategradestudent.php`, `postgrade.php`, and `inputGrade.php`:

```php
if( $key == 4 || $value == 4 || stripos($value, 'Fourth') !== false || stripos($value, '4th') !== false ){
    // Fourth quarter option disabled for 3-term UI.
    continue;
}

$term_label = str_replace(array('First Quarter', 'Second Quarter', 'Third Quarter', '1st Quarter', '2nd Quarter', '3rd Quarter'), array('First Term', 'Second Term', 'Third Term', 'First Term', 'Second Term', 'Third Term'), $value);
```

### Row Display Pattern

Used where records still store numeric quarter values:

```php
<?php $term_label = $student['quarter']; if($term_label == 1){ $term_label = 'First Term'; } elseif($term_label == 2){ $term_label = 'Second Term'; } elseif($term_label == 3){ $term_label = 'Third Term'; } elseif($term_label == 4){ $term_label = ''; } echo $term_label; ?>
```

### Input Grade Term Select

`inputGrade.php` restored the missing term selection field:

```php
<label for="exampleInputEmail1">Term</label>

<select id="quarter" name="quarter" class="form-control">
    <option value=""><?php echo $this->lang->line('select'); ?></option>
    ...
</select>
```

`Grade.php` preserves the selected term:

```php
$data['quarter'] = '';
$quarter = $this->input->post('quarter');
$data['quarter'] = $quarter;
```

### Input Grade Visible Term Inputs

Visible input fallbacks were restored for:

```text
subj_{subject_id}_1
subj_{subject_id}_2
subj_{subject_id}_3
```

4th term rendering remains disabled:

```php
if( false && $check_fourth_exam ){
```

4th term empty fallback remains disabled:

```php
} elseif( false ) {
```

## Retest Checklist

### Imported Grades

Expected:

```text
First Term
Second Term
Third Term
Term
```

Should not show:

```text
Fourth Q
Fourth Quarter
Fourth Term
```

### Update Grades

Expected dropdown options:

```text
First Term
Second Term
Third Term
```

Expected table header:

```text
Term
```

### Grade Requests

Expected checkboxes:

```text
First Term
Second Term
Third Term
```

Expected table header:

```text
Term
```

### Input Grade

Expected:

- `Term` dropdown is visible beside `School Year`.
- First/Second/Third Term columns are visible.
- First/Second/Third Term empty grade input cells are visible.
- 4th term column is hidden.

## Upload / Apply List

```text
application/controllers/principal/Grade.php
application/views/principal/grade/imported.php
application/views/principal/grade/inputGrade.php
application/views/principal/grade/updategrade.php
application/views/principal/grade/updategradestudent.php
application/views/principal/grade/postgrade.php
application/views/principal/grade/nogrades.php
application/views/principal/grade/viewgradebreakdown.php
application/views/principal/grade/graderequests.php
application/views/principal/grade/approvedrequests.php
application/views/principal/grade/declinedrequests.php
```

## Extra Screens To Review If Scope Expands

These were outside the six reported QA items but may still contain visible `Quarter` wording:

```text
character.php
import.php
teacher_report.php
teacherswhoimport.php
viewbatch_old.php
```
