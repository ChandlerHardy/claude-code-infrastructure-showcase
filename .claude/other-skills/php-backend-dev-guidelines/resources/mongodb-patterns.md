# MongoDB Patterns & Best Practices

## Connection & Collection Access

### Global MongoDB Connection

```php
// Access global MongoDB instance
global $mongo;

// Access collection
$collection = $mongo->collection_name;

// Common collections in this project
$users = $mongo->users;
$pens = $mongo->pens;
$rations = $mongo->rations;
$groups = $mongo->groups;
```

## CRUD Operations

### Create (Insert) Operations

```php
// Insert single document
$result = $collection->insertOne([
    'name' => 'Example',
    'value' => 123,
    'created_at' => new MongoDB\BSON\UTCDateTime(),
    'metadata' => [
        'source' => 'api',
        'version' => '1.0'
    ]
]);

$insertedId = $result->getInsertedId();

// Insert multiple documents
$result = $collection->insertMany([
    ['name' => 'Item 1', 'value' => 1],
    ['name' => 'Item 2', 'value' => 2],
    ['name' => 'Item 3', 'value' => 3]
]);

$insertedIds = $result->getInsertedIds();
```

### Read (Find) Operations

```php
// Find one document by ID
$doc = $collection->findOne([
    '_id' => new MongoDB\BSON\ObjectId($id)
]);

// Find one with specific criteria
$doc = $collection->findOne([
    'email' => $email,
    'status' => 'active'
]);

// Find multiple documents
$cursor = $collection->find([
    'category' => 'beef',
    'weight' => ['$gt' => 500]
]);

foreach ($cursor as $doc) {
    // Process each document
    $name = $doc['name'];
}

// Find with projection (select specific fields)
$cursor = $collection->find(
    ['category' => 'beef'],
    [
        'projection' => [
            'name' => 1,
            'weight' => 1,
            'category' => 1,
            '_id' => 0  // Exclude _id
        ]
    ]
);

// Find with sorting
$cursor = $collection->find(
    ['category' => 'beef'],
    [
        'sort' => ['created_at' => -1],  // Descending
        'limit' => 10
    ]
);

// Find with pagination
$page = 1;
$perPage = 20;
$skip = ($page - 1) * $perPage;

$cursor = $collection->find(
    $filter,
    [
        'skip' => $skip,
        'limit' => $perPage,
        'sort' => ['created_at' => -1]
    ]
);

// Count documents
$total = $collection->countDocuments($filter);
```

### Update Operations

```php
// Update one document
$result = $collection->updateOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['$set' => [
        'name' => 'New Name',
        'updated_at' => new MongoDB\BSON\UTCDateTime()
    ]]
);

$modifiedCount = $result->getModifiedCount();

// Update multiple documents
$result = $collection->updateMany(
    ['status' => 'pending'],
    ['$set' => ['status' => 'processed']]
);

// Increment numeric field
$collection->updateOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['$inc' => ['view_count' => 1]]
);

// Push to array
$collection->updateOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['$push' => ['tags' => 'new-tag']]
);

// Pull from array
$collection->updateOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['$pull' => ['tags' => 'old-tag']]
);

// Add to set (only if not exists)
$collection->updateOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['$addToSet' => ['tags' => 'unique-tag']]
);

// Upsert (update or insert)
$result = $collection->updateOne(
    ['unique_key' => $uniqueValue],
    ['$set' => $data],
    ['upsert' => true]
);
```

### Delete Operations

```php
// Delete one document
$result = $collection->deleteOne([
    '_id' => new MongoDB\BSON\ObjectId($id)
]);

$deletedCount = $result->getDeletedCount();

// Delete multiple documents
$result = $collection->deleteMany([
    'status' => 'archived',
    'created_at' => ['$lt' => new MongoDB\BSON\UTCDateTime(strtotime('-1 year') * 1000)]
]);
```

## Query Operators

### Comparison Operators

```php
// Greater than
$collection->find(['weight' => ['$gt' => 500]]);

// Greater than or equal
$collection->find(['weight' => ['$gte' => 500]]);

// Less than
$collection->find(['weight' => ['$lt' => 1000]]);

// Less than or equal
$collection->find(['weight' => ['$lte' => 1000]]);

// Not equal
$collection->find(['status' => ['$ne' => 'deleted']]);

// In array
$collection->find(['category' => ['$in' => ['beef', 'dairy']]]);

// Not in array
$collection->find(['category' => ['$nin' => ['archived', 'deleted']]]);

// Range query
$collection->find([
    'weight' => [
        '$gte' => 500,
        '$lte' => 1000
    ]
]);
```

