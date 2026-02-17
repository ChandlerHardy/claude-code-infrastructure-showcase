---
name: php-backend-dev-guidelines
description: PHP backend development guidelines for Performance Beef web application — covers auth, ApiHelper, Head_event subclasses, save file flows, UserSettings unit conversions, and multi-tenant scoping
version: 2.0.0
---

# PHP Backend Development Guidelines — Performance Beef

This skill provides guidance for developing backend features in the Performance Beef (PB) PHP application.

## When to Use This Skill

Use this skill when:
- Creating or modifying PHP files in `/phplib/local/` or `/www/`
- Working with Head_event subclasses (add, sold, death, move)
- Writing `save_*.php` form submission handlers
- Calling pb-api via `ApiHelper`
- Handling unit conversions with `UserSettings`
- Debugging PHP backend issues

## Directory Structure

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
  ├── overview/       # Overview pages (head events live here)
  ├── pens/           # Pen management
  ├── rations/        # Ration calculations
  └── reports/        # Reporting features
test/phpunit/         # PHPUnit tests
```

## Pattern 1: Core Identity — Auth & IDs

Every PHP file that touches data starts with:

```php
$user_id       = Login::newFromSession()->getFeedyardId();   // int (e.g. 38317)
$feedyard_id   = sprintf('%024x', $user_id);                 // hex string for API paths ("0000000000000000000095ad")
$user_settings = new UserSettings($user_id, $_SESSION['permission']);
```

**Key facts:**
- `Login::newFromSession()` returns a `Login` object (or null if not authenticated). It checks `$_SESSION['login_id']`, validates reauth, and caches in `self::$current_session`.
- `getFeedyardId()` returns `(int)$this->session_vars['feedyard_id']` — an integer.
- The hex `$feedyard_id` (`sprintf('%024x', $user_id)`) is what pb-api expects in URL paths. Never pass the raw int to ApiHelper.
- `$_SESSION['permission']` is passed to UserSettings for permission-aware formatting.
- Auth redirect files (e.g. `require 'auth.php'`) call `Login::newFromSession()` and redirect to login if null.

## Pattern 2: Multi-Tenant Scoping

Everything is scoped by `feedyard_id`. The first two arguments in every ApiHelper call are always `'feedyards', $feedyard_id`:

```php
ApiHelper::GET('feedyards', $feedyard_id, 'groups');
ApiHelper::GET('feedyards', $feedyard_id, 'groups', $group_id, 'events', $event_id);
ApiHelper::PATCH($payload, 'feedyards', $feedyard_id, 'groups', $group_id, 'events', $event_id);
ApiHelper::DELETE('feedyards', $feedyard_id, 'groups', $group_id, 'events', $event_id);
```

pb-api enforces that the session user matches the feedyard_id in the URL — this is the primary multi-tenancy enforcement point. PHP-side, the session's `feedyard_id` (via `Login::newFromSession()->getFeedyardId()`) is always the authoritative source.

## Pattern 3: Head_event Subclass Pattern

**Inheritance chain:**
```
Sheets
  └── Head_event
        ├── Head_add
        ├── Head_sold
        ├── Head_death
        └── Head_move
```

**Sheets** (base class) takes `$user_id, $origin, $origin_id, $sheet` in its constructor. Defines origin constants `Sheets::PEN` and `Sheets::GROUP`, plus error helpers `getUpdateErrorForUI()` and `getRemoveErrorForUI()`.

**Head_event** (intermediate) implements shared validation in `validateEditData()`:
```php
public function validateEditData(array $updated_rows, array $removed_rows) : array {
    $this->validateOrigin();
    $this->validateExistence($updated_rows, "getUpdateErrorForUI");
    $this->validateExistence($removed_rows, "getRemoveErrorForUI");
    $this->validateOwnership($updated_rows, "getUpdateErrorForUI");
    $this->validateOwnership($removed_rows, "getRemoveErrorForUI");
    $this->validateDates($updated_rows, "getUpdateErrorForUI");
    $this->validateNumHead($updated_rows, "getUpdateErrorForUI");
    return $this->all_errors;
}
```

**Required CRUD methods on each subclass:**

| Method | Signature | Purpose |
|---|---|---|
| `getData` | `getData($markup_id=null)` | Returns array of row arrays for the sheet grid |
| `newFromData` | `static newFromData($data)` | Creates a new event via API, returns event ID |
| `updateData` | `updateData($datas)` | PATCHes changed fields; returns `['errors'=>[], 'successes'=>[]]` |
| `removeData` | `removeData($datas)` | DELETEs events; returns same structure |
| `validateEditData` | `validateEditData(array $updated_rows, array $removed_rows): array` | Validates; returns `['errors'=>[...]]` or `['success'=>"..."]` |
| `getHeaders` | `getHeaders()` | Returns array of column header strings |
| `getColDataType` | `getColDataType()` | Returns array of Handsontable column config objects |

**Subclass validation** calls `parent::validateEditData()` first, then adds type-specific checks:
```php
// Head_sold.php
$all_errors = parent::validateEditData($updated_rows, $removed_rows);
// then checks expense, price, pay_weight, hedges, hot_weight, etc.
```

**SheetsFactory** maps sheet name strings to class instances:
```php
class SheetsFactory {
    private $headMap = ['head_add', 'head_sold', 'head_move', 'head_death', 'heads', 'pens'];

