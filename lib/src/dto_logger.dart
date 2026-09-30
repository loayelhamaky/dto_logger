/// Main DTO Logger - validates JSON parsing and logs with colors
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;

import 'colors.dart';
import 'safe_parser.dart';

/// Log level for DTO logging
enum DtoLogLevel {
  /// Log everything
  verbose,

  /// Log warnings and errors only
  warnings,

  /// Log errors only
  errors,

  /// No logging
  none,
}

/// Configuration for DTO logging
class DtoLogConfig {
  /// Whether logging is enabled (set to false to disable all logging)
  static bool enabled = true;

  /// Current log level
  static DtoLogLevel level = DtoLogLevel.verbose;

  /// Whether to use colors in output
  static bool useColors = true;

  /// Whether to use developer.log or print
  static bool useDeveloperLog = false;

  /// Whether to log successful parses
  static bool logSuccess = true;

  /// Whether to show timing information
  static bool showTiming = true;

  /// Whether to show the JSON data in logs
  static bool showJsonData = false;

  /// Maximum string length to show in logs
  static int maxValueLength = 50;

  /// Width of the log box border
  static int maxWidth = 80;

  /// Compress repeated logs for large lists (default true).
  /// When true, after [maxReportsPerClass] logs of the same class,
  /// further logs are suppressed with a summary line.
  static bool compressLogs = true;

  /// Max reports per class name before suppressing (when [compressLogs] is true)
  static int maxReportsPerClass = 10;

  /// Defer log output to a microtask so [DtoLogger.parse] returns immediately.
  /// Useful for large lists where synchronous logging blocks the event loop.
  /// Default is false (synchronous logging, existing behavior).
  static bool deferLogging = false;
}

/// Issue found during parsing
class DtoIssue {
  final String field;
  final String message;
  final IssueType type;

  const DtoIssue({
    required this.field,
    required this.message,
    required this.type,
  });
}

/// Type of validation issue
enum IssueType {
  missingField,
  typeMismatch,
  typeCoerced,
  nullValue,
  extraField,
  suspiciousType,
}

/// Internal parse session - supports nested objects without data loss
class _ParseSession {
  final String className;
  final Map<String, dynamic> json;
  final List<DtoIssue> issues;
  final DateTime startTime;

  final Set<String> accessedKeys;

  _ParseSession({
    required this.className,
    required this.json,
    required this.issues,
    required this.startTime,
  }) : accessedKeys = {};
}

/// Main DTO Logger class - SIMPLE API
///
/// Usage:
/// ```dart
/// factory User.fromJson(Map<String, dynamic> json) {
///   return DtoLogger.parse(json, () => User(
///     id: json.safeInt('id'),
///     name: json.safeString('name'),
///   ));
/// }
/// ```
class DtoLogger {
  DtoLogger._();

  // Cached RegExp for stack trace parsing
  static final _fromJsonPattern = RegExp(r'(\w+)\.fromJson');
  static final _methodPattern = RegExp(r'(\w+)\.\w+');

  // Stack-based sessions: nested objects each get their own session
  // so parsing a child object doesn't overwrite the parent's issues
  static final List<_ParseSession> _sessionStack = [];

  // Report compression: track how many times each class has been logged
  static final Map<String, int> _reportCounts = {};
  static bool _resetScheduled = false;

  /// Auto-detect class name from the call stack.
  /// Looks for patterns like "ClassName.fromJson" in the stack trace.
  /// Falls back to "Unknown" if detection fails (e.g. minified web builds).
  static String _inferClassName() {
    try {
      final trace = StackTrace.current.toString();
      final lines = trace.split('\n');
      // Skip frames from DtoLogger itself, find the first external caller
      for (final line in lines) {
        // Skip DtoLogger's own frames and extension/wrapper frames
        if (line.contains('DtoLogger.') ||
            line.contains('_inferClassName') ||
            line.contains('SafeJsonParsing.') ||
            line.contains('LoggedMap.')) {
          continue;
        }
        // Match "ClassName.methodName" or "new ClassName.fromJson"
        final match = _fromJsonPattern.firstMatch(line);
        if (match != null) return match.group(1)!;
        // Match any "ClassName.methodName" as fallback
        final fallback = _methodPattern.firstMatch(line);
        if (fallback != null) {
          final name = fallback.group(1)!;
          // Skip common non-class names
          if (name != 'main' && name != 'new' && name != 'dart') {
            return name;
          }
        }
        break; // Only check the first non-DtoLogger frame
      }
    } catch (_) {
      // StackTrace parsing failed — safe fallback
    }
    return 'Unknown';
  }

