import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  // ==========================================================================
  // SafeParser.asInt - infinity, NaN, overflow
  // ==========================================================================
  group('SafeParser.asInt edge cases', () {
    test('asInt(double.infinity) fails safely instead of throwing', () {
      final result = SafeParser.asInt(double.infinity);
      expect(result.success, isFalse);
      expect(result.value, isNull);
    });

    test('asInt(double.nan) fails safely instead of throwing', () {
      final result = SafeParser.asInt(double.nan);
      expect(result.success, isFalse);
      expect(result.value, isNull);
    });

    test('asInt(double.negativeInfinity) fails safely instead of throwing', () {
      final result = SafeParser.asInt(double.negativeInfinity);
      expect(result.success, isFalse);
      expect(result.value, isNull);
    });

    test('asInt("99999999999999999999") - large string parsed via double', () {
      // int.tryParse overflows → null, then double.tryParse succeeds
      final result = SafeParser.asInt('99999999999999999999');
      expect(result.success, isTrue);
      expect(result.warning, contains('String (via double)'));
      expect(result.value, isNotNull);
    });

    test('asInt(double.maxFinite) converts without error', () {
      final result = SafeParser.asInt(double.maxFinite);
      expect(result.success, isTrue);
      expect(result.value, isNotNull);
    });
  });

  // ==========================================================================
  // SafeParser.asDouble - special string values
  // ==========================================================================
  group('SafeParser.asDouble edge cases', () {
    test('asDouble("-0.0") parses as double', () {
      final result = SafeParser.asDouble('-0.0');
      expect(result.success, isTrue);
      expect(result.value, equals(0.0));
      expect(result.warning, contains('String'));
    });

    test('asDouble("Infinity") parses as double.infinity', () {
      final result = SafeParser.asDouble('Infinity');
      expect(result.success, isTrue);
      expect(result.value, double.infinity);
    });

    test('asDouble("-Infinity") parses as negative infinity', () {
      final result = SafeParser.asDouble('-Infinity');
      expect(result.success, isTrue);
      expect(result.value, double.negativeInfinity);
    });

    test('asDouble("NaN") parses as NaN', () {
      final result = SafeParser.asDouble('NaN');
      expect(result.success, isTrue);
      expect(result.value!.isNaN, isTrue);
    });

    test('asDouble(true) fails - bool not supported for double', () {
      final result = SafeParser.asDouble(true);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected double'));
    });
  });

  // ==========================================================================
  // SafeParser.asBool - non-0/1 ints
  // ==========================================================================
  group('SafeParser.asBool edge cases', () {
    test('asBool(2) coerces to true', () {
      final result = SafeParser.asBool(2);
      expect(result.success, isTrue);
      expect(result.value, isTrue);
    });

    test('asBool(-1) coerces to true', () {
      final result = SafeParser.asBool(-1);
      expect(result.success, isTrue);
      expect(result.value, isTrue);
    });

    test('asBool(999) coerces to true', () {
      final result = SafeParser.asBool(999);
      expect(result.success, isTrue);
      expect(result.value, isTrue);
    });

    test('asBool("YES") coerces to true (case insensitive)', () {
      final result = SafeParser.asBool('YES');
      expect(result.success, isTrue);
      expect(result.value, isTrue);
    });

    test('asBool("NO") coerces to false (case insensitive)', () {
      final result = SafeParser.asBool('NO');
      expect(result.success, isTrue);
      expect(result.value, isFalse);
    });

    test('asBool(" true ") coerces to true (trimmed)', () {
      final result = SafeParser.asBool(' true ');
      expect(result.success, isTrue);
      expect(result.value, isTrue);
    });

    test('asBool("maybe") fails', () {
      final result = SafeParser.asBool('maybe');
      expect(result.success, isFalse);
    });

    test('asBool(double) fails - double not supported for bool', () {
      final result = SafeParser.asBool(1.5);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected bool'));
    });
  });

  // ==========================================================================
  // SafeParser.asDateTime - negative/zero timestamps, unsupported types
  // ==========================================================================
  group('SafeParser.asDateTime edge cases', () {
    test('asDateTime(-86400) - before epoch, treated as seconds', () {
      final result = SafeParser.asDateTime(-86400);
      expect(result.success, isTrue);
      final expected = DateTime.fromMillisecondsSinceEpoch(-86400 * 1000);
      expect(result.value, equals(expected));
      expect(result.warning, contains('int (seconds)'));
    });

    test('asDateTime(0) - epoch zero, treated as seconds', () {
      final result = SafeParser.asDateTime(0);
      expect(result.success, isTrue);
      expect(result.value, equals(DateTime.fromMillisecondsSinceEpoch(0)));
    });

    test('asDateTime(1.5) - double fails', () {
      final result = SafeParser.asDateTime(1.5);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected DateTime'));
    });

    test('asDateTime(true) - bool fails', () {
      final result = SafeParser.asDateTime(true);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected DateTime'));
    });

    test('asDateTime([]) - list fails', () {
      final result = SafeParser.asDateTime([]);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected DateTime'));
    });
  });

  // ==========================================================================
  // SafeParser.asString - non-primitive inputs
  // ==========================================================================
  group('SafeParser.asString edge cases', () {
    test('asString([1,2,3]) - list fails', () {
      final result = SafeParser.asString([1, 2, 3]);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected String'));
    });

    test('asString({"key": "val"}) - map fails', () {
      final result = SafeParser.asString({'key': 'val'});
      expect(result.success, isFalse);
      expect(result.warning, contains('expected String'));
    });

    test('asString("") - empty string is valid', () {
      final result = SafeParser.asString('');
      expect(result.success, isTrue);
      expect(result.value, equals(''));
      expect(result.warning, isNull);
    });

    test('asString(42) - int coerces to "42"', () {
      final result = SafeParser.asString(42);
      expect(result.success, isTrue);
      expect(result.value, equals('42'));
      expect(result.warning, contains('int'));
    });

    test('asString(3.14) - double coerces to string', () {
      final result = SafeParser.asString(3.14);
      expect(result.success, isTrue);
      expect(result.value, equals('3.14'));
    });
  });

  // ==========================================================================
  // SafeParser.asList - invalid inputs
  // ==========================================================================
  group('SafeParser.asList edge cases', () {
    test('asList with String value fails', () {
      final result = SafeParser.asList<int>('not a list', (e) => e as int);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected List'));
    });

    test('asList with Map value fails', () {
      final result = SafeParser.asList<int>({'key': 1}, (e) => e as int);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected List'));
    });

    test('asList with int value fails', () {
      final result = SafeParser.asList<int>(42, (e) => e as int);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected List'));
    });

    test('asList with parser that throws fails gracefully', () {
      final result = SafeParser.asList<int>(
        [1, 'bad', 3],
        (e) => e as int,
      );
      expect(result.success, isFalse);
      expect(result.warning, contains("couldn't parse list items"));
    });
  });

  // ==========================================================================
  // SafeParser.asMap - invalid inputs
  // ==========================================================================
  group('SafeParser.asMap edge cases', () {
    test('asMap with List value fails', () {
      final result = SafeParser.asMap([1, 2, 3]);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected Map'));
    });

    test('asMap with String value fails', () {
      final result = SafeParser.asMap('not a map');
      expect(result.success, isFalse);
      expect(result.warning, contains('expected Map'));
    });

    test('asMap with int value fails', () {
      final result = SafeParser.asMap(42);
      expect(result.success, isFalse);
      expect(result.warning, contains('expected Map'));
    });

    test('asMap with empty Map<String, dynamic> returns ok', () {
      final result = SafeParser.asMap(<String, dynamic>{});
      expect(result.success, isTrue);
      expect(result.value, isEmpty);
      expect(result.warning, isNull);
    });
  });

  // ==========================================================================
  // SafeParser._preview - truncation boundary (tested via error messages)
  // ==========================================================================
  group('SafeParser._preview truncation boundary', () {
    test('50-char string is NOT truncated', () {
      final str = 'a' * 50;
      final result = SafeParser.asInt(str);
      expect(result.success, isFalse);
      expect(result.warning, contains(str));
      expect(result.warning, isNot(contains('...')));
    });

    test('51-char string IS truncated with "..."', () {
      final str = 'b' * 51;
      final result = SafeParser.asInt(str);
      expect(result.success, isFalse);
      expect(result.warning, contains('${'b' * 50}...'));
    });

    test('100-char string is truncated to 50 + "..."', () {
      final str = 'c' * 100;
      final result = SafeParser.asInt(str);
      expect(result.success, isFalse);
      expect(result.warning, contains('${'c' * 50}...'));
      expect(result.warning, isNot(contains('c' * 51)));
    });
  });

  // ==========================================================================
  // ParseResult factory constructors
  // ==========================================================================
  group('ParseResult edge cases', () {
    test('ParseResult.ok stores value correctly', () {
      final r = ParseResult<int>.ok(42);
      expect(r.value, 42);
      expect(r.success, isTrue);
      expect(r.warning, isNull);
      expect(r.originalType, isNull);
      expect(r.originalValue, isNull);
    });

    test('ParseResult.nullValue has success true', () {
      final r = ParseResult<int>.nullValue();
      expect(r.value, isNull);
      expect(r.success, isTrue);
      expect(r.warning, 'null');
    });

    test('ParseResult.failed stores original info', () {
      final r = ParseResult<int>.failed('bad', 'hello');
      expect(r.value, isNull);
      expect(r.success, isFalse);
      expect(r.originalType, 'String');
      expect(r.originalValue, 'hello');
    });

    test('ParseResult.coerced stores original info', () {
      final r = ParseResult<int>.coerced(42, 'String', '42');
      expect(r.value, 42);
      expect(r.success, isTrue);
      expect(r.originalType, 'String');
      expect(r.originalValue, '42');
    });

    test('ParseResult.failed with null original has null originalType', () {
      final r = ParseResult<int>.failed('bad', null);
      expect(r.originalType, isNull);
    });
  });

  // ==========================================================================
  // inferType edge cases
  // ==========================================================================
  group('SafeParser.inferType edge cases', () {
    test('inferType with empty map', () {
      expect(SafeParser.inferType({}), 'Map<String, dynamic>?');
    });

    test('inferType with Set (unknown type)', () {
      expect(SafeParser.inferType({1, 2, 3}), 'dynamic?');
    });

    test('inferType with nested list of maps', () {
      final result = SafeParser.inferType([
        {'a': 1}
      ]);
      // inferType on a Map returns 'Map<String, dynamic>?' (nullable)
      // But inside a List, inferType is called with nullable:false on elements
      // So first element type is 'Map<String, dynamic>', List becomes List<Map<String, dynamic>>?
      expect(result, 'List<Map<String, dynamic>>?');
    });

    test('inferType nullable false', () {
      expect(SafeParser.inferType(42, nullable: false), 'int');
      expect(SafeParser.inferType('hi', nullable: false), 'String');
    });
  });
}
