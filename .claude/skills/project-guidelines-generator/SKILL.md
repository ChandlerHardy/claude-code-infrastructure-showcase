---
name: project-guidelines-generator
description: Generate or update project-specific development guideline skills by scanning the current codebase. Use when the user says "generate project guidelines", "create project skill", "scan project stack", "update project guidelines", or when starting work on a repo with no .claude/skills/*-guidelines/ directory.
---

# Project Guidelines Generator

Scans the current project and generates a tailored `{project-name}-guidelines` skill in `.claude/skills/` within the project root. This replaces generic domain skills with project-specific patterns, conventions, and gotchas.

**This is a meta-skill — it instructs YOU (Claude) to perform the analysis and generation.**

---

## Execution Flow

Execute these 4 phases sequentially. Do NOT skip phases or parallelize across phases.

### Phase 1: Stack Detection

**Goal:** Build a structured stack summary by scanning indicator files.

Read the resource file `resources/stack-detection.md` for the full indicator-to-stack mapping tables.

**Steps:**
1. Use Glob to find indicator files in the project root and immediate subdirectories:
   ```
   package.json, pyproject.toml, Cargo.toml, go.mod, composer.json, Gemfile,
   requirements.txt, pom.xml, build.gradle, mix.exs, pubspec.yaml
   ```
2. Read each found file to extract dependency names and versions
3. Scan for framework configs:
   ```
   next.config.*, nuxt.config.*, vite.config.*, turbo.json, angular.json,
   prisma/schema.prisma, drizzle.config.*, tailwind.config.*, tsconfig.json
   ```
4. Check for infrastructure files:
   ```
   docker-compose*.yml, Dockerfile*, .env.example, CLAUDE.md,
   Procfile, fly.toml, vercel.json, netlify.toml, railway.json
   ```
5. Check for monorepo indicators:
   ```
   turbo.json, pnpm-workspace.yaml, lerna.json, nx.json,
   package.json "workspaces" field
   ```
6. **Output:** Build a structured summary with these categories:
   - **Language(s):** TypeScript, Python, Rust, Go, etc.
   - **Runtime:** Node.js, Bun, Deno, Python 3.x, etc.
   - **Frontend framework:** Next.js, Nuxt, SvelteKit, Remix, etc.
   - **Backend framework:** Fastify, Express, Django, FastAPI, Actix, etc.
   - **Database:** PostgreSQL, MySQL, MongoDB, SQLite, etc.
   - **ORM/Query builder:** Prisma, Drizzle, SQLAlchemy, Diesel, etc.
   - **Auth:** Clerk, NextAuth, Supabase Auth, custom JWT, etc.
   - **Queue/Workers:** BullMQ, Celery, Sidekiq, etc.
   - **AI/ML:** OpenAI SDK, Anthropic SDK, custom LLM integration, etc.
   - **Testing:** Jest, Vitest, pytest, cargo test, etc.
   - **Monorepo:** Turborepo, Nx, pnpm workspaces, etc.
   - **Deployment:** Vercel, Docker, AWS, fly.io, etc.
   - **UI library:** shadcn/ui, MUI, Chakra, Tailwind, etc.
   - **Workspaces:** List each workspace with its role (e.g., `apps/web` = frontend, `apps/api` = backend)

### Phase 2: Pattern Analysis

**Goal:** For each detected workspace, read 2-3 representative files per category to extract actual patterns.

Read the resource file `resources/pattern-analysis.md` for detailed per-category instructions.

**Steps:**
1. For each workspace identified in Phase 1, use Glob and Grep to find representative files
2. Read 2-3 files per pattern category (NOT exhaustive — just enough to identify conventions)
3. Extract patterns for these categories:
   - **Route/endpoint organization:** File structure, naming, grouping
   - **Auth middleware/guards:** How auth is enforced, where context is attached
   - **Error handling:** Helper functions, error response shapes, status codes
   - **Database access:** Direct ORM in routes vs. repository pattern, transaction handling
   - **API client (frontend):** Fetch wrappers, SWR/React Query hooks, auth token injection
   - **State management:** React Context, Zustand, Redux, server state vs. client state
   - **Background jobs:** Queue setup, worker patterns, retry/backoff config
   - **Testing patterns:** Test file location, mocking strategy, fixture patterns
   - **Shared code:** Cross-workspace types, validation schemas, constants
   - **Logging:** Logger setup, structured logging, log levels
4. **Output:** For each pattern, record:
   - The convention (e.g., "routes use Fastify plugin pattern with `registerRoutes(app)` function")
   - A brief code snippet showing the pattern (3-10 lines)
   - Which files exemplify it

### Phase 3: CLAUDE.md & Memory Mining

**Goal:** Extract project-specific gotchas, deployment info, and known pitfalls.

**Steps:**
1. Read `CLAUDE.md` in the project root (if present)
2. Read any `.claude/` memory files (MEMORY.md, topic files)
3. Extract:
   - **Environment variables** and their purpose
   - **Deployment process** and URLs
   - **Known gotchas** (things that break easily, non-obvious behaviors)
   - **Port allocation** and service dependencies
   - **Database migration gotchas** (e.g., "prisma db push drops tsvector columns")
   - **Auth quirks** (e.g., "Clerk v2 uses compact JWT claims")
   - **Common operations** (dev setup, deploy, test commands)

### Phase 4: Generate Skill

**Goal:** Create the project-specific guidelines skill with resource files.

Read the resource file `resources/skill-template.md` for the complete template structure.

**Steps:**
1. Determine the project name from the root directory name or `package.json` name field
2. Create the skill directory: `.claude/skills/{project-name}-guidelines/`
3. Create `resources/` subdirectory
4. Generate these files using the template in `resources/skill-template.md`:

   **SKILL.md** (~300-500 lines):
   - Frontmatter with name `{project-name}-guidelines` and detection-focused description
   - Stack overview section
   - Backend patterns section (referencing `resources/backend-patterns.md`)
   - Frontend patterns section (referencing `resources/frontend-patterns.md`)
   - Database guide section (referencing `resources/database-guide.md`)
   - API contracts section (referencing `resources/api-contracts.md`)
   - Deployment & gotchas section
   - `## Custom Notes` section (empty, preserved on regeneration)

   **resources/backend-patterns.md**:
   - Route organization with code snippets
   - Auth middleware patterns
   - Error handling helpers with signatures
   - Background job patterns
   - Logging conventions

   **resources/frontend-patterns.md**:
   - Component organization
   - Data fetching patterns (hooks, cache)
   - Auth integration (token injection, protected routes)
   - UI library conventions
   - State management approach

   **resources/database-guide.md**:
   - ORM usage patterns with code snippets
   - Migration process and gotchas
   - Naming conventions (table names vs. model names)
   - Connection setup and pooling
   - Query patterns (filters, pagination, search)

   **resources/api-contracts.md**:
   - Shared types location and usage
   - Validation schema patterns (Zod, etc.)
   - API response envelope shape
   - Error response format
   - Type generation workflow (if applicable)

5. **Update behavior:** If the skill already exists:
   - Read the existing SKILL.md
   - Preserve any content under `## Custom Notes`
   - Regenerate all other sections
   - Regenerate all resource files

---

## Post-Generation

After generating:
1. List all created/updated files with line counts
2. Summarize the key patterns captured
3. Remind the user to restart Claude Code for the new skill to be available
4. Suggest running `code-review-local` to verify the project skill is detected

---

## Quality Checks

The generated skill should:
- Reference actual file paths from THIS project (not generic examples)
- Include real code snippets extracted during Phase 2 (not made-up examples)
- Capture project-specific gotchas from CLAUDE.md/memory (not generic advice)
- Be useful for a NEW developer joining the project
- Be useful for code review agents to check patterns against
- NOT duplicate information already in CLAUDE.md (reference it instead)
- Stay under 500 lines for the main SKILL.md (use resource files for details)
