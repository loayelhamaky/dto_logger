# DTO Logger

Your API sends `"42"` instead of `42`, or `null` where you don't expect it.
dto_logger reads JSON safely and shows, for every model, exactly what the API sent.
Logs appear in debug builds only.

![One report per model: converted values, values that can't be read, missing keys, nulls and unused fields](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/report.png)

- **No crash on bad JSON.** `json.safeInt('id')` turns `"42"` into `42`. A value that can't be read becomes `null` and is logged.
- **One report per model.** Nulls, missing keys, converted types and fields your model never reads.
- **Works with the models you have.** One line in `fromJson`, or one command for a whole folder.
- **No model yet?** Generate it from a JSON response.

## Try it in one minute

**1.** Add the package:

```bash
flutter pub add dto_logger
```

**2.** Open a model you already have and add one line at the start of its `fromJson`:

```dart
import 'package:dto_logger/dto_logger.dart';

factory User.fromJson(Map<String, dynamic> json) {
  json = json.logged(); // add this
  return User(id: json['id'] as int?, name: json['name'] as String?);
}
```

**3.** Run the app in debug and open the screen that loads it.
If the API sent `{"id": 7, "name": null, "phone": "0100"}`, the console shows:

![The report for User: name is null, phone is not used by the model](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/logged.png)

Nothing is printed in release builds.

<details>
<summary><b>Watch the full demo (1:50)</b></summary>
<br>
<img src="https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/demo.gif" alt="dto_logger full demo">
</details>

## Pick your case

### You already have models

Add `json = json.logged();` by hand (step 2 above), or let the CLI add it to every `fromJson` in a folder or a file:

```bash
dart run dto_logger:inject lib/features/auth/data/models   # a folder
dart run dto_logger:inject lib/models/user.dart            # one file
dart run dto_logger:inject lib/models --dry-run            # preview first
```

![The inject command adds json.logged() and the import to every fromJson](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/inject.png)

`.logged()` reports problems but doesn't convert types.
To convert too, read the fields with the safe readers below.

### You're writing a model

Read every field with a safe reader inside `DtoLogger.parse`:

```dart
factory User.fromJson(Map<String, dynamic> json) =>
    DtoLogger.parse(json, () => User(
          id: json.safeInt('id'),
          name: json.safeString('name'),
          email: json.safeString('email'),
          age: json.safeInt('age'),
          phone: json.safeString('phone'),
        ));
```

With `{"id": "42", "name": "Loay", "email": null, "age": "N/A", "avatar_url": "a.png"}`:

![The id string became 42, age could not be read, phone is missing and avatar_url is unused](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/safe_readers.png)

The class name in the report is read from the stack trace.
Pass it as the last argument (`DtoLogger.parse(json, () => ..., 'User')`) to make it faster and keep it after obfuscation.

### You have a JSON response but no model

Save the response to a file and generate the classes:

```bash
dart run dto_logger:generate --input order.json
```

![The generated Order class reads every field with a safe reader](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/generate.png)

Nested objects get their own classes (`Customer`, `Item`). Run `dart run dto_logger:generate` with no options to paste the JSON instead.

| Option | Meaning |
|---|---|
| `-i, --input <file>` | JSON file. An array of objects generates the item class. |
| `-o, --output <dir>` | Output folder (default `lib/models/`) |
| `-c, --class <name>` | Class name (default: from the file name) |
| `--no-from-json`, `--no-to-json` | Skip those methods |
| `--copy-with`, `--equality` | Add `copyWith`, `==` and `hashCode` |
| `--no-logging` | Plain `fromJson` without `DtoLogger.parse` |
| `--required` | Non-nullable fields; `fromJson` throws `FormatException` if one is missing or invalid |

Keys become valid Dart names (`class` → `class_`, `user-name` → `userName`, `1st` → `field1st`), and the JSON keys stay as they are.
If strict JSON parsing fails, the CLI retries with single quotes turned into double quotes. That retry can corrupt values that contain an apostrophe, so prefer real JSON.

### You prefer code generation

Annotate the class with `@DtoLog` and let `build_runner` write `fromJson`, `toJson` and, if you want, `copyWith` and equality.
The builder is a separate dev dependency:

```yaml
dev_dependencies:
  build_runner: ^2.10.0
  dto_logger_generator: ^1.0.0
```

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

Nested classes need a `fromJson` factory and a `toJson` method. The builder stops with a clear error if one is missing.

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

Lists are compared by identity, like any Dart `List`. `copyWith(field: null)` keeps the old value.

## Reading the report

| Mark | Meaning | Box color |
|---|---|---|
| `✗` | Value can't be used (wrong type, unknown enum, `fromJson` threw) | red |
| `?` | Model reads a key the response doesn't have | yellow |
| `⚠` | Value was converted (`"7"` → `7`) | yellow |
| `~` | `.logged()` only: a string that looks like a number or bool | yellow |
| `·` | Value is null (informational) | stays green |
| `+` | Response has a field the model never reads | cyan |

A reader with a default (`safeIntOr`, `@DtoDefault`, `DtoKey(defaultValue:)`) does not log null or missing values.
With plain `dart run`, add `--enable-asserts` to see the logs.

## Missing or broken values

![A nullable field gets null, a field with a default gets the default, a required field gets a clear error](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/three_cases.png)

- **Nullable field** (`int? age`): the value becomes `null`.
- **Field with a default** (`json.safeIntOr('points', 0)`, `@DtoDefault(0)`): the value becomes the default.
- **Required field** (non-nullable, no default): a `FormatException` that names the field.

Models made by `dto_logger:generate` are nullable unless you pass `--required`, so they never throw.

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

## Big lists

When thousands of items share the same problem, the console stays readable.
After `maxReportsPerClass` boxes of one class (10 by default) the rest of that response is summed up in one line:

```dart
DtoLogConfig.maxReportsPerClass = 3;
final products = api.map(Product.fromJson).toList(); // 5,000 items
```

![Three boxes, then one line saying the rest were suppressed](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/big_list.png)

## Test data

```dart
final user = DtoMock.generate({
  'id': 'int', 'name': 'String',
  'email': 'String', 'phone': 'String',
  'avatar_url': 'String', 'is_verified': 'bool',
  'created_at': 'DateTime',
  'cart': [{'price': 'double'}],
}, seed: 0);
```

![Realistic values that follow the field names](https://raw.githubusercontent.com/loayelhamaky/dto_logger/main/doc/screens/mock.png)

Values follow the field name, and the same seed gives the same data on every machine.

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
DtoLogConfig.compressLogs = true;          // see "Big lists"
DtoLogConfig.maxReportsPerClass = 10;
DtoLogConfig.deferLogging = false;         // print in a microtask instead of inline
```

In release builds `DtoLogger.parse`, `.logged()` and `logJson` skip all logging work.
The safe readers still convert values.

## Dependencies

`dto_logger` has no dependencies, so it resolves in any Dart 3 project,
next to `json_serializable`, `freezed` or any analyzer version.
The `@DtoLog` builder lives in `dto_logger_generator` (analyzer 8.1.1 to 14.x, Dart 3.7+), a dev dependency you only add if you use it.

## License

MIT. See LICENSE.
