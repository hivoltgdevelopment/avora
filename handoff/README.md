# Avora Handoff

This package contains PRD, acceptance criteria, and API stubs.

## Acceptance Criteria

Each acceptance file uses the following structure:

```
{
  "feature": "Feature name",
  "scenarios": [
    {
      "name": "Scenario label",
      "given": "precondition",
      "when": "action",
      "then": ["expected outcome"]
    }
  ],
  "done": ["definition of done items"]
}
```

A matching `.feature` file is provided for BDD tooling.

