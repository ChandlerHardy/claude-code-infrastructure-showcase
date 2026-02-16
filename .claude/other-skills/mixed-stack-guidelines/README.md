# Mixed Stack Development Guidelines

This skill provides comprehensive guidance for development projects using mixed technology stacks. When working with multiple languages, frameworks, or paradigms, follow these universal patterns and principles.

## When to Use This Skill

Use this skill when:
- Working with projects that use multiple programming languages
- Integrating different frameworks or libraries
- Making architectural decisions for polyglot systems
- Organizing codebases with diverse technologies
- Setting up development patterns for mixed environments
- Debugging issues across different technology boundaries

## Universal Development Principles

### 1. **Architecture Patterns**

**Layered Architecture:**
```
├── src/
│   ├── api/           # API layer (endpoints, routes)
│   ├── services/       # Business logic layer
│   ├── repositories/   # Data access layer
│   ├── models/         # Data models/entities
│   ├── utils/          # Shared utilities
│   └── config/         # Configuration files
```

**Microservice Patterns:**
```
├── services/
│   ├── auth-service/     # Authentication
│   ├── user-service/     # User management
│   ├── payment-service/  # Payment processing
│   └── notification-service/ # Notifications
├── shared/              # Shared libraries
└── gateway/             # API Gateway
```

### 2. **File Organization Strategies**

**Technology-Specific Directories:**
```
project/
├── backend/
│   ├── php/             # PHP code
│   ├── python/           # Python code
│   └── node/            # Node.js code
├── frontend/
│   ├── react/            # React components
│   ├── vue/              # Vue components
│   └── static/           # Static assets
├── database/
│   ├── migrations/       # Database migrations
│   ├── seeds/            # Seed data
│   └── schemas/          # Database schemas
├── infrastructure/
│   ├── docker/           # Docker configurations
│   ├── k8s/              # Kubernetes manifests
│   └── ci-cd/            # CI/CD pipelines
└── docs/                # Documentation
```

**Feature-Based Organization:**
```
project/
├── features/
│   ├── user-management/
│   │   ├── api/          # API endpoints
│   │   ├── models/        # Data models
│   │   ├── services/      # Business logic
│   │   ├── tests/         # Tests
│   │   └── frontend/      # UI components
│   ├── payments/
│   └── notifications/
├── shared/               # Shared code
└── config/               # Configuration
```

### 3. **Cross-Language Communication**

**API Contracts:**
```json
{
  "version": "1.0.0",
  "endpoints": {
    "users": {
      "GET /api/users": {
        "description": "List all users",
        "response": {
          "200": {
            "type": "array",
            "items": {"$ref": "#/components/schemas/User"}
          }
        }
      }
    }
  }
}
```

**Message Formats:**
```json
{
  "event": "user.created",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "user_id": 12345,
    "email": "user@example.com"
  },
  "metadata": {
    "source": "user-service",
    "version": "1.0"
  }
}
```

### 4. **Database Design Patterns**

**Polyglot Persistence:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL     │    │      Redis       │    │    MongoDB      │
│                 │    │                 │    │                 │
│ • Relational    │    │ • Caching       │    │ • Documents     │
│ • Transactions  │    │ • Sessions      │    │ • Flexible      │
│ • Consistency   │    │ • Fast lookup   │    │ • Schema-less   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                    ┌─────────────────┐
                    │   Application   │
                    │    Layer       │
                    └─────────────────┘
```

**Data Access Patterns:**
```python
# Repository Pattern (Python)
class UserRepository:
    def __init__(self, db_connection):
        self.db = db_connection

    def find_by_id(self, user_id):
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def create(self, user_data):
        # Validation and business logic
        pass
```

```php
// Repository Pattern (PHP)
class UserRepository {
    private $db;

    public function __construct(Database $db) {
        $this->db = $db;
    }

    public function findById(int $userId): ?User {
        $stmt = $this->db->prepare("SELECT * FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        return $stmt->fetchObject(User::class);
    }
}
```

### 5. **Error Handling Standards**

**Consistent Error Format:**
```json
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with ID 12345 not found",
    "details": {
      "user_id": 12345,
      "timestamp": "2024-01-15T10:30:00Z"
    },
    "trace_id": "abc123-def456-ghi789"
  }
}
```

**Language-Agnostic Logging:**
```python
# Python
import structlog
logger = structlog.get_logger()
logger.error("User operation failed",
            user_id=user_id,
            operation="create_user",
            error=str(e))
```

```php
// PHP
use Monolog\Logger;
use Monolog\Handler\StreamHandler;

