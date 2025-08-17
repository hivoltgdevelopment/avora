Feature: Lighthouse Targets
# targets: performance 0.95, accessibility 0.98, bestPractices 1.0, seo 1.0

Scenario: CI enforces Lighthouse thresholds
  Given Production build
  When LHCI runs in CI
  Then Build fails if thresholds unmet
  And Reports stored under /compliance/lighthouse/

