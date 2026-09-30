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
}
