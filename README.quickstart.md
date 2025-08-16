# Avora Quickstart

_Last updated: 2025-08-16T21:14:45.095393Z_

This guide gets you from zero → running Avora locally (Web + API) on macOS, Windows/WSL, and Linux.

---

## 1) Prerequisites

- **VS Code** with extensions:
  - ESLint (`dbaeumer.vscode-eslint`)
  - Prettier (`esbenp.prettier-vscode`)
  - Tailwind CSS (`bradlc.vscode-tailwindcss`)
  - Playwright (`ms-playwright.playwright`) – optional for E2E
- **Node.js 20 LTS** (we lock to 20 via `.nvmrc` / `.tool-versions`)
- **pnpm 9** (managed by Corepack)
- **Git**

> We pin versions to avoid “works on my machine.”

---

## 2) Clone and prepare

```bash
git clone <YOUR_REPO_URL> avora
cd avora
# Ensure Node 20
nvm use || echo "Use Node 20 if you have nvm"
# Enable Corepack for pnpm 9
corepack enable
corepack prepare pnpm@9 --activate
pnpm -v   # should show 9.x
```

If you don't use `nvm`, install Node 20 from nodejs.org and continue.

---

## 3) Install dependencies

```bash
pnpm install --frozen-lockfile
```

If this is a fresh repo without a lockfile yet, run:
```bash
pnpm install
```

---

## 4) Environment variables

Copy the example file and fill in credentials later:
```bash
cp env/.env.example services/avora-api/.env
```

Minimal local dev works without live credentials; the app will run with seed data, but integrations (Google, Monday) and Billing (Stripe/Coinbase) won’t function until keys are set.

**When ready**, fill these in `services/avora-api/.env`:
```
CORS_ORIGIN=http://localhost:5173
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:3000/api/auth/google/callback

MONDAY_CLIENT_ID=
MONDAY_CLIENT_SECRET=
MONDAY_REDIRECT_URI=http://localhost:3000/api/auth/monday/callback

STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_PRO=
STRIPE_PRICE_BUSINESS=

COINBASE_API_KEY=
COINBASE_WEBHOOK_SECRET=
```

---

## 5) Run locally (two terminals or VS Code compound)

### Option A: VS Code (one click)
- Open the workspace folder in VS Code.
- Press **F5**, or choose the compound launch: **Run Web + API**.

### Option B: Terminals
Terminal 1 (API):
```bash
cd services/avora-api
pnpm dev
# listens on http://localhost:3000
```
Terminal 2 (Web):
```bash
cd apps/avora-web
pnpm dev
# opens http://localhost:5173
```

---

## 6) Verify it’s working

- Visit **http://localhost:5173** – you should see the Avora starter page.
- API health check: **http://localhost:3000/healthz** → `{ "ok": true }`

---

## 7) GitHub Pages deploy (frontend)

1. Push to GitHub on the `main` branch.
2. In your repo, go to **Settings → Pages** and select **GitHub Actions** (if not already).
3. Our workflow `deploy-pages.yml` builds and deploys `apps/avora-web/dist` to Pages automatically.

Your app will be served at `https://<your-username>.github.io/<repo>/` once the Action finishes.

> If the site path includes a subfolder, ensure your router uses relative paths or set Vite’s `base` accordingly.

---

## 8) Deploy the API (Vercel or Netlify)

### Vercel
- Import the repo in Vercel.
- Set environment variables from `.env.example` (don’t commit secrets).
- Framework preset: **Other** (Node/Express).
- Build command: none required for the simple starter; or `pnpm --filter avora-api build` if you add a build step.
- Output: none (it’s a server).

### Netlify
- Create a new site from Git.
- Use Netlify functions or a simple Node server (Netlify Edge Functions optional).
- Set environment variables in Site Settings.

**CORS:** set `CORS_ORIGIN` to your production web origin(s) in the API env.

---

## 9) Continuous Integration

CI runs on every push:
- Build, lint, test
- Lighthouse CI against the built web app (performance ≥ 0.95, a11y ≥ 0.98, best practices = 1.0, SEO = 1.0)
- GitHub Pages deploy of the web

If Lighthouse fails, fix performance or a11y issues before merging.

---

## 10) Common pitfalls & fixes

- **Windows path/EOL issues:** we enforce LF via `.gitattributes` and VS Code settings. If you see odd diffs, re-check `core.autocrlf=false` or use WSL2.
- **pnpm missing:** `corepack enable && corepack prepare pnpm@9 --activate`
- **Node version mismatch:** `nvm use` or ensure Node 20 is installed.
- **Port conflicts:** change Vite port with `--port 5173` or update API port via `PORT=3001` in the env and CORS.
- **CSP blocks Stripe/Coinbase:** verify `Content-Security-Policy` includes `js.stripe.com` and `commerce.coinbase.com` in `script-src` and `frame-src`.

---

## 11) Next steps

- Wire Google & Monday OAuth (Scopes: Calendar readonly; Monday boards/items/users read-only).
- Add Stripe/Coinbase keys and test webhooks.
- Build the **Gauge** UI and **Flight Plan** logic per acceptance criteria.
- Turn on Sentry DSNs and create a status page in `/docs/status/`.

---

## 12) Useful scripts (optional)

Add these to the **root** `package.json` if you want shortcuts:
```json
{{
  "scripts": {{
    "dev:web": "pnpm --filter avora-web dev",
    "dev:api": "pnpm --filter avora-api dev",
    "build:web": "pnpm --filter avora-web build",
    "build:api": "pnpm --filter avora-api build",
    "lint": "eslint .",
    "test": "vitest run"
  }}
}}
```

---

## 13) Support

- Issues: open a GitHub issue in your repo
- Logs: check your Vercel/Netlify dashboard for API logs, and browser devtools for the web
- Performance: run `npx @lhci/cli autorun` locally to preview Lighthouse results

Happy building.
