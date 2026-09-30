/// Mock JSON data generator for DTO testing
///
/// Generates realistic fake JSON data based on field names and types.
/// Uses field name heuristics to produce contextually appropriate values.
///
/// Usage:
/// ```dart
/// final json = DtoMock.generate({
///   'id': 'int',
///   'user_name': 'String',
///   'email': 'String',
///   'is_active': 'bool',
///   'created_at': 'DateTime',
///   'tags': 'List<String>',
///   'address': {
///     'street': 'String',
///     'city': 'String',
///   },
/// });
/// ```
class DtoMock {
  DtoMock._();

  /// Generate a mock JSON map from a schema definition.
  ///
  /// The [schema] maps field names to type hints:
  /// - `'int'` → integer value
  /// - `'double'` → double value
  /// - `'String'` → string value (smart based on field name)
  /// - `'bool'` → boolean value
  /// - `'DateTime'` → ISO 8601 string
  /// - `'List<X>'` → list of X
  /// - `Map<String, dynamic>` (nested) → recursive mock
  /// - `null` → null value
  ///
  /// [seed] controls deterministic output (same seed = same data).
  static Map<String, dynamic> generate(
    Map<String, dynamic> schema, {
    int seed = 0,
  }) {
    final result = <String, dynamic>{};
    int fieldIndex = 0;

    for (final entry in schema.entries) {
      final key = entry.key;
      final typeHint = entry.value;
      result[key] = _generateValue(key, typeHint, seed + fieldIndex);
      fieldIndex++;
    }

    return result;
  }

  /// Generate a list of mock JSON maps from a schema.
  ///
  /// ```dart
  /// final users = DtoMock.generateList({
  ///   'id': 'int',
  ///   'name': 'String',
  /// }, count: 5);
  /// // Returns 5 user maps with seed 0..4
  /// ```
  static List<Map<String, dynamic>> generateList(
    Map<String, dynamic> schema, {
    int count = 3,
    int startSeed = 0,
  }) {
    return List.generate(
      count,
      (i) => generate(schema, seed: startSeed + i),
    );
  }

  /// Generate a single mock value for a given field name and type.
  ///
  /// ```dart
  /// DtoMock.value('email', 'String');      // → 'user0@test.com'
  /// DtoMock.value('age', 'int');            // → 25
  /// DtoMock.value('price', 'double');       // → 9.99
  /// DtoMock.value('is_active', 'bool');     // → true
  /// DtoMock.value('created_at', 'DateTime');// → '2024-01-01T00:00:00.000Z'
  /// ```
  static dynamic value(String fieldName, String type, {int seed = 0}) {
    return _generateValue(fieldName, type, seed);
  }

  static dynamic _generateValue(String key, dynamic typeHint, int seed) {
    if (typeHint == null) return null;

    // Nested object (Map schema)
    if (typeHint is Map<String, dynamic>) {
      return generate(typeHint, seed: seed);
    }

    // List schema: [{'id': 'int'}] → 3 objects, ['String'] → 3 strings
    if (typeHint is List) {
      if (typeHint.isEmpty) return <dynamic>[];
      return List.generate(
          3, (i) => _generateValue(key, typeHint.first, seed + i));
    }

    if (typeHint is! String) {
      return 'unsupported_type';
    }

    final type = typeHint.replaceAll('?', '').trim();
    final lower = key.toLowerCase();
    final words = _FieldWords(key);

    switch (type) {
      case 'int':
        return _smartInt(words, seed);
      case 'double':
        return _smartDouble(words, seed);
      case 'bool':
        return _smartBool(words, seed);
      case 'String':
        return _smartString(words, lower, seed);
      case 'DateTime':
        return _smartDateTime(words, seed);
      default:
        if (type.startsWith('List<')) {
          return _smartList(key, type, seed);
        }
        if (type.startsWith('Map<')) {
          return <String, dynamic>{'key_$seed': 'value_$seed'};
        }
        return 'mock_$seed';
    }
  }

