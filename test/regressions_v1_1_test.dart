// Regression tests for the bugs fixed in 1.1.0. One test per fix.
import 'dart:async';

import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

enum _Color { red, green }

/// Runs [body] and returns everything DtoLogger printed.
List<String> _captureLogs(void Function() body) {
  final lines = <String>[];
  runZoned(body,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => lines.addAll(line.split('\n')),
      ));
  return lines;
}

void main() {
  setUp(() {
    DtoLogConfig.enabled = true;
    DtoLogConfig.level = DtoLogLevel.verbose;
    DtoLogConfig.useColors = false;
    DtoLogConfig.showTiming = false;
    DtoLogConfig.logSuccess = true;
    DtoLogConfig.compressLogs = false;
    DtoLogConfig.deferLogging = false;
    DtoLogConfig.useDeveloperLog = false;
  });

  group('runtime logger', () {
    test('DtoLogLevel.none prints nothing', () {
      DtoLogConfig.level = DtoLogLevel.none;
      final json = <String, dynamic>{'a': '1', 'b': null};
      final logs = _captureLogs(() {
        DtoLogger.parse(json, () => json.safeInt('a'), 'T');
        DtoLogger.logJson(json, 'T');
      });
      expect(logs, isEmpty);
    });

    test('a value that cannot be converted is an error, not a null', () {
      final json = <String, dynamic>{'a': 'abc'};
      final logs = _captureLogs(
          () => DtoLogger.parse(json, () => json.safeInt('a'), 'T'));
      expect(logs.first, contains('✗ T'));
      expect(logs.any((l) => l.contains('✗ a')), isTrue);
    });

    test('a missing key is reported as missing, not as null', () {
      final json = <String, dynamic>{'b': null};
      final logs = _captureLogs(() => DtoLogger.parse(json, () {
            json.safeInt('a');
            json.safeInt('b');
          }, 'T'));
      expect(
          logs.any((l) => l.contains('? a') && l.contains('not in response')),
          isTrue);
      expect(logs.any((l) => l.contains('· b') && l.contains('null')), isTrue);
    });

    test('a throwing builder is logged, rethrown, and leaks no session', () {
      final json = <String, dynamic>{'a': 1};
      final logs = _captureLogs(() {
        expect(
          () => DtoLogger.parse<int>(json, () => throw StateError('boom'), 'T'),
          throwsStateError,
        );
      });
      expect(logs.any((l) => l.contains('threw Bad state: boom')), isTrue);

      // The next parse must not inherit issues from the crashed one
      final next = <String, dynamic>{'x': 1};
      final nextLogs = _captureLogs(
          () => DtoLogger.parse(next, () => next.safeInt('x'), 'Next'));
      expect(nextLogs.first, contains('✓ Next'));
    });

    test('nested parse keeps the parent issues', () {
      final json = <String, dynamic>{
        'x': '1',
        'child': {'a': 'zz'},
      };
      final logs = _captureLogs(() => DtoLogger.parse(json, () {
            json.safeInt('x');
            json.safeObject('child',
                (m) => DtoLogger.parse(m, () => m.safeInt('a'), 'Child'));
          }, 'Parent'));
      expect(logs.any((l) => l.contains('Child')), isTrue);
      expect(logs.any((l) => l.contains('Parent')), isTrue);
      expect(logs.any((l) => l.contains('⚠ x')), isTrue);
    });

    test('safeList skips items that are not maps instead of throwing', () {
      final json = <String, dynamic>{
        'items': [
          {'id': 1},
          'bad',
          {'id': 2},
        ],
      };
      final ids = json.safeList('items', (m) => m['id']);
      expect(ids, [1, 2]);
    });

    test('safeObject accepts Map<dynamic, dynamic>', () {
      final json = <String, dynamic>{
        'child': <dynamic, dynamic>{'a': 1},
      };
      expect(json.safeObject('child', (m) => m['a']), 1);
    });

    test('safeIntOr does not log a null when a default is given', () {
      final json = <String, dynamic>{'a': null};
      final logs = _captureLogs(
          () => DtoLogger.parse(json, () => json.safeIntOr('a', 5), 'T'));
      expect(logs.first, contains('✓ T'));
      expect(logs.any((l) => l.contains(' a ')), isFalse);
    });

    test('safeListOf coerces items and skips the rest', () {
      final json = <String, dynamic>{
        'ids': ['1', 2, 'x'],
        'names': [1, 'b'],
      };
      expect(json.safeListOf<int>('ids'), [1, 2]);
      expect(json.safeListOf<String>('names'), ['1', 'b']);
      expect(json.safeListOf<int?>('ids'), [1, 2]);
    });

    test('safeValue marks a dynamic field as used', () {
      final json = <String, dynamic>{
        'extra': [1]
      };
      final logs = _captureLogs(
          () => DtoLogger.parse(json, () => json.safeValue('extra'), 'T'));
      expect(logs.any((l) => l.contains('not used by model')), isFalse);
    });

    test('safeCast returns null and logs on a wrong type', () {
      final json = <String, dynamic>{'n': 'text'};
      final logs = _captureLogs(
          () => DtoLogger.parse(json, () => json.safeCast<num>('n'), 'T'));
      expect(json.safeCast<num>('n'), isNull);
      expect(logs.any((l) => l.contains('✗ n')), isTrue);
    });

    test('safeEnumList skips unknown values', () {
      final json = <String, dynamic>{
        'colors': ['RED', 'blue', 'green'],
      };
      expect(json.safeEnumList('colors', _Color.values),
          [_Color.red, _Color.green]);
    });
  });

  group('SafeParser', () {
    test('a 10-digit string is a Unix timestamp, not the year 170411', () {
      expect(SafeParser.asDateTime('1704067200').value!.year, 2024);
    });

    test('an 8-digit date string still parses as a date', () {
      final date = SafeParser.asDateTime('20240115').value!;
      expect([date.year, date.month, date.day], [2024, 1, 15]);
    });

    test('a timestamp out of DateTime range fails safely', () {
      expect(SafeParser.asDateTime('99999999999999999').success, isFalse);
    });

    test('NaN and Infinity never throw', () {
      expect(SafeParser.asInt('NaN').success, isFalse);
      expect(SafeParser.asInt(double.infinity).success, isFalse);
    });
  });

  group('CaseConverter', () {
    test('leading acronyms are lowered', () {
      expect(CaseConverter.snakeToCamel('ID'), 'id');
      expect(CaseConverter.snakeToCamel('URL'), 'url');
      expect(CaseConverter.snakeToCamel('HTTPResponse'), 'httpResponse');
      expect(CaseConverter.snakeToCamel('userID'), 'userID');
    });

    test('names with nothing usable become "field"', () {
      expect(CaseConverter.toValidIdentifier('__'), 'field');
      expect(CaseConverter.toValidIdentifier('الاسم'), 'field');
      expect(CaseConverter.toValidIdentifier('123field'), 'field123field');
    });
  });

  group('JsonToDartGenerator', () {
    List<String> names(GeneratedClass c) =>
        c.fields.map((f) => f.name).toList();

    test('keys become valid, unique Dart names', () {
      final result = JsonToDartGenerator().generate({
        'class': 1,
        'user-name': 'x',
        '1st': 2,
        'الاسم': 'a',
        'العنوان': 'b',
        'user_name': 'c',
        'userName': 'd',
        'hashCode': 3,
      }, 'Sample');
      expect(names(result), [
        'class_',
        'userName',
        'field1st',
        'field',
        'field2',
        'userName2',
        'userName3',
        'hashCodeValue',
      ]);
      // Keys stay untouched for the JSON side
      expect(result.code, contains("json.safeString('الاسم')"));
    });

    test('keys with quotes and \$ are escaped in the generated code', () {
      final code = JsonToDartGenerator().generate({r"it's $x": 1}, 'T').code;
      expect(code, contains(r"'it\'s \$x'"));
    });

    test('allNullable: false throws instead of assigning null', () {
      final code = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      ).generate({
        'id': 1,
        'child': {'a': 1}
      }, 'T').code;
      expect(code, contains('final int id;'));
      expect(code, contains("json.safeInt('id') ?? (throw FormatException("));
      expect(code, contains("'child': child.toJson()"));
    });

    test('list item type checks every item, not just the first', () {
      final fields = JsonToDartGenerator().generate({
        'ints': [1, 2],
        'nums': [1, 2.5],
        'mixed': ['a', 1],
        'withNull': [1, null],
      }, 'T').fields;
      expect(fields.map((f) => f.type), [
        'List<int>?',
        'List<double>?',
        'List<dynamic>?',
        'List<int?>?',
      ]);
    });

    test('list of objects merges keys from every item', () {
      final result = JsonToDartGenerator().generate({
        'items': [
          {'id': 1},
          {'id': 2, 'only_in_second': 'x'},
        ],
      }, 'T');
      expect(names(result.nestedClasses.single), ['id', 'onlyInSecond']);
    });

    test(
        'a key missing from one sample is nullable even with allNullable: false',
        () {
      final result = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      ).generateFromSamples([
        {'id': 1, 'name': 'a'},
        {'id': 2},
      ], 'T');
      expect(result.fields.map((f) => f.type), ['int', 'String?']);
    });

    test('item class names are singularized correctly', () {
      final result = JsonToDartGenerator().generate({
        'status': [
          {'a': 1}
        ],
        'courses': [
          {'a': 1}
        ],
        'children': [
          {'a': 1}
        ],
        'orderItems': [
          {'a': 1}
        ],
        'categories': [
          {'a': 1}
        ],
      }, 'T');
      expect(result.nestedClasses.map((c) => c.name),
          ['Status', 'Course', 'Child', 'OrderItem', 'Category']);
    });

    test('repeated and core-type class names get the parent prefix', () {
      final result = JsonToDartGenerator().generate({
        'dup': {'a': 1},
        'wrap': {
          'dup': {'b': 2},
        },
        'map': {'c': 3},
      }, 'Root');
      final all = <String>[];
      void collect(GeneratedClass c) {
        all.add(c.name);
        c.nestedClasses.forEach(collect);
      }

      collect(result);
      expect(all, containsAll(['Root', 'Dup', 'Wrap', 'WrapDup', 'RootMap']));
      expect(all, isNot(contains('Map')));
    });

    test('an empty object becomes Map<String, dynamic>', () {
      final field =
          JsonToDartGenerator().generate({'meta': {}}, 'T').fields.single;
      expect(field.type, 'Map<String, dynamic>?');
      expect(JsonToDartGenerator().generate({'meta': {}}, 'T').code,
          contains("json.safeMap('meta')"));
    });

    test('more than 20 fields use Object.hashAll', () {
      final json = {for (var i = 0; i < 21; i++) 'f$i': i};
      final code = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      ).generate(json, 'T').code;
      expect(code, contains('Object.hashAll(['));
      expect(code, isNot(contains('Object.hash(f0')));
    });

    test('a field named "other" does not break ==', () {
      final code = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      ).generate({'other': 1}, 'T').code;
      expect(code, contains('bool operator ==(Object that)'));
      expect(code, contains('that.other == other'));
    });
  });

  group('DtoMock', () {
    test('field names match whole words', () {
      expect(DtoMock.value('width', 'int', seed: 1), 110);
      expect(DtoMock.value('shipping_address', 'String'),
          isNot(startsWith('192.168')));
      expect(DtoMock.value('ip_address', 'String'), startsWith('192.168'));
      expect(DtoMock.value('inactive', 'bool', seed: 0), isFalse);
    });

    test('dates do not depend on the machine timezone', () {
      expect(
          DtoMock.value('created_at', 'DateTime'), '2024-01-01T00:00:00.000Z');
    });

    test('a list schema generates a list of objects', () {
      final result = DtoMock.generate({
        'items': [
          {'id': 'int'},
        ],
      });
      expect(result['items'], hasLength(3));
      expect((result['items'] as List).first, isA<Map<String, dynamic>>());
    });
  });
}
