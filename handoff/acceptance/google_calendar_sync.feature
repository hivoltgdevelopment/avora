Feature: Google Calendar Integration (read-only)
# scopes: openid, email, profile, https://www.googleapis.com/auth/calendar.readonly

Scenario: Connect and fetch today's events
  Given User connects Google Calendar
  When Fetching today's events
  Then Fuel gauge reflects free vs busy hours
  And Next event countdown visible
  And No PII leaked to logs

