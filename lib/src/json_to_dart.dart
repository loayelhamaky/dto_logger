/// JSON to Dart class generator
/// Generates CLEAN classes - all logging logic is in the package
library;

import 'case_converter.dart';

/// Options for class generation
class GeneratorOptions {
  final bool generateFromJson;
  final bool generateToJson;
  final bool generateCopyWith;
  final bool generateEquality;
  final bool addLogging;

  /// When false, fields seen with a value in every sample become
  /// non-nullable and `fromJson` throws a [FormatException] if they are
  /// missing or invalid.
  final bool allNullable;
  final String? dtoLoggerImport;

  const GeneratorOptions({
    this.generateFromJson = true,
    this.generateToJson = true,
    this.generateCopyWith = false,
    this.generateEquality = false,
    this.addLogging = true,
    this.allNullable = true,
    this.dtoLoggerImport = 'package:dto_logger/dto_logger.dart',
  });
}

/// Represents a field in a generated class
class FieldInfo {
  final String name;
  final String jsonKey;
  final String type;
  final bool nullable;
  final bool isNestedObject;
  final bool isList;
  final String? nestedClassName;
  final String? warning;

  /// Item type of a list of primitives, e.g. `int` or `String?`.
  final String? listElementType;

  /// True for `Map<String, dynamic>` fields (empty objects in the sample).
  final bool isMap;

  const FieldInfo({
    required this.name,
    required this.jsonKey,
    required this.type,
    required this.nullable,
    this.isNestedObject = false,
    this.isList = false,
    this.nestedClassName,
    this.warning,
    this.listElementType,
    this.isMap = false,
  });
}

/// Result of class generation
class GeneratedClass {
  final String name;
  final String code;
  final List<FieldInfo> fields;
  final List<GeneratedClass> nestedClasses;
  final List<String> warnings;

  const GeneratedClass({
    required this.name,
    required this.code,
    required this.fields,
    this.nestedClasses = const [],
    this.warnings = const [],
  });

  String get fullCode {
    final buffer = StringBuffer();
    buffer.writeln(code);
    for (final nested in nestedClasses) {
      buffer.writeln();
      buffer.write(nested.fullCode);
    }
    return buffer.toString();
  }
}

/// Generates CLEAN Dart classes from JSON
class JsonToDartGenerator {
  final GeneratorOptions options;
  final Set<String> _generatedClassNames = {};

  JsonToDartGenerator({this.options = const GeneratorOptions()});

  /// Generate a class (and its nested classes) from one JSON object.
  GeneratedClass generate(Map<String, dynamic> json, String className) =>
      generateFromSamples([json], className);

  /// Generate a class from several samples of the same object, for example
  /// the items of a JSON array. Keys are merged across samples; a key that
  /// is missing or null in any sample becomes nullable.
  GeneratedClass generateFromSamples(
      List<Map<String, dynamic>> samples, String className) {
    _generatedClassNames.clear();
    final name = _topLevelClassName(className);
    _generatedClassNames.add(name);
    return _generateClass(samples, name);
  }

  GeneratedClass _generateClass(
      List<Map<String, dynamic>> samples, String className) {
    final fields = <FieldInfo>[];
    final nestedClasses = <GeneratedClass>[];
    final warnings = <String>[];
    final usedNames = <String>{};

    // Union of keys across samples, in first-seen order
    final keys = <String>{for (final sample in samples) ...sample.keys};
    for (final key in keys) {
      final values = [for (final sample in samples) sample[key]];
      final field = _analyzeField(
        key,
        _uniqueFieldName(key, usedNames),
        values,
        className,
        nestedClasses,
      );
      fields.add(field);
      if (field.warning != null) warnings.add(field.warning!);
    }

    return GeneratedClass(
      name: className,
      code: _generateCode(className, fields),
      fields: fields,
      nestedClasses: nestedClasses,
      warnings: warnings,
    );
  }