  /// Schedule counter reset after all microtasks complete.
  /// Uses Future.delayed(Duration.zero) which runs after microtask queue drains,
  /// so each API response's items share one budget.
  static void _scheduleCounterReset() {
    if (!_resetScheduled) {
      _resetScheduled = true;
      Future.delayed(Duration.zero, () {
        _reportCounts.clear();
        _resetScheduled = false;
      });
    }
  }

  /// Parse JSON and log results with pretty box-drawn output.
  /// Safe type coercion (safeInt, safeString, etc.) always works,
  /// even in release mode. Only console logging is debug-only.
  ///
  /// [className] is optional — auto-detected from the call stack if omitted.
  static T parse<T>(Map<String, dynamic> json, T Function() builder,
      [String? className]) {
    if (!DtoLogConfig.enabled || DtoLogConfig.level == DtoLogLevel.none) {
      return builder();
    }

    // Debug-only: skip logging overhead in release builds
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    if (!isDebug) return builder();

    final session = _ParseSession(
      className: className ?? _inferClassName(),
      json: json,
      issues: [],
      startTime: DateTime.now(),
    );
    _sessionStack.add(session);

    final T result;
    try {
      result = builder();
    } catch (e) {
      // Report what was collected before the crash, then let the caller see it
      _sessionStack.remove(session);
      session.issues.add(DtoIssue(
        field: 'fromJson',
        message: 'threw $e',
        type: IssueType.typeMismatch,
      ));
      _printResults(session);
      rethrow;
    }
    _sessionStack.remove(session);

    // Detect extra fields from backend not used by model
    for (final key in session.json.keys) {
      if (!session.accessedKeys.contains(key)) {
        session.issues.add(DtoIssue(
          field: key,
          message: 'not used by model',
          type: IssueType.extraField,
        ));
      }
    }

    _printResults(session);

    return result;
  }

  /// Quick JSON logger - just add ONE line to your existing fromJson.
  ///
  /// [className] is optional — auto-detected from the call stack if omitted.
  ///
  /// ```dart
  /// RequestContext.fromJson(Map<String, dynamic> json) {
  ///   DtoLogger.logJson(json);  // class name detected automatically
  ///   sourceSystem = json['sourceSystem'];
  ///   // ... rest of your existing code
  /// }
  /// ```
  static void logJson(Map<String, dynamic> json, [String? className]) {
    if (!DtoLogConfig.enabled) return;
    // logJson can only find nulls (warnings), never errors
    if (DtoLogConfig.level == DtoLogLevel.none ||
        DtoLogConfig.level == DtoLogLevel.errors) {
      return;
    }

    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    if (!isDebug) return;

    final resolvedName = className ?? _inferClassName();

    final c = DtoLogConfig.useColors;
    final w = DtoLogConfig.maxWidth;
    final r = c ? AnsiColors.reset : '';
    final dim = c ? AnsiColors.dim : '';
    final bold = c ? AnsiColors.bold : '';
    final cyan = c ? AnsiColors.cyan : '';
    final yellow = c ? AnsiColors.yellow : '';
    final green = c ? AnsiColors.green : '';

    final nullCount = json.values.where((v) => v == null).length;
    final hasNulls = nullCount > 0;
    if (!hasNulls &&
        (DtoLogConfig.level == DtoLogLevel.warnings ||
            !DtoLogConfig.logSuccess)) {
      return;
    }

    String boxColor;
    String icon;
    String statusText;

    if (hasNulls) {
      boxColor = yellow;
      icon = '⚠';
      statusText = '${json.length} fields, $nullCount null';
    } else {
      boxColor = green;
      icon = '✓';
      statusText = '${json.length} fields';
    }

    // Build entire output as one string for fewer I/O calls
    final buf = StringBuffer();
    buf.writeln(
        '$r$boxColor╔╣ $icon $bold$resolvedName$r$boxColor ║ $statusText$r');

    if (json.isNotEmpty) {
      final maxKeyLen =
          json.keys.fold<int>(0, (max, k) => k.length > max ? k.length : max);

      for (final entry in json.entries) {
        final paddedKey = entry.key.padRight(maxKeyLen);
        final value = entry.value;

        if (value == null) {
          buf.writeln(
              '$boxColor╟$r $yellow⚠$r $cyan$paddedKey$r : ${yellow}null$r');
        } else {
          var valueStr = value.toString();
          if (valueStr.length > DtoLogConfig.maxValueLength) {
            valueStr =
                '${valueStr.substring(0, DtoLogConfig.maxValueLength)}...';
          }
          buf.writeln('$boxColor╟$r   $cyan$paddedKey$r : $dim$valueStr$r');
        }
      }
    }

    buf.write('$boxColor╚${'═' * w}$r');
    _log(buf.toString());
  }

