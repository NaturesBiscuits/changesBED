# Grade Request AJAX Refresh Documentation

## Requested Change

On the Principal Grade Request pages, user actions should not reload the whole browser page.

Affected pages:

- `principal/request/grade_requests_new`
- `principal/request/approved_requests`
- `principal/request/declined_requests_new`

## Files Involved

Pending request view:

```text
application/views/principal/grade/graderequests.php
```

Approved request view:

```text
application/views/principal/grade/approvedrequests.php
```

Declined request view:

```text
application/views/principal/grade/declinedrequests.php
```

## Changes Applied

Each request view received a wrapper:

```html
<div id="grade-request-ajax-container">
```

The JavaScript intercepts only elements inside that wrapper.

## AJAX Behavior

The script handles:

- Tab switches between Pending, Approved, and Declined.
- Single-row Approve.
- Single-row Decline.
- Bulk Approve All.
- Bulk Decline All.
- School year/session form changes.
- Enable/Disable Update Grades.
- Feedback modal form submissions.

## How Refresh Works

1. User clicks an action or submits a form.
2. AJAX sends the same URL/form request.
3. Existing controller redirect still runs.
4. Returned HTML is parsed.
5. Only `#grade-request-ajax-container` is replaced.
6. Header/sidebar/full browser page are not reloaded.

## Fallback

If JavaScript fails, the original links and forms still perform normal full-page requests.

## Result

- User actions refresh only the request panel.
- Badge counts and table rows update after actions.
- Browser does not do a full-page reload for Grade Request tab actions.

## Verification

Command used:

```powershell
php -l .\graderequests.php
php -l .\approvedrequests.php
php -l .\declinedrequests.php
```

Expected result:

```text
No syntax errors detected
```

## Code Change Record

Wrapper added to each request view:

```html
<div id="grade-request-ajax-container">
```

Delegated tab click handler:

```javascript
$(document)
    .off('click.gradeRequestAjaxTab', containerSelector + ' .nav-tabs a')
    .on('click.gradeRequestAjaxTab', containerSelector + ' .nav-tabs a', function (event) {
        event.preventDefault();
        loadGradeRequestPanel(this.href, true);
    });
```

Delegated action click handler:

```javascript
$(document)
    .off('click.gradeRequestAjaxAction', containerSelector + ' a.grade-request-action')
    .on('click.gradeRequestAjaxAction', containerSelector + ' a.grade-request-action', function (event) {
        var confirmMessage = $(this).data('confirm');
        var actionUrl = this.href;

        event.preventDefault();

        if (confirmMessage && !confirm(confirmMessage)) {
            return;
        }

        $.ajax({
            url: actionUrl,
            type: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            success: function (response) {
                replaceGradeRequestPanel(response, '');
            },
            error: function () {
                window.location.href = actionUrl;
            }
        });
    });
```

Delegated form submit handler:

```javascript
$(document)
    .off('submit.gradeRequestAjaxForm', containerSelector + ' form')
    .on('submit.gradeRequestAjaxForm', containerSelector + ' form', function (event) {
        event.preventDefault();
        ...
    });
```

## Retest Record

Path:

```text
Principal > Grades > Grade Requests
```

Retest:

1. Switch from Pending to Approved.
2. Switch from Approved to Declined.
3. Return to Pending.
4. Approve a request.
5. Decline a request.
6. Use Approve All or Decline All.

Expected:

- Only the request panel refreshes.
- The full page layout does not reload.
- Badge counts update.
- Rows move to the correct tab.
- Normal full-page behavior still works if JavaScript fails.
