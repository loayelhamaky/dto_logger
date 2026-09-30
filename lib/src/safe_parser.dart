/// Safe JSON parsing utilities with type coercion
/// Handles common API inconsistencies like String numbers, booleans as strings, etc.
library;

/// Result of a safe parse operation
class ParseResult<T> {
  final T? value;
  final bool success;
  final String? warning;
  final String? originalType;
  final dynamic originalValue;

  const ParseResult({
    required this.value,
    required this.success,
    this.warning,
    this.originalType,
    this.originalValue,
  });

  factory ParseResult.ok(T value) => ParseResult(
        value: value,
        success: true,
      );

  factory ParseResult.coerced(T value, String from, dynamic original) =>
      ParseResult(
        value: value,
        success: true,
        warning: 'was $from, parsed as $T',
        originalType: from,
        originalValue: original,
      );

  factory ParseResult.failed(String reason, dynamic original) => ParseResult(
        value: null,
        success: false,
        warning: reason,
        originalType: original?.runtimeType.toString(),
        originalValue: original,
      );

  factory ParseResult.nullValue() => const ParseResult(
        value: null,
        success: true,
        warning: 'null',
      );
}

/// Safe JSON parser with type coercion and detailed error tracking
class SafeParser {
  SafeParser._();

  /// Truncate a value for display in warning messages
  static String _preview(dynamic value, [int maxLen = 50]) {
    final s = value.toString();
    return s.length > maxLen ? '${s.substring(0, maxLen)}...' : s;
  }

