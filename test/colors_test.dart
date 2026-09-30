import 'package:dto_logger/src/colors.dart';
import 'package:test/test.dart';

void main() {
  group('ANSI Escape Code Constants', () {
    group('Reset code', () {
      test('reset equals \\x1B[0m', () {
        expect(AnsiColors.reset, equals('\x1B[0m'));
      });

      test('reset starts with escape character', () {
        expect(AnsiColors.reset, startsWith('\x1B'));
      });

      test('reset is non-empty', () {
        expect(AnsiColors.reset.isNotEmpty, isTrue);
      });
    });

    group('Text style codes', () {
      test('bold equals \\x1B[1m', () {
        expect(AnsiColors.bold, equals('\x1B[1m'));
      });

      test('dim equals \\x1B[2m', () {
        expect(AnsiColors.dim, equals('\x1B[2m'));
      });

      test('italic equals \\x1B[3m', () {
        expect(AnsiColors.italic, equals('\x1B[3m'));
      });

      test('underline equals \\x1B[4m', () {
        expect(AnsiColors.underline, equals('\x1B[4m'));
      });

      test('all style codes start with \\x1B[', () {
        final styles = [
          AnsiColors.bold,
          AnsiColors.dim,
          AnsiColors.italic,
          AnsiColors.underline,
        ];
        for (final style in styles) {
          expect(style, startsWith('\x1B['));
        }
      });

      test('all style codes are non-empty', () {
        expect(AnsiColors.bold.isNotEmpty, isTrue);
        expect(AnsiColors.dim.isNotEmpty, isTrue);
        expect(AnsiColors.italic.isNotEmpty, isTrue);
        expect(AnsiColors.underline.isNotEmpty, isTrue);
      });

      test('all style codes contain the escape character \\x1B', () {
        expect(AnsiColors.bold, contains('\x1B'));
        expect(AnsiColors.dim, contains('\x1B'));
        expect(AnsiColors.italic, contains('\x1B'));
        expect(AnsiColors.underline, contains('\x1B'));
      });
    });

    group('Foreground color codes', () {
      test('black equals \\x1B[30m', () {
        expect(AnsiColors.black, equals('\x1B[30m'));
      });

      test('red equals \\x1B[31m', () {
        expect(AnsiColors.red, equals('\x1B[31m'));
      });

      test('green equals \\x1B[32m', () {
        expect(AnsiColors.green, equals('\x1B[32m'));
      });

      test('yellow equals \\x1B[33m', () {
        expect(AnsiColors.yellow, equals('\x1B[33m'));
      });

      test('blue equals \\x1B[34m', () {
        expect(AnsiColors.blue, equals('\x1B[34m'));
      });

      test('magenta equals \\x1B[35m', () {
        expect(AnsiColors.magenta, equals('\x1B[35m'));
      });

      test('cyan equals \\x1B[36m', () {
        expect(AnsiColors.cyan, equals('\x1B[36m'));
      });

      test('white equals \\x1B[37m', () {
        expect(AnsiColors.white, equals('\x1B[37m'));
      });

      test('all foreground color codes start with \\x1B[', () {
        final colors = [
          AnsiColors.black,
          AnsiColors.red,
          AnsiColors.green,
          AnsiColors.yellow,
          AnsiColors.blue,
          AnsiColors.magenta,
          AnsiColors.cyan,
          AnsiColors.white,
        ];
        for (final color in colors) {
          expect(color, startsWith('\x1B['));
        }
      });

      test('all foreground color codes are non-empty', () {
        final colors = [
          AnsiColors.black,
          AnsiColors.red,
          AnsiColors.green,
          AnsiColors.yellow,
          AnsiColors.blue,
          AnsiColors.magenta,
          AnsiColors.cyan,
          AnsiColors.white,
        ];
        for (final color in colors) {
          expect(color.isNotEmpty, isTrue);
        }
      });

      test('foreground codes use range 30-37', () {
        expect(AnsiColors.black, contains('[30m'));
        expect(AnsiColors.red, contains('[31m'));
        expect(AnsiColors.green, contains('[32m'));
        expect(AnsiColors.yellow, contains('[33m'));
        expect(AnsiColors.blue, contains('[34m'));
        expect(AnsiColors.magenta, contains('[35m'));
        expect(AnsiColors.cyan, contains('[36m'));
        expect(AnsiColors.white, contains('[37m'));
      });
    });

    group('Bright foreground color codes', () {
      test('brightBlack equals \\x1B[90m', () {
        expect(AnsiColors.brightBlack, equals('\x1B[90m'));
      });

      test('brightRed equals \\x1B[91m', () {
        expect(AnsiColors.brightRed, equals('\x1B[91m'));
      });

      test('brightGreen equals \\x1B[92m', () {
        expect(AnsiColors.brightGreen, equals('\x1B[92m'));
      });

      test('brightYellow equals \\x1B[93m', () {
        expect(AnsiColors.brightYellow, equals('\x1B[93m'));
      });

      test('brightBlue equals \\x1B[94m', () {
        expect(AnsiColors.brightBlue, equals('\x1B[94m'));
      });

      test('brightMagenta equals \\x1B[95m', () {
        expect(AnsiColors.brightMagenta, equals('\x1B[95m'));
      });

      test('brightCyan equals \\x1B[96m', () {
        expect(AnsiColors.brightCyan, equals('\x1B[96m'));
      });

      test('brightWhite equals \\x1B[97m', () {
        expect(AnsiColors.brightWhite, equals('\x1B[97m'));
      });

      test('all bright foreground codes start with \\x1B[', () {
        final brights = [
          AnsiColors.brightBlack,
          AnsiColors.brightRed,
          AnsiColors.brightGreen,
          AnsiColors.brightYellow,
          AnsiColors.brightBlue,
          AnsiColors.brightMagenta,
          AnsiColors.brightCyan,
          AnsiColors.brightWhite,
        ];
        for (final bright in brights) {
          expect(bright, startsWith('\x1B['));
        }
      });

      test('bright foreground codes use range 90-97', () {
        expect(AnsiColors.brightBlack, contains('[90m'));
        expect(AnsiColors.brightRed, contains('[91m'));
        expect(AnsiColors.brightGreen, contains('[92m'));
        expect(AnsiColors.brightYellow, contains('[93m'));
        expect(AnsiColors.brightBlue, contains('[94m'));
        expect(AnsiColors.brightMagenta, contains('[95m'));
        expect(AnsiColors.brightCyan, contains('[96m'));
        expect(AnsiColors.brightWhite, contains('[97m'));
      });

      test('all bright foreground codes contain the escape character', () {
        final brights = [
          AnsiColors.brightBlack,
          AnsiColors.brightRed,
          AnsiColors.brightGreen,
          AnsiColors.brightYellow,
          AnsiColors.brightBlue,
          AnsiColors.brightMagenta,
          AnsiColors.brightCyan,
          AnsiColors.brightWhite,
        ];
        for (final bright in brights) {
          expect(bright, contains('\x1B'));
        }
      });
    });

    group('Background color codes', () {
      test('bgRed equals \\x1B[41m', () {
        expect(AnsiColors.bgRed, equals('\x1B[41m'));
      });

      test('bgGreen equals \\x1B[42m', () {
        expect(AnsiColors.bgGreen, equals('\x1B[42m'));
      });

      test('bgYellow equals \\x1B[43m', () {
        expect(AnsiColors.bgYellow, equals('\x1B[43m'));
      });

      test('bgBlue equals \\x1B[44m', () {
        expect(AnsiColors.bgBlue, equals('\x1B[44m'));
      });

      test('bgMagenta equals \\x1B[45m', () {
        expect(AnsiColors.bgMagenta, equals('\x1B[45m'));
      });

      test('bgCyan equals \\x1B[46m', () {
        expect(AnsiColors.bgCyan, equals('\x1B[46m'));
      });

      test('bgWhite equals \\x1B[47m', () {
        expect(AnsiColors.bgWhite, equals('\x1B[47m'));
      });

      test('all background codes start with \\x1B[', () {
        final bgs = [
          AnsiColors.bgRed,
          AnsiColors.bgGreen,
          AnsiColors.bgYellow,
          AnsiColors.bgBlue,
          AnsiColors.bgMagenta,
          AnsiColors.bgCyan,
          AnsiColors.bgWhite,
        ];
        for (final bg in bgs) {
          expect(bg, startsWith('\x1B['));
        }
      });

      test('background codes use range 41-47', () {
        expect(AnsiColors.bgRed, contains('[41m'));
        expect(AnsiColors.bgGreen, contains('[42m'));
        expect(AnsiColors.bgYellow, contains('[43m'));
        expect(AnsiColors.bgBlue, contains('[44m'));
        expect(AnsiColors.bgMagenta, contains('[45m'));
        expect(AnsiColors.bgCyan, contains('[46m'));
        expect(AnsiColors.bgWhite, contains('[47m'));
      });

      test('all background codes are non-empty', () {
        final bgs = [
          AnsiColors.bgRed,
          AnsiColors.bgGreen,
          AnsiColors.bgYellow,
          AnsiColors.bgBlue,
          AnsiColors.bgMagenta,
          AnsiColors.bgCyan,
          AnsiColors.bgWhite,
        ];
        for (final bg in bgs) {
          expect(bg.isNotEmpty, isTrue);
        }
      });

      test('all background codes contain the escape character', () {
        final bgs = [
          AnsiColors.bgRed,
          AnsiColors.bgGreen,
          AnsiColors.bgYellow,
          AnsiColors.bgBlue,
          AnsiColors.bgMagenta,
          AnsiColors.bgCyan,
          AnsiColors.bgWhite,
        ];
        for (final bg in bgs) {
          expect(bg, contains('\x1B'));
        }
      });
    });
  });

  group('Helper Methods', () {
    group('error()', () {
      test('wraps message with red and reset', () {
        final result = AnsiColors.error('fail');
        expect(result, equals('${AnsiColors.red}fail${AnsiColors.reset}'));
      });

      test('starts with red escape code', () {
        expect(AnsiColors.error('test'), startsWith(AnsiColors.red));
      });

      test('ends with reset escape code', () {
        expect(AnsiColors.error('test'), endsWith(AnsiColors.reset));
      });

      test('contains the original message', () {
        expect(
            AnsiColors.error('my error message'), contains('my error message'));
      });

      test('works with empty string', () {
        final result = AnsiColors.error('');
        expect(result, equals('${AnsiColors.red}${AnsiColors.reset}'));
      });

      test('works with special characters', () {
        final result = AnsiColors.error('!@#\$%^&*()');
        expect(result, contains('!@#\$%^&*()'));
        expect(result, startsWith(AnsiColors.red));
        expect(result, endsWith(AnsiColors.reset));
      });

      test('works with very long string', () {
        final longMsg = 'a' * 1000;
        final result = AnsiColors.error(longMsg);
        expect(result, contains(longMsg));
        expect(result, startsWith(AnsiColors.red));
        expect(result, endsWith(AnsiColors.reset));
      });
    });

    group('success()', () {
      test('wraps message with green and reset', () {
        final result = AnsiColors.success('ok');
        expect(result, equals('${AnsiColors.green}ok${AnsiColors.reset}'));
      });

      test('starts with green escape code', () {
        expect(AnsiColors.success('test'), startsWith(AnsiColors.green));
      });

      test('ends with reset escape code', () {
        expect(AnsiColors.success('test'), endsWith(AnsiColors.reset));
      });

      test('contains the original message', () {
        expect(AnsiColors.success('all good'), contains('all good'));
      });

      test('works with empty string', () {
        final result = AnsiColors.success('');
        expect(result, equals('${AnsiColors.green}${AnsiColors.reset}'));
      });

      test('works with special characters', () {
        final result = AnsiColors.success('<html>&nbsp;</html>');
        expect(result, contains('<html>&nbsp;</html>'));
      });

      test('works with very long string', () {
        final longMsg = 'success' * 200;
        final result = AnsiColors.success(longMsg);
        expect(result, contains(longMsg));
      });
    });

    group('warning()', () {
      test('wraps message with yellow and reset', () {
        final result = AnsiColors.warning('caution');
        expect(
            result, equals('${AnsiColors.yellow}caution${AnsiColors.reset}'));
      });

      test('starts with yellow escape code', () {
        expect(AnsiColors.warning('test'), startsWith(AnsiColors.yellow));
      });

      test('ends with reset escape code', () {
        expect(AnsiColors.warning('test'), endsWith(AnsiColors.reset));
      });

      test('contains the original message', () {
        expect(AnsiColors.warning('be careful'), contains('be careful'));
      });

      test('works with empty string', () {
        final result = AnsiColors.warning('');
        expect(result, equals('${AnsiColors.yellow}${AnsiColors.reset}'));
      });

      test('works with newlines in message', () {
        final result = AnsiColors.warning('line1\nline2');
        expect(result, contains('line1\nline2'));
        expect(result, startsWith(AnsiColors.yellow));
      });
    });

    group('info()', () {
      test('wraps message with cyan and reset', () {
        final result = AnsiColors.info('note');
        expect(result, equals('${AnsiColors.cyan}note${AnsiColors.reset}'));
      });

      test('starts with cyan escape code', () {
        expect(AnsiColors.info('test'), startsWith(AnsiColors.cyan));
      });

      test('ends with reset escape code', () {
        expect(AnsiColors.info('test'), endsWith(AnsiColors.reset));
      });

      test('contains the original message', () {
        expect(AnsiColors.info('information'), contains('information'));
      });

      test('works with empty string', () {
        final result = AnsiColors.info('');
        expect(result, equals('${AnsiColors.cyan}${AnsiColors.reset}'));
      });

      test('works with unicode characters', () {
        final result = AnsiColors.info('unicode: \u2603 \u2764');
        expect(result, contains('unicode: \u2603 \u2764'));
      });
    });

    group('highlight()', () {
      test('wraps message with bold + white and reset', () {
        final result = AnsiColors.highlight('important');
        expect(
          result,
          equals(
              '${AnsiColors.bold}${AnsiColors.white}important${AnsiColors.reset}'),
        );
      });

      test('starts with bold escape code', () {
        expect(AnsiColors.highlight('test'), startsWith(AnsiColors.bold));
      });

      test('contains white escape code', () {
        expect(AnsiColors.highlight('test'), contains(AnsiColors.white));
      });

      test('ends with reset escape code', () {
        expect(AnsiColors.highlight('test'), endsWith(AnsiColors.reset));
      });

      test('works with empty string', () {
        final result = AnsiColors.highlight('');
        expect(
          result,
          equals('${AnsiColors.bold}${AnsiColors.white}${AnsiColors.reset}'),
        );
      });

      test('works with special characters', () {
        final result = AnsiColors.highlight('tab\there');
        expect(result, contains('tab\there'));
      });
    });

    group('muted()', () {
      test('wraps message with dim and reset', () {
        final result = AnsiColors.muted('faded');
        expect(result, equals('${AnsiColors.dim}faded${AnsiColors.reset}'));
      });

      test('starts with dim escape code', () {
        expect(AnsiColors.muted('test'), startsWith(AnsiColors.dim));
      });

      test('ends with reset escape code', () {
        expect(AnsiColors.muted('test'), endsWith(AnsiColors.reset));
      });

      test('works with empty string', () {
        final result = AnsiColors.muted('');
        expect(result, equals('${AnsiColors.dim}${AnsiColors.reset}'));
      });

      test('works with very long string', () {
        final longMsg = 'x' * 500;
        final result = AnsiColors.muted(longMsg);
        expect(result, contains(longMsg));
      });
    });

    group('Nested helper calls', () {
      test('error wrapping success produces nested escape codes', () {
        final result = AnsiColors.error(AnsiColors.success('nested'));
        expect(result, startsWith(AnsiColors.red));
        expect(result, endsWith(AnsiColors.reset));
        expect(result, contains(AnsiColors.green));
        expect(result, contains('nested'));
      });

      test('success wrapping error produces nested escape codes', () {
        final result = AnsiColors.success(AnsiColors.error('inner'));
        expect(result, startsWith(AnsiColors.green));
        expect(result, contains(AnsiColors.red));
        expect(result, contains('inner'));
      });

      test('highlight wrapping warning produces nested escape codes', () {
        final result = AnsiColors.highlight(AnsiColors.warning('warn'));
        expect(result, startsWith(AnsiColors.bold));
        expect(result, contains(AnsiColors.yellow));
        expect(result, contains('warn'));
      });

      test('triple nesting works correctly', () {
        final result =
            AnsiColors.error(AnsiColors.success(AnsiColors.info('deep')));
        expect(result, contains('deep'));
        expect(result, startsWith(AnsiColors.red));
        expect(result, endsWith(AnsiColors.reset));
      });
    });
  });

  group('Icon Methods', () {
    group('errorIcon()', () {
      test('contains cross icon', () {
        expect(AnsiColors.errorIcon('fail'), contains('\u2717'));
      });

      test('wraps with red and reset', () {
        final result = AnsiColors.errorIcon('fail');
        expect(result, startsWith(AnsiColors.red));
        expect(result, endsWith(AnsiColors.reset));
      });

      test('contains the message text', () {
        expect(AnsiColors.errorIcon('something broke'),
            contains('something broke'));
      });

      test('works with empty message', () {
        final result = AnsiColors.errorIcon('');
        expect(result, contains('\u2717'));
        expect(result, startsWith(AnsiColors.red));
        expect(result, endsWith(AnsiColors.reset));
      });

      test('icon appears before message', () {
        final result = AnsiColors.errorIcon('msg');
        final iconIndex = result.indexOf('\u2717');
        final msgIndex = result.indexOf('msg');
        expect(iconIndex, lessThan(msgIndex));
      });
    });

    group('successIcon()', () {
      test('contains checkmark icon', () {
        expect(AnsiColors.successIcon('pass'), contains('\u2713'));
      });

      test('wraps with green and reset', () {
        final result = AnsiColors.successIcon('pass');
        expect(result, startsWith(AnsiColors.green));
        expect(result, endsWith(AnsiColors.reset));
      });

      test('contains the message text', () {
        expect(AnsiColors.successIcon('all tests pass'),
            contains('all tests pass'));
      });

      test('works with empty message', () {
        final result = AnsiColors.successIcon('');
        expect(result, contains('\u2713'));
        expect(result, startsWith(AnsiColors.green));
      });

      test('icon appears before message', () {
        final result = AnsiColors.successIcon('msg');
        final iconIndex = result.indexOf('\u2713');
        final msgIndex = result.indexOf('msg');
        expect(iconIndex, lessThan(msgIndex));
      });
    });

    group('warningIcon()', () {
      test('contains warning icon', () {
        expect(AnsiColors.warningIcon('careful'), contains('\u26A0'));
      });

      test('wraps with yellow and reset', () {
        final result = AnsiColors.warningIcon('careful');
        expect(result, startsWith(AnsiColors.yellow));
        expect(result, endsWith(AnsiColors.reset));
      });

      test('contains the message text', () {
        expect(AnsiColors.warningIcon('watch out'), contains('watch out'));
      });

      test('works with empty message', () {
        final result = AnsiColors.warningIcon('');
        expect(result, contains('\u26A0'));
        expect(result, startsWith(AnsiColors.yellow));
      });

      test('icon appears before message', () {
        final result = AnsiColors.warningIcon('msg');
        final iconIndex = result.indexOf('\u26A0');
        final msgIndex = result.indexOf('msg');
        expect(iconIndex, lessThan(msgIndex));
      });
    });

    group('infoIcon()', () {
      test('contains arrow icon', () {
        expect(AnsiColors.infoIcon('hint'), contains('\u2192'));
      });

      test('wraps with cyan and reset', () {
        final result = AnsiColors.infoIcon('hint');
        expect(result, startsWith(AnsiColors.cyan));
        expect(result, endsWith(AnsiColors.reset));
      });

      test('contains the message text', () {
        expect(AnsiColors.infoIcon('see this'), contains('see this'));
      });

      test('works with empty message', () {
        final result = AnsiColors.infoIcon('');
        expect(result, contains('\u2192'));
        expect(result, startsWith(AnsiColors.cyan));
      });

      test('icon appears before message', () {
        final result = AnsiColors.infoIcon('msg');
        final iconIndex = result.indexOf('\u2192');
        final msgIndex = result.indexOf('msg');
        expect(iconIndex, lessThan(msgIndex));
      });
    });
  });

  group('Type/Field/Value Indicators', () {
    group('typeStr()', () {
      test('wraps type with magenta and reset', () {
        final result = AnsiColors.typeStr('String');
        expect(
            result, equals('${AnsiColors.magenta}String${AnsiColors.reset}'));
      });

      test('starts with magenta', () {
        expect(AnsiColors.typeStr('int'), startsWith(AnsiColors.magenta));
      });

      test('ends with reset', () {
        expect(AnsiColors.typeStr('int'), endsWith(AnsiColors.reset));
      });

      test('contains the type name', () {
        expect(AnsiColors.typeStr('List<Map<String, dynamic>>'),
            contains('List<Map<String, dynamic>>'));
      });
    });

    group('fieldStr()', () {
      test('wraps field with cyan and reset', () {
        final result = AnsiColors.fieldStr('userName');
        expect(result, equals('${AnsiColors.cyan}userName${AnsiColors.reset}'));
      });

      test('starts with cyan', () {
        expect(AnsiColors.fieldStr('id'), startsWith(AnsiColors.cyan));
      });

      test('ends with reset', () {
        expect(AnsiColors.fieldStr('id'), endsWith(AnsiColors.reset));
      });
    });

    group('valueStr()', () {
      test('wraps string value with yellow and reset', () {
        final result = AnsiColors.valueStr('hello');
        expect(result, equals('${AnsiColors.yellow}hello${AnsiColors.reset}'));
      });

      test('works with integer value', () {
        final result = AnsiColors.valueStr(42);
        expect(result, equals('${AnsiColors.yellow}42${AnsiColors.reset}'));
        expect(result, contains('42'));
      });

      test('works with boolean value', () {
        final result = AnsiColors.valueStr(true);
        expect(result, equals('${AnsiColors.yellow}true${AnsiColors.reset}'));
        expect(result, contains('true'));
      });

      test('works with null value', () {
        final result = AnsiColors.valueStr(null);
        expect(result, equals('${AnsiColors.yellow}null${AnsiColors.reset}'));
        expect(result, contains('null'));
      });

      test('works with double value', () {
        final result = AnsiColors.valueStr(3.14);
        expect(result, contains('3.14'));
        expect(result, startsWith(AnsiColors.yellow));
      });

      test('works with list value', () {
        final result = AnsiColors.valueStr([1, 2, 3]);
        expect(result, contains('[1, 2, 3]'));
        expect(result, startsWith(AnsiColors.yellow));
      });
    });
  });

  group('Box Drawing Constants', () {
    test('boxTopLeft is correct Unicode character', () {
      expect(AnsiColors.boxTopLeft, equals('\u250C'));
    });

    test('boxTopRight is correct Unicode character', () {
      expect(AnsiColors.boxTopRight, equals('\u2510'));
    });

    test('boxBottomLeft is correct Unicode character', () {
      expect(AnsiColors.boxBottomLeft, equals('\u2514'));
    });

    test('boxBottomRight is correct Unicode character', () {
      expect(AnsiColors.boxBottomRight, equals('\u2518'));
    });

    test('boxHorizontal is correct Unicode character', () {
      expect(AnsiColors.boxHorizontal, equals('\u2500'));
    });

    test('boxVertical is correct Unicode character', () {
      expect(AnsiColors.boxVertical, equals('\u2502'));
    });

    test('boxTeeRight is correct Unicode character', () {
      expect(AnsiColors.boxTeeRight, equals('\u251C'));
    });

    test('boxTeeLeft is correct Unicode character', () {
      expect(AnsiColors.boxTeeLeft, equals('\u2524'));
    });

    test('all box drawing characters are single characters', () {
      expect(AnsiColors.boxTopLeft.length, equals(1));
      expect(AnsiColors.boxTopRight.length, equals(1));
      expect(AnsiColors.boxBottomLeft.length, equals(1));
      expect(AnsiColors.boxBottomRight.length, equals(1));
      expect(AnsiColors.boxHorizontal.length, equals(1));
      expect(AnsiColors.boxVertical.length, equals(1));
      expect(AnsiColors.boxTeeRight.length, equals(1));
      expect(AnsiColors.boxTeeLeft.length, equals(1));
    });

    test('all box drawing characters are non-empty', () {
      final chars = [
        AnsiColors.boxTopLeft,
        AnsiColors.boxTopRight,
        AnsiColors.boxBottomLeft,
        AnsiColors.boxBottomRight,
        AnsiColors.boxHorizontal,
        AnsiColors.boxVertical,
        AnsiColors.boxTeeRight,
        AnsiColors.boxTeeLeft,
      ];
      for (final c in chars) {
        expect(c.isNotEmpty, isTrue);
      }
    });
  });

  group('line() Method', () {
    test('default width produces 50 characters', () {
      final result = AnsiColors.line();
      expect(result.length, equals(50));
    });

    test('default width uses boxHorizontal characters', () {
      final result = AnsiColors.line();
      for (int i = 0; i < result.length; i++) {
        expect(result[i], equals(AnsiColors.boxHorizontal));
      }
    });

    test('custom width 0 produces empty string', () {
      final result = AnsiColors.line(0);
      expect(result, equals(''));
      expect(result.length, equals(0));
    });

    test('custom width 1 produces single character', () {
      final result = AnsiColors.line(1);
      expect(result.length, equals(1));
      expect(result, equals(AnsiColors.boxHorizontal));
    });

    test('custom width 10 produces 10 characters', () {
      final result = AnsiColors.line(10);
      expect(result.length, equals(10));
    });

    test('custom width 100 produces 100 characters', () {
      final result = AnsiColors.line(100);
      expect(result.length, equals(100));
    });

    test('all characters in custom width line are boxHorizontal', () {
      final result = AnsiColors.line(25);
      expect(result, equals(AnsiColors.boxHorizontal * 25));
    });

    test('line with width 5 matches repeated boxHorizontal', () {
      expect(AnsiColors.line(5), equals('\u2500\u2500\u2500\u2500\u2500'));
    });

    test('line output does not contain newlines', () {
      final result = AnsiColors.line(30);
      expect(result, isNot(contains('\n')));
    });

    test('line with large width 500 has correct length', () {
      final result = AnsiColors.line(500);
      expect(result.length, equals(500));
    });
  });

  group('box() Method', () {
    test('basic box with title and one line', () {
      final result = AnsiColors.box('Title', ['content']);
      expect(result, contains('Title'));
      expect(result, contains('content'));
    });

    test('box with empty lines list', () {
      final result = AnsiColors.box('Header', []);
      expect(result, contains('Header'));
      expect(result, contains(AnsiColors.boxTopLeft));
      expect(result, contains(AnsiColors.boxBottomLeft));
    });

    test('box with single line', () {
      final result = AnsiColors.box('Test', ['line one']);
      expect(result, contains('Test'));
      expect(result, contains('line one'));
    });

    test('box with multiple lines', () {
      final result = AnsiColors.box('Multi', ['aaa', 'bbb', 'ccc']);
      expect(result, contains('aaa'));
      expect(result, contains('bbb'));
      expect(result, contains('ccc'));
    });

    test('box with lines of different lengths', () {
      final result =
          AnsiColors.box('Diff', ['short', 'a much longer line here']);
      expect(result, contains('short'));
      expect(result, contains('a much longer line here'));
    });

    test('box contains top left corner', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxTopLeft));
    });

    test('box contains top right corner', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxTopRight));
    });

    test('box contains bottom left corner', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxBottomLeft));
    });

    test('box contains bottom right corner', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxBottomRight));
    });

    test('box contains tee right separator', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxTeeRight));
    });

    test('box contains tee left separator', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxTeeLeft));
    });

    test('box contains vertical bars', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxVertical));
    });

    test('box contains horizontal bars', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, contains(AnsiColors.boxHorizontal));
    });

    test('box contains bold for title', () {
      final result = AnsiColors.box('Title', ['line']);
      expect(result, contains(AnsiColors.bold));
    });

    test('box contains reset codes', () {
      final result = AnsiColors.box('Title', ['line']);
      expect(result, contains(AnsiColors.reset));
    });

    test('box with color parameter applies color', () {
      final result = AnsiColors.box('Title', ['line'], color: AnsiColors.green);
      expect(result, contains(AnsiColors.green));
    });

    test('box without color parameter defaults to empty string', () {
      final result = AnsiColors.box('Title', ['line']);
      // When color is '', the box still works, just without extra color codes
      // wrapping structural elements. The bold and reset should still be present.
      expect(result, contains(AnsiColors.bold));
      expect(result, contains('Title'));
    });

    test('box with red color wraps structural elements', () {
      final result =
          AnsiColors.box('Error', ['bad thing'], color: AnsiColors.red);
      expect(result, contains(AnsiColors.red));
      expect(result, contains('Error'));
      expect(result, contains('bad thing'));
    });

    test('box width adapts to longest line', () {
      final result =
          AnsiColors.box('Hi', ['short', 'this is the longest line']);
      // The longest line is 'this is the longest line' (23 chars)
      // width = 23 + 4 = 27
      // Top border should have (27 - 2) = 25 horizontal chars
      final topBorder = AnsiColors.boxHorizontal * 25;
      expect(result, contains(topBorder));
    });

    test('box width adapts to title length when title is longest', () {
      final result = AnsiColors.box('This Is A Very Long Title', ['ok']);
      // Title is 25 chars, longest line is 'ok' (2 chars)
      // width = 25 + 4 = 29
      // Top border should have (29 - 2) = 27 horizontal chars
      final topBorder = AnsiColors.boxHorizontal * 27;
      expect(result, contains(topBorder));
    });

    test('box output ends with newline', () {
      final result = AnsiColors.box('T', ['l']);
      expect(result, endsWith('\n'));
    });

    test('box with very long title creates wide box', () {
      final longTitle = 'A' * 100;
      final result = AnsiColors.box(longTitle, ['x']);
      expect(result, contains(longTitle));
      // width = 100 + 4 = 104, border = 102 horizontal chars
      final border = AnsiColors.boxHorizontal * 102;
      expect(result, contains(border));
    });

    test('box has exactly 5 lines of output when given one content line', () {
      final result = AnsiColors.box('T', ['L']);
      // top border, title row, separator, content line, bottom border
      final lineCount = '\n'.allMatches(result).length;
      expect(lineCount, equals(5));
    });

    test('box has 4 lines of output when given zero content lines', () {
      final result = AnsiColors.box('T', []);
      // top border, title row, separator, bottom border
      final lineCount = '\n'.allMatches(result).length;
      expect(lineCount, equals(4));
    });

    test('box has 7 lines of output when given three content lines', () {
      final result = AnsiColors.box('T', ['a', 'b', 'c']);
      // top border, title row, separator, 3 content lines, bottom border
      final lineCount = '\n'.allMatches(result).length;
      expect(lineCount, equals(7));
    });

    test('box with yellow color for warning style', () {
      final result = AnsiColors.box('Warning', ['issue 1', 'issue 2'],
          color: AnsiColors.yellow);
      expect(result, contains(AnsiColors.yellow));
      expect(result, contains('Warning'));
      expect(result, contains('issue 1'));
      expect(result, contains('issue 2'));
    });

    test('box title is on the second line of output', () {
      final result = AnsiColors.box('MyTitle', ['data']);
      final lines = result.split('\n');
      // lines[0] = top border, lines[1] = title row
      expect(lines[1], contains('MyTitle'));
    });

    test('box separator is on the third line of output', () {
      final result = AnsiColors.box('MyTitle', ['data']);
      final lines = result.split('\n');
      // lines[2] = separator
      expect(lines[2], contains(AnsiColors.boxTeeRight));
      expect(lines[2], contains(AnsiColors.boxTeeLeft));
    });

    test('box content appears after separator', () {
      final result = AnsiColors.box('MyTitle', ['mydata']);
      final lines = result.split('\n');
      // lines[3] = first content line
      expect(lines[3], contains('mydata'));
    });
  });
}
