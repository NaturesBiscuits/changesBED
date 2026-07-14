# View Batch Approve Button Change Documentation

## QA Item

Imported Grades approve button has the wrong tense.

## Issue

On Principal > Grades > Imported Grades > View Batch, pending submitted grades showed the green action button as `Approved`.

Expected visible text:

```text
Approve
```

Bulk action expected text:

```text
Approve All
```

## Files Involved

FileZilla / project path:

```text
application/controllers/principal
application/views/principal/grade
```

Controller:

```text
application/controllers/principal/Grade.php
```

View:

```text
application/views/principal/grade/viewbatch.php
```

## Changes Applied

### Controller Render Safety

`Grade.php::view_batch()` was updated to render `principal/grade/viewbatch` into a string and normalize the button labels before output.

Changed logic:

```php
$viewbatch = preg_replace('/(<(?:a|button)\b(?=[^>]*\bclass\s*=\s*["\'][^"\']*\bbtn\b)[^>]*>)\s*Approved All\s*(<\/(?:a|button)>)/i', '$1Approve All$2', $viewbatch);
$viewbatch = preg_replace('/(<(?:a|button)\b(?=[^>]*\bclass\s*=\s*["\'][^"\']*\bbtn\b)[^>]*>)\s*Approved\s*(<\/(?:a|button)>)/i', '$1Approve$2', $viewbatch);
```

### Direct View Cleanup

`viewbatch.php` was also changed directly so the source view no longer depends only on controller output replacement.

Changed direct visible labels:

- `Approved All` / language-line output changed to `Approve All`.
- Pending row action button text changed from `Approved` to `Approve`.
- Pending row action tooltip changed from `Approved` to `Approve`.
- `Quarter:` label changed to `Term:`.

## Result

Pending submitted grades now show:

```text
Approve
```

Bulk approve now shows:

```text
Approve All
```

## Verification

Command used:

```powershell
php -l .\Grade.php
php -l .\viewbatch.php
```

Expected result:

```text
No syntax errors detected
```

## Retest Record

Path:

```text
Principal > Grades > Imported Grades > Pending batch > View
```

Steps:

1. Open an imported grade batch with pending rows.
2. Check the green row action button.
3. Check the green bulk action button.

Expected:

```text
Approve
Approve All
```

Should not show on pending action buttons:

```text
Approved
Approved All
```

Note:

`Approved` is still valid as a status label for rows that are already approved. The tense fix only applies to action buttons.

## Code Change Record

Controller output normalization in `Grade.php`:

```php
$viewbatch = preg_replace('/(<(?:a|button)\b(?=[^>]*\bclass\s*=\s*["\'][^"\']*\bbtn\b)[^>]*>)\s*Approved All\s*(<\/(?:a|button)>)/i', '$1Approve All$2', $viewbatch);
$viewbatch = preg_replace('/(<(?:a|button)\b(?=[^>]*\bclass\s*=\s*["\'][^"\']*\bbtn\b)[^>]*>)\s*Approved\s*(<\/(?:a|button)>)/i', '$1Approve$2', $viewbatch);
```

Direct view label used in `viewbatch.php`:

```php
Approve
Approve All
title="Approve"
title="Approve All"
```
