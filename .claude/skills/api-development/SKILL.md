# API Development Skill

**Purpose:** Modern API development patterns, RESTful design, GraphQL implementation, and backend service architecture.

## When to Use This Skill

- Designing and building RESTful APIs
- Implementing GraphQL schemas and resolvers
- Creating microservices and distributed systems
- Setting up API documentation and testing
- Implementing authentication and authorization
- API performance optimization and scaling

## API Architectures

### RESTful APIs
- **HTTP Methods**: Proper use of GET, POST, PUT, PATCH, DELETE
- **Resource Design**: Nouns over verbs, consistent URL patterns
- **Status Codes**: Appropriate HTTP status code usage
- **Versioning**: API versioning strategies and best practices

### GraphQL APIs
- **Schema Design**: Type definitions, queries, mutations
- **Resolver Patterns**: Efficient data fetching and relationships
- **Federation**: Distributed GraphQL architecture
- **Subscriptions**: Real-time data updates

### Microservices
- **Service Boundaries**: Domain-driven design principles
- **Inter-Service Communication**: REST, gRPC, message queues
- **Data Management**: Database per service pattern
- **Service Discovery**: Dynamic service registration

## Frameworks and Technologies

### Backend Frameworks
- **FastAPI**: Modern Python web framework with automatic docs
- **Express.js**: Minimalist Node.js framework
- **NestJS**: Opinionated Node.js framework with TypeScript
- **Django**: Full-featured Python web framework
- **Spring Boot**: Enterprise Java framework

### Database Technologies
- **SQL Databases**: PostgreSQL, MySQL, relational design
- **NoSQL Databases**: MongoDB, DynamoDB, document stores
- **Caching**: Redis, Memcached for performance
- **ORM/ODM**: SQLAlchemy, Prisma, Mongoose

### API Gateway and Management
- **API Gateway**: Request routing, rate limiting, authentication
- **Load Balancing**: Traffic distribution and high availability
- **Rate Limiting**: Preventing abuse and ensuring fair usage
- **CORS Configuration**: Cross-origin resource sharing setup

## API Design Patterns

### RESTful Design Principles
```python
# FastAPI example with proper REST patterns
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI()

class UserCreate(BaseModel):
    name: str
    email: str
    age: Optional[int] = None

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

@app.post("/users", response_model=UserResponse)
async def create_user(user: UserCreate):
    # Create user logic
    pass

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    # Get user logic
    pass

@app.get("/users", response_model=List[UserResponse])
async def list_users(skip: int = 0, limit: int = 100):
    # List users with pagination
    pass
```

### GraphQL Schema Design
```graphql
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
}

type Query {
  user(id: ID!): User
  users: [User!]!
  posts: [Post!]!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  createPost(input: CreatePostInput!): Post!
}
```

### Error Handling Patterns
- **Consistent Error Format**: Standardized error response structure
- **HTTP Status Codes**: Appropriate status code selection
- **Validation Errors**: Detailed field-level validation feedback
- **Global Exception Handlers**: Centralized error processing

## Authentication and Authorization

### Authentication Strategies
- **JWT (JSON Web Tokens)**: Stateless authentication
- **OAuth 2.0**: Third-party authentication integration
- **API Keys**: Simple key-based authentication
- **Session-Based Authentication**: Server-side session management

### Authorization Patterns
- **Role-Based Access Control (RBAC)**: Permission management
- **Attribute-Based Access Control (ABAC)**: Fine-grained permissions
- **Resource-Based Policies**: AWS-style policy evaluation
- **Middleware Integration**: Framework-specific authorization

### Security Best Practices
- **Input Validation**: Prevent injection attacks
- **Rate Limiting**: Prevent abuse and DDoS
- **HTTPS Only**: Encrypted communication
- **CORS Configuration**: Proper cross-origin setup

## Documentation and Testing

### API Documentation
- **OpenAPI/Swagger**: REST API specification
- **GraphQL Schema**: Self-documenting schema
- **API Reference**: Interactive documentation
- **Usage Examples**: Code samples and tutorials

### Testing Strategies
- **Unit Tests**: Individual endpoint testing
- **Integration Tests**: Multi-component testing
- **Contract Testing**: API contract verification
- **Load Testing**: Performance and scalability testing

### Testing Tools
- **pytest**: Python testing framework
- **Jest**: JavaScript testing framework
- **Postman/Newman**: API testing automation
- **Artillery**: Load testing framework

## Performance and Scaling

### Optimization Techniques
- **Database Indexing**: Query performance optimization
- **Caching Strategies**: Redis, application-level caching
- **Connection Pooling**: Database connection management
- **Async Processing**: Background jobs and queues

### Monitoring and Observability
- **API Metrics**: Response times, error rates, throughput
- **Health Checks**: Service health monitoring
- **Distributed Tracing**: Request flow across services
- **Log Aggregation**: Centralized logging and analysis

### Scaling Patterns
- **Horizontal Scaling**: Load balancing and clustering
- **Database Scaling**: Read replicas, sharding
- **Caching Layers**: Multi-level caching strategy
- **CDN Integration**: Content delivery networks

## Development Workflow

### Project Structure
```
api-project/
├── app/
│   ├── api/           # API routes and endpoints
│   ├── models/        # Database models
│   ├── schemas/       # Pydantic models/validation
│   ├── services/      # Business logic
│   └── core/          # Configuration and utilities
├── tests/             # Test suites
├── migrations/        # Database migrations
└── docs/              # API documentation
```

### Development Practices
- **API-First Design**: Design API before implementation
- **Version Control**: Git workflows and branching strategies
- **CI/CD**: Automated testing and deployment
- **Code Review**: Quality assurance and knowledge sharing

### Environment Management
- **Configuration Management**: Environment-specific settings
- **Secrets Management**: Secure credential handling
- **Database Migrations**: Schema versioning and updates
- **Docker**: Containerized development and deployment

## Resources and Templates

### API Templates
- `fastapi-template.md` - FastAPI project structure
- `express-api-template.md` - Express.js setup
- `graphql-schema-template.md` - GraphQL schema design
- `microservice-template.md` - Microservice architecture

### Documentation Templates
- `openapi-specification.md` - API documentation structure
- `postman-collection.md` - API testing collection
- `api-changelog.md` - Version change documentation
- `integration-guide.md` - Third-party integration guide

### Testing Templates
- `api-test-suite.md` - Comprehensive API testing
- `load-testing-template.md` - Performance testing setup
- `contract-testing.md` - API contract verification
- `security-testing.md` - Security testing procedures

## Quick Reference

This skill provides immediate guidance for:
- **API Design** with REST and GraphQL best practices
- **Authentication** and authorization implementation
- **Performance Optimization** techniques and monitoring
- **Documentation** and testing strategies
- **Security** implementation and best practices
- **Scaling** strategies for high-traffic APIs

Use this skill to build robust, secure, and scalable APIs that provide excellent developer experience and meet modern performance standards.