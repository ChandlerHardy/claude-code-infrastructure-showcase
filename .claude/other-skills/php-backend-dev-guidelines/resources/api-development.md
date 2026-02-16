# API Development Guide

## REST API Endpoint Development

### Standard Endpoint Template

```php
<?php
// www/api/feature/action.php

// Bootstrap: include required dependencies
require_once __DIR__ . '/../../../phplib/local/bootstrap.php';

// Enable error reporting (remove in production)
error_reporting(E_ALL);
ini_set('display_errors', '1');

// CORS headers (if needed)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Set content type
header('Content-Type: application/json');

// Authentication check
session_start();
if (!isset($_SESSION['user_id'])) {
    ApiHelper::jsonError('Unauthorized', 401);
}

// Get request method and data
$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

try {
    switch ($method) {
        case 'GET':
            // Handle GET request
            $id = $_GET['id'] ?? null;
            if (!$id) {
                ApiHelper::jsonError('ID parameter required', 400);
            }

            $result = getResource($id);
            ApiHelper::jsonResponse(['data' => $result]);
            break;

        case 'POST':
            // Handle POST request
            if (!validateInput($input)) {
                ApiHelper::jsonError('Invalid input', 400);
            }

            $result = createResource($input);
            ApiHelper::jsonResponse([
                'data' => $result,
                'message' => 'Resource created successfully'
            ], 201);
            break;

        case 'PUT':
            // Handle PUT request
            $id = $_GET['id'] ?? null;
            if (!$id) {
                ApiHelper::jsonError('ID parameter required', 400);
            }

            $result = updateResource($id, $input);
            ApiHelper::jsonResponse([
                'data' => $result,
                'message' => 'Resource updated successfully'
            ]);
            break;

        case 'DELETE':
            // Handle DELETE request
            $id = $_GET['id'] ?? null;
            if (!$id) {
                ApiHelper::jsonError('ID parameter required', 400);
            }

            deleteResource($id);
            ApiHelper::jsonResponse([
                'message' => 'Resource deleted successfully'
            ]);
            break;

        default:
            ApiHelper::jsonError('Method not allowed', 405);
    }
} catch (Exception $e) {
    error_log("API Error in " . __FILE__ . ": " . $e->getMessage());
    ApiHelper::jsonError('Internal server error', 500);
}

// Helper functions
function validateInput($input) {
    // Add validation logic
    return true;
}

function getResource($id) {
    global $mongo;
    // Implementation
}

function createResource($input) {
    global $mongo;
    // Implementation
}

function updateResource($id, $input) {
    global $mongo;
    // Implementation
}

function deleteResource($id) {
    global $mongo;
    // Implementation
}
```

## Input Validation Patterns

### Required Field Validation

```php
function validateRequired(array $input, array $requiredFields): array
{
    $errors = [];

    foreach ($requiredFields as $field) {
        if (!isset($input[$field]) || empty($input[$field])) {
            $errors[] = "$field is required";
        }
    }

    return $errors;
}

// Usage
$errors = validateRequired($input, ['name', 'email', 'phone']);
if (!empty($errors)) {
    ApiHelper::jsonError(implode(', ', $errors), 400);
}
```

### Type Validation

```php
function validateTypes(array $input, array $schema): array
{
    $errors = [];

    foreach ($schema as $field => $type) {
        if (!isset($input[$field])) {
            continue;
        }

        $value = $input[$field];

        switch ($type) {
            case 'email':
                if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $errors[] = "$field must be a valid email";
                }
                break;

            case 'int':
                if (!is_numeric($value) || (int)$value != $value) {
                    $errors[] = "$field must be an integer";
                }
                break;

            case 'float':
                if (!is_numeric($value)) {
                    $errors[] = "$field must be a number";
                }
                break;

            case 'string':
                if (!is_string($value)) {
                    $errors[] = "$field must be a string";
                }
                break;

            case 'array':
                if (!is_array($value)) {
                    $errors[] = "$field must be an array";
                }
                break;
        }
    }

    return $errors;
}

// Usage
$schema = [
    'name' => 'string',
    'email' => 'email',
    'age' => 'int',
    'weight' => 'float'
];

$errors = validateTypes($input, $schema);
if (!empty($errors)) {
    ApiHelper::jsonError(implode(', ', $errors), 400);
}
```

### Custom Validation Rules

```php
function validateCustom(array $input, array $rules): array
{
    $errors = [];

    foreach ($rules as $field => $rule) {
        if (!isset($input[$field])) {
            continue;
        }

        $value = $input[$field];

        // Min length
        if (isset($rule['min_length']) && strlen($value) < $rule['min_length']) {
            $errors[] = "$field must be at least {$rule['min_length']} characters";
        }

        // Max length
        if (isset($rule['max_length']) && strlen($value) > $rule['max_length']) {
            $errors[] = "$field must be at most {$rule['max_length']} characters";
        }

        // Min value
        if (isset($rule['min']) && $value < $rule['min']) {
            $errors[] = "$field must be at least {$rule['min']}";
        }

        // Max value
        if (isset($rule['max']) && $value > $rule['max']) {
            $errors[] = "$field must be at most {$rule['max']}";
        }

        // Regex pattern
        if (isset($rule['pattern']) && !preg_match($rule['pattern'], $value)) {
            $errors[] = "$field has invalid format";
        }

        // In array
        if (isset($rule['in']) && !in_array($value, $rule['in'])) {
            $errors[] = "$field must be one of: " . implode(', ', $rule['in']);
        }
    }

    return $errors;
}

// Usage
$rules = [
    'name' => ['min_length' => 2, 'max_length' => 100],
    'age' => ['min' => 0, 'max' => 150],
    'status' => ['in' => ['active', 'inactive', 'pending']],
    'phone' => ['pattern' => '/^\d{10}$/']
];

$errors = validateCustom($input, $rules);
if (!empty($errors)) {
    ApiHelper::jsonError(implode(', ', $errors), 400);
}
```

