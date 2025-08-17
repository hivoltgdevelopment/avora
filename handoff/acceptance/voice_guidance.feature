Feature: AI Voice & Audio

Scenario: Daily recap via TTS
  Given User enables voice guidance
  When Daily recap is requested
  Then TTS reads Top 3 and next meeting
  And Fallback to text if TTS unavailable

Scenario: Voice query surfaces focus task
  Given User says 'What should I do now?'
  When STT captures intent
  Then Assistant surfaces current focus task
  And Optional start/stop focus timer

