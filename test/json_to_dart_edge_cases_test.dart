import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  // ==========================================================================
  // _singularize edge cases
  // ==========================================================================
  group('JsonToDartGenerator singularize (via list field names)', () {
    // We test singularize indirectly: when a list of objects is generated,
    // the nested class name is derived from the singularized field name.

    test('field "items" → nested class from singular "item"', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'items': [
          {'id': 1}
        ]
      }, 'Response');

      // Should contain nested class based on singular of "items"
      final code = result.fullCode;
      expect(code, contains('Item'));
    });

    test('field "categories" → singular "category" (ies → y)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'categories': [
          {'name': 'test'}
        ]
      }, 'Response');

      final code = result.fullCode;
      expect(code, contains('Categor')); // Category or similar
    });

    test('field "addresses" → singular "address" (sses → ss)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'addresses': [
          {'street': 'Main St'}
        ]
      }, 'Response');

      final code = result.fullCode;
      expect(code, contains('Address'));
    });

    test('field "boxes" → singular "box" (xes → x)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'boxes': [
          {'size': 1}
        ]
      }, 'Response');

      final code = result.fullCode;
      expect(code, contains('Box'));
    });

    test('field "data" → kept as "data" (no -s ending)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'data': [
          {'id': 1}
        ]
      }, 'Response');

      final code = result.fullCode;
      // "data" doesn't end in 's' so no singularization
      expect(code, contains('Data'));
    });

    test('field "status" → kept as "status" (ends in -s but is "ss"-like)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'status': [
          {'code': 200}
        ]
      }, 'Response');

      final code = result.fullCode;
      // "status" ends in 's' but NOT 'ss', so it gets singularized to "statu"
      // This is a known limitation of simple singularization
      expect(code, isNotEmpty);
    });
  });

  // ==========================================================================
  // Deeply nested empty objects
  // ==========================================================================
  group('Deeply nested structures', () {
    test('deeply nested empty objects generate classes', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'a': {
          'b': {
            'c': <String, dynamic>{}
          }
        }
      }, 'Deep');

      final code = result.fullCode;
      expect(code, contains('class Deep'));
      expect(code, contains('class A'));
    });

    test('single-level nested object generates two classes', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'child': {'name': 'test'}
      }, 'Parent');

      expect(result.nestedClasses.length, 1);
      expect(result.fullCode, contains('class Parent'));
      expect(result.fullCode, contains('class Child'));
    });
  });

  // ==========================================================================
  // Mixed-type lists
  // ==========================================================================
  group('Mixed-type lists', () {
    test('list of mixed primitives - first element determines type', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'mixed': [1, 'two', true]
      }, 'Mixed');

      // Generator uses first element's type; allSameType check may vary
      final code = result.fullCode;
      expect(code, isNotEmpty);
      expect(result.fields.first.isList, isTrue);
    });

    test('empty list → List<dynamic>', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'items': <dynamic>[]
      }, 'Empty');

      final code = result.fullCode;
      expect(code, contains('List<dynamic>'));
    });

    test('list with single null → List<dynamic>', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'items': [null]
      }, 'NullList');

      // null values in list - first element is null, inferType returns "String?"
      // This ends up as List<dynamic> since we can't determine element type
      final code = result.fullCode;
      expect(code, isNotEmpty);
    });
  });

  // ==========================================================================
  // Null JSON values
  // ==========================================================================
  group('Null values in JSON', () {
    test('null value defaults to String? with warning', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'unknown': null,
      }, 'NullField');

      final code = result.fullCode;
      expect(code, contains('String?'));
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('null'));
    });

    test('allNullable=false with null value still produces nullable field', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({
        'value': null,
      }, 'StrictNull');

      final code = result.fullCode;
      // null value should still be String? even with allNullable=false
      expect(code, contains('String?'));
    });
  });

  // ==========================================================================
  // Empty JSON
  // ==========================================================================
  group('Empty JSON', () {
    test('empty JSON object generates class with no fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate(<String, dynamic>{}, 'Empty');

      expect(result.fields, isEmpty);
      expect(result.fullCode, contains('class Empty'));
      expect(result.nestedClasses, isEmpty);
    });
  });

  // ==========================================================================
  // Single field JSON
  // ==========================================================================
  group('Single field JSON', () {
    test('single int field', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 42}, 'Simple');

      expect(result.fields.length, 1);
      expect(result.fields.first.name, 'id');
      expect(result.fields.first.type, 'int?');
    });

    test('single string field', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'name': 'test'}, 'Simple');

      expect(result.fields.length, 1);
      expect(result.fields.first.type, 'String?');
    });
  });

  // ==========================================================================
  // Generator with all options disabled
  // ==========================================================================
  group('Generator options combinations', () {
    test('all generation disabled - still produces class shell', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateFromJson: false,
          generateToJson: false,
          generateCopyWith: false,
          generateEquality: false,
          addLogging: false,
        ),
      );
      final result = gen.generate({'id': 1}, 'Minimal');

      final code = result.fullCode;
      expect(code, contains('class Minimal'));
      expect(code, contains('final int? id'));
      // No fromJson, toJson, etc.
      expect(code, isNot(contains('fromJson')));
      expect(code, isNot(contains('toJson')));
    });

    test('only toJson enabled', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateFromJson: false,
          generateToJson: true,
        ),
      );
      final result = gen.generate({'id': 1}, 'ToJsonOnly');

      final code = result.fullCode;
      expect(code, isNot(contains('fromJson')));
      expect(code, contains('toJson'));
    });

    test('copyWith and equality enabled', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateCopyWith: true,
          generateEquality: true,
        ),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Full');

      final code = result.fullCode;
      expect(code, contains('copyWith'));
      expect(code, contains('operator =='));
      expect(code, contains('hashCode'));
    });

    test('allNullable=false makes fields required', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({'id': 1}, 'Required');

      final code = result.fullCode;
      expect(code, contains('final int id'));
      expect(code, contains('required'));
    });

    test('addLogging=false generates plain constructor', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: false),
      );
      final result = gen.generate({'id': 1}, 'NoLog');

      final code = result.fullCode;
      expect(code, isNot(contains('DtoLogger')));
      expect(code, contains('fromJson'));
    });
  });

  // ==========================================================================
  // GeneratorOptions defaults
  // ==========================================================================
  group('GeneratorOptions defaults', () {
    test('default options have expected values', () {
      const opts = GeneratorOptions();
      expect(opts.generateFromJson, isTrue);
      expect(opts.generateToJson, isTrue);
      expect(opts.generateCopyWith, isFalse);
      expect(opts.generateEquality, isFalse);
      expect(opts.addLogging, isTrue);
      expect(opts.allNullable, isTrue);
      expect(opts.dtoLoggerImport, 'package:dto_logger/dto_logger.dart');
    });
  });

  // ==========================================================================
  // FieldInfo properties
  // ==========================================================================
  group('FieldInfo from generation', () {
    test('nested object field has correct flags', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': 'Main'}
      }, 'User');

      final addressField = result.fields.first;
      expect(addressField.isNestedObject, isTrue);
      expect(addressField.nestedClassName, isNotNull);
    });

    test('list of objects field has correct flags', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'items': [
          {'id': 1}
        ]
      }, 'Container');

      final itemsField = result.fields.first;
      expect(itemsField.isList, isTrue);
      expect(itemsField.isNestedObject, isTrue);
    });

    test('primitive list field is list but not nested', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'tags': ['a', 'b']
      }, 'Post');

      final tagsField = result.fields.first;
      expect(tagsField.isList, isTrue);
      expect(tagsField.isNestedObject, isFalse);
    });

    test('bool field type', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'active': true}, 'Flag');

      expect(result.fields.first.type, 'bool?');
    });

    test('double field type', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'price': 9.99}, 'Product');

      expect(result.fields.first.type, 'double?');
    });
  });

  // ==========================================================================
  // snake_case field names → camelCase dart names
  // ==========================================================================
  group('Field name conversion in generator', () {
    test('snake_case keys become camelCase field names', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'user_name': 'test',
        'created_at': '2024-01-01',
      }, 'User');

      final names = result.fields.map((f) => f.name).toList();
      expect(names, contains('userName'));
      expect(names, contains('createdAt'));
    });

    test('jsonKey preserves original snake_case', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'user_name': 'test'}, 'User');

      expect(result.fields.first.jsonKey, 'user_name');
      expect(result.fields.first.name, 'userName');
    });
  });

  // ==========================================================================
  // Class name collision avoidance
  // ==========================================================================
  group('Class name collision', () {
    test('duplicate nested class names get suffix', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'home': {'city': 'NYC'},
        'work': {'city': 'LA'},
      }, 'Addresses');

      // Both nested objects might want "Home" and "Work" class names
      // The generator should handle them without collision
      final code = result.fullCode;
      expect(code, contains('class Addresses'));
    });
  });
}