  /// Track field access for extra field detection
  static void _trackAccess(Map<String, dynamic> map, String key) {
    if (_sessionStack.isNotEmpty && identical(map, _sessionStack.last.json)) {
      _sessionStack.last.accessedKeys.add(key);
    }
  }

  /// Log an issue (called internally by safe parsing methods)
  static void logIssue(String field, String message, IssueType type) {
    if (_sessionStack.isNotEmpty) {
      _sessionStack.last.issues
          .add(DtoIssue(field: field, message: message, type: type));
    }
  }

  static void _printResults(_ParseSession session) {
    if (!DtoLogConfig.enabled || DtoLogConfig.level == DtoLogLevel.none) return;

    final duration = DateTime.now().difference(session.startTime);

    // Severity groups:
    // errors = typeMismatch only (real breakage)
    // warns  = typeCoerced, suspiciousType, missingField (worth knowing)
    // info   = nullValue (very common, just informational)
    // extras = extraField (backend sends unused data)
    final errors =
        session.issues.where((i) => i.type == IssueType.typeMismatch).toList();
    final warns = session.issues
        .where((i) =>
            i.type == IssueType.typeCoerced ||
            i.type == IssueType.suspiciousType ||
            i.type == IssueType.missingField)
        .toList();
    final infos =
        session.issues.where((i) => i.type == IssueType.nullValue).toList();
    final extras =
        session.issues.where((i) => i.type == IssueType.extraField).toList();
    final hasErrors = errors.isNotEmpty;
    final hasWarnings = warns.isNotEmpty;
    final hasExtras = extras.isNotEmpty;

    if (DtoLogConfig.level == DtoLogLevel.errors && !hasErrors) return;
    if (DtoLogConfig.level == DtoLogLevel.warnings &&
        !hasErrors &&
        !hasWarnings &&
        !hasExtras) {
      return;
    }
    if (!DtoLogConfig.logSuccess && session.issues.isEmpty) return;

    // Report compression: suppress repeated logs for large lists
    if (DtoLogConfig.compressLogs) {
      final key = session.className;
      _reportCounts[key] = (_reportCounts[key] ?? 0) + 1;
      final count = _reportCounts[key]!;
      if (count > DtoLogConfig.maxReportsPerClass) {
        if (count == DtoLogConfig.maxReportsPerClass + 1) {
          final dim = DtoLogConfig.useColors ? AnsiColors.dim : '';
          final r = DtoLogConfig.useColors ? AnsiColors.reset : '';
          _log(
              '$dim╔╣ ... $key ║ further logs suppressed (repeated pattern)$r');
        }
        return;
      }
      _scheduleCounterReset();
    }

    final c = DtoLogConfig.useColors;
    final w = DtoLogConfig.maxWidth;

    // Pick color + icon + status text based on severity
    // Red = only for typeMismatch (real errors)
    // Yellow = coercion, suspicious types, missing fields
    // Green = clean parse (nulls alone don't downgrade)
    String boxColor;
    String icon;
    String statusText;

    if (hasErrors) {
      boxColor = c ? AnsiColors.red : '';
      icon = '✗';
      final parts = <String>[];
      parts.add('${errors.length} error${errors.length > 1 ? 's' : ''}');
      if (warns.isNotEmpty) {
        parts.add('${warns.length} warning${warns.length > 1 ? 's' : ''}');
      }
      if (extras.isNotEmpty) parts.add('${extras.length} extra');
      statusText = parts.join(', ');
    } else if (hasWarnings) {
      boxColor = c ? AnsiColors.yellow : '';
      icon = '⚠';
      final parts = <String>[];
      parts.add('${warns.length} warning${warns.length > 1 ? 's' : ''}');
      if (extras.isNotEmpty) parts.add('${extras.length} extra');
      statusText = parts.join(', ');
    } else if (hasExtras) {
      boxColor = c ? AnsiColors.cyan : '';
      icon = '+';
      statusText =
          '${extras.length} extra field${extras.length > 1 ? 's' : ''}';
    } else {
      boxColor = c ? AnsiColors.green : '';
      icon = '✓';
      final nullCount = infos.length;
      statusText =
          nullCount > 0 ? 'parsed safely · $nullCount null' : 'parsed safely';
    }

    final r = c ? AnsiColors.reset : '';
    final dim = c ? AnsiColors.dim : '';
    final bold = c ? AnsiColors.bold : '';
    final cyan = c ? AnsiColors.cyan : '';

    // Build entire output as one string for fewer I/O calls
    final buf = StringBuffer();

    final timing =
        DtoLogConfig.showTiming ? ' ║ ${duration.inMicroseconds}µs' : '';
    buf.writeln(
        '$r$boxColor╔╣ $icon $bold${session.className}$r$boxColor ║ $statusText$timing$r');

    // Issue lines with aligned field names
    if (session.issues.isNotEmpty) {
      final maxFieldLen = session.issues.fold<int>(
          0, (max, i) => i.field.length > max ? i.field.length : max);

      // ╟ + sp + icon + sp + field + sp + : + sp = 7 chars of prefix
      final msgMaxLen = w - maxFieldLen - 7;

      for (final issue in session.issues) {
        final paddedField = issue.field.padRight(maxFieldLen);
        String issueColor;
        String issueIcon;
        if (issue.type == IssueType.typeMismatch) {
          issueColor = c ? AnsiColors.red : '';
          issueIcon = '✗';
        } else if (issue.type == IssueType.missingField) {
          issueColor = c ? AnsiColors.yellow : '';
          issueIcon = '?';
        } else if (issue.type == IssueType.nullValue) {
          issueColor = c ? AnsiColors.dim : '';
          issueIcon = '·';
        } else if (issue.type == IssueType.extraField) {
          issueColor = c ? AnsiColors.cyan : '';
          issueIcon = '+';
        } else if (issue.type == IssueType.suspiciousType) {
          issueColor = c ? AnsiColors.magenta : '';
          issueIcon = '~';
        } else {
          issueColor = c ? AnsiColors.yellow : '';
          issueIcon = '⚠';
        }
        var msg = issue.message;
        if (msgMaxLen > 6 && msg.length > msgMaxLen) {
          msg = '${msg.substring(0, msgMaxLen - 3)}...';
        }
        buf.writeln(
            '$boxColor╟$r $issueColor$issueIcon$r $cyan$paddedField$r : $issueColor$msg$r');
      }
    }

    // JSON data preview (when showJsonData is enabled)
    if (DtoLogConfig.showJsonData && session.json.isNotEmpty) {
      buf.writeln('$boxColor╟$dim${'─' * w}$r');
      final maxLen = DtoLogConfig.maxValueLength;
      final display = session.json.map((k, v) {
        if (v is String && v.length > maxLen) {
          return MapEntry(k, '${v.substring(0, maxLen)}...');
        }
        return MapEntry(k, v);
      });
      final jsonStr = const JsonEncoder.withIndent('  ').convert(display);
      for (final line in jsonStr.split('\n')) {
        buf.writeln('$boxColor║$r  $dim$line$r');
      }
    }

    buf.write('$boxColor╚${'═' * w}$r');
    _log(buf.toString());
  }

