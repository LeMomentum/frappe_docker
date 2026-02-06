# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Frappe Bench development environment containing:
- **Frappe Framework** (`apps/frappe/`): Full-stack Python/JavaScript web framework
- **Frappe CRM** (`apps/crm/`): Open-source CRM built on Frappe with Vue 3 frontend
- **Vooroo SaaS** (`apps/vooroo_saas/`): Custom SaaS extensions

**Stack**: Python 3.10+, Node 18+, MariaDB, Redis, Vue 3, Vite, Tailwind CSS

## Development Commands

### Start Development Server
```bash
bench start                    # Starts web server, socketio, watch, scheduler, worker
```
Site available at: http://development.localhost:8000 (Administrator/admin)

### Frontend Development (CRM)
```bash
cd apps/vooroo_saas
yarn install
yarn dev                       # Vite dev server at http://development.localhost:8080
yarn build                     # Production build
```

### Backend Testing
```bash
bench --site development.localhost run-tests --app frappe
bench --site development.localhost run-tests --app crm
bench --site development.localhost run-tests --module frappe.tests.test_api
```

### Linting and Formatting
```bash
# Python (from apps/frappe directory)
ruff check frappe/             # Lint
ruff format frappe/            # Format

# Pre-commit hooks
pre-commit install             # Setup hooks
pre-commit run --all-files     # Run all checks
```

### Bench CLI
```bash
bench console                  # Python REPL with Frappe context
bench migrate                  # Run database migrations
bench build                    # Build frontend assets
bench clear-cache              # Clear Redis cache
bench --site development.localhost mariadb  # Database shell
```

## Architecture

### Directory Structure
```
frappe-bench/
├── apps/                      # Installed Frappe applications
│   ├── frappe/frappe/        # Core framework Python modules
│   ├── crm/crm/              # CRM backend modules
│   └── vooroo_saas/frontend/src/     # CRM Vue 3 frontend
├── sites/                     # Site-specific data and configs
│   ├── development.localhost/ # Current dev site
│   └── common_site_config.json
├── env/                       # Python virtual environment
└── logs/                      # Application logs
```

### Frappe Framework Key Concepts
- **DocType**: Data model definition (schema + controller logic)
- **Document**: Instance of a DocType
- **Hooks**: App-level event handlers (`hooks.py`)
- **API**: REST endpoints via `@frappe.whitelist()` decorator

### CRM Frontend
- Vue 3 + Vite + Tailwind CSS
- State management: Pinia + Frappe call resources
- UI library: Frappe UI (`@frappe/ui`)
- Frontend code: `apps/vooroo_saas/frontend/src/`
- Built assets: `apps/vooroo_saas/vooroo_saas/public/frontend/`

## Code Style

### Python
- Indent: tabs
- Quotes: double
- Line length: 110
- Linter: ruff (see `apps/frappe/pyproject.toml` for rules)

### JavaScript/Vue
- Formatter: Prettier
- Linter: ESLint
- Commit messages: Conventional Commits (enforced by commitlint)

## Configuration

Site config: `sites/common_site_config.json`
- `developer_mode: 1` enables auto-reload and debug features
- `webserver_port: 8000` for HTTP
- `socketio_port: 9000` for real-time

## Integrations

CRM integrates with:
- Twilio (calls/recordings)
- Exotel (agent calling)
- WhatsApp (via Frappe WhatsApp)
- ERPNext (invoicing, accounting)
