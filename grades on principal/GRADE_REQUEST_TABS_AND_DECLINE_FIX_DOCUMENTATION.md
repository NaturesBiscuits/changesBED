# Grade Request Tabs and Decline Route Fix Documentation

## QA / Bug Items Covered

- Request tab badge counts did not stay synchronized.
- Approved count could be off by one.
- Pending count could be off by one.
- Declining a request produced a 404.
- Approved requests were not always loaded using the principal workflow filter.

## Files Involved

Controller:

```text
application/controllers/principal/Request.php
```

Pending view:

```text
application/views/principal/grade/graderequests.php
```

Approved view:

```text
application/views/principal/grade/approvedrequests.php
```

Declined view:

```text
application/views/principal/grade/declinedrequests.php
```

## Approved Tab Count Fix

The Approved tab was using older or inconsistent count queries.

Fix:

```php
$approved_grades = $this->importgraderequest_model->getrequest( 'approved', 'principal', $principal_id, $session_id );
$data['count_approved'] = count($approved_grades);
```

This makes the Approved tab count use the same principal/session-filtered record source as the actual Approved records table.

## Pending Count Fix

The Pending badge on Approved and Declined tabs was using a different count method than the Pending page.

Fix:

```php
$data['count_pending'] = count( $this->importgraderequest_model->getrequest( 'pending', 'principal', $principal_id, $session_id ) );
```

This aligns Pending count on:

- `grade_requests_new`
- `approved_requests`
- `declined_requests_new`

## Decline Route Fix

The active `declinedrequest($id)` method was missing because an older version was inside a commented block.

Fix:

```php
public function declinedrequest( $id ){
    if( $id ){
        $student_session_data = $this->session->userdata("student");
        $principal_id = $student_session_data['principal_id'];
        $current_datetime = $this->setting_model->getDatetime();
        $update_array = array(
            'astatus' => 'declined',
            'principal_id' => $principal_id,
            'date_adeclined' => $current_datetime,
            'id' => $id
        );
        $this->importgraderequest_model->add( $update_array );
        $this->session->set_flashdata('msg', '<div class="alert alert-success">Declined data successfully</div>');
    }
    $referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : '';
    redirect( $referer );
}
```

## Pending Form Action Fix

The Grade Request page form action was corrected from the academic head path to the principal path.

Changed:

```text
academichead/request/grade_requests_new
```

To:

```text
principal/request/grade_requests_new
```

## Result

- Approving a pending request moves it to Approved.
- Declining a pending request moves it to Declined.
- Decline no longer gives a 404.
- Pending / Approved / Declined badge counts use consistent principal/session filters.
- Approved and Declined tabs display the correct records.

## Verification

Command used:

```powershell
php -l .\Request.php
php -l .\graderequests.php
php -l .\approvedrequests.php
php -l .\declinedrequests.php
```

Expected result:

```text
No syntax errors detected
```

## Code Change Record

Pending count source:

```php
$data['count_pending'] = count( $this->importgraderequest_model->getrequest( 'pending', 'principal', $principal_id, $session_id ) );
```

Approved count and record source:

```php
$approved_grades = $this->importgraderequest_model->getrequest( 'approved', 'principal', $principal_id, $session_id );
$data['approved_grades'] = $approved_grades;
$data['count_approved'] = count($approved_grades);
```

Decline save data:

```php
$update_array = array(
    'astatus' => 'declined',
    'principal_id' => $principal_id,
    'date_adeclined' => $current_datetime,
    'id' => $id
);
```

## Database / Status Expectation

Approve:

```text
astatus = approved
principal_id = current principal id
date_aapproved = current datetime
```

Decline:

```text
astatus = declined
principal_id = current principal id
date_adeclined = current datetime
```

## Retest Record

Path:

```text
Principal > Grades > Grade Requests
```

Retest:

1. Compare Pending count across Pending, Approved, and Declined tabs.
2. Compare Approved count across Pending, Approved, and Declined tabs.
3. Approve a pending request and verify it appears in Approved.
4. Decline a pending request and verify it appears in Declined.
5. Verify decline no longer opens a 404 page.
6. Change school year/session and confirm counts stay synchronized.
