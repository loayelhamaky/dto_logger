#!/usr/bin/env dart

// ignore_for_file: avoid_print
/// CLI tool to generate Dart classes from JSON
///
/// Usage:
///   dart run dto_logger:generate
///   dart run dto_logger:generate --input file.json --output lib/models/
///   dart run dto_logger:generate --help
library;

import 'dart:convert';
import 'dart:io';

import 'package:dto_logger/dto_logger.dart';

void main(List<String> args) async {
  final parser = ArgParser();

  try {
    final result = parser.parse(args);

    if (result.showHelp) {
      _printHelp();
      return;
    }

    if (result.inputFile != null) {
      // Non-interactive mode
      await _generateFromFile(result);
    } else {
      // Interactive mode
      await _interactiveMode();
    }
  } catch (e) {
    _printError('Error: $e');
    exit(1);
  }
}

/// Simple argument parser (no external dependencies)
class ArgParser {
  ArgParseResult parse(List<String> args) {
    String? inputFile;
    String? outputPath;
    String? className;
    bool showHelp = false;
    bool fromJson = true;
    bool toJson = true;
    bool copyWith = false;
    bool logging = true;
    bool allNullable = true;
    bool equality = false;

    for (int i = 0; i < args.length; i++) {
      final arg = args[i];

      if (arg == '--help' || arg == '-h') {
        showHelp = true;
      } else if (arg == '--input' || arg == '-i') {
        if (i + 1 < args.length) inputFile = args[++i];
      } else if (arg == '--output' || arg == '-o') {
        if (i + 1 < args.length) outputPath = args[++i];
      } else if (arg == '--class' || arg == '-c') {
        if (i + 1 < args.length) className = args[++i];
      } else if (arg == '--no-from-json') {
        fromJson = false;
      } else if (arg == '--no-to-json') {
        toJson = false;
      } else if (arg == '--copy-with') {
        copyWith = true;
      } else if (arg == '--no-logging') {
        logging = false;
      } else if (arg == '--required') {
        allNullable = false;
      } else if (arg == '--equality') {
        equality = true;
      }
    }

    return ArgParseResult(
      inputFile: inputFile,
      outputPath: outputPath,
      className: className,
      showHelp: showHelp,
      fromJson: fromJson,
      toJson: toJson,
      copyWith: copyWith,
      logging: logging,
      allNullable: allNullable,
      equality: equality,
    );
  }
}

class ArgParseResult {
  final String? inputFile;
  final String? outputPath;
  final String? className;
  final bool showHelp;
  final bool fromJson;
  final bool toJson;
  final bool copyWith;
  final bool logging;
  final bool allNullable;
  final bool equality;

  ArgParseResult({
    this.inputFile,
    this.outputPath,
    this.className,
    this.showHelp = false,
    this.fromJson = true,
    this.toJson = true,
    this.copyWith = false,
    this.logging = true,
    this.allNullable = true,
    this.equality = false,
  });
}

