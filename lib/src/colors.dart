/// ANSI color codes for terminal output
/// No external dependencies - uses raw escape codes
library;

/// ANSI escape codes for colored console output
/// Works in VS Code, Android Studio, terminal, etc.
class AnsiColors {
  AnsiColors._();

  // Reset
  static const String reset = '\x1B[0m';

  // Text styles
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String italic = '\x1B[3m';
  static const String underline = '\x1B[4m';

  // Foreground colors
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';

  // Bright foreground colors
  static const String brightBlack = '\x1B[90m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightMagenta = '\x1B[95m';
  static const String brightCyan = '\x1B[96m';
  static const String brightWhite = '\x1B[97m';

  // Background colors
  static const String bgRed = '\x1B[41m';
  static const String bgGreen = '\x1B[42m';
  static const String bgYellow = '\x1B[43m';
  static const String bgBlue = '\x1B[44m';
  static const String bgMagenta = '\x1B[45m';
  static const String bgCyan = '\x1B[46m';
  static const String bgWhite = '\x1B[47m';

  // Helper methods
  static String error(String msg) => '$red$msg$reset';
  static String success(String msg) => '$green$msg$reset';
  static String warning(String msg) => '$yellow$msg$reset';
  static String info(String msg) => '$cyan$msg$reset';
  static String highlight(String msg) => '$bold$white$msg$reset';
  static String muted(String msg) => '$dim$msg$reset';

  // Styled messages with icons
  static String errorIcon(String msg) => '$red✗ $msg$reset';
  static String successIcon(String msg) => '$green✓ $msg$reset';
  static String warningIcon(String msg) => '$yellow⚠ $msg$reset';
  static String infoIcon(String msg) => '$cyan→ $msg$reset';

  // Type indicators
  static String typeStr(String type) => '$magenta$type$reset';
  static String fieldStr(String field) => '$cyan$field$reset';
  static String valueStr(dynamic value) => '$yellow$value$reset';

  // Box drawing for pretty output
  static const String boxTopLeft = '┌';
  static const String boxTopRight = '┐';
  static const String boxBottomLeft = '└';
  static const String boxBottomRight = '┘';
  static const String boxHorizontal = '─';
  static const String boxVertical = '│';
  static const String boxTeeRight = '├';
  static const String boxTeeLeft = '┤';

  /// Creates a horizontal line
  static String line([int width = 50]) => boxHorizontal * width;

  /// Wraps text in a box
  static String box(String title, List<String> lines, {String color = ''}) {
    final maxLen = lines.fold<int>(
      title.length,
      (max, line) => line.length > max ? line.length : max,
    );
    final width = maxLen + 4;

    final buffer = StringBuffer();
    buffer.writeln('$color$boxTopLeft${boxHorizontal * (width - 2)}$boxTopRight$reset');
    buffer.writeln('$color$boxVertical $bold$title${' ' * (width - title.length - 3)}$reset$color$boxVertical$reset');
    buffer.writeln('$color$boxTeeRight${boxHorizontal * (width - 2)}$boxTeeLeft$reset');

    for (final line in lines) {
      buffer.writeln('$color$boxVertical$reset $line${' ' * (width - line.length - 3)}$color$boxVertical$reset');
    }

    buffer.writeln('$color$boxBottomLeft${boxHorizontal * (width - 2)}$boxBottomRight$reset');
    return buffer.toString();
  }
}
