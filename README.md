# DTO Logger

Debug-only logging and safe type coercion for JSON DTOs in Flutter/Dart.

![dto_logger demo](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/demo.gif)

For every model you parse, it shows what the API actually sent:
nulls, missing keys, type mismatches, coerced values, and fields your model never reads.
It never throws on bad data, except for required fields: non-nullable fields without a default, or fields marked required.

## Try it in one minute

**1.** Add the package:

```bash
flutter pub add dto_logger
```

**2.** Open any model you already have and add one line at the start of its `fromJson`:

```dart
import 'package:dto_logger/dto_logger.dart';

factory User.fromJson(Map<String, dynamic> json) {
  json = json.logged(); // add this
  return User(id: json['id'] as int?, name: json['name'] as String?);
}
```

**3.** Run the app in debug and open the screen that loads it.
If the API sent `{"id": 7, "name": null, "phone": "0100"}`, the console shows:

```
╔╣ + User ║ 1 extra field ║ 7565µs
╟ · name  : null
╟ + phone : not used by model
╚════════════════════════════════════════════════════════════════════════════════
```

Nothing is printed in release builds.

### On a whole feature

Point the CLI at the feature's models folder. It adds that line to every `fromJson` in it:

```bash
dart run dto_logger:inject --dir lib/features/auth/data/models --dry-run   # preview
dart run dto_logger:inject --dir lib/features/auth/data/models             # apply
```

### From a JSON response

Save the response to a file and generate the model classes:

```bash
dart run dto_logger:generate -i user_response.json -o lib/features/auth/data/models
```

## Installation

```yaml
dependencies:
  dto_logger: ^2.0.0
```

Only if you use `@DtoLog` code generation, also add:

```yaml
dev_dependencies:
  build_runner: ^2.10.0
  dto_logger_generator: ^1.0.0
```

## Four ways to use it

### 1. One line in an existing `fromJson` (`.logged()`)

```dart
factory User.fromJson(Map<String, dynamic> json) {
  json = json.logged();
  return User(id: json['id'] as int?, name: json['name'] as String?);
}
```

Reports extra fields, nulls, missing keys, and strings that look like numbers.
It does not convert types. `dart run dto_logger:inject` adds this line to every `fromJson` in `lib/`.

### 2. Safe readers inside `DtoLogger.parse`

```dart
factory User.fromJson(Map<String, dynamic> json) {
  return DtoLogger.parse(json, () => User(
    id: json.safeInt('id'),
    name: json.safeString('name'),
    address: json.safeObject('address', Address.fromJson),
    orders: json.safeList('orders', Order.fromJson),
  ), 'User');
}
```

The class name is optional. Without it, it is read from the stack trace.
Passing it is faster and survives obfuscation.

### 3. Code generation with `@DtoLog`

