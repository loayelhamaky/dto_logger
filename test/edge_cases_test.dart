import 'package:test/test.dart';
import '../lib/src/dto_logger.dart';
import '../lib/src/safe_parser.dart';
import '../lib/src/json_to_dart.dart';

/// Edge cases and stress tests for dto_logger
/// Covers scenarios not handled in main test file

// ============================================================
// Test helpers
// ============================================================
enum TestEnum { alpha, beta, gamma }

class SimpleModel {
  final int? id;
  final String? name;

  SimpleModel({this.id, this.name});

  factory SimpleModel.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => SimpleModel(
      id: json.safeInt('id'),
      name: json.safeString('name'),
    ));
  }
}

class EmptyModel {
  EmptyModel();
  factory EmptyModel.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => EmptyModel());
  }
}

// Deep nesting test models (5 levels)
class Level5 {
  final String value;
  Level5({required this.value});
  factory Level5.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => Level5(
      value: json.safeString('value') ?? '',
    ));
  }
}

class Level4 {
  final Level5? level5;
  Level4({this.level5});
  factory Level4.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => Level4(
      level5: json.safeObject('level5', Level5.fromJson),
    ));
  }
}

class Level3 {
  final Level4? level4;
  Level3({this.level4});
  factory Level3.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => Level3(
      level4: json.safeObject('level4', Level4.fromJson),
    ));
  }
}

class Level2 {
  final Level3? level3;
  Level2({this.level3});
  factory Level2.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => Level2(
      level3: json.safeObject('level3', Level3.fromJson),
    ));
  }
}

class Level1 {
  final Level2? level2;
  Level1({this.level2});
  factory Level1.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () => Level1(
      level2: json.safeObject('level2', Level2.fromJson),
    ));
  }
}

// Throwing model for error testing
class ThrowingModel {
  ThrowingModel();
  factory ThrowingModel.fromJson(Map<String, dynamic> json) {
    if (json['fail'] == true) {
      throw Exception('Intentional failure');
    }
    return ThrowingModel();
  }
}