  static void _log(String message) {
    if (DtoLogConfig.deferLogging) {
      final msg = message;
      scheduleMicrotask(() => _logSync(msg));
      return;
    }
    _logSync(message);
  }

  static void _logSync(String message) {
    if (DtoLogConfig.useDeveloperLog) {
      developer.log(message, name: 'DTO');
    } else {
      // ignore: avoid_print
      print(message);
    }
  }
}

/// Extension on Map for safe parsing WITH automatic logging
extension SafeJsonParsing on Map<String, dynamic> {
  /// Log a [ParseResult] warning with the right severity:
  /// key absent → missingField, parse failed → typeMismatch,
  /// null → nullValue, converted → typeCoerced.
  void _logResult(String key, ParseResult<Object?> result) {
    if (result.warning == null) return;
    final IssueType type;
    if (!containsKey(key)) {
      DtoLogger.logIssue(key, 'not in response', IssueType.missingField);
      return;
    } else if (!result.success) {
      type = IssueType.typeMismatch;
    } else if (result.value == null) {
      type = IssueType.nullValue;
    } else {
      type = IssueType.typeCoerced;
    }
    DtoLogger.logIssue(key, result.warning!, type);
  }

  /// Log why [value] (which is not the expected container) was rejected.
  void _logRejected(String key, dynamic value, String expected) {
    if (value == null) {
      if (!containsKey(key)) {
        DtoLogger.logIssue(key, 'not in response', IssueType.missingField);
      } else {
        DtoLogger.logIssue(key, 'null', IssueType.nullValue);
      }
      return;
    }
    DtoLogger.logIssue(key, 'got ${value.runtimeType}, expected $expected',
        IssueType.typeMismatch);
  }