  FieldInfo _analyzeField(
    String jsonKey,
    String name,
    List<dynamic> values,
    String ownerClass,
    List<GeneratedClass> nestedClasses,
  ) {
    final present = values.where((v) => v != null).toList();
    // Missing or null in any sample means the API does send null here
    final nullable = options.allNullable || present.length != values.length;
    String typed(String base) => nullable ? '$base?' : base;

    if (present.isEmpty) {
      return FieldInfo(
        name: name,
        jsonKey: jsonKey,
        type: 'String?',
        nullable: true,
        warning: 'Field "$jsonKey" is null - assuming String?',
      );
    }

    if (present.every((v) => v is Map)) {
      final maps = present.map(_asStringMap).toList();
      if (maps.every((m) => m.isEmpty)) {
        return FieldInfo(
          name: name,
          jsonKey: jsonKey,
          type: typed('Map<String, dynamic>'),
          nullable: nullable,
          isMap: true,
          warning: 'Field "$jsonKey" is an empty object - '
              'using Map<String, dynamic>',
        );
      }
      final nested =
          _generateClass(maps, _uniqueClassName(_pascal(name), ownerClass));
      nestedClasses.add(nested);
      return FieldInfo(
        name: name,
        jsonKey: jsonKey,
        type: typed(nested.name),
        nullable: nullable,
        isNestedObject: true,
        nestedClassName: nested.name,
      );
    }

    if (present.every((v) => v is List)) {
      final items = [for (final list in present) ...(list as List)];
      final presentItems = items.where((e) => e != null).toList();

      if (presentItems.isEmpty) {
        return FieldInfo(
          name: name,
          jsonKey: jsonKey,
          type: 'List<dynamic>?',
          nullable: true,
          isList: true,
          listElementType: 'dynamic',
          warning: 'Empty list',
        );
      }

      if (presentItems.every((e) => e is Map)) {
        final nested = _generateClass(
          presentItems.map(_asStringMap).toList(),
          _uniqueClassName(_pascal(_singularize(name)), ownerClass),
        );
        nestedClasses.add(nested);
        return FieldInfo(
          name: name,
          jsonKey: jsonKey,
          type: typed('List<${nested.name}>'),
          nullable: nullable,
          isList: true,
          isNestedObject: true,
          nestedClassName: nested.name,
        );
      }

      var element = _primitiveType(presentItems);
      final hasNullItems = presentItems.length != items.length;
      if (hasNullItems && element != 'dynamic') element = '$element?';
      return FieldInfo(
        name: name,
        jsonKey: jsonKey,
        type: typed('List<$element>'),
        nullable: nullable,
        isList: true,
        listElementType: element,
        warning: element == 'dynamic'
            ? 'Field "$jsonKey" has items of mixed types - using List<dynamic>'
            : null,
      );
    }

    final type = _primitiveType(present);
    if (type == 'dynamic') {
      return FieldInfo(
        name: name,
        jsonKey: jsonKey,
        type: 'dynamic',
        nullable: true,
        warning: 'Field "$jsonKey" has mixed types - using dynamic',
      );
    }
    return FieldInfo(
      name: name,
      jsonKey: jsonKey,
      type: typed(type),
      nullable: nullable,
    );
  }

  /// The common Dart type of JSON scalars, or `dynamic` when they disagree.
  static String _primitiveType(List<dynamic> values) {
    if (values.every((v) => v is int)) return 'int';
    if (values.every((v) => v is num)) return 'double';
    if (values.every((v) => v is String)) return 'String';
    if (values.every((v) => v is bool)) return 'bool';
    return 'dynamic';
  }

  static Map<String, dynamic> _asStringMap(dynamic value) =>
      value is Map<String, dynamic>
          ? value
          : (value as Map).map((k, v) => MapEntry(k.toString(), v));

  // ═══════════════════════════════════════════════════════════════════════
  // Naming
  // ═══════════════════════════════════════════════════════════════════════

  /// Keep the user's class name when it is already valid ("HTTPResponse"),
  /// otherwise sanitize it ("user response" → "UserResponse").
  String _topLevelClassName(String raw) {
    final pascal = CaseConverter.snakeToPascal(raw.trim());
    if (CaseConverter.isValidIdentifier(pascal) && !pascal.startsWith('_')) {
      return pascal;
    }
    return _pascal(CaseConverter.toValidIdentifier(raw));
  }

  /// Nested class names must not shadow dart:core types or repeat:
  /// a second "dup" object under "wrap" becomes "WrapDup".
  String _uniqueClassName(String base, String ownerClass) {
    var name = base.endsWith('_') ? base.substring(0, base.length - 1) : base;
    if (name.isEmpty) name = 'Item';
    if (_reservedTypeNames.contains(name) ||
        _generatedClassNames.contains(name)) {
      name = '$ownerClass$name';
    }
    var candidate = name;
    var suffix = 2;
    while (_generatedClassNames.contains(candidate)) {
      candidate = '$name$suffix';
      suffix++;
    }
    _generatedClassNames.add(candidate);
    return candidate;
  }

  /// Valid, non-reserved, unique field name for a JSON key:
  /// "user-name" → userName, "class" → class_, "1st" → field1st,
  /// a second key that maps to "userName" → userName2.
  static String _uniqueFieldName(String jsonKey, Set<String> used) {
    var name = CaseConverter.toValidIdentifier(jsonKey);
    if (_reservedMemberNames.contains(name)) name = '${name}Value';
    var candidate = name;
    var suffix = 2;
    while (used.contains(candidate)) {
      candidate = '$name$suffix';
      suffix++;
    }
    used.add(candidate);
    return candidate;
  }