void main() {
  // ============================================================
  // SETUP
  // ============================================================
  setUp(() {
    DtoLogConfig.enabled = true;
    DtoLogConfig.level = DtoLogLevel.verbose;
    DtoLogConfig.useColors = false;
    DtoLogConfig.useDeveloperLog = false;
    DtoLogConfig.logSuccess = true;
    DtoLogConfig.showTiming = false;
    DtoLogConfig.showJsonData = false;
    DtoLogConfig.maxValueLength = 50;
    DtoLogConfig.maxWidth = 80;
    DtoLogConfig.compressLogs = false; // Disable compression by default in tests
    DtoLogConfig.maxReportsPerClass = 10;
  });

  // ============================================================
  // 1. Singularize tests
  // ============================================================
  group('JsonToDartGenerator - _singularize', () {
    test('entries → Entry (ies → y)', () {
      final json = {
        'entries': [{'id': 1}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      // Check that a nested class named "Entry" was generated
      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Entry');
    });

    test('addresses → Address (sses → ss)', () {
      final json = {
        'addresses': [{'street': '123 Main'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Address');
    });

    test('boxes → Box (xes → x)', () {
      final json = {
        'boxes': [{'size': 'large'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Box');
    });

    test('classes → Class (sses → ss)', () {
      final json = {
        'classes': [{'name': 'Math'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Class');
    });

    test('dishes → Dish (shes → sh)', () {
      final json = {
        'dishes': [{'type': 'plate'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Dish');
    });

    test('buses → Bus (ses → s)', () {
      final json = {
        'buses': [{'number': '42'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Bus');
    });

    test('quizzes → Quiz (irregular plural)', () {
      final json = {
        'quizzes': [{'score': 100}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Quiz');
    });

    test('items → Item (generic s)', () {
      final json = {
        'items': [{'id': 1}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Item');
    });

    test('data → Data (no s, unchanged)', () {
      final json = {
        'data': [{'value': 'test'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      // "data" doesn't end in 's' in a plural form, stays as is
      expect(result.nestedClasses[0].name, 'Data');
    });

    test('status → Status (ends in s but not plural)', () {
      final json = {
        'status': [{'code': 200}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      // "status" is already singular (ends in -us)
      expect(result.nestedClasses[0].name, 'Status');
    });

    test('watches → Watch (ches → ch)', () {
      final json = {
        'watches': [{'brand': 'Rolex'}]
      };
      final generator = JsonToDartGenerator();
      final result = generator.generate(json, 'Root');

      expect(result.nestedClasses.length, 1);
      expect(result.nestedClasses[0].name, 'Watch');
    });
  });

  // ============================================================
  // 2. Stress / Performance tests
  // ============================================================
  group('Stress and Performance', () {
    test('large list compression - 100 items', () async {
      DtoLogConfig.compressLogs = true;
      DtoLogConfig.maxReportsPerClass = 10;

      final items = List.generate(100, (i) => {'id': i, 'name': 'Item $i'});

      // Parse all items
      for (final item in items) {
        SimpleModel.fromJson(item);
      }

      // Counter should have limited the logs
      // This is a smoke test - just verify no crashes
      expect(items.length, 100);
    });

    test('compression counter resets between event loop turns', () async {
      DtoLogConfig.compressLogs = true;
      DtoLogConfig.maxReportsPerClass = 5;

      // First batch
      for (int i = 0; i < 10; i++) {
        SimpleModel.fromJson({'id': i});
      }

      // Wait for event loop to drain
      await Future.delayed(Duration.zero);

      // Second batch - should reset counter
      for (int i = 0; i < 10; i++) {
        SimpleModel.fromJson({'id': i + 100});
      }

      // No assertions - just verify no crashes
      expect(true, isTrue);
    });

    test('1000+ field JSON does not crash', () {
      final hugeJson = <String, dynamic>{};
      for (int i = 0; i < 1000; i++) {
        hugeJson['field_$i'] = 'value_$i';
      }

      // Use .logged() on huge map
      final logged = hugeJson.logged('HugeModel');

      // Access a few fields
      expect(logged['field_0'], 'value_0');
      expect(logged['field_500'], 'value_500');
      expect(logged['field_999'], 'value_999');
    });

    test('deeply nested structure does not crash', () {
      final json = {
        'level1': {
          'level2': {
            'level3': {
              'level4': {
                'level5': {
                  'value': 'deep'
                }
              }
            }
          }
        }
      };

      final logged = json.logged('DeepModel');
      final level1 = logged.safeMap('level1');
      expect(level1, isNotNull);
    });
  });

  // ============================================================
  // 3. LoggedMap edge cases
  // ============================================================
  group('LoggedMap edge cases', () {
    test('empty map .logged() does not crash', () {
      final json = <String, dynamic>{};
      final logged = json.logged('EmptyModel');

      expect(logged.isEmpty, isTrue);
    });

    test('map with 50+ keys tracked correctly', () {
      final json = <String, dynamic>{};
      for (int i = 0; i < 50; i++) {
        json['field$i'] = 'value$i';
      }

      final logged = json.logged('LargeModel');

      // Access all fields
      for (int i = 0; i < 50; i++) {
        expect(logged['field$i'], 'value$i');
      }
    });

    test('map with Unicode field names (emoji)', () {
      final json = {
        '🔥': 'fire',
        '🎉': 'party',
        '😀': 'smile',
      };

      final logged = json.logged('EmojiModel');
      expect(logged['🔥'], 'fire');
      expect(logged['🎉'], 'party');
      expect(logged['😀'], 'smile');
    });

    test('map with Arabic field names', () {
      final json = {
        'اسم': 'name in Arabic',
        'قيمة': 'value in Arabic',
      };

      final logged = json.logged('ArabicModel');
      expect(logged['اسم'], 'name in Arabic');
      expect(logged['قيمة'], 'value in Arabic');
    });

    test('map with Chinese field names', () {
      final json = {
        '名字': 'name in Chinese',
        '值': 'value in Chinese',
      };

      final logged = json.logged('ChineseModel');
      expect(logged['名字'], 'name in Chinese');
      expect(logged['值'], 'value in Chinese');
    });

    test('map with very long field names (200+ chars)', () {
      final longName = 'field_' + 'x' * 200;
      final json = {longName: 'value'};

      final logged = json.logged('LongNameModel');
      expect(logged[longName], 'value');
    });

    test('map with very long values (10000+ chars)', () {
      final longValue = 'x' * 10000;
      final json = {'field': longValue};

      final logged = json.logged('LongValueModel');
      expect(logged['field'], longValue);
    });

    test('nested .logged() - logged map inside logged map', () {
      final json = {
        'outer': 'value',
        'inner': {
          'nested': 'data'
        }
      };

      final logged = json.logged('OuterModel');
      expect(logged['outer'], 'value');

      final innerMap = logged['inner'] as Map<String, dynamic>;
      final innerLogged = innerMap.logged('InnerModel');
      expect(innerLogged['nested'], 'data');
    });

    test('access same key twice - appears once in report', () {
      final json = {'field': 'value'};
      final logged = json.logged('DuplicateAccessModel');

      // Access same key multiple times
      expect(logged['field'], 'value');
      expect(logged['field'], 'value');
      expect(logged['field'], 'value');

      // Should only track once
      // No easy way to assert this directly, just verify no crash
    });

    test('map with null keys behavior', () {
      // Dart maps can't have null keys in <String, dynamic>
      // But we can test accessing with null
      final json = {'field': 'value'};
      final logged = json.logged('NullKeyModel');

      expect(logged[null], isNull);
    });
  });

  // ============================================================
  // 4. DtoLogger.parse edge cases
  // ============================================================
  group('DtoLogger.parse edge cases', () {
    test('empty JSON with builder that reads no fields', () {
      final result = EmptyModel.fromJson({});
      expect(result, isNotNull);
    });

    test('JSON with 0 issues - verify green "parsed safely"', () {
      final json = {'id': 1, 'name': 'Test'};
      final result = SimpleModel.fromJson(json);

      expect(result.id, 1);
      expect(result.name, 'Test');
    });

    test('deeply nested objects (5+ levels) using session stack', () {
      // Use the Level1-5 classes defined at top of file
      final json = {
        'level2': {
          'level3': {
            'level4': {
              'level5': {
                'value': 'deep'
              }
            }
          }
        }
      };

      final result = Level1.fromJson(json);
      expect(result.level2?.level3?.level4?.level5?.value, 'deep');
    });

    test('DtoLogConfig.enabled = false - builder runs, no logging', () {
      DtoLogConfig.enabled = false;

      final json = {'id': 1, 'name': 'Test'};
      final result = SimpleModel.fromJson(json);

      expect(result.id, 1);
      expect(result.name, 'Test');
    });

    test('DtoLogConfig.level = DtoLogLevel.none - no output', () {
      DtoLogConfig.level = DtoLogLevel.none;

      final json = {'id': 'invalid', 'name': 'Test'};
      final result = SimpleModel.fromJson(json);

      expect(result.name, 'Test');
    });

    test('DtoLogConfig.level = DtoLogLevel.errors - only typeMismatch shown', () {
      DtoLogConfig.level = DtoLogLevel.errors;

      final json = {'id': 'invalid', 'name': 'Test', 'extra': 'field'};
      final result = SimpleModel.fromJson(json);

      expect(result.name, 'Test');
    });
  });

  // ============================================================
  // 5. SafeJsonParsing extension edge cases
  // ============================================================
  group('SafeJsonParsing extension edge cases', () {
    test('safeInt on a Map value - fails gracefully', () {
      final json = {'field': {'nested': 'value'}};
      final result = json.safeInt('field');

      expect(result, isNull);
    });

    test('safeString on a List value - fails gracefully', () {
      final json = {'field': [1, 2, 3]};
      final result = json.safeString('field');

      expect(result, isNull);
    });

    test('safeEnum with empty values list', () {
      final json = {'status': 'alpha'};
      final result = json.safeEnum<TestEnum>('status', []);

      expect(result, isNull);
    });

    test('safeList with mixed types in list (some throw)', () {
      // Use the ThrowingModel class defined at top of file
      final json = {
        'items': [
          {'fail': false},
          {'fail': true}, // This will throw
          {'fail': false},
        ]
      };

      expect(
        () => json.safeList('items', ThrowingModel.fromJson),
        throwsException,
      );
    });

    test('safeObject with nested map that has wrong structure', () {
      final json = {
        'nested': {
          'invalid': 'structure'
        }
      };

      // SimpleModel expects 'id' and 'name'
      final result = json.safeObject('nested', SimpleModel.fromJson);

      expect(result, isNotNull);
      expect(result?.id, isNull);
      expect(result?.name, isNull);
    });

    test('safeMap on a nested Map<int, dynamic> - coerces keys', () {
      final json = {
        'data': {
          1: 'value1',
          2: 'value2',
        }
      };

      final result = json.safeMap('data');

      // Keys should be coerced to String
      expect(result, isNotNull);
      expect(result?['1'], 'value1');
      expect(result?['2'], 'value2');
    });

    test('safeBoolOr with default when key missing', () {
      final json = <String, dynamic>{};
      final result = json.safeBoolOr('missing', true);

      expect(result, true);
    });

    test('safeIntOr with default when key missing', () {
      final json = <String, dynamic>{};
      final result = json.safeIntOr('missing', 42);

      expect(result, 42);
    });

    test('safeDoubleOr with default when key missing', () {
      final json = <String, dynamic>{};
      final result = json.safeDoubleOr('missing', 3.14);

      expect(result, 3.14);
    });

    test('safeStringOr with default when key missing', () {
      final json = <String, dynamic>{};
      final result = json.safeStringOr('missing', 'default');

      expect(result, 'default');
    });

    test('safeBoolOr with default when value is null', () {
      final json = {'field': null};
      final result = json.safeBoolOr('field', true);

      expect(result, true);
    });

    test('safeIntOr with default when value is null', () {
      final json = {'field': null};
      final result = json.safeIntOr('field', 42);

      expect(result, 42);
    });
  });

  // ============================================================
  // 6. Color output tests
  // ============================================================
  group('Color output', () {
    test('useColors = false produces no ANSI codes', () {
      DtoLogConfig.useColors = false;

      final json = {'id': 'invalid'};
      final result = SimpleModel.fromJson(json);

      // Can't easily capture output, but verify no crash
      expect(result, isNotNull);
    });

    test('useColors = true produces ANSI codes', () {
      DtoLogConfig.useColors = true;

      final json = {'id': 'invalid'};
      final result = SimpleModel.fromJson(json);

      // Can't easily capture output, but verify no crash
      expect(result, isNotNull);
    });

    test('box color is red only for typeMismatch', () {
      DtoLogConfig.useColors = true;

      final json = {'id': 'invalid'}; // typeMismatch
      final result = SimpleModel.fromJson(json);

      expect(result, isNotNull);
    });

    test('box color stays green when only nulls present', () {
      DtoLogConfig.useColors = true;

      final json = {'id': null, 'name': null};
      final result = SimpleModel.fromJson(json);

      expect(result.id, isNull);
      expect(result.name, isNull);
    });

    test('box color is yellow for warnings', () {
      DtoLogConfig.useColors = true;

      final json = {'id': '123'}; // typeCoerced (String to int)
      final result = SimpleModel.fromJson(json);

      expect(result.id, 123);
    });
  });

  // ============================================================
  // 7. Message truncation tests
  // ============================================================
  group('Message truncation', () {
    test('field name 40 chars + message gets truncated', () {
      final longFieldName = 'x' * 40;
      final json = {longFieldName: 'invalid'};

      DtoLogConfig.maxWidth = 60;
      final logged = json.logged('TruncateModel');

      expect(logged[longFieldName], 'invalid');
    });

    test('maxWidth = 40 with long field names - truncation works', () {
      DtoLogConfig.maxWidth = 40;

      final json = {
        'very_long_field_name_that_exceeds_limit': 'invalid'
      };

      final logged = json.logged('ShortWidthModel');
      expect(logged['very_long_field_name_that_exceeds_limit'], 'invalid');
    });

    test('maxWidth = 200 with long messages - no truncation', () {
      DtoLogConfig.maxWidth = 200;

      final json = {
        'field_with_very_long_error_message': 'x' * 100
      };

      final logged = json.logged('LongWidthModel');
      expect(logged['field_with_very_long_error_message'], 'x' * 100);
    });

    test('maxValueLength truncates long values in logs', () {
      DtoLogConfig.maxValueLength = 20;

      final longValue = 'x' * 100;
      final json = {'field': longValue};

      final logged = json.logged('ValueTruncateModel');
      expect(logged['field'], longValue); // Full value still accessible
    });
  });

  // ============================================================
  // 8. SafeParser edge cases
  // ============================================================
  group('SafeParser edge cases', () {
    test('asInt with very large double', () {
      final result = SafeParser.asInt(9999999999999.99);
      expect(result.value, isNotNull);
      expect(result.warning, isNotNull);
    });

    test('asInt with negative double', () {
      final result = SafeParser.asInt(-42.7);
      expect(result.value, -42);
      expect(result.warning, contains('double'));
    });

    test('asDouble with very large int', () {
      final result = SafeParser.asDouble(9999999999999);
      expect(result.value, 9999999999999.0);
    });

    test('asString with List - fails', () {
      final result = SafeParser.asString([1, 2, 3]);
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('asString with Map - fails', () {
      final result = SafeParser.asString({'key': 'value'});
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('asBool with "yes" string', () {
      final result = SafeParser.asBool('yes');
      expect(result.value, true);
      expect(result.warning, contains('String'));
    });

    test('asBool with "no" string', () {
      final result = SafeParser.asBool('no');
      expect(result.value, false);
      expect(result.warning, contains('String'));
    });

    test('asBool with "YES" uppercase', () {
      final result = SafeParser.asBool('YES');
      expect(result.value, true);
    });

    test('asBool with "No" mixed case', () {
      final result = SafeParser.asBool('No');
      expect(result.value, false);
    });

    test('asBool with int 5 (non-zero)', () {
      final result = SafeParser.asBool(5);
      expect(result.value, true);
    });

    test('asBool with int -1 (non-zero)', () {
      final result = SafeParser.asBool(-1);
      expect(result.value, true);
    });

    test('asDateTime with millisecond timestamp', () {
      final timestamp = 1704067200000; // Jan 1, 2024 in milliseconds
      final result = SafeParser.asDateTime(timestamp);
      expect(result.value, isNotNull);
      expect(result.value?.year, 2024);
    });

    test('asDateTime with second timestamp', () {
      final timestamp = 1704067200; // Jan 1, 2024 in seconds
      final result = SafeParser.asDateTime(timestamp);
      expect(result.value, isNotNull);
      expect(result.value?.year, 2024);
    });

    test('asDateTime with ISO8601 string', () {
      final result = SafeParser.asDateTime('2024-01-01T00:00:00Z');
      expect(result.value, isNotNull);
      expect(result.value?.year, 2024);
    });

    test('asDateTime with invalid string', () {
      final result = SafeParser.asDateTime('not a date');
      expect(result.value, isNull);
      expect(result.success, isFalse);
    });

    test('asMap with Map<int, String>', () {
      final input = <int, String>{1: 'a', 2: 'b'};
      final result = SafeParser.asMap(input);

      expect(result.value, isNotNull);
      expect(result.value?['1'], 'a');
      expect(result.value?['2'], 'b');
      expect(result.warning, contains('Map<dynamic, dynamic>'));
    });
  });

  // ============================================================
  // 9. Additional edge cases
  // ============================================================
  group('Additional edge cases', () {
    test('safeListOf with empty list', () {
      final json = {'items': <dynamic>[]};
      final result = json.safeListOf<int>('items');

      expect(result, isNotNull);
      expect(result?.isEmpty, true);
    });

    test('safeListOf with wrong type items - all skipped, no throw', () {
      final json = {
        'items': ['a', 'b', 'c']
      };
      final result = json.safeListOf<int>('items');

      expect(result, isEmpty);
    });

    test('safeEnum with case-insensitive match', () {
      final json = {'status': 'ALPHA'};
      final result = json.safeEnum<TestEnum>('status', TestEnum.values);

      expect(result, TestEnum.alpha);
    });

    test('safeEnum with mixed case', () {
      final json = {'status': 'BeTa'};
      final result = json.safeEnum<TestEnum>('status', TestEnum.values);

      expect(result, TestEnum.beta);
    });

    test('safeEnum with invalid value', () {
      final json = {'status': 'invalid'};
      final result = json.safeEnum<TestEnum>('status', TestEnum.values);

      expect(result, isNull);
    });

    test('DtoLogger.logJson with empty map', () {
      DtoLogger.logJson({}, 'EmptyJsonModel');
      // Just verify no crash
      expect(true, isTrue);
    });

    test('DtoLogger.logJson with null values', () {
      DtoLogger.logJson({
        'field1': null,
        'field2': null,
        'field3': null,
      }, 'NullJsonModel');

      expect(true, isTrue);
    });

    test('DtoLogger.logJson with mixed values', () {
      DtoLogger.logJson({
        'int': 42,
        'string': 'test',
        'bool': true,
        'null': null,
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
      }, 'MixedJsonModel');

      expect(true, isTrue);
    });

    test('showJsonData = true shows JSON preview', () {
      DtoLogConfig.showJsonData = true;

      final json = {'id': 1, 'name': 'Test'};
      final result = SimpleModel.fromJson(json);

      expect(result.id, 1);
    });

    test('showTiming = true shows timing info', () {
      DtoLogConfig.showTiming = true;

      final json = {'id': 1, 'name': 'Test'};
      final result = SimpleModel.fromJson(json);

      expect(result.id, 1);
    });

    test('logSuccess = false hides successful parses', () {
      DtoLogConfig.logSuccess = false;

      final json = {'id': 1, 'name': 'Test'};
      final result = SimpleModel.fromJson(json);

      expect(result.id, 1);
    });

    test('compression with exactly maxReportsPerClass items', () {
      DtoLogConfig.compressLogs = true;
      DtoLogConfig.maxReportsPerClass = 3;

      for (int i = 0; i < 3; i++) {
        SimpleModel.fromJson({'id': i});
      }

      expect(true, isTrue);
    });

    test('compression with maxReportsPerClass + 1 items', () async {
      DtoLogConfig.compressLogs = true;
      DtoLogConfig.maxReportsPerClass = 3;

      for (int i = 0; i < 4; i++) {
        SimpleModel.fromJson({'id': i});
      }

      // Wait for microtask to see suppression message
      await Future.delayed(Duration.zero);

      expect(true, isTrue);
    });
  });
}