  // Smart value generators - match whole words of the field name, so
  // "width" is not an "id", "video" is not an "id", and
  // "shipping_address" is not an IP address.

  static int _smartInt(_FieldWords f, int seed) {
    if (f.has('id')) return seed + 1;
    if (f.has('age')) return 18 + (seed % 60);
    if (f.has('count') || f.has('quantity')) return seed + 1;
    if (f.has('year')) return 2024 + (seed % 5);
    if (f.has('month')) return (seed % 12) + 1;
    if (f.has('day')) return (seed % 28) + 1;
    if (f.has('hour')) return seed % 24;
    if (f.has('minute') || f.has('second')) return seed % 60;
    if (f.has('port')) return 3000 + seed;
    if (f.has('page')) return seed + 1;
    if (f.has('size') || f.has('limit')) return 10 + seed;
    if (f.has('status') || f.has('code')) return 200 + seed;
    if (f.has('version')) return seed + 1;
    if (f.has('index') || f.has('position')) return seed;
    if (f.has('width') || f.has('height')) return 100 + seed * 10;
    if (f.has('duration')) return 1000 + seed * 500;
    if (f.has('score') || f.has('rating')) return (seed % 5) + 1;
    if (f.has('order') || f.has('priority')) return seed + 1;
    return seed;
  }

  static double _smartDouble(_FieldWords f, int seed) {
    // Integer math, then one division: 9.99 + 2 * 10 is 29.990000000000002
    if (f.has('price') || f.has('cost') || f.has('amount')) {
      return (999 + seed * 1000) / 100;
    }
    if (f.has('lat') || f.has('latitude')) return (377749 + seed * 100) / 10000;
    if (f.has('lng') || f.has('lon') || f.has('longitude')) {
      return (-1224194 + seed * 100) / 10000;
    }
    if (f.has('percent') || f.has('percentage') || f.has('ratio')) {
      return (seed % 100) / 100.0;
    }
    if (f.has('rate') || f.has('score') || f.has('rating')) {
      return (seed % 50) / 10.0;
    }
    if (f.has('weight')) return 65.0 + seed;
    if (f.has('height')) return 170.0 + seed;
    if (f.startsWith('temp')) return 20.0 + seed;
    if (f.has('distance')) return 1.5 + seed * 0.5;
    return seed.toDouble();
  }

  static bool _smartBool(_FieldWords f, int seed) {
    if (f.has('active') ||
        f.has('enabled') ||
        f.has('verified') ||
        f.has('valid') ||
        f.has('visible') ||
        f.has('available') ||
        f.has('completed') ||
        f.has('success')) {
      return true;
    }
    if (f.has('deleted') ||
        f.has('disabled') ||
        f.has('inactive') ||
        f.has('blocked') ||
        f.has('banned') ||
        f.has('expired') ||
        f.has('archived')) {
      return false;
    }
    return seed % 2 == 0;
  }

