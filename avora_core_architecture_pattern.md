# Avora — Zero‑to‑Deploy Playbook (Everything Needed To Build Now)

> This replaces the prior architecture doc with a **concrete build plan**. It keeps all the standards (ethics, security, UX, performance, monetization), but focuses on what’s left to do and exactly how to do it. Follow this end‑to‑end to ship Avora.

---

## 0) Quick Answer: What’s left?

1. Create accounts & keys · 2) Bootstrap the monorepo · 3) Wire OAuth (Google, Monday) · 4) Add billing (Stripe + Coinbase Commerce) · 5) Add CI/CD (build, tests, Lighthouse) · 6) Stand up API service (Vercel/Netlify) · 7) Ship PWA to GitHub Pages · 8) Publish docs · 9) Turn on observability & status page · 10) Run the production checklist.

This document gives you scripts, file templates, env variables, headers/CSP, and workflow YAML to do all of that.

---

## 1) Prerequisites (create once)

- **GitHub** repo: `hivoltg/avora` (public or private)
- **Vercel** *or* **Netlify** account for `services/avora-api`
- **Google Cloud** project: OAuth consent screen + OAuth client (Web app)
- **Monday.com** Developer: OAuth app (OAuth 2.0)
- **Stripe** account: live + test keys, Customer Portal enabled, Stripe Tax optional
- **Coinbase Commerce** account: API keys + webhook secret
- **Sentry** (frontend & backend projects)
- **Supabase** project: Postgres + Auth (for configs/flags)
- **Firebase** (optional) for WebPush (or Web Push VAPID keys)
- **PostHog** (or Supabase Analytics) for telemetry

> Keep provider ownership under **Hivoltg Technology Services, LLC**.

---

## 2) Bootstrap the Monorepo (pnpm + Turborepo)

```bash
mkdir avora && cd avora
pnpm init -y
pnpm add -D typescript ts-node @types/node vite turbo pnpm rimraf eslint prettier
pnpm add -D eslint-config-prettier eslint-plugin-import eslint-plugin-react eslint-plugin-react-hooks

# workspace layout
mkdir -p apps/avora-web services/avora-api packages/{ui,theme,core,integrations,notifications,analytics,billing,i18n,utils,types} docs compliance infra .github/workflows

# workspace files
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'apps/*'
  - 'services/*'
  - 'packages/*'
  - 'docs'
  - 'infra'
EOF

cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**", "build/**"] },
    "lint": {},
    "test": { "dependsOn": ["^build"] }
  }
}
EOF
```

---

## 3) App Shell (Vite + PWA)

```bash
# inside apps/avora-web
pnpm create vite@latest . -- --template react-ts
pnpm add react-router-dom
pnpm add -D tailwindcss postcss autoprefixer workbox-window
npx tailwindcss init -p
```

**Tailwind config**

```js
// apps/avora-web/tailwind.config.js
export default { content: ["./index.html", "./src/**/*.{ts,tsx}"], theme: { extend: {} }, plugins: [] }
```

**PWA manifest**

```json
// apps/avora-web/public/manifest.webmanifest
{ "name":"Avora","short_name":"Avora","start_url":"/","display":"standalone","background_color":"#0D1B2A","theme_color":"#0D1B2A","icons":[{"src":"/icon-192.png","sizes":"192x192","type":"image/png"},{"src":"/icon-512.png","sizes":"512x512","type":"image/png"}]}
```

**Service worker registration** (deferred, no prompt storms)

```ts
// apps/avora-web/src/sw.ts (generated later with Workbox) // placeholder
```

---

## 4) API Service (Node/Express)

```bash
# inside services/avora-api
pnpm add express cors helmet zod jose axios stripe @coinbase/commerce-node
pnpm add -D ts-node-dev typescript @types/express @types/cors
```

**Server skeleton**

```ts
// services/avora-api/src/index.ts
import 'dotenv/config'
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
const app = express()
app.use(helmet())
app.use(cors({ origin: process.env.CORS_ORIGIN?.split(',')||[], credentials:true }))
app.use(express.json({ limit: '1mb' }))
app.get('/healthz', (_,res)=>res.json({ ok:true }))
// TODO: add routes from Section 8 & 10
app.listen(process.env.PORT||3000, ()=>console.log('avora-api up'))
```