  /// Get int with safe coercion and logging
  int? safeInt(String key) {
    DtoLogger._trackAccess(this, key);
    final result = SafeParser.asInt(this[key]);
    _logResult(key, result);
    return result.value;
  }

  /// Get double with safe coercion and logging
  double? safeDouble(String key) {
    DtoLogger._trackAccess(this, key);
    final result = SafeParser.asDouble(this[key]);
    _logResult(key, result);
    return result.value;
  }

  /// Get String with safe coercion and logging
  String? safeString(String key) {
    DtoLogger._trackAccess(this, key);
    final result = SafeParser.asString(this[key]);
    _logResult(key, result);
    return result.value;
  }

  /// Get bool with safe coercion and logging
  bool? safeBool(String key) {
    DtoLogger._trackAccess(this, key);
    final result = SafeParser.asBool(this[key]);
    _logResult(key, result);
    return result.value;
  }

  /// Get DateTime with safe coercion and logging
  DateTime? safeDateTime(String key) {
    DtoLogger._trackAccess(this, key);
    final result = SafeParser.asDateTime(this[key]);
    _logResult(key, result);
    return result.value;
  }

  /// A default means absence is expected, so null/missing is not logged.
  bool _isAbsent(String key) {
    DtoLogger._trackAccess(this, key);
    return this[key] == null;
  }

  /// Get int with default value (null/missing is not logged)
  int safeIntOr(String key, int defaultValue) =>
      _isAbsent(key) ? defaultValue : safeInt(key) ?? defaultValue;

  /// Get double with default value (null/missing is not logged)
  double safeDoubleOr(String key, double defaultValue) =>
      _isAbsent(key) ? defaultValue : safeDouble(key) ?? defaultValue;

  /// Get String with default value (null/missing is not logged)
  String safeStringOr(String key, String defaultValue) =>
      _isAbsent(key) ? defaultValue : safeString(key) ?? defaultValue;

  /// Get bool with default value (null/missing is not logged)
  bool safeBoolOr(String key, bool defaultValue) =>
      _isAbsent(key) ? defaultValue : safeBool(key) ?? defaultValue;

