#!/usr/bin/env dart
// ignore_for_file: avoid_print
/// CLI tool to inject .logged() into existing fromJson methods
///
/// Usage:
///   dart run dto_logger:inject
///   dart run dto_logger:inject --dir lib/models/
///   dart run dto_logger:inject --dry-run
///   dart run dto_logger:inject --help

import 'dart:io';

import 'package:dto_logger/dto_logger.dart';

void main(List<String> args) {
  String? directory;
  bool dryRun = false;
  bool showHelp = false;

  // Parse args
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--help' || arg == '-h') {
      showHelp = true;
    } else if (arg == '--dir' || arg == '-d') {
      if (i + 1 < args.length) directory = args[++i];
    } else if (arg == '--dry-run') {
      dryRun = true;
    }
  }

  if (showHelp) {
    _printHelp();
    return;
  }

  final targetDir = directory ?? 'lib/';

  _printHeader();

  if (dryRun) {
    print('${AnsiColors.yellow}DRY RUN — no files will be modified${AnsiColors.reset}\n');
  }

  final dir = Directory(targetDir);
  if (!dir.existsSync()) {
    print('${AnsiColors.red}✗ Directory not found: $targetDir${AnsiColors.reset}');
    exit(1);
  }

  // Collect stats
  int filesScanned = 0;
  int fromJsonFound = 0;
  int injected = 0;
  int alreadyLogged = 0;
  int inComments = 0;
  int unsupported = 0;
  int importsAdded = 0;
  final modifiedFiles = <String>[];

  // Find all .dart files
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) =>
          f.path.endsWith('.dart') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.contains('dto_logger/lib/') &&
          !f.path.contains('dto_logger/bin/'))
      .toList();

  filesScanned = files.length;
  print('Scanning $filesScanned Dart files in $targetDir...\n');

  for (final file in files) {
    var content = file.readAsStringSync();

    // Find all fromJson methods
    final fromJsonPattern = RegExp(
      r'(?:factory\s+\w+\.fromJson|\w+\.fromJson|(?:static\s+)?\w+\s+fromJson)\s*\(\s*Map\s*<\s*String\s*,\s*dynamic\s*>\s+(\w+)\s*\)',
    );

    final matches = fromJsonPattern.allMatches(content).toList();
    if (matches.isEmpty) continue;

    fromJsonFound += matches.length;

    bool fileModified = false;

    // Process matches from bottom to top so offsets don't shift
    for (final match in matches.reversed) {
      // Skip matches inside comments
      if (_isInsideComment(content, match.start)) {
        inComments++;
        continue;
      }

      final paramName = match.group(1)!;

      // Check if THIS specific fromJson already has logging
      if (_methodAlreadyLogged(content, match)) {
        alreadyLogged++;
        continue;
      }

      final afterMatch = content.substring(match.end);

      // Find the next non-whitespace after the closing paren
      final trimmed = afterMatch.trimLeft();

      if (trimmed.startsWith('{')) {
        // Body-style: inject after {
        final braceOffset = match.end + afterMatch.indexOf('{');
        final afterBrace = content.substring(braceOffset + 1);

        // Detect indentation from next non-empty line
        final indent = _detectIndent(afterBrace);

        final injection = '\n$indent$paramName = $paramName.logged();';
        content = content.substring(0, braceOffset + 1) +
            injection +
            content.substring(braceOffset + 1);

        injected++;
        fileModified = true;
      } else if (trimmed.startsWith('=>')) {
        // Arrow-style: convert to body
        final arrowOffset = match.end + afterMatch.indexOf('=>');
        final afterArrow = content.substring(arrowOffset + 2);

        // Find terminating ; at depth 0
        final semiIndex = _findTerminatingSemicolon(afterArrow);
        if (semiIndex == -1) {
          unsupported++;
          continue;
        }

        final expression = afterArrow.substring(0, semiIndex).trim();

        // Detect indentation from the line containing the factory
        final lineStart = content.lastIndexOf('\n', match.start);
        final lineContent = content.substring(lineStart + 1, match.start);
        final baseIndent = _extractLeadingWhitespace(lineContent);
        final bodyIndent = '$baseIndent  ';

        final replacement = ' {\n'
            '$bodyIndent$paramName = $paramName.logged();\n'
            '${bodyIndent}return $expression;\n'
            '$baseIndent}';

        content = content.substring(0, arrowOffset) +
            replacement +
            content.substring(arrowOffset + 2 + semiIndex + 1);

        injected++;
        fileModified = true;
      } else {
        // e.g. a constructor with an initializer list (`: id = json['id']`)
        unsupported++;
      }
    }

    // Add import if needed
    if (fileModified && !_hasImport(content)) {
      content = _addImport(content);
      importsAdded++;
    }

    if (fileModified) {
      modifiedFiles.add(file.path);
      if (!dryRun) {
        file.writeAsStringSync(content);
      }
    }
  }

  // Summary
  print('');
  print('${AnsiColors.cyan}╔════════════════════════════════════════╗${AnsiColors.reset}');
  print('${AnsiColors.cyan}║${AnsiColors.reset}     ${AnsiColors.bold}DTO Logger — Inject ${dryRun ? "Preview" : "Complete"}${AnsiColors.reset}     ${AnsiColors.cyan}║${AnsiColors.reset}');
  print('${AnsiColors.cyan}╚════════════════════════════════════════╝${AnsiColors.reset}');
  print('');
  print('${AnsiColors.dim}Files scanned:${AnsiColors.reset}    $filesScanned');
  print('${AnsiColors.dim}fromJson found:${AnsiColors.reset}   $fromJsonFound');
  print('${AnsiColors.green}✓ Injected:${AnsiColors.reset}       $injected');
  if (alreadyLogged > 0) {
    print('${AnsiColors.yellow}⚠ Skipped:${AnsiColors.reset}        $alreadyLogged (already using dto_logger)');
  }
  if (inComments > 0) {
    print('${AnsiColors.yellow}⚠ Skipped:${AnsiColors.reset}        $inComments (inside comments)');
  }
  if (unsupported > 0) {
    print('${AnsiColors.yellow}⚠ Skipped:${AnsiColors.reset}        $unsupported (unsupported shape, add .logged() by hand)');
  }
  if (importsAdded > 0) {
    print('${AnsiColors.cyan}+ Imports added:${AnsiColors.reset}  $importsAdded');
  }
  print('');

  if (modifiedFiles.isNotEmpty) {
    print('${AnsiColors.bold}${dryRun ? "Would modify" : "Modified"}:${AnsiColors.reset}');
    for (final f in modifiedFiles) {
      print('  ${AnsiColors.green}✓${AnsiColors.reset} $f');
    }
    print('');
  }

  if (injected == 0 && fromJsonFound > 0 && alreadyLogged == fromJsonFound) {
    print('${AnsiColors.dim}All fromJson methods already have logging.${AnsiColors.reset}\n');
  } else if (fromJsonFound == 0) {
    print('${AnsiColors.dim}No fromJson methods found in $targetDir${AnsiColors.reset}\n');
  }
}