---

## 5) Environment Variables (single source)

Create `` at repo root and mirror per environment.

```
# General
NODE_ENV=
CORS_ORIGIN=https://hivoltg.github.io,https://localhost:5173

# Google OAuth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=https://YOUR_API_HOST/api/auth/google/callback

# Monday OAuth
MONDAY_CLIENT_ID=
MONDAY_CLIENT_SECRET=
MONDAY_REDIRECT_URI=https://YOUR_API_HOST/api/auth/monday/callback

# Stripe
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_PRO=
STRIPE_PRICE_BUSINESS=

# Coinbase Commerce
COINBASE_API_KEY=
COINBASE_WEBHOOK_SECRET=

# Sentry
SENTRY_DSN_FRONTEND=
SENTRY_DSN_BACKEND=

# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Web Push (VAPID)
VAPID_PUBLIC_KEY=
VAPID_PRIVATE_KEY=
```

> Do **not** commit real `.env` values. Commit only `.env.example`.

---

## 6) OAuth Scopes & Redirect URIs

- **Google Calendar**: scopes → `openid email profile https://www.googleapis.com/auth/calendar.readonly`
  - Redirect: `https://YOUR_API_HOST/api/auth/google/callback`
- **Monday.com**: scopes → `boards:read items:read users:read` (start read‑only)
  - Redirect: `https://YOUR_API_HOST/api/auth/monday/callback`

Document these in `/docs/integrations.md`.

---

## 7) Integrations Adapters (normalize data)

Create minimal adapters that return Avora types.

```ts
// packages/integrations/google-calendar/src/index.ts
export async function listTodayEvents(token:string){ /* fetch, map → CalendarBlock[] */ }
export async function freeBusy(token:string){ /* map → CalendarBlock[] */ }

// packages/integrations/monday/src/index.ts
export async function listProjects(token:string){ /* map → Project[] */ }
export async function listTasks(token:string){ /* map → Task[] */ }
```

---

## 8) API Routes (contract)

```ts
// services/avora-api/src/routes.ts (sketch)
app.get('/api/calendar/today', /* uses google adapter */)
app.get('/api/monday/tasks', /* uses monday adapter */)
app.post('/api/plan/generate', /* calls core.buildDailyPlan */)
app.post('/api/notify/shift', /* schedules push */)
```

Auth uses provider tokens stored **server‑side** (encrypted at rest) or short‑lived in session; frontend never sees provider secrets.

---

## 9) Core Logic (prioritization)

```ts
// packages/core/src/priority.ts
export function scoreUrgency(/* due diff */){ /* 0..1 scale */ }
export function scoreImportance(/* project weight */){ /* 0..1 */ }
export function priorityIndex(/* 0..1 weighted */){ /* 0..1 */ }
export function buildDailyPlan(/* tasks, projects, blocks */){ /* returns DailyPlan */ }
```

Unit tests cover edge cases (no focus time, stacked deadlines, long tasks).

---

## 10) Billing (Stripe + Coinbase Commerce)

**Server endpoints**

```ts
// services/avora-api/src/billing.ts
app.post('/api/billing/checkout', /* create Stripe session or Coinbase charge */)
app.post('/api/billing/portal', /* create Stripe portal session */)
app.post('/api/webhooks/stripe', /* verify sig, handle events */)
app.post('/api/webhooks/coinbase', /* verify sig, handle events */)
```

**UI components** (pure props)

```tsx
// packages/ui: <PlanPicker />, <CheckoutButton provider="stripe|coinbase" />, <EntitlementGate feature="flight-plan" />
```

**Required docs**: `/docs/pricing.md`, `/docs/refunds.md`, `/docs/crypto-policy.md`.

---

## 11) Security Headers & CSP

**Netlify **`` or **Vercel config** to set:

```
/*
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer
  Permissions-Policy: geolocation=(), microphone=(), camera=()
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
  Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' https://js.stripe.com https://commerce.coinbase.com; connect-src 'self' https://api.stripe.com https://api.commerce.coinbase.com https://api.monday.com https://www.googleapis.com; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; frame-src https://js.stripe.com https://commerce.coinbase.com
```