### Logical Operators

```php
// AND (implicit)
$collection->find([
    'category' => 'beef',
    'weight' => ['$gt' => 500]
]);

// OR
$collection->find([
    '$or' => [
        ['category' => 'beef'],
        ['category' => 'dairy']
    ]
]);

// AND with OR
$collection->find([
    'status' => 'active',
    '$or' => [
        ['type' => 'premium'],
        ['weight' => ['$gt' => 1000]]
    ]
]);

// NOT
$collection->find([
    'weight' => ['$not' => ['$gt' => 1000]]
]);

// NOR
$collection->find([
    '$nor' => [
        ['status' => 'deleted'],
        ['archived' => true]
    ]
]);
```

### Array Operators

```php
// Array contains value
$collection->find(['tags' => 'organic']);

// Array contains all values
$collection->find(['tags' => ['$all' => ['organic', 'local']]]);

// Array size
$collection->find(['tags' => ['$size' => 3]]);

// Element match
$collection->find([
    'items' => [
        '$elemMatch' => [
            'quantity' => ['$gt' => 10],
            'price' => ['$lt' => 100]
        ]
    ]
]);
```

### Text Search

```php
// Text search (requires text index)
$collection->find([
    '$text' => ['$search' => 'beef cattle feed']
]);

// Text search with relevance score
$cursor = $collection->find(
    ['$text' => ['$search' => 'beef cattle']],
    [
        'projection' => ['score' => ['$meta' => 'textScore']],
        'sort' => ['score' => ['$meta' => 'textScore']]
    ]
);
```

## Date & Time Handling

### Working with UTCDateTime

```php
// Current timestamp
$now = new MongoDB\BSON\UTCDateTime();

// Specific timestamp
$timestamp = strtotime('2024-01-01 00:00:00');
$date = new MongoDB\BSON\UTCDateTime($timestamp * 1000); // Convert to milliseconds

// Query by date range
$startDate = new MongoDB\BSON\UTCDateTime(strtotime('2024-01-01') * 1000);
$endDate = new MongoDB\BSON\UTCDateTime(strtotime('2024-12-31') * 1000);

$collection->find([
    'created_at' => [
        '$gte' => $startDate,
        '$lte' => $endDate
    ]
]);

// Convert UTCDateTime to PHP DateTime
$mongoDate = $doc['created_at'];
$phpDateTime = $mongoDate->toDateTime();
$formatted = $phpDateTime->format('Y-m-d H:i:s');
```

## Aggregation Pipeline

### Basic Aggregation

```php
// Simple aggregation
$pipeline = [
    ['$match' => ['category' => 'beef']],
    ['$group' => [
        '_id' => '$status',
        'count' => ['$sum' => 1],
        'total_weight' => ['$sum' => '$weight']
    ]],
    ['$sort' => ['count' => -1]]
];

$cursor = $collection->aggregate($pipeline);
foreach ($cursor as $result) {
    // Process aggregated results
}
```

### Common Aggregation Stages

```php
// Match (filter)
['$match' => ['category' => 'beef']]

// Group
['$group' => [
    '_id' => '$category',
    'count' => ['$sum' => 1],
    'avg_weight' => ['$avg' => '$weight'],
    'max_weight' => ['$max' => '$weight'],
    'min_weight' => ['$min' => '$weight']
]]

// Project (select/transform fields)
['$project' => [
    'name' => 1,
    'weight_kg' => ['$divide' => ['$weight', 1000]],
    'full_name' => ['$concat' => ['$first_name', ' ', '$last_name']]
]]

// Sort
['$sort' => ['created_at' => -1]]

// Limit
['$limit' => 10]

// Skip
['$skip' => 20]

// Lookup (join)
['$lookup' => [
    'from' => 'users',
    'localField' => 'user_id',
    'foreignField' => '_id',
    'as' => 'user_data'
]]

// Unwind (flatten array)
['$unwind' => '$tags']

// Add fields
['$addFields' => [
    'calculated_field' => ['$multiply' => ['$price', '$quantity']]
]]
```

### Complex Aggregation Example

