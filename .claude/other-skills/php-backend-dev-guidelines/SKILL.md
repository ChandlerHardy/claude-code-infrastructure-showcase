---
name: php-backend-dev-guidelines
description: Comprehensive PHP backend development guidelines for Performance Beef web application
version: 1.0.0
---

# PHP Backend Development Guidelines

This skill provides comprehensive guidance for developing backend features in the Performance Beef PHP application.

## When to Use This Skill

Use this skill when:
- Creating or modifying PHP files in `/phplib/` or `/www/`
- Implementing API endpoints in `/www/api/`
- Working with MongoDB models and data access
- Adding new business logic or server-side features
- Debugging PHP backend issues
- Writing or modifying PHPUnit tests

## Project Architecture Overview

**Technology Stack:**
- PHP (primary backend language)
- MongoDB (primary database)
- PHPUnit (testing framework)
- Traditional PHP architecture (no framework like Laravel/Symfony)

**Directory Structure:**
```
phplib/local/          # Core business logic and models
www/                   # Web-accessible files
  ├── api/            # REST API endpoints
  ├── account/        # Account management
  ├── admin/          # Admin interfaces
  ├── analytics/      # Analytics features
  ├── delivery/       # Delivery management
  ├── health/         # Health tracking
  ├── inventory/      # Inventory management
  ├── invoices/       # Invoice handling
  ├── pens/           # Pen management
  ├── rations/        # Ration calculations
  └── reports/        # Reporting features
test/phpunit/         # PHPUnit tests
```

## Core Development Principles

### 1. **File Organization**

**Library Files (phplib/local/):**
- Place reusable business logic classes here
- One class per file
- Use descriptive class names (e.g., `RationIngredientMongo.php`, `UserSettings.php`)

**Web Files (www/):**
- Organize by feature/module
- API endpoints go in `www/api/`
- Each feature should have its own subdirectory

### 2. **Code Style & Conventions**

**Class Names:**
- Use PascalCase for class names
- Descriptive names that indicate purpose
- Example: `class RationIngredientMongo`, `class DeliveryDetails`

**Function Names:**
- Use camelCase for function names
- Descriptive names indicating action
- Example: `getUserSettings()`, `calculateRation()`

**Constants:**
- Use UPPER_SNAKE_CASE
- Define at top of class or in configuration files

### 3. **MongoDB Patterns**

**Collection Access:**
```php
// Use global Mongo connection
global $mongo;
$collection = $mongo->collection_name;
```

**Query Patterns:**
```php
// Find one document
$doc = $collection->findOne(['_id' => new MongoDB\BSON\ObjectId($id)]);

// Find multiple documents
$cursor = $collection->find(['field' => $value]);
foreach ($cursor as $doc) {
    // Process document
}

// Insert document
$result = $collection->insertOne($document);
$insertedId = $result->getInsertedId();

// Update document
$collection->updateOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['$set' => $updates]
);
```

**Error Handling:**
```php
try {
    $result = $collection->insertOne($document);
} catch (MongoDB\Driver\Exception\Exception $e) {
    error_log("MongoDB error: " . $e->getMessage());
    // Handle error appropriately
}
```

### 4. **API Development**

**API Endpoint Structure:**
```php
<?php
// www/api/feature/endpoint.php

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Set JSON response header
header('Content-Type: application/json');

// Handle CORS if needed
header('Access-Control-Allow-Origin: *');

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Handle GET request
        break;
    case 'POST':
        // Handle POST request
        $input = json_decode(file_get_contents('php://input'), true);
        break;
    case 'PUT':
        // Handle PUT request
        break;
    case 'DELETE':
        // Handle DELETE request
        break;
    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        exit;
}

// Return JSON response
http_response_code(200);
echo json_encode(['success' => true, 'data' => $result]);
```

**Response Format:**
```php
// Success response
echo json_encode([
    'success' => true,
    'data' => $data,
    'message' => 'Operation completed successfully'
]);

// Error response
http_response_code(400);
echo json_encode([
    'success' => false,
    'error' => 'Error message',
    'code' => 'ERROR_CODE'
]);
```

### 5. **Security Best Practices**