  static String _smartString(_FieldWords f, String lower, int seed) {
    // Email
    if (f.has('email') || f.has('mail')) return 'user$seed@test.com';

    // Name patterns
    if (f.isExactly('name') || f.has('full_name') || f.has('fullname')) {
      return _names[seed % _names.length];
    }
    if (f.has('first_name') || f.has('firstname')) {
      return _firstNames[seed % _firstNames.length];
    }
    if (f.has('last_name') || f.has('lastname') || f.has('surname')) {
      return _lastNames[seed % _lastNames.length];
    }
    if (f.has('user_name') || f.has('username')) {
      return 'user_$seed';
    }
    if (f.has('display_name') || f.has('nickname')) {
      return 'User $seed';
    }

    // Contact
    if (f.has('phone') || f.has('mobile') || f.has('tel')) {
      return '+1555${seed.toString().padLeft(7, '0')}';
    }

    // URL patterns
    if (f.has('image') ||
        f.has('avatar') ||
        f.has('photo') ||
        f.has('picture') ||
        f.has('thumbnail')) {
      return 'https://example.com/images/$seed.png';
    }
    if (f.has('video')) return 'https://example.com/videos/$seed.mp4';
    if (f.has('website')) return 'https://example$seed.com';
    if (f.has('icon')) return 'https://example.com/icons/$seed.svg';
    if (f.has('url') || f.has('link') || f.has('href')) {
      return 'https://example.com/$seed';
    }

    // Address (IP addresses first: "ip_address" is not a street)
    if (f.has('ip')) return '192.168.1.${seed % 256}';
    if (f.has('street') ||
        f.has('address_line') ||
        f.has('address1') ||
        f.has('address')) {
      return '${100 + seed} Main Street';
    }
    if (f.has('city')) return _cities[seed % _cities.length];
    if (f.has('state') || f.has('province')) {
      return _states[seed % _states.length];
    }
    if (f.has('country')) return _countries[seed % _countries.length];
    if (f.has('zip') || f.has('zipcode') || f.has('postal')) {
      return (10000 + seed).toString();
    }

    // Content
    if (f.has('title')) return 'Title $seed';
    if (f.startsWith('desc')) return 'Description for item $seed';
    if (f.has('body') ||
        f.has('content') ||
        f.has('text') ||
        f.has('message')) {
      return 'Lorem ipsum content $seed';
    }
    if (f.has('comment') || f.has('note')) {
      return 'Note $seed';
    }
    if (f.has('label') || f.has('tag')) return 'tag_$seed';
    if (f.has('category') || f.has('type') || f.has('kind')) {
      return 'category_$seed';
    }

    // Identifiers
    if (f.has('uuid') || f.has('guid')) {
      return '${_hex(seed)}${_hex(seed + 1)}-${_hex(seed + 2)}-4${_hex(seed + 3).substring(1)}-${_hex(seed + 4)}-${_hex(seed + 5)}${_hex(seed + 6)}${_hex(seed + 7)}';
    }
    if (f.has('token') || f.has('key') || f.has('secret')) {
      return 'tok_${_hex(seed)}${_hex(seed + 1)}${_hex(seed + 2)}${_hex(seed + 3)}';
    }
    if (f.has('code')) return 'CODE_$seed';
    if (f.has('slug')) return 'item-$seed';
    if (f.has('hash')) return _hex(seed) * 4;

    // Technical
    if (f.has('color') || f.has('colour')) {
      return '#${_hex(seed).substring(0, 2)}${_hex(seed + 1).substring(0, 2)}${_hex(seed + 2).substring(0, 2)}';
    }
    if (f.has('currency')) return _currencies[seed % _currencies.length];
    if (f.has('locale') || f.has('language') || f.has('lang')) {
      return _locales[seed % _locales.length];
    }
    if (f.has('timezone') || f.has('tz')) return 'UTC';
    if (f.has('mime') || f.has('content_type')) return 'application/json';
    if (f.has('extension') || f.has('ext')) return 'json';
    if (f.has('path') || f.has('file')) return '/path/to/file_$seed';
    if (f.has('format')) return 'json';

    // Status
    if (f.has('status')) return 'active';
    if (f.has('role')) return 'user';
    if (f.has('gender')) return seed % 2 == 0 ? 'male' : 'female';

    return '${lower}_$seed';
  }