```php
$pipeline = [
    // Stage 1: Filter documents
    ['$match' => [
        'status' => 'active',
        'created_at' => ['$gte' => $startDate]
    ]],

    // Stage 2: Join with users
    ['$lookup' => [
        'from' => 'users',
        'localField' => 'user_id',
        'foreignField' => '_id',
        'as' => 'user'
    ]],

    // Stage 3: Unwind user array
    ['$unwind' => '$user'],

    // Stage 4: Calculate derived fields
    ['$addFields' => [
        'total_value' => ['$multiply' => ['$price', '$quantity']],
        'user_name' => '$user.name'
    ]],

    // Stage 5: Group and aggregate
    ['$group' => [
        '_id' => '$category',
        'total_items' => ['$sum' => 1],
        'total_value' => ['$sum' => '$total_value'],
        'avg_value' => ['$avg' => '$total_value']
    ]],

    // Stage 6: Sort results
    ['$sort' => ['total_value' => -1]],

    // Stage 7: Limit results
    ['$limit' => 10]
];

$results = $collection->aggregate($pipeline)->toArray();
```

## Indexes

### Creating Indexes

```php
// Single field index
$collection->createIndex(['email' => 1]); // Ascending
$collection->createIndex(['created_at' => -1]); // Descending

// Compound index
$collection->createIndex([
    'category' => 1,
    'status' => 1,
    'created_at' => -1
]);

// Unique index
$collection->createIndex(
    ['email' => 1],
    ['unique' => true]
);

// Text index for search
$collection->createIndex([
    'name' => 'text',
    'description' => 'text'
]);

// Sparse index (only index documents with the field)
$collection->createIndex(
    ['optional_field' => 1],
    ['sparse' => true]
);

// TTL index (auto-delete after time)
$collection->createIndex(
    ['expires_at' => 1],
    ['expireAfterSeconds' => 0]
);
```

### Listing Indexes

```php
$indexes = $collection->listIndexes();
foreach ($indexes as $index) {
    print_r($index);
}
```

## Error Handling

### MongoDB Exception Handling

```php
try {
    $result = $collection->insertOne($document);
} catch (MongoDB\Driver\Exception\BulkWriteException $e) {
    // Handle duplicate key or other write errors
    $writeErrors = $e->getWriteResult()->getWriteErrors();
    foreach ($writeErrors as $error) {
        if ($error->getCode() === 11000) {
            // Duplicate key error
            error_log("Duplicate key: " . $error->getMessage());
        }
    }
} catch (MongoDB\Driver\Exception\ConnectionException $e) {
    // Handle connection errors
    error_log("MongoDB connection error: " . $e->getMessage());
} catch (MongoDB\Driver\Exception\Exception $e) {
    // Handle other MongoDB errors
    error_log("MongoDB error: " . $e->getMessage());
}
```

## Best Practices

### 1. Always Use ObjectId for IDs

```php
// CORRECT
$doc = $collection->findOne([
    '_id' => new MongoDB\BSON\ObjectId($id)
]);

// WRONG
$doc = $collection->findOne(['_id' => $id]);
```

### 2. Validate ObjectId Before Use

```php
function isValidObjectId($id)
{
    return preg_match('/^[a-f\d]{24}$/i', $id);
}

if (!isValidObjectId($id)) {
    ApiHelper::jsonError('Invalid ID format', 400);
}

$doc = $collection->findOne([
    '_id' => new MongoDB\BSON\ObjectId($id)
]);
```

### 3. Use Projections to Limit Returned Data

```php
// Only get needed fields
$doc = $collection->findOne(
    ['_id' => new MongoDB\BSON\ObjectId($id)],
    ['projection' => ['name' => 1, 'email' => 1]]
);
```

### 4. Use Indexes for Performance

```php
// Create indexes for frequently queried fields
$collection->createIndex(['user_id' => 1]);
$collection->createIndex(['email' => 1], ['unique' => true]);
$collection->createIndex(['status' => 1, 'created_at' => -1]);
```

### 5. Handle Null/Missing Fields

```php
// Check if field exists and is not null
$collection->find([
    'optional_field' => ['$exists' => true, '$ne' => null]
]);

// Find documents where field doesn't exist
$collection->find([
    'optional_field' => ['$exists' => false]
]);
```

### 6. Use Batch Operations for Multiple Updates

```php
$bulk = $collection->createBulkWrite();

foreach ($items as $item) {
    $bulk->updateOne(
        ['_id' => new MongoDB\BSON\ObjectId($item['id'])],
        ['$set' => ['status' => 'processed']]
    );
}

$result = $bulk->execute();
```

## Performance Tips

1. **Create appropriate indexes** for queries
2. **Use projections** to reduce data transfer
3. **Limit query results** when possible
4. **Use aggregation pipeline** for complex queries instead of post-processing in PHP
5. **Cache frequently accessed data** in application memory or Redis
6. **Avoid `$where` operator** (uses JavaScript evaluation, slow)
7. **Use covered queries** (queries that can be satisfied using indexes only)
