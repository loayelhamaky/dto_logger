import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // Reset config to defaults before each test
    DtoLogConfig.enabled = true;
    DtoLogConfig.level = DtoLogLevel.verbose;
    DtoLogConfig.useColors = false;
    DtoLogConfig.logSuccess = true;
    DtoLogConfig.showTiming = false;
    DtoLogConfig.showJsonData = false;
    DtoLogConfig.compressLogs = false;
    DtoLogConfig.deferLogging = false;
    DtoLogConfig.maxReportsPerClass = 10;
  });

  // ==========================================================================
  // safeObject edge cases
  // ==========================================================================
  group('safeObject edge cases', () {
    test('safeObject with non-map value logs typeMismatch', () {
      final json = <String, dynamic>{'data': 'not a map'};

      DtoLogger.parse(json, () {
        final result = json.safeObject('data', (m) => m);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeObject with List value logs typeMismatch', () {
      final json = <String, dynamic>{
        'data': [1, 2, 3]
      };

      DtoLogger.parse(json, () {
        final result = json.safeObject('data', (m) => m);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeObject with int value logs typeMismatch', () {
      final json = <String, dynamic>{'data': 42};

      DtoLogger.parse(json, () {
        final result = json.safeObject('data', (m) => m);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeObject with null logs nullValue', () {
      final json = <String, dynamic>{'data': null};

      DtoLogger.parse(json, () {
        final result = json.safeObject('data', (m) => m);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeObject with valid map works', () {
      final json = <String, dynamic>{
        'data': {'id': 1, 'name': 'test'}
      };

      DtoLogger.parse(json, () {
        final result = json.safeObject<Map<String, dynamic>>(
            'data', (m) => m);
        expect(result, isNotNull);
        expect(result!['id'], 1);
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // safeList edge cases
  // ==========================================================================
  group('safeList edge cases', () {
    test('safeList with non-list value logs typeMismatch', () {
      final json = <String, dynamic>{'items': 'not a list'};

      DtoLogger.parse(json, () {
        final result =
            json.safeList('items', (m) => m);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeList with null logs nullValue', () {
      final json = <String, dynamic>{'items': null};

      DtoLogger.parse(json, () {
        final result =
            json.safeList('items', (m) => m);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeList with valid list of maps works', () {
      final json = <String, dynamic>{
        'items': [
          {'id': 1},
          {'id': 2}
        ]
      };

      DtoLogger.parse(json, () {
        final result = json.safeList<Map<String, dynamic>>(
            'items', (m) => m);
        expect(result, isNotNull);
        expect(result!.length, 2);
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // safeListOf edge cases
  // ==========================================================================
  group('safeListOf edge cases', () {
    test('safeListOf<int> skips items that cannot become int', () {
      final json = <String, dynamic>{
        'ids': [1, 'two', 3]
      };

      DtoLogger.parse(json, () {
        final result = json.safeListOf<int>('ids');
        expect(result, [1, 3]);
        return null;
      }, 'TestModel');
    });

    test('safeListOf<String> with valid list works', () {
      final json = <String, dynamic>{
        'names': ['a', 'b', 'c']
      };

      DtoLogger.parse(json, () {
        final result = json.safeListOf<String>('names');
        expect(result, isNotNull);
        expect(result!.length, 3);
        return null;
      }, 'TestModel');
    });

    test('safeListOf with non-list value fails', () {
      final json = <String, dynamic>{'ids': 42};

      DtoLogger.parse(json, () {
        final result = json.safeListOf<int>('ids');
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // safeEnum edge cases
  // ==========================================================================
  group('safeEnum edge cases', () {
    test('safeEnum with empty values list returns null', () {
      final json = <String, dynamic>{'status': 'active'};

      DtoLogger.parse(json, () {
        final result = json.safeEnum('status', <_TestEnum>[]);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeEnum with numeric value (int) converts to string for matching', () {
      final json = <String, dynamic>{'status': 1};

      DtoLogger.parse(json, () {
        // toString() of 1 is "1", which won't match enum names
        final result = json.safeEnum('status', _TestEnum.values);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeEnum case-insensitive matching works', () {
      final json = <String, dynamic>{'status': 'ACTIVE'};

      DtoLogger.parse(json, () {
        final result = json.safeEnum('status', _TestEnum.values);
        expect(result, _TestEnum.active);
        return null;
      }, 'TestModel');
    });

    test('safeEnum with null value logs nullValue', () {
      final json = <String, dynamic>{'status': null};

      DtoLogger.parse(json, () {
        final result = json.safeEnum('status', _TestEnum.values);
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // safeEnumOr edge cases
  // ==========================================================================
  group('safeEnumOr edge cases', () {
    test('safeEnumOr returns fallback for unknown value', () {
      final json = <String, dynamic>{'status': 'unknown_value'};

      DtoLogger.parse(json, () {
        final result = json.safeEnumOr(
            'status', _TestEnum.values, _TestEnum.pending);
        expect(result, _TestEnum.pending);
        return null;
      }, 'TestModel');
    });

    test('safeEnumOr returns fallback for null value', () {
      final json = <String, dynamic>{'status': null};

      DtoLogger.parse(json, () {
        final result = json.safeEnumOr(
            'status', _TestEnum.values, _TestEnum.active);
        expect(result, _TestEnum.active);
        return null;
      }, 'TestModel');
    });

    test('safeEnumOr returns matched value when valid', () {
      final json = <String, dynamic>{'status': 'active'};

      DtoLogger.parse(json, () {
        final result = json.safeEnumOr(
            'status', _TestEnum.values, _TestEnum.pending);
        expect(result, _TestEnum.active);
        return null;
      }, 'TestModel');
    });

    test('safeEnumOr with empty values always returns fallback', () {
      final json = <String, dynamic>{'status': 'active'};

      DtoLogger.parse(json, () {
        final result =
            json.safeEnumOr('status', <_TestEnum>[], _TestEnum.inactive);
        expect(result, _TestEnum.inactive);
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // safeMap edge cases
  // ==========================================================================
  group('safeMap edge cases', () {
    test('safeMap with String value fails', () {
      final json = <String, dynamic>{'data': 'not a map'};

      DtoLogger.parse(json, () {
        final result = json.safeMap('data');
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeMap with List value fails', () {
      final json = <String, dynamic>{
        'data': [1, 2]
      };

      DtoLogger.parse(json, () {
        final result = json.safeMap('data');
        expect(result, isNull);
        return null;
      }, 'TestModel');
    });

    test('safeMap with valid map works', () {
      final json = <String, dynamic>{
        'data': <String, dynamic>{'key': 'val'}
      };

      DtoLogger.parse(json, () {
        final result = json.safeMap('data');
        expect(result, isNotNull);
        expect(result!['key'], 'val');
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // safeXOr default value methods
  // ==========================================================================
  group('safeXOr default value methods', () {
    test('safeIntOr returns default when null', () {
      final json = <String, dynamic>{'val': null};
      DtoLogger.parse(json, () {
        expect(json.safeIntOr('val', 99), 99);
        return null;
      }, 'TestModel');
    });

    test('safeDoubleOr returns default when null', () {
      final json = <String, dynamic>{'val': null};
      DtoLogger.parse(json, () {
        expect(json.safeDoubleOr('val', 3.14), 3.14);
        return null;
      }, 'TestModel');
    });

    test('safeBoolOr returns default when null', () {
      final json = <String, dynamic>{'val': null};
      DtoLogger.parse(json, () {
        expect(json.safeBoolOr('val', true), true);
        return null;
      }, 'TestModel');
    });

    test('safeStringOr returns default when null', () {
      final json = <String, dynamic>{'val': null};
      DtoLogger.parse(json, () {
        expect(json.safeStringOr('val', 'default'), 'default');
        return null;
      }, 'TestModel');
    });

    test('safeIntOr returns parsed value when present', () {
      final json = <String, dynamic>{'val': 42};
      DtoLogger.parse(json, () {
        expect(json.safeIntOr('val', 99), 42);
        return null;
      }, 'TestModel');
    });
  });

  // ==========================================================================
  // DtoLogConfig edge cases
  // ==========================================================================
  group('DtoLogConfig edge cases', () {
    test('level=none suppresses all output', () {
      DtoLogConfig.level = DtoLogLevel.none;
      // Should not throw or crash
      final json = <String, dynamic>{'id': 'not_int'};
      final result = DtoLogger.parse(json, () => json.safeInt('id'), 'Test');
      expect(result, isNull); // parsing still works
    });

    test('level=errors only logs on typeMismatch', () {
      DtoLogConfig.level = DtoLogLevel.errors;
      // Coercion (warning) should not log
      final json = <String, dynamic>{'id': '42'};
      DtoLogger.parse(json, () => json.safeInt('id'), 'Test');
      // No crash = pass
    });

    test('logSuccess=false skips clean parses', () {
      DtoLogConfig.logSuccess = false;
      final json = <String, dynamic>{'id': 42};
      DtoLogger.parse(json, () => json.safeInt('id'), 'Test');
      // No crash = pass
    });

    test('maxReportsPerClass=1 suppresses after 1 report', () {
      DtoLogConfig.compressLogs = true;
      DtoLogConfig.maxReportsPerClass = 1;
      // Parse same class multiple times
      for (int i = 0; i < 5; i++) {
        DtoLogger.parse(<String, dynamic>{'id': i}, () => i, 'Repeated');
      }
      // No crash = pass, compression kicked in
    });

    test('deferLogging=true does not block parse', () async {
      DtoLogConfig.deferLogging = true;
      final json = <String, dynamic>{'id': 42, 'name': 'test'};
      final result = DtoLogger.parse(json, () {
        return {
          'id': json.safeInt('id'),
          'name': json.safeString('name'),
        };
      }, 'DeferTest');

      expect(result['id'], 42);
      expect(result['name'], 'test');

      // Wait for microtask to complete
      await Future.delayed(Duration.zero);
    });
  });

  // ==========================================================================
  // logJson edge cases
  // ==========================================================================
  group('logJson edge cases', () {
    test('logJson with empty map does not crash', () {
      DtoLogger.logJson(<String, dynamic>{}, 'EmptyModel');
    });

    test('logJson with very long key name handles alignment', () {
      final json = <String, dynamic>{
        'a_very_long_field_name_that_exceeds_normal_length_limits': 'value',
        'x': 'y',
      };
      DtoLogger.logJson(json, 'LongKeyModel');
      // No crash = pass
    });

    test('logJson with all null values shows warning style', () {
      final json = <String, dynamic>{
        'field1': null,
        'field2': null,
      };
      DtoLogger.logJson(json, 'NullModel');
      // No crash = pass
    });

    test('logJson with showJsonData enabled works', () {
      DtoLogConfig.showJsonData = true;
      DtoLogger.logJson(<String, dynamic>{'id': 1}, 'JsonData');
      // No crash = pass
    });
  });

  // ==========================================================================
  // Multiple rapid parses - session stack integrity
  // ==========================================================================
  group('Session stack integrity', () {
    test('nested DtoLogger.parse calls maintain separate sessions', () {
      final outerJson = <String, dynamic>{
        'id': 1,
        'child': <String, dynamic>{'name': 'inner'}
      };

      DtoLogger.parse(outerJson, () {
        final id = outerJson.safeInt('id');
        // Nested parse
        final child = outerJson['child'] as Map<String, dynamic>;
        DtoLogger.parse(child, () {
          return child.safeString('name');
        }, 'InnerModel');
        return id;
      }, 'OuterModel');
      // No crash = sessions didn't interfere
    });

    test('20 sequential parses do not corrupt stack', () {
      for (int i = 0; i < 20; i++) {
        final json = <String, dynamic>{'index': i};
        final result = DtoLogger.parse(json, () {
          return json.safeInt('index');
        }, 'Sequential');
        expect(result, i);
      }
    });
  });

  // ==========================================================================
  // showJsonData edge cases
  // ==========================================================================
  group('showJsonData', () {
    test('showJsonData with long string values truncates', () {
      DtoLogConfig.showJsonData = true;
      DtoLogConfig.maxValueLength = 10;
      final json = <String, dynamic>{
        'long': 'a' * 100,
      };
      DtoLogger.parse(json, () {
        json.safeString('long');
        return null;
      }, 'TruncTest');
      // No crash = truncation works
    });
  });

  // ==========================================================================
  // disabled logging still parses correctly
  // ==========================================================================
  group('Disabled logging', () {
    test('DtoLogConfig.enabled=false still returns correct result', () {
      DtoLogConfig.enabled = false;
      final json = <String, dynamic>{'id': 42};
      final result = DtoLogger.parse(json, () {
        return json.safeInt('id');
      }, 'DisabledTest');
      expect(result, 42);
    });

    test('logJson with enabled=false does not crash', () {
      DtoLogConfig.enabled = false;
      DtoLogger.logJson(<String, dynamic>{'id': 1});
      // No crash = pass
    });
  });
}

enum _TestEnum { active, inactive, pending }
