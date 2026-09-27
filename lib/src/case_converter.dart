/// Case conversion utilities for JSON field names
/// Handles snake_case → camelCase with edge cases like _id, __private
library;

/// Converts between different naming conventions
class CaseConverter {
  CaseConverter._();

  // Cached RegExp patterns — avoid recompiling on every call
  static final _leadingUnderscores = RegExp(r'^_+');
  static final _underscoreSplit = RegExp(r'_+');
  static final _identifierStart = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
  static final _invalidChars = RegExp(r'[^a-zA-Z0-9_]');
  static final _startsWithDigit = RegExp(r'[0-9]');

  /// Converts snake_case to camelCase
  /// 
  /// Examples:
  /// - user_name → userName
  /// - _id → id (leading underscore removed)
  /// - __private → private (multiple leading underscores removed)
  /// - USER_NAME → userName (all caps handled)
  /// - already_camelCase → alreadyCamelcase
  /// - first__last → firstLast (double underscore = single boundary)
  /// - userId → userId (already camelCase, preserved)
  /// - ID → id, HTTPResponse → httpResponse (leading acronym lowered)
  static String snakeToCamel(String input) {
    if (input.isEmpty) return input;

    // If no underscore, it's already camelCase or single word - preserve it
    if (!input.contains('_')) {
      return _lowerLeadingAcronym(input);
    }

    // Remove leading underscores: _id → id, __private → private
    final clean = input.replaceFirst(_leadingUnderscores, '');
    
    if (clean.isEmpty) return input; // Edge case: input was only underscores

    // Split by underscore(s)
    final parts = clean.split(_underscoreSplit).where((p) => p.isNotEmpty).toList();
    
    if (parts.isEmpty) return input;

    // First part: all lowercase
    final buffer = StringBuffer(parts[0].toLowerCase());

    // Remaining parts: capitalize first letter
    for (int i = 1; i < parts.length; i++) {
      final part = parts[i].toLowerCase();
      if (part.isNotEmpty) {
        buffer.write(part[0].toUpperCase());
        if (part.length > 1) {
          buffer.write(part.substring(1));
        }
      }
    }

    return buffer.toString();
  }

  /// Lowercases the first letter, or a whole leading acronym:
  /// Name → name, ID → id, URL → url, HTTPResponse → httpResponse.
  static String _lowerLeadingAcronym(String input) {
    var upperRun = 0;
    while (upperRun < input.length && _isUpper(input[upperRun])) {
      upperRun++;
    }
    if (upperRun <= 1) return input[0].toLowerCase() + input.substring(1);
    if (upperRun == input.length) return input.toLowerCase();
    // Keep the last capital: it starts the next word (HTTP|Response)
    final cut = upperRun - 1;
    return input.substring(0, cut).toLowerCase() + input.substring(cut);
  }

  static bool _isUpper(String char) =>
      char.toUpperCase() == char && char.toLowerCase() != char;

  /// Converts camelCase to snake_case
  ///
  /// Examples:
  /// - userName → user_name
  /// - userID → user_id (handles consecutive caps)
  /// - HTTPResponse → http_response
  static String camelToSnake(String input) {
    if (input.isEmpty) return input;

    final result = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;

      if (isUpper && i > 0) {
        final prevChar = input[i - 1];
        final prevIsUpper = prevChar.toUpperCase() == prevChar && prevChar.toLowerCase() != prevChar;

        // Add underscore if:
        // 1. Previous char was lowercase (normal camelCase boundary)
        // 2. Previous char was uppercase AND next char exists AND is lowercase (end of acronym)
        if (!prevIsUpper) {
          result.write('_');
        } else if (i + 1 < input.length) {
          final nextChar = input[i + 1];
          final nextIsLower = nextChar.toLowerCase() == nextChar && nextChar.toUpperCase() != nextChar;
          if (nextIsLower) {
            result.write('_');
          }
        }
      }

      result.write(char.toLowerCase());
    }

    return result.toString();
  }

  /// Converts to PascalCase (for class names)
  /// 
  /// Examples:
  /// - user_response → UserResponse
  /// - _user → User
  /// - userResponse → UserResponse (already camelCase)
  /// - UserResponse → UserResponse (already PascalCase)
  static String snakeToPascal(String input) {
    if (input.isEmpty) return input;
    
    // If already contains uppercase, it might be camelCase or PascalCase
    // Check if it has underscores - if not, just capitalize first letter
    if (!input.contains('_')) {
      return input[0].toUpperCase() + input.substring(1);
    }
    
    // Has underscores - convert from snake_case
    final camel = snakeToCamel(input);
    if (camel.isEmpty) return camel;
    return camel[0].toUpperCase() + camel.substring(1);
  }

  /// Checks if a string is valid Dart identifier
  static bool isValidIdentifier(String name) {
    if (name.isEmpty) return false;
    
    // Must start with letter or underscore
    final firstChar = name[0];
    if (!firstChar.contains(RegExp(r'[a-zA-Z_]'))) return false;

    // Rest must be alphanumeric or underscore
    return _identifierStart.hasMatch(name);
  }

  /// Makes a string a valid Dart identifier
  ///
  /// Examples:
  /// - 123field → field123field (numbers can't start)
  /// - my-field → myField (dashes become camelCase)
  /// - my field → myField (spaces become camelCase)
  /// - class → class_ (reserved word)
  /// - الاسم / __ → field (nothing usable left)
  static String toValidIdentifier(String input) {
    if (input.isEmpty) return 'field';

    // Replace invalid characters with underscores
    String clean = input.replaceAll(_invalidChars, '_');

    // Convert to camelCase, then drop leading underscores:
    // a leading _ makes the name private and breaks named parameters.
    clean = snakeToCamel(clean).replaceFirst(_leadingUnderscores, '');
    if (clean.isEmpty) return 'field';

    // If starts with number, prefix with "field"
    if (_startsWithDigit.hasMatch(clean[0])) {
      clean = 'field$clean';
    }
    
    // Handle Dart reserved words
    if (_reservedWords.contains(clean)) {
      clean = '${clean}_';
    }
    
    return clean.isEmpty ? 'field' : clean;
  }

  /// Dart reserved keywords that can't be used as identifiers
  static const Set<String> _reservedWords = {
    'abstract', 'as', 'assert', 'async', 'await', 'break', 'case', 'catch',
    'class', 'const', 'continue', 'covariant', 'default', 'deferred', 'do',
    'dynamic', 'else', 'enum', 'export', 'extends', 'extension', 'external',
    'factory', 'false', 'final', 'finally', 'for', 'Function', 'get', 'hide',
    'if', 'implements', 'import', 'in', 'interface', 'is', 'late', 'library',
    'mixin', 'new', 'null', 'on', 'operator', 'part', 'required', 'rethrow',
    'return', 'sealed', 'set', 'show', 'static', 'super', 'switch', 'sync',
    'this', 'throw', 'true', 'try', 'typedef', 'var', 'void', 'while', 'with',
    'yield',
  };
}
