Feature: Entitlement Gating

Scenario: Active subscription allows access
  Given Subscription is active with 'flight-plan' entitlement
  When User opens Flight Plan
  Then Feature accessible

Scenario: Past due subscription shows gate
  Given Subscription past_due after grace period
  When User opens Flight Plan
  Then Gate UI shown with upgrade/retry options

