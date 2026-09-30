import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  group('snakeToCamel with numbers', () {
    test('user_2_name → user2Name', () {
      expect(CaseConverter.snakeToCamel('user_2_name'), 'user2Name');
    });

    test('item_3 → item3', () {
      expect(CaseConverter.snakeToCamel('item_3'), 'item3');
    });

    test('my_3rd_item → my3rdItem', () {
      expect(CaseConverter.snakeToCamel('my_3rd_item'), 'my3rdItem');
    });

    test('field_123_value → field123Value', () {
      expect(CaseConverter.snakeToCamel('field_123_value'), 'field123Value');
    });

    test('a1_b2_c3 → a1B2C3', () {
      expect(CaseConverter.snakeToCamel('a1_b2_c3'), 'a1B2C3');
    });
  });

  group('snakeToCamel single/short identifiers', () {
    test('single char "a" → "a"', () {
      expect(CaseConverter.snakeToCamel('a'), 'a');
    });

    test('single char "A" → "a" (lowercased)', () {
      expect(CaseConverter.snakeToCamel('A'), 'a');
    });

    test('single char "x" → "x"', () {
      expect(CaseConverter.snakeToCamel('x'), 'x');
    });

    test('empty string → empty string', () {
      expect(CaseConverter.snakeToCamel(''), '');
    });

    test('two chars "ab" → "ab"', () {
      expect(CaseConverter.snakeToCamel('ab'), 'ab');
    });
  });

  group('snakeToCamel all uppercase', () {
    test('HTTP_STATUS → httpStatus', () {
      expect(CaseConverter.snakeToCamel('HTTP_STATUS'), 'httpStatus');
    });

    test('API_KEY → apiKey', () {
      expect(CaseConverter.snakeToCamel('API_KEY'), 'apiKey');
    });

    test('X_Y_Z → xYZ', () {
      expect(CaseConverter.snakeToCamel('X_Y_Z'), 'xYZ');
    });

    test('ALL_CAPS_FIELD → allCapsField', () {
      expect(CaseConverter.snakeToCamel('ALL_CAPS_FIELD'), 'allCapsField');
    });
  });

  group('snakeToCamel consecutive underscores', () {
    test('my__field → myField (double underscore)', () {
      expect(CaseConverter.snakeToCamel('my__field'), 'myField');
    });

    test('a___b → aB (triple underscore)', () {
      expect(CaseConverter.snakeToCamel('a___b'), 'aB');
    });

    test('x____y → xY (quad underscore)', () {
      expect(CaseConverter.snakeToCamel('x____y'), 'xY');
    });
  });

  group('snakeToCamel only underscores', () {
    test('"_" → "_" (single underscore)', () {
      expect(CaseConverter.snakeToCamel('_'), '_');
    });

    test('"__" → "__" (double underscore)', () {
      expect(CaseConverter.snakeToCamel('__'), '__');
    });

    test('"___" → "___" (triple underscore)', () {
      expect(CaseConverter.snakeToCamel('___'), '___');
    });
  });

  group('snakeToCamel very long identifiers', () {
    test('100+ char snake_case converts correctly', () {
      // Build: a_b_c_d_... (50+ segments)
      final parts = List.generate(50, (i) => 'part$i');
      final snake = parts.join('_');
      final result = CaseConverter.snakeToCamel(snake);

      expect(result, startsWith('part0'));
      expect(result, contains('Part1'));
      expect(result, contains('Part49'));
      expect(result.length, greaterThan(100));
    });
  });

  group('camelToSnake with numbers', () {
    test('user2Name → user2_name', () {
      // Numbers don't trigger uppercase split
      expect(CaseConverter.camelToSnake('user2Name'), 'user2_name');
    });

    test('myItem3 → my_item3', () {
      expect(CaseConverter.camelToSnake('myItem3'), 'my_item3');
    });

    test('abc → abc (all lowercase, no change)', () {
      expect(CaseConverter.camelToSnake('abc'), 'abc');
    });
  });

  group('camelToSnake acronyms', () {
    test('HTTPResponse → http_response', () {
      expect(CaseConverter.camelToSnake('HTTPResponse'), 'http_response');
    });

    test('userID → user_id', () {
      expect(CaseConverter.camelToSnake('userID'), 'user_id');
    });

    test('getHTTPSUrl → get_https_url', () {
      expect(CaseConverter.camelToSnake('getHTTPSUrl'), 'get_https_url');
    });

    test('empty string → empty string', () {
      expect(CaseConverter.camelToSnake(''), '');
    });

    test('single char "A" → "a"', () {
      expect(CaseConverter.camelToSnake('A'), 'a');
    });

    test('single char "a" → "a"', () {
      expect(CaseConverter.camelToSnake('a'), 'a');
    });
  });

  group('snakeToPascal edge cases', () {
    test('empty string → empty string', () {
      expect(CaseConverter.snakeToPascal(''), '');
    });

    test('single char "a" → "A"', () {
      expect(CaseConverter.snakeToPascal('a'), 'A');
    });

    test('already PascalCase "UserName" → "UserName"', () {
      expect(CaseConverter.snakeToPascal('UserName'), 'UserName');
    });

    test('camelCase "userName" → "UserName"', () {
      expect(CaseConverter.snakeToPascal('userName'), 'UserName');
    });

    test('snake_case "user_name" → "UserName"', () {
      expect(CaseConverter.snakeToPascal('user_name'), 'UserName');
    });

    test('"_" → "_" (only underscore)', () {
      // snakeToCamel("_") → "_", then "_"[0].toUpper → "_" (non-alpha)
      final result = CaseConverter.snakeToPascal('_');
      expect(result, '_');
    });
  });

  group('isValidIdentifier edge cases', () {
    test('empty string is invalid', () {
      expect(CaseConverter.isValidIdentifier(''), isFalse);
    });

    test('"_" is valid', () {
      expect(CaseConverter.isValidIdentifier('_'), isTrue);
    });

    test('"_a" is valid', () {
      expect(CaseConverter.isValidIdentifier('_a'), isTrue);
    });

    test('"1abc" is invalid (starts with digit)', () {
      expect(CaseConverter.isValidIdentifier('1abc'), isFalse);
    });

    test('"abc123" is valid', () {
      expect(CaseConverter.isValidIdentifier('abc123'), isTrue);
    });

    test('"my-field" is invalid (dash)', () {
      expect(CaseConverter.isValidIdentifier('my-field'), isFalse);
    });

    test('"my field" is invalid (space)', () {
      expect(CaseConverter.isValidIdentifier('my field'), isFalse);
    });

    test('"camelCase" is valid', () {
      expect(CaseConverter.isValidIdentifier('camelCase'), isTrue);
    });
  });

  group('toValidIdentifier edge cases', () {
    test('empty string → "field"', () {
      expect(CaseConverter.toValidIdentifier(''), 'field');
    });

    test('"123field" → "field123field" (starts with digit)', () {
      final result = CaseConverter.toValidIdentifier('123field');
      expect(result, startsWith('field'));
    });

    test('"my-field" → "myField" (dash converted)', () {
      expect(CaseConverter.toValidIdentifier('my-field'), 'myField');
    });

    test('"my field" → "myField" (space converted)', () {
      expect(CaseConverter.toValidIdentifier('my field'), 'myField');
    });

    test('reserved word "class" → "class_"', () {
      expect(CaseConverter.toValidIdentifier('class'), 'class_');
    });

    test('reserved word "return" → "return_"', () {
      expect(CaseConverter.toValidIdentifier('return'), 'return_');
    });

    test('already valid "myField" → "myField"', () {
      expect(CaseConverter.toValidIdentifier('myField'), 'myField');
    });

    test('"a.b.c" → dots become underscores then camelCase', () {
      final result = CaseConverter.toValidIdentifier('a.b.c');
      expect(CaseConverter.isValidIdentifier(result), isTrue);
    });
  });
}
