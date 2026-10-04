import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('inject_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('inject turns an arrow fromJson into a logged block body', () async {
    final file = File('${dir.path}/user.dart')..writeAsStringSync('''
class User {
  final int? id;
  User({this.id});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'] as int?);
}
''');

    final result = await Process.run(Platform.resolvedExecutable,
        ['run', 'bin/inject.dart', '--dir', dir.path]);
    expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');

    expect(file.readAsStringSync(), '''
import 'package:dto_logger/dto_logger.dart';

class User {
  final int? id;
  User({this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    json = json.logged();
    return User(id: json['id'] as int?);
  }
}
''');
  });

  group('target path', () {
    const model = '''
class User {
  final int? id;
  User({this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] as int?);
  }
}
''';

    Future<ProcessResult> inject(List<String> args) => Process.run(
        Platform.resolvedExecutable, ['run', 'bin/inject.dart', ...args]);

    test('a single file only changes that file', () async {
      final user = File('${dir.path}/user.dart')..writeAsStringSync(model);
      final other = File('${dir.path}/other.dart')..writeAsStringSync(model);

      final result = await inject([user.path]);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');

      expect(user.readAsStringSync(), contains('json = json.logged();'));
      expect(other.readAsStringSync(), model);
    });

    test('a folder can be passed without --dir', () async {
      final user = File('${dir.path}/user.dart')..writeAsStringSync(model);

      final result = await inject([dir.path]);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');

      expect(user.readAsStringSync(), contains('json = json.logged();'));
    });

    test('--dir accepts a single file', () async {
      final user = File('${dir.path}/user.dart')..writeAsStringSync(model);

      final result = await inject(['--dir', user.path, '--dry-run']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');

      expect(result.stdout, contains('Scanning 1 Dart files'));
      expect(user.readAsStringSync(), model);
    });

    test('a path that does not exist fails', () async {
      final result = await inject(['${dir.path}/missing.dart']);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('Not found'));
    });
  });
}
