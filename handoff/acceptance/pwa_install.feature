Feature: PWA Install & Offline

Scenario: Chrome desktop install prompt
  Given User on Chrome desktop
  When PWA criteria met
  Then Install prompt available (deferred)
  And Offline cache for shell available

Scenario: Offline mode shows cached data
  Given Network offline
  When User opens app
  Then Last-synced data visible
  And Clear offline state message

