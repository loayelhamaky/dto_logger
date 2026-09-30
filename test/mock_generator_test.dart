import 'package:dto_logger/dto_logger.dart';
import 'package:test/test.dart';

void main() {
  // ==========================================================================
  // Basic type generation
  // ==========================================================================
  group('DtoMock.generate basic types', () {
    test('int field generates integer', () {
      final result = DtoMock.generate({'count': 'int'});
      expect(result['count'], isA<int>());
    });

    test('double field generates double', () {
      final result = DtoMock.generate({'price': 'double'});
      expect(result['price'], isA<double>());
    });

    test('String field generates string', () {
      final result = DtoMock.generate({'name': 'String'});
      expect(result['name'], isA<String>());
      expect((result['name'] as String).isNotEmpty, isTrue);
    });

    test('bool field generates boolean', () {
      final result = DtoMock.generate({'active': 'bool'});
      expect(result['active'], isA<bool>());
    });

    test('DateTime field generates ISO 8601 string', () {
      final result = DtoMock.generate({'created_at': 'DateTime'});
      final value = result['created_at'] as String;
      // Should be parseable as DateTime
      expect(DateTime.tryParse(value), isNotNull);
    });

    test('null type hint generates null', () {
      final result = DtoMock.generate({'unknown': null});
      expect(result['unknown'], isNull);
    });
  });

  // ==========================================================================
  // Smart field name heuristics - String
  // ==========================================================================
  group('DtoMock smart String heuristics', () {
    test('email field generates email format', () {
      final result = DtoMock.generate({'email': 'String'});
      final email = result['email'] as String;
      expect(email, contains('@'));
      expect(email, contains('.'));
    });

    test('user_email field generates email format', () {
      final result = DtoMock.generate({'user_email': 'String'});
      expect(result['user_email'] as String, contains('@'));
    });

    test('phone field generates phone format', () {
      final result = DtoMock.generate({'phone': 'String'});
      expect(result['phone'] as String, startsWith('+'));
    });

    test('url field generates URL format', () {
      final result = DtoMock.generate({'url': 'String'});
      expect(result['url'] as String, startsWith('https://'));
    });

    test('image field generates image URL', () {
      final result = DtoMock.generate({'image': 'String'});
      expect(result['image'] as String, contains('.png'));
    });

    test('avatar field generates image URL', () {
      final result = DtoMock.generate({'avatar': 'String'});
      expect(result['avatar'] as String, contains('.png'));
    });

    test('city field generates city name', () {
      final result = DtoMock.generate({'city': 'String'});
      expect(result['city'] as String, isNotEmpty);
    });

    test('country field generates country name', () {
      final result = DtoMock.generate({'country': 'String'});
      expect(result['country'] as String, isNotEmpty);
    });

    test('title field generates title', () {
      final result = DtoMock.generate({'title': 'String'});
      expect(result['title'] as String, contains('Title'));
    });

    test('description field generates description', () {
      final result = DtoMock.generate({'description': 'String'});
      expect(result['description'] as String, contains('Description'));
    });

    test('slug field generates slug format', () {
      final result = DtoMock.generate({'slug': 'String'});
      expect(result['slug'] as String, contains('-'));
    });

    test('token field generates token format', () {
      final result = DtoMock.generate({'token': 'String'});
      expect(result['token'] as String, startsWith('tok_'));
    });

    test('status field generates "active"', () {
      final result = DtoMock.generate({'status': 'String'});
      expect(result['status'], 'active');
    });

    test('name field generates full name', () {
      final result = DtoMock.generate({'name': 'String'});
      expect(result['name'] as String, contains(' '));
    });

    test('first_name field generates first name', () {
      final result = DtoMock.generate({'first_name': 'String'});
      expect((result['first_name'] as String).isNotEmpty, isTrue);
    });

    test('username field generates username format', () {
      final result = DtoMock.generate({'username': 'String'});
      expect(result['username'] as String, startsWith('user_'));
    });

    test('street field generates street address', () {
      final result = DtoMock.generate({'street': 'String'});
      expect(result['street'] as String, contains('Street'));
    });

    test('zip field generates zip code', () {
      final result = DtoMock.generate({'zip': 'String'});
      final zip = result['zip'] as String;
      expect(int.tryParse(zip), isNotNull);
    });

    test('currency field generates currency code', () {
      final result = DtoMock.generate({'currency': 'String'});
      expect((result['currency'] as String).length, 3);
    });

    test('color field generates hex color', () {
      final result = DtoMock.generate({'color': 'String'});
      expect(result['color'] as String, startsWith('#'));
    });

    test('unknown field uses field name + seed', () {
      final result = DtoMock.generate({'random_thing': 'String'});
      expect(result['random_thing'] as String, contains('random_thing'));
    });
  });

  // ==========================================================================
  // Smart field name heuristics - int
  // ==========================================================================
  group('DtoMock smart int heuristics', () {
    test('id field generates positive int', () {
      final result = DtoMock.generate({'id': 'int'});
      expect(result['id'] as int, greaterThan(0));
    });

    test('age field generates realistic age', () {
      final result = DtoMock.generate({'age': 'int'});
      final age = result['age'] as int;
      expect(age, greaterThanOrEqualTo(18));
      expect(age, lessThan(78));
    });

    test('year field generates realistic year', () {
      final result = DtoMock.generate({'year': 'int'});
      final year = result['year'] as int;
      expect(year, greaterThanOrEqualTo(2024));
    });

    test('port field generates port number', () {
      final result = DtoMock.generate({'port': 'int'});
      expect(result['port'] as int, greaterThanOrEqualTo(3000));
    });

    test('status_code field generates HTTP-like code', () {
      final result = DtoMock.generate({'status_code': 'int'});
      expect(result['status_code'] as int, greaterThanOrEqualTo(200));
    });
  });

  // ==========================================================================
  // Smart field name heuristics - double
  // ==========================================================================
  group('DtoMock smart double heuristics', () {
    test('price field generates realistic price', () {
      final result = DtoMock.generate({'price': 'double'});
      expect(result['price'] as double, greaterThan(0));
    });

    test('prices and coordinates have no floating point noise', () {
      for (var seed = 0; seed < 50; seed++) {
        for (final field in ['price', 'lat', 'lng']) {
          final text = DtoMock.value(field, 'double', seed: seed).toString();
          final decimals = text.contains('.') ? text.split('.')[1].length : 0;
          expect(decimals, lessThanOrEqualTo(field == 'price' ? 2 : 4),
              reason: '$field seed $seed gave $text');
        }
      }
      expect(DtoMock.value('price', 'double', seed: 2), 29.99);
    });

    test('lat field generates latitude-like value', () {
      final result = DtoMock.generate({'lat': 'double'});
      final lat = result['lat'] as double;
      expect(lat, greaterThan(30));
      expect(lat, lessThan(50));
    });

    test('lng field generates longitude-like value', () {
      final result = DtoMock.generate({'lng': 'double'});
      final lng = result['lng'] as double;
      expect(lng, lessThan(0)); // Negative longitude
    });
  });

  // ==========================================================================
  // Smart field name heuristics - bool
  // ==========================================================================
  group('DtoMock smart bool heuristics', () {
    test('is_active generates true', () {
      final result = DtoMock.generate({'is_active': 'bool'});
      expect(result['is_active'], isTrue);
    });

    test('verified generates true', () {
      final result = DtoMock.generate({'verified': 'bool'});
      expect(result['verified'], isTrue);
    });

    test('deleted generates false', () {
      final result = DtoMock.generate({'deleted': 'bool'});
      expect(result['deleted'], isFalse);
    });

    test('disabled generates false', () {
      final result = DtoMock.generate({'disabled': 'bool'});
      expect(result['disabled'], isFalse);
    });

    test('banned generates false', () {
      final result = DtoMock.generate({'banned': 'bool'});
      expect(result['banned'], isFalse);
    });
  });

  // ==========================================================================
  // Smart DateTime heuristics
  // ==========================================================================
  group('DtoMock smart DateTime heuristics', () {
    test('created_at generates past date', () {
      final result = DtoMock.generate({'created_at': 'DateTime'});
      final dt = DateTime.parse(result['created_at'] as String);
      expect(dt.isBefore(DateTime(2024, 2, 1)), isTrue);
    });

    test('expires_at generates future date', () {
      final result = DtoMock.generate({'expires_at': 'DateTime'});
      final dt = DateTime.parse(result['expires_at'] as String);
      expect(dt.isAfter(DateTime(2024, 6, 1)), isTrue);
    });

    test('birth_date generates past date (18+ years ago)', () {
      final result = DtoMock.generate({'birth_date': 'DateTime'});
      final dt = DateTime.parse(result['birth_date'] as String);
      expect(dt.isBefore(DateTime(2006)), isTrue);
    });
  });

  // ==========================================================================
  // Nested objects
  // ==========================================================================
  group('DtoMock nested objects', () {
    test('nested map schema generates nested map', () {
      final result = DtoMock.generate({
        'id': 'int',
        'address': {
          'street': 'String',
          'city': 'String',
          'zip': 'String',
        },
      });

      expect(result['address'], isA<Map<String, dynamic>>());
      final address = result['address'] as Map<String, dynamic>;
      expect(address['street'], isA<String>());
      expect(address['city'], isA<String>());
      expect(address['zip'], isA<String>());
    });

    test('deeply nested objects work', () {
      final result = DtoMock.generate({
        'level1': {
          'level2': {
            'level3': {
              'value': 'String',
            },
          },
        },
      });

      final l1 = result['level1'] as Map<String, dynamic>;
      final l2 = l1['level2'] as Map<String, dynamic>;
      final l3 = l2['level3'] as Map<String, dynamic>;
      expect(l3['value'], isA<String>());
    });
  });

  // ==========================================================================
  // List generation
  // ==========================================================================
  group('DtoMock list generation', () {
    test('List<String> generates list of 3 strings', () {
      final result = DtoMock.generate({'tags': 'List<String>'});
      final tags = result['tags'] as List;
      expect(tags.length, 3);
      expect(tags.every((e) => e is String), isTrue);
    });

    test('List<int> generates list of 3 ints', () {
      final result = DtoMock.generate({'ids': 'List<int>'});
      final ids = result['ids'] as List;
      expect(ids.length, 3);
      expect(ids.every((e) => e is int), isTrue);
    });

    test('List<bool> generates list of 3 bools', () {
      final result = DtoMock.generate({'flags': 'List<bool>'});
      final flags = result['flags'] as List;
      expect(flags.length, 3);
      expect(flags.every((e) => e is bool), isTrue);
    });

    test('List<double> generates list of 3 doubles', () {
      final result = DtoMock.generate({'scores': 'List<double>'});
      final scores = result['scores'] as List;
      expect(scores.length, 3);
      expect(scores.every((e) => e is double), isTrue);
    });
  });

  // ==========================================================================
  // Map type
  // ==========================================================================
  group('DtoMock Map type', () {
    test('Map<String, dynamic> generates simple map', () {
      final result = DtoMock.generate({'metadata': 'Map<String, dynamic>'});
      expect(result['metadata'], isA<Map<String, dynamic>>());
    });
  });

  // ==========================================================================
  // Seed determinism
  // ==========================================================================
  group('DtoMock seed determinism', () {
    test('same seed produces same output', () {
      final a = DtoMock.generate({'id': 'int', 'name': 'String'}, seed: 42);
      final b = DtoMock.generate({'id': 'int', 'name': 'String'}, seed: 42);
      expect(a['id'], equals(b['id']));
      expect(a['name'], equals(b['name']));
    });

    test('different seeds produce different output', () {
      final a = DtoMock.generate({'id': 'int', 'name': 'String'}, seed: 0);
      final b = DtoMock.generate({'id': 'int', 'name': 'String'}, seed: 5);
      // At least one field should differ
      expect(a['id'] != b['id'] || a['name'] != b['name'], isTrue);
    });
  });

  // ==========================================================================
  // generateList
  // ==========================================================================
  group('DtoMock.generateList', () {
    test('generates correct count', () {
      final list = DtoMock.generateList({'id': 'int'}, count: 5);
      expect(list.length, 5);
    });

    test('each item has incrementing seed', () {
      final list = DtoMock.generateList({'id': 'int'}, count: 3);
      // IDs should be different (seed increments)
      final ids = list.map((m) => m['id']).toSet();
      expect(ids.length, 3); // All unique
    });

    test('startSeed offsets all seeds', () {
      final listA = DtoMock.generateList({'id': 'int'}, count: 2, startSeed: 0);
      final listB = DtoMock.generateList({'id': 'int'}, count: 2, startSeed: 10);
      expect(listA[0]['id'] != listB[0]['id'], isTrue);
    });

    test('count=0 returns empty list', () {
      final list = DtoMock.generateList({'id': 'int'}, count: 0);
      expect(list, isEmpty);
    });

    test('count=1 returns single item', () {
      final list = DtoMock.generateList({'id': 'int'}, count: 1);
      expect(list.length, 1);
    });
  });

  // ==========================================================================
  // DtoMock.value standalone
  // ==========================================================================
  group('DtoMock.value', () {
    test('generates int value', () {
      expect(DtoMock.value('id', 'int'), isA<int>());
    });

    test('generates String value', () {
      expect(DtoMock.value('name', 'String'), isA<String>());
    });

    test('generates double value', () {
      expect(DtoMock.value('price', 'double'), isA<double>());
    });

    test('generates bool value', () {
      expect(DtoMock.value('active', 'bool'), isA<bool>());
    });

    test('respects seed parameter', () {
      final a = DtoMock.value('id', 'int', seed: 0);
      final b = DtoMock.value('id', 'int', seed: 0);
      expect(a, equals(b));
    });
  });

  // ==========================================================================
  // Edge cases
  // ==========================================================================
  group('DtoMock edge cases', () {
    test('empty schema generates empty map', () {
      final result = DtoMock.generate({});
      expect(result, isEmpty);
    });

    test('unsupported type hint generates fallback string', () {
      final result = DtoMock.generate({'weird': 'SomeCustomType'});
      expect(result['weird'], isA<String>());
    });

    test('nullable type hint (int?) treated same as int', () {
      final result = DtoMock.generate({'count': 'int?'});
      expect(result['count'], isA<int>());
    });

    test('non-string type hint (int literal) generates fallback', () {
      final result = DtoMock.generate({'bad': 42});
      // Non-String, non-Map, non-null → 'unsupported_type'
      expect(result['bad'], 'unsupported_type');
    });

    test('very large seed does not crash', () {
      final result = DtoMock.generate({'id': 'int'}, seed: 999999);
      expect(result['id'], isA<int>());
    });

    test('negative seed does not crash', () {
      final result = DtoMock.generate({'id': 'int'}, seed: -5);
      expect(result['id'], isA<int>());
    });

    test('multiple fields all get generated', () {
      final result = DtoMock.generate({
        'id': 'int',
        'name': 'String',
        'email': 'String',
        'age': 'int',
        'active': 'bool',
        'score': 'double',
        'created_at': 'DateTime',
      });

      expect(result.length, 7);
      expect(result['id'], isA<int>());
      expect(result['name'], isA<String>());
      expect(result['email'] as String, contains('@'));
      expect(result['age'], isA<int>());
      expect(result['active'], isA<bool>());
      expect(result['score'], isA<double>());
      expect(DateTime.tryParse(result['created_at'] as String), isNotNull);
    });
  });
}
