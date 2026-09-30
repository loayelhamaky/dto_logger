/// Debug-only logging and safe type coercion for JSON DTOs.
///
/// ```dart
/// class User {
///   final int? id;
///   final String? name;
///
///   User({this.id, this.name});
///
///   factory User.fromJson(Map<String, dynamic> json) {
///     return DtoLogger.parse(json, () => User(
///       id: json.safeInt('id'),
///       name: json.safeString('name'),
///     ), 'User');
///   }
/// }
/// ```
library dto_logger;

export 'src/dto_logger.dart';
export 'src/safe_parser.dart' show SafeParser, ParseResult;
export 'src/case_converter.dart';
export 'src/colors.dart' show AnsiColors;
export 'src/json_to_dart.dart';
export 'src/annotations.dart';
export 'src/mock_generator.dart';
