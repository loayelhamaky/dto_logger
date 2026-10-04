## 2.1.1

- README: a numbered list of what the package does, linking to each section.

## 2.1.0

- `inject` takes a single file as well as a folder, with or without `--dir`:
  `dart run dto_logger:inject lib/models/user.dart`.
- README: organized by use case, with a screenshot of the real output under
  each feature. The full demo moved to a collapsed section.
- Package page: more screenshots.

## 2.0.1

- README: a demo of every feature at the top.
- Package page: a screenshot.

## 2.0.0

### Breaking
- The `@DtoLog` builder moved to a new package, `dto_logger_generator`.
  If you use `@DtoLog`, add it next to `build_runner`:
  ```yaml
  dev_dependencies:
    build_runner: ^2.10.0
    dto_logger_generator: ^1.0.0
  ```
  The annotations stay in `dto_logger` and the generated code is the same, except
  that a field read with `safeCast` keeps nullable type arguments
  (`Map<String, int?>` was read as `Map<String, int>`).
  `package:dto_logger/builder.dart` is gone. If your `build.yaml` configures the
  builder, rename `dto_logger:dto_logger` to `dto_logger_generator:dto_logger`.

### Changed
- `dto_logger` has no dependencies now. Before, its `source_gen ^1.5.0` made it
  impossible to add next to current `json_serializable` or `freezed`, which
  need `source_gen` 3 or newer.
- `pubspec.yaml` links to the repository and issue tracker.

### Fixed
- `DtoMock` prices and coordinates had floating point noise
  (`29.990000000000002`). They are exact now (`29.99`).
- `DtoMock` gave `avatar_url` and `image_url` a plain page URL. They get image URLs now.
- A timestamp sent as a string (`"1704067200"`) was reported as `was int (seconds)`.
  It now says `was String (seconds)`.
- `inject` left a double space (`json)  {`) when it turned an `=>` fromJson into a block.
- The CLI header boxes were misaligned.

### Docs
- README starts with a one-minute quick start.

## 1.1.1

- LICENSE: copyright holder is now the full name (Loay Elhamaky). No code changes.

## 1.1.0

First release on pub.dev.

### Breaking
- Annotations renamed so they no longer clash with other packages:
  `JsonKey` → `DtoKey` (json_annotation), `Required` → `DtoRequired`
  (package:meta / Flutter), `NullDefault` → `DtoDefault`.
- Removed annotations and options that never did anything: `NullHandling`,
  `DtoLog.className`, `JsonKey.fromJson/toJson/includeInToJson/includeInFromJson`,
  `NestedDto`, `EnumField`, `DateFormat` (clashed with intl), `DateTimeFormat`.
  Enums, nested classes, lists and `DateTime` are detected from the field type.
- A missing key is now reported as `? not in response` (warning) instead of `· null`,
  unless the reader has a default (`safeIntOr`, `@DtoDefault`, ...), which stays quiet.
- A value that can't be converted is now reported as `✗` (error) instead of `· null`.

### Fixed — runtime
- `DtoLogLevel.none` printed everything. It now prints nothing (`parse`, `logJson`, `.logged()`).
- A `fromJson` that throws left its session on the stack forever. It is now
  logged as `threw ...`, cleaned up, and rethrown.
- `safeList` threw a `TypeError` on a non-map item. Bad items are now skipped and logged.
- `safeObject` rejected `Map<dynamic, dynamic>` (e.g. from Hive). It is now accepted.
- `safeListOf<int>` failed the whole list for one bad item. Items are now
  coerced like single values (`"1"` → `1`) and bad ones are skipped and logged.
- `safeIntOr` & co. logged a null even though a default was given.
- `asDateTime("1704067200")` returned the year 170411. Digit-only strings of 10+
  characters are now Unix timestamps; `"20240115"` still parses as a date.
- `asInt("NaN")`, `asInt("Infinity")` and `asInt(double.nan)` threw. They now fail safely.
- Timestamps beyond `DateTime`'s range threw a `RangeError`. They now fail safely.

### Fixed — JSON → Dart generator and CLI
- Keys like `class`, `user-name`, `1st` or Arabic text produced code that
  didn't compile. Names are now valid, unique Dart identifiers (`class_`,
  `userName`, `field1st`, `field`, `field2`); JSON keys stay unchanged.
- Keys containing `'`, `$` or `\` broke the generated string literals.
- `--required` (`allNullable: false`) generated `int id = json.safeInt(...)`,
  which doesn't compile. Required fields now throw a `FormatException` when
  missing or invalid.
- `--no-logging` removed the import that the `safe*` calls need.
- List item types used only the first item (`[1, 2.5]` → `List<int>`).
  Every item is checked now; lists with nulls get `List<int?>`.
- A list of objects used only the first object's keys. Keys from all items are merged.
- Singular names: `status` → `Statu`, `quizzes` → `Quizz` and similar are fixed.
- More than 20 fields generated `Object.hash(...)` with too many arguments.
- An empty object `{}` produced a `dynamic` field read with `safeString`.
  It is now `Map<String, dynamic>` read with `safeMap`.
- Empty classes generated `Empty({})` and `copyWith({})`, which are invalid Dart.
- A second nested class with the same name became `Dup_`; it is now
  `ParentDup`. Nested classes never shadow `dart:core` types like `Map` or `List`.
- A field named `other` broke the generated `==`.
- The CLI wrote `out_buser.dart` for `-o out_b` (missing slash) in file mode.
- The CLI now accepts a top-level array of objects and generates the item class.
- Interactive paste stopped at the first blank line inside pretty JSON.
  It now reads until the brackets close.
- `snakeToCamel('ID')` gave `iD`; leading acronyms are lowered now (`ID` → `id`,
  `HTTPResponse` → `httpResponse`).

### Fixed — `@DtoLog` builder
- Annotations are matched by package URL, so json_annotation's `JsonKey` is never picked up.
- Non-nullable fields without a default didn't compile. They now throw a
  `FormatException` when missing or invalid; `@DtoRequired` does the same for nullable fields.
- Enum fields were treated as nested classes (`Status.fromJson`). Enums (and
  lists of enums) are parsed by name now and written as `.name`.
- `DateTime` was written raw, so `jsonEncode` threw. It is written as an ISO-8601 string now.
- Default values: strings are escaped, lists/maps keep their content, enum
  values work, `@DtoDefault(0)` works on `double` fields, and a default of the
  wrong type is a clear build error.
- Constructor arguments follow the real constructor (named and positional);
  a required parameter with no matching field is a clear build error.
- A nested class without `fromJson` is a clear build error instead of broken code.
- `dynamic` fields no longer show up as "not used by model".
- `copyWith` / equality: 20+ fields use `Object.hashAll`; a field named `other` works.
- Verified to compile against analyzer 5.13.0 + source_gen 1.5.0 and analyzer 6.4.1.

### Other
- `DtoMock`: field names match whole words (`width` is not an id, `shipping_address`
  is not an IP), dates are UTC so output is the same in every timezone, and list
  schemas like `'items': [{'id': 'int'}]` are supported.
- `inject` reports why each method was skipped (already logged / in a comment / unsupported shape).
- The example no longer imports Flutter (it had 44 analyzer errors in a pure Dart package).
- Added LICENSE, CHANGELOG, .gitignore; removed the `yourname` homepage placeholder.

## 1.0.0

- Initial version.