  static String _pascal(String name) =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  /// Dart string literal for any JSON key: quotes, `$` and `\` escaped.
  static String _literal(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
    return "'$escaped'";
  }

  /// dart:core names and names used by the generated code itself.
  static const _reservedTypeNames = {
    'BigInt', 'DateTime', 'Duration', 'DtoIssue', 'DtoLogger', 'Enum', //
    'Error', 'Exception', 'FormatException', 'Function', 'Future',
    'Iterable', 'Iterator', 'List', 'Map', 'MapEntry', 'Match', 'Never',
    'Null', 'Object', 'ParseResult', 'Pattern', 'Record', 'RegExp',
    'SafeParser', 'Set', 'Sink', 'StackTrace', 'Stream', 'String',
    'StringBuffer', 'Symbol', 'Type', 'Uri',
  };

  /// Members every generated class already has.
  static const _reservedMemberNames = {
    'copyWith', 'hashCode', 'noSuchMethod', 'runtimeType', 'toJson', //
    'toString',
  };

  // ═══════════════════════════════════════════════════════════════════════
  // Code generation
  // ═══════════════════════════════════════════════════════════════════════

  String _generateCode(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();

    // Class declaration
    buffer.writeln('class $className {');

    // Fields
    for (final field in fields) {
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln();

    // Constructor (an empty `({})` parameter list is not valid Dart)
    if (fields.isEmpty) {
      buffer.writeln('  $className();');
    } else {
      buffer.writeln('  $className({');
      for (final field in fields) {
        final required = !field.nullable ? 'required ' : '';
        buffer.writeln('    ${required}this.${field.name},');
      }
      buffer.writeln('  });');
    }

    if (options.generateFromJson) {
      buffer.writeln();
      buffer.writeln(_generateFromJson(className, fields));
    }

    if (options.generateToJson) {
      buffer.writeln();
      buffer.writeln(_generateToJson(fields));
    }

    if (options.generateCopyWith) {
      buffer.writeln();
      buffer.writeln(_generateCopyWith(className, fields));
    }

    if (options.generateEquality) {
      buffer.writeln();
      buffer.writeln(_generateEquality(className, fields));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate CLEAN fromJson - all logic hidden in package
  String _generateFromJson(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();

    buffer
        .writeln('  factory $className.fromJson(Map<String, dynamic> json) {');

    if (options.addLogging) {
      buffer.writeln('    return DtoLogger.parse(json, () => $className(');
    } else {
      buffer.writeln('    return $className(');
    }

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final comma = i < fields.length - 1 ? ',' : '';
      buffer.writeln('      ${field.name}: ${_readExpression(field)}$comma');
    }

    if (options.addLogging) {
      // Class name passed explicitly: no stack-trace lookup per parse
      buffer.writeln("    ), '$className');");
    } else {
      buffer.writeln('    );');
    }
    buffer.writeln('  }');

    return buffer.toString();
  }

  String _readExpression(FieldInfo field) {
    final key = _literal(field.jsonKey);
    final String read;
    if (field.isList && field.isNestedObject) {
      read = 'json.safeList($key, ${field.nestedClassName}.fromJson)';
    } else if (field.isNestedObject) {
      read = 'json.safeObject($key, ${field.nestedClassName}.fromJson)';
    } else if (field.isList) {
      final element = field.listElementType ??
          field.type
              .replaceAll('List<', '')
              .replaceAll('>?', '')
              .replaceAll('>', '');
      read = 'json.safeListOf<$element>($key)';
    } else if (field.isMap) {
      read = 'json.safeMap($key)';
    } else if (field.type == 'dynamic') {
      read = 'json.safeValue($key)';
    } else {
      read = 'json.${_getSafeMethod(field.type.replaceAll('?', ''))}($key)';
    }

    if (field.nullable) return read;
    final message =
        _literal('Required field "${field.jsonKey}" is missing or invalid');
    return '$read ?? (throw FormatException($message))';
  }

  String _getSafeMethod(String type) {
    switch (type) {
      case 'int': return 'safeInt';
      case 'double': return 'safeDouble';
      case 'bool': return 'safeBool';
      case 'String': return 'safeString';
      case 'DateTime': return 'safeDateTime';
      default: return 'safeString';
    }
  }

  String _generateToJson(List<FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln('  Map<String, dynamic> toJson() => {');

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final comma = i < fields.length - 1 ? ',' : '';
      final access = field.nullable ? '?.' : '.';
      final key = _literal(field.jsonKey);

      if (field.isNestedObject && !field.isList) {
        buffer.writeln('        $key: ${field.name}${access}toJson()$comma');
      } else if (field.isList && field.isNestedObject) {
        buffer.writeln(
            '        $key: ${field.name}${access}map((e) => e.toJson()).toList()$comma');
      } else {
        buffer.writeln('        $key: ${field.name}$comma');
      }
    }

    buffer.writeln('      };');
    return buffer.toString();
  }

  String _generateCopyWith(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    if (fields.isEmpty) {
      buffer.writeln('  $className copyWith() => $className();');
      return buffer.toString();
    }

    buffer.writeln('  $className copyWith({');
    for (final field in fields) {
      final paramType = field.type.endsWith('?') || field.type == 'dynamic'
          ? field.type
          : '${field.type}?';
      buffer.writeln('    $paramType ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return $className(');
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final comma = i < fields.length - 1 ? ',' : '';
      buffer.writeln(
          '      ${field.name}: ${field.name} ?? this.${field.name}$comma');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    return buffer.toString();
  }

  String _generateEquality(String className, List<FieldInfo> fields) {
    final buffer = StringBuffer();
    // A field called "other" would shadow the parameter
    final names = fields.map((f) => f.name).toSet();
    final other = ['other', 'that', 'o'].firstWhere(
      (n) => !names.contains(n),
      orElse: () => 'otherObject',
    );

    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object $other) =>');
    buffer.writeln('      identical(this, $other) ||');
    buffer.write('      $other is $className');

    for (final field in fields) {
      buffer.write(' &&\n          $other.${field.name} == ${field.name}');
    }
    buffer.writeln(';');
    buffer.writeln();

    buffer.writeln('  @override');
    if (fields.isEmpty) {
      buffer.writeln('  int get hashCode => 0;');
    } else if (fields.length == 1) {
      buffer.writeln('  int get hashCode => ${fields[0].name}.hashCode;');
    } else if (fields.length <= 20) {
      buffer.write('  int get hashCode => Object.hash(');
      buffer.write(fields.map((f) => f.name).join(', '));
      buffer.writeln(');');
    } else {
      // Object.hash accepts at most 20 values
      buffer.write('  int get hashCode => Object.hashAll([');
      buffer.write(fields.map((f) => f.name).join(', '));
      buffer.writeln(']);');
    }

    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Singularization (list field name → item class name)
  // ═══════════════════════════════════════════════════════════════════════

  static const _irregularPlurals = {
    'analyses': 'analysis', 'bonuses': 'bonus', 'buses': 'bus', //
    'campuses': 'campus', 'children': 'child', 'cookies': 'cookie',
    'criteria': 'criterion', 'data': 'data', 'feet': 'foot',
    'geese': 'goose', 'indices': 'index', 'matrices': 'matrix',
    'media': 'media', 'men': 'man', 'menus': 'menu', 'mice': 'mouse',
    'movies': 'movie', 'news': 'news', 'people': 'person',
    'quizzes': 'quiz', 'series': 'series', 'species': 'species',
    'statuses': 'status', 'teeth': 'tooth', 'vertices': 'vertex',
    'viruses': 'virus', 'women': 'woman',
  };

  /// Singularizes the last camelCase word: orderItems → orderItem,
  /// categories → category, addresses → address, status → status.
  String _singularize(String word) {
    var start = 0;
    for (var i = word.length - 1; i > 0; i--) {
      final char = word[i];
      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        start = i;
        break;
      }
    }
    final last = word.substring(start);
    if (last.isEmpty) return word;
    var singular = _singularWord(last.toLowerCase());
    if (last[0] != last[0].toLowerCase()) {
      singular = singular[0].toUpperCase() + singular.substring(1);
    }
    return word.substring(0, start) + singular;
  }

  static String _singularWord(String word) {
    final irregular = _irregularPlurals[word];
    if (irregular != null) return irregular;
    if (word.length <= 2) return word;
    // Already singular: address, status, analysis
    if (word.endsWith('ss') || word.endsWith('us') || word.endsWith('is')) {
      return word;
    }
    if (word.endsWith('ies') && word.length > 4) {
      return '${word.substring(0, word.length - 3)}y';
    }
    if (word.endsWith('sses') ||
        word.endsWith('xes') ||
        word.endsWith('zes') ||
        word.endsWith('ches') ||
        word.endsWith('shes')) {
      return word.substring(0, word.length - 2);
    }
    // courses → course, images → image, items → item
    if (word.endsWith('s')) return word.substring(0, word.length - 1);
    return word;
  }
}
