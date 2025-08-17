Feature: Checkout (Stripe + Coinbase Commerce)

Scenario: Card payment for Pro plan
  Given User selects Pro plan and card payment
  When Checkout is initiated
  Then Stripe Checkout session URL returned
  And Redirect occurs
  And Webhook marks subscription active
  And Entitlements applied

Scenario: Crypto payment for Business plan
  Given User selects Business plan and crypto
  When Checkout is initiated
  Then Coinbase charge created
  And Confirmation webhook updates subscription
  And Receipt reference stored

