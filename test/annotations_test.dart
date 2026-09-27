import 'package:test/test.dart';
import '../lib/src/annotations.dart';

// A dummy class used for NestedDto type tests

void main() {
  // =========================================================================
  // DtoLog
  // =========================================================================
  group('DtoLog', () {
    test('default constructor sets generateFromJson to true', () {
      const annotation = DtoLog();
      expect(annotation.generateFromJson, isTrue);
    });

    test('default constructor sets generateToJson to true', () {
      const annotation = DtoLog();
      expect(annotation.generateToJson, isTrue);
    });

    test('default constructor sets generateCopyWith to false', () {
      const annotation = DtoLog();
      expect(annotation.generateCopyWith, isFalse);
    });

    test('default constructor sets generateEquality to false', () {
      const annotation = DtoLog();
      expect(annotation.generateEquality, isFalse);
    });

    test('default constructor sets enableLogging to true', () {
      const annotation = DtoLog();
      expect(annotation.enableLogging, isTrue);
    });

    test('can set generateFromJson to false', () {
      const annotation = DtoLog(generateFromJson: false);
      expect(annotation.generateFromJson, isFalse);
    });

    test('can set generateToJson to false', () {
      const annotation = DtoLog(generateToJson: false);
      expect(annotation.generateToJson, isFalse);
    });

    test('can set generateCopyWith to true', () {
      const annotation = DtoLog(generateCopyWith: true);
      expect(annotation.generateCopyWith, isTrue);
    });

    test('can set generateEquality to true', () {
      const annotation = DtoLog(generateEquality: true);
      expect(annotation.generateEquality, isTrue);
    });

    test('can set enableLogging to false', () {
      const annotation = DtoLog(enableLogging: false);
      expect(annotation.enableLogging, isFalse);
    });

    test('can be created as const', () {
      const a = DtoLog();
      const b = DtoLog();
      expect(identical(a, b), isTrue);
    });

    test('two const instances with same params are identical', () {
      const a = DtoLog(enableLogging: false);
      const b = DtoLog(enableLogging: false);
      expect(identical(a, b), isTrue);
    });
  });

  // =========================================================================
  // DtoKey
  // =========================================================================
  group('DtoKey', () {
    group('main constructor', () {
      test('sets name from positional argument', () {
        const key = DtoKey('user_name');
        expect(key.name, equals('user_name'));
      });

      test('name can be null', () {
        const key = DtoKey(null);
        expect(key.name, isNull);
      });

      test('defaultValue is null by default', () {
        const key = DtoKey('field');
        expect(key.defaultValue, isNull);
      });

      test('required defaults to false', () {
        const key = DtoKey('field');
        expect(key.required, isFalse);
      });

      test('can set defaultValue to an int', () {
        const key = DtoKey('age', defaultValue: 0);
        expect(key.defaultValue, equals(0));
      });

      test('can set defaultValue to a String', () {
        const key = DtoKey('name', defaultValue: 'unknown');
        expect(key.defaultValue, equals('unknown'));
      });

      test('can set defaultValue to a bool', () {
        const key = DtoKey('active', defaultValue: false);
        expect(key.defaultValue, equals(false));
      });

      test('can set defaultValue to a double', () {
        const key = DtoKey('score', defaultValue: 0.0);
        expect(key.defaultValue, equals(0.0));
      });

      test('can set defaultValue to null explicitly', () {
        const key = DtoKey('field', defaultValue: null);
        expect(key.defaultValue, isNull);
      });

      test('can set defaultValue to a list', () {
        const key = DtoKey('tags', defaultValue: []);
        expect(key.defaultValue, equals([]));
      });

      test('can set defaultValue to a map', () {
        const key = DtoKey('meta', defaultValue: {});
        expect(key.defaultValue, equals({}));
      });

      test('can set required to true', () {
        const key = DtoKey('id', required: true);
        expect(key.required, isTrue);
      });

      test('can be created as const', () {
        const a = DtoKey('x');
        const b = DtoKey('x');
        expect(identical(a, b), isTrue);
      });

      test('name can be empty string', () {
        const key = DtoKey('');
        expect(key.name, equals(''));
      });
    });

    group('defaultValue constructor', () {
      test('sets defaultValue from positional argument', () {
        const key = DtoKey.defaultValue(42);
        expect(key.defaultValue, equals(42));
      });

      test('sets name to null', () {
        const key = DtoKey.defaultValue(42);
        expect(key.name, isNull);
      });

      test('sets required to false', () {
        const key = DtoKey.defaultValue(42);
        expect(key.required, isFalse);
      });

      test('can hold a String default', () {
        const key = DtoKey.defaultValue('hello');
        expect(key.defaultValue, equals('hello'));
      });

      test('can hold a bool default', () {
        const key = DtoKey.defaultValue(true);
        expect(key.defaultValue, isTrue);
      });

      test('can be created as const', () {
        const a = DtoKey.defaultValue(10);
        const b = DtoKey.defaultValue(10);
        expect(identical(a, b), isTrue);
      });
    });

    group('required constructor', () {
      test('sets required to true', () {
        const key = DtoKey.required();
        expect(key.required, isTrue);
      });

      test('sets name to null', () {
        const key = DtoKey.required();
        expect(key.name, isNull);
      });

      test('sets defaultValue to null', () {
        const key = DtoKey.required();
        expect(key.defaultValue, isNull);
      });

      test('can be created as const', () {
        const a = DtoKey.required();
        const b = DtoKey.required();
        expect(identical(a, b), isTrue);
      });
    });
  });

  // =========================================================================
  // DtoDefault
  // =========================================================================
  group('DtoDefault', () {
    test('stores a String value', () {
      const nd = DtoDefault('hello');
      expect(nd.value, equals('hello'));
    });

    test('stores an int value', () {
      const nd = DtoDefault(42);
      expect(nd.value, equals(42));
    });

    test('stores a double value', () {
      const nd = DtoDefault(3.14);
      expect(nd.value, equals(3.14));
    });

    test('stores a bool value (true)', () {
      const nd = DtoDefault(true);
      expect(nd.value, isTrue);
    });

    test('stores a bool value (false)', () {
      const nd = DtoDefault(false);
      expect(nd.value, isFalse);
    });

    test('stores a null value', () {
      const nd = DtoDefault(null);
      expect(nd.value, isNull);
    });

    test('stores an empty string', () {
      const nd = DtoDefault('');
      expect(nd.value, equals(''));
    });

    test('stores zero', () {
      const nd = DtoDefault(0);
      expect(nd.value, equals(0));
    });

    test('stores an empty list', () {
      const nd = DtoDefault([]);
      expect(nd.value, equals([]));
    });

    test('stores an empty map', () {
      const nd = DtoDefault({});
      expect(nd.value, equals({}));
    });

    test('can be created as const', () {
      const a = DtoDefault(99);
      const b = DtoDefault(99);
      expect(identical(a, b), isTrue);
    });

    test('stores negative int value', () {
      const nd = DtoDefault(-1);
      expect(nd.value, equals(-1));
    });
  });

  // =========================================================================
  // DtoIgnore
  // =========================================================================
  group('DtoIgnore', () {
    group('default constructor', () {
      test('sets fromJson to true by default', () {
        const ignore = DtoIgnore();
        expect(ignore.fromJson, isTrue);
      });

      test('sets toJson to true by default', () {
        const ignore = DtoIgnore();
        expect(ignore.toJson, isTrue);
      });

      test('can be created as const', () {
        const a = DtoIgnore();
        const b = DtoIgnore();
        expect(identical(a, b), isTrue);
      });

    });

    group('fromJson named constructor', () {
      test('sets fromJson to true', () {
        const ignore = DtoIgnore.fromJson();
        expect(ignore.fromJson, isTrue);
      });

      test('sets toJson to false', () {
        const ignore = DtoIgnore.fromJson();
        expect(ignore.toJson, isFalse);
      });

      test('can be created as const', () {
        const a = DtoIgnore.fromJson();
        const b = DtoIgnore.fromJson();
        expect(identical(a, b), isTrue);
      });
    });

    group('toJson named constructor', () {
      test('sets fromJson to false', () {
        const ignore = DtoIgnore.toJson();
        expect(ignore.fromJson, isFalse);
      });

      test('sets toJson to true', () {
        const ignore = DtoIgnore.toJson();
        expect(ignore.toJson, isTrue);
      });

      test('can be created as const', () {
        const a = DtoIgnore.toJson();
        const b = DtoIgnore.toJson();
        expect(identical(a, b), isTrue);
      });
    });
  });

  // =========================================================================
  // DtoRequired
  // =========================================================================
  group('DtoRequired', () {
    test('message is null by default', () {
      const req = DtoRequired();
      expect(req.message, isNull);
    });

    test('can set a message string', () {
      const req = DtoRequired(message: 'Field is required');
      expect(req.message, equals('Field is required'));
    });

    test('can set an empty message', () {
      const req = DtoRequired(message: '');
      expect(req.message, equals(''));
    });

    test('can set a long message', () {
      const longMsg = 'This is a very long validation message that explains '
          'exactly why this field is required and what happens when it is '
          'missing from the JSON payload that is being parsed by the DTO.';
      const req = DtoRequired(message: longMsg);
      expect(req.message, equals(longMsg));
    });

    test('can be created as const with no message', () {
      const a = DtoRequired();
      const b = DtoRequired();
      expect(identical(a, b), isTrue);
    });

    test('can be created as const with same message', () {
      const a = DtoRequired(message: 'required');
      const b = DtoRequired(message: 'required');
      expect(identical(a, b), isTrue);
    });

    test('message with special characters', () {
      const req = DtoRequired(message: r'Field "$name" is required!');
      expect(req.message, equals(r'Field "$name" is required!'));
    });

    test('message with unicode characters', () {
      const req = DtoRequired(message: 'Required field \u2022');
      expect(req.message, contains('\u2022'));
    });

    test('message with newline characters', () {
      const req = DtoRequired(message: 'Line1\nLine2');
      expect(req.message, contains('\n'));
    });

    test('different messages produce non-identical const instances', () {
      const a = DtoRequired(message: 'a');
      const b = DtoRequired(message: 'b');
      expect(identical(a, b), isFalse);
    });
  });

  // =========================================================================
  // Cross-annotation interaction sanity checks
  // =========================================================================
  group('Cross-annotation sanity checks', () {
    test('DtoKey and DtoDefault can both reference default values', () {
      const jk = DtoKey('field', defaultValue: 0);
      const nd = DtoDefault(0);
      expect(jk.defaultValue, equals(nd.value));
    });

    test('DtoKey.required and Required annotation both mark required', () {
      const jk = DtoKey.required();
      const req = DtoRequired();
      expect(jk.required, isTrue);
      expect(req.message, isNull);
    });

    test('DtoIgnore.fromJson ignores fromJson only', () {
      const ignore = DtoIgnore.fromJson();
      expect(ignore.fromJson, isTrue);
      expect(ignore.toJson, isFalse);
    });

    test('DtoIgnore.toJson ignores toJson only', () {
      const ignore = DtoIgnore.toJson();
      expect(ignore.fromJson, isFalse);
      expect(ignore.toJson, isTrue);
    });

  });
}
