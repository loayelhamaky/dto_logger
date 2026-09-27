import 'package:test/test.dart';
import 'package:dto_logger/dto_logger.dart';

// ============================================================
// REALISTIC MESSY DTOs
// ============================================================

// Enum for user status
enum UserStatus { active, inactive, suspended, pending }

// Nested Address DTO
class AddressDto {
  final String? street;
  final String? city;
  final String? zipCode;
  final String? country;

  AddressDto({this.street, this.city, this.zipCode, this.country});

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () {
      return AddressDto(
        street: json.safeString('street'),
        city: json.safeString('city'),
        zipCode: json.safeString('zip_code'),
        country: json.safeString('country'),
      );
    });
  }

  factory AddressDto.fromJsonLogged(Map<String, dynamic> json) {
    json = json.logged();
    return AddressDto(
      street: json['street'] as String?,
      city: json['city'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
    );
  }
}

// Nested Metadata DTO
class MetadataDto {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  MetadataDto({this.createdAt, this.updatedAt, this.createdBy});

  factory MetadataDto.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () {
      return MetadataDto(
        createdAt: json.safeDateTime('created_at'),
        updatedAt: json.safeDateTime('updated_at'),
        createdBy: json.safeString('created_by'),
      );
    });
  }
}

// Main UserProfileDto - the chaotic one
class UserProfileDto {
  final int? id;
  final String? name;
  final String? email;
  final int? age;
  final bool? isVerified;
  final double? score;
  final UserStatus? status;
  final AddressDto? address;
  final MetadataDto? metadata;
  final List<String>? tags;
  final String? bio;

  UserProfileDto({
    this.id,
    this.name,
    this.email,
    this.age,
    this.isVerified,
    this.score,
    this.status,
    this.address,
    this.metadata,
    this.tags,
    this.bio,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () {
      return UserProfileDto(
        id: json.safeInt('id'),
        name: json.safeString('name'),
        email: json.safeString('email'),
        age: json.safeInt('age'),
        isVerified: json.safeBool('is_verified'),
        score: json.safeDouble('score'),
        status: json.safeEnum('status', UserStatus.values),
        address: json.safeObject('address', AddressDto.fromJson),
        metadata: json.safeObject('metadata', MetadataDto.fromJson),
        tags: json.safeListOf<String>('tags'),
        bio: json.safeString('bio'),
      );
    });
  }

  factory UserProfileDto.fromJsonLogged(Map<String, dynamic> json) {
    json = json.logged();
    return UserProfileDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      age: json['age'] as int?,
      isVerified: json['is_verified'] as bool?,
      score: json['score'] as double?,
      status: json['status'] != null
          ? UserStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => UserStatus.pending,
            )
          : null,
      address: json['address'] != null
          ? AddressDto.fromJsonLogged(json['address'] as Map<String, dynamic>)
          : null,
      metadata: null, // Skip metadata in logged version for testing
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      bio: json['bio'] as String?,
    );
  }
}

// Simple DTO for list testing
class ItemDto {
  final int? id;
  final String? title;
  final double? price;