**Input Validation:**
```php
// Validate required fields
if (!isset($_POST['field']) || empty($_POST['field'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Field is required']);
    exit;
}

// Sanitize input
$cleanValue = filter_var($input, FILTER_SANITIZE_STRING);

// Validate email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    // Invalid email
}
```

**SQL Injection Prevention:**
- Use parameterized queries for any SQL operations
- Never concatenate user input into queries

**Authentication & Authorization:**
```php
// Check if user is authenticated
session_start();
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit;
}

// Check user permissions
if (!hasPermission($_SESSION['user_id'], 'admin')) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden']);
    exit;
}
```

### 6. **Error Handling & Logging**

**Error Logging:**
```php
// Log errors to error log
error_log("Error in feature X: " . $errorMessage);

// Log with context
error_log(sprintf(
    "Error in %s for user %s: %s",
    __FUNCTION__,
    $userId,
    $errorMessage
));
```

**Exception Handling:**
```php
try {
    // Operation that might fail
    $result = performOperation();
} catch (Exception $e) {
    error_log("Exception: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Internal server error',
        'message' => $e->getMessage() // Only in development
    ]);
    exit;
}
```

### 7. **Testing with PHPUnit**

**Test File Location:**
- Place tests in `test/phpunit/`
- Mirror the structure of the code being tested

**Test Class Structure:**
```php
<?php
namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class MyFeatureTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        // Set up test fixtures
    }

    public function testSomething(): void
    {
        // Arrange
        $input = 'test';

        // Act
        $result = myFunction($input);

        // Assert
        $this->assertEquals('expected', $result);
    }

    protected function tearDown(): void
    {
        // Clean up after test
        parent::tearDown();
    }
}
```

**Running Tests:**
```bash
# Run all tests
vendor/bin/phpunit

# Run specific test file
vendor/bin/phpunit test/phpunit/path/to/TestFile.php

# Run with coverage
vendor/bin/phpunit --coverage-html coverage/
```

## Common Patterns in This Codebase

### Pattern 1: Model Classes
```php
class MyModel
{
    private $mongo;
    private $collection;

    public function __construct()
    {
        global $mongo;
        $this->mongo = $mongo;
        $this->collection = $mongo->collection_name;
    }

    public function findById($id)
    {
        return $this->collection->findOne([
            '_id' => new MongoDB\BSON\ObjectId($id)
        ]);
    }

    public function create($data)
    {
        $result = $this->collection->insertOne($data);
        return $result->getInsertedId();
    }
}
```

### Pattern 2: API Helper Functions
```php
// phplib/local/ApiHelper.php style patterns
class ApiHelper
{
    public static function jsonResponse($data, $statusCode = 200)
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }

    public static function jsonError($message, $statusCode = 400)
    {
        self::jsonResponse([
            'success' => false,
            'error' => $message
        ], $statusCode);
    }
}
```

## Development Workflow

1. **Before Writing Code:**
   - Understand the feature requirements
   - Identify which files need to be modified
   - Check if similar functionality exists

2. **Writing Code:**
   - Follow existing patterns in the codebase
   - Add appropriate error handling
   - Log important operations
   - Validate all inputs

3. **Testing:**
   - Write PHPUnit tests for new functionality
   - Test manually through the UI or API
   - Check error conditions

4. **Before Committing:**
   - Run `php -l` on modified files to check syntax
   - Run relevant PHPUnit tests
   - Review changes for security issues

## Resource Files

For detailed guidance on specific topics, see:
- `resources/api-development.md` - Detailed API patterns
- `resources/mongodb-patterns.md` - MongoDB best practices
- `resources/testing-guide.md` - Comprehensive testing guide
- `resources/security-guide.md` - Security considerations

## Quick Reference

**Check PHP Syntax:**
```bash
php -l path/to/file.php
```

**Run PHPUnit Tests:**
```bash
vendor/bin/phpunit test/phpunit/path/to/Test.php
```

**Common Issues:**
- Missing `global $mongo;` declaration
- Incorrect MongoDB ObjectId construction
- Missing input validation
- Improper error handling

## Getting Help

If you encounter issues:
1. Check existing similar code in the codebase
2. Review the resource files in this skill
3. Check error logs for detailed error messages
4. Use the debugging-guide skill for systematic debugging