    public function __construct($user_id, $origin, $origin_id, $sheet, ...) {
        if (in_array($sheet, $this->headMap)) {
            $target = ucfirst($sheet);  // 'head_add' → 'Head_add'
            $this->instance = new $target($user_id, $origin, $origin_id, $sheet);
        }
    }
}
```

## Pattern 4: Form Submission Flow (save_*.php)

The canonical sequence in `save_*.php` files:

```
1. Auth:       $user_id = Login::newFromSession()->getFeedyardId();
2. Setup:      $feedyard_id = sprintf('%024x', $user_id);
               $user_settings = new UserSettings($user_id, $_SESSION['permission']);
3. Read POST:  $data = $_POST; $data['user_id'] = $user_id;
4. Validate:   $response = validate($data); if error → echo json, return
5. Distribute: distributeToGroups($data);  (splits totals to per-group fractions)
6. Preview:    if ($data['preview'] == "true") { echo preview; return; }
7. Convert:    formatRawValue(..., CONVERT_INPUT) on weight fields
8. Save:       foreach $data['head_data'] → Head_*::newFromData(...)
9. Side effects: TargetMaintenanceService::maintainForPens(),
                 WorkDate::rebalanceLoadsAfterChange(),
                 Hubspot_API\Subscription_Observer::update("head")
10. Respond:   echo json_encode($response)
```

**Preview short-circuit** — skips save and returns table preview data:
```php
if (isset($data['preview']) && $data['preview'] == "true") {
    echo json_encode(['response' => $table_preview]);
    return;
}
```

**Weight conversion before save** — always use `CONVERT_INPUT` to convert user units to storage units (lbs):
```php
$event_data['pay_weight'] = $user_settings->formatRawValue(
    $event['pay_weight'], UserSettings::WEIGHT_ANIMAL, UserSettings::CONVERT_INPUT
);
```

## Pattern 5: ApiHelper Proxy

`ApiHelper` proxies all calls to pb-api (Go backend) over localhost. The four CRUD methods accept variadic args:

```php
public static function GET(...$routePath) { ... }
public static function PUT($payload, ...$routePath) { ... }
public static function PATCH($payload, ...$routePath) { ... }
public static function DELETE(...$routePath) { ... }
```

**URL construction** interleaves resource names and IDs:
```php
// Get all groups:
ApiHelper::GET('feedyards', $feedyard_id, 'groups');

// Get specific event:
ApiHelper::GET('feedyards', $feedyard_id, 'groups', $group_id, 'events', $event_id);

// Query string as last arg:
ApiHelper::GET('feedyards', $feedyard_id, 'animals', $animal_id, 'applied_costs', '?inventory_id=' . $inventory_id);

