/// Annotations for DTO code generation (`dart run build_runner build`).
///
/// Names are `Dto*` so they never clash with `JsonKey` (json_annotation),
/// `Required` (package:meta, re-exported by Flutter) or `DateFormat` (intl).
///
/// Enums, nested `@DtoLog` classes, `List`s and `DateTime` are detected
/// from the field type, so they need no annotation.
library;

/// Main annotation to enable DTO logging and generation
///
/// Example:
/// ```dart
/// @DtoLog()
/// class User {
///   final int? id;
///   final String? name;
///
///   User({this.id, this.name});
///
///   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
///   Map<String, dynamic> toJson() => _$UserToJson(this);
/// }
/// ```
class DtoLog {
  /// Whether to generate `_$ClassFromJson`
  final bool generateFromJson;

  /// Whether to generate `_$ClassToJson`
  final bool generateToJson;

  /// Whether to generate a `copyWith` extension
  final bool generateCopyWith;

  /// Whether to generate an `equals()` / `hashValue` extension.
  /// Extensions can't override `==`, so wire them yourself:
  /// `bool operator ==(Object o) => equals(o);`
  final bool generateEquality;

  /// Whether fromJson runs inside `DtoLogger.parse` (debug-only logging)
  final bool enableLogging;

  const DtoLog({
    this.generateFromJson = true,
    this.generateToJson = true,
    this.generateCopyWith = false,
    this.generateEquality = false,
    this.enableLogging = true,
  });
}

/// Customizes one field: JSON key, default value, required.
///
/// Example:
/// ```dart
/// @DtoLog()
/// class User {
///   @DtoKey('user_name')
///   final String? userName;
///
///   @DtoKey('is_active', defaultValue: false)
///   final bool isActive;
/// }
/// ```
class DtoKey {
  /// The JSON key name (defaults to the field name)
  final String? name;

  /// Used when the JSON value is null, missing, or can't be converted
  final Object? defaultValue;

  /// Throw a [FormatException] when the value is null, missing or invalid
  final bool required;

  const DtoKey(
    this.name, {
    this.defaultValue,
    this.required = false,
  });

  /// Shorthand for specifying just a default value
  const DtoKey.defaultValue(this.defaultValue)
      : name = null,
        required = false;

  /// Shorthand for required fields
  const DtoKey.required()
      : name = null,
        defaultValue = null,
        required = true;
}

/// Value to use when the JSON value is null, missing, or can't be converted.
///
/// Example:
/// ```dart
/// @DtoLog()
/// class User {
///   @DtoDefault('')
///   final String name;
///
///   @DtoDefault(0)
///   final int age;
/// }
/// ```
class DtoDefault {
  /// The default value (must be a constant assignable to the field type)
  final Object? value;

  const DtoDefault(this.value);
}

/// Annotation to exclude a field from JSON serialization
///
/// Example:
/// ```dart
/// @DtoLog()
/// class User {
///   final String name;
///
///   @DtoIgnore()
///   final String? localCacheKey;  // Not serialized
/// }
/// ```
class DtoIgnore {
  /// Whether to ignore in fromJson
  final bool fromJson;

  /// Whether to ignore in toJson
  final bool toJson;

  const DtoIgnore({
    this.fromJson = true,
    this.toJson = true,
  });

  /// Only ignore in fromJson
  const DtoIgnore.fromJson()
      : fromJson = true,
        toJson = false;

  /// Only ignore in toJson
  const DtoIgnore.toJson()
      : fromJson = false,
        toJson = true;
}

/// Marks a field as required: fromJson throws a [FormatException] when the
/// value is null, missing, or can't be converted.
///
/// Non-nullable fields without a default are required automatically.
///
/// Example:
/// ```dart
/// @DtoLog()
/// class User {
///   @DtoRequired(message: 'User id is required')
///   final int? id;
///
///   final String? name;  // Optional
/// }
/// ```
class DtoRequired {
  /// Custom error message for the thrown [FormatException]
  final String? message;

  const DtoRequired({this.message});
}
