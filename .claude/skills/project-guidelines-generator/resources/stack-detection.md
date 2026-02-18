# Stack Detection Reference

Indicator file → stack mapping tables for all major ecosystems.

## Package Manager / Language Detection

| Indicator File | Language | Runtime |
|---|---|---|
| `package.json` | JavaScript/TypeScript | Node.js (check `engines` field for Bun/Deno) |
| `pyproject.toml` or `requirements.txt` or `setup.py` | Python | Check `requires-python` or `.python-version` |
| `Cargo.toml` | Rust | Rust/cargo |
| `go.mod` | Go | Go |
| `composer.json` | PHP | PHP |
| `Gemfile` | Ruby | Ruby |
| `pom.xml` or `build.gradle` | Java/Kotlin | JVM |
| `mix.exs` | Elixir | Erlang/OTP |
| `pubspec.yaml` | Dart | Dart/Flutter |
| `*.csproj` or `*.sln` | C# | .NET |

## Node.js Framework Detection (from package.json dependencies)

| Dependency | Framework | Category |
|---|---|---|
| `next` | Next.js | Fullstack/Frontend |
| `nuxt` | Nuxt | Fullstack/Frontend |
| `@sveltejs/kit` | SvelteKit | Fullstack/Frontend |
| `@remix-run/node` | Remix | Fullstack/Frontend |
| `astro` | Astro | Frontend/SSG |
| `gatsby` | Gatsby | Frontend/SSG |
| `fastify` | Fastify | Backend |
| `express` | Express | Backend |
| `@nestjs/core` | NestJS | Backend |
| `hono` | Hono | Backend |
| `koa` | Koa | Backend |
| `react` (without Next/Remix) | React SPA | Frontend |
| `vue` (without Nuxt) | Vue SPA | Frontend |
| `svelte` (without SvelteKit) | Svelte SPA | Frontend |
| `@angular/core` | Angular | Frontend |

## Python Framework Detection

| Dependency/File | Framework |
|---|---|
| `fastapi` in deps | FastAPI |
| `django` in deps | Django |
| `flask` in deps | Flask |
| `starlette` in deps | Starlette |
| `litestar` in deps | Litestar |
| `manage.py` exists | Django |
| `alembic/` directory | SQLAlchemy + Alembic |

## Database Detection

| Indicator | Database |
|---|---|
| `prisma/schema.prisma` → `provider = "postgresql"` | PostgreSQL + Prisma |
| `prisma/schema.prisma` → `provider = "mysql"` | MySQL + Prisma |
| `prisma/schema.prisma` → `provider = "sqlite"` | SQLite + Prisma |
| `drizzle.config.*` | Drizzle ORM (check DB from config) |
| `sqlalchemy` in Python deps | SQLAlchemy |
| `django.db` usage | Django ORM |
| `mongoose` in deps | MongoDB + Mongoose |
| `pg` or `postgres` in deps (without ORM) | PostgreSQL raw |
| `redis` or `ioredis` in deps | Redis |
| `pgvector` in Prisma schema or deps | pgvector extension |

## Auth Detection

| Indicator | Auth System |
|---|---|
| `@clerk/nextjs` or `@clerk/backend` | Clerk |
| `next-auth` or `@auth/core` | NextAuth/Auth.js |
| `@supabase/auth-helpers-*` | Supabase Auth |
| `passport` | Passport.js |
| `jsonwebtoken` + custom middleware | Custom JWT |
| `firebase-admin` auth usage | Firebase Auth |
| `@aws-amplify/auth` | AWS Cognito |

## Queue/Worker Detection

| Indicator | Queue System |
|---|---|
| `bullmq` or `bull` in deps | BullMQ/Bull (Redis-backed) |
| `celery` in Python deps | Celery |
| `sidekiq` in Gemfile | Sidekiq |
| `@google-cloud/tasks` | Google Cloud Tasks |
| `@aws-sdk/client-sqs` | AWS SQS |
| `amqplib` or `amqp-connection-manager` | RabbitMQ |

## AI/ML Detection

| Indicator | AI Integration |
|---|---|
| `openai` in deps | OpenAI API |
| `@anthropic-ai/sdk` | Anthropic API |
| `@google/genai` or `@google-cloud/aiplatform` | Google AI |
| `langchain` in deps | LangChain |
| `llamaindex` in deps | LlamaIndex |
| Custom API endpoint with `x-api-key` header | Custom/proxy AI API |
| `ZAI_API_KEY` in env | z.ai (Anthropic-compatible) |

## Testing Detection

| Indicator | Test Framework |
|---|---|
| `jest` in deps or `jest.config.*` | Jest |
| `vitest` in deps or `vitest.config.*` | Vitest |
| `@playwright/test` in deps | Playwright |
| `cypress` in deps | Cypress |
| `pytest` in Python deps | pytest |
| `cargo test` (Rust default) | cargo test |
| `go test` (Go default) | go test |
| `phpunit/phpunit` in composer | PHPUnit |

## Monorepo Detection

| Indicator | Monorepo Tool |
|---|---|
| `turbo.json` | Turborepo |
| `nx.json` | Nx |
| `lerna.json` | Lerna |
| `pnpm-workspace.yaml` | pnpm workspaces |
| `"workspaces"` in root `package.json` | npm/yarn workspaces |

## UI Library Detection

| Indicator | UI Library |
|---|---|
| `@shadcn/ui` or `.components/ui/` with shadcn patterns | shadcn/ui |
| `@mui/material` | Material UI |
| `@chakra-ui/react` | Chakra UI |
| `@mantine/core` | Mantine |
| `tailwindcss` in deps | Tailwind CSS |
| `styled-components` | styled-components |
| `@emotion/react` | Emotion |

## Deployment Detection

| Indicator | Platform |
|---|---|
| `vercel.json` or `"vercel"` in deps | Vercel |
| `netlify.toml` | Netlify |
| `fly.toml` | Fly.io |
| `railway.json` or `railway.toml` | Railway |
| `Dockerfile` + `docker-compose*.yml` | Docker (self-hosted) |
| `appspec.yml` | AWS CodeDeploy |
| `Procfile` | Heroku |
| `.github/workflows/*.yml` with deploy steps | GitHub Actions CD |
