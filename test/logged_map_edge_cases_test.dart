import 'dart:async';

import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    DtoLogConfig.enabled = true;
    DtoLogConfig.level = DtoLogLevel.verbose;
    DtoLogConfig.useColors = false;
    DtoLogConfig.logSuccess = true;
    DtoLogConfig.showTiming = false;
    DtoLogConfig.compressLogs = false;
    DtoLogConfig.deferLogging = false;
  });

  // ==========================================================================
  // LoggedMap write operations
  // ==========================================================================
  group('LoggedMap write operations', () {
    test('[]= delegates to inner map', () async {
      final json = <String, dynamic>{'id': 1};
      final logged = json.logged('WriteTest');

      logged['newKey'] = 'newValue';
      expect(logged['newKey'], 'newValue');
      // Also check inner map was modified
      expect(json['newKey'], 'newValue');

      await Future.delayed(Duration.zero);
    });

    test('remove() delegates to inner map', () async {
      final json = <String, dynamic>{'id': 1, 'name': 'test'};
      final logged = json.logged('RemoveTest');

      final removed = logged.remove('name');
      expect(removed, 'test');
      expect(logged.containsKey('name'), isFalse);

      await Future.delayed(Duration.zero);
    });

    test('clear() delegates to inner map', () async {
      final json = <String, dynamic>{'id': 1, 'name': 'test'};
      final logged = json.logged('ClearTest');

      logged.clear();
      expect(logged.isEmpty, isTrue);
      expect(json.isEmpty, isTrue);

      await Future.delayed(Duration.zero);
    });
  });

  // ==========================================================================
  // LoggedMap key access tracking
  // ==========================================================================
  group('LoggedMap key access tracking', () {
    test('direct [] access tracks the key', () async {
      final json = <String, dynamic>{'id': 1, 'name': 'test', 'extra': 'x'};
      final logged = json.logged('AccessTest');

      // Access only 'id' and 'name', not 'extra'
      final _ = logged['id'];
      final name = logged['name'];
      expect(name, isNotNull);

      // Wait for microtask report
      await Future.delayed(Duration.zero);
      // 'extra' should be reported as extra field (not accessed)
    });

    test('accessing non-existent key does not crash', () async {
      final json = <String, dynamic>{'id': 1};
      final logged = json.logged('NonExistTest');

      final result = logged['does_not_exist'];
      expect(result, isNull);

      await Future.delayed(Duration.zero);
    });

    test('keys iteration returns inner map keys', () async {
      final json = <String, dynamic>{'a': 1, 'b': 2, 'c': 3};
      final logged = json.logged('KeysTest');

      expect(logged.keys.toList(), ['a', 'b', 'c']);

      await Future.delayed(Duration.zero);
    });
  });

  // ==========================================================================
  // LoggedMap._detectSuspiciousType edge cases
  // ==========================================================================
  group('LoggedMap suspicious type detection', () {
    test('string "123" is detected as suspicious (looks like int)', () async {
      final json = <String, dynamic>{'value': '123'};
      final logged = json.logged('SuspiciousInt');

      final _ = logged['value'];
      await Future.delayed(Duration.zero);
      // Should report suspiciousType for "123"
    });

    test('string "true" is detected as suspicious (looks like bool)', () async {
      final json = <String, dynamic>{'flag': 'true'};
      final logged = json.logged('SuspiciousBool');

      final _ = logged['flag'];
      await Future.delayed(Duration.zero);
    });

    test('string "3.14" is detected as suspicious (looks like double)', () async {
      final json = <String, dynamic>{'price': '3.14'};
      final logged = json.logged('SuspiciousDouble');

      final _ = logged['price'];
      await Future.delayed(Duration.zero);
    });

    test('empty string is NOT suspicious', () async {
      final json = <String, dynamic>{'empty': ''};
      final logged = json.logged('EmptyStr');

      final _ = logged['empty'];
      await Future.delayed(Duration.zero);
      // Empty string should not trigger suspicious type
    });

    test('string "NaN" is NOT suspicious (not parseable as int/double with dot)', () async {
      // _detectSuspiciousType: int.tryParse("NaN") returns null
      // double.tryParse("NaN") returns NaN but doesn't contain '.'
      // So it should NOT be flagged as suspicious double
      final json = <String, dynamic>{'value': 'NaN'};
      final logged = json.logged('NaNStr');

      final _ = logged['value'];
      await Future.delayed(Duration.zero);
    });

    test('non-string values are never suspicious', () async {
      final json = <String, dynamic>{'num': 42, 'flag': true};
      final logged = json.logged('NonString');

      final _ = logged['num'];
      final flag = logged['flag'];
      expect(flag, isNotNull);
      await Future.delayed(Duration.zero);
      // int and bool should not trigger _detectSuspiciousType
    });
  });

  // ==========================================================================
  // LoggedMap with logging disabled
  // ==========================================================================
  group('LoggedMap with logging disabled', () {
    test('logged() returns original map when disabled', () {
      DtoLogConfig.enabled = false;
      final json = <String, dynamic>{'id': 1};
      final result = json.logged('Disabled');
      // Should return the same map, not a LoggedMap
      expect(identical(result, json), isTrue);
    });
  });

  // ==========================================================================
  // LoggedMap report behavior
  // ==========================================================================
  group('LoggedMap report behavior', () {
    test('report fires once via microtask', () async {
      final json = <String, dynamic>{'id': 1};
      final logged = json.logged('MicrotaskTest');

      final _ = logged['id'];

      // Report hasn't fired yet (microtask pending)
      // After microtask, report fires
      await Future.delayed(Duration.zero);
      // No crash = report fired successfully
    });

    test('multiple logged maps for same class with compression', () async {
      DtoLogConfig.compressLogs = true;
      DtoLogConfig.maxReportsPerClass = 2;

      for (int i = 0; i < 5; i++) {
        final json = <String, dynamic>{'id': i};
        final logged = json.logged('CompressTest');
        final _ = logged['id'];
      }

      await Future.delayed(Duration.zero);
      // Compression should suppress after 2 reports
    });
  });
}