Future<void> _generateFromFile(ArgParseResult args) async {
  final file = File(args.inputFile!);
  if (!file.existsSync()) {
    throw Exception('File not found: ${args.inputFile}');
  }

  final content = await file.readAsString();
  final samples = _parseJson(content);

  final className = args.className ?? _inferClassName(args.inputFile!);
  final outputPath = _normalizeDir(args.outputPath ?? 'lib/models/');

  final options = GeneratorOptions(
    generateFromJson: args.fromJson,
    generateToJson: args.toJson,
    generateCopyWith: args.copyWith,
    generateEquality: args.equality,
    addLogging: args.logging,
    allNullable: args.allNullable,
  );

  final generator = JsonToDartGenerator(options: options);
  final result = generator.generateFromSamples(samples, className);

  final dir = Directory(outputPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final fileContent = _generateFileContent(result, options);

  // Named after the sanitized class name
  final fileName = CaseConverter.camelToSnake(result.name);
  final outputFile = File('$outputPath$fileName.dart');
  await outputFile.writeAsString(fileContent);

  _printSuccess('Generated: ${outputFile.path}');

  if (result.warnings.isNotEmpty) {
    _printWarning('Warnings:');
    for (final warning in result.warnings) {
      _printWarning('  ⚠ $warning');
    }
  }
}

Future<void> _interactiveMode() async {
  _printHeader();

  _printPrompt('Paste your JSON (reading stops when the brackets close):\n');
  final jsonInput = _readMultilineInput();

  if (jsonInput.trim().isEmpty) {
    throw Exception('No JSON provided');
  }

  final samples = _parseJson(jsonInput);

  _printPrompt('Class name [Response]: ');
  final classNameInput = stdin.readLineSync()?.trim();
  final className =
      classNameInput?.isNotEmpty == true ? classNameInput! : 'Response';

  _printPrompt('Generate fromJson? [Y/n]: ');
  final fromJson = _readYesNo(defaultYes: true);

  _printPrompt('Generate toJson? [Y/n]: ');
  final toJson = _readYesNo(defaultYes: true);

  _printPrompt('Generate copyWith? [y/N]: ');
  final copyWith = _readYesNo(defaultYes: false);

  _printPrompt('Generate equality? [y/N]: ');
  final equality = _readYesNo(defaultYes: false);

  _printPrompt('Add logging? [Y/n]: ');
  final logging = _readYesNo(defaultYes: true);

  _printPrompt('Make all fields nullable? [Y/n]: ');
  final allNullable = _readYesNo(defaultYes: true);

  print('');
  _printInfo('Generating class, one moment...');

  final options = GeneratorOptions(
    generateFromJson: fromJson,
    generateToJson: toJson,
    generateCopyWith: copyWith,
    generateEquality: equality,
    addLogging: logging,
    allNullable: allNullable,
  );

  final generator = JsonToDartGenerator(options: options);
  final result = generator.generateFromSamples(samples, className);

  _printHeader();
  _printInfo('Preview:');
  print('');
  print(_generateFileContent(result, options));
  print('');

  final fileName = CaseConverter.camelToSnake(result.name);
  const defaultPath = 'lib/models/';
  print('');
  _printPrompt('Folder to save $fileName.dart [$defaultPath]: ');
  final pathInput = stdin.readLineSync()?.trim() ?? '';
  final outputDir = _normalizeDir(pathInput.isEmpty ? defaultPath : pathInput);

  final dir = Directory(outputDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final fileContent = _generateFileContent(result, options);
  final outputFile = File('$outputDir$fileName.dart');
  await outputFile.writeAsString(fileContent);

  _printSuccess('Generated: ${outputFile.path}');

  if (result.nestedClasses.isNotEmpty) {
    _printInfo(
        '  Also generated ${result.nestedClasses.length} nested class(es)');
  }

  if (result.warnings.isNotEmpty) {
    print('');
    _printWarning('Warnings:');
    for (final warning in result.warnings) {
      _printWarning('  ⚠ $warning');
    }
  }
}

String _generateFileContent(GeneratedClass result, GeneratorOptions options) {
  final buffer = StringBuffer();

  buffer.writeln('// Generated by dto_logger');
  buffer.writeln('// Do not modify by hand');
  buffer.writeln('');

  // Imports: fromJson uses the safe* extensions even without logging
  if (options.generateFromJson && options.dtoLoggerImport != null) {
    buffer.writeln("import '${options.dtoLoggerImport}';");
    buffer.writeln('');
  }

  buffer.write(result.fullCode);

  return buffer.toString();
}

/// Parse JSON string, auto-fixing Dart map syntax (single quotes, trailing commas).
/// Returns one sample for an object, or every item for an array of objects.
List<Map<String, dynamic>> _parseJson(String input) {
  dynamic decoded;

  // Try as-is first (valid JSON)
  try {
    decoded = jsonDecode(input);
  } catch (_) {
    // Auto-fix: single quotes → double quotes, strip trailing commas
    final fixed = input
        .replaceAll("'", '"')
        .replaceAllMapped(RegExp(r',(\s*[}\]])'), (m) => m.group(1)!);
    try {
      decoded = jsonDecode(fixed);
      _printInfo('  (auto-converted single quotes to double quotes)');
    } catch (_) {
      throw Exception(
        'Could not parse JSON.\n'
        '  Tip: Use double quotes ("key": "value") and no trailing commas.',
      );
    }
  }

  if (decoded is Map<String, dynamic>) return [decoded];

  if (decoded is List) {
    final objects = decoded.whereType<Map<String, dynamic>>().toList();
    if (objects.isEmpty || objects.length != decoded.length) {
      throw Exception(
        'JSON is an array, but its items are not all objects {...}.\n'
        '  Tip: Wrap it like {"items": [...]}',
      );
    }
    _printInfo('  (array of ${objects.length} object(s): '
        'generating the class for one item)');
    return objects;
  }

  throw Exception('Expected a JSON object {...}, got ${decoded.runtimeType}');
}

/// "out" → "out/" so the file lands inside the folder, not next to it.
String _normalizeDir(String path) {
  if (path.endsWith('/') || path.endsWith(Platform.pathSeparator)) return path;
  return '$path/';
}

String _inferClassName(String filePath) {
  final fileName = filePath.split('/').last.split('\\').last;
  final name = fileName.replaceAll('.json', '').replaceAll('.', '_');
  return CaseConverter.snakeToPascal(name);
}

/// Reads pasted JSON until its brackets balance, so blank lines inside a
/// pretty-printed paste don't cut it off. An empty line before any JSON,
/// or end of input, also finishes.
String _readMultilineInput() {
  final lines = <String>[];
  var depth = 0;
  var started = false;
  var inString = false;
  var escaped = false;

  while (true) {
    final line = stdin.readLineSync();
    if (line == null) break;
    if (line.trim().isEmpty && !started) break;
    lines.add(line);

    for (final char in line.split('')) {
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }
      if (char == '"') {
        inString = true;
      } else if (char == '{' || char == '[') {
        depth++;
        started = true;
      } else if (char == '}' || char == ']') {
        depth--;
      }
    }
    if (started && depth <= 0) break;
  }

  return lines.join('\n');
}

bool _readYesNo({required bool defaultYes}) {
  final input = stdin.readLineSync()?.trim().toLowerCase();
  if (input == null || input.isEmpty) return defaultYes;
  return input == 'y' || input == 'yes';
}

void _printHeader() {
  print('');
  print(
      '${AnsiColors.cyan}╔════════════════════════════════════════╗${AnsiColors.reset}');
  print(
      '${AnsiColors.cyan}║${AnsiColors.reset}     ${AnsiColors.bold}DTO Logger - Class Generator${AnsiColors.reset}     ${AnsiColors.cyan}║${AnsiColors.reset}');
  print(
      '${AnsiColors.cyan}╚════════════════════════════════════════╝${AnsiColors.reset}');
  print('');
}

void _printPrompt(String message) {
  stdout.write('${AnsiColors.cyan}? ${AnsiColors.reset}$message');
}

void _printSuccess(String message) {
  print('${AnsiColors.green}$message${AnsiColors.reset}');
}

void _printError(String message) {
  print('${AnsiColors.red}$message${AnsiColors.reset}');
}

void _printWarning(String message) {
  print('${AnsiColors.yellow}$message${AnsiColors.reset}');
}

void _printInfo(String message) {
  print('${AnsiColors.dim}$message${AnsiColors.reset}');
}

void _printHelp() {
  print('''
${AnsiColors.bold}DTO Logger - Dart Class Generator${AnsiColors.reset}

${AnsiColors.cyan}USAGE:${AnsiColors.reset}
  dart run dto_logger:generate [options]

${AnsiColors.cyan}OPTIONS:${AnsiColors.reset}
  -h, --help            Show this help message
  -i, --input <file>    Input JSON file
  -o, --output <dir>    Output directory (default: lib/models/)
  -c, --class <name>    Class name (default: inferred from file name)
  
  --no-from-json        Don't generate fromJson method
  --no-to-json          Don't generate toJson method
  --copy-with           Generate copyWith method
  --equality            Generate equality (== and hashCode)
  --no-logging          Don't add logging to fromJson
  --required            Non-nullable fields; fromJson throws FormatException
                        when one is missing or invalid

${AnsiColors.cyan}EXAMPLES:${AnsiColors.reset}
  ${AnsiColors.dim}# Interactive mode${AnsiColors.reset}
  dart run dto_logger:generate
  
  ${AnsiColors.dim}# From file${AnsiColors.reset}
  dart run dto_logger:generate -i response.json -c UserResponse
  
  ${AnsiColors.dim}# With options${AnsiColors.reset}
  dart run dto_logger:generate -i data.json --copy-with --no-logging

${AnsiColors.cyan}FEATURES:${AnsiColors.reset}
  • Automatic snake_case → camelCase conversion
  • Type-safe parsing with coercion
  • Nested objects auto-generated
  • Detailed validation logging
  • Null safety handling
''');
}