Adjust for hosting constraints; keep least‑privilege.

---

## 12) CI/CD (GitHub Actions)

**Build, Test, Lint, Lighthouse, Deploy**

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: 9 }
      - run: pnpm i --frozen-lockfile
      - run: pnpm -w run lint && pnpm -w run build && pnpm -w run test
  lighthouse:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npx @lhci/cli autorun --config=./infra/lighthouserc.json
```

**Pages deploy (frontend)**

```yaml
# .github/workflows/deploy-pages.yml
name: Deploy Pages
on:
  push:
    branches: [ main ]
    paths: [ 'apps/avora-web/**' ]
permissions: { pages: write, id-token: write }
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
        with: { version: 9 }
      - run: pnpm i --frozen-lockfile
      - run: pnpm --filter avora-web run build
      - uses: actions/upload-pages-artifact@v3
        with: { path: apps/avora-web/dist }
      - uses: actions/deploy-pages@v4
```

**API deploy**: use Vercel/Netlify Git integration or `vercel --prod`/`ntl deploy`.

---

## 13) Lighthouse CI Config

```json
// infra/lighthouserc.json
{ "ci": { "collect": { "staticDistDir": "apps/avora-web/dist" }, "assert": { "assertions": { "categories:performance": ["error", {"minScore": 0.95}], "categories:accessibility": ["error", {"minScore": 0.98}], "categories:best-practices": ["error", {"minScore": 1}], "categories:seo": ["error", {"minScore": 1}] } } } }
```

---

## 14) Observability

- **Sentry** DSNs in env. Initialize in `apps/avora-web/src/main.tsx` and `services/avora-api/src/index.ts`.
- **Metrics**: expose `/metrics` (Prom‑style) or vendor SDK; dashboard p95 latency, error rate, notification success.
- **Status Page**: publish from `/docs/status/`.

---

## 15) Documentation Site

```bash
# at repo root
pnpm add -D docusaurus @docusaurus/init
npx create-docusaurus@latest docs classic --typescript
```

Required pages (fill stubs now):

- `docs/prd.md`, `docs/whitepaper.md`, `docs/privacy.md`, `docs/security.md`, `docs/data-retention.md`, `docs/terms.md`, `docs/accessibility.md`, `docs/pricing.md`, `docs/refunds.md`, `docs/crypto-policy.md`, `docs/integrations.md`, `docs/status/README.md`.

Publish to GitHub Pages (Docs → Settings → Pages → `gh-pages`).

---

## 16) Internationalization (i18n)

- `packages/i18n`: ICU message catalogs, RTL helpers, number/date formatting.
- Default locale: `en-US`; add `es-US` next.

---

## 17) Testing

- **Unit**: `packages/core`, adapters
- **Integration**: API endpoints + webhooks (Stripe/Coinbase)
- **E2E**: Playwright covering: sign‑in → connect Google+Monday → generate plan → checkout Stripe → entitlement gate passes.
- **Accessibility**: axe‑core in CI + manual screen reader pass.

---

## 18) Data Retention & Residency

- Telemetry: 12 months (aggregated after 90 days)
- Webhook payloads: 30 days
- User data: while subscription active or 30 days post‑deletion request
- Residency: US‑East primary; document options per customer in `/docs/data-residency.md`.

---

## 19) Production Readiness Checklist (run before launch)

-

---

## 20) Legal/Ethics (ship‑blockers)

- **Explicit consent** toggles for Google/Monday; default off
- **Privacy policy** and **data use** plain‑English summaries
- **Crypto refunds** policy disclosed; tax language accurate (Stripe Tax when available)
- **Accessibility statement** and contact path

---

## 21) What you get after this playbook

- **Deployed API** (Vercel/Netlify)
- **Deployed PWA** (GitHub Pages)
- **Docs site** (GitHub Pages, `gh-pages`)
- **Working integrations** (Google Calendar, Monday)
- **Monetization live** (Stripe + Coinbase Commerce)
- **Observability & status** online

No further blockers. Build, test, and ship.

