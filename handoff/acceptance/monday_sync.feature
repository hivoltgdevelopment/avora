Feature: Monday.com Integration (read-only)
# scopes: boards:read, items:read, users:read

Scenario: Fetch boards and items
  Given User connects Monday.com
  When Fetching boards and items
  Then Projects and tasks are normalized
  And Urgency scores computed
  And Redline shown for due<48h