  static String _smartDateTime(_FieldWords f, int seed) {
    // UTC so the output is identical on every machine, whatever its timezone
    final base = DateTime.utc(2024, 1, 1);

    if (f.startsWith('birth') || f.has('dob')) {
      // Birth dates: 25-74 years before 2024
      return DateTime.utc(2024 - 25 - (seed % 50), 6, 15).toIso8601String();
    }
    if (f.startsWith('expir') || f.startsWith('expire')) {
      // Expiry: in the future
      return base.add(Duration(days: 365 + seed * 30)).toIso8601String();
    }
    if (f.has('created') || f.has('registered') || f.has('joined')) {
      // Created: in the past
      return base.subtract(Duration(days: seed * 30)).toIso8601String();
    }
    if (f.has('updated') || f.has('modified') || f.has('edited')) {
      // Updated: recently
      return base.subtract(Duration(days: seed)).toIso8601String();
    }
    if (f.has('deleted')) {
      return base.subtract(Duration(days: seed * 7)).toIso8601String();
    }
    if (f.has('start') || f.has('begin') || f.has('starts')) {
      return base.add(Duration(days: seed)).toIso8601String();
    }
    if (f.has('end') || f.has('ends') || f.has('finish') || f.has('deadline')) {
      return base.add(Duration(days: seed + 30)).toIso8601String();
    }

    return base.add(Duration(days: seed)).toIso8601String();
  }

  static List<dynamic> _smartList(String field, String type, int seed) {
    // Extract inner type: List<String> → String
    final innerMatch = RegExp(r'List<(.+)>').firstMatch(type);
    final innerType = innerMatch?.group(1) ?? 'String';
    const count = 3; // Default list size

    return List.generate(
        count, (i) => _generateValue(field, innerType, seed + i));
  }

  // Data pools

  static String _hex(int seed) {
    return ((seed.abs() * 2654435761) & 0xFFFFFFFF)
        .toRadixString(16)
        .padLeft(4, '0')
        .substring(0, 4);
  }

  static const _firstNames = [
    'Alice',
    'Bob',
    'Charlie',
    'Diana',
    'Eve',
    'Frank',
    'Grace',
    'Henry',
    'Ivy',
    'Jack',
  ];

  static const _lastNames = [
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Wilson',
    'Taylor',
  ];

  static const _names = [
    'Alice Smith',
    'Bob Johnson',
    'Charlie Williams',
    'Diana Brown',
    'Eve Jones',
    'Frank Garcia',
    'Grace Miller',
    'Henry Davis',
    'Ivy Wilson',
    'Jack Taylor',
  ];

  static const _cities = [
    'New York',
    'London',
    'Tokyo',
    'Paris',
    'Berlin',
    'Sydney',
    'Toronto',
    'Dubai',
    'Singapore',
    'Amsterdam',
  ];

  static const _states = [
    'California',
    'Texas',
    'New York',
    'Florida',
    'Illinois',
    'Pennsylvania',
    'Ohio',
    'Georgia',
    'Michigan',
    'Virginia',
  ];

  static const _countries = [
    'United States',
    'United Kingdom',
    'Japan',
    'France',
    'Germany',
    'Australia',
    'Canada',
    'UAE',
    'Singapore',
    'Netherlands',
  ];

  static const _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];

  static const _locales = [
    'en',
    'fr',
    'de',
    'ja',
    'es',
    'ar',
    'zh',
    'ko',
    'pt',
    'it'
  ];
}

/// The words of a field name: "userEmail", "user_email" and "User-Email"
/// all give [user, email]. Rules match whole words (or a word plus "s"),
/// so short tokens like "id" or "ip" don't match inside other words.
class _FieldWords {
  final List<String> words;
  final String joined;

  factory _FieldWords(String key) {
    final spaced = key
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
        .replaceAllMapped(
            RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]}_${m[2]}');
    final words = spaced
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return _FieldWords._(words, words.join('_'));
  }

  _FieldWords._(this.words, this.joined);

  /// Whole word ("id"), its plural ("ids"), or a multi-word token
  /// ("first_name") appearing as consecutive words.
  bool has(String token) {
    if (token.contains('_')) return '_${joined}_'.contains('_${token}_');
    return words.any((w) => w == token || w == '${token}s');
  }

  /// A word starting with [stem]: "desc" matches "description".
  bool startsWith(String stem) => words.any((w) => w.startsWith(stem));

  bool isExactly(String word) => words.length == 1 && words.first == word;
}
