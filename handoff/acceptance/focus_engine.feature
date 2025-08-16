Feature: Focus Engine

Scenario: Top tasks highlighted
  Given Tasks have varying priority
  When User views Focus Engine
  Then User can see Top 3 tasks