$logger = new Logger('app');
$logger->error('User operation failed', [
    'user_id' => $userId,
    'operation' => 'create_user',
    'error' => $e->getMessage()
]);
```

### 6. **Testing Strategies**

**Test Organization:**
```
tests/
├── unit/                 # Unit tests
│   ├── python/
│   ├── php/
│   └── javascript/
├── integration/          # Integration tests
├── e2e/                # End-to-end tests
├── fixtures/            # Test data
└── helpers/             # Test utilities
```

**Cross-Language Testing:**
```python
# Python integration test
def test_user_api_flow():
    # Create user via API
    response = requests.post('/api/users', json=user_data)
    assert response.status_code == 201

    # Verify in database
    user = db.query("SELECT * FROM users WHERE id = %s",
                    (response.json()['id'],))
    assert user is not None
```

```php
// PHP integration test
class UserApiTest extends TestCase {
    public function testCreateUserFlow() {
        $response = $this->client->post('/api/users', $userData);
        $this->assertEquals(201, $response->getStatusCode());

        $user = $this->db->fetchOne(
            "SELECT * FROM users WHERE id = ?",
            [$response->json()['id']]
        );
        $this->assertNotNull($user);
    }
}
```

### 7. **Configuration Management**

**Environment-Specific Config:**
```yaml
# config/development.yaml
database:
  host: localhost
  port: 5432
  name: app_dev

cache:
  type: redis
  host: localhost
  port: 6379

logging:
  level: debug
```

```yaml
# config/production.yaml
database:
  host: ${DB_HOST}
  port: ${DB_PORT}
  name: ${DB_NAME}

cache:
  type: redis
  host: ${REDIS_HOST}
  port: ${REDIS_PORT}

logging:
  level: info
```

### 8. **Development Workflow Patterns**

**Git Workflow for Mixed Stacks:**
```
main
├── feature/user-authentication
│   ├── backend-changes/
│   ├── frontend-changes/
│   ├── database-migrations/
│   └── tests/
├── feature/payment-integration
└── hotfix/critical-bug-fix
```

**Docker Multi-Stage Builds:**
```dockerfile
# Multi-language application
FROM node:16-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

FROM python:3.9-slim AS backend
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY backend/ ./
COPY --from=frontend-builder /app/frontend/dist ./static

EXPOSE 8000
CMD ["python", "app.py"]
```

### 9. **Performance Optimization

**Caching Strategies:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │      Cache      │    │    Database     │
│                 │    │                 │    │                 │
│ • Check cache   │────▶│ • Redis        │────▶│ • PostgreSQL    │
│ • Cache miss    │    │ • Memcached    │    │ • MongoDB       │
│ • Update cache  │    │ • In-memory    │    │ • Queries       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Language-Specific Optimizations:**
```python
# Python async patterns
import asyncio
import aiohttp

async def fetch_multiple_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)
```

```php
// PHP optimization patterns
use Opis\Closure\SerializableClosure;

// Lazy loading with generators
function processLargeDataset($data) {
    foreach ($data as $item) {
        yield processItem($item);
    }
}
```

### 10. **Security Best Practices**

**Universal Security Principles:**
```
Input Validation ──▶ Authentication ──▶ Authorization
        │                     │                    │
        ▼                     ▼                    ▼
  • Type checking      • JWT tokens         • Role-based
  • Sanitization       • Sessions           • Permissions
  • Length limits      • MFA                • Auditing
        │                     │                    │
        └─────────────────────┼────────────────────┘
                              │
                              ▼
                       Output Encoding
  • XSS prevention
  • SQL injection prevention
  • CSRF protection
```

## Technology Integration Patterns

### Database Integration

**Multi-Database Transactions:**
```python
# Distributed transaction pattern
class TransactionManager:
    def __init__(self, primary_db, cache_db):
        self.primary = primary_db
        self.cache = cache_db

    async def transfer_user_data(self, user_id):
        async with self.primary.transaction():
            # Update primary database
            await self.primary.update_user(user_id, data)

            # Update cache
            await self.cache.set_user(user_id, data)

            # Trigger background sync
            await self.sync_to_secondary(user_id)