/// Check if a match position is inside a line comment or block comment.
bool _isInsideComment(String content, int position) {
  // Check if the line containing this position starts with //
  final lineStart = content.lastIndexOf('\n', position);
  final lineContent = content.substring(lineStart + 1, position).trimLeft();
  if (lineContent.startsWith('//')) return true;

  // Check if inside a block comment /* ... */
  int searchFrom = 0;
  while (searchFrom < position) {
    final openIdx = content.indexOf('/*', searchFrom);
    if (openIdx == -1 || openIdx > position) break;
    final closeIdx = content.indexOf('*/', openIdx + 2);
    if (closeIdx == -1 || closeIdx > position) return true;
    searchFrom = closeIdx + 2;
  }
  return false;
}

/// Check if a specific fromJson method already has logging injected.
/// Looks at the method body (from match end to its closing brace/semicolon).
bool _methodAlreadyLogged(String content, RegExpMatch match) {
  final after = content.substring(match.end);
  final trimmed = after.trimLeft();

  // Determine method body boundary
  String body;
  if (trimmed.startsWith('{')) {
    final braceStart = match.end + after.indexOf('{');
    // Find matching closing brace
    int depth = 0;
    int end = braceStart;
    for (int i = braceStart; i < content.length; i++) {
      if (content[i] == '{') depth++;
      if (content[i] == '}') depth--;
      if (depth == 0) {
        end = i;
        break;
      }
    }
    body = content.substring(braceStart, end);
  } else if (trimmed.startsWith('=>')) {
    final arrowStart = match.end + after.indexOf('=>');
    final semiIndex = _findTerminatingSemicolon(content.substring(arrowStart + 2));
    if (semiIndex == -1) return false;
    body = content.substring(arrowStart, arrowStart + 2 + semiIndex);
  } else {
    return false;
  }

  return body.contains('.logged()') ||
      body.contains('DtoLogger.parse') ||
      body.contains('.safeInt(') ||
      body.contains('.safeString(') ||
      body.contains('.safeDouble(') ||
      body.contains('.safeBool(');
}

