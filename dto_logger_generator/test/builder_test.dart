import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dto_logger_generator/dto_logger_generator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

/// Code with whitespace and trailing commas removed, so the checks don't
/// depend on how the installed dart_style formats the output.
String squash(String code) =>
    code.replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r',(?=[)\]}])'), '');

Matcher generates(String snippet) => contains(squash(snippet));

/// Runs the @DtoLog builder on [body] and returns the squashed output.
Future<String> generate(String body, {List<String>? errors}) async {
  final readerWriter = TestReaderWriter(rootPackage: 'app');
  await readerWriter.testing.loadIsolateSources();
  final result = await testBuilder(
    dtoLoggerBuilder(BuilderOptions.empty),
    {
      'app|lib/model.dart': '''
import 'package:dto_logger/dto_logger.dart';

part 'model.g.dart';

$body
''',
    },
    rootPackage: 'app',
    readerWriter: readerWriter,
    flattenOutput: true,
    onLog: (record) {
      if (record.level >= Level.SEVERE) errors?.add(record.message);
    },
  );
  final outputs = result.outputs.toList();
  if (outputs.isEmpty) return '';
  return squash(readerWriter.testing.readString(outputs.single));
}

/// Runs the builder on [body] and returns the error it reported.
Future<String> generateError(String body) async {
  final errors = <String>[];
  await generate(body, errors: errors);
  return errors.join('\n');
}