```

### API Gateway Patterns

**Language-Agnostic API Gateway:**
```yaml
# API Gateway configuration
routes:
  - path: /api/v1/users/*
    service: user-service
    methods: [GET, POST, PUT, DELETE]
    auth: required

  - path: /api/v1/payments/*
    service: payment-service
    methods: [GET, POST]
    auth: required
    rate_limit: 100/minute

  - path: /api/v1/notifications/*
    service: notification-service
    methods: [POST]
    auth: required
    async: true
```

### Service Communication

**Event-Driven Architecture:**
```python
# Event publisher (Python)
class EventPublisher:
    def __init__(self, message_broker):
        self.broker = message_broker

    def publish_user_event(self, event_type, user_data):
        event = {
            'type': event_type,
            'data': user_data,
            'timestamp': datetime.utcnow().isoformat(),
            'source': 'user-service'
        }
        self.broker.publish('user.events', event)
```

```php
// Event subscriber (PHP)
class UserEventHandler {
    public function handleUserCreated(Event $event): void {
        $userData = $event->getData();

        // Send welcome email
        $this->emailService->sendWelcomeEmail($userData);

        // Update search index
        $this->searchService->indexUser($userData);

        // Create initial profile
        $this->profileService->createProfile($userData);
    }
}
```

## Debugging and Troubleshooting

### Cross-Language Debugging

**Correlation IDs:**
```python
# Python - Add correlation ID
import correlation_id
correlation_id.set_id(request.headers.get('X-Correlation-ID'))

logger.info("Processing user request",
           user_id=user_id,
           correlation_id=correlation_id.get_id())
```

```php
// PHP - Use correlation ID
$correlationId = $request->getHeader('X-Correlation-ID') ?? uniqid();
$this->logger->info('Processing user request', [
    'user_id' => $userId,
    'correlation_id' => $correlationId
]);
```

### Performance Monitoring

**Universal Metrics:**
```yaml
# Metrics collection
metrics:
  response_time:
    type: histogram
    buckets: [10ms, 50ms, 100ms, 500ms, 1s, 5s]

  error_rate:
    type: counter
    labels: [service, endpoint, error_type]

  active_users:
    type: gauge
    description: "Number of active users"

  database_connections:
    type: gauge
    description: "Active database connections"
```

## Migration Strategies

### Language Migration

**Strangler Fig Pattern:**
```
┌─────────────────┐    ┌─────────────────┐
│   Legacy App    │    │   New Service   │
│                 │    │                 │
│ • Existing      │────▶│ • New features  │
│ • Stable        │    │ • Modern stack   │
│ • Bug fixes     │    │ • Incremental   │
└─────────────────┘    └─────────────────┘
        │                       │
        └───────────┬───────────┘
                    │
            ┌─────────────────┐
            │   Proxy/Router  │
            │                 │
            │ • Route rules   │
            │ • Feature flag │
            └─────────────────┘
```

### Database Migration

**Zero-Downtime Migration:**
```python
# Phase 1: Dual write
async def create_user(user_data):
    # Write to old database
    await old_db.create_user(user_data)

    # Write to new database
    await new_db.create_user(user_data)

# Phase 2: Read from new, fallback to old
async def get_user(user_id):
    user = await new_db.get_user(user_id)
    if not user:
        user = await old_db.get_user(user_id)
    return user

# Phase 3: Read from new only
async def get_user(user_id):
    return await new_db.get_user(user_id)
```

## Team Collaboration

### Documentation Standards

**API Documentation:**
```markdown
# User API Endpoints

## Create User
`POST /api/v1/users`

### Request Body
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "preferences": {
    "language": "en",
    "timezone": "UTC"
  }
}
```

### Response
```json
{
  "id": 12345,
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Error Responses
- `400 Bad Request` - Invalid input data
- `409 Conflict` - Email already exists
- `500 Internal Server Error` - Server error
```

### Code Review Guidelines

**Cross-Language Review Checklist:**
- [ ] API contracts are followed
- [ ] Error handling is consistent
- [ ] Security best practices are applied
- [ ] Database transactions are properly handled
- [ ] Logging is adequate and structured
- [ ] Tests cover critical paths
- [ ] Documentation is updated
- [ ] Performance impact is considered

## Quick Reference

### Common Patterns by Use Case

| Use Case | Pattern | Implementation |
|----------|---------|----------------|
| **Multi-language API** | API Gateway | Kong, Traefik, or custom |
| **Data consistency** | Saga Pattern | Event-driven transactions |
| **Authentication** | JWT + Refresh | Language-agnostic tokens |
| **Real-time updates** | WebSocket | SignalR, Socket.io |
| **File uploads** | Object Storage | S3, MinIO, or local |
| **Background jobs** | Message Queue | RabbitMQ, Redis, SQS |
| **Caching** | Multi-layer | CDN + Redis + Application |
| **Monitoring** | Structured logs | ELK stack, Prometheus |

### Technology Stack Matrix

| Component | Python | PHP | Node.js | Go | Java |
|-----------|---------|-----|----------|-----|------|
| **Web Framework** | Django/FastAPI | Laravel/Symfony | Express/Fastify | Gin/Echo | Spring |
| **Database ORM** | SQLAlchemy | Eloquent/Doctrine | Sequelize/TypeORM | GORM | Hibernate |
| **HTTP Client** | requests/aiohttp | Guzzle | axios/needle | net/http | OkHttp |
| **Queue Worker** | Celery | Laravel Queue | Bull Queue | NATS | RabbitMQ |
| **Testing** | pytest | PHPUnit | Jest/Mocha | Go test | JUnit |

## Getting Help

When working with mixed stacks:

1. **Start with architecture** - Design clear boundaries between languages
2. **Use contracts** - Define clear APIs and data formats
3. **Implement gradually** - Migrate piece by piece, not all at once
4. **Monitor everything** - Track performance across all services
5. **Document patterns** - Create shared standards and conventions

For specific technology questions, refer to language-specific documentation and best practices for that ecosystem.