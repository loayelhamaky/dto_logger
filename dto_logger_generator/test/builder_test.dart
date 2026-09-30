import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dto_logger_generator/dto_logger_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

/// Runs the @DtoLog builder on [body] and returns the generated part,
/// with whitespace collapsed so the checks don't depend on dart_style.
Future<String> generate(String body, {List<String>? errors}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'app');
  await readerWriter.testing.loadIsolateSources();
  final result = await testBuilder(
    dtoLoggerBuilder(BuilderOptions.empty),
    {
      'app|lib/model.dart': '''
import 'package:dto_logger/dto_logger.dart';

part 'model.g.dart';

$body
''',
    },
    rootPackage: 'app',
    readerWriter: readerWriter,
    flattenOutput: true,
    onLog: (record) {
      if (record.level >= Level.SEVERE) errors?.add(record.message);
    },
  );
  final outputs = result.outputs.toList();
  if (outputs.isEmpty) return '';
  return readerWriter.testing
      .readString(outputs.single)
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('( ', '(');
}

void main() {
  test(
    'generates fromJson with safe readers, required fields and defaults',
    () async {
      final code = await generate('''
enum Status { active, blocked }

@DtoLog()
class User {
  final int id;
  @DtoKey('user_name')
  final String? userName;
  @DtoDefault('')
  final String email;
  final Status? status;
  final DateTime? createdAt;
  final List<int?>? scores;
  @DtoIgnore()
  final String? cache;
  String get computed => 'x';
  static const version = 1;

  User({required this.id, this.userName, required this.email, this.status,
      this.createdAt, this.scores, this.cache});
}
''');
      expect(code, contains(r'User _$UserFromJson(Map<String, dynamic> json)'));
      expect(code, contains('DtoLogger.parse('));
      expect(
        code,
        contains(
          "id: json.safeInt('id') ?? (throw FormatException("
          '\'Required field "id" is missing or invalid\'))',
        ),
      );
      expect(code, contains("userName: json.safeString('user_name')"));
      expect(code, contains("email: json.safeStringOr('email', '')"));
      expect(code, contains("status: json.safeEnum('status', Status.values)"));
      expect(code, contains("createdAt: json.safeDateTime('createdAt')"));
      expect(code, contains("scores: json.safeListOf<int?>('scores')"));
      expect(code, contains("'status': instance.status?.name"));
      expect(
        code,
        contains("'createdAt': instance.createdAt?.toIso8601String()"),
      );
      expect(code, isNot(contains('cache')));
      expect(code, isNot(contains('computed')));
      expect(code, isNot(contains('version')));
    },
  );

  test('generates copyWith and equality', () async {
    final code = await generate('''
@DtoLog(generateCopyWith: true, generateEquality: true)
class Point {
  final int x;
  final int? other;
  Point(this.x, [this.other]);
}
''');
    expect(code, contains(r'extension $PointCopyWith on Point'));
    expect(code, contains('int? x,'));
    expect(code, contains('bool equals(Object that)'));
    expect(code, contains('int get hashValue => Object.hash(x, other);'));
  });

  test('nested class without fromJson is a clear error', () async {
    final errors = <String>[];
    await generate('''
class Plain {
  final int? a;
  Plain(this.a);
}

@DtoLog()
class Holder {
  final Plain? plain;
  Holder({this.plain});
}
''', errors: errors);
    expect(
      errors.join('\n'),
      contains('Plain is used by plain but has no fromJson.'),
    );
  });

  test('@DtoLog on a generic class is an error', () async {
    final errors = <String>[];
    await generate('''
@DtoLog()
class Box<T> {
  final T? value;
  Box({this.value});
}
''', errors: errors);
    expect(
      errors.join('\n'),
      contains('@DtoLog does not support generic classes.'),
    );
  });
}
