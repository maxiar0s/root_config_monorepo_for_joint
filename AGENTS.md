# AGENTS.md
Repository-level guidance for coding agents working in `joint/`.

Workspace apps:
- `joint-frontend` (Angular 19)
- `joint-backend` (NestJS 10)

If a subproject has its own `AGENTS.md`, follow that file first when editing files in that subproject.

## Workspace Map
- Frontend root: `joint-frontend/`
- Backend root: `joint-backend/`
- Frontend source: `joint-frontend/src/`
- Backend source: `joint-backend/src/`
- Backend e2e tests: `joint-backend/test/`

## Setup
Install deps per app:
```bash
cd joint-frontend && npm install
cd ../joint-backend && npm install
```

## Build / Lint / Test Commands

### Frontend (`joint-frontend`)
```bash
# dev server
npm start

# builds
npm run build
npm run watch
npx ng build --configuration qa
npx ng build --configuration development

# tests
npm test
npm test -- --watch=false --browsers=ChromeHeadless
```

Run a single frontend test:
```bash
# one file
npm test -- --include src/app/path/to/file.component.spec.ts --watch=false --browsers=ChromeHeadless

# glob subset
npm test -- --include "src/app/pages/**/feature*.spec.ts" --watch=false --browsers=ChromeHeadless
```

Frontend lint status:
- No `lint` script in `joint-frontend/package.json`.
- No lint architect target in `joint-frontend/angular.json`.
- Use build + tests as quality gates unless lint tooling is explicitly requested.

### Backend (`joint-backend`)
```bash
# build/run
npm run build
npm run start
npm run start:dev
npm run start:debug
npm run start:prod

# quality
npm run format
npm run lint
npx tsc --noEmit
npx eslint "{src,apps,libs,test}/**/*.ts"

# tests
npm run test
npm run test:watch
npm run test:cov
npm run test:debug
npm run test:e2e
```

Run a single backend test:
```bash
# one unit file
npm test -- src/auth/auth.service.spec.ts

# one unit test by name
npm test -- -t "should be defined"

# one e2e file
npx jest --config ./test/jest-e2e.json test/app.e2e-spec.ts

# one e2e test by name
npx jest --config ./test/jest-e2e.json -t "AppController (e2e)"
```

## Code Style Guidelines
Use nearby code as the source of truth. Keep edits focused and minimal.

### Formatting
- Prefer ASCII unless the file already requires Unicode.
- Respect `.editorconfig` and existing Prettier output.
- Backend formatting conventions include `singleQuote: true` and `trailingComma: all`.
- Do not reformat unrelated files.

### Imports
- Order imports: framework -> third-party -> aliases -> relative.
- Frontend aliases in active use: `@shared/*`, `@service/*`, `@models/*`.
- Prefer aliases over deep relative imports across feature boundaries.

### Types
- Frontend is strict TypeScript: keep strict-compatible typings.
- Backend has legacy loose areas; still prefer explicit, narrow types in new code.
- Prefer DTOs/interfaces/types over ad-hoc object shapes.
- Avoid introducing new `any` unless unavoidable at legacy boundaries.

### Naming
- `PascalCase`: classes, interfaces, enums.
- `camelCase`: variables, params, methods, functions.
- Frontend selectors/files: `kebab-case`.
- Backend file naming: `*.module.ts`, `*.service.ts`, `*.controller.ts`, `*.dto.ts`, `*.entity.ts`.

### Architecture
- Frontend: components for UI orchestration; services for API/business reuse.
- Backend: thin controllers; business logic in services.
- Respect existing DI patterns and module boundaries.
- Avoid broad refactors unless explicitly requested.

### Error Handling
- Backend: use Nest HTTP exceptions for request-facing failures.
- Backend: do not swallow errors; rethrow/map with actionable context.
- Frontend: always handle failure branches in user-triggered async flows.
- Always clear loading states on success and error.

### Testing
- Prefer single-file/test-name runs first, then broader suites.
- Keep tests deterministic and isolated.
- Never leave `fit`/`fdescribe` in committed code.
- For bug fixes, add/adjust the smallest test proving behavior.

### Security / Safety
- Never commit secrets, credentials, or `.env` values.
- Do not add dependencies unless required by the task scope.
- Avoid destructive DB/schema changes unless explicitly requested.

## Cursor / Copilot Rules
Checked:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`

Current status:
- No Cursor rules found.
- No Copilot instructions found.

If those files are added later, treat them as higher-priority instructions and update this file.

## Agent Checklist
- Confirm target app first (`joint-frontend` or `joint-backend`).
- Read subproject `AGENTS.md` before changing files there.
- Prefer focused edits over unrelated cleanup.
- Run relevant build/tests for touched areas.
- Report what you validated and what you intentionally did not run.
