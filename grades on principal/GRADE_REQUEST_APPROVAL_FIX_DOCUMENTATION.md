# Grade Request Approval Fix Documentation

## QA Item

Approve button on selected Request Grade updates request to Approved.

## Issue

When the principal approved a pending grade request, the page displayed a raw PHP array instead of saving the approval result.

Observed output:

```text
Array
(
    [astatus] => approved
    [principal_id] => 1
    [date_aapproved] => 2026-07-07 11:11:56
    [id] => 3217
)
```

After reload, the request status remained unchanged.

## Expected Result

- Request grade is updated to `Approved`.
- Imported Grades / Student Records are updated.
- No raw PHP array is displayed.

## Files Involved

Path:

```text
application/controllers/principal/Request.php
```

## Root Cause

Inside the active `approve_request($id)` method, a debug output call was left before the request status update was saved.

The debug call interrupted the normal flow, so the approval array was printed and the save operation did not complete.

## Change Applied

The debug output was removed/commented so the method could continue to:

```php
$this->importgraderequest_model->add( $update_array1 );
```

The saved approval data includes:

```php
astatus => approved
principal_id => current principal id
date_aapproved => current datetime
id => request id
```

## Result

Approving a request now:

- Does not print the approval array.
- Saves `astatus = approved`.
- Allows the request to leave Pending.
- Allows updated grades to be applied to Imported Grades / Student Records.

## Verification

Command used:

```powershell
php -l .\Request.php
```

Expected result:

```text
No syntax errors detected
```

Debug-output scan:

```powershell
Select-String -Path .\Request.php -Pattern "printx|print_r|var_dump"
```

Expected result:

```text
No active debug output inside approve_request()
```

## Code Change Record

Approval save array used by `Request.php::approve_request($id)`:

```php
$update_array1 = array(
    'astatus' => 'approved',
    'principal_id' => $principal_id,
    'date_aapproved' => $current_datetime,
    'id' => $id,
);

$this->importgraderequest_model->add( $update_array1 );
```

## Database / Status Expectation

After successful approval:

```text
astatus = approved
principal_id = current principal id
date_aapproved = current datetime
id = request id
```

The existing grade update flow continues through:

```php
examresult_model->add(...)
importgraderequest_model->add(...)
importgradesdetails_model->add(...)
```

## Retest Record

Path:

```text
Principal > Grades > Grade Requests > Pending Request
```

Steps:

1. Click `Approve` on a pending request.
2. Confirm the action.
3. Verify no PHP array appears.
4. Verify the request leaves Pending.
5. Verify the request appears under Approved.
6. Verify the related imported/student grade record is updated.

Should not show:

```text
Array
(
    [astatus] => approved
    ...
)
```
