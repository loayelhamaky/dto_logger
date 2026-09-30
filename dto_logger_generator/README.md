# dto_logger_generator

The `build_runner` code generator for [`dto_logger`](https://pub.dev/packages/dto_logger)'s `@DtoLog` annotation.

For each annotated class it generates `fromJson`, `toJson`, and optionally `copyWith` and equality.
The generated `fromJson` reads every field with `dto_logger`'s safe readers, so in debug builds you
see nulls, missing keys, type mismatches and unused fields per model.

## Installation

```yaml
dependencies:
  dto_logger: ^2.0.0

dev_dependencies:
  build_runner: ^2.10.0
  dto_logger_generator: ^1.0.0
```

## Usage

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

  User({required this.id, this.userName, required this.email, this.status,
      this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

```bash
dart run build_runner build
```

The annotations (`@DtoLog`, `@DtoKey`, `@DtoDefault`, `@DtoRequired`, `@DtoIgnore`) and all
options are documented in the [dto_logger README](https://pub.dev/packages/dto_logger).

## Compatibility

Works with analyzer 8.1.1 to 14.x and `source_gen` 4, so it can sit next to current
`json_serializable` and `freezed`. Requires Dart 3.7 or newer.