  /// Get nested object. Accepts any Map (e.g. `Map<dynamic, dynamic>`).
  T? safeObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    DtoLogger._trackAccess(this, key);
    final value = this[key];
    final map = SafeParser.asMap(value).value;
    if (map == null) {
      _logRejected(key, value, 'Map');
      return null;
    }
    return fromJson(map);
  }

  /// Get list of objects. Items that are not maps are skipped and logged
  /// instead of throwing.
  List<T>? safeList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    DtoLogger._trackAccess(this, key);
    final value = this[key];
    if (value is! List) {
      _logRejected(key, value, 'List');
      return null;
    }
    final items = <T>[];
    for (var i = 0; i < value.length; i++) {
      final map = SafeParser.asMap(value[i]).value;
      if (map == null) {
        DtoLogger.logIssue(
            '$key[$i]',
            'got ${value[i].runtimeType}, expected Map (skipped)',
            IssueType.typeMismatch);
        continue;
      }
      items.add(fromJson(map));
    }
    return items;
  }

  /// Get list of primitives. Items are coerced like single values
  /// (`"1"` → `1` for `int`); items that can't be converted are skipped.
  List<T>? safeListOf<T>(String key) {
    DtoLogger._trackAccess(this, key);
    final value = this[key];
    if (value is! List) {
      _logRejected(key, value, 'List');
      return null;
    }
    final items = <T>[];
    var coerced = 0;
    final skipped = <int>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      if (item is T) {
        items.add(item);
        continue;
      }
      final converted = _coerceListItem<T>(item);
      // null here means conversion failed (a real null item passed `is T`)
      if (converted != null && converted is T) {
        items.add(converted as T);
        coerced++;
      } else {
        skipped.add(i);
      }
    }
    if (coerced > 0) {
      DtoLogger.logIssue(
          key, '$coerced item(s) coerced to $T', IssueType.typeCoerced);
    }
    if (skipped.isNotEmpty) {
      DtoLogger.logIssue(
          key,
          '${skipped.length} item(s) are not $T, skipped at ${skipped.join(', ')}',
          IssueType.typeMismatch);
    }
    return items;
  }

  /// Convert one list item to [T] using the same rules as single fields.
  /// Returns null when [T] has no coercion rule or conversion fails.
  static Object? _coerceListItem<T>(dynamic item) {
    // Probe T with sample values instead of comparing Type objects,
    // so nullable and num types work too.
    if (0.5 is T) return SafeParser.asDouble(item).value;
    if (0 is T) return SafeParser.asInt(item).value;
    if ('' is T) return SafeParser.asString(item).value;
    if (true is T) return SafeParser.asBool(item).value;
    if (DateTime.fromMillisecondsSinceEpoch(0) is T) {
      return SafeParser.asDateTime(item).value;
    }
    if (<String, dynamic>{} is T) return SafeParser.asMap(item).value;
    return null;
  }

  /// Get enum value (case-insensitive match)
  T? safeEnum<T extends Enum>(String key, List<T> values) {
    DtoLogger._trackAccess(this, key);
    final raw = this[key];
    if (raw == null) {
      _logRejected(key, raw, 'enum');
      return null;
    }
    final str = raw.toString().toLowerCase();
    for (final v in values) {
      if (v.name.toLowerCase() == str) return v;
    }
    final allowed = values.map((v) => v.name).join(', ');
    DtoLogger.logIssue(
        key, '"$raw" — expected: $allowed', IssueType.typeMismatch);
    return null;
  }

  /// Get a list of enum values (case-insensitive). Unknown items are
  /// skipped and logged.
  List<T>? safeEnumList<T extends Enum>(String key, List<T> values) {
    DtoLogger._trackAccess(this, key);
    final value = this[key];
    if (value is! List) {
      _logRejected(key, value, 'List');
      return null;
    }
    final byName = {for (final v in values) v.name.toLowerCase(): v};
    final items = <T>[];
    final unknown = <Object?>[];
    for (final raw in value) {
      final match = raw == null ? null : byName[raw.toString().toLowerCase()];
      if (match == null) {
        unknown.add(raw);
      } else {
        items.add(match);
      }
    }
    if (unknown.isNotEmpty) {
      final allowed = values.map((v) => v.name).join(', ');
      DtoLogger.logIssue(
          key,
          '${unknown.length} unknown item(s) skipped: ${unknown.take(3).join(', ')}'
          ' — expected: $allowed',
          IssueType.typeMismatch);
    }
    return items;
  }

  /// Get the raw value (for `dynamic` fields). Only records the access, so
  /// the key is not reported as an unused extra field.
  dynamic safeValue(String key) {
    DtoLogger._trackAccess(this, key);
    return this[key];
  }

  /// Get a value that is already a [T], without conversion. Used by
  /// generated code for types with no coercion rule; a wrong type is
  /// logged and returns null instead of throwing a cast error.
  T? safeCast<T>(String key) {
    DtoLogger._trackAccess(this, key);
    final value = this[key];
    if (value != null && value is T) return value;
    _logRejected(key, value, '$T');
    return null;
  }

  /// Get enum value with fallback for unknown values
  T safeEnumOr<T extends Enum>(String key, List<T> values, T fallback) {
    if (_isAbsent(key)) return fallback;
    return safeEnum(key, values) ?? fallback;
  }

  /// Get Map with safe coercion and logging
  Map<String, dynamic>? safeMap(String key) {
    DtoLogger._trackAccess(this, key);
    final result = SafeParser.asMap(this[key]);
    _logResult(key, result);
    return result.value;
  }

  /// Wrap this map with logging. Add ONE line to existing fromJson:
  ///
  /// ```dart
  /// factory User.fromJson(Map<String, dynamic> json) {
  ///   json = json.logged();
  ///   return User(id: json['id'] as int?, name: json['name'] as String?);
  /// }
  /// ```
  ///
  /// In release builds, returns the original map (zero overhead).
  /// Safe type coercion (safeInt, etc.) always works in both modes.
  Map<String, dynamic> logged([String? className]) {
    if (!DtoLogConfig.enabled || DtoLogConfig.level == DtoLogLevel.none) {
      return this;
    }
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    if (!isDebug) return this;
    return LoggedMap._(this, className ?? DtoLogger._inferClassName());
  }
}