  ItemDto({this.id, this.title, this.price});

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(json, () {
      return ItemDto(
        id: json.safeInt('id'),
        title: json.safeString('title'),
        price: json.safeDouble('price'),
      );
    });
  }
}

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
    DtoLogConfig.compressLogs = true;
    DtoLogConfig.maxReportsPerClass = 10;
  });

  // ============================================================
  // TEST DATA
  // ============================================================
  final perfectJson = {
    'id': 123,
    'name': 'John Doe',
    'email': 'john@example.com',
    'age': 30,
    'is_verified': true,
    'score': 95.5,
    'status': 'active',
    'address': {
      'street': '123 Main St',
      'city': 'New York',
      'zip_code': '10001',
      'country': 'USA',
    },
    'metadata': {
      'created_at': '2024-01-15T10:30:00Z',
      'updated_at': '2024-01-20T14:45:00Z',
      'created_by': 'admin',
    },
    'tags': ['premium', 'verified', 'vip'],
    'bio': 'A perfect user profile',
  };

  final messyJson = {
    'id': '456', // Should be int, but backend sends String
    'name': 'Jane Smith',
    'email': null, // Oops, email is null
    'age': '25', // Age as String
    'is_verified': 'true', // Bool as String
    'score': '88.5', // Double as String
    'status': 'active',
    'address': {
      'street': '456 Elm St',
      'city': 789, // City as int instead of String
      'zip_code': '90210',
      // country missing
      'internal_code': 'XYZ-123', // Extra field
    },
    'metadata': null, // Null nested object
    'tags': ['user', 'regular'],
    // bio missing
    'internal_score': 42, // Extra field the model doesn't use
    '_metadata': {'version': 2}, // Extra nested field
    'debug_flags': true, // Extra field
  };

  final nightmareJson = {
    'id': 'not-a-number', // Completely wrong
    'name': 12345, // Name as int
    'email': ['not', 'a', 'string'], // Email as array
    'age': 'twenty-five', // Can't parse
    'is_verified': 'maybe', // Invalid bool
    'score': 'high', // Invalid double
    'status': 'super-active', // Invalid enum value
    'address': 'not an object', // Should be object, is string
    'metadata': [1, 2, 3], // Should be object, is array
    'tags': 'should be array', // Should be array, is string
    'bio': true, // Should be string, is bool
    'random_field_1': 'garbage',
    'random_field_2': {'nested': 'garbage'},
    'random_field_3': [1, 2, 3],
  };

  final emptyJson = <String, dynamic>{};

  final listOfMessyItems = [
    {'id': 1, 'title': 'Perfect Item', 'price': 19.99},
    {'id': '2', 'title': 'Item Two', 'price': '29.99'}, // String types
    {'id': 3, 'title': null, 'price': 39.99}, // Null title
    {'id': '4', 'title': 123, 'price': 'forty-nine'}, // Wrong types
    {
      'id': 5,
      'title': 'Extra Fields Item',
      'price': 59.99,
      'sku': 'SKU-123',
      'vendor': 'Acme'
    }, // Extra fields
    {'title': 'Missing ID', 'price': 69.99}, // Missing id
    <String, dynamic>{}, // Empty object
    {
      'id': 'not-a-number',
      'title': ['array', 'title'],
      'price': {'nested': 'object'}
    }, // Completely wrong
  ];

  // ============================================================
  // GROUP 1: PERFECT JSON TESTS
  // ============================================================
  group('Perfect JSON - Safe Parser Approach', () {
    test('parses perfectly with no issues', () {
      final user = UserProfileDto.fromJson(perfectJson);

      expect(user.id, equals(123));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.age, equals(30));
      expect(user.isVerified, equals(true));
      expect(user.score, equals(95.5));
      expect(user.status, equals(UserStatus.active));
      expect(user.address, isNotNull);
      expect(user.address!.street, equals('123 Main St'));
      expect(user.address!.city, equals('New York'));
      expect(user.address!.zipCode, equals('10001'));
      expect(user.address!.country, equals('USA'));
      expect(user.metadata, isNotNull);
      expect(user.metadata!.createdBy, equals('admin'));
      expect(user.tags, equals(['premium', 'verified', 'vip']));
      expect(user.bio, equals('A perfect user profile'));
    });

    test('nested address parses correctly', () {
      final user = UserProfileDto.fromJson(perfectJson);
      final address = user.address!;

      expect(address.street, equals('123 Main St'));
      expect(address.city, equals('New York'));
      expect(address.zipCode, equals('10001'));
      expect(address.country, equals('USA'));
    });

    test('nested metadata parses correctly', () {
      final user = UserProfileDto.fromJson(perfectJson);
      final metadata = user.metadata!;

      expect(metadata.createdAt, isNotNull);
      expect(metadata.updatedAt, isNotNull);
      expect(metadata.createdBy, equals('admin'));
    });

    test('tags list parses correctly', () {
      final user = UserProfileDto.fromJson(perfectJson);

      expect(user.tags, isNotNull);
      expect(user.tags!.length, equals(3));
      expect(user.tags, contains('premium'));
      expect(user.tags, contains('verified'));
      expect(user.tags, contains('vip'));
    });
  });

  // ============================================================
  // GROUP 2: MESSY JSON TESTS
  // ============================================================
  group('Messy JSON - Safe Parser Approach', () {
    test('handles type coercion gracefully', () {
      final user = UserProfileDto.fromJson(messyJson);

      // String -> int coercion
      expect(user.id, equals(456));

      // String -> int coercion
      expect(user.age, equals(25));

      // String -> bool coercion
      expect(user.isVerified, equals(true));

      // String -> double coercion
      expect(user.score, equals(88.5));

      // Valid fields still work
      expect(user.name, equals('Jane Smith'));
      expect(user.status, equals(UserStatus.active));
    });

    test('handles null values correctly', () {
      final user = UserProfileDto.fromJson(messyJson);

      expect(user.email, isNull); // Null in JSON
      expect(user.metadata, isNull); // Null nested object
      expect(user.bio, isNull); // Missing field
    });

    test('handles missing fields correctly', () {
      final user = UserProfileDto.fromJson(messyJson);

      expect(user.bio, isNull); // bio is missing
    });

    test('nested object with wrong types still parses usable fields', () {
      final user = UserProfileDto.fromJson(messyJson);
      final address = user.address!;

      expect(address.street, equals('456 Elm St'));
      // City is int in JSON, gets coerced to String
      expect(address.city, equals('789'));
      expect(address.zipCode, equals('90210'));
      expect(address.country, isNull); // Missing field
    });

    test('extra fields are detected but don\'t break parsing', () {
      final user = UserProfileDto.fromJson(messyJson);

      // Model should still have valid data
      expect(user.id, equals(456));
      expect(user.name, equals('Jane Smith'));
      expect(user.tags, equals(['user', 'regular']));
    });

    test('tags array parses correctly even in messy data', () {
      final user = UserProfileDto.fromJson(messyJson);

      expect(user.tags, isNotNull);
      expect(user.tags!.length, equals(2));
      expect(user.tags, contains('user'));
      expect(user.tags, contains('regular'));
    });
  });

  // ============================================================
  // GROUP 3: NIGHTMARE JSON TESTS
  // ============================================================
  group('Nightmare JSON - Safe Parser Approach', () {
    test('survives completely wrong data without crashing', () {
      expect(() => UserProfileDto.fromJson(nightmareJson), returnsNormally);
    });

    test('returns null for unparseable fields', () {
      final user = UserProfileDto.fromJson(nightmareJson);

      expect(user.id, isNull); // 'not-a-number' can't be parsed
      expect(user.age, isNull); // 'twenty-five' can't be parsed
      expect(user.isVerified, isNull); // 'maybe' is not a valid bool
      expect(user.score, isNull); // 'high' is not a valid double
      expect(user.status, isNull); // 'super-active' is not a valid enum
      expect(user.address, isNull); // String instead of object
      expect(user.metadata, isNull); // Array instead of object
      expect(user.tags, isNull); // String instead of array
    });

    test('coerces what it can even in nightmare scenario', () {
      final user = UserProfileDto.fromJson(nightmareJson);

      // Name as int gets coerced to String
      expect(user.name, equals('12345'));

      // Bio as bool gets coerced to String
      expect(user.bio, equals('true'));
    });

    test('extra fields in nightmare JSON don\'t crash the parser', () {
      final user = UserProfileDto.fromJson(nightmareJson);

      // Model should still be created, even if most fields are null
      expect(user, isNotNull);
      expect(user.name, equals('12345')); // At least one field worked
    });
  });

  // ============================================================
  // GROUP 4: EMPTY JSON TESTS
  // ============================================================
  group('Empty JSON Tests', () {
    test('handles empty JSON without crashing - safe parser', () {
      expect(() => UserProfileDto.fromJson(emptyJson), returnsNormally);
    });

    test('all fields are null for empty JSON - safe parser', () {
      final user = UserProfileDto.fromJson(emptyJson);

      expect(user.id, isNull);
      expect(user.name, isNull);
      expect(user.email, isNull);
      expect(user.age, isNull);
      expect(user.isVerified, isNull);
      expect(user.score, isNull);
      expect(user.status, isNull);
      expect(user.address, isNull);
      expect(user.metadata, isNull);
      expect(user.tags, isNull);
      expect(user.bio, isNull);
    });
  });

  // ============================================================
  // GROUP 5: LIST PARSING TESTS
  // ============================================================
  group('List of Messy Items', () {
    test('parses all items without crashing', () {
      expect(() {
        for (final json in listOfMessyItems) {
          ItemDto.fromJson(json);
        }
      }, returnsNormally);
    });

    test('first item (perfect) parses correctly', () {
      final item = ItemDto.fromJson(listOfMessyItems[0]);

      expect(item.id, equals(1));
      expect(item.title, equals('Perfect Item'));
      expect(item.price, equals(19.99));
    });

    test('second item (string types) coerces correctly', () {
      final item = ItemDto.fromJson(listOfMessyItems[1]);

      expect(item.id, equals(2)); // '2' -> 2
      expect(item.title, equals('Item Two'));
      expect(item.price, equals(29.99)); // '29.99' -> 29.99
    });

    test('third item (null title) handles null', () {
      final item = ItemDto.fromJson(listOfMessyItems[2]);

      expect(item.id, equals(3));
      expect(item.title, isNull);
      expect(item.price, equals(39.99));
    });

    test('fourth item (wrong types) handles errors', () {
      final item = ItemDto.fromJson(listOfMessyItems[3]);

      expect(item.id, equals(4)); // '4' -> 4
      expect(item.title, equals('123')); // 123 -> '123'
      expect(item.price, isNull); // 'forty-nine' can't be parsed
    });

    test('fifth item (extra fields) parses used fields', () {
      final item = ItemDto.fromJson(listOfMessyItems[4]);

      expect(item.id, equals(5));
      expect(item.title, equals('Extra Fields Item'));
      expect(item.price, equals(59.99));
      // sku and vendor are extra fields, ignored
    });

    test('sixth item (missing id) handles missing field', () {
      final item = ItemDto.fromJson(listOfMessyItems[5]);

      expect(item.id, isNull);
      expect(item.title, equals('Missing ID'));
      expect(item.price, equals(69.99));
    });

    test('seventh item (empty object) all fields null', () {
      final item = ItemDto.fromJson(listOfMessyItems[6]);

      expect(item.id, isNull);
      expect(item.title, isNull);
      expect(item.price, isNull);
    });

    test('eighth item (completely wrong) survives', () {
      final item = ItemDto.fromJson(listOfMessyItems[7]);

      expect(item.id, isNull); // 'not-a-number'
      expect(item.title, isNull); // Array can't be coerced
      expect(item.price, isNull); // Object can't be coerced
    });
  });

  // ============================================================
  // GROUP 6: EDGE CASES
  // ============================================================
  group('Edge Cases', () {
    test('handles negative numbers correctly', () {
      final json = {
        'id': -1,
        'age': -25,
        'score': -88.5,
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.id, equals(-1));
      expect(user.age, equals(-25));
      expect(user.score, equals(-88.5));
    });

    test('handles zero values correctly', () {
      final json = {
        'id': 0,
        'age': 0,
        'score': 0.0,
        'is_verified': false,
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.id, equals(0));
      expect(user.age, equals(0));
      expect(user.score, equals(0.0));
      expect(user.isVerified, equals(false));
    });

    test('handles empty strings vs null', () {
      final json = {
        'id': 1,
        'name': '',
        'email': null,
        'bio': '',
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.name, equals('')); // Empty string is valid
      expect(user.email, isNull); // Null is null
      expect(user.bio, equals('')); // Empty string is valid
    });

    test('handles empty arrays', () {
      final json = {
        'id': 1,
        'tags': [],
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.tags, isNotNull);
      expect(user.tags!.isEmpty, isTrue);
    });

    test('handles empty nested objects', () {
      final json = {
        'id': 1,
        'address': <String, dynamic>{},
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.address, isNotNull);
      expect(user.address!.street, isNull);
      expect(user.address!.city, isNull);
    });
  });

  // ============================================================
  // GROUP 7: ENUM PARSING TESTS
  // ============================================================
  group('Enum Parsing', () {
    test('parses valid enum values', () {
      final json = {'id': 1, 'status': 'active'};
      final user = UserProfileDto.fromJson(json);
      expect(user.status, equals(UserStatus.active));
    });

    test('handles invalid enum values', () {
      final json = {'id': 1, 'status': 'super-active'};
      final user = UserProfileDto.fromJson(json);
      expect(user.status, isNull);
    });

    test('handles null enum values', () {
      final json = {'id': 1, 'status': null};
      final user = UserProfileDto.fromJson(json);
      expect(user.status, isNull);
    });

    test('handles case-insensitive enum matching', () {
      final json = {'id': 1, 'status': 'ACTIVE'};
      final user = UserProfileDto.fromJson(json);
      expect(user.status, equals(UserStatus.active));
    });
  });

  // ============================================================
  // GROUP 8: DATETIME PARSING TESTS
  // ============================================================
  group('DateTime Parsing', () {
    test('parses ISO8601 datetime strings', () {
      final json = {
        'metadata': {
          'created_at': '2024-01-15T10:30:00Z',
          'updated_at': '2024-01-20T14:45:00.123Z',
        },
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.metadata, isNotNull);
      expect(user.metadata!.createdAt, isNotNull);
      expect(user.metadata!.updatedAt, isNotNull);
    });

    test('parses unix timestamps (seconds)', () {
      final json = {
        'metadata': {
          'created_at': 1705315800, // seconds
        },
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.metadata, isNotNull);
      expect(user.metadata!.createdAt, isNotNull);
    });

    test('parses unix timestamps (milliseconds)', () {
      final json = {
        'metadata': {
          'created_at': 1705315800000, // milliseconds
        },
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.metadata, isNotNull);
      expect(user.metadata!.createdAt, isNotNull);
    });

    test('handles invalid datetime strings', () {
      final json = {
        'metadata': {
          'created_at': 'not-a-date',
        },
      };

      final user = UserProfileDto.fromJson(json);
      expect(user.metadata, isNotNull);
      expect(user.metadata!.createdAt, isNull);
    });
  });

  // ============================================================
  // GROUP 9: LOGGING BEHAVIOR TESTS
  // ============================================================
  group('Logging Behavior', () {
    test('disabled config prevents logging', () {
      DtoLogConfig.enabled = false;

      final user = UserProfileDto.fromJson(messyJson);

      // Should still parse correctly
      expect(user.id, equals(456));
      expect(user.name, equals('Jane Smith'));

      DtoLogConfig.enabled = true; // Reset
    });

    test('log level filtering works', () {
      DtoLogConfig.level = DtoLogLevel.errors;

      // Messy JSON has warnings but no errors (type coercion works)
      final user = UserProfileDto.fromJson(messyJson);
      expect(user.id, equals(456));

      DtoLogConfig.level = DtoLogLevel.verbose; // Reset
    });

    test('logSuccess=false skips clean parses', () {
      DtoLogConfig.logSuccess = false;

      final user = UserProfileDto.fromJson(perfectJson);
      expect(user.id, equals(123));

      DtoLogConfig.logSuccess = true; // Reset
    });
  });
}