/// Detect indentation from the first non-empty line
String _detectIndent(String code) {
  final lines = code.split('\n');
  for (final line in lines) {
    if (line.trim().isNotEmpty) {
      return _extractLeadingWhitespace(line);
    }
  }
  return '    '; // fallback: 4 spaces
}

/// Extract leading whitespace from a line
String _extractLeadingWhitespace(String line) {
  final match = RegExp(r'^(\s*)').firstMatch(line);
  return match?.group(1) ?? '';
}

/// Find the terminating semicolon at depth 0
int _findTerminatingSemicolon(String code) {
  int depth = 0;
  bool inString = false;
  String? stringChar;

  for (int i = 0; i < code.length; i++) {
    final char = code[i];

    // Handle strings
    if (!inString && (char == "'" || char == '"')) {
      inString = true;
      stringChar = char;
      continue;
    }
    if (inString && char == stringChar) {
      // Count consecutive backslashes before this quote
      int backslashes = 0;
      for (int j = i - 1; j >= 0 && code[j] == '\\'; j--) {
        backslashes++;
      }
      // Quote is escaped only if preceded by odd number of backslashes
      if (backslashes.isEven) {
        inString = false;
      }
      continue;
    }
    if (inString) continue;

    if (char == '(' || char == '{' || char == '[') depth++;
    if (char == ')' || char == '}' || char == ']') depth--;
    if (char == ';' && depth == 0) return i;
  }
  return -1;
}

/// Check if the dto_logger import exists
bool _hasImport(String content) {
  return content.contains("package:dto_logger/dto_logger.dart") ||
      content.contains("packages/dto_logger/lib/dto_logger.dart");
}

/// Add the dto_logger import to the file
String _addImport(String content) {
  final importLine = "import 'package:dto_logger/dto_logger.dart';\n";

  // Find first import to add before it
  final importMatch = RegExp('^import\\s+[\'"]', multiLine: true).firstMatch(content);
  if (importMatch != null) {
    return content.substring(0, importMatch.start) +
        importLine +
        content.substring(importMatch.start);
  }

  // No imports found, add after any leading comments
  final lines = content.split('\n');
  int insertIndex = 0;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty || line.startsWith('//') || line.startsWith('///')) {
      insertIndex = i + 1;
    } else {
      break;
    }
  }
  lines.insert(insertIndex, importLine.trimRight());
  lines.insert(insertIndex + 1, '');
  return lines.join('\n');
}

void _printHeader() {
  print('');
  print('${AnsiColors.cyan}╔════════════════════════════════════════╗${AnsiColors.reset}');
  print('${AnsiColors.cyan}║${AnsiColors.reset}     ${AnsiColors.bold}DTO Logger — Inject Tool${AnsiColors.reset}          ${AnsiColors.cyan}║${AnsiColors.reset}');
  print('${AnsiColors.cyan}╚════════════════════════════════════════╝${AnsiColors.reset}');
  print('');
}

void _printHelp() {
  print('''
${AnsiColors.bold}DTO Logger — Inject Tool${AnsiColors.reset}

${AnsiColors.cyan}USAGE:${AnsiColors.reset}
  dart run dto_logger:inject [options]

${AnsiColors.cyan}OPTIONS:${AnsiColors.reset}
  -h, --help            Show this help message
  -d, --dir <path>      Directory to scan (default: lib/)
  --dry-run             Preview changes without modifying files

${AnsiColors.cyan}EXAMPLES:${AnsiColors.reset}
  ${AnsiColors.dim}# Inject into all fromJson in lib/${AnsiColors.reset}
  dart run dto_logger:inject

  ${AnsiColors.dim}# Preview what would change${AnsiColors.reset}
  dart run dto_logger:inject --dry-run

  ${AnsiColors.dim}# Target a specific directory${AnsiColors.reset}
  dart run dto_logger:inject --dir lib/models/

${AnsiColors.cyan}WHAT IT DOES:${AnsiColors.reset}
  Finds every fromJson(Map<String, dynamic> json) in your project
  and adds: json = json.logged();

  This gives you:
  • Extra field detection (backend sends fields your model ignores)
  • Null warnings (api sent null for a field you accessed)
  • Suspicious type hints (String "123" that looks like int)
  • Beautiful box-drawn output with timing
  • Zero overhead when logging is disabled

${AnsiColors.cyan}SAFE:${AnsiColors.reset}
  • Skips .g.dart generated files
  • Skips files already using DtoLogger
  • Use --dry-run to preview first
''');
}
