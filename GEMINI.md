# GEMINI.md
Repository-level guidance for coding agents in `joint/`.

This workspace has two TypeScript apps:
- `joint-frontend` (Angular 19)
- `joint-backend` (NestJS 10)

If a subproject has its own `GEMINI.md`, use that as the more specific source.

## Workspace Map
- Frontend root: `joint-frontend/`
- Backend root: `joint-backend/`
- Frontend source: `joint-frontend/src/`
- Backend source: `joint-backend/src/`
- Backend e2e tests: `joint-backend/test/`

## Setup
Install dependencies in each app:
```bash
cd joint-frontend && npm install
cd ../joint-backend && npm install
```

## Build / Lint / Test Commands

### Frontend (`joint-frontend`)
Primary commands from `package.json` and `angular.json`:
```bash
# dev server
npm start
# production build (default config)
npm run build
# development watch build
npm run watch
# test suite (Karma/Jasmine)
npm test
```
Useful explicit builds/tests:
```bash
# QA build
npx ng build --configuration qa
# development build
npx ng build --configuration development
# one-off headless run
npm test -- --watch=false --browsers=ChromeHeadless
```
Single-test commands (frontend):
```bash
# single spec file
npm test -- --include src/app/path/to/file.component.spec.ts --watch=false --browsers=ChromeHeadless
# subset by glob
npm test -- --include "src/app/pages/**/feature*.spec.ts" --watch=false --browsers=ChromeHeadless
```

Frontend lint status:
- No `lint` script in `joint-frontend/package.json`.
- No `lint` target in `joint-frontend/angular.json`.
- Use build + tests as quality gates unless lint setup is explicitly requested.

### Backend (`joint-backend`)
Primary commands from `package.json`:
```bash
# build
npm run build
# run app
npm run start
npm run start:dev
npm run start:debug
npm run start:prod
# lint / format
npm run lint
npm run format
# tests
npm run test
npm run test:watch
npm run test:cov
npm run test:debug
npm run test:e2e
```
Single-test commands (backend):
```bash
# one unit test file
npm test -- src/auth/auth.service.spec.ts
# one unit test by name
npm test -- -t "should create user"
# one e2e file
npx jest --config ./test/jest-e2e.json test/app.e2e-spec.ts
# one e2e test by name
npx jest --config ./test/jest-e2e.json -t "AppController (e2e)"
```
Helpful read-only checks:
```bash
# backend type-check only
npx tsc --noEmit
# backend lint without autofix
npx eslint "{src,apps,libs,test}/**/*.ts"
```

## Code Style Guidelines
Prefer the nearest-local style in files you touch. Keep diffs small and focused.

### Formatting
- Backend Prettier (`joint-backend/.prettierrc`): `singleQuote: true`, `trailingComma: all`.
- Frontend follows Angular CLI/TypeScript defaults.
- Do not reformat unrelated files.
- Keep ASCII unless the file already requires Unicode.

### Imports
- Order imports: framework, third-party, project aliases, relative.
- Frontend aliases in `joint-frontend/tsconfig.json`:
  - `@shared/*`
  - `@service/*`
  - `@models/*`
- Prefer aliases over deep relative paths across feature boundaries.

### Types
- Frontend is strict (`strict: true`, strict templates).
- Backend is less strict (`noImplicitAny: false`, `strictNullChecks: false`).
- For new code, prefer explicit return types and narrow types/interfaces.
- Avoid introducing new `any` unless unavoidable at legacy edges.

### Naming
- `PascalCase`: classes, interfaces, enums.
- `camelCase`: variables, functions, methods, parameters.
- `kebab-case`: Angular filenames/selectors.
- Preserve Nest naming patterns: `*.module.ts`, `*.service.ts`, `*.controller.ts`, `*.dto.ts`, `*.entity.ts`.

### Architecture
- Frontend: keep heavy logic in services; components orchestrate UI state.
- Backend: keep controllers thin; business logic belongs in services.
- Respect current module boundaries and DI patterns.
- Avoid broad refactors unless explicitly requested.

### Frontend scan UI standard
- Treat `joint-frontend/src/app/shared/styles/scan-session-tokens.css`, `joint-frontend/src/app/shared/styles/scan-session-tables.css`, `joint-frontend/src/app/shared/styles/scan-session-modals.css`, and `joint-frontend/src/styles.css` as the source of truth for scan/session visual patterns.
- Import scan shared styles as the first line of feature stylesheets from `src/app/shared/styles` (or use `scan/shared/scan-session-theme.css` as the compatibility wrapper).
- Apply `scan-session-shell` on scan/session wrappers; if extra wrapper classes are needed, append them without removing `scan-session-shell`.
- Use `session-table` for default tables and add `session-table-compact` for dense views (modals, selectors, high-column lists).
- Build search bars with `search-standard-row`, `search-standard`, `search-standard-icon`, and `search-standard-input`; do not prefer legacy wrappers such as `flex-search`/`search-section`.
- Use `btn-back session-back-btn` together for back actions in scan/session pages.
- Reuse shared classes before creating local CSS: `scan-cta-btn`, `scan-last-card`, `bg-text`, `kpi-card`, `kpi-card-active`, `kpi-card-static`, `scan-kpi-grid`, `scan-list-grid`, `list-selector-grid`, `list-toggle-item`, `list-toggle-label`, `session-back-btn`.
- For classification/status modals, use `classify-guide-modal`, `classify-guide-body`, `classify-guide-title`, `classify-guide-subtitle`, `classify-guide-select-wrap`, `classify-guide-select`, `classify-guide-submit`, and `classify-guide-cancel`.
- Preserve module-specific behavior (for example, `Total` counters and domain-specific columns) while standardizing visuals.
- When KPI counters switch list views, use a helper such as `selectListFromCounter(listKey: string)` and bind both click and Enter on `kpi-card`.

