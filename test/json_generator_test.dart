import 'package:test/test.dart';
import 'package:dto_logger/src/json_to_dart.dart';

void main() {
  group('GeneratorOptions', () {
    test('default generateFromJson is true', () {
      const opts = GeneratorOptions();
      expect(opts.generateFromJson, isTrue);
    });

    test('default generateToJson is true', () {
      const opts = GeneratorOptions();
      expect(opts.generateToJson, isTrue);
    });

    test('default generateCopyWith is false', () {
      const opts = GeneratorOptions();
      expect(opts.generateCopyWith, isFalse);
    });

    test('default generateEquality is false', () {
      const opts = GeneratorOptions();
      expect(opts.generateEquality, isFalse);
    });

    test('default addLogging is true', () {
      const opts = GeneratorOptions();
      expect(opts.addLogging, isTrue);
    });

    test('default allNullable is true', () {
      const opts = GeneratorOptions();
      expect(opts.allNullable, isTrue);
    });

    test('default dtoLoggerImport is package:dto_logger/dto_logger.dart', () {
      const opts = GeneratorOptions();
      expect(
          opts.dtoLoggerImport, equals('package:dto_logger/dto_logger.dart'));
    });

    test('custom generateFromJson can be set to false', () {
      const opts = GeneratorOptions(generateFromJson: false);
      expect(opts.generateFromJson, isFalse);
    });

    test('custom generateToJson can be set to false', () {
      const opts = GeneratorOptions(generateToJson: false);
      expect(opts.generateToJson, isFalse);
    });

    test('custom generateCopyWith can be set to true', () {
      const opts = GeneratorOptions(generateCopyWith: true);
      expect(opts.generateCopyWith, isTrue);
    });

    test('custom generateEquality can be set to true', () {
      const opts = GeneratorOptions(generateEquality: true);
      expect(opts.generateEquality, isTrue);
    });

    test('custom addLogging can be set to false', () {
      const opts = GeneratorOptions(addLogging: false);
      expect(opts.addLogging, isFalse);
    });

    test('custom allNullable can be set to false', () {
      const opts = GeneratorOptions(allNullable: false);
      expect(opts.allNullable, isFalse);
    });

    test('custom dtoLoggerImport can be set to null', () {
      const opts = GeneratorOptions(dtoLoggerImport: null);
      expect(opts.dtoLoggerImport, isNull);
    });

    test('custom dtoLoggerImport can be set to custom value', () {
      const opts =
          GeneratorOptions(dtoLoggerImport: 'package:custom/custom.dart');
      expect(opts.dtoLoggerImport, equals('package:custom/custom.dart'));
    });

    test('const constructor works', () {
      const opts = GeneratorOptions();
      expect(opts, isA<GeneratorOptions>());
    });

    test('all custom values can be set simultaneously', () {
      const opts = GeneratorOptions(
        generateFromJson: false,
        generateToJson: false,
        generateCopyWith: true,
        generateEquality: true,
        addLogging: false,
        allNullable: false,
        dtoLoggerImport: null,
      );
      expect(opts.generateFromJson, isFalse);
      expect(opts.generateToJson, isFalse);
      expect(opts.generateCopyWith, isTrue);
      expect(opts.generateEquality, isTrue);
      expect(opts.addLogging, isFalse);
      expect(opts.allNullable, isFalse);
      expect(opts.dtoLoggerImport, isNull);
    });
  });

  group('FieldInfo', () {
    test('required fields must be provided', () {
      const field = FieldInfo(
        name: 'userName',
        jsonKey: 'user_name',
        type: 'String?',
        nullable: true,
      );
      expect(field.name, equals('userName'));
      expect(field.jsonKey, equals('user_name'));
      expect(field.type, equals('String?'));
      expect(field.nullable, isTrue);
    });

    test('isNestedObject defaults to false', () {
      const field = FieldInfo(
        name: 'test',
        jsonKey: 'test',
        type: 'String',
        nullable: false,
      );
      expect(field.isNestedObject, isFalse);
    });

    test('isList defaults to false', () {
      const field = FieldInfo(
        name: 'test',
        jsonKey: 'test',
        type: 'String',
        nullable: false,
      );
      expect(field.isList, isFalse);
    });

    test('nestedClassName defaults to null', () {
      const field = FieldInfo(
        name: 'test',
        jsonKey: 'test',
        type: 'String',
        nullable: false,
      );
      expect(field.nestedClassName, isNull);
    });

    test('warning defaults to null', () {
      const field = FieldInfo(
        name: 'test',
        jsonKey: 'test',
        type: 'String',
        nullable: false,
      );
      expect(field.warning, isNull);
    });

    test('custom isNestedObject can be set to true', () {
      const field = FieldInfo(
        name: 'address',
        jsonKey: 'address',
        type: 'Address?',
        nullable: true,
        isNestedObject: true,
        nestedClassName: 'Address',
      );
      expect(field.isNestedObject, isTrue);
      expect(field.nestedClassName, equals('Address'));
    });

    test('custom isList can be set to true', () {
      const field = FieldInfo(
        name: 'tags',
        jsonKey: 'tags',
        type: 'List<String>?',
        nullable: true,
        isList: true,
      );
      expect(field.isList, isTrue);
    });

    test('custom warning can be set', () {
      const field = FieldInfo(
        name: 'data',
        jsonKey: 'data',
        type: 'String?',
        nullable: true,
        warning: 'Field "data" is null - assuming String?',
      );
      expect(field.warning, equals('Field "data" is null - assuming String?'));
    });

    test('const constructor works', () {
      const field = FieldInfo(
        name: 'test',
        jsonKey: 'test',
        type: 'int',
        nullable: false,
      );
      expect(field, isA<FieldInfo>());
    });

    test('all fields can be set at once', () {
      const field = FieldInfo(
        name: 'items',
        jsonKey: 'items',
        type: 'List<Item>?',
        nullable: true,
        isNestedObject: true,
        isList: true,
        nestedClassName: 'Item',
        warning: 'test warning',
      );
      expect(field.name, equals('items'));
      expect(field.jsonKey, equals('items'));
      expect(field.type, equals('List<Item>?'));
      expect(field.nullable, isTrue);
      expect(field.isNestedObject, isTrue);
      expect(field.isList, isTrue);
      expect(field.nestedClassName, equals('Item'));
      expect(field.warning, equals('test warning'));
    });
  });

  group('GeneratedClass', () {
    test('name stores correctly', () {
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
      );
      expect(gc.name, equals('User'));
    });

    test('code stores correctly', () {
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
      );
      expect(gc.code, equals('class User {}'));
    });

    test('fields stores correctly', () {
      const field = FieldInfo(
        name: 'id',
        jsonKey: 'id',
        type: 'int?',
        nullable: true,
      );
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [field],
      );
      expect(gc.fields.length, equals(1));
      expect(gc.fields[0].name, equals('id'));
    });

    test('nestedClasses defaults to empty list', () {
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
      );
      expect(gc.nestedClasses, isEmpty);
    });

    test('warnings defaults to empty list', () {
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
      );
      expect(gc.warnings, isEmpty);
    });

    test('nestedClasses can be set', () {
      const nested = GeneratedClass(
        name: 'Address',
        code: 'class Address {}',
        fields: [],
      );
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
        nestedClasses: [nested],
      );
      expect(gc.nestedClasses.length, equals(1));
      expect(gc.nestedClasses[0].name, equals('Address'));
    });

    test('warnings can be set', () {
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
        warnings: ['test warning'],
      );
      expect(gc.warnings.length, equals(1));
      expect(gc.warnings[0], equals('test warning'));
    });

    test('fullCode with no nested classes returns just code with newline', () {
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
      );
      expect(gc.fullCode, equals('class User {}\n'));
    });

    test('fullCode with one nested class appends nested code', () {
      const nested = GeneratedClass(
        name: 'Address',
        code: 'class Address {}',
        fields: [],
      );
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
        nestedClasses: [nested],
      );
      final full = gc.fullCode;
      expect(full, contains('class User {}'));
      expect(full, contains('class Address {}'));
    });

    test('fullCode with multiple nested classes includes all', () {
      const nested1 = GeneratedClass(
        name: 'Address',
        code: 'class Address {}',
        fields: [],
      );
      const nested2 = GeneratedClass(
        name: 'Phone',
        code: 'class Phone {}',
        fields: [],
      );
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
        nestedClasses: [nested1, nested2],
      );
      final full = gc.fullCode;
      expect(full, contains('class User {}'));
      expect(full, contains('class Address {}'));
      expect(full, contains('class Phone {}'));
    });

    test('fullCode concatenation preserves order', () {
      const nested1 = GeneratedClass(
        name: 'First',
        code: 'class First {}',
        fields: [],
      );
      const nested2 = GeneratedClass(
        name: 'Second',
        code: 'class Second {}',
        fields: [],
      );
      const gc = GeneratedClass(
        name: 'Parent',
        code: 'class Parent {}',
        fields: [],
        nestedClasses: [nested1, nested2],
      );
      final full = gc.fullCode;
      final parentIdx = full.indexOf('class Parent {}');
      final firstIdx = full.indexOf('class First {}');
      final secondIdx = full.indexOf('class Second {}');
      expect(parentIdx, lessThan(firstIdx));
      expect(firstIdx, lessThan(secondIdx));
    });

    test('fullCode includes newline separators between nested classes', () {
      const nested = GeneratedClass(
        name: 'Address',
        code: 'class Address {}',
        fields: [],
      );
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
        nestedClasses: [nested],
      );
      final full = gc.fullCode;
      // After code writeln, then writeln for separator, then nested
      expect(full, contains('class User {}\n\n'));
    });

    test('fullCode recursively includes deeply nested classes', () {
      const deepNested = GeneratedClass(
        name: 'City',
        code: 'class City {}',
        fields: [],
      );
      const nested = GeneratedClass(
        name: 'Address',
        code: 'class Address {}',
        fields: [],
        nestedClasses: [deepNested],
      );
      const gc = GeneratedClass(
        name: 'User',
        code: 'class User {}',
        fields: [],
        nestedClasses: [nested],
      );
      final full = gc.fullCode;
      expect(full, contains('class User {}'));
      expect(full, contains('class Address {}'));
      expect(full, contains('class City {}'));
    });

    test('const constructor works', () {
      const gc = GeneratedClass(
        name: 'Test',
        code: 'class Test {}',
        fields: [],
      );
      expect(gc, isA<GeneratedClass>());
    });
  });

  group('JsonToDartGenerator - Field Type Analysis (allNullable=true)', () {
    late JsonToDartGenerator generator;

    setUp(() {
      generator = JsonToDartGenerator();
    });

    test('null value produces String? type', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.fields[0].type, equals('String?'));
    });

    test('null value produces nullable=true', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.fields[0].nullable, isTrue);
    });

    test('null value produces warning', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.fields[0].warning, contains('is null'));
      expect(result.fields[0].warning, contains('assuming String?'));
    });

    test('null value warning includes field name', () {
      final result = generator.generate({'my_field': null}, 'Test');
      expect(result.fields[0].warning, contains('my_field'));
    });

    test('int value produces int? type', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.fields[0].type, equals('int?'));
    });

    test('int value produces nullable=true', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.fields[0].nullable, isTrue);
    });

    test('int value produces no warning', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.fields[0].warning, isNull);
    });

    test('double value produces double? type', () {
      final result = generator.generate({'price': 9.99}, 'Test');
      expect(result.fields[0].type, equals('double?'));
    });

    test('double value produces nullable=true', () {
      final result = generator.generate({'price': 9.99}, 'Test');
      expect(result.fields[0].nullable, isTrue);
    });

    test('bool value produces bool? type', () {
      final result = generator.generate({'active': true}, 'Test');
      expect(result.fields[0].type, equals('bool?'));
    });

    test('bool false value produces bool? type', () {
      final result = generator.generate({'active': false}, 'Test');
      expect(result.fields[0].type, equals('bool?'));
    });

    test('String value produces String? type', () {
      final result = generator.generate({'name': 'John'}, 'Test');
      expect(result.fields[0].type, equals('String?'));
    });

    test('String value produces nullable=true', () {
      final result = generator.generate({'name': 'John'}, 'Test');
      expect(result.fields[0].nullable, isTrue);
    });

    test('empty string value produces String? type', () {
      final result = generator.generate({'name': ''}, 'Test');
      expect(result.fields[0].type, equals('String?'));
    });

    test('Map value produces nested class type with ?', () {
      final result = generator.generate({
        'address': {'street': '123 Main'}
      }, 'Test');
      expect(result.fields[0].type, endsWith('?'));
      expect(result.fields[0].isNestedObject, isTrue);
    });

    test('Map value sets nestedClassName', () {
      final result = generator.generate({
        'address': {'street': '123 Main'}
      }, 'Test');
      expect(result.fields[0].nestedClassName, isNotNull);
    });

    test('Map value produces nested GeneratedClass', () {
      final result = generator.generate({
        'address': {'street': '123 Main'}
      }, 'Test');
      expect(result.nestedClasses.length, equals(1));
    });

    test('empty list produces List<dynamic>? type', () {
      final result = generator.generate({'items': []}, 'Test');
      expect(result.fields[0].type, equals('List<dynamic>?'));
    });

    test('empty list produces nullable=true', () {
      final result = generator.generate({'items': []}, 'Test');
      expect(result.fields[0].nullable, isTrue);
    });

    test('empty list produces isList=true', () {
      final result = generator.generate({'items': []}, 'Test');
      expect(result.fields[0].isList, isTrue);
    });

    test('empty list produces warning', () {
      final result = generator.generate({'items': []}, 'Test');
      expect(result.fields[0].warning, equals('Empty list'));
    });

    test('list of int produces List<int>? type', () {
      final result = generator.generate({
        'ids': [1, 2, 3]
      }, 'Test');
      expect(result.fields[0].type, equals('List<int>?'));
    });

    test('list of int produces isList=true', () {
      final result = generator.generate({
        'ids': [1, 2, 3]
      }, 'Test');
      expect(result.fields[0].isList, isTrue);
    });

    test('list of double produces List<double>? type', () {
      final result = generator.generate({
        'scores': [1.1, 2.2]
      }, 'Test');
      expect(result.fields[0].type, equals('List<double>?'));
    });

    test('list of bool produces List<bool>? type', () {
      final result = generator.generate({
        'flags': [true, false]
      }, 'Test');
      expect(result.fields[0].type, equals('List<bool>?'));
    });

    test('list of String produces List<String>? type', () {
      final result = generator.generate({
        'tags': ['a', 'b']
      }, 'Test');
      expect(result.fields[0].type, equals('List<String>?'));
    });

    test('list of Map produces List<NestedClass>? type', () {
      final result = generator.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.fields[0].type, contains('List<'));
      expect(result.fields[0].type, endsWith('?'));
      expect(result.fields[0].isList, isTrue);
      expect(result.fields[0].isNestedObject, isTrue);
    });

    test('list of Map generates nested class', () {
      final result = generator.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.nestedClasses.length, equals(1));
    });

    test('list of Map sets nestedClassName', () {
      final result = generator.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.fields[0].nestedClassName, isNotNull);
    });

    test('list of mixed types produces List<dynamic>?', () {
      final result = generator.generate({
        'mixed': [1, 'two', true]
      }, 'Test');
      // Every item is checked, not just the first one
      expect(result.fields[0].type, equals('List<dynamic>?'));
      expect(result.fields[0].isList, isTrue);
    });

    test(
        'list where first element is non-standard type produces List<dynamic>?',
        () {
      // A list where the first element is itself a list (not a Map)
      final result = generator.generate({
        'nested_lists': [
          [1, 2],
          [3, 4]
        ]
      }, 'Test');
      expect(result.fields[0].type, equals('List<dynamic>?'));
      expect(result.fields[0].isList, isTrue);
    });

    test('int zero value produces int? type', () {
      final result = generator.generate({'count': 0}, 'Test');
      expect(result.fields[0].type, equals('int?'));
    });

    test('negative int value produces int? type', () {
      final result = generator.generate({'count': -5}, 'Test');
      expect(result.fields[0].type, equals('int?'));
    });

    test('large int value produces int? type', () {
      final result = generator.generate({'count': 9999999999}, 'Test');
      expect(result.fields[0].type, equals('int?'));
    });

    test('double zero value produces double? type', () {
      final result = generator.generate({'price': 0.0}, 'Test');
      expect(result.fields[0].type, equals('double?'));
    });

    test('negative double value produces double? type', () {
      final result = generator.generate({'price': -3.14}, 'Test');
      expect(result.fields[0].type, equals('double?'));
    });

    test('multiple fields produce correct types', () {
      final result = generator.generate({
        'id': 1,
        'name': 'John',
        'active': true,
        'score': 9.5,
      }, 'Test');
      expect(result.fields.length, equals(4));
      expect(result.fields[0].type, equals('int?'));
      expect(result.fields[1].type, equals('String?'));
      expect(result.fields[2].type, equals('bool?'));
      expect(result.fields[3].type, equals('double?'));
    });

    test('null fields are always nullable regardless of allNullable', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.fields[0].nullable, isTrue);
      expect(result.fields[0].type, equals('String?'));
    });

    test('nested map with empty object becomes Map<String, dynamic>', () {
      final result = generator.generate({'meta': <String, dynamic>{}}, 'Test');
      // An empty object tells us nothing, so no empty class is generated
      expect(result.fields[0].isNestedObject, isFalse);
      expect(result.fields[0].isMap, isTrue);
      expect(result.fields[0].type, equals('Map<String, dynamic>?'));
      expect(result.nestedClasses, isEmpty);
    });

    test('list with single int element', () {
      final result = generator.generate({
        'ids': [42]
      }, 'Test');
      expect(result.fields[0].type, equals('List<int>?'));
    });

    test('list with single string element', () {
      final result = generator.generate({
        'tags': ['hello']
      }, 'Test');
      expect(result.fields[0].type, equals('List<String>?'));
    });

    test('list with single map element', () {
      final result = generator.generate({
        'items': [
          {'id': 1}
        ]
      }, 'Test');
      expect(result.fields[0].isList, isTrue);
      expect(result.fields[0].isNestedObject, isTrue);
    });

    test('warnings list collects all null field warnings', () {
      final result = generator.generate({
        'field1': null,
        'field2': null,
      }, 'Test');
      expect(result.warnings.length, equals(2));
    });

    test('warnings list collects empty list warnings', () {
      final result = generator.generate({
        'items': [],
      }, 'Test');
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('Empty list'));
    });
  });

  group('JsonToDartGenerator - Field Type Analysis (allNullable=false)', () {
    late JsonToDartGenerator generator;

    setUp(() {
      generator = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
    });

    test('int value produces int (no ?)', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.fields[0].type, equals('int'));
      expect(result.fields[0].nullable, isFalse);
    });

    test('double value produces double (no ?)', () {
      final result = generator.generate({'price': 9.99}, 'Test');
      expect(result.fields[0].type, equals('double'));
      expect(result.fields[0].nullable, isFalse);
    });

    test('bool value produces bool (no ?)', () {
      final result = generator.generate({'active': true}, 'Test');
      expect(result.fields[0].type, equals('bool'));
      expect(result.fields[0].nullable, isFalse);
    });

    test('String value produces String (no ?)', () {
      final result = generator.generate({'name': 'John'}, 'Test');
      expect(result.fields[0].type, equals('String'));
      expect(result.fields[0].nullable, isFalse);
    });

    test('null value still produces String? even with allNullable=false', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.fields[0].type, equals('String?'));
      expect(result.fields[0].nullable, isTrue);
    });

    test('Map value produces non-nullable nested type', () {
      final result = generator.generate({
        'address': {'street': '123'}
      }, 'Test');
      expect(result.fields[0].type, isNot(endsWith('?')));
      expect(result.fields[0].nullable, isFalse);
    });

    test('list of int produces List<int> (no ?)', () {
      final result = generator.generate({
        'ids': [1, 2, 3]
      }, 'Test');
      expect(result.fields[0].type, equals('List<int>'));
      expect(result.fields[0].nullable, isFalse);
    });

    test('list of double produces List<double> (no ?)', () {
      final result = generator.generate({
        'scores': [1.1, 2.2]
      }, 'Test');
      expect(result.fields[0].type, equals('List<double>'));
    });

    test('list of bool produces List<bool> (no ?)', () {
      final result = generator.generate({
        'flags': [true, false]
      }, 'Test');
      expect(result.fields[0].type, equals('List<bool>'));
    });

    test('list of String produces List<String> (no ?)', () {
      final result = generator.generate({
        'tags': ['a', 'b']
      }, 'Test');
      expect(result.fields[0].type, equals('List<String>'));
    });

    test('list of Map produces non-nullable List type', () {
      final result = generator.generate({
        'items': [
          {'id': 1}
        ]
      }, 'Test');
      expect(result.fields[0].type, isNot(endsWith('?')));
    });

    test('empty list still produces List<dynamic>? even with allNullable=false',
        () {
      final result = generator.generate({'items': []}, 'Test');
      expect(result.fields[0].type, equals('List<dynamic>?'));
      expect(result.fields[0].nullable, isTrue);
    });

    test('non-nullable fields have no warning', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.fields[0].warning, isNull);
    });
  });

  group('Generated Code Quality - Class Structure', () {
    late JsonToDartGenerator generator;

    setUp(() {
      generator = JsonToDartGenerator();
    });

    test('class declaration contains class name', () {
      final result = generator.generate({'id': 1}, 'UserResponse');
      expect(result.code, contains('class UserResponse {'));
    });

    test('fields are declared as final', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('final int? id;'));
    });

    test('multiple fields are all final', () {
      final result = generator.generate({
        'id': 1,
        'name': 'John',
      }, 'Test');
      expect(result.code, contains('final int? id;'));
      expect(result.code, contains('final String? name;'));
    });

    test('constructor has named parameters with this prefix', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('this.id'));
    });

    test('constructor uses curly braces for named parameters', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('Test({'));
    });

    test('non-nullable fields get required keyword in constructor', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('required this.id'));
    });

    test('nullable fields do not get required keyword', () {
      final result = generator.generate({'id': 1}, 'Test');
      // id is int? (nullable) so no required
      expect(result.code, isNot(contains('required this.id')));
      expect(result.code, contains('this.id'));
    });

    test('class closes with }', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code.trimRight(), endsWith('}'));
    });

    test('empty JSON produces class with no fields', () {
      final result = generator.generate({}, 'Empty');
      expect(result.code, contains('class Empty {'));
      expect(result.fields, isEmpty);
    });

    test('empty JSON constructor has no parameters', () {
      final result = generator.generate({}, 'Empty');
      // `Empty({})` is not valid Dart
      expect(result.code, contains('Empty();'));
    });

    test('fromJson generated when generateFromJson=true', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('factory Test.fromJson'));
    });

    test('fromJson NOT generated when generateFromJson=false', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateFromJson: false),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, isNot(contains('fromJson')));
    });

    test('toJson generated when generateToJson=true', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('Map<String, dynamic> toJson()'));
    });

    test('toJson NOT generated when generateToJson=false', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateToJson: false),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, isNot(contains('toJson')));
    });

    test('copyWith generated when generateCopyWith=true', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('copyWith'));
    });

    test('copyWith NOT generated when generateCopyWith=false', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, isNot(contains('copyWith')));
    });

    test('equality generated when generateEquality=true', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('operator =='));
      expect(result.code, contains('hashCode'));
    });

    test('equality NOT generated when generateEquality=false', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, isNot(contains('operator ==')));
      expect(result.code, isNot(contains('hashCode')));
    });

    test('DtoLogger.parse used when addLogging=true', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('DtoLogger.parse'));
    });

    test('DtoLogger.parse NOT used when addLogging=false', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: false),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, isNot(contains('DtoLogger.parse')));
    });

    test('DtoLogger.parse wraps the builder', () {
      final result = generator.generate({'id': 1}, 'MyModel');
      expect(result.code, contains('DtoLogger.parse(json, () => MyModel('));
    });

    test('safeInt used for int fields', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.code, contains("json.safeInt('count')"));
    });

    test('safeDouble used for double fields', () {
      final result = generator.generate({'price': 9.99}, 'Test');
      expect(result.code, contains("json.safeDouble('price')"));
    });

    test('safeBool used for bool fields', () {
      final result = generator.generate({'active': true}, 'Test');
      expect(result.code, contains("json.safeBool('active')"));
    });

    test('safeString used for String fields', () {
      final result = generator.generate({'name': 'John'}, 'Test');
      expect(result.code, contains("json.safeString('name')"));
    });

    test('safeString used for null fields (defaulting to String?)', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.code, contains("json.safeString('field')"));
    });

    test('safeObject used for nested objects', () {
      final result = generator.generate({
        'address': {'street': '123 Main'}
      }, 'Test');
      expect(result.code, contains("json.safeObject('address'"));
    });

    test('safeObject includes fromJson reference', () {
      final result = generator.generate({
        'address': {'street': '123 Main'}
      }, 'Test');
      expect(result.code, contains('.fromJson)'));
    });

    test('safeList used for list of objects', () {
      final result = generator.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.code, contains("json.safeList('items'"));
    });

    test('safeList includes fromJson reference for list of objects', () {
      final result = generator.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.code, contains('.fromJson)'));
    });

    test('safeListOf used for list of primitives (int)', () {
      final result = generator.generate({
        'ids': [1, 2, 3]
      }, 'Test');
      expect(result.code, contains("json.safeListOf<int>('ids')"));
    });

    test('safeListOf used for list of primitives (String)', () {
      final result = generator.generate({
        'tags': ['a', 'b']
      }, 'Test');
      expect(result.code, contains("json.safeListOf<String>('tags')"));
    });

    test('safeListOf used for list of primitives (double)', () {
      final result = generator.generate({
        'scores': [1.1, 2.2]
      }, 'Test');
      expect(result.code, contains("json.safeListOf<double>('scores')"));
    });

    test('safeListOf used for list of primitives (bool)', () {
      final result = generator.generate({
        'flags': [true, false]
      }, 'Test');
      expect(result.code, contains("json.safeListOf<bool>('flags')"));
    });

    test('class name is PascalCase from snake_case input', () {
      final result = generator.generate({'id': 1}, 'user_response');
      expect(result.name, equals('UserResponse'));
      expect(result.code, contains('class UserResponse {'));
    });

    test('field indentation is 2 spaces', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('  final int? id;'));
    });

    test('constructor parameter indentation is 4 spaces', () {
      final result = generator.generate({'id': 1}, 'Test');
      expect(result.code, contains('    this.id,'));
    });

    test(
        'no fromJson and no toJson and no copyWith and no equality produces minimal class',
        () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateFromJson: false,
          generateToJson: false,
          generateCopyWith: false,
          generateEquality: false,
        ),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('class Test {'));
      expect(result.code, contains('final int? id;'));
      expect(result.code, contains('Test({'));
      expect(result.code, isNot(contains('fromJson')));
      expect(result.code, isNot(contains('toJson')));
      expect(result.code, isNot(contains('copyWith')));
      expect(result.code, isNot(contains('operator ==')));
    });

    test('all options enabled generates complete class', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateFromJson: true,
          generateToJson: true,
          generateCopyWith: true,
          generateEquality: true,
          addLogging: true,
        ),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains('class Test {'));
      expect(result.code, contains('fromJson'));
      expect(result.code, contains('toJson'));
      expect(result.code, contains('copyWith'));
      expect(result.code, contains('operator =='));
      expect(result.code, contains('hashCode'));
    });
  });

  group('fromJson Code', () {
    test('uses json.safeInt for int fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'age': 25}, 'User');
      expect(result.code, contains("json.safeInt('age')"));
    });

    test('uses json.safeDouble for double fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'weight': 70.5}, 'User');
      expect(result.code, contains("json.safeDouble('weight')"));
    });

    test('uses json.safeBool for bool fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'verified': true}, 'User');
      expect(result.code, contains("json.safeBool('verified')"));
    });

    test('uses json.safeString for String fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'email': 'a@b.com'}, 'User');
      expect(result.code, contains("json.safeString('email')"));
    });

    test('uses json.safeObject for nested objects', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'profile': {'bio': 'hello'}
      }, 'User');
      expect(result.code, contains("json.safeObject('profile'"));
    });

    test('safeObject passes fromJson constructor', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'profile': {'bio': 'hello'}
      }, 'User');
      expect(result.code, contains('Profile.fromJson)'));
    });

    test('uses json.safeList for list of objects', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'orders': [
          {'id': 1}
        ]
      }, 'User');
      expect(result.code, contains("json.safeList('orders'"));
    });

    test('safeList passes fromJson constructor for list of objects', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'orders': [
          {'id': 1}
        ]
      }, 'User');
      expect(result.code, contains('.fromJson)'));
    });

    test('uses json.safeListOf for list of int', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'ids': [1, 2]
      }, 'User');
      expect(result.code, contains("json.safeListOf<int>('ids')"));
    });

    test('uses json.safeListOf for list of String', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'names': ['a', 'b']
      }, 'User');
      expect(result.code, contains("json.safeListOf<String>('names')"));
    });

    test('uses json.safeListOf for list of double', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'values': [1.0, 2.0]
      }, 'User');
      expect(result.code, contains("json.safeListOf<double>('values')"));
    });

    test('uses json.safeListOf for list of bool', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'checks': [true, false]
      }, 'User');
      expect(result.code, contains("json.safeListOf<bool>('checks')"));
    });

    test('wraps in DtoLogger.parse when addLogging=true', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: true),
      );
      final result = gen.generate({'id': 1}, 'User');
      expect(result.code, contains('DtoLogger.parse(json, () => User('));
    });

    test('DtoLogger.parse closing parentheses when addLogging=true', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: true),
      );
      final result = gen.generate({'id': 1}, 'User');
      // Class name is passed explicitly as the third argument
      expect(result.code, contains("    ), 'User');"));
    });

    test('direct return when addLogging=false', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: false),
      );
      final result = gen.generate({'id': 1}, 'User');
      expect(result.code, contains('return User('));
      expect(result.code, isNot(contains('DtoLogger.parse')));
    });

    test('correct JSON key names used in safeInt', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'user_id': 1}, 'Test');
      expect(result.code, contains("json.safeInt('user_id')"));
    });

    test('correct JSON key names preserved (not converted to camelCase)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'first_name': 'John'}, 'Test');
      expect(result.code, contains("json.safeString('first_name')"));
    });

    test('field name is camelCase in assignment', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'first_name': 'John'}, 'Test');
      expect(result.code, contains('firstName: json.safeString'));
    });

    test('commas between fields except last', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      // id should have comma, name should not
      expect(result.code, contains("json.safeInt('id'),"));
    });

    test('factory constructor signature', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code,
          contains('factory Test.fromJson(Map<String, dynamic> json)'));
    });
  });

  group('toJson Code', () {
    test('primitive fields use simple key: value pattern', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains("'id': id"));
    });

    test('string primitive field in toJson', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'name': 'John'}, 'Test');
      expect(result.code, contains("'name': name"));
    });

    test('nested object calls ?.toJson()', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123 Main'}
      }, 'Test');
      expect(result.code, contains("'address': address?.toJson()"));
    });

    test('list of objects calls ?.map((e) => e.toJson()).toList()', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.code, contains('?.map((e) => e.toJson()).toList()'));
    });

    test('toJson returns Map<String, dynamic>', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('Map<String, dynamic> toJson() => {'));
    });

    test('toJson closes with };', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('};'));
    });

    test('toJson uses original JSON key names', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'user_name': 'test'}, 'Test');
      expect(result.code, contains("'user_name': userName"));
    });

    test('toJson with bool field', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'is_active': true}, 'Test');
      expect(result.code, contains("'is_active': isActive"));
    });

    test('toJson with int field', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'count': 5}, 'Test');
      expect(result.code, contains("'count': count"));
    });

    test('toJson with double field', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'price': 1.5}, 'Test');
      expect(result.code, contains("'price': price"));
    });

    test('toJson commas between fields except last', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      // First field should have comma
      expect(result.code, contains("'id': id,"));
    });

    test('toJson with list of primitives uses simple pattern', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'tags': ['a', 'b']
      }, 'Test');
      expect(result.code, contains("'tags': tags"));
      expect(result.code, isNot(contains("'tags': tags?.map")));
    });

    test('toJson with empty JSON produces empty map', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({}, 'Test');
      expect(result.code, contains('Map<String, dynamic> toJson() => {'));
      expect(result.code, contains('};'));
    });

    test('toJson with multiple fields of different types', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'id': 1,
        'name': 'John',
        'active': true,
        'score': 9.5,
      }, 'Test');
      expect(result.code, contains("'id': id"));
      expect(result.code, contains("'name': name"));
      expect(result.code, contains("'active': active"));
      expect(result.code, contains("'score': score"));
    });

    test('toJson nested object uses JSON key not dart name', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'home_address': {'street': '123'}
      }, 'Test');
      expect(result.code, contains("'home_address': homeAddress?.toJson()"));
    });
  });

  group('copyWith Code', () {
    test('copyWith method has correct signature', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('Test copyWith({'));
    });

    test('copyWith parameters are nullable', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateCopyWith: true,
          allNullable: false,
        ),
      );
      final result = gen.generate({'id': 1}, 'Test');
      // int (non-nullable) should become int? in copyWith
      expect(result.code, contains('int? id,'));
    });

    test('copyWith already-nullable params stay nullable', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      // int? already ends with ?, so it should stay int?
      expect(result.code, contains('int? id,'));
    });

    test('copyWith uses ?? this.field fallback', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('id: id ?? this.id'));
    });

    test('copyWith returns new instance of same class', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('return Test('));
    });

    test('copyWith with multiple fields has all fallbacks', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains('id: id ?? this.id'));
      expect(result.code, contains('name: name ?? this.name'));
    });

    test('copyWith with no fields produces empty parameter list', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({}, 'Test');
      // `copyWith({})` is not valid Dart
      expect(result.code, contains('Test copyWith() => Test();'));
    });

    test('copyWith with no fields returns instance with empty constructor', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({}, 'Test');
      expect(result.code, contains('=> Test();'));
    });

    test('copyWith closes with }', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      // The method should close properly
      expect(result.code, contains('  }'));
    });

    test('copyWith with String field has String? param', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({'name': 'John'}, 'Test');
      expect(result.code, contains('String? name,'));
    });
  });

  group('equality Code', () {
    test('operator== checks identical first', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('identical(this, other)'));
    });

    test('operator== checks type with is', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('other is Test'));
    });

    test('operator== checks all fields', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains('other.id == id'));
      expect(result.code, contains('other.name == name'));
    });

    test('operator== uses && between conditions', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains('&&'));
    });

    test('operator== has @override annotation', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('@override'));
      expect(result.code, contains('bool operator ==(Object other)'));
    });

    test('hashCode with 0 fields returns 0', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({}, 'Test');
      expect(result.code, contains('int get hashCode => 0;'));
    });

    test('hashCode with 1 field uses .hashCode', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('int get hashCode => id.hashCode;'));
    });

    test('hashCode with multiple fields uses Object.hash', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(
          result.code, contains('int get hashCode => Object.hash(id, name);'));
    });

    test('hashCode with 3 fields lists all', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({
        'id': 1,
        'name': 'test',
        'active': true,
      }, 'Test');
      expect(result.code, contains('Object.hash(id, name, active)'));
    });

    test('hashCode has @override annotation', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      // Two @override annotations: one for == and one for hashCode
      final overrideCount = '@override'.allMatches(result.code).length;
      expect(overrideCount, equals(2));
    });

    test('equality with no fields only checks type', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({}, 'Test');
      expect(result.code, contains('other is Test;'));
    });
  });

  group('Nested Objects', () {
    test('single level nesting generates one nested class', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123 Main', 'city': 'NYC'}
      }, 'User');
      expect(result.nestedClasses.length, equals(1));
    });

    test('nested class name is PascalCase', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'home_address': {'street': '123 Main'}
      }, 'User');
      expect(result.nestedClasses[0].name, equals('HomeAddress'));
    });

    test('nested class has its own fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123 Main', 'city': 'NYC'}
      }, 'User');
      expect(result.nestedClasses[0].fields.length, equals(2));
    });

    test('nested class has its own code', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123 Main'}
      }, 'User');
      expect(result.nestedClasses[0].code, contains('class Address {'));
    });

    test('two levels deep generates nested classes at both levels', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {
          'city': {
            'name': 'NYC',
            'state': 'NY',
          }
        }
      }, 'User');
      // The address nested class should have its own nested city class
      expect(result.nestedClasses.length, equals(1));
      expect(result.nestedClasses[0].nestedClasses.length, equals(1));
    });

    test('deeply nested class names are PascalCase', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {
          'city_info': {
            'name': 'NYC',
          }
        }
      }, 'User');
      final addressClass = result.nestedClasses[0];
      final cityClass = addressClass.nestedClasses[0];
      expect(cityClass.name, equals('CityInfo'));
    });

    test('multiple nested objects at same level', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123'},
        'phone': {'number': '555'},
      }, 'User');
      expect(result.nestedClasses.length, equals(2));
    });

    test('multiple nested objects have correct names', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123'},
        'phone': {'number': '555'},
      }, 'User');
      final names = result.nestedClasses.map((n) => n.name).toList();
      expect(names, contains('Address'));
      expect(names, contains('Phone'));
    });

    test('nested field in parent references correct class name', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123 Main'}
      }, 'User');
      final addressField = result.fields[0];
      expect(addressField.nestedClassName, equals('Address'));
      expect(addressField.type, contains('Address'));
    });

    test('duplicate class names get _ suffix', () {
      final gen = JsonToDartGenerator();
      // Create a scenario where same class name could be generated twice
      // This happens when there are two nested objects that would produce
      // the same PascalCase name
      final result = gen.generate({
        'address': {
          'address': {'street': '123'},
        }
      }, 'User');
      // The inner address class may get a _ suffix
      final allNames = <String>[];
      void collectNames(GeneratedClass gc) {
        allNames.add(gc.name);
        for (final nested in gc.nestedClasses) {
          collectNames(nested);
        }
      }

      collectNames(result);
      // All names should be unique
      expect(allNames.toSet().length, equals(allNames.length));
    });

    test('three levels deep nesting', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'level1': {
          'level2': {
            'level3': {
              'value': 'deep',
            }
          }
        }
      }, 'Root');
      expect(result.nestedClasses.length, equals(1));
      expect(result.nestedClasses[0].nestedClasses.length, equals(1));
      expect(result.nestedClasses[0].nestedClasses[0].nestedClasses.length,
          equals(1));
    });

    test('nested class from list of objects', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'users': [
          {'name': 'John', 'age': 30}
        ]
      }, 'Response');
      expect(result.nestedClasses.length, equals(1));
    });

    test('nested class from list uses singularized name', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'users': [
          {'name': 'John'}
        ]
      }, 'Response');
      // 'users' -> singularize('users') -> 'user' -> PascalCase -> 'User'
      expect(result.nestedClasses[0].name, equals('User'));
    });

    test('fullCode includes all nested class code recursively', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {
          'city': {'name': 'NYC'}
        }
      }, 'User');
      final fullCode = result.fullCode;
      expect(fullCode, contains('class User {'));
      expect(fullCode, contains('class Address {'));
      expect(fullCode, contains('class City {'));
    });

    test(
        'nested class with list of objects generates nested class for list item',
        () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'department': {
          'employees': [
            {'name': 'John'}
          ]
        }
      }, 'Company');
      // department nested class should have a nested class for Employee
      final departmentClass = result.nestedClasses[0];
      expect(departmentClass.nestedClasses.length, equals(1));
    });
  });

  group('Singularize behavior (via list of objects)', () {
    late JsonToDartGenerator generator;

    setUp(() {
      generator = JsonToDartGenerator();
    });

    test('orders -> Order (removes s)', () {
      final result = generator.generate({
        'orders': [
          {'id': 1}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Order'));
    });

    test('categories -> Category (ies -> y)', () {
      final result = generator.generate({
        'categories': [
          {'name': 'tech'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Category'));
    });

    test('addresses -> Addres (es removed)', () {
      // Note: _singularize('addresses') removes 'es' -> 'address' but wait
      // The field name is 'addresses', snakeToCamel('addresses') = 'addresses'
      // _singularize('addresses') -> ends with 'es' -> 'address'
      // Wait no: 'addresses' ends with 'ies'? No. 'addresses' ends with 'es'
      // Actually 'addresses' ends with 'es' but also with 'sses'
      // Check: endsWith('ies')? 'addresses' does not end with 'ies' -> no
      // endsWith('es')? yes -> remove last 2 chars -> 'address'
      // Then PascalCase -> 'Address'
      final result = generator.generate({
        'addresses': [
          {'street': '123'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Address'));
    });

    test('items -> Item (removes s)', () {
      final result = generator.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Item'));
    });

    test('data -> Data (no s ending, stays same)', () {
      final result = generator.generate({
        'data': [
          {'value': 1}
        ]
      }, 'Test');
      // 'data' does not end with 'ies', 'es', or 's' -> stays 'data'
      // PascalCase -> 'Data'
      expect(result.nestedClasses[0].name, equals('Data'));
    });

    test('classes -> Class (es removal)', () {
      // 'classes' -> snakeToCamel -> 'classes'
      // _singularize('classes') -> endsWith 'ies'? No. endsWith 'es'? Yes -> 'class'
      // PascalCase -> 'Class'
      final result = generator.generate({
        'classes': [
          {'name': 'Math'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Class'));
    });

    test('tags -> Tag (removes s)', () {
      // But tags is List<String> if first element is string, not Map
      // So use map items
      final result = generator.generate({
        'tags': [
          {'label': 'important'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Tag'));
    });

    test('users -> User (removes s)', () {
      final result = generator.generate({
        'users': [
          {'name': 'John'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('User'));
    });

    test('entries -> Entr (ies -> y)', () {
      // 'entries' ends with 'ies' -> remove 'ies' add 'y' -> 'entry'
      // PascalCase -> 'Entry'
      final result = generator.generate({
        'entries': [
          {'value': 1}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Entry'));
    });

    test('buses -> Bus (es removal)', () {
      final result = generator.generate({
        'buses': [
          {'number': 42}
        ]
      }, 'Test');
      // 'buses' -> endsWith 'ies'? No. endsWith 'es'? Yes -> 'bus'
      expect(result.nestedClasses[0].name, equals('Bus'));
    });

    test('single char s is not singularized', () {
      // 's' has length 1, so the condition word.length > 1 is false
      // But this is a list field key, so 's' -> snakeToCamel -> 's'
      // _singularize('s') -> endsWith('ies')? no. endsWith('es')? no.
      // endsWith('s') && length > 1? length == 1, so no. -> returns 's'
      final result = generator.generate({
        's': [
          {'x': 1}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('S'));
    });

    test('companies -> Company (ies -> y)', () {
      final result = generator.generate({
        'companies': [
          {'name': 'Acme'}
        ]
      }, 'Test');
      expect(result.nestedClasses[0].name, equals('Company'));
    });
  });

  group('Snake_case to camelCase in field names', () {
    late JsonToDartGenerator generator;

    setUp(() {
      generator = JsonToDartGenerator();
    });

    test('user_name -> userName in generated field', () {
      final result = generator.generate({'user_name': 'John'}, 'Test');
      expect(result.fields[0].name, equals('userName'));
      expect(result.code, contains('final String? userName;'));
    });

    test('_id -> id (leading underscore removed)', () {
      final result = generator.generate({'_id': 'abc123'}, 'Test');
      expect(result.fields[0].name, equals('id'));
    });

    test('USER_TYPE -> userType', () {
      // CaseConverter.snakeToCamel('USER_TYPE') -> has _, so split
      // Remove leading _ (none). Split by _: ['USER', 'TYPE']
      // First part lowercase: 'user'. Second part: capitalize first 'Type'
      // Result: 'userType'
      final result = generator.generate({'USER_TYPE': 'admin'}, 'Test');
      expect(result.fields[0].name, equals('userType'));
    });

    test('alreadyCamel -> alreadyCamel (preserved)', () {
      // No underscore -> first letter lowercase + rest
      // 'alreadyCamel' -> 'a' lowercase + 'lreadyCamel' = 'alreadyCamel'
      final result = generator.generate({'alreadyCamel': 'value'}, 'Test');
      expect(result.fields[0].name, equals('alreadyCamel'));
    });

    test('first_name -> firstName', () {
      final result = generator.generate({'first_name': 'John'}, 'Test');
      expect(result.fields[0].name, equals('firstName'));
    });

    test('is_active -> isActive', () {
      final result = generator.generate({'is_active': true}, 'Test');
      expect(result.fields[0].name, equals('isActive'));
    });

    test('created_at -> createdAt', () {
      final result = generator.generate({'created_at': '2024-01-01'}, 'Test');
      expect(result.fields[0].name, equals('createdAt'));
    });

    test('simple single word stays lowercase', () {
      final result = generator.generate({'name': 'test'}, 'Test');
      expect(result.fields[0].name, equals('name'));
    });

    test('JSON key is preserved in jsonKey field', () {
      final result = generator.generate({'user_name': 'John'}, 'Test');
      expect(result.fields[0].jsonKey, equals('user_name'));
    });

    test('multiple underscores: a__b -> aB', () {
      // snakeToCamel('a__b'): has underscore, remove leading _ (none)
      // clean = 'a__b', split by _+: ['a', 'b']
      // first part: 'a', second: capitalize 'B' -> 'aB'
      final result = generator.generate({'a__b': 'test'}, 'Test');
      expect(result.fields[0].name, equals('aB'));
    });

    test('PascalCase input -> pascalCase (first letter lowered)', () {
      // 'UserName' has no underscore -> first letter lowercase + rest
      // -> 'userName'
      final result = generator.generate({'UserName': 'test'}, 'Test');
      expect(result.fields[0].name, equals('userName'));
    });

    test('field with all lowercase no underscores stays same', () {
      final result = generator.generate({'email': 'test@test.com'}, 'Test');
      expect(result.fields[0].name, equals('email'));
    });
  });

  group('Edge Cases', () {
    test('empty JSON produces class with no fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({}, 'Empty');
      expect(result.fields, isEmpty);
      expect(result.name, equals('Empty'));
    });

    test('empty JSON produces no nested classes', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({}, 'Empty');
      expect(result.nestedClasses, isEmpty);
    });

    test('empty JSON produces no warnings', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({}, 'Empty');
      expect(result.warnings, isEmpty);
    });

    test('single field JSON', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.fields.length, equals(1));
    });

    test('JSON with 20+ fields', () {
      final gen = JsonToDartGenerator();
      final json = <String, dynamic>{};
      for (int i = 0; i < 25; i++) {
        json['field_$i'] = 'value_$i';
      }
      final result = gen.generate(json, 'Big');
      expect(result.fields.length, equals(25));
    });

    test('JSON with 20+ fields all have correct types', () {
      final gen = JsonToDartGenerator();
      final json = <String, dynamic>{};
      for (int i = 0; i < 20; i++) {
        json['field_$i'] = i;
      }
      final result = gen.generate(json, 'Big');
      for (final field in result.fields) {
        expect(field.type, equals('int?'));
      }
    });

    test('deeply nested JSON (3+ levels)', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'l1': {
          'l2': {
            'l3': {
              'l4': {
                'value': 'deep',
              }
            }
          }
        }
      }, 'Deep');
      // Verify 4 levels of nesting exist
      expect(result.nestedClasses.length, equals(1));
      var current = result.nestedClasses[0];
      expect(current.nestedClasses.length, equals(1));
      current = current.nestedClasses[0];
      expect(current.nestedClasses.length, equals(1));
      current = current.nestedClasses[0];
      // L3 contains l4 which is a nested object -> 1 nested class
      expect(current.nestedClasses.length, equals(1));
      // L4 has only 'value': 'deep' (a string, not nested)
      final deepest = current.nestedClasses[0];
      expect(deepest.nestedClasses.length, equals(0));
      expect(deepest.fields[0].name, equals('value'));
    });

    test('JSON with all types mixed', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'id': 1,
        'name': 'John',
        'active': true,
        'score': 9.5,
        'unknown': null,
        'address': {'street': '123'},
        'tags': ['a', 'b'],
        'items': [
          {'name': 'test'}
        ],
        'empty_list': [],
      }, 'Mixed');
      expect(result.fields.length, equals(9));
      expect(result.fields[0].type, equals('int?'));
      expect(result.fields[1].type, equals('String?'));
      expect(result.fields[2].type, equals('bool?'));
      expect(result.fields[3].type, equals('double?'));
      expect(result.fields[4].type, equals('String?'));
      expect(result.fields[5].isNestedObject, isTrue);
      expect(result.fields[6].isList, isTrue);
      expect(result.fields[7].isList, isTrue);
      expect(result.fields[7].isNestedObject, isTrue);
      expect(result.fields[8].type, equals('List<dynamic>?'));
    });

    test('reusing generator for multiple generates clears state', () {
      final gen = JsonToDartGenerator();
      final result1 = gen.generate({'id': 1}, 'First');
      final result2 = gen.generate({'id': 1}, 'Second');
      expect(result1.name, equals('First'));
      expect(result2.name, equals('Second'));
      // Both should work independently
      expect(result1.fields.length, equals(1));
      expect(result2.fields.length, equals(1));
    });

    test('reusing generator clears _generatedClassNames', () {
      final gen = JsonToDartGenerator();
      // First call creates a class named 'User'
      gen.generate({
        'address': {'street': '123'}
      }, 'User');
      // Second call should also be able to create 'User' without suffix
      final result2 = gen.generate({'id': 1}, 'User');
      expect(result2.name, equals('User'));
    });

    test('class name from snake_case is PascalCase', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'user_response');
      expect(result.name, equals('UserResponse'));
    });

    test('class name already PascalCase stays PascalCase', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'UserResponse');
      expect(result.name, equals('UserResponse'));
    });

    test('class name camelCase becomes PascalCase', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'userResponse');
      expect(result.name, equals('UserResponse'));
    });

    test('generator with default options', () {
      final gen = JsonToDartGenerator();
      expect(gen.options.generateFromJson, isTrue);
      expect(gen.options.generateToJson, isTrue);
      expect(gen.options.generateCopyWith, isFalse);
      expect(gen.options.generateEquality, isFalse);
      expect(gen.options.addLogging, isTrue);
      expect(gen.options.allNullable, isTrue);
    });

    test('generated name stored in result', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'test_model');
      expect(result.name, equals('TestModel'));
    });

    test('JSON with only nested objects', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'a': {'x': 1},
        'b': {'y': 2},
        'c': {'z': 3},
      }, 'Test');
      expect(result.nestedClasses.length, equals(3));
      expect(result.fields.length, equals(3));
      for (final field in result.fields) {
        expect(field.isNestedObject, isTrue);
      }
    });

    test('JSON with only lists', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'ids': [1, 2],
        'names': ['a', 'b'],
        'flags': [true, false],
      }, 'Test');
      for (final field in result.fields) {
        expect(field.isList, isTrue);
      }
    });

    test('JSON with only null values', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'a': null,
        'b': null,
        'c': null,
      }, 'Test');
      expect(result.warnings.length, equals(3));
      for (final field in result.fields) {
        expect(field.type, equals('String?'));
        expect(field.nullable, isTrue);
      }
    });
  });

  group('_getSafeMethod (via generated code)', () {
    late JsonToDartGenerator generator;

    setUp(() {
      generator = JsonToDartGenerator();
    });

    test('int type uses safeInt', () {
      final result = generator.generate({'count': 42}, 'Test');
      expect(result.code, contains('safeInt'));
    });

    test('double type uses safeDouble', () {
      final result = generator.generate({'price': 9.99}, 'Test');
      expect(result.code, contains('safeDouble'));
    });

    test('bool type uses safeBool', () {
      final result = generator.generate({'active': true}, 'Test');
      expect(result.code, contains('safeBool'));
    });

    test('String type uses safeString', () {
      final result = generator.generate({'name': 'John'}, 'Test');
      expect(result.code, contains('safeString'));
    });

    test('null field (defaults to String) uses safeString', () {
      final result = generator.generate({'field': null}, 'Test');
      expect(result.code, contains('safeString'));
    });

    test('unknown type defaults to safeString', () {
      // The _getSafeMethod default case returns safeString
      // This is hit when the type is something like 'dynamic'
      // A null field becomes 'String?' so it uses safeString directly
      // The default case is used for unrecognized types
      final result = generator.generate({'field': null}, 'Test');
      expect(result.code, contains('safeString'));
    });
  });

  group('Code formatting and structure', () {
    test('fromJson factory starts with proper indentation', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('  factory Test.fromJson'));
    });

    test('toJson method starts with proper indentation', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('  Map<String, dynamic> toJson()'));
    });

    test('field declarations have 2-space indentation', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains('  final int? id;'));
      expect(result.code, contains('  final String? name;'));
    });

    test('fromJson field assignments have 6-space indentation', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains("      id: json.safeInt('id')"));
    });

    test('toJson entries have 8-space indentation', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains("        'id': id"));
    });

    test('constructor closing has 2-space indentation when fields exist', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('  });'));
    });

    test('generated code starts with class keyword', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code.trimLeft(), startsWith('class'));
    });
  });

  group('Integration: Full class generation', () {
    test('complete class with all primitive types', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'id': 1,
        'name': 'test',
        'active': true,
        'score': 3.14,
      }, 'User');
      expect(result.code, contains('class User {'));
      expect(result.code, contains('final int? id;'));
      expect(result.code, contains('final String? name;'));
      expect(result.code, contains('final bool? active;'));
      expect(result.code, contains('final double? score;'));
      expect(result.code, contains('User({'));
      expect(result.code, contains('factory User.fromJson'));
      expect(result.code, contains('Map<String, dynamic> toJson()'));
    });

    test('complete class with nested object and list', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'id': 1,
        'address': {'street': '123 Main'},
        'orders': [
          {'item': 'book'}
        ],
      }, 'User');
      final fullCode = result.fullCode;
      expect(fullCode, contains('class User {'));
      expect(fullCode, contains('class Address {'));
      expect(fullCode, contains('class Order {'));
    });

    test('complete class with all options enabled', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateFromJson: true,
          generateToJson: true,
          generateCopyWith: true,
          generateEquality: true,
          addLogging: true,
          allNullable: true,
        ),
      );
      final result = gen.generate({
        'id': 1,
        'name': 'John',
      }, 'User');
      expect(result.code, contains('factory User.fromJson'));
      expect(result.code, contains('Map<String, dynamic> toJson()'));
      expect(result.code, contains('User copyWith({'));
      expect(result.code, contains('operator =='));
      expect(result.code, contains('hashCode'));
      expect(result.code, contains('DtoLogger.parse'));
    });

    test('complete class with no options generates minimal code', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateFromJson: false,
          generateToJson: false,
          generateCopyWith: false,
          generateEquality: false,
          addLogging: false,
        ),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('class Test {'));
      expect(result.code, contains('final int? id;'));
      expect(result.code, contains('Test({'));
      expect(result.code, isNot(contains('fromJson')));
      expect(result.code, isNot(contains('toJson')));
      expect(result.code, isNot(contains('copyWith')));
      expect(result.code, isNot(contains('operator ==')));
    });

    test('fromJson without logging uses direct return', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: false),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'User');
      expect(result.code, contains('return User('));
      expect(result.code, contains('    );'));
      expect(result.code, isNot(contains('DtoLogger')));
    });

    test('fromJson with logging wraps in DtoLogger.parse', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(addLogging: true),
      );
      final result = gen.generate({'id': 1, 'name': 'test'}, 'User');
      expect(result.code, contains('return DtoLogger.parse(json, () => User('));
      expect(result.code, contains("    ), 'User');"));
    });

    test('toJson with nested object and list of objects', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'profile': {'bio': 'hello'},
        'posts': [
          {'title': 'test'}
        ],
        'name': 'John',
      }, 'User');
      expect(result.code, contains("'profile': profile?.toJson()"));
      expect(result.code,
          contains("'posts': posts?.map((e) => e.toJson()).toList()"));
      expect(result.code, contains("'name': name"));
    });

    test('non-nullable fields with all options', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          allNullable: false,
          generateFromJson: true,
          generateToJson: true,
          generateCopyWith: true,
          generateEquality: true,
        ),
      );
      final result = gen.generate({'id': 1, 'name': 'John'}, 'User');
      expect(result.code, contains('final int id;'));
      expect(result.code, contains('final String name;'));
      expect(result.code, contains('required this.id'));
      expect(result.code, contains('required this.name'));
    });
  });

  group('Multiple fields - comma handling', () {
    test('single field in fromJson has no trailing comma', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      // The last (and only) field should not have a comma after it
      expect(result.code, contains("id: json.safeInt('id')\n"));
    });

    test('two fields in fromJson: first has comma, last does not', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains("id: json.safeInt('id'),"));
      // The last field should not have comma (just newline)
      expect(result.code, contains("name: json.safeString('name')\n"));
    });

    test('single field in toJson has no trailing comma', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains("'id': id\n"));
    });

    test('two fields in toJson: first has comma, last does not', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.code, contains("'id': id,"));
    });

    test('three fields in fromJson: first two have commas', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'id': 1,
        'name': 'test',
        'active': true,
      }, 'Test');
      expect(result.code, contains("id: json.safeInt('id'),"));
      expect(result.code, contains("name: json.safeString('name'),"));
      expect(result.code, contains("active: json.safeBool('active')\n"));
    });
  });

  group('GeneratedClass.name consistency', () {
    test('result name matches class declaration', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'MyModel');
      expect(result.code, contains('class ${result.name} {'));
    });

    test('result name matches constructor', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'MyModel');
      expect(result.code, contains('${result.name}({'));
    });

    test('result name matches fromJson factory', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'MyModel');
      expect(result.code, contains('factory ${result.name}.fromJson'));
    });

    test('nested class name matches its own code', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'address': {'street': '123'}
      }, 'User');
      final nested = result.nestedClasses[0];
      expect(nested.code, contains('class ${nested.name} {'));
    });
  });

  group('safeListOf type extraction', () {
    test('List<int>? extracts int for safeListOf', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'ids': [1, 2]
      }, 'Test');
      expect(result.code, contains('safeListOf<int>'));
    });

    test('List<String>? extracts String for safeListOf', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'names': ['a']
      }, 'Test');
      expect(result.code, contains('safeListOf<String>'));
    });

    test('List<double>? extracts double for safeListOf', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'vals': [1.0]
      }, 'Test');
      expect(result.code, contains('safeListOf<double>'));
    });

    test('List<bool>? extracts bool for safeListOf', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'flags': [true]
      }, 'Test');
      expect(result.code, contains('safeListOf<bool>'));
    });

    test('List<dynamic>? for empty list uses safeListOf<dynamic>', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'items': []}, 'Test');
      expect(result.code, contains('safeListOf<dynamic>'));
    });

    test('non-nullable List<int> extracts int for safeListOf', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({
        'ids': [1, 2]
      }, 'Test');
      expect(result.code, contains('safeListOf<int>'));
    });
  });

  group('Constructor forms', () {
    test('no fields: compact constructor', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({}, 'Empty');
      expect(result.code, contains('Empty();'));
    });

    test('one nullable field: no required keyword', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('this.id,'));
      expect(result.code, isNot(contains('required this.id')));
    });

    test('one non-nullable field: has required keyword', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('required this.id,'));
    });

    test('mixed nullable and non-nullable fields', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({
        'id': 1,
        'maybe': null,
      }, 'Test');
      // id is int (non-nullable) -> required
      // maybe is null -> String? (always nullable) -> no required
      expect(result.code, contains('required this.id,'));
      expect(result.code, isNot(contains('required this.maybe')));
    });

    test('constructor with multiple fields all nullable', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'a': 1,
        'b': 'test',
        'c': true,
      }, 'Test');
      expect(result.code, contains('this.a,'));
      expect(result.code, contains('this.b,'));
      expect(result.code, contains('this.c,'));
    });
  });

  group('Warnings collection', () {
    test('no warnings for normal fields', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'id': 1, 'name': 'test'}, 'Test');
      expect(result.warnings, isEmpty);
    });

    test('warning for null field', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'field': null}, 'Test');
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], contains('is null'));
    });

    test('warning for empty list', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'items': []}, 'Test');
      expect(result.warnings.length, equals(1));
      expect(result.warnings[0], equals('Empty list'));
    });

    test('multiple warnings collected', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'a': null,
        'b': null,
        'c': [],
      }, 'Test');
      expect(result.warnings.length, equals(3));
    });

    test('warnings are strings from field warnings', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({'x': null}, 'Test');
      expect(result.warnings[0], equals(result.fields[0].warning));
    });

    test('non-warning fields do not add to warnings', () {
      final gen = JsonToDartGenerator();
      final result = gen.generate({
        'id': 1,
        'field': null,
        'name': 'test',
      }, 'Test');
      expect(result.warnings.length, equals(1));
    });
  });

  group('copyWith edge cases', () {
    test('copyWith with nested object field', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({
        'address': {'street': '123'}
      }, 'User');
      expect(result.code, contains('copyWith'));
      // The type should be nullable in copyWith params
      expect(result.code, contains('Address?'));
    });

    test('copyWith with list field', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateCopyWith: true),
      );
      final result = gen.generate({
        'tags': ['a', 'b']
      }, 'User');
      expect(result.code, contains('copyWith'));
      expect(result.code, contains('tags: tags ?? this.tags'));
    });

    test('copyWith with non-nullable type adds ? to param', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateCopyWith: true,
          allNullable: false,
        ),
      );
      final result = gen.generate({'id': 1}, 'Test');
      // int (non-nullable) becomes int? in copyWith params
      expect(result.code, contains('int? id,'));
    });

    test('copyWith with already-nullable type keeps same type', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(
          generateCopyWith: true,
          allNullable: true,
        ),
      );
      final result = gen.generate({'id': 1}, 'Test');
      // int? already ends with ?, stays int?
      expect(result.code, contains('int? id,'));
    });
  });

  group('equality edge cases', () {
    test('equality with snake_case field uses camelCase name', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'user_name': 'John'}, 'Test');
      expect(result.code, contains('other.userName == userName'));
    });

    test('equality operator== uses || between identical and type check', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, contains('identical(this, other) ||'));
    });

    test('hashCode with 4 fields lists all in Object.hash', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({
        'a': 1,
        'b': 2,
        'c': 3,
        'd': 4,
      }, 'Test');
      expect(result.code, contains('Object.hash(a, b, c, d)'));
    });

    test('equality with single field does not use Object.hash', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(generateEquality: true),
      );
      final result = gen.generate({'id': 1}, 'Test');
      expect(result.code, isNot(contains('Object.hash')));
      expect(result.code, contains('id.hashCode'));
    });
  });

  group('Generator reuse and state', () {
    test('same generator can generate different classes', () {
      final gen = JsonToDartGenerator();
      final r1 = gen.generate({'id': 1}, 'First');
      final r2 = gen.generate({'name': 'test'}, 'Second');
      expect(r1.name, equals('First'));
      expect(r2.name, equals('Second'));
    });

    test('second generate does not retain first generate nested names', () {
      final gen = JsonToDartGenerator();
      gen.generate({
        'address': {'street': '123'}
      }, 'First');
      // Second call should not have Address in _generatedClassNames
      final r2 = gen.generate({
        'address': {'street': '456'}
      }, 'Second');
      expect(r2.nestedClasses[0].name, equals('Address'));
    });

    test('generate returns independent results', () {
      final gen = JsonToDartGenerator();
      final r1 = gen.generate({'a': 1}, 'A');
      final r2 = gen.generate({'b': 2}, 'B');
      expect(r1.fields[0].name, equals('a'));
      expect(r2.fields[0].name, equals('b'));
    });
  });

  group('Non-nullable nested and list types in code', () {
    test('non-nullable nested object type in field declaration', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({
        'address': {'street': '123'}
      }, 'User');
      expect(result.fields[0].type, equals('Address'));
    });

    test('non-nullable list of objects type in field declaration', () {
      final gen = JsonToDartGenerator(
        options: const GeneratorOptions(allNullable: false),
      );
      final result = gen.generate({
        'items': [
          {'name': 'test'}
        ]
      }, 'User');
      expect(result.fields[0].type, startsWith('List<'));
      expect(result.fields[0].type, isNot(endsWith('?')));
    });
  });
}
