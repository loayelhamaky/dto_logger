/// Code generator for @DtoLog annotation
/// Uses build_runner and source_gen
///
/// Uses only element API members that exist from analyzer 8.1.1 through 14.x.
library;

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dto_logger/dto_logger.dart' show DtoLog;

/// Builder factory for build_runner
Builder dtoLoggerBuilder(BuilderOptions options) =>
    SharedPartBuilder([DtoLogGenerator()], 'dto_logger');

// Matched by library URL, so json_annotation's JsonKey etc. are never picked up
const _annotationsUrl = 'package:dto_logger/src/annotations.dart';
const _keyChecker = TypeChecker.fromUrl('$_annotationsUrl#DtoKey');
const _defaultChecker = TypeChecker.fromUrl('$_annotationsUrl#DtoDefault');
const _ignoreChecker = TypeChecker.fromUrl('$_annotationsUrl#DtoIgnore');
const _requiredChecker = TypeChecker.fromUrl('$_annotationsUrl#DtoRequired');
const _dtoLogChecker = TypeChecker.fromUrl('$_annotationsUrl#DtoLog');

/// Generator for @DtoLog annotation
///
/// Generates top-level functions (like json_serializable):
/// ```dart
/// // In your class:
/// factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
/// Map<String, dynamic> toJson() => _$UserToJson(this);
///
/// // Generated:
/// User _$UserFromJson(Map<String, dynamic> json) {
///   return DtoLogger.parse(json, () => User(
///     id: json.safeInt('id'),
///     name: json.safeString('name'),
///   ), 'User');
/// }
/// ```
class DtoLogGenerator extends GeneratorForAnnotation<DtoLog> {
  @override
  TypeChecker get typeChecker => _dtoLogChecker;

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@DtoLog can only be applied to classes.',
        element: element,
      );
    }
    if (element.typeParameters.isNotEmpty) {
      throw InvalidGenerationSourceError(
        '@DtoLog does not support generic classes.',
        element: element,
      );
    }

    final className = element.displayName;
    final generateFromJson = annotation.read('generateFromJson').boolValue;
    final generateToJson = annotation.read('generateToJson').boolValue;
    final generateCopyWith = annotation.read('generateCopyWith').boolValue;
    final generateEquality = annotation.read('generateEquality').boolValue;
    final enableLogging = annotation.read('enableLogging').boolValue;

    final fields = _getFields(element);
    final buffer = StringBuffer();

    if (generateFromJson) {
      buffer.writeln(_generateFromJson(element, fields, enableLogging));
    }
    if (generateToJson) {
      final toJsonFields = fields.where((f) => !f.ignoreToJson).toList();
      buffer.writeln(_generateToJson(className, toJsonFields));
    }
    if (generateCopyWith) {
      buffer.writeln(_generateCopyWith(element, fields));
    }
    if (generateEquality) {
      buffer.writeln(_generateEquality(className, fields));
    }

    return buffer.toString();
  }

  // Field discovery

  List<_FieldInfo> _getFields(ClassElement classElement) {
    final library = classElement.library;
    final fields = <_FieldInfo>[];

    for (final field in classElement.fields) {
      // Fields induced by a getter or setter point back to that accessor
      if (field.isStatic || field.nonSynthetic is PropertyAccessorElement) {
        continue;
      }

      var ignoreFromJson = false;
      var ignoreToJson = false;
      final ignore = _ignoreChecker.firstAnnotationOfExact(field);
      if (ignore != null) {
        final reader = ConstantReader(ignore);
        ignoreFromJson = reader.read('fromJson').boolValue;
        ignoreToJson = reader.read('toJson').boolValue;
      }

      var jsonKey = field.displayName;
      ConstantReader? defaultReader;
      var required = false;
      String? requiredMessage;

      final key = _keyChecker.firstAnnotationOfExact(field);
      if (key != null) {
        final reader = ConstantReader(key);
        final name = reader.peek('name');
        if (name != null && name.isString) jsonKey = name.stringValue;
        final defaultValue = reader.peek('defaultValue');
        if (defaultValue != null && !defaultValue.isNull) {
          defaultReader = defaultValue;
        }
        required = reader.read('required').boolValue;
      }

      final nullDefault = _defaultChecker.firstAnnotationOfExact(field);
      if (nullDefault != null) {
        final value = ConstantReader(nullDefault).read('value');
        if (!value.isNull) defaultReader = value;
      }

      final requiredAnnotation = _requiredChecker.firstAnnotationOfExact(field);
      if (requiredAnnotation != null) {
        required = true;
        final message = ConstantReader(requiredAnnotation).peek('message');
        if (message != null && message.isString) {
          requiredMessage = message.stringValue;
        }
      }

      String? defaultSource;
      if (defaultReader != null) {
        final valueType = defaultReader.objectValue.type;
        final intForDouble = defaultReader.isInt && field.type.isDartCoreDouble;
        if (valueType != null &&
            !intForDouble &&
            !library.typeSystem.isAssignableTo(valueType, field.type)) {
          throw InvalidGenerationSourceError(
            'Default value of type '
            '${valueType.getDisplayString()} can\'t be '
            'assigned to ${field.type.getDisplayString()} '
            '${field.displayName}.',
            element: field,
          );
        }
        defaultSource =
            intForDouble
                ? '${defaultReader.intValue}.0'
                : _constantSource(defaultReader, field, inConst: false);
      }

      fields.add(
        _FieldInfo(
          element: field,
          name: field.displayName,
          jsonKey: jsonKey,
          type: field.type,
          isNullable: _isNullable(field.type),
          defaultValue: defaultSource,
          required: required,
          requiredMessage: requiredMessage,
          ignoreFromJson: ignoreFromJson,
          ignoreToJson: ignoreToJson,
        ),
      );
    }

    return fields;
  }

  /// Dart source for a constant annotation value.
  String _constantSource(
    ConstantReader reader,
    Element context, {
    required bool inConst,
  }) {
    if (reader.isNull) return 'null';
    if (reader.isString) return _stringLiteral(reader.stringValue);
    if (reader.isBool) return reader.boolValue.toString();
    if (reader.isInt) return reader.intValue.toString();
    if (reader.isDouble) {
      final value = reader.doubleValue;
      if (value.isNaN) return 'double.nan';
      if (value.isInfinite) {
        return value > 0 ? 'double.infinity' : 'double.negativeInfinity';
      }
      return value.toString();
    }
    final prefix = inConst ? '' : 'const ';
    if (reader.isList) {
      final items = reader.listValue
          .map(
            (e) => _constantSource(ConstantReader(e), context, inConst: true),
          )
          .join(', ');
      return '$prefix[$items]';
    }
    if (reader.isMap) {
      final entries = reader.mapValue.entries
          .map(
            (e) =>
                '${_constantSource(ConstantReader(e.key), context, inConst: true)}: '
                '${_constantSource(ConstantReader(e.value), context, inConst: true)}',
          )
          .join(', ');
      return '$prefix{$entries}';
    }
    final enumName = _enumConstantName(reader.objectValue);
    if (enumName != null) return enumName;
    throw InvalidGenerationSourceError(
      'Unsupported default value. Use a String, number, bool, enum value, '
      'or a const List/Map of those.',
      element: context,
    );
  }

  String? _enumConstantName(DartObject value) {
    final type = value.type;
    if (type is! InterfaceType || type.element is! EnumElement) return null;
    final name =
        value.variable?.name ??
        value.getField('_name')?.toStringValue() ??
        value.getField('name')?.toStringValue();
    return name == null ? null : '${type.element.displayName}.$name';
  }

  // Type helpers

  bool _isNullable(DartType type) =>
      type is DynamicType ||
      type.nullabilitySuffix == NullabilitySuffix.question;

  /// The type without its own `?` (type arguments keep theirs).
  String _baseName(DartType type) {
    final name = type.getDisplayString();
    return type.nullabilitySuffix == NullabilitySuffix.question &&
            name.endsWith('?')
        ? name.substring(0, name.length - 1)
        : name;
  }

  bool _isDateTime(DartType type) =>
      type is InterfaceType &&
      type.element.displayName == 'DateTime' &&
      (_libraryOf(type.element)?.isDartCore ?? false);

  bool _isEnum(DartType type) =>
      type is InterfaceType && type.element is EnumElement;

  /// A user class (not SDK, not enum) that is expected to have fromJson.
  bool _isNested(DartType type) {
    if (type is! InterfaceType || type.element is EnumElement) return false;
    final library = _libraryOf(type.element);
    return library != null && !library.isInSdk;
  }

  bool _isStringDynamicMap(DartType type) =>
      type is InterfaceType &&
      type.isDartCoreMap &&
      type.typeArguments.length == 2 &&
      type.typeArguments[0].isDartCoreString &&
      type.typeArguments[1] is DynamicType;

  LibraryElement? _libraryOf(Element element) => element.library;

  DartType? _listElementType(DartType type) =>
      type is InterfaceType &&
              type.isDartCoreList &&
              type.typeArguments.isNotEmpty
          ? type.typeArguments.first
          : null;

  void _requireFromJson(DartType type, _FieldInfo field) {
    final element = (type as InterfaceType).element;
    final hasFromJson =
        element.getNamedConstructor('fromJson') != null ||
        (element.getMethod('fromJson')?.isStatic ?? false);
    if (!hasFromJson) {
      throw InvalidGenerationSourceError(
        '${element.displayName} is used by ${field.name} but has no fromJson. '
        'Add: factory ${element.displayName}.fromJson(Map<String, dynamic> json) '
        '=> _\$${element.displayName}FromJson(json);',
        element: field.element,
      );
    }
  }

  // fromJson - top-level _$ClassNameFromJson function

  String _generateFromJson(
    ClassElement classElement,
    List<_FieldInfo> fields,
    bool enableLogging,
  ) {
    final className = classElement.displayName;
    final byName = {
      for (final f in fields)
        if (!f.ignoreFromJson) f.name: f,
    };
    final arguments = _constructorArguments(
      classElement,
      byName,
      (field, _) => _readExpression(field),
      purpose: 'fromJson',
    ).map((a) => a.source);

    final buffer = StringBuffer();
    buffer.writeln(
      '$className _\$${className}FromJson(Map<String, dynamic> json) {',
    );
    if (enableLogging) {
      buffer.writeln('  return DtoLogger.parse(json, () => $className(');
    } else {
      buffer.writeln('  return $className(');
    }
    for (final argument in arguments) {
      buffer.writeln('    $argument,');
    }
    if (enableLogging) {
      buffer.writeln("  ), '$className');");
    } else {
      buffer.writeln('  );');
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  /// Maps the unnamed constructor's parameters to fields.
  /// Positional parameters keep their order; named ones use `name:`.
  List<_Argument> _constructorArguments(
    ClassElement classElement,
    Map<String, _FieldInfo> fieldsByName,
    String Function(_FieldInfo field, String parameterName) valueFor, {
    required String purpose,
  }) {
    final constructor = classElement.unnamedConstructor;
    if (constructor == null) {
      throw InvalidGenerationSourceError(
        '${classElement.displayName} needs an unnamed constructor for $purpose.',
        element: classElement,
      );
    }

    final arguments = <_Argument>[];
    var skippedPositional = false;
    for (final parameter in constructor.formalParameters) {
      // A named `this._nick` is called `nick`; look up the field it sets
      final fieldName =
          parameter is FieldFormalParameterElement
              ? parameter.field?.displayName ?? parameter.displayName
              : parameter.displayName;
      final field = fieldsByName[fieldName];
      if (field == null) {
        if (parameter.isRequiredPositional || parameter.isRequiredNamed) {
          throw InvalidGenerationSourceError(
            'Constructor parameter "${parameter.displayName}" of '
            '${classElement.displayName} is required, but there is no field '
            '"$fieldName" available for $purpose '
            '(is it @DtoIgnore\'d?).',
            element: parameter,
          );
        }
        if (parameter.isPositional) skippedPositional = true;
        continue;
      }
      // copyWith parameters are named, and named parameters can't be private
      final name = parameter.displayName.replaceFirst(RegExp(r'^_+'), '');
      if (parameter.isNamed) {
        arguments.add(
          _Argument(
            '${parameter.displayName}: ${valueFor(field, name)}',
            field,
            name,
          ),
        );
      } else if (!skippedPositional) {
        // Can't pass a positional argument after skipping an earlier one
        arguments.add(_Argument(valueFor(field, name), field, name));
      }
    }
    return arguments;
  }

  String _readExpression(_FieldInfo field) {
    final key = _stringLiteral(field.jsonKey);
    final type = field.type;
    if (type is DynamicType) return 'json.safeValue($key)';

    final String read;
    final elementType = _listElementType(type);
    if (type.isDartCoreInt) {
      read = 'json.safeInt($key)';
    } else if (type.isDartCoreDouble) {
      read = 'json.safeDouble($key)';
    } else if (type.isDartCoreBool) {
      read = 'json.safeBool($key)';
    } else if (type.isDartCoreString) {
      read = 'json.safeString($key)';
    } else if (_isDateTime(type)) {
      read = 'json.safeDateTime($key)';
    } else if (_isEnum(type)) {
      read = 'json.safeEnum($key, ${_baseName(type)}.values)';
    } else if (_isNested(type)) {
      _requireFromJson(type, field);
      read = 'json.safeObject($key, ${_baseName(type)}.fromJson)';
    } else if (elementType != null) {
      if (_isNested(elementType)) {
        _requireFromJson(elementType, field);
        read = 'json.safeList($key, ${_baseName(elementType)}.fromJson)';
      } else if (_isEnum(elementType)) {
        read = 'json.safeEnumList($key, ${_baseName(elementType)}.values)';
      } else {
        final itemType = elementType.getDisplayString();
        read = 'json.safeListOf<$itemType>($key)';
      }
    } else if (_isStringDynamicMap(type)) {
      read = 'json.safeMap($key)';
    } else {
      read = 'json.safeCast<${_baseName(type)}>($key)';
    }

    final defaultValue = field.defaultValue;
    if (defaultValue != null) {
      // A default means absence is expected: the *Or readers don't log it
      final orMethod = _orMethod(type);
      if (orMethod != null) return 'json.$orMethod($key, $defaultValue)';
      if (_isEnum(type)) {
        return 'json.safeEnumOr($key, ${_baseName(type)}.values, $defaultValue)';
      }
      // safeValue records the access without logging null/missing
      return 'json.safeValue($key) == null ? $defaultValue : $read ?? $defaultValue';
    }
    if (field.required || !field.isNullable) {
      final message = _stringLiteral(
        field.requiredMessage ??
            'Required field "${field.jsonKey}" is missing or invalid',
      );
      return '$read ?? (throw FormatException($message))';
    }
    return read;
  }

  String? _orMethod(DartType type) {
    if (type.isDartCoreInt) return 'safeIntOr';
    if (type.isDartCoreDouble) return 'safeDoubleOr';
    if (type.isDartCoreBool) return 'safeBoolOr';
    if (type.isDartCoreString) return 'safeStringOr';
    return null;
  }

  // toJson - top-level _$ClassNameToJson function

  String _generateToJson(String className, List<_FieldInfo> fields) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Map<String, dynamic> _\$${className}ToJson('
      '$className instance) => <String, dynamic>{',
    );
    for (final field in fields) {
      buffer.writeln(
        '      ${_stringLiteral(field.jsonKey)}: '
        '${_writeExpression(field)},',
      );
    }
    buffer.writeln('    };');
    return buffer.toString();
  }

  /// JSON-safe value: DateTime → ISO string, enum → name, object → toJson().
  String _writeExpression(_FieldInfo field) {
    final value = 'instance.${field.name}';
    final access = field.isNullable ? '?.' : '.';
    final type = field.type;
    if (_isDateTime(type)) return '$value${access}toIso8601String()';
    if (_isEnum(type)) return '$value${access}name';
    if (_isNested(type)) return '$value${access}toJson()';

    final elementType = _listElementType(type);
    if (elementType != null) {
      final itemAccess = _isNullable(elementType) ? '?.' : '.';
      String? mapItem;
      if (_isDateTime(elementType)) mapItem = 'toIso8601String()';
      if (_isEnum(elementType)) mapItem = 'name';
      if (_isNested(elementType)) mapItem = 'toJson()';
      if (mapItem != null) {
        return '$value${access}map((e) => e$itemAccess$mapItem).toList()';
      }
    }
    return value;
  }

  // copyWith - extension (called on instances)

  String _generateCopyWith(ClassElement classElement, List<_FieldInfo> fields) {
    final className = classElement.displayName;
    final byName = {for (final f in fields) f.name: f};
    final arguments = _constructorArguments(
      classElement,
      byName,
      (field, name) => '$name ?? this.${field.name}',
      purpose: 'copyWith',
    );
    final buffer = StringBuffer();
    buffer.writeln('extension \$${className}CopyWith on $className {');
    if (arguments.isEmpty) {
      buffer.writeln('  $className copyWith() => $className();');
    } else {
      buffer.writeln('  $className copyWith({');
      for (final argument in arguments) {
        final field = argument.field;
        final typeName = field.type.getDisplayString();
        final paramType = field.isNullable ? typeName : '$typeName?';
        buffer.writeln('    $paramType ${argument.name},');
      }
      buffer.writeln('  }) {');
      buffer.writeln('    return $className(');
      for (final argument in arguments) {
        buffer.writeln('      ${argument.source},');
      }
      buffer.writeln('    );');
      buffer.writeln('  }');
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  // equality - extension. Extensions can't override ==, so wire it:
  //   bool operator ==(Object other) => equals(other);
  //   int get hashCode => hashValue;

  String _generateEquality(String className, List<_FieldInfo> fields) {
    final names = fields.map((f) => f.name).toSet();
    final other = [
      'other',
      'that',
      'o',
    ].firstWhere((n) => !names.contains(n), orElse: () => 'otherObject');

    final buffer = StringBuffer();
    buffer.writeln('extension \$${className}Equality on $className {');
    buffer.writeln('  bool equals(Object $other) {');
    buffer.writeln('    if (identical(this, $other)) return true;');
    buffer.write('    return $other is $className');
    for (final field in fields) {
      buffer.write('\n        && $other.${field.name} == ${field.name}');
    }
    buffer.writeln(';');
    buffer.writeln('  }');
    buffer.writeln();

    buffer.write('  int get hashValue => ');
    if (fields.isEmpty) {
      buffer.writeln('0;');
    } else if (fields.length == 1) {
      buffer.writeln('${fields[0].name}.hashCode;');
    } else if (fields.length <= 20) {
      buffer.writeln('Object.hash(${fields.map((f) => f.name).join(', ')});');
    } else {
      // Object.hash accepts at most 20 values
      buffer.writeln(
        'Object.hashAll([${fields.map((f) => f.name).join(', ')}]);',
      );
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  /// Single-quoted Dart literal with quotes, `$` and `\` escaped.
  static String _stringLiteral(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
    return "'$escaped'";
  }
}

/// One constructor argument and the field it comes from.
class _Argument {
  final String source;
  final _FieldInfo field;

  /// Public parameter name, used for copyWith
  final String name;

  _Argument(this.source, this.field, this.name);
}

class _FieldInfo {
  final FieldElement element;
  final String name;
  final String jsonKey;
  final DartType type;
  final bool isNullable;
  final String? defaultValue;
  final bool required;
  final String? requiredMessage;
  final bool ignoreFromJson;
  final bool ignoreToJson;

  _FieldInfo({
    required this.element,
    required this.name,
    required this.jsonKey,
    required this.type,
    required this.isNullable,
    this.defaultValue,
    this.required = false,
    this.requiredMessage,
    this.ignoreFromJson = false,
    this.ignoreToJson = false,
  });
}