void main() {
  late String code;

  setUpAll(() async => code = await generate(_models));

  group('User', () {
    test(
      'User.fromJson reads int id',
      () => expect(
        code,
        generates(
          r'''id: json.safeInt('id') ?? (throw FormatException( 'Required field "id" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads int? age',
      () => expect(code, generates(r'''age: json.safeInt('age')''')),
    );
    test(
      'User.fromJson reads double? score',
      () => expect(code, generates(r'''score: json.safeDouble('score')''')),
    );
    test(
      'User.fromJson reads double ratio',
      () => expect(
        code,
        generates(
          r'''ratio: json.safeDouble('ratio') ?? (throw FormatException( 'Required field "ratio" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads bool? active',
      () => expect(code, generates(r'''active: json.safeBool('active')''')),
    );
    test(
      'User.fromJson reads bool verified',
      () => expect(
        code,
        generates(
          r'''verified: json.safeBool('verified') ?? (throw FormatException( 'Required field "verified" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads String? name',
      () => expect(code, generates(r'''name: json.safeString('name')''')),
    );
    test(
      r'''User.fromJson reads @DtoKey('user_name') String? userName''',
      () => expect(
        code,
        generates(r'''userName: json.safeString('user_name')'''),
      ),
    );
    test(
      r'''User.fromJson reads @DtoDefault('') String email''',
      () =>
          expect(code, generates(r'''email: json.safeStringOr('email', '')''')),
    );
    test(
      r'''User.fromJson reads @DtoKey('it\'s \$weird\\key') String? weird''',
      () => expect(
        code,
        generates(r'''weird: json.safeString('it\'s \$weird\\key')'''),
      ),
    );
    test(
      'User.fromJson reads Status? status',
      () => expect(
        code,
        generates(r'''status: json.safeEnum('status', Status.values)'''),
      ),
    );
    test(
      'User.fromJson reads @DtoDefault(Status.active) Status status2',
      () => expect(
        code,
        generates(
          r'''status2: json.safeEnumOr('status2', Status.values, Status.active)''',
        ),
      ),
    );
    test(
      r'''User.fromJson reads @DtoKey('role_key', defaultValue: Role.user) Role? role''',
      () => expect(
        code,
        generates(
          r'''role: json.safeEnumOr('role_key', Role.values, Role.user)''',
        ),
      ),
    );
    test(
      'User.fromJson reads List<Status>? statuses',
      () => expect(
        code,
        generates(
          r'''statuses: json.safeEnumList('statuses', Status.values)''',
        ),
      ),
    );
    test(
      'User.fromJson reads DateTime? createdAt',
      () => expect(
        code,
        generates(r'''createdAt: json.safeDateTime('createdAt')'''),
      ),
    );
    test(
      'User.fromJson reads DateTime updatedAt',
      () => expect(
        code,
        generates(
          r'''updatedAt: json.safeDateTime('updatedAt') ?? (throw FormatException( 'Required field "updatedAt" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads List<DateTime>? dates',
      () => expect(
        code,
        generates(r'''dates: json.safeListOf<DateTime>('dates')'''),
      ),
    );
    test(
      'User.fromJson reads List<DateTime?>? maybeDates',
      () => expect(
        code,
        generates(r'''maybeDates: json.safeListOf<DateTime?>('maybeDates')'''),
      ),
    );
    test(
      'User.fromJson reads Address? address',
      () => expect(
        code,
        generates(r'''address: json.safeObject('address', Address.fromJson)'''),
      ),
    );
    test(
      'User.fromJson reads Address home',
      () => expect(
        code,
        generates(
          r'''home: json.safeObject('home', Address.fromJson) ?? (throw FormatException( 'Required field "home" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads List<Address>? addresses',
      () => expect(
        code,
        generates(
          r'''addresses: json.safeList('addresses', Address.fromJson)''',
        ),
      ),
    );
    test(
      'User.fromJson reads List<Address?>? maybeAddresses',
      () => expect(
        code,
        generates(
          r'''maybeAddresses: json.safeList('maybeAddresses', Address.fromJson)''',
        ),
      ),
    );
    test(
      'User.fromJson reads Legacy? legacy',
      () => expect(
        code,
        generates(r'''legacy: json.safeObject('legacy', Legacy.fromJson)'''),
      ),
    );
    test(
      'User.fromJson reads List<int>? ints',
      () => expect(code, generates(r'''ints: json.safeListOf<int>('ints')''')),
    );
    test(
      'User.fromJson reads List<int?>? maybeInts',
      () => expect(
        code,
        generates(r'''maybeInts: json.safeListOf<int?>('maybeInts')'''),
      ),
    );
    test(
      'User.fromJson reads List<String> tags',
      () => expect(
        code,
        generates(
          r'''tags: json.safeListOf<String>('tags') ?? (throw FormatException( 'Required field "tags" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads Map<String, dynamic>? extra',
      () => expect(code, generates(r'''extra: json.safeMap('extra')''')),
    );
    test(
      'User.fromJson reads Map<String, int>? counts',
      () => expect(code, generates('counts: json.safeCast<Map<String')),
    );
    test(
      'User.fromJson passes positional argument 29',
      () => expect(code, generates(r'''int>>('counts')''')),
    );
    test(
      'User.fromJson reads dynamic anything',
      () =>
          expect(code, generates(r'''anything: json.safeValue('anything')''')),
    );
    test(
      'User.fromJson reads Object? obj',
      () => expect(code, generates(r'''obj: json.safeCast<Object>('obj')''')),
    );
    test(
      'User.fromJson reads Uri? uri',
      () => expect(code, generates(r'''uri: json.safeCast<Uri>('uri')''')),
    );
    test(
      r'''User.fromJson reads @DtoKey('limit', defaultValue: 10) int limit''',
      () => expect(code, generates(r'''limit: json.safeIntOr('limit', 10)''')),
    );
    test(
      'User.fromJson reads @DtoDefault(5) double factor',
      () => expect(
        code,
        generates(r'''factor: json.safeDoubleOr('factor', 5.0)'''),
      ),
    );
    test(
      'User.fromJson reads @DtoDefault(1.5) double? factor2',
      () => expect(
        code,
        generates(r'''factor2: json.safeDoubleOr('factor2', 1.5)'''),
      ),
    );
    test(
      'User.fromJson reads @DtoDefault(double.infinity) double maxValue',
      () => expect(
        code,
        generates(
          r'''maxValue: json.safeDoubleOr('maxValue', double.infinity)''',
        ),
      ),
    );
    test(
      'User.fromJson reads @DtoDefault(true) bool flag',
      () => expect(code, generates(r'''flag: json.safeBoolOr('flag', true)''')),
    );
    test(
      r'''User.fromJson reads @DtoDefault(<String>['a', 'b']) List<String> defaults''',
      () => expect(
        code,
        generates(
          r'''defaults: json.safeValue('defaults') == null ? const ['a', 'b'] : json.safeListOf<String>('defaults') ?? const ['a', 'b']''',
        ),
      ),
    );
    test(
      r'''User.fromJson reads @DtoDefault(<String, int>{'x': 1}) Map<String, int> defaultMap''',
      () => expect(
        code,
        generates(
          r'''defaultMap: json.safeValue('defaultMap') == null ? const {'x': 1} : json.safeCast<Map<String''',
        ),
      ),
    );
    test(
      'User.fromJson passes positional argument 40',
      () =>
          expect(code, generates(r'''int>>('defaultMap') ?? const {'x': 1}''')),
    );
    test(
      r'''User.fromJson reads @DtoKey.defaultValue('guest') String? kind''',
      () => expect(
        code,
        generates(r'''kind: json.safeStringOr('kind', 'guest')'''),
      ),
    );
    test(
      'User.fromJson reads @DtoKey.required() String? token',
      () => expect(
        code,
        generates(
          r'''token: json.safeString('token') ?? (throw FormatException( 'Required field "token" is missing or invalid'))''',
        ),
      ),
    );
    test(
      r'''User.fromJson reads @DtoKey('code', required: true) int? code''',
      () => expect(
        code,
        generates(
          r'''code: json.safeInt('code') ?? (throw FormatException( 'Required field "code" is missing or invalid'))''',
        ),
      ),
    );
    test(
      r'''User.fromJson reads @DtoRequired(message: 'phone is required') String? phone''',
      () => expect(
        code,
        generates(
          r'''phone: json.safeString('phone') ?? (throw FormatException('phone is required'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads @DtoRequired() String? other2',
      () => expect(
        code,
        generates(
          r'''other2: json.safeString('other2') ?? (throw FormatException( 'Required field "other2" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'User.fromJson reads @DtoIgnore.toJson() String? onlyIn',
      () => expect(code, generates(r'''onlyIn: json.safeString('onlyIn')''')),
    );
    test(
      'User.toJson writes int id',
      () => expect(code, generates(r''''id': instance.id''')),
    );
    test(
      'User.toJson writes int? age',
      () => expect(code, generates(r''''age': instance.age''')),
    );
    test(
      'User.toJson writes double? score',
      () => expect(code, generates(r''''score': instance.score''')),
    );
    test(
      'User.toJson writes double ratio',
      () => expect(code, generates(r''''ratio': instance.ratio''')),
    );
    test(
      'User.toJson writes bool? active',
      () => expect(code, generates(r''''active': instance.active''')),
    );
    test(
      'User.toJson writes bool verified',
      () => expect(code, generates(r''''verified': instance.verified''')),
    );
    test(
      'User.toJson writes String? name',
      () => expect(code, generates(r''''name': instance.name''')),
    );
    test(
      r'''User.toJson writes @DtoKey('user_name') String? userName''',
      () => expect(code, generates(r''''user_name': instance.userName''')),
    );
    test(
      r'''User.toJson writes @DtoDefault('') String email''',
      () => expect(code, generates(r''''email': instance.email''')),
    );
    test(
      r'''User.toJson writes @DtoKey('it\'s \$weird\\key') String? weird''',
      () =>
          expect(code, generates(r''''it\'s \$weird\\key': instance.weird''')),
    );
    test(
      'User.toJson writes Status? status',
      () => expect(code, generates(r''''status': instance.status?.name''')),
    );
    test(
      'User.toJson writes @DtoDefault(Status.active) Status status2',
      () => expect(code, generates(r''''status2': instance.status2.name''')),
    );
    test(
      r'''User.toJson writes @DtoKey('role_key', defaultValue: Role.user) Role? role''',
      () => expect(code, generates(r''''role_key': instance.role?.name''')),
    );
    test(
      'User.toJson writes List<Status>? statuses',
      () => expect(
        code,
        generates(
          r''''statuses': instance.statuses?.map((e) => e.name).toList()''',
        ),
      ),
    );
    test(
      'User.toJson writes DateTime? createdAt',
      () => expect(
        code,
        generates(r''''createdAt': instance.createdAt?.toIso8601String()'''),
      ),
    );
    test(
      'User.toJson writes DateTime updatedAt',
      () => expect(
        code,
        generates(r''''updatedAt': instance.updatedAt.toIso8601String()'''),
      ),
    );
    test(
      'User.toJson writes List<DateTime>? dates',
      () => expect(
        code,
        generates(
          r''''dates': instance.dates?.map((e) => e.toIso8601String()).toList()''',
        ),
      ),
    );
    test(
      'User.toJson writes List<DateTime?>? maybeDates',
      () => expect(
        code,
        generates(
          r''''maybeDates': instance.maybeDates?.map((e) => e?.toIso8601String()).toList()''',
        ),
      ),
    );
    test(
      'User.toJson writes Address? address',
      () =>
          expect(code, generates(r''''address': instance.address?.toJson()''')),
    );
    test(
      'User.toJson writes Address home',
      () => expect(code, generates(r''''home': instance.home.toJson()''')),
    );
    test(
      'User.toJson writes List<Address>? addresses',
      () => expect(
        code,
        generates(
          r''''addresses': instance.addresses?.map((e) => e.toJson()).toList()''',
        ),
      ),
    );
    test(
      'User.toJson writes List<Address?>? maybeAddresses',
      () => expect(
        code,
        generates(
          r''''maybeAddresses': instance.maybeAddresses?.map((e) => e?.toJson()).toList()''',
        ),
      ),
    );
    test(
      'User.toJson writes Legacy? legacy',
      () => expect(code, generates(r''''legacy': instance.legacy?.toJson()''')),
    );
    test(
      'User.toJson writes List<int>? ints',
      () => expect(code, generates(r''''ints': instance.ints''')),
    );
    test(
      'User.toJson writes List<int?>? maybeInts',
      () => expect(code, generates(r''''maybeInts': instance.maybeInts''')),
    );
    test(
      'User.toJson writes List<String> tags',
      () => expect(code, generates(r''''tags': instance.tags''')),
    );
    test(
      'User.toJson writes Map<String, dynamic>? extra',
      () => expect(code, generates(r''''extra': instance.extra''')),
    );
    test(
      'User.toJson writes Map<String, int>? counts',
      () => expect(code, generates(r''''counts': instance.counts''')),
    );
    test(
      'User.toJson writes dynamic anything',
      () => expect(code, generates(r''''anything': instance.anything''')),
    );
    test(
      'User.toJson writes Object? obj',
      () => expect(code, generates(r''''obj': instance.obj''')),
    );
    test(
      'User.toJson writes Uri? uri',
      () => expect(code, generates(r''''uri': instance.uri''')),
    );
    test(
      r'''User.toJson writes @DtoKey('limit', defaultValue: 10) int limit''',
      () => expect(code, generates(r''''limit': instance.limit''')),
    );
    test(
      'User.toJson writes @DtoDefault(5) double factor',
      () => expect(code, generates(r''''factor': instance.factor''')),
    );
    test(
      'User.toJson writes @DtoDefault(1.5) double? factor2',
      () => expect(code, generates(r''''factor2': instance.factor2''')),
    );
    test(
      'User.toJson writes @DtoDefault(double.infinity) double maxValue',
      () => expect(code, generates(r''''maxValue': instance.maxValue''')),
    );
    test(
      'User.toJson writes @DtoDefault(true) bool flag',
      () => expect(code, generates(r''''flag': instance.flag''')),
    );
    test(
      r'''User.toJson writes @DtoDefault(<String>['a', 'b']) List<String> defaults''',
      () => expect(code, generates(r''''defaults': instance.defaults''')),
    );
    test(
      r'''User.toJson writes @DtoDefault(<String, int>{'x': 1}) Map<String, int> defaultMap''',
      () => expect(code, generates(r''''defaultMap': instance.defaultMap''')),
    );
    test(
      r'''User.toJson writes @DtoKey.defaultValue('guest') String? kind''',
      () => expect(code, generates(r''''kind': instance.kind''')),
    );
    test(
      'User.toJson writes @DtoKey.required() String? token',
      () => expect(code, generates(r''''token': instance.token''')),
    );
    test(
      r'''User.toJson writes @DtoKey('code', required: true) int? code''',
      () => expect(code, generates(r''''code': instance.code''')),
    );
    test(
      r'''User.toJson writes @DtoRequired(message: 'phone is required') String? phone''',
      () => expect(code, generates(r''''phone': instance.phone''')),
    );
    test(
      'User.toJson writes @DtoRequired() String? other2',
      () => expect(code, generates(r''''other2': instance.other2''')),
    );
    test(
      'User.toJson writes @DtoIgnore.fromJson() String? onlyOut',
      () => expect(code, generates(r''''onlyOut': instance.onlyOut''')),
    );
  });

  group('Address', () {
    test(
      'Address.fromJson reads String? city',
      () => expect(code, generates(r'''city: json.safeString('city')''')),
    );
    test(
      'Address.fromJson reads String street',
      () => expect(
        code,
        generates(
          r'''street: json.safeString('street') ?? (throw FormatException( 'Required field "street" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'Address.toJson writes String? city',
      () => expect(code, generates(r''''city': instance.city''')),
    );
    test(
      'Address.toJson writes String street',
      () => expect(code, generates(r''''street': instance.street''')),
    );
  });

  group('Point', () {
    test(
      'Point.fromJson passes positional argument 1',
      () => expect(
        code,
        generates(
          r'''json.safeInt('x') ?? (throw FormatException('Required field "x" is missing or invalid'))''',
        ),
      ),
    );
    test(
      'Point.fromJson passes positional argument 2',
      () => expect(code, generates(r'''json.safeInt('y')''')),
    );
    test(
      'Point.fromJson passes positional argument 3',
      () => expect(code, generates(r'''json.safeInt('other')''')),
    );
    test(
      'Point.fromJson passes positional argument 4',
      () => expect(code, generates(r'''json.safeInt('that')''')),
    );
    test(
      'Point.toJson writes int x',
      () => expect(code, generates(r''''x': instance.x''')),
    );
    test(
      'Point.toJson writes int? y',
      () => expect(code, generates(r''''y': instance.y''')),
    );
    test(
      'Point.toJson writes int? other',
      () => expect(code, generates(r''''other': instance.other''')),
    );
    test(
      'Point.toJson writes int? that',
      () => expect(code, generates(r''''that': instance.that''')),
    );
  });

  group('Others', () {
    test(
      'Others.fromJson reads int? other',
      () => expect(code, generates(r'''other: json.safeInt('other')''')),
    );
    test(
      'Others.fromJson reads int? that',
      () => expect(code, generates(r'''that: json.safeInt('that')''')),
    );
    test(
      'Others.fromJson reads int? o',
      () => expect(code, generates(r'''o: json.safeInt('o')''')),
    );
    test(
      'Others.toJson writes int? other',
      () => expect(code, generates(r''''other': instance.other''')),
    );
    test(
      'Others.toJson writes int? that',
      () => expect(code, generates(r''''that': instance.that''')),
    );
    test(
      'Others.toJson writes int? o',
      () => expect(code, generates(r''''o': instance.o''')),
    );
  });

  group('whole classes', () {
    test('logging is skipped with enableLogging: false', () {
      expect(
        code,
        generates(
          r'''Point _$PointFromJson(Map<String, dynamic> json) { return Point(''',
        ),
      );
    });

    test('a skipped positional parameter drops the ones after it', () {
      expect(
        code,
        generates(
          r'''return DtoLogger.parse(json, () => Skipped(), 'Skipped');''',
        ),
      );
    });

    test('a class without fields gets an empty constructor call', () {
      expect(
        code,
        generates(r'''return DtoLogger.parse(json, () => Empty(), 'Empty');'''),
      );
      expect(code, generates('Empty copyWith() => Empty();'));
      expect(code, generates('int get hashValue => 0;'));
    });

    test('generateToJson: false skips toJson', () {
      expect(code, isNot(contains(squash(r'_$EmptyToJson'))));
    });

    test('generateFromJson: false skips fromJson', () {
      expect(code, isNot(contains(squash(r'_$OneFromJson'))));
      expect(
        code,
        generates(
          r"Map<String, dynamic> _$OneToJson(One instance) => <String, dynamic>{'only': instance.only};",
        ),
      );
    });

    test('@DtoIgnore() skips the field both ways', () {
      expect(code, isNot(contains("'localCacheKey'")));
    });

    test('@DtoIgnore.fromJson() only skips reading', () {
      expect(code, isNot(contains("onlyOut:json.safe")));
      expect(code, generates("'onlyOut': instance.onlyOut"));
    });

    test('@DtoIgnore.toJson() only skips writing', () {
      expect(code, generates("onlyIn: json.safeString('onlyIn')"));
      expect(code, isNot(contains("'onlyIn':instance.onlyIn")));
    });

    test('getters and static fields are not fields', () {
      expect(code, isNot(contains('computed')));
      expect(code, isNot(contains('version')));
    });

    test('copyWith keeps positional parameters positional', () {
      expect(
        code,
        generates(
          'return Point(x ?? this.x, y ?? this.y, other ?? this.other, that ?? this.that);',
        ),
      );
    });

    test('copyWith includes fields ignored by fromJson', () {
      expect(
        code,
        generates('return Skipped(a ?? this.a, b ?? this.b, c ?? this.c);'),
      );
    });

    test('copyWith makes every parameter nullable', () {
      expect(
        code,
        generates('Address copyWith({String? city, String? street})'),
      );
    });

    test('equality compares every field', () {
      expect(
        code,
        generates(
          'return other is Address && other.city == city && other.street == street;',
        ),
      );
      expect(
        code,
        generates('int get hashValue => Object.hash(city, street);'),
      );
    });

    test('equality picks a parameter name no field uses', () {
      expect(code, generates('bool equals(Object o)'));
      expect(code, generates('bool equals(Object otherObject)'));
    });

    test('equality with one field uses its hashCode', () {
      expect(code, generates('int get hashValue => only.hashCode;'));
    });

    test('equality with more than 20 fields uses Object.hashAll', () {
      expect(
        code,
        generates('int get hashValue => Object.hashAll([f1, f2, f3'),
      );
    });
  });

  group('errors', () {
    test('@DtoLog on something that is not a class', () async {
      expect(
        await generateError('@DtoLog()\nconst int notAClass = 1;'),
        contains('@DtoLog can only be applied to classes.'),
      );
    });

    test('@DtoLog on a generic class', () async {
      expect(
        await generateError('''
@DtoLog()
class Box<T> {
  final T? value;
  Box({this.value});
}
'''),
        contains('@DtoLog does not support generic classes.'),
      );
    });

    test('nested class without fromJson', () async {
      expect(
        await generateError('''
class Plain {
  final int? a;
  Plain(this.a);
}

@DtoLog()
class Holder {
  final Plain? plain;
  Holder({this.plain});
}
'''),
        contains('Plain is used by plain but has no fromJson.'),
      );
    });

    test('list of a nested class without fromJson', () async {
      expect(
        await generateError('''
class Plain {
  final int? a;
  Plain(this.a);
}

@DtoLog()
class Holder {
  final List<Plain>? plains;
  Holder({this.plains});
}
'''),
        contains('Plain is used by plains but has no fromJson.'),
      );
    });

    test('default value of the wrong type', () async {
      expect(
        await generateError('''
@DtoLog()
class BadDefault {
  @DtoDefault('x')
  final int? count;
  BadDefault({this.count});
}
'''),
        contains(
          "Default value of type String can't be assigned to int? count.",
        ),
      );
    });

    test('class without an unnamed constructor', () async {
      expect(
        await generateError('''
@DtoLog()
class NoCtor {
  final int? a;
  NoCtor.named(this.a);
}
'''),
        contains('NoCtor needs an unnamed constructor for fromJson.'),
      );
    });

    test('required constructor parameter for an ignored field', () async {
      expect(
        await generateError('''
@DtoLog()
class ReqParam {
  @DtoIgnore()
  final int a;
  ReqParam({required this.a});
}
'''),
        contains('Constructor parameter "a" of ReqParam is required'),
      );
    });

    test('default value that is not a literal', () async {
      expect(
        await generateError('''
@DtoLog()
class Unsupported {
  @DtoDefault(Duration.zero)
  final Duration? d;
  Unsupported({this.d});
}
'''),
        contains('Unsupported default value.'),
      );
    });
  });
}

const _models = r'''
enum Status { active, blocked }

enum Role { admin, user }

@DtoLog(generateCopyWith: true, generateEquality: true)
class Address {
  final String? city;
  final String street;

  Address({this.city, required this.street});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

class Legacy {
  final int? a;
  Legacy(this.a);
  static Legacy fromJson(Map<String, dynamic> json) => Legacy(json['a'] as int?);
  Map<String, dynamic> toJson() => {'a': a};
}

@DtoLog(generateCopyWith: true, generateEquality: true)
class User {
  final int id;
  final int? age;
  final double? score;
  final double ratio;
  final bool? active;
  final bool verified;
  final String? name;
  @DtoKey('user_name')
  final String? userName;
  @DtoDefault('')
  final String email;
  @DtoKey('it\'s \$weird\\key')
  final String? weird;
  final Status? status;
  @DtoDefault(Status.active)
  final Status status2;
  @DtoKey('role_key', defaultValue: Role.user)
  final Role? role;
  final List<Status>? statuses;
  final DateTime? createdAt;
  final DateTime updatedAt;
  final List<DateTime>? dates;
  final List<DateTime?>? maybeDates;
  final Address? address;
  final Address home;
  final List<Address>? addresses;
  final List<Address?>? maybeAddresses;
  final Legacy? legacy;
  final List<int>? ints;
  final List<int?>? maybeInts;
  final List<String> tags;
  final Map<String, dynamic>? extra;
  final Map<String, int>? counts;
  final dynamic anything;
  final Object? obj;
  final Uri? uri;
  @DtoKey('limit', defaultValue: 10)
  final int limit;
  @DtoDefault(5)
  final double factor;
  @DtoDefault(1.5)
  final double? factor2;
  @DtoDefault(double.infinity)
  final double maxValue;
  @DtoDefault(true)
  final bool flag;
  @DtoDefault(<String>['a', 'b'])
  final List<String> defaults;
  @DtoDefault(<String, int>{'x': 1})
  final Map<String, int> defaultMap;
  @DtoKey.defaultValue('guest')
  final String? kind;
  @DtoKey.required()
  final String? token;
  @DtoKey('code', required: true)
  final int? code;
  @DtoRequired(message: 'phone is required')
  final String? phone;
  @DtoRequired()
  final String? other2;
  @DtoIgnore()
  final String? localCacheKey;
  @DtoIgnore.fromJson()
  final String? onlyOut;
  @DtoIgnore.toJson()
  final String? onlyIn;
  static const version = 1;
  String get computed => 'x';

  User({
    required this.id,
    this.age,
    this.score,
    required this.ratio,
    this.active,
    required this.verified,
    this.name,
    this.userName,
    required this.email,
    this.weird,
    this.status,
    required this.status2,
    this.role,
    this.statuses,
    this.createdAt,
    required this.updatedAt,
    this.dates,
    this.maybeDates,
    this.address,
    required this.home,
    this.addresses,
    this.maybeAddresses,
    this.legacy,
    this.ints,
    this.maybeInts,
    required this.tags,
    this.extra,
    this.counts,
    this.anything,
    this.obj,
    this.uri,
    required this.limit,
    required this.factor,
    this.factor2,
    required this.maxValue,
    required this.flag,
    required this.defaults,
    required this.defaultMap,
    this.kind,
    this.token,
    this.code,
    this.phone,
    this.other2,
    this.localCacheKey,
    this.onlyOut,
    this.onlyIn,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@DtoLog(generateEquality: true, generateCopyWith: true, enableLogging: false)
class Point {
  final int x;
  final int? y;
  final int? other;
  final int? that;

  Point(this.x, [this.y, this.other, this.that]);

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);
  Map<String, dynamic> toJson() => _$PointToJson(this);
}

@DtoLog(generateEquality: true, generateCopyWith: true)
class Skipped {
  @DtoIgnore()
  final int? a;
  final int? b;
  final int? c;

  Skipped([this.a, this.b, this.c]);

  factory Skipped.fromJson(Map<String, dynamic> json) =>
      _$SkippedFromJson(json);
}

@DtoLog(generateToJson: false, generateEquality: true, generateCopyWith: true)
class Empty {
  Empty();
  factory Empty.fromJson(Map<String, dynamic> json) => _$EmptyFromJson(json);
}

@DtoLog(generateFromJson: false, generateEquality: true)
class One {
  final String? only;
  One(this.only);
  Map<String, dynamic> toJson() => _$OneToJson(this);
}

@DtoLog(generateEquality: true)
class Wide {
  final int? f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11;
  final int? f12, f13, f14, f15, f16, f17, f18, f19, f20, f21;
  Wide({
    this.f1, this.f2, this.f3, this.f4, this.f5, this.f6, this.f7, this.f8,
    this.f9, this.f10, this.f11, this.f12, this.f13, this.f14, this.f15,
    this.f16, this.f17, this.f18, this.f19, this.f20, this.f21,
  });
  factory Wide.fromJson(Map<String, dynamic> json) => _$WideFromJson(json);
  Map<String, dynamic> toJson() => _$WideToJson(this);
}

@DtoLog(generateEquality: true)
class Others {
  final int? other;
  final int? that;
  final int? o;
  Others({this.other, this.that, this.o});
  factory Others.fromJson(Map<String, dynamic> json) => _$OthersFromJson(json);
}
''';