### Frontend form UI standard
- Treat `joint-frontend/src/app/shared/styles/configuration-form-standards.css` as the source of truth for configuration forms.
- Import the shared form stylesheet in feature stylesheets (`@import '../../../shared/styles/configuration-form-standards.css';` or equivalent relative path).
- Apply `config-form-shell` on form wrappers to enable shared form tokens.
- Build form layout with `config-form-panel`, `config-form-panel-body`, `config-form-grid`, and `config-form-field`.
- Use `config-form-label` and `config-form-label is-required` for labels; use `config-form-control` for inputs, selects, dates, and editable inline controls.
- Use `config-form-note`/`required-fields-note` and `config-form-hint` for helper text and required-field copy.
- Use `config-form-actions`, `config-form-btn`, `config-form-btn-primary`, and `config-form-btn-secondary` for submit/cancel zones.
- Use `config-upload-grid`, `config-upload-card`, `config-upload-title`, and `config-upload-file` for file/document form sections.
- Preserve module-specific behavior and validations while standardizing form visuals.

### Error Handling
- Backend: use Nest HTTP exceptions instead of generic `Error` where request-facing.
- Backend: do not swallow exceptions; map/rethrow with actionable context.
- Frontend: handle error paths for user-triggered async flows.
- Always clear loading state on success and failure.

### Testing Practices
- Start with targeted runs (single file/name), then broaden.
- Do not commit `fit`/`fdescribe` in frontend specs.
- Keep unit tests deterministic and isolated from external systems.

### Dependency and Config Safety
- Do not add dependencies unless task scope requires it.
- Never commit secrets (for example `.env` values).

## Cursor and Copilot Rules
Checked locations:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`

Current status:
- No Cursor rules found.
- No Copilot instructions found.

If these files are added later, treat them as higher-priority and update this document.

## Agent Checklist
- Confirm target app first (`joint-frontend` or `joint-backend`).
- Prefer single-test execution before full suites.
- Keep edits minimal and aligned with local conventions.
- Report what was validated and what was intentionally not run.

### Skills Registry

Auto-generated from `./.agents/skills` (repo) and `~/.agents/skills` (global).

| Skill | Source | Description |
|-------|--------|-------------|
| `agents-gemini-sync` | global | Sync `AGENTS.md` and `GEMINI.md` skill registry sections from both repository-local skills (`./.agents/skills`) and global skills (`~/.agents/skills`). Use when creating, renaming, deleting, or updating skills and you need agent docs to reflect current available skills. |
| `angular-component` | global | Create modern Angular standalone components following v20+ best practices. Use for building UI components with signal-based inputs/outputs, OnPush change detection, host bindings, content projection, and lifecycle hooks. Triggers on component creation, refactoring class-based inputs to signals, adding host bindings, or implementing accessible interactive components. |
| `error-handling-patterns` | global | Master error handling patterns across languages including exceptions, Result types, error propagation, and graceful degradation to build resilient applications. Use when implementing error handling, designing APIs, or improving application reliability. |
| `find-skills` | global | Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill. |
| `frontend-design` | global | Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics. |
| `monorepo-guides-sync` | global | Synchronize root `AGENTS.md` and `GEMINI.md` with workspace subprojects by generating an up-to-date project inventory from folder structure. Use when adding, renaming, or removing repositories inside a monorepo root so agent docs stay aligned. |
| `php-pro` | global | Use when building PHP applications with modern PHP 8.3+ features, Laravel, or Symfony frameworks. Invoke for strict typing, PHPStan level 9, async patterns with Swoole, PSR standards. |
| `responsive-design` | global | Implement modern responsive layouts using container queries, fluid typography, CSS Grid, and mobile-first breakpoint strategies. Use when building adaptive interfaces, implementing fluid layouts, or creating component-level responsive behavior. |
| `responsive-design` | repo | Implement modern responsive layouts using container queries, fluid typography, CSS Grid, and mobile-first breakpoint strategies. Use when building adaptive interfaces, implementing fluid layouts, or creating component-level responsive behavior. |
| `shadcn-ui` | global | Provides complete shadcn/ui component library patterns including installation, configuration, and implementation of accessible React components. Use when setting up shadcn/ui, installing components, building forms with React Hook Form and Zod, customizing themes with Tailwind CSS, or implementing UI patterns like buttons, dialogs, dropdowns, tables, and complex form layouts. |
| `skill-creator` | global | Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations. |
| `skill-sync` | global | Syncs skill metadata to AGENTS.md Auto-invoke sections. Trigger: When updating skill metadata (metadata.scope/metadata.auto_invoke), regenerating Auto-invoke tables, or running ./skills/skill-sync/assets/sync.sh (including --dry-run/--scope). |
| `style-standards-sync` | repo | Synchronize frontend styling standards into agent guidance files (`AGENTS.md` and `GEMINI.md`) by reading current CSS/HTML standard sources and updating the docs sections that define UI conventions. Use when style standards change, when new shared classes are introduced, or when docs drift from implemented UI patterns. |
| `tailwind-v4-shadcn` | global | Set up Tailwind v4 with shadcn/ui using @theme inline pattern and CSS variable architecture. Four-step pattern: CSS variables, Tailwind mapping, base styles, automatic dark mode. Prevents 8 documented errors. Use when initializing React projects with Tailwind v4, or fixing colors not working, tw-animate-css errors, @theme inline dark mode conflicts, @apply breaking, v3 migration issues. |
