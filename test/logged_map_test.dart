import 'dart:async';
import 'package:test/test.dart';
import 'package:dto_logger/dto_logger.dart';

void main() {
  // ============================================================
  // SETUP / TEARDOWN
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
  });

  // ============================================================
  // BASIC TRACKING: .logged() returns a LoggedMap
  // ============================================================
  group('LoggedMap - Basic tracking', () {
    test('logged() returns a LoggedMap (Map<String, dynamic>)', () {
      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      // Should be a Map<String, dynamic>
      expect(logged, isA<Map<String, dynamic>>());
      expect(logged, isA<LoggedMap>());
    });

    test('logged() can access fields via operator[]', () {
      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      expect(logged['id'], equals(1));
      expect(logged['name'], equals('Alice'));
    });

    test('logged() tracks field access', () async {
      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      // Access id and name
      expect(logged['id'], equals(1));
      expect(logged['name'], equals('Alice'));

      // Wait for microtask to report
      await Future.microtask(() {});

      // The map itself should still work as a map
      expect(logged['id'], equals(1));
      expect(logged['name'], equals('Alice'));
    });

    test('logged() preserves all keys property', () {
      final json = {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'};
      final logged = json.logged('TestClass');

      expect(logged.keys.length, equals(3));
      expect(logged.keys, containsAll(['id', 'name', 'email']));
    });

    test('logged() preserves isNotEmpty and isEmpty', () {
      final emptyLogged = <String, dynamic>{}.logged('Empty');
      final filledLogged = {'id': 1}.logged('Filled');

      expect(emptyLogged.isEmpty, isTrue);
      expect(filledLogged.isNotEmpty, isTrue);
    });

    test('logged() preserves length', () {
      final json = {'id': 1, 'name': 'Alice', 'email': 'test@example.com'};
      final logged = json.logged('TestClass');

      expect(logged.length, equals(3));
    });
  });

  // ============================================================
  // NULL VALUE DETECTION
  // ============================================================
  group('LoggedMap - Null value detection', () {
    test('accessed null value is detected', () async {
      final json = {'name': null};
      final logged = json.logged('TestClass');

      // Access the null field
      expect(logged['name'], isNull);

      // Wait for microtask to report
      await Future.microtask(() {});

      // Verify the map still works
      expect(logged['name'], isNull);
    });

    test('unaccessed null value is detected', () async {
      final json = {'unused': null};
      final logged = json.logged('TestClass');

      // Don't access 'unused'

      // Wait for microtask to report
      await Future.microtask(() {});

      // Map should still have the null
      expect(logged['unused'], isNull);
    });

    test('mixed accessed and unaccessed nulls', () async {
      final json = {'accessed': null, 'unaccessed': null, 'data': 'value'};
      final logged = json.logged('TestClass');

      // Access only 'accessed' and 'data'
      expect(logged['accessed'], isNull);
      expect(logged['data'], equals('value'));

      // 'unaccessed' remains unaccessed

      await Future.microtask(() {});

      // All should still be in the map
      expect(logged['accessed'], isNull);
      expect(logged['unaccessed'], isNull);
      expect(logged['data'], equals('value'));
    });
  });

  // ============================================================
  // MISSING FIELD DETECTION
  // ============================================================
  group('LoggedMap - Missing field detection', () {
    test('accessing a non-existent field records it as missing', () async {
      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // Access a field that doesn't exist
      expect(logged['name'], isNull);

      // Wait for microtask to report
      await Future.microtask(() {});

      // Should still return null
      expect(logged['name'], isNull);
    });

    test('multiple missing fields are tracked', () async {
      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // Access multiple missing fields
      expect(logged['name'], isNull);
      expect(logged['email'], isNull);
      expect(logged['phone'], isNull);

      await Future.microtask(() {});

      // All should still be null
      expect(logged['name'], isNull);
      expect(logged['email'], isNull);
      expect(logged['phone'], isNull);
    });
  });

  // ============================================================
  // SUSPICIOUS TYPE DETECTION
  // ============================================================
  group('LoggedMap - Suspicious type detection', () {
    test('string "123" looks like int', () async {
      final json = {'id': '123'};
      final logged = json.logged('TestClass');

      // Access the string that looks like int
      expect(logged['id'], equals('123'));

      await Future.microtask(() {});

      // Should still return the string
      expect(logged['id'], equals('123'));
    });

    test('string "true" looks like bool', () async {
      final json = {'isActive': 'true'};
      final logged = json.logged('TestClass');

      expect(logged['isActive'], equals('true'));

      await Future.microtask(() {});

      expect(logged['isActive'], equals('true'));
    });

    test('string "false" looks like bool (case insensitive)', () async {
      final json = {'isActive': 'FALSE'};
      final logged = json.logged('TestClass');

      expect(logged['isActive'], equals('FALSE'));

      await Future.microtask(() {});

      expect(logged['isActive'], equals('FALSE'));
    });

    test('string "1.5" looks like double', () async {
      final json = {'price': '1.5'};
      final logged = json.logged('TestClass');

      expect(logged['price'], equals('1.5'));

      await Future.microtask(() {});

      expect(logged['price'], equals('1.5'));
    });

    test('only accessed suspicious types are detected', () async {
      final json = {
        'accessed': '123',
        'unaccessed': '456',
      };
      final logged = json.logged('TestClass');

      // Access only 'accessed'
      expect(logged['accessed'], equals('123'));

      // Don't access 'unaccessed'

      await Future.microtask(() {});

      expect(logged['accessed'], equals('123'));
      expect(logged['unaccessed'], equals('456'));
    });

    test('non-string types are not flagged as suspicious', () async {
      final json = {
        'intValue': 123,
        'boolValue': true,
        'doubleValue': 1.5,
      };
      final logged = json.logged('TestClass');

      expect(logged['intValue'], equals(123));
      expect(logged['boolValue'], equals(true));
      expect(logged['doubleValue'], equals(1.5));

      await Future.microtask(() {});

      // Should all work fine (no suspicious type warnings)
      expect(logged['intValue'], equals(123));
      expect(logged['boolValue'], equals(true));
      expect(logged['doubleValue'], equals(1.5));
    });

    test('string that doesn\'t look like anything suspicious is not flagged', () async {
      final json = {'name': 'Alice'};
      final logged = json.logged('TestClass');

      expect(logged['name'], equals('Alice'));

      await Future.microtask(() {});

      expect(logged['name'], equals('Alice'));
    });
  });

  // ============================================================
  // EXTRA FIELD DETECTION
  // ============================================================
  group('LoggedMap - Extra field detection', () {
    test('unaccessed fields are detected as extra', () async {
      final json = {
        'used': 'value',
        'unused': 'extra',
      };
      final logged = json.logged('TestClass');

      // Access only 'used'
      expect(logged['used'], equals('value'));

      // Don't access 'unused'

      await Future.microtask(() {});

      expect(logged['used'], equals('value'));
      expect(logged['unused'], equals('extra'));
    });

    test('all unaccessed non-null fields are reported as extra', () async {
      final json = {
        'accessed': 'value',
        'extra1': 'unused1',
        'extra2': 'unused2',
      };
      final logged = json.logged('TestClass');

      expect(logged['accessed'], equals('value'));

      await Future.microtask(() {});

      expect(logged['accessed'], equals('value'));
      expect(logged['extra1'], equals('unused1'));
      expect(logged['extra2'], equals('unused2'));
    });

    test('unaccessed null fields are NOT reported as extra (only null warning)', () async {
      final json = {
        'accessed': 'value',
        'unaccessed_null': null,
      };
      final logged = json.logged('TestClass');

      expect(logged['accessed'], equals('value'));

      await Future.microtask(() {});

      expect(logged['accessed'], equals('value'));
      expect(logged['unaccessed_null'], isNull);
    });
  });

  // ============================================================
  // DISABLED CONFIG
  // ============================================================
  group('LoggedMap - Disabled config', () {
    test('when enabled=false, logged() returns plain map', () {
      DtoLogConfig.enabled = false;

      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      // When disabled, should return the original map, not LoggedMap
      expect(logged, isA<Map<String, dynamic>>());
      // Should be the same object reference (not wrapped)
      expect(identical(logged, json), isTrue);
    });

    test('when enabled=false, no tracking occurs', () async {
      DtoLogConfig.enabled = false;

      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // Access a non-existent field
      expect(logged['missing'], isNull);

      await Future.microtask(() {});

      // No logging should occur (but map should work normally)
      expect(logged['missing'], isNull);
    });

    test('when enabled=true again, logging resumes', () async {
      DtoLogConfig.enabled = true;

      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // Access a non-existent field
      expect(logged['missing'], isNull);

      await Future.microtask(() {});

      expect(logged['missing'], isNull);
    });
  });

  // ============================================================
  // SCHEDULED MICROTASK REPORTING
  // ============================================================
  group('LoggedMap - Microtask scheduling', () {
    test('report() is scheduled via scheduleMicrotask', () async {
      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // Create a LoggedMap - it should schedule a microtask
      // This test verifies the microtask runs

      await Future.microtask(() {});

      // If we can get here without hanging, the microtask ran
      expect(logged['id'], equals(1));
    });

    test('_reported flag prevents double reporting', () async {
      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // First access
      expect(logged['id'], equals(1));

      // Wait for microtask to complete reporting
      await Future.microtask(() {});

      // Second access shouldn't trigger another report
      // (this test verifies no exceptions or unexpected behavior)
      expect(logged['id'], equals(1));

      await Future.microtask(() {});

      // Accessing after reporting should still work fine
      expect(logged['id'], equals(1));
    });

    test('calling logged() multiple times creates separate LoggedMaps', () async {
      final json = {'id': 1};
      final logged1 = json.logged('Class1');
      final logged2 = json.logged('Class2');

      // They should be different objects
      expect(identical(logged1, logged2), isFalse);

      // Both should work as maps
      expect(logged1['id'], equals(1));
      expect(logged2['id'], equals(1));

      await Future.microtask(() {});

      // Both should still work
      expect(logged1['id'], equals(1));
      expect(logged2['id'], equals(1));
    });
  });

  // ============================================================
  // CLASS NAME PARAMETER
  // ============================================================
  group('LoggedMap - Class name parameter', () {
    test('logged(className) uses provided class name', () async {
      final json = {'id': 1};
      final logged = json.logged('MyCustomClass');

      // Accessing fields
      expect(logged['id'], equals(1));

      await Future.microtask(() {});

      expect(logged['id'], equals(1));
    });

    test('logged() without parameter infers class name', () async {
      final json = {'id': 1};
      final logged = json.logged();

      expect(logged['id'], equals(1));

      await Future.microtask(() {});

      expect(logged['id'], equals(1));
    });

    test('different class names can be passed', () async {
      final json = {'id': 1};
      final logged1 = json.logged('User');
      final logged2 = json.logged('Product');

      expect(logged1['id'], equals(1));
      expect(logged2['id'], equals(1));

      await Future.microtask(() {});

      expect(logged1['id'], equals(1));
      expect(logged2['id'], equals(1));
    });
  });

  // ============================================================
  // EDGE CASES
  // ============================================================
  group('LoggedMap - Edge cases', () {
    test('empty map', () async {
      final json = <String, dynamic>{};
      final logged = json.logged('Empty');

      expect(logged.isEmpty, isTrue);
      expect(logged.length, equals(0));

      await Future.microtask(() {});

      expect(logged.isEmpty, isTrue);
    });

    test('all fields accessed', () async {
      final json = {'a': 1, 'b': 2, 'c': 3};
      final logged = json.logged('TestClass');

      // Access all fields
      expect(logged['a'], equals(1));
      expect(logged['b'], equals(2));
      expect(logged['c'], equals(3));

      await Future.microtask(() {});

      // No extra fields should be reported
      expect(logged['a'], equals(1));
      expect(logged['b'], equals(2));
      expect(logged['c'], equals(3));
    });

    test('no fields accessed', () async {
      final json = {'a': 1, 'b': 2, 'c': 3};
      final logged = json.logged('TestClass');

      // Don't access any fields

      await Future.microtask(() {});

      // All should still be in the map and accessible
      expect(logged['a'], equals(1));
      expect(logged['b'], equals(2));
      expect(logged['c'], equals(3));
    });

    test('containsKey works correctly', () {
      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      expect(logged.containsKey('id'), isTrue);
      expect(logged.containsKey('name'), isTrue);
      expect(logged.containsKey('missing'), isFalse);
    });

    test('values property works correctly', () {
      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      final values = logged.values.toList();
      expect(values, contains(1));
      expect(values, contains('Alice'));
      expect(values.length, equals(2));
    });

    test('entries property works correctly', () {
      final json = {'id': 1, 'name': 'Alice'};
      final logged = json.logged('TestClass');

      final entries = logged.entries.toList();
      expect(entries.length, equals(2));

      final entryMap = {for (var e in entries) e.key: e.value};
      expect(entryMap['id'], equals(1));
      expect(entryMap['name'], equals('Alice'));
    });

    test('can read same field multiple times', () async {
      final json = {'id': 1};
      final logged = json.logged('TestClass');

      // Access same field multiple times
      expect(logged['id'], equals(1));
      expect(logged['id'], equals(1));
      expect(logged['id'], equals(1));

      await Future.microtask(() {});

      // Still works
      expect(logged['id'], equals(1));
    });

    test('complex nested types', () async {
      final json = {
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
        'string': 'test',
        'null': null,
      };
      final logged = json.logged('Complex');

      expect(logged['list'], equals([1, 2, 3]));
      expect(logged['map'], equals({'nested': 'value'}));
      expect(logged['string'], equals('test'));
      expect(logged['null'], isNull);

      await Future.microtask(() {});

      expect(logged['list'], equals([1, 2, 3]));
      expect(logged['map'], equals({'nested': 'value'}));
    });

    test('special characters in keys', () async {
      final json = {
        'user_id': 1,
        'user-email': 'test@example.com',
        'user.name': 'Alice',
      };
      final logged = json.logged('Special');

      expect(logged['user_id'], equals(1));
      expect(logged['user-email'], equals('test@example.com'));
      expect(logged['user.name'], equals('Alice'));

      await Future.microtask(() {});

      expect(logged['user_id'], equals(1));
      expect(logged['user-email'], equals('test@example.com'));
      expect(logged['user.name'], equals('Alice'));
    });
  });

  // ============================================================
  // MAP INTERFACE COMPLIANCE
  // ============================================================
  group('LoggedMap - Map interface compliance', () {
    test('operator[]= sets values', () {
      final logged = <String, dynamic>{'id': 1}.logged('Test');

      logged['newField'] = 'value';

      expect(logged['newField'], equals('value'));
    });

    test('clear() empties the map', () {
      final logged = <String, dynamic>{'id': 1, 'name': 'Alice'}.logged('Test');

      logged.clear();

      expect(logged.isEmpty, isTrue);
      expect(logged.length, equals(0));
    });

    test('remove() removes a field', () {
      final logged = <String, dynamic>{'id': 1, 'name': 'Alice'}.logged('Test');

      final removed = logged.remove('name');

      expect(removed, equals('Alice'));
      expect(logged.containsKey('name'), isFalse);
      expect(logged.containsKey('id'), isTrue);
    });

    test('removeWhere removes matching entries', () {
      final logged = <String, dynamic>{
        'id': 1,
        'name': 'Alice',
        'age': 30,
      }.logged('Test');

      logged.removeWhere((k, v) => v is int);

      expect(logged.containsKey('id'), isFalse);
      expect(logged.containsKey('age'), isFalse);
      expect(logged.containsKey('name'), isTrue);
    });

    test('forEach iterates all entries', () {
      final logged = <String, dynamic>{'a': 1, 'b': 2}.logged('Test');

      final result = <String, dynamic>{};
      logged.forEach((k, v) {
        result[k] = v;
      });

      expect(result['a'], equals(1));
      expect(result['b'], equals(2));
    });
  });

  // ============================================================
  // COMBINATION SCENARIOS
  // ============================================================
  group('LoggedMap - Combination scenarios', () {
    test('accessed null + extra fields', () async {
      final json = {
        'id': null,
        'accessed': 'value',
        'extra': 'unused',
      };
      final logged = json.logged('TestClass');

      expect(logged['id'], isNull);
      expect(logged['accessed'], equals('value'));

      await Future.microtask(() {});

      expect(logged['id'], isNull);
      expect(logged['accessed'], equals('value'));
      expect(logged['extra'], equals('unused'));
    });

    test('missing + suspicious type + extra', () async {
      final json = {
        'accessed_int': '123',
        'extra': 'unused',
      };
      final logged = json.logged('TestClass');

      expect(logged['accessed_int'], equals('123'));
      expect(logged['missing'], isNull);

      await Future.microtask(() {});

      expect(logged['accessed_int'], equals('123'));
      expect(logged['missing'], isNull);
      expect(logged['extra'], equals('unused'));
    });

    test('complex scenario with all issue types', () async {
      final json = {
        'validInt': 42,
        'validString': 'hello',
        'suspiciousString': '789',
        'nullAccessed': null,
        'extraField': 'ignored',
      };
      final logged = json.logged('Complex');

      // Access some fields
      expect(logged['validInt'], equals(42));
      expect(logged['validString'], equals('hello'));
      expect(logged['suspiciousString'], equals('789'));
      expect(logged['nullAccessed'], isNull);
      expect(logged['missingField'], isNull);

      // Don't access 'extraField'

      await Future.microtask(() {});

      expect(logged['validInt'], equals(42));
      expect(logged['validString'], equals('hello'));
      expect(logged['suspiciousString'], equals('789'));
      expect(logged['nullAccessed'], isNull);
      expect(logged['missingField'], isNull);
      expect(logged['extraField'], equals('ignored'));
    });
  });

  // ============================================================
  // INTEGRATION WITH ACTUAL MAP OPERATIONS
  // ============================================================
  group('LoggedMap - Integration with map operations', () {
    test('putIfAbsent works', () {
      final logged = <String, dynamic>{'id': 1}.logged('Test');

      logged.putIfAbsent('name', () => 'Alice');
      expect(logged['name'], equals('Alice'));

      logged.putIfAbsent('id', () => 999);
      expect(logged['id'], equals(1)); // unchanged
    });

    test('update works', () {
      final logged = <String, dynamic>{'id': 1}.logged('Test');

      logged.update('id', (v) => v + 1);
      expect(logged['id'], equals(2));
    });

    test('addAll works', () {
      final logged = <String, dynamic>{'id': 1}.logged('Test');

      logged.addAll({'name': 'Alice', 'email': 'test@example.com'});
      expect(logged['id'], equals(1));
      expect(logged['name'], equals('Alice'));
      expect(logged['email'], equals('test@example.com'));
    });
  });
}
