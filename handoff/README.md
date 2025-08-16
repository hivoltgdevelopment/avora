# Avora Handoff Pack

This folder contains everything Codex needs to scaffold and ship the Avora MVP.

## Contents
- **PRD.avora.json** — machine-readable product requirements.
- **/acceptance/** — per-feature acceptance criteria and test cases.
- **/openapi/openapi.v1.yaml** — API endpoints contract.
- **/seed/** — tiny fixtures (projects, tasks, calendar) for local runs.
- **/env/.env.example** — environment variable template.

## How to use
1. Create a new GitHub repo and copy this `handoff` contents into the root (or `/handoff`).
2. Follow the *Avora — Zero‑to‑Deploy Playbook* (in your canvas) for monorepo scaffolding.
3. Wire env secrets from `.env.example` into CI and hosting.
4. Generate Stripe price IDs and Coinbase keys, paste into env.
5. Start by implementing routes from the OpenAPI file, then acceptance tests.

## Build targets (non-negotiable)
- Lighthouse: Performance ≥ 0.95, Accessibility ≥ 0.98, Best Practices = 1.0, SEO = 1.0
- Security: OAuth2, encrypted refresh tokens, CSP, headers, webhooks verified & idempotent
- UX: WCAG 2.2 AA, keyboard-first, reduced motion, Top‑3 rule
- Perf: Minified JS/CSS/HTML, code-splitting, PWA caching

Generated: 2025-08-16T20:17:48.472865Z