## Response Formatting

### Standard Response Format

```php
// Success response with data
ApiHelper::jsonResponse([
    'success' => true,
    'data' => $data,
    'message' => 'Operation completed successfully'
], 200);

// Success response without data
ApiHelper::jsonResponse([
    'success' => true,
    'message' => 'Operation completed successfully'
], 200);

// Error response
ApiHelper::jsonError('Error message', 400);

// Detailed error response
http_response_code(400);
echo json_encode([
    'success' => false,
    'error' => [
        'code' => 'VALIDATION_ERROR',
        'message' => 'Validation failed',
        'details' => $validationErrors
    ]
]);
exit;
```

### Pagination Response

```php
function paginatedResponse($items, $page, $perPage, $total)
{
    return [
        'success' => true,
        'data' => $items,
        'pagination' => [
            'page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'total_pages' => ceil($total / $perPage)
        ]
    ];
}

// Usage
$page = $_GET['page'] ?? 1;
$perPage = $_GET['per_page'] ?? 20;
$skip = ($page - 1) * $perPage;

$total = $collection->count($filter);
$items = $collection->find($filter, [
    'skip' => $skip,
    'limit' => $perPage
])->toArray();

ApiHelper::jsonResponse(paginatedResponse($items, $page, $perPage, $total));
```

## Authentication & Authorization

### Session-Based Authentication

```php
function requireAuth()
{
    session_start();
    if (!isset($_SESSION['user_id'])) {
        ApiHelper::jsonError('Unauthorized', 401);
    }
    return $_SESSION['user_id'];
}

function requireRole($role)
{
    $userId = requireAuth();

    global $mongo;
    $user = $mongo->users->findOne([
        '_id' => new MongoDB\BSON\ObjectId($userId)
    ]);

    if (!$user || $user['role'] !== $role) {
        ApiHelper::jsonError('Forbidden', 403);
    }

    return $user;
}

// Usage
$userId = requireAuth();
// or
$user = requireRole('admin');
```

### Permission Checks

```php
function hasPermission($userId, $permission)
{
    global $mongo;

    $user = $mongo->users->findOne([
        '_id' => new MongoDB\BSON\ObjectId($userId)
    ]);

    if (!$user) {
        return false;
    }

    // Check if user has permission
    return in_array($permission, $user['permissions'] ?? []);
}

// Usage
$userId = requireAuth();
if (!hasPermission($userId, 'edit_rations')) {
    ApiHelper::jsonError('Insufficient permissions', 403);
}
```

## Error Handling Best Practices

### Try-Catch Blocks

```php
try {
    // Risky operation
    $result = performDatabaseOperation();
    ApiHelper::jsonResponse(['data' => $result]);
} catch (MongoDB\Driver\Exception\Exception $e) {
    error_log("MongoDB error: " . $e->getMessage());
    ApiHelper::jsonError('Database error occurred', 500);
} catch (Exception $e) {
    error_log("Unexpected error: " . $e->getMessage());
    ApiHelper::jsonError('An unexpected error occurred', 500);
}
```

### Logging Errors with Context

```php
function logError($message, $context = [])
{
    $logMessage = $message;

    if (!empty($context)) {
        $logMessage .= " | Context: " . json_encode($context);
    }

    error_log($logMessage);
}

// Usage
try {
    $result = updateDocument($id, $data);
} catch (Exception $e) {
    logError("Failed to update document", [
        'id' => $id,
        'data' => $data,
        'error' => $e->getMessage()
    ]);
    ApiHelper::jsonError('Update failed', 500);
}
```

## Rate Limiting (Optional)

```php
function checkRateLimit($userId, $endpoint, $maxRequests = 100, $window = 3600)
{
    global $mongo;

    $key = "rate_limit:{$userId}:{$endpoint}";
    $now = time();

    $rateLimitDoc = $mongo->rate_limits->findOne(['key' => $key]);

    if (!$rateLimitDoc) {
        // First request
        $mongo->rate_limits->insertOne([
            'key' => $key,
            'count' => 1,
            'window_start' => $now
        ]);
        return true;
    }

    $windowStart = $rateLimitDoc['window_start'];
    $count = $rateLimitDoc['count'];

    if ($now - $windowStart > $window) {
        // New window
        $mongo->rate_limits->updateOne(
            ['key' => $key],
            ['$set' => ['count' => 1, 'window_start' => $now]]
        );
        return true;
    }

    if ($count >= $maxRequests) {
        return false;
    }

    $mongo->rate_limits->updateOne(
        ['key' => $key],
        ['$inc' => ['count' => 1]]
    );

    return true;
}

// Usage
$userId = requireAuth();
if (!checkRateLimit($userId, 'api/rations/calculate')) {
    ApiHelper::jsonError('Rate limit exceeded', 429);
}
```

## Common HTTP Status Codes

```
200 OK                  - Successful GET, PUT, PATCH
201 Created             - Successful POST
204 No Content          - Successful DELETE
400 Bad Request         - Invalid input
401 Unauthorized        - Authentication required
403 Forbidden           - Insufficient permissions
404 Not Found           - Resource not found
409 Conflict            - Resource already exists
422 Unprocessable       - Validation failed
429 Too Many Requests   - Rate limit exceeded
500 Internal Error      - Server error
503 Service Unavailable - Server temporarily unavailable
```