```dart
import 'package:dto_logger/dto_logger.dart';

part 'user.g.dart';

enum Status { active, blocked }

@DtoLog(generateCopyWith: true)
class User {
  final int id;                     // non-nullable: throws if missing/invalid
  @DtoKey('user_name')
  final String? userName;
  @DtoDefault('')
  final String email;               // non-nullable with a default: never throws
  final Status? status;             // enums parsed by name, written as .name
  final DateTime? createdAt;        // ISO string or Unix timestamp in, ISO string out
  final Address? address;           // nested @DtoLog class
  @DtoIgnore()
  final String? localCacheKey;

  User({required this.id, this.userName, required this.email, this.status,
      this.createdAt, this.address, this.localCacheKey});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

```bash
dart run build_runner build
```

The builder is in the separate `dto_logger_generator` package (see Installation).
Nested classes must have a `fromJson` factory and a `toJson` method.
The builder stops with a clear error if one is missing.

### 4. Generate classes from JSON (CLI)

```bash
dart run dto_logger:generate                       # interactive: paste JSON
dart run dto_logger:generate -i user.json -c UserResponse -o lib/models
```

| Option | Meaning |
|---|---|
| `-i, --input <file>` | JSON file. An array of objects generates the item class. |
| `-o, --output <dir>` | Output folder (default `lib/models/`) |
| `-c, --class <name>` | Class name (default: from the file name) |
| `--no-from-json`, `--no-to-json` | Skip those methods |
| `--copy-with`, `--equality` | Add `copyWith`, `==` and `hashCode` |
| `--no-logging` | Plain `fromJson` without `DtoLogger.parse` |
| `--required` | Non-nullable fields; `fromJson` throws `FormatException` if one is missing or invalid |

Keys become valid Dart names (`class` → `class_`, `user-name` → `userName`, `1st` → `field1st`).
The JSON keys themselves are kept as they are.
If strict JSON parsing fails, the CLI retries with single quotes turned into double quotes.
That retry can corrupt values that contain an apostrophe, so prefer real JSON.

## What the log looks like

Logs only appear in debug builds. With plain `dart run`, add `--enable-asserts`.

```
╔╣ ✗ User ║ 3 errors, 4 warnings, 1 extra
╟ ⚠ id           : was String, parsed as int
╟ · email        : null
╟ ? age          : not in response
╟ ✗ role         : "nope" — expected: active, inactive, pending
╟ ✗ addresses[1] : got String, expected Map (skipped)
╟ ⚠ scores       : 1 item(s) coerced to int
╟ ✗ scores       : 1 item(s) are not int, skipped at 2
╟ + unused       : not used by model
╚════════════════════════════════════════════════════════════════
```

| Mark | Meaning | Box color |
|---|---|---|
| `✗` | Value can't be used (wrong type, unknown enum, `fromJson` threw) | red |
| `?` | Model reads a key the response doesn't have | yellow |
| `⚠` | Value was converted (`"7"` → `7`) | yellow |
| `~` | `.logged()` only: a string that looks like a number or bool | yellow |
| `·` | Value is null (informational) | stays green |
| `+` | Response has a field the model never reads | cyan |

A reader with a default (`safeIntOr`, `@DtoDefault`, `DtoKey(defaultValue:)`) does not log null or missing values.

## Configuration

```dart
DtoLogConfig.enabled = true;
DtoLogConfig.level = DtoLogLevel.warnings; // verbose, warnings, errors, none
DtoLogConfig.useColors = true;             // ANSI colors; turn off if your console shows escape codes
DtoLogConfig.useDeveloperLog = false;      // true → dart:developer log instead of print
DtoLogConfig.logSuccess = true;            // log clean parses too
DtoLogConfig.showTiming = true;
DtoLogConfig.showJsonData = false;         // dump the raw JSON under each box
DtoLogConfig.maxValueLength = 50;
DtoLogConfig.maxWidth = 80;
DtoLogConfig.compressLogs = true;          // after 10 boxes of one class in one burst, suppress the rest
DtoLogConfig.maxReportsPerClass = 10;
DtoLogConfig.deferLogging = false;         // print in a microtask instead of inline
```

In release builds `DtoLogger.parse`, `.logged()` and `logJson` skip all logging work.
The safe readers still convert values in release builds.

## Safe readers

| Reader | Returns |
|---|---|
| `safeInt`, `safeDouble`, `safeString`, `safeBool`, `safeDateTime` | converted value or null |
| `safeIntOr`, `safeDoubleOr`, `safeStringOr`, `safeBoolOr`, `safeEnumOr` | value or your default |
| `safeObject(key, X.fromJson)` | nested object (any `Map` type) or null |
| `safeList(key, X.fromJson)` | list of objects; non-map items are skipped and logged |
| `safeListOf<T>(key)` | list of primitives; items are converted like single values, bad ones skipped |
| `safeEnum(key, E.values)`, `safeEnumList(key, E.values)` | enum by name, case-insensitive |
| `safeMap(key)` | `Map<String, dynamic>` |
| `safeCast<T>(key)` | the value if it already is a `T`, else null (logged) |
| `safeValue(key)` | the raw value, marked as used |

### Conversions

| JSON value | Target | Result |
|---|---|---|
| `"123"` | `int` | `123` |
| `12.9` | `int` | `12` (truncated, logged as converted) |
| `123` | `double` | `123.0` |
| `"true"`, `"1"`, `"yes"`, `1` | `bool` | `true` |
| `"false"`, `"0"`, `"no"`, `0` | `bool` | `false` |
| `1704067200` or `"1704067200"` | `DateTime` | Unix seconds (above 10,000,000,000 → milliseconds) |
| `"2024-01-15T10:30:00Z"`, `"20240115"` | `DateTime` | ISO-8601 |
| `"NaN"`, `"Infinity"` | `int` | null, logged as an error |

Timestamps become local `DateTime` values.

## Annotations

| Annotation | Effect |
|---|---|
| `@DtoLog(...)` | `generateFromJson`, `generateToJson`, `generateCopyWith`, `generateEquality`, `enableLogging` |
| `@DtoKey('api_name', defaultValue: 0, required: false)` | JSON key, default, required |
| `@DtoDefault(value)` | Default when the value is null, missing, or invalid |
| `@DtoRequired(message: '...')` | Throw `FormatException` when null, missing, or invalid |
| `@DtoIgnore()`, `.fromJson()`, `.toJson()` | Skip the field in one or both directions |

Names start with `Dto` so they don't clash with `JsonKey` (json_annotation), `Required` (package:meta) or `DateFormat` (intl).

`generateEquality` creates an extension, and an extension can't override `==`. Wire it in the class:

```dart
@override
bool operator ==(Object other) => equals(other);
@override
int get hashCode => hashValue;
```

Lists are compared by identity, like any Dart `List`.
`copyWith(field: null)` keeps the old value.

## Mock data

```dart
final json = DtoMock.generate({
  'id': 'int',
  'email': 'String',
  'created_at': 'DateTime',
  'address': {'city': 'String'},
  'items': [{'id': 'int', 'price': 'double'}],
}, seed: 0);
```

Values follow the field name (`email` → `user0@test.com`, `price` → `9.99`).
The same seed gives the same data on every machine.

## Dependencies

`dto_logger` has no dependencies, so it resolves in any Dart 3 project,
next to `json_serializable`, `freezed` or any analyzer version.

The `@DtoLog` builder needs `analyzer`, `build` and `source_gen`, so it lives in
`dto_logger_generator`, a dev dependency. It supports analyzer 8.1.1 to 14.x (Dart 3.7+).
Projects that can't use it still get everything else: safe readers, `.logged()`, the CLI and mock data.

## License

MIT. See LICENSE.