  /// Parse as int with coercion
  ///
  /// Handles:
  /// - int → int
  /// - double → int (truncates)
  /// - String "123" → int
  /// - bool → int (true=1, false=0)
  /// - null → null
  static ParseResult<int> asInt(dynamic value) {
    if (value == null) return ParseResult.nullValue();

    if (value is int) {
      return ParseResult.ok(value);
    }

    if (value is double) {
      if (!value.isFinite) {
        return ParseResult.failed('$value can\'t be converted to int', value);
      }
      return ParseResult.coerced(value.toInt(), 'double', value);
    }

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return ParseResult.coerced(parsed, 'String', value);
      }
      // Try parsing as double first, then convert
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null && parsedDouble.isFinite) {
        return ParseResult.coerced(
            parsedDouble.toInt(), 'String (via double)', value);
      }
      return ParseResult.failed(
          '"${_preview(value)}" can\'t be parsed as int', value);
    }

    if (value is bool) {
      return ParseResult.coerced(value ? 1 : 0, 'bool', value);
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected int',
      value,
    );
  }

  /// Parse as double with coercion
  ///
  /// Handles:
  /// - double → double
  /// - int → double
  /// - String "123.45" → double
  /// - null → null
  static ParseResult<double> asDouble(dynamic value) {
    if (value == null) return ParseResult.nullValue();

    if (value is double) {
      return ParseResult.ok(value);
    }

    if (value is int) {
      return ParseResult.coerced(value.toDouble(), 'int', value);
    }

    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return ParseResult.coerced(parsed, 'String', value);
      }
      return ParseResult.failed(
          '"${_preview(value)}" can\'t be parsed as double', value);
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected double',
      value,
    );
  }

  /// Parse as String with coercion
  ///
  /// Handles:
  /// - String → String
  /// - int/double/bool → String (toString)
  /// - null → null
  static ParseResult<String> asString(dynamic value) {
    if (value == null) return ParseResult.nullValue();

    if (value is String) {
      return ParseResult.ok(value);
    }

    if (value is num || value is bool) {
      return ParseResult.coerced(
          value.toString(), value.runtimeType.toString(), value);
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected String',
      value,
    );
  }

  /// Parse as bool with coercion
  ///
  /// Handles:
  /// - bool → bool
  /// - String "true"/"false"/"1"/"0" → bool
  /// - int 0/1 → bool
  /// - null → null
  static ParseResult<bool> asBool(dynamic value) {
    if (value == null) return ParseResult.nullValue();

    if (value is bool) {
      return ParseResult.ok(value);
    }

    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'yes') {
        return ParseResult.coerced(true, 'String', value);
      }
      if (lower == 'false' || lower == '0' || lower == 'no') {
        return ParseResult.coerced(false, 'String', value);
      }
      return ParseResult.failed(
          '"${_preview(value)}" can\'t be parsed as bool', value);
    }

    if (value is int) {
      return ParseResult.coerced(value != 0, 'int', value);
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected bool',
      value,
    );
  }

  /// Parse as DateTime with coercion
  ///
  /// Handles:
  /// - DateTime → DateTime
  /// - String (ISO8601) → DateTime
  /// - int (Unix timestamp seconds) → DateTime
  /// - int (Unix timestamp milliseconds) → DateTime
  /// - null → null
  static ParseResult<DateTime> asDateTime(dynamic value) {
    if (value == null) return ParseResult.nullValue();

    if (value is DateTime) {
      return ParseResult.ok(value);
    }

    if (value is String) {
      final text = value.trim();
      // "1704067200" is a Unix timestamp. DateTime.tryParse would read it
      // as the year 170411. Shorter digit strings like "20240115" stay dates.
      final looksLikeTimestamp =
          text.length >= 10 && _digitsOnly.hasMatch(text);
      if (!looksLikeTimestamp) {
        final parsed = DateTime.tryParse(text);
        if (parsed != null) {
          return ParseResult.coerced(parsed, 'String (ISO8601)', value);
        }
      }
      final timestamp = int.tryParse(text);
      if (timestamp != null) {
        return _parseTimestamp(timestamp, value);
      }
      return ParseResult.failed(
          '"${_preview(value)}" can\'t be parsed as DateTime', value);
    }

    if (value is int) {
      return _parseTimestamp(value, value);
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected DateTime',
      value,
    );
  }

  static final _digitsOnly = RegExp(r'^-?\d+$');

  static ParseResult<DateTime> _parseTimestamp(
      int timestamp, dynamic original) {
    // Above 10000000000 (year ~2286 in seconds) it must be milliseconds
    final isMillis = timestamp > 10000000000;
    try {
      return ParseResult.coerced(
        DateTime.fromMillisecondsSinceEpoch(
            isMillis ? timestamp : timestamp * 1000),
        isMillis ? 'int (milliseconds)' : 'int (seconds)',
        original,
      );
    } on RangeError {
      // Beyond DateTime's supported range (±100,000,000 days)
      return ParseResult.failed(
          '$timestamp is out of DateTime range', original);
    }
  }

  /// Parse as List with coercion
  ///
  /// Handles:
  /// - List → `List<T>`
  /// - null → null
  static ParseResult<List<T>> asList<T>(
    dynamic value,
    T Function(dynamic) itemParser,
  ) {
    if (value == null) return ParseResult.nullValue();

    if (value is List) {
      try {
        final list = value.map((e) => itemParser(e)).toList();
        return ParseResult.ok(list);
      } catch (e) {
        return ParseResult.failed('couldn\'t parse list items: $e', value);
      }
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected List',
      value,
    );
  }

  /// Parse as Map with coercion
  static ParseResult<Map<String, dynamic>> asMap(dynamic value) {
    if (value == null) return ParseResult.nullValue();

    if (value is Map<String, dynamic>) {
      return ParseResult.ok(value);
    }

    if (value is Map) {
      try {
        final map = value.map((k, v) => MapEntry(k.toString(), v));
        return ParseResult.coerced(map, 'Map<dynamic, dynamic>', value);
      } catch (e) {
        return ParseResult.failed('couldn\'t convert map: $e', value);
      }
    }

    return ParseResult.failed(
      'got ${value.runtimeType}, expected Map',
      value,
    );
  }

  /// Infer Dart type from JSON value
  ///
  /// Used when generating classes from JSON
  static String inferType(dynamic value, {bool nullable = true}) {
    final suffix = nullable ? '?' : '';

    if (value == null) return 'String$suffix'; // Default assumption for null

    if (value is int) return 'int$suffix';
    if (value is double) return 'double$suffix';
    if (value is bool) return 'bool$suffix';
    if (value is String) return 'String$suffix';

    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>$suffix';

      // Infer type from first element
      final firstType = inferType(value.first, nullable: false);

      // Check if all elements are same type
      final allSameType = value.every((e) {
        final t = inferType(e, nullable: false);
        return t == firstType || t == 'dynamic';
      });

      if (allSameType) {
        return 'List<$firstType>$suffix';
      }
      return 'List<dynamic>$suffix';
    }

    if (value is Map) {
      return 'Map<String, dynamic>$suffix';
    }

    return 'dynamic$suffix';
  }
}
