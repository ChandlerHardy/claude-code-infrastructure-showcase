# Pattern Analysis Guide

Per-category analysis instructions for Phase 2. For each category, find 2-3 representative files and extract the patterns described.

---

## Route/Endpoint Organization

**What to find:**
- Backend: Glob for `routes/*.ts`, `routes/**/*.ts`, `api/**/*.ts`, `endpoints/*.ts`, `controllers/*.ts`
- Frontend: Glob for `app/**/page.tsx`, `pages/**/*.tsx`, `app/**/route.ts`

**What to extract:**
- How routes are registered (plugin pattern, decorator, file-based)
- URL naming convention (kebab-case, camelCase, nested resources)
- How route handlers are structured (inline vs. imported controllers)
- Request validation approach (Zod schema, decorator, middleware)
- Response envelope shape (e.g., `{ data, error, meta }`)

**Example pattern to document:**
```
Routes use Fastify plugin pattern:
  export async function conversationRoutes(app: FastifyInstance) {
    app.get('/', { preHandler: [requireOrg] }, async (request, reply) => { ... })
  }
Registered in server.ts via app.register(conversationRoutes, { prefix: '/api/v1/conversations' })
```

---

## Auth Middleware/Guards

**What to find:**
- Grep for `middleware`, `preHandler`, `guard`, `requireAuth`, `protect`, `authenticate`
- Look in `lib/auth.ts`, `middleware/auth.ts`, `middleware.ts`, `guards/`

**What to extract:**
- How auth is enforced (middleware, preHandler hook, decorator)
- What auth context is attached to requests (`request.auth`, `request.user`, `ctx.user`)
- Multi-tenancy scoping (org ID, tenant ID, workspace ID)
- Token format quirks (e.g., compact JWT claims)

---

## Error Handling

**What to find:**
- Grep for `sendError`, `AppError`, `HttpException`, `createError`, `throw new`
- Look in `lib/errors.ts`, `utils/errors.ts`, `exceptions/`

**What to extract:**
- Error helper function signatures and usage
- Error response shape sent to clients
- HTTP status code conventions
- How errors are logged vs. returned

---

## Database Access

**What to find:**
- Grep for `prisma.`, `db.`, `repository`, `getRepository`, `Model.find`
- Look in route handlers, service files, repository files

**What to extract:**
- Direct ORM in routes vs. repository/service pattern
- Transaction patterns (`$transaction`, `withTransaction`)
- Query patterns (includes/relations, pagination, filtering)
- Naming conventions (model names vs. table names, if different via `@@map` etc.)
- Migration approach (Prisma migrate, Alembic, raw SQL)
- Known gotchas (e.g., tsvector columns dropped by `db push`)

---

## API Client (Frontend)

**What to find:**
- Grep for `fetch(`, `axios`, `useSWR`, `useQuery`, `apiClient`, `createClient`
- Look in `lib/api.ts`, `utils/api.ts`, `hooks/useApi.ts`, `services/`

**What to extract:**
- Fetch wrapper implementation (how base URL, auth headers are set)
- Data fetching hooks (SWR, React Query, custom)
- How auth tokens are injected into requests
- Error handling on the client side
- Cache/revalidation strategy

---

## State Management

**What to find:**
- Grep for `createContext`, `useContext`, `create(` (Zustand), `createSlice`, `atom(`
- Look in `store/`, `context/`, `providers/`, `state/`

**What to extract:**
- Server state approach (SWR, React Query, tRPC)
- Client state approach (Context, Zustand, Redux, Jotai)
- How state is scoped (global vs. feature-level)
- Provider hierarchy in the app root

---

## Background Jobs/Workers

**What to find:**
- Grep for `Queue`, `Worker`, `Bull`, `process`, `celery`, `job`
- Look in `workers/`, `jobs/`, `queues/`, `tasks/`

**What to extract:**
- Queue technology and setup
- Worker concurrency settings
- Retry/backoff configuration
- Job types and their handlers
- How jobs are enqueued from route handlers

---

## Testing Patterns

**What to find:**
- Glob for `**/*.test.ts`, `**/*.spec.ts`, `**/test_*.py`, `**/*_test.go`
- Look in `__tests__/`, `tests/`, `test/`

**What to extract:**
- Test file location convention (co-located vs. separate directory)
- Test runner and assertion library
- Mocking strategy (jest.mock, dependency injection, test doubles)
- Fixture/factory patterns
- Integration vs. unit test separation
- Database test strategy (in-memory, transactions, test DB)

---

## Shared Code Organization

**What to find:**
- Look in `packages/shared/`, `lib/shared/`, `common/`, `core/`
- Grep for shared type imports across workspaces

**What to extract:**
- Where shared types live
- Where shared validation schemas live
- Where shared constants live
- How workspaces import from shared (package name, path aliases)
- What belongs in shared vs. workspace-specific

---

## Logging

**What to find:**
- Grep for `logger`, `log.`, `console.log`, `pino`, `winston`, `bunyan`
- Look in `lib/logger.ts`, `utils/logger.ts`, `logging.py`

**What to extract:**
- Logger library and setup
- Structured logging fields
- Log levels used and when
- Request logging middleware
- How sensitive data is redacted

---

## Output Format

For each pattern category, produce a block like:

```markdown
### [Category Name]

**Convention:** [1-2 sentence description]

**Example:**
```[language]
// from [file path]
[3-10 line code snippet]
```

**Key files:** [list of 2-3 files that exemplify this pattern]

**Gotchas:** [any non-obvious behavior or common mistakes]
```