/// A Map wrapper that tracks field access for automatic logging.
///
/// Use the `.logged()` extension on any `Map<String, dynamic>`:
/// ```dart
/// factory User.fromJson(Map<String, dynamic> json) {
///   json = json.logged();
///   return User(id: json['id'] as int?, name: json['name'] as String?);
/// }
/// ```
class LoggedMap extends MapBase<String, dynamic> {
  final Map<String, dynamic> _inner;
  final String _className;
  final DateTime _startTime;
  final Set<String> _accessedKeys = {};
  bool _reported = false;

  LoggedMap._(this._inner, this._className) : _startTime = DateTime.now() {
    DtoLogger._scheduleCounterReset();
    scheduleMicrotask(_report);
  }

  @override
  dynamic operator [](Object? key) {
    if (key is String) _accessedKeys.add(key);
    return _inner[key];
  }

  @override
  Iterable<String> get keys => _inner.keys;

  @override
  void operator []=(String key, dynamic value) => _inner[key] = value;

  @override
  void clear() => _inner.clear();

  @override
  dynamic remove(Object? key) => _inner.remove(key);

  void _report() {
    if (!DtoLogConfig.enabled || _reported) return;
    _reported = true;

    final issues = <DtoIssue>[];

    // Pass 1: check all accessed keys (missing, null, suspicious)
    for (final key in _accessedKeys) {
      if (!_inner.containsKey(key)) {
        issues.add(DtoIssue(
          field: key,
          message: 'not in response',
          type: IssueType.missingField,
        ));
      } else {
        final value = _inner[key];
        if (value == null) {
          issues.add(DtoIssue(
            field: key,
            message: 'null',
            type: IssueType.nullValue,
          ));
        } else {
          final hint = _detectSuspiciousType(value);
          if (hint != null) {
            var preview = value.toString();
            if (preview.length > DtoLogConfig.maxValueLength) {
              preview =
                  '${preview.substring(0, DtoLogConfig.maxValueLength)}...';
            }
            issues.add(DtoIssue(
              field: key,
              message: '"$preview" $hint',
              type: IssueType.suspiciousType,
            ));
          }
        }
      }
    }

    // Pass 2: check inner keys not accessed (extra fields + unaccessed nulls)
    for (final key in _inner.keys) {
      if (!_accessedKeys.contains(key)) {
        if (_inner[key] == null) {
          issues.add(DtoIssue(
            field: key,
            message: 'null',
            type: IssueType.nullValue,
          ));
        } else {
          issues.add(DtoIssue(
            field: key,
            message: 'not used by model',
            type: IssueType.extraField,
          ));
        }
      }
    }

    final session = _ParseSession(
      className: _className,
      json: _inner,
      issues: issues,
      startTime: _startTime,
    );
    DtoLogger._printResults(session);
  }

  static String? _detectSuspiciousType(dynamic value) {
    if (value is! String) return null;
    if (int.tryParse(value) != null) return 'looks like int';
    if (double.tryParse(value) != null && value.contains('.')) {
      return 'looks like double';
    }
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == 'false') return 'looks like bool';
    return null;
  }
}