// PUT with payload as first arg:
ApiHelper::PUT($payload, 'feedyards', $feedyard_id, 'work_dates', $date, 'rations', $ration_id);
```

**Error handling:**
- HTTP 500+: throws `Exception("API returned unrecoverable {$status} status for URL {$url}")`
- HTTP 300-499: throws `Exception($method . " " . $endpoint . " failed. status=" . $status, $status)` — the HTTP status is set as the exception code, so callers can check `$ex->getCode() == 404`
- A static `$curl` handle is reused across calls within a request for performance.

**`retrieve()` helper** wraps `GET` with standard feedyard scoping and `field=` query parameter setup:
```php
public static function retrieve($document_key_map, $shown_fields=[], $hidden_fields=[], ...) {
    $user_id = Login::newFromSession()->getFeedyardId();
    $feedyard_id = sprintf('%024x', $user_id);
    // builds $function_parameters = ['feedyards', $feedyard_id, ...]
    $data = ApiHelper::GET(...$function_parameters);
}
```

## Pattern 6: UserSettings Unit Conversions

`UserSettings` handles converting between user-preferred units (kg, km/h, Celsius) and storage units (lbs, mph, Fahrenheit).

**Type constants:**
```php
const CURRENCY          = 0;
const WEIGHT            = 1;   // aggregate weight (tons)
const WEIGHT_PRECISE    = 2;   // rate-of-gain, high precision
const DATE              = 3;
const PERCENT           = 4;
const CALORIES          = 5;
const NEAREST_ONE       = 6;
const DELIVERY          = 7;
const HUNDREDTHS        = 8;
const TENTHS            = 9;
const RAW               = 10;
const CURRENCY_VIEWABLE = 11;
const TEMPERATURE       = 12;
const SPEED             = 13;
const WEIGHT_ANIMAL     = 14;  // per-head animal weights (lbs vs kg)
const WEIGHT_MICRO_RATION = 15;
```

**Direction constants:**
```php
const CONVERT_INPUT  = 'input';   // user-unit → stored-unit (kg → lbs before saving)
const CONVERT_OUTPUT = 'output';  // stored-unit → user-unit (lbs → kg for display)
```

**Three conversion methods:**

| Method | Returns | Use case |
|---|---|---|
| `formatValue($value, $type, $includeLabel, $includeSeparator, $convertUnit)` | Formatted string with optional label and separators | Display in UI |
| `formatRawValue($value, $type, $convertUnit)` | Numeric string, no label/separator | Preparing values for API calls |
| `getRawValue($value, $type, $convertUnit)` | Numeric (cast via `+ 0`) | Calculations |

**The critical rule:** Always convert weights on input (`CONVERT_INPUT`) before saving and on output (`CONVERT_OUTPUT`) before displaying:

```php
// Before saving (save_*.php or updateData):
$pay_weight = $user_settings->formatRawValue(
    $data['pay_weight'], UserSettings::WEIGHT_ANIMAL, UserSettings::CONVERT_INPUT
);

// Before displaying (getData):
$row["pay_weight"] = $user_settings->formatRawValue(
    $pay_weight, UserSettings::WEIGHT_ANIMAL, UserSettings::CONVERT_OUTPUT
);
```

## Common Issues (PB-Specific)

1. **Saving weight without `CONVERT_INPUT`** — data stored in user's unit instead of lbs. All weight fields must be converted before ApiHelper calls.

2. **Using `$user_id` (int) where `$feedyard_id` (hex) is needed** — ApiHelper expects the 24-char hex string from `sprintf('%024x', $user_id)`, not the raw integer. Passing the int silently produces wrong API paths.

3. **Adding Head_* subclass without all required CRUD methods** — SheetsFactory will instantiate the class but the sheets UI will break if any of `getData`, `newFromData`, `updateData`, `removeData`, `validateEditData`, `getHeaders`, or `getColDataType` are missing.

4. **Missing `parent::validateEditData()` call** — subclass validation that skips the parent misses origin, existence, ownership, date, and head count validation.

5. **Forgetting feedyard_id scoping** — every ApiHelper call must include `'feedyards', $feedyard_id` as the first two path args. Queries without feedyard scoping can leak data across tenants.

6. **Wrong ApiHelper arg order** — `PUT` and `PATCH` take `$payload` as the first arg, then the variadic route path. `GET` and `DELETE` take only the variadic route path.

7. **Not handling ApiHelper exceptions** — 300+ and 500+ status codes both throw exceptions. Callers must either catch or let them propagate with appropriate error handling.

## Code Style

- **Class names:** PascalCase (`Head_sold`, `UserSettings`, `ApiHelper`) — note underscores in Head_* classes follow the established convention
- **Function names:** camelCase (`getData`, `newFromData`, `formatRawValue`)
- **Constants:** UPPER_SNAKE_CASE (`CONVERT_INPUT`, `WEIGHT_ANIMAL`)

## Resource Files

For detailed guidance on specific topics, see:
- `resources/api-development.md` — Detailed API patterns
- `resources/mongodb-patterns.md` — MongoDB best practices
