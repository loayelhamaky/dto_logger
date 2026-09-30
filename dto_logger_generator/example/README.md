# Example

`pubspec.yaml`:

```yaml
dependencies:
  dto_logger: ^2.0.0

dev_dependencies:
  build_runner: ^2.10.0
  dto_logger_generator: ^1.0.0
```

`lib/user.dart`:

```dart
import 'package:dto_logger/dto_logger.dart';

part 'user.g.dart';

@DtoLog()
class User {
  final int id;
  final String? name;

  User({required this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

Run `dart run build_runner build`. The generated `user.g.dart` contains:

```dart
User _$UserFromJson(Map<String, dynamic> json) {
  return DtoLogger.parse(
    json,
    () => User(
      id:
          json.safeInt('id') ??
          (throw FormatException('Required field "id" is missing or invalid')),
      name: json.safeString('name'),
    ),
    'User',
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};
```

`User.fromJson({'id': '42', 'name': null})` returns a `User` with `id == 42`.
In debug builds (assertions on, like `flutter run`) it also logs:

```
╔╣ ⚠ User ║ 1 warning ║ 6511µs
╟ ⚠ id   : was String, parsed as int
╟ · name : null
╚════════════════════════════════════════════════════════════════════════════════
```
