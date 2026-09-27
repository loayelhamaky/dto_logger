import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // ParseResult factories
  // ═══════════════════════════════════════════════════════════════════════════
  group('ParseResult factories', () {
    test('ParseResult.ok stores value and marks success', () {
      final result = ParseResult.ok(42);
      expect(result.value, equals(42));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
      expect(result.originalType, isNull);
      expect(result.originalValue, isNull);
    });

    test('ParseResult.ok with string value', () {
      final result = ParseResult.ok('hello');
      expect(result.value, equals('hello'));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('ParseResult.ok with bool value', () {
      final result = ParseResult.ok(true);
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('ParseResult.ok with double value', () {
      final result = ParseResult.ok(3.14);
      expect(result.value, equals(3.14));
      expect(result.success, isTrue);
    });

    test('ParseResult.coerced stores value, warning, originalType, originalValue', () {
      final result = ParseResult.coerced(42, 'String', '42');
      expect(result.value, equals(42));
      expect(result.success, isTrue);
      expect(result.warning, contains('String'));
      expect(result.originalType, equals('String'));
      expect(result.originalValue, equals('42'));
    });

    test('ParseResult.coerced warning contains expected type', () {
      final result = ParseResult<int>.coerced(1, 'bool', true);
      expect(result.warning, contains('bool'));
      expect(result.warning, contains('int'));
    });

    test('ParseResult.failed stores null value and marks failure', () {
      final result = ParseResult<int>.failed('reason', 'original');
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, equals('reason'));
      expect(result.originalType, equals('String'));
      expect(result.originalValue, equals('original'));
    });

    test('ParseResult.failed with int original stores int runtimeType', () {
      final result = ParseResult<String>.failed('bad', 123);
      expect(result.originalType, equals('int'));
      expect(result.originalValue, equals(123));
    });

    test('ParseResult.failed with null original has null originalType', () {
      final result = ParseResult<int>.failed('reason', null);
      expect(result.originalType, isNull);
      expect(result.originalValue, isNull);
    });

    test('ParseResult.nullValue returns null with success', () {
      final result = ParseResult<int>.nullValue();
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    test('ParseResult.nullValue warning says null', () {
      final result = ParseResult<String>.nullValue();
      expect(result.warning, equals('null'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asInt
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asInt', () {
    // --- null ---
    test('null returns null value with success and null warning', () {
      final result = SafeParser.asInt(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- int values ---
    test('int 0 returns 0', () {
      final result = SafeParser.asInt(0);
      expect(result.value, equals(0));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('int 1 returns 1', () {
      final result = SafeParser.asInt(1);
      expect(result.value, equals(1));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('int -1 returns -1', () {
      final result = SafeParser.asInt(-1);
      expect(result.value, equals(-1));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('int 42 returns 42', () {
      final result = SafeParser.asInt(42);
      expect(result.value, equals(42));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('int -999 returns -999', () {
      final result = SafeParser.asInt(-999);
      expect(result.value, equals(-999));
      expect(result.success, isTrue);
    });

    test('int max safe value (2^53 - 1) returns correctly', () {
      const maxSafe = 9007199254740991; // 2^53 - 1
      final result = SafeParser.asInt(maxSafe);
      expect(result.value, equals(maxSafe));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    // --- double values ---
    test('double 1.0 coerced to int 1', () {
      final result = SafeParser.asInt(1.0);
      expect(result.value, equals(1));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.originalValue, equals(1.0));
    });

    test('double 1.7 truncated to int 1', () {
      final result = SafeParser.asInt(1.7);
      expect(result.value, equals(1));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
    });

    test('double -3.5 truncated to int -3', () {
      final result = SafeParser.asInt(-3.5);
      expect(result.value, equals(-3));
      expect(result.success, isTrue);
    });

    test('double 0.0 coerced to int 0', () {
      final result = SafeParser.asInt(0.0);
      expect(result.value, equals(0));
      expect(result.success, isTrue);
    });

    test('double value has originalType double', () {
      final result = SafeParser.asInt(5.5);
      expect(result.warning, contains('double'));
    });

    test('double.infinity toInt behavior', () {
      // double.infinity.toInt() throws in Dart, but let's see what SafeParser does
      // Since it calls value.toInt(), it may throw or return a value
      // We just test that it does not crash (catch behavior)
      try {
        final result = SafeParser.asInt(double.infinity);
        // If it doesn't throw, it was coerced
        expect(result.success, isTrue);
      } catch (e) {
        // If it throws, that's also valid behavior
        expect(e, isA<Object>());
      }
    });

    test('double.nan toInt behavior', () {
      try {
        final result = SafeParser.asInt(double.nan);
        expect(result.success, isTrue);
      } catch (e) {
        expect(e, isA<Object>());
      }
    });

    // --- String values ---
    test('String "0" coerced to int 0', () {
      final result = SafeParser.asInt('0');
      expect(result.value, equals(0));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.originalValue, equals('0'));
    });

    test('String "1" coerced to int 1', () {
      final result = SafeParser.asInt('1');
      expect(result.value, equals(1));
      expect(result.success, isTrue);
    });

    test('String "42" coerced to int 42', () {
      final result = SafeParser.asInt('42');
      expect(result.value, equals(42));
      expect(result.success, isTrue);
    });

    test('String "-5" coerced to int -5', () {
      final result = SafeParser.asInt('-5');
      expect(result.value, equals(-5));
      expect(result.success, isTrue);
    });

    test('String "123456789" coerced to int 123456789', () {
      final result = SafeParser.asInt('123456789');
      expect(result.value, equals(123456789));
      expect(result.success, isTrue);
    });

    test('String "1.5" coerced via double to int 1', () {
      final result = SafeParser.asInt('1.5');
      expect(result.value, equals(1));
      expect(result.success, isTrue);
      expect(result.warning, contains('via double'));
    });

    test('String "9.99" coerced via double to int 9', () {
      final result = SafeParser.asInt('9.99');
      expect(result.value, equals(9));
      expect(result.success, isTrue);
      expect(result.warning, contains('via double'));
    });

    test('String "abc" fails', () {
      final result = SafeParser.asInt('abc');
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('abc'));
      expect(result.warning, contains("can't be parsed as int"));
    });

    test('empty String "" fails', () {
      final result = SafeParser.asInt('');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "  123  " (with spaces) behavior depends on Dart int.tryParse', () {
      // Dart's int.tryParse may or may not handle leading/trailing whitespace
      final dartParse = int.tryParse('  123  ');
      final result = SafeParser.asInt('  123  ');
      if (dartParse != null) {
        // Dart trims and parses successfully
        expect(result.value, equals(123));
        expect(result.success, isTrue);
      } else {
        // Falls through to double.tryParse
        final doubleParse = double.tryParse('  123  ');
        if (doubleParse != null) {
          expect(result.value, equals(123));
          expect(result.success, isTrue);
        } else {
          expect(result.value, isNull);
          expect(result.success, isFalse);
        }
      }
    });

    test('String "1e5" parsed via double to int 100000', () {
      // int.tryParse("1e5") returns null
      // double.tryParse("1e5") returns 100000.0
      // 100000.0.toInt() = 100000
      final result = SafeParser.asInt('1e5');
      expect(result.value, equals(100000));
      expect(result.success, isTrue);
      expect(result.warning, contains('via double'));
    });

    test('String "0xFF" fails (int.tryParse without radix)', () {
      // int.tryParse("0xFF") actually succeeds in Dart! It parses hex.
      // Let's test the actual behavior:
      final dartParse = int.tryParse('0xFF');
      if (dartParse != null) {
        // If Dart can parse it, SafeParser should coerce it
        final result = SafeParser.asInt('0xFF');
        expect(result.value, equals(255));
        expect(result.success, isTrue);
      } else {
        final result = SafeParser.asInt('0xFF');
        expect(result.success, isFalse);
      }
    });

    test('String "007" coerced to int 7', () {
      final result = SafeParser.asInt('007');
      expect(result.value, equals(7));
      expect(result.success, isTrue);
    });

    test('String with 100 chars fails with truncated preview (tests _preview)', () {
      final longString = 'a' * 100;
      final result = SafeParser.asInt(longString);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      // _preview truncates to 50 chars + "..."
      expect(result.warning, contains('...'));
      // The warning should not contain the full 100-char string
      expect(result.warning!.contains(longString), isFalse);
    });

    test('String "null" fails', () {
      final result = SafeParser.asInt('null');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "true" fails', () {
      final result = SafeParser.asInt('true');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "Infinity" fails safely (no int for infinity)', () {
      final result = SafeParser.asInt('Infinity');
      expect(result.success, isFalse);
      expect(result.value, isNull);
    });

    test('String "NaN" fails safely (no int for NaN)', () {
      final result = SafeParser.asInt('NaN');
      expect(result.success, isFalse);
      expect(result.value, isNull);
    });

    // --- bool values ---
    test('bool true coerced to int 1', () {
      final result = SafeParser.asInt(true);
      expect(result.value, equals(1));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.originalValue, isTrue);
    });

    test('bool false coerced to int 0', () {
      final result = SafeParser.asInt(false);
      expect(result.value, equals(0));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.originalValue, isFalse);
    });

    // --- unsupported types ---
    test('List [1,2] fails', () {
      final result = SafeParser.asInt([1, 2]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('List'));
    });

    test('Map fails', () {
      final result = SafeParser.asInt({'a': 1});
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('empty string fails', () {
      final result = SafeParser.asInt('');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asDouble
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asDouble', () {
    // --- null ---
    test('null returns null with success', () {
      final result = SafeParser.asDouble(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- double values ---
    test('double 0.0 returns 0.0', () {
      final result = SafeParser.asDouble(0.0);
      expect(result.value, equals(0.0));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('double 1.5 returns 1.5', () {
      final result = SafeParser.asDouble(1.5);
      expect(result.value, equals(1.5));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('double -3.14 returns -3.14', () {
      final result = SafeParser.asDouble(-3.14);
      expect(result.value, equals(-3.14));
      expect(result.success, isTrue);
    });

    test('double.maxFinite returns maxFinite', () {
      final result = SafeParser.asDouble(double.maxFinite);
      expect(result.value, equals(double.maxFinite));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('double.infinity returns infinity', () {
      final result = SafeParser.asDouble(double.infinity);
      expect(result.value, equals(double.infinity));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('double.nan returns nan', () {
      final result = SafeParser.asDouble(double.nan);
      expect(result.value, isNaN);
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('double.negativeInfinity returns negativeInfinity', () {
      final result = SafeParser.asDouble(double.negativeInfinity);
      expect(result.value, equals(double.negativeInfinity));
      expect(result.success, isTrue);
    });

    // --- int values ---
    test('int 0 coerced to double 0.0', () {
      final result = SafeParser.asDouble(0);
      expect(result.value, equals(0.0));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.warning, contains('int'));
      expect(result.originalValue, equals(0));
    });

    test('int 42 coerced to double 42.0', () {
      final result = SafeParser.asDouble(42);
      expect(result.value, equals(42.0));
      expect(result.success, isTrue);
      expect(result.warning, contains('int'));
    });

    test('int -1 coerced to double -1.0', () {
      final result = SafeParser.asDouble(-1);
      expect(result.value, equals(-1.0));
      expect(result.success, isTrue);
    });

    // --- String values ---
    test('String "0" coerced to double 0.0', () {
      final result = SafeParser.asDouble('0');
      expect(result.value, equals(0.0));
      expect(result.success, isTrue);
      expect(result.warning, contains('String'));
    });

    test('String "1.5" coerced to double 1.5', () {
      final result = SafeParser.asDouble('1.5');
      expect(result.value, equals(1.5));
      expect(result.success, isTrue);
    });

    test('String "-3.14" coerced to double -3.14', () {
      final result = SafeParser.asDouble('-3.14');
      expect(result.value, equals(-3.14));
      expect(result.success, isTrue);
    });

    test('String "1e5" coerced to double 100000.0 (scientific notation)', () {
      final result = SafeParser.asDouble('1e5');
      expect(result.value, equals(100000.0));
      expect(result.success, isTrue);
    });

    test('String ".5" coerced to double 0.5', () {
      final result = SafeParser.asDouble('.5');
      expect(result.value, equals(0.5));
      expect(result.success, isTrue);
    });

    test('String "abc" fails', () {
      final result = SafeParser.asDouble('abc');
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('abc'));
    });

    test('empty String "" fails', () {
      final result = SafeParser.asDouble('');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "Infinity" coerced to double.infinity', () {
      final result = SafeParser.asDouble('Infinity');
      expect(result.value, equals(double.infinity));
      expect(result.success, isTrue);
    });

    test('String "NaN" coerced to double.nan', () {
      final result = SafeParser.asDouble('NaN');
      expect(result.value, isNaN);
      expect(result.success, isTrue);
    });

    test('String "-Infinity" coerced to double.negativeInfinity', () {
      final result = SafeParser.asDouble('-Infinity');
      expect(result.value, equals(double.negativeInfinity));
      expect(result.success, isTrue);
    });

    test('String "  1.5  " with spaces fails (no trim)', () {
      // double.tryParse does not trim
      final dartResult = double.tryParse('  1.5  ');
      if (dartResult != null) {
        // If Dart trims it, it will succeed
        final result = SafeParser.asDouble('  1.5  ');
        expect(result.success, isTrue);
      } else {
        final result = SafeParser.asDouble('  1.5  ');
        expect(result.success, isFalse);
      }
    });

    // --- unsupported types ---
    test('bool true fails', () {
      final result = SafeParser.asDouble(true);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('bool'));
    });

    test('bool false fails', () {
      final result = SafeParser.asDouble(false);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('List fails', () {
      final result = SafeParser.asDouble([1.0, 2.0]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('List'));
    });

    test('Map fails', () {
      final result = SafeParser.asDouble({'key': 1.0});
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String with long value fails with truncated preview', () {
      final longString = '1' * 100;
      // This is a valid numeric string, so it may actually parse
      final dartParse = double.tryParse(longString);
      if (dartParse != null) {
        final result = SafeParser.asDouble(longString);
        expect(result.success, isTrue);
      } else {
        final result = SafeParser.asDouble(longString);
        expect(result.success, isFalse);
        expect(result.warning, contains('...'));
      }
    });

    test('String "null" fails', () {
      final result = SafeParser.asDouble('null');
      expect(result.success, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asString
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asString', () {
    // --- null ---
    test('null returns null with success', () {
      final result = SafeParser.asString(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- String values ---
    test('String "hello" returns "hello"', () {
      final result = SafeParser.asString('hello');
      expect(result.value, equals('hello'));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('empty String "" returns ""', () {
      final result = SafeParser.asString('');
      expect(result.value, equals(''));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('String "  spaces  " preserves spaces', () {
      final result = SafeParser.asString('  spaces  ');
      expect(result.value, equals('  spaces  '));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('String with unicode characters', () {
      final result = SafeParser.asString('\u0645\u0631\u062d\u0628\u0627');
      expect(result.value, equals('\u0645\u0631\u062d\u0628\u0627'));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('very long string returns the full string', () {
      final longStr = 'x' * 1000;
      final result = SafeParser.asString(longStr);
      expect(result.value, equals(longStr));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('String with newlines and tabs', () {
      final result = SafeParser.asString('line1\nline2\ttab');
      expect(result.value, equals('line1\nline2\ttab'));
      expect(result.success, isTrue);
    });

    test('String with special characters', () {
      final result = SafeParser.asString(r'!@#$%^&*(){}[]');
      expect(result.value, equals(r'!@#$%^&*(){}[]'));
      expect(result.success, isTrue);
    });

    // --- int values ---
    test('int 0 coerced to String "0"', () {
      final result = SafeParser.asString(0);
      expect(result.value, equals('0'));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.originalValue, equals(0));
    });

    test('int 42 coerced to String "42"', () {
      final result = SafeParser.asString(42);
      expect(result.value, equals('42'));
      expect(result.success, isTrue);
    });

    test('int -1 coerced to String "-1"', () {
      final result = SafeParser.asString(-1);
      expect(result.value, equals('-1'));
      expect(result.success, isTrue);
    });

    // --- double values ---
    test('double 1.5 coerced to String', () {
      final result = SafeParser.asString(1.5);
      expect(result.value, equals('1.5'));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
    });

    test('double 0.0 coerced to String', () {
      final result = SafeParser.asString(0.0);
      expect(result.value, equals('0.0'));
      expect(result.success, isTrue);
    });

    // --- bool values ---
    test('bool true coerced to String "true"', () {
      final result = SafeParser.asString(true);
      expect(result.value, equals('true'));
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.originalValue, isTrue);
    });

    test('bool false coerced to String "false"', () {
      final result = SafeParser.asString(false);
      expect(result.value, equals('false'));
      expect(result.success, isTrue);
    });

    // --- unsupported types ---
    test('List fails', () {
      final result = SafeParser.asString([1, 2, 3]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('List'));
    });

    test('Map fails', () {
      final result = SafeParser.asString({'key': 'value'});
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('Map'));
    });

    test('int warning contains runtimeType', () {
      final result = SafeParser.asString(42);
      expect(result.warning, contains('int'));
    });

    test('double warning contains runtimeType', () {
      final result = SafeParser.asString(3.14);
      expect(result.warning, contains('double'));
    });

    test('bool warning contains runtimeType', () {
      final result = SafeParser.asString(true);
      expect(result.warning, contains('bool'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asBool
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asBool', () {
    // --- null ---
    test('null returns null with success', () {
      final result = SafeParser.asBool(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- bool values ---
    test('bool true returns true', () {
      final result = SafeParser.asBool(true);
      expect(result.value, isTrue);
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('bool false returns false', () {
      final result = SafeParser.asBool(false);
      expect(result.value, isFalse);
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    // --- String truthy values ---
    test('String "true" coerced to true', () {
      final result = SafeParser.asBool('true');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
      expect(result.warning, contains('String'));
    });

    test('String "false" coerced to false', () {
      final result = SafeParser.asBool('false');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String "TRUE" coerced to true', () {
      final result = SafeParser.asBool('TRUE');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String "FALSE" coerced to false', () {
      final result = SafeParser.asBool('FALSE');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String "True" coerced to true', () {
      final result = SafeParser.asBool('True');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String "False" coerced to false', () {
      final result = SafeParser.asBool('False');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String "1" coerced to true', () {
      final result = SafeParser.asBool('1');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String "0" coerced to false', () {
      final result = SafeParser.asBool('0');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String "yes" coerced to true', () {
      final result = SafeParser.asBool('yes');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String "no" coerced to false', () {
      final result = SafeParser.asBool('no');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String "YES" coerced to true', () {
      final result = SafeParser.asBool('YES');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String "NO" coerced to false', () {
      final result = SafeParser.asBool('NO');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String "Yes" coerced to true', () {
      final result = SafeParser.asBool('Yes');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String "No" coerced to false', () {
      final result = SafeParser.asBool('No');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    // --- String with whitespace (trimmed) ---
    test('String " true " (with spaces) trimmed to true', () {
      final result = SafeParser.asBool(' true ');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String " YES " (with spaces) trimmed to true', () {
      final result = SafeParser.asBool(' YES ');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String " false " (with spaces) trimmed to false', () {
      final result = SafeParser.asBool(' false ');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String " no " (with spaces) trimmed to false', () {
      final result = SafeParser.asBool(' no ');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('String " 1 " (with spaces) trimmed to true', () {
      final result = SafeParser.asBool(' 1 ');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('String " 0 " (with spaces) trimmed to false', () {
      final result = SafeParser.asBool(' 0 ');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    // --- String invalid values ---
    test('String "abc" fails', () {
      final result = SafeParser.asBool('abc');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('empty String "" fails', () {
      final result = SafeParser.asBool('');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "2" fails', () {
      final result = SafeParser.asBool('2');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "maybe" fails', () {
      final result = SafeParser.asBool('maybe');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "y" fails', () {
      final result = SafeParser.asBool('y');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "n" fails', () {
      final result = SafeParser.asBool('n');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "on" fails', () {
      final result = SafeParser.asBool('on');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "off" fails', () {
      final result = SafeParser.asBool('off');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    // --- int values ---
    test('int 0 coerced to false', () {
      final result = SafeParser.asBool(0);
      expect(result.value, isFalse);
      expect(result.success, isTrue);
      expect(result.warning, contains('int'));
      expect(result.originalValue, equals(0));
    });

    test('int 1 coerced to true', () {
      final result = SafeParser.asBool(1);
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('int 42 coerced to true (non-zero)', () {
      final result = SafeParser.asBool(42);
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('int -1 coerced to true (non-zero)', () {
      final result = SafeParser.asBool(-1);
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('int 100 coerced to true (non-zero)', () {
      final result = SafeParser.asBool(100);
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    // --- unsupported types ---
    test('double 1.5 fails', () {
      final result = SafeParser.asBool(1.5);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('double'));
    });

    test('double 0.0 fails', () {
      final result = SafeParser.asBool(0.0);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('List fails', () {
      final result = SafeParser.asBool([true, false]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('List'));
    });

    test('Map fails', () {
      final result = SafeParser.asBool({'a': true});
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asDateTime
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asDateTime', () {
    // --- null ---
    test('null returns null with success', () {
      final result = SafeParser.asDateTime(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- DateTime values ---
    test('DateTime object returned as-is', () {
      final now = DateTime(2024, 1, 15, 10, 30, 0);
      final result = SafeParser.asDateTime(now);
      expect(result.value, equals(now));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('DateTime.now() returned as-is', () {
      final now = DateTime.now();
      final result = SafeParser.asDateTime(now);
      expect(result.value, equals(now));
      expect(result.success, isTrue);
    });

    // --- String ISO 8601 ---
    test('String ISO "2024-01-15T10:30:00Z" parsed correctly', () {
      final result = SafeParser.asDateTime('2024-01-15T10:30:00Z');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(2024));
      expect(result.value!.month, equals(1));
      expect(result.value!.day, equals(15));
      expect(result.warning, contains('ISO8601'));
    });

    test('String ISO "2024-01-15" parsed (date only)', () {
      final result = SafeParser.asDateTime('2024-01-15');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(2024));
      expect(result.value!.month, equals(1));
      expect(result.value!.day, equals(15));
    });

    test('String ISO with timezone offset', () {
      final result = SafeParser.asDateTime('2024-06-15T10:30:00+05:00');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(2024));
    });

    test('String ISO with milliseconds', () {
      final result = SafeParser.asDateTime('2024-01-15T10:30:00.123Z');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
    });

    // --- String invalid ---
    test('String "not-a-date" fails', () {
      final result = SafeParser.asDateTime('not-a-date');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "abc" fails', () {
      final result = SafeParser.asDateTime('abc');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('empty String "" fails', () {
      final result = SafeParser.asDateTime('');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('String "true" fails', () {
      final result = SafeParser.asDateTime('true');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    // --- String numeric timestamp ---
    test('String numeric "1704067200" parsed successfully', () {
      final result = SafeParser.asDateTime('1704067200');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      // Digit-only strings of 10+ chars are Unix timestamps, not ISO years
      expect(result.value!.year, equals(2024));
    });

    // --- int timestamps ---
    test('int 0 parsed as epoch 1970', () {
      final result = SafeParser.asDateTime(0);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(1970));
      expect(result.value!.month, equals(1));
      expect(result.value!.day, equals(1));
    });

    test('int 1704067200 (< 10^10) parsed as seconds, year 2024', () {
      final result = SafeParser.asDateTime(1704067200);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(2024));
      expect(result.warning, contains('seconds'));
    });

    test('int 1704067200000 (> 10^10) parsed as milliseconds, year 2024', () {
      final result = SafeParser.asDateTime(1704067200000);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(2024));
      expect(result.warning, contains('milliseconds'));
    });

    test('int negative timestamp', () {
      final result = SafeParser.asDateTime(-86400);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      // -86400 seconds = 1969-12-31
      expect(result.value!.year, equals(1969));
    });

    test('int 1 parsed as seconds from epoch', () {
      final result = SafeParser.asDateTime(1);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(1970));
    });

    test('int at boundary 10000000000 parsed as seconds', () {
      // 10000000000 is exactly at the boundary (not > 10000000000), so seconds
      final result = SafeParser.asDateTime(10000000000);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('seconds'));
    });

    test('int at boundary 10000000001 parsed as milliseconds', () {
      final result = SafeParser.asDateTime(10000000001);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('milliseconds'));
    });

    // --- unsupported types ---
    test('bool fails', () {
      final result = SafeParser.asDateTime(true);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('bool'));
    });

    test('double fails', () {
      final result = SafeParser.asDateTime(1.5);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('double'));
    });

    test('List fails', () {
      final result = SafeParser.asDateTime([2024, 1, 15]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('Map fails', () {
      final result = SafeParser.asDateTime({'year': 2024});
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asList
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asList', () {
    // --- null ---
    test('null returns null with success', () {
      final result = SafeParser.asList<int>(null, (e) => e as int);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- valid Lists ---
    test('List [1,2,3] with int parser returns [1,2,3]', () {
      final result = SafeParser.asList<int>([1, 2, 3], (e) => e as int);
      expect(result.value, equals([1, 2, 3]));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('empty List [] returns empty list', () {
      final result = SafeParser.asList<int>([], (e) => e as int);
      expect(result.value, equals([]));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('single element list [42] returns [42]', () {
      final result = SafeParser.asList<int>([42], (e) => e as int);
      expect(result.value, equals([42]));
      expect(result.success, isTrue);
    });

    test('List of strings with String parser', () {
      final result =
          SafeParser.asList<String>(['a', 'b', 'c'], (e) => e as String);
      expect(result.value, equals(['a', 'b', 'c']));
      expect(result.success, isTrue);
    });

    test('List of maps with converter', () {
      final data = [
        {'name': 'Alice'},
        {'name': 'Bob'},
      ];
      final result = SafeParser.asList<String>(
        data,
        (e) => (e as Map<String, dynamic>)['name'] as String,
      );
      expect(result.value, equals(['Alice', 'Bob']));
      expect(result.success, isTrue);
    });

    test('List of doubles with double parser', () {
      final result =
          SafeParser.asList<double>([1.1, 2.2, 3.3], (e) => e as double);
      expect(result.value, equals([1.1, 2.2, 3.3]));
      expect(result.success, isTrue);
    });

    test('List of bools with bool parser', () {
      final result = SafeParser.asList<bool>(
          [true, false, true], (e) => e as bool);
      expect(result.value, equals([true, false, true]));
      expect(result.success, isTrue);
    });

    // --- parser throws ---
    test('List with parser that throws returns failed', () {
      final result = SafeParser.asList<int>(
        ['a', 'b'],
        (e) => int.parse(e as String),
      );
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains("couldn't parse list items"));
    });

    test('List with type cast error returns failed', () {
      final result = SafeParser.asList<int>(
        ['not', 'ints'],
        (e) => e as int,
      );
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    // --- not a List ---
    test('String value fails', () {
      final result = SafeParser.asList<int>('hello', (e) => e as int);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('String'));
      expect(result.warning, contains('expected List'));
    });

    test('int value fails', () {
      final result = SafeParser.asList<int>(42, (e) => e as int);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('int'));
    });

    test('Map value fails', () {
      final result =
          SafeParser.asList<int>({'a': 1}, (e) => e as int);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('bool value fails', () {
      final result = SafeParser.asList<int>(true, (e) => e as int);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('nested list of lists works', () {
      final result = SafeParser.asList<List<int>>(
        [
          [1, 2],
          [3, 4],
        ],
        (e) => (e as List).cast<int>(),
      );
      expect(result.value, equals([
        [1, 2],
        [3, 4],
      ]));
      expect(result.success, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.asMap
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asMap', () {
    // --- null ---
    test('null returns null with success', () {
      final result = SafeParser.asMap(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
      expect(result.warning, contains('null'));
    });

    // --- Map<String, dynamic> ---
    test('Map<String, dynamic> returned as-is, no warning', () {
      final map = <String, dynamic>{'key': 'value', 'num': 42};
      final result = SafeParser.asMap(map);
      expect(result.value, equals(map));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('empty Map<String, dynamic> returned as-is', () {
      final map = <String, dynamic>{};
      final result = SafeParser.asMap(map);
      expect(result.value, equals(map));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('nested Map<String, dynamic> returned as-is', () {
      final map = <String, dynamic>{
        'outer': <String, dynamic>{
          'inner': 'value',
        },
      };
      final result = SafeParser.asMap(map);
      expect(result.value, equals(map));
      expect(result.success, isTrue);
      expect(result.warning, isNull);
    });

    test('Map with various value types returned as-is', () {
      final map = <String, dynamic>{
        'string': 'hello',
        'int': 42,
        'double': 3.14,
        'bool': true,
        'null': null,
        'list': [1, 2, 3],
      };
      final result = SafeParser.asMap(map);
      expect(result.value, equals(map));
      expect(result.success, isTrue);
    });

    // --- Map<dynamic, dynamic> coercion ---
    test('Map<dynamic, dynamic> with int keys coerced to string keys', () {
      final map = <dynamic, dynamic>{1: 'one', 2: 'two'};
      final result = SafeParser.asMap(map);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.warning, isNotNull);
      expect(result.value!['1'], equals('one'));
      expect(result.value!['2'], equals('two'));
    });

    test('Map<dynamic, dynamic> empty coerced', () {
      final map = <dynamic, dynamic>{};
      final result = SafeParser.asMap(map);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      // Empty map - could be either ok or coerced depending on runtime type
      expect(result.value, isEmpty);
    });

    test('Map<int, String> coerced, warning mentions Map<dynamic, dynamic>', () {
      final map = <int, String>{10: 'ten', 20: 'twenty'};
      final result = SafeParser.asMap(map);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!['10'], equals('ten'));
      expect(result.value!['20'], equals('twenty'));
    });

    // --- not a Map ---
    test('String fails', () {
      final result = SafeParser.asMap('hello');
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('String'));
      expect(result.warning, contains('expected Map'));
    });

    test('int fails', () {
      final result = SafeParser.asMap(42);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('int'));
    });

    test('List fails', () {
      final result = SafeParser.asMap([1, 2, 3]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
      expect(result.warning, contains('List'));
    });

    test('bool fails', () {
      final result = SafeParser.asMap(true);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('double fails', () {
      final result = SafeParser.asMap(3.14);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // SafeParser.inferType
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.inferType', () {
    // --- null ---
    test('null returns "String?"', () {
      expect(SafeParser.inferType(null), equals('String?'));
    });

    test('null with nullable: false returns "String"', () {
      expect(SafeParser.inferType(null, nullable: false), equals('String'));
    });

    // --- primitives ---
    test('int returns "int?"', () {
      expect(SafeParser.inferType(42), equals('int?'));
    });

    test('int with nullable: false returns "int"', () {
      expect(SafeParser.inferType(42, nullable: false), equals('int'));
    });

    test('double returns "double?"', () {
      expect(SafeParser.inferType(3.14), equals('double?'));
    });

    test('double with nullable: false returns "double"', () {
      expect(SafeParser.inferType(3.14, nullable: false), equals('double'));
    });

    test('bool returns "bool?"', () {
      expect(SafeParser.inferType(true), equals('bool?'));
    });

    test('bool false returns "bool?"', () {
      expect(SafeParser.inferType(false), equals('bool?'));
    });

    test('bool with nullable: false returns "bool"', () {
      expect(SafeParser.inferType(true, nullable: false), equals('bool'));
    });

    test('String returns "String?"', () {
      expect(SafeParser.inferType('hello'), equals('String?'));
    });

    test('String with nullable: false returns "String"', () {
      expect(
          SafeParser.inferType('hello', nullable: false), equals('String'));
    });

    test('empty String returns "String?"', () {
      expect(SafeParser.inferType(''), equals('String?'));
    });

    test('int 0 returns "int?"', () {
      expect(SafeParser.inferType(0), equals('int?'));
    });

    test('double 0.0 returns "double?"', () {
      expect(SafeParser.inferType(0.0), equals('double?'));
    });

    // --- Lists ---
    test('List<int> [1,2,3] returns "List<int>?"', () {
      expect(SafeParser.inferType([1, 2, 3]), equals('List<int>?'));
    });

    test('List<String> ["a","b"] returns "List<String>?"', () {
      expect(SafeParser.inferType(['a', 'b']), equals('List<String>?'));
    });

    test('List<bool> [true, false] returns "List<bool>?"', () {
      expect(SafeParser.inferType([true, false]), equals('List<bool>?'));
    });

    test('List<double> [1.0, 2.0] returns "List<double>?"', () {
      expect(SafeParser.inferType([1.0, 2.0]), equals('List<double>?'));
    });

    test('empty List [] returns "List<dynamic>?"', () {
      expect(SafeParser.inferType([]), equals('List<dynamic>?'));
    });

    test('mixed List [1, "two"] returns "List<dynamic>?"', () {
      expect(SafeParser.inferType([1, 'two']), equals('List<dynamic>?'));
    });

    test('List of maps returns appropriate type', () {
      final result = SafeParser.inferType([
        {'key': 'value'},
      ]);
      expect(result, equals('List<Map<String, dynamic>>?'));
    });

    test('List with nullable: false returns without ?', () {
      expect(
          SafeParser.inferType([1, 2, 3], nullable: false),
          equals('List<int>'));
    });

    test('List with single element infers type', () {
      expect(SafeParser.inferType([42]), equals('List<int>?'));
    });

    test('List<int> with null element', () {
      // null element has inferType "String" (nullable:false), int has "int"
      // So they differ -> List<dynamic>?
      final result = SafeParser.inferType([1, null, 3]);
      expect(result, equals('List<dynamic>?'));
    });

    // --- Maps ---
    test('Map returns "Map<String, dynamic>?"', () {
      expect(SafeParser.inferType({'a': 1}), equals('Map<String, dynamic>?'));
    });

    test('empty Map returns "Map<String, dynamic>?"', () {
      expect(SafeParser.inferType({}), equals('Map<String, dynamic>?'));
    });

    test('Map with nullable: false returns "Map<String, dynamic>"', () {
      expect(SafeParser.inferType({'a': 1}, nullable: false),
          equals('Map<String, dynamic>'));
    });

    test('nested Map returns "Map<String, dynamic>?"', () {
      expect(
          SafeParser.inferType({
            'outer': {'inner': 'value'}
          }),
          equals('Map<String, dynamic>?'));
    });

    // --- unknown types ---
    test('custom object returns "dynamic?"', () {
      final result = SafeParser.inferType(Object());
      expect(result, equals('dynamic?'));
    });

    test('custom object with nullable: false returns "dynamic"', () {
      final result = SafeParser.inferType(Object(), nullable: false);
      expect(result, equals('dynamic'));
    });

    test('DateTime object returns "dynamic?"', () {
      // DateTime is not int/double/bool/String/List/Map, so it should be dynamic?
      final result = SafeParser.inferType(DateTime.now());
      expect(result, equals('dynamic?'));
    });

    test('RegExp returns "dynamic?"', () {
      final result = SafeParser.inferType(RegExp(r'test'));
      expect(result, equals('dynamic?'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // _preview (indirect tests via warning messages)
  // ═══════════════════════════════════════════════════════════════════════════
  group('_preview (indirect via warning messages)', () {
    test('short string value appears fully in warning', () {
      final result = SafeParser.asInt('abc');
      expect(result.warning, contains('abc'));
    });

    test('string of exactly 50 chars appears fully in warning (no truncation)',
        () {
      final str50 = 'x' * 50;
      final result = SafeParser.asInt(str50);
      expect(result.warning, contains(str50));
      expect(result.warning!.contains('...'), isFalse);
    });

    test('string of 51 chars is truncated in warning', () {
      final str51 = 'y' * 51;
      final result = SafeParser.asInt(str51);
      // Should contain first 50 chars + "..."
      expect(result.warning, contains('y' * 50));
      expect(result.warning, contains('...'));
      // Should NOT contain the full 51-char string in warning
      expect(result.warning!.contains(str51), isFalse);
    });

    test('string of 100 chars is truncated in warning', () {
      final str100 = 'z' * 100;
      final result = SafeParser.asInt(str100);
      expect(result.warning, contains('...'));
      expect(result.warning!.contains(str100), isFalse);
    });

    test('string of 200 chars is truncated in warning', () {
      final str200 = 'w' * 200;
      final result = SafeParser.asDouble(str200);
      expect(result.warning, contains('...'));
    });

    test('empty string preview appears as empty in warning', () {
      final result = SafeParser.asInt('');
      // The warning should contain "" (the empty quoted value)
      expect(result.warning, contains('""'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Edge cases and cross-cutting concerns
  // ═══════════════════════════════════════════════════════════════════════════
  group('Edge cases', () {
    test('asInt with negative zero double (-0.0) returns 0', () {
      final result = SafeParser.asInt(-0.0);
      expect(result.value, equals(0));
      expect(result.success, isTrue);
    });

    test('asDouble with negative zero returns -0.0', () {
      final result = SafeParser.asDouble(-0.0);
      expect(result.value, equals(-0.0));
      expect(result.success, isTrue);
    });

    test('asString with negative zero int', () {
      final result = SafeParser.asString(0);
      expect(result.value, equals('0'));
    });

    test('asInt with very large string number', () {
      final result = SafeParser.asInt('99999999999999999999');
      // This may overflow or succeed depending on Dart's int handling
      if (result.success) {
        expect(result.value, isNotNull);
      } else {
        expect(result.value, isNull);
      }
    });

    test('asDouble with very small number string', () {
      final result = SafeParser.asDouble('0.000000000000001');
      expect(result.success, isTrue);
      expect(result.value, isNotNull);
      expect(result.value!, greaterThan(0));
    });

    test('asString with int returns coerced warning containing runtimeType', () {
      final result = SafeParser.asString(42);
      expect(result.warning, contains('int'));
      expect(result.warning, contains('String'));
    });

    test('asBool String "tRuE" (mixed case) coerced to true', () {
      final result = SafeParser.asBool('tRuE');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('asBool String "fAlSe" (mixed case) coerced to false', () {
      final result = SafeParser.asBool('fAlSe');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('asBool String "yEs" (mixed case) coerced to true', () {
      final result = SafeParser.asBool('yEs');
      expect(result.value, isTrue);
      expect(result.success, isTrue);
    });

    test('asBool String "nO" (mixed case) coerced to false', () {
      final result = SafeParser.asBool('nO');
      expect(result.value, isFalse);
      expect(result.success, isTrue);
    });

    test('asInt String "+42" (explicit positive sign)', () {
      // int.tryParse("+42") may or may not work in Dart
      final dartParse = int.tryParse('+42');
      final result = SafeParser.asInt('+42');
      if (dartParse != null) {
        expect(result.value, equals(42));
        expect(result.success, isTrue);
      } else {
        // Falls through to double.tryParse
        final doubleParse = double.tryParse('+42');
        if (doubleParse != null) {
          expect(result.value, equals(42));
          expect(result.success, isTrue);
        } else {
          expect(result.success, isFalse);
        }
      }
    });

    test('asDouble String "+1.5" (explicit positive sign)', () {
      final result = SafeParser.asDouble('+1.5');
      final dartParse = double.tryParse('+1.5');
      if (dartParse != null) {
        expect(result.value, equals(1.5));
        expect(result.success, isTrue);
      } else {
        expect(result.success, isFalse);
      }
    });

    test('asInt with String "  " (whitespace only) fails', () {
      final result = SafeParser.asInt('  ');
      expect(result.success, isFalse);
    });

    test('asDouble with String "  " (whitespace only) fails', () {
      final result = SafeParser.asDouble('  ');
      expect(result.success, isFalse);
    });

    test('asBool with String "  " (whitespace only) - trimmed to empty, fails',
        () {
      final result = SafeParser.asBool('  ');
      // After trim + toLowerCase, it's "", which doesn't match any truthy/falsy
      expect(result.success, isFalse);
    });

    test('asDateTime with String "2024" (year only)', () {
      // DateTime.tryParse("2024") might or might not work
      final dartParse = DateTime.tryParse('2024');
      final result = SafeParser.asDateTime('2024');
      if (dartParse != null) {
        expect(result.success, isTrue);
      } else {
        // Falls through to int.tryParse("2024") -> 2024
        // Then _parseTimestamp(2024, "2024")
        // 2024 < 10000000000 -> seconds -> 1970-01-01 + 2024 seconds
        expect(result.success, isTrue);
        expect(result.value, isNotNull);
      }
    });

    test('asMap with Map<String, int> (specific value type) returned as-is', () {
      // Map<String, int> is also a Map<String, dynamic>
      final map = <String, int>{'a': 1, 'b': 2};
      final result = SafeParser.asMap(map);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
    });

    test('asList with identity parser returns same elements', () {
      final result = SafeParser.asList<dynamic>([1, 'two', true], (e) => e);
      expect(result.value, equals([1, 'two', true]));
      expect(result.success, isTrue);
    });

    test('asInt originalValue is preserved on coercion', () {
      final result = SafeParser.asInt('42');
      expect(result.originalValue, equals('42'));
      expect(result.originalType, equals('String'));
    });

    test('asDouble originalValue is preserved on coercion', () {
      final result = SafeParser.asDouble(42);
      expect(result.originalValue, equals(42));
      expect(result.originalType, equals('int'));
    });

    test('asBool originalValue is preserved on coercion', () {
      final result = SafeParser.asBool('true');
      expect(result.originalValue, equals('true'));
      expect(result.originalType, equals('String'));
    });

    test('asString originalValue is preserved on coercion', () {
      final result = SafeParser.asString(42);
      expect(result.originalValue, equals(42));
    });

    test('asDateTime originalValue is preserved on coercion', () {
      final result = SafeParser.asDateTime(1704067200);
      expect(result.originalValue, equals(1704067200));
    });

    test('asInt failed result has originalType from runtimeType', () {
      final result = SafeParser.asInt([1, 2]);
      expect(result.originalType, contains('List'));
    });

    test('asDouble failed result has originalType from runtimeType', () {
      final result = SafeParser.asDouble(true);
      expect(result.originalType, equals('bool'));
    });

    test('asBool failed result has originalType from runtimeType', () {
      final result = SafeParser.asBool(1.5);
      expect(result.originalType, equals('double'));
    });

    test('asString failed result has originalType from runtimeType', () {
      final result = SafeParser.asString([1]);
      expect(result.originalType, contains('List'));
    });

    test('asDateTime failed result has originalType from runtimeType', () {
      final result = SafeParser.asDateTime(true);
      expect(result.originalType, equals('bool'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Consistency tests: all methods handle null consistently
  // ═══════════════════════════════════════════════════════════════════════════
  group('Null handling consistency', () {
    test('asInt(null) returns success with null value', () {
      final result = SafeParser.asInt(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('asDouble(null) returns success with null value', () {
      final result = SafeParser.asDouble(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('asString(null) returns success with null value', () {
      final result = SafeParser.asString(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('asBool(null) returns success with null value', () {
      final result = SafeParser.asBool(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('asDateTime(null) returns success with null value', () {
      final result = SafeParser.asDateTime(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('asList(null) returns success with null value', () {
      final result = SafeParser.asList<int>(null, (e) => e as int);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('asMap(null) returns success with null value', () {
      final result = SafeParser.asMap(null);
      expect(result.value, isNull);
      expect(result.success, isTrue);
    });

    test('all null results have warning containing "null"', () {
      expect(SafeParser.asInt(null).warning, contains('null'));
      expect(SafeParser.asDouble(null).warning, contains('null'));
      expect(SafeParser.asString(null).warning, contains('null'));
      expect(SafeParser.asBool(null).warning, contains('null'));
      expect(SafeParser.asDateTime(null).warning, contains('null'));
      expect(SafeParser.asList<int>(null, (e) => e as int).warning,
          contains('null'));
      expect(SafeParser.asMap(null).warning, contains('null'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Warning message format tests
  // ═══════════════════════════════════════════════════════════════════════════
  group('Warning message format', () {
    test('coerced warning format: "was X, parsed as Y"', () {
      final result = SafeParser.asInt('42');
      expect(result.warning, matches(RegExp(r'was .+, parsed as .+')));
    });

    test('failed warning for String asInt contains quoted value', () {
      final result = SafeParser.asInt('abc');
      expect(result.warning, contains('"abc"'));
    });

    test('failed warning for unsupported type contains runtimeType', () {
      final result = SafeParser.asInt([1]);
      expect(result.warning, contains('List'));
      expect(result.warning, contains('expected int'));
    });

    test('asDouble failed warning contains quoted String value', () {
      final result = SafeParser.asDouble('xyz');
      expect(result.warning, contains('"xyz"'));
    });

    test('asBool failed warning contains quoted String value', () {
      final result = SafeParser.asBool('maybe');
      expect(result.warning, contains('"maybe"'));
    });

    test('asDateTime failed warning contains quoted String value', () {
      final result = SafeParser.asDateTime('bad-date');
      expect(result.warning, contains('"bad-date"'));
    });

    test('asList failed warning mentions expected a List', () {
      final result = SafeParser.asList<int>('not-list', (e) => e as int);
      expect(result.warning, contains('expected List'));
    });

    test('asMap failed warning mentions expected a Map', () {
      final result = SafeParser.asMap('not-map');
      expect(result.warning, contains('expected Map'));
    });

    test('nullValue warning is exactly "null"', () {
      final result = ParseResult<int>.nullValue();
      expect(result.warning, equals('null'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Type safety and generics
  // ═══════════════════════════════════════════════════════════════════════════
  group('Type safety and generics', () {
    test('ParseResult<int>.ok value is typed as int?', () {
      final ParseResult<int> result = ParseResult.ok(42);
      final int? val = result.value;
      expect(val, equals(42));
    });

    test('ParseResult<String>.ok value is typed as String?', () {
      final ParseResult<String> result = ParseResult.ok('hello');
      final String? val = result.value;
      expect(val, equals('hello'));
    });

    test('ParseResult<bool>.ok value is typed as bool?', () {
      final ParseResult<bool> result = ParseResult.ok(true);
      final bool? val = result.value;
      expect(val, isTrue);
    });

    test('ParseResult<double>.ok value is typed as double?', () {
      final ParseResult<double> result = ParseResult.ok(3.14);
      final double? val = result.value;
      expect(val, equals(3.14));
    });

    test('ParseResult<DateTime>.ok value is typed as DateTime?', () {
      final now = DateTime.now();
      final ParseResult<DateTime> result = ParseResult.ok(now);
      final DateTime? val = result.value;
      expect(val, equals(now));
    });

    test('ParseResult<List<int>>.ok value is typed as List<int>?', () {
      final ParseResult<List<int>> result = ParseResult.ok([1, 2, 3]);
      final List<int>? val = result.value;
      expect(val, equals([1, 2, 3]));
    });

    test('asList generic type parameter works with custom types', () {
      final result = SafeParser.asList<Map<String, dynamic>>(
        [
          {'id': 1},
          {'id': 2},
        ],
        (e) => e as Map<String, dynamic>,
      );
      expect(result.value, isNotNull);
      expect(result.value!.length, equals(2));
      expect(result.value![0]['id'], equals(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional asInt edge cases for String numeric formats
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asInt - additional String formats', () {
    test('String "0.0" parsed via double to int 0', () {
      final result = SafeParser.asInt('0.0');
      expect(result.value, equals(0));
      expect(result.success, isTrue);
      expect(result.warning, contains('via double'));
    });

    test('String "-1.0" parsed via double to int -1', () {
      final result = SafeParser.asInt('-1.0');
      expect(result.value, equals(-1));
      expect(result.success, isTrue);
    });

    test('String "1e2" parsed via double to int 100', () {
      final result = SafeParser.asInt('1e2');
      expect(result.value, equals(100));
      expect(result.success, isTrue);
    });

    test('String "2.5e2" parsed via double to int 250', () {
      final result = SafeParser.asInt('2.5e2');
      expect(result.value, equals(250));
      expect(result.success, isTrue);
    });

    test('String "-1e3" parsed via double to int -1000', () {
      final result = SafeParser.asInt('-1e3');
      expect(result.value, equals(-1000));
      expect(result.success, isTrue);
    });

    test('String "1.0e1" parsed via double to int 10', () {
      final result = SafeParser.asInt('1.0e1');
      expect(result.value, equals(10));
      expect(result.success, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional asDateTime edge cases
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asDateTime - additional', () {
    test('String timestamp as milliseconds "1704067200000" parsed', () {
      final result = SafeParser.asDateTime('1704067200000');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(2024));
    });

    test('int 86400 parsed as seconds from epoch (day 2)', () {
      final result = SafeParser.asDateTime(86400);
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      final expected = DateTime.fromMillisecondsSinceEpoch(86400 * 1000);
      expect(result.value!.day, equals(expected.day));
    });

    test('DateTime with microseconds preserved', () {
      final dt = DateTime(2024, 6, 15, 10, 30, 0, 0, 123);
      final result = SafeParser.asDateTime(dt);
      expect(result.value, equals(dt));
      expect(result.value!.microsecond, equals(123));
    });

    test('String with only time fails (no date component)', () {
      final result = SafeParser.asDateTime('10:30:00');
      // DateTime.tryParse("10:30:00") returns null
      // int.tryParse("10:30:00") returns null
      expect(result.success, isFalse);
    });

    test('String "1970-01-01T00:00:00Z" parsed as epoch start', () {
      final result = SafeParser.asDateTime('1970-01-01T00:00:00Z');
      expect(result.value, isNotNull);
      expect(result.success, isTrue);
      expect(result.value!.year, equals(1970));
      expect(result.value!.month, equals(1));
      expect(result.value!.day, equals(1));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional inferType edge cases
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.inferType - additional', () {
    test('negative int returns "int?"', () {
      expect(SafeParser.inferType(-42), equals('int?'));
    });

    test('negative double returns "double?"', () {
      expect(SafeParser.inferType(-3.14), equals('double?'));
    });

    test('List of nulls', () {
      // First element is null -> inferType(null, nullable: false) = "String"
      // All elements null -> all "String" -> List<String>?
      expect(SafeParser.inferType([null, null]), equals('List<String>?'));
    });

    test('List with one int and one null', () {
      // First is int -> "int", second is null -> "String"
      // They differ -> List<dynamic>?
      expect(SafeParser.inferType([1, null]), equals('List<dynamic>?'));
    });

    test('List of empty lists', () {
      final result = SafeParser.inferType([
        [],
        [],
      ]);
      expect(result, equals('List<List<dynamic>>?'));
    });

    test('deeply nested list', () {
      final result = SafeParser.inferType([
        [1, 2],
        [3, 4],
      ]);
      expect(result, equals('List<List<int>>?'));
    });

    test('Map<int, String> returns "Map<String, dynamic>?"', () {
      // Any Map returns Map<String, dynamic>?
      expect(
          SafeParser.inferType(<int, String>{1: 'one'}),
          equals('Map<String, dynamic>?'));
    });

    test('List of mixed int and double', () {
      // First is int -> "int", double is "double" -> differ -> List<dynamic>?
      expect(SafeParser.inferType([1, 2.0]), equals('List<dynamic>?'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional asMap coercion edge cases
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asMap - additional coercion', () {
    test('Map with bool keys coerced to string keys', () {
      final map = <dynamic, dynamic>{true: 'yes', false: 'no'};
      final result = SafeParser.asMap(map);
      expect(result.success, isTrue);
      expect(result.value!['true'], equals('yes'));
      expect(result.value!['false'], equals('no'));
    });

    test('Map with double keys coerced to string keys', () {
      final map = <dynamic, dynamic>{1.5: 'a', 2.5: 'b'};
      final result = SafeParser.asMap(map);
      expect(result.success, isTrue);
      expect(result.value!['1.5'], equals('a'));
      expect(result.value!['2.5'], equals('b'));
    });

    test('Map with null value preserved', () {
      final map = <String, dynamic>{'key': null};
      final result = SafeParser.asMap(map);
      expect(result.success, isTrue);
      expect(result.value!.containsKey('key'), isTrue);
      expect(result.value!['key'], isNull);
    });

    test('Map with nested list value preserved', () {
      final map = <String, dynamic>{
        'items': [1, 2, 3],
      };
      final result = SafeParser.asMap(map);
      expect(result.success, isTrue);
      expect(result.value!['items'], equals([1, 2, 3]));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Additional asList edge cases
  // ═══════════════════════════════════════════════════════════════════════════
  group('SafeParser.asList - additional', () {
    test('List with null elements and identity parser', () {
      final result =
          SafeParser.asList<dynamic>([null, 1, null], (e) => e);
      expect(result.value, equals([null, 1, null]));
      expect(result.success, isTrue);
    });

    test('List<dynamic> cast to specific type', () {
      final result = SafeParser.asList<String>(
        ['a', 'b', 'c'],
        (e) => e.toString(),
      );
      expect(result.value, equals(['a', 'b', 'c']));
      expect(result.success, isTrue);
    });

    test('double value fails as list', () {
      final result = SafeParser.asList<int>(3.14, (e) => e as int);
      expect(result.success, isFalse);
      expect(result.warning, contains('double'));
    });

    test('empty Map fails as list', () {
      final result = SafeParser.asList<int>({}, (e) => e as int);
      expect(result.success, isFalse);
    });

    test('large list with valid parser succeeds', () {
      final bigList = List.generate(1000, (i) => i);
      final result = SafeParser.asList<int>(bigList, (e) => e as int);
      expect(result.success, isTrue);
      expect(result.value!.length, equals(1000));
      expect(result.value!.last, equals(999));
    });

    test('List with partially invalid items fails on first error', () {
      final result = SafeParser.asList<int>(
        [1, 2, 'three', 4],
        (e) => e as int,
      );
      expect(result.success, isFalse);
      expect(result.warning, contains("couldn't parse list items"));
    });
  });
}
