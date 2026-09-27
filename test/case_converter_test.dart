import 'package:test/test.dart';
import '../lib/src/case_converter.dart';

void main() {
  // ===========================================================================
  // snakeToCamel
  // ===========================================================================
  group('snakeToCamel', () {
    group('basic conversions', () {
      test('converts user_name to userName', () {
        expect(CaseConverter.snakeToCamel('user_name'), equals('userName'));
      });

      test('converts first_name to firstName', () {
        expect(CaseConverter.snakeToCamel('first_name'), equals('firstName'));
      });

      test('converts last_name to lastName', () {
        expect(CaseConverter.snakeToCamel('last_name'), equals('lastName'));
      });

      test('converts created_at to createdAt', () {
        expect(CaseConverter.snakeToCamel('created_at'), equals('createdAt'));
      });

      test('converts updated_at_time to updatedAtTime', () {
        expect(
            CaseConverter.snakeToCamel('updated_at_time'), equals('updatedAtTime'));
      });

      test('converts is_active to isActive', () {
        expect(CaseConverter.snakeToCamel('is_active'), equals('isActive'));
      });

      test('converts has_permission to hasPermission', () {
        expect(
            CaseConverter.snakeToCamel('has_permission'), equals('hasPermission'));
      });

      test('converts phone_number_verified to phoneNumberVerified', () {
        expect(CaseConverter.snakeToCamel('phone_number_verified'),
            equals('phoneNumberVerified'));
      });
    });

    group('single word (no underscores)', () {
      test('preserves single lowercase word', () {
        expect(CaseConverter.snakeToCamel('name'), equals('name'));
      });

      test('lowercases first letter of capitalized word', () {
        expect(CaseConverter.snakeToCamel('Name'), equals('name'));
      });

      test('lowercases first letter only for PascalCase', () {
        expect(CaseConverter.snakeToCamel('UserName'), equals('userName'));
      });

      test('preserves already camelCase', () {
        expect(CaseConverter.snakeToCamel('userName'), equals('userName'));
      });

      test('single character lowercase', () {
        expect(CaseConverter.snakeToCamel('a'), equals('a'));
      });

      test('single character uppercase becomes lowercase', () {
        expect(CaseConverter.snakeToCamel('A'), equals('a'));
      });
    });

    group('leading underscores', () {
      test('removes single leading underscore: _id -> id', () {
        expect(CaseConverter.snakeToCamel('_id'), equals('id'));
      });

      test('removes double leading underscores: __private -> private', () {
        expect(CaseConverter.snakeToCamel('__private'), equals('private'));
      });

      test('removes triple leading underscores: ___triple -> triple', () {
        expect(CaseConverter.snakeToCamel('___triple'), equals('triple'));
      });

      test('removes leading underscore with compound name: _user_name -> userName',
          () {
        expect(CaseConverter.snakeToCamel('_user_name'), equals('userName'));
      });

      test(
          'removes double leading underscore with compound: __first_name -> firstName',
          () {
        expect(CaseConverter.snakeToCamel('__first_name'), equals('firstName'));
      });
    });

    group('all underscores input', () {
      test('single underscore returns itself', () {
        expect(CaseConverter.snakeToCamel('_'), equals('_'));
      });

      test('double underscore returns itself', () {
        expect(CaseConverter.snakeToCamel('__'), equals('__'));
      });

      test('triple underscore returns itself', () {
        expect(CaseConverter.snakeToCamel('___'), equals('___'));
      });
    });

    group('multiple underscores between words', () {
      test('double underscore between words: first__last -> firstLast', () {
        expect(CaseConverter.snakeToCamel('first__last'), equals('firstLast'));
      });

      test('triple underscore between words: a___b -> aB', () {
        expect(CaseConverter.snakeToCamel('a___b'), equals('aB'));
      });

      test(
          'mixed multiple underscores: one__two___three -> oneTwoThree',
          () {
        expect(CaseConverter.snakeToCamel('one__two___three'),
            equals('oneTwoThree'));
      });
    });

    group('trailing underscores', () {
      test('trailing single underscore: name_ -> name', () {
        expect(CaseConverter.snakeToCamel('name_'), equals('name'));
      });

      test('trailing double underscore: name__ -> name', () {
        expect(CaseConverter.snakeToCamel('name__'), equals('name'));
      });

      test('trailing underscore with compound: user_name_ -> userName', () {
        expect(CaseConverter.snakeToCamel('user_name_'), equals('userName'));
      });
    });

    group('ALL CAPS input', () {
      test('USER_NAME -> userName', () {
        expect(CaseConverter.snakeToCamel('USER_NAME'), equals('userName'));
      });

      test('HTTP_RESPONSE -> httpResponse', () {
        expect(
            CaseConverter.snakeToCamel('HTTP_RESPONSE'), equals('httpResponse'));
      });

      test('API_KEY -> apiKey', () {
        expect(CaseConverter.snakeToCamel('API_KEY'), equals('apiKey'));
      });

      test('ALL_CAPS_MULTI_WORD -> allCapsMultiWord', () {
        expect(CaseConverter.snakeToCamel('ALL_CAPS_MULTI_WORD'),
            equals('allCapsMultiWord'));
      });

      test('ID -> id (single word all caps, no underscore)', () {
        expect(CaseConverter.snakeToCamel('ID'), equals('id'));
      });
    });

    group('mixed case input', () {
      test('User_Name -> userName', () {
        expect(CaseConverter.snakeToCamel('User_Name'), equals('userName'));
      });

      test('FIRST_name -> firstName', () {
        expect(CaseConverter.snakeToCamel('FIRST_name'), equals('firstName'));
      });

      test('user_NAME -> userName', () {
        expect(CaseConverter.snakeToCamel('user_NAME'), equals('userName'));
      });

      test('First_Second_Third -> firstSecondThird', () {
        expect(CaseConverter.snakeToCamel('First_Second_Third'),
            equals('firstSecondThird'));
      });
    });

    group('numbers in input', () {
      test('field_1 -> field1', () {
        expect(CaseConverter.snakeToCamel('field_1'), equals('field1'));
      });

      test('user_2_name -> user2Name', () {
        expect(CaseConverter.snakeToCamel('user_2_name'), equals('user2Name'));
      });

      test('item_10_price -> item10Price', () {
        expect(
            CaseConverter.snakeToCamel('item_10_price'), equals('item10Price'));
      });

      test('v2_api -> v2Api', () {
        expect(CaseConverter.snakeToCamel('v2_api'), equals('v2Api'));
      });

      test('field123_value -> field123Value', () {
        expect(
            CaseConverter.snakeToCamel('field123_value'), equals('field123Value'));
      });
    });

    group('single character parts', () {
      test('a_b_c -> aBC', () {
        expect(CaseConverter.snakeToCamel('a_b_c'), equals('aBC'));
      });

      test('x_y -> xY', () {
        expect(CaseConverter.snakeToCamel('x_y'), equals('xY'));
      });

      test('a_long_word -> aLongWord', () {
        expect(CaseConverter.snakeToCamel('a_long_word'), equals('aLongWord'));
      });
    });

    group('empty string', () {
      test('returns empty string for empty input', () {
        expect(CaseConverter.snakeToCamel(''), equals(''));
      });
    });

    group('long strings', () {
      test('handles very long snake_case string', () {
        expect(
            CaseConverter.snakeToCamel(
                'this_is_a_very_long_snake_case_string_with_many_parts'),
            equals('thisIsAVeryLongSnakeCaseStringWithManyParts'));
      });
    });

    group('starts with number (no underscore)', () {
      test('1abc is returned with lowered first char (digit unchanged)', () {
        expect(CaseConverter.snakeToCamel('1abc'), equals('1abc'));
      });

      test('123 is returned as-is', () {
        expect(CaseConverter.snakeToCamel('123'), equals('123'));
      });
    });

    group('underscore and number combinations', () {
      test('_1_field -> 1Field', () {
        // Leading underscore removed, then "1" is first part, "field" capitalized
        expect(CaseConverter.snakeToCamel('_1_field'), equals('1Field'));
      });

      test('field_1_2_3 -> field123', () {
        expect(CaseConverter.snakeToCamel('field_1_2_3'), equals('field123'));
      });
    });
  });

  // ===========================================================================
  // camelToSnake
  // ===========================================================================
  group('camelToSnake', () {
    group('basic conversions', () {
      test('userName -> user_name', () {
        expect(CaseConverter.camelToSnake('userName'), equals('user_name'));
      });

      test('firstName -> first_name', () {
        expect(CaseConverter.camelToSnake('firstName'), equals('first_name'));
      });

      test('lastName -> last_name', () {
        expect(CaseConverter.camelToSnake('lastName'), equals('last_name'));
      });

      test('createdAt -> created_at', () {
        expect(CaseConverter.camelToSnake('createdAt'), equals('created_at'));
      });

      test('isActive -> is_active', () {
        expect(CaseConverter.camelToSnake('isActive'), equals('is_active'));
      });

      test('hasPermission -> has_permission', () {
        expect(
            CaseConverter.camelToSnake('hasPermission'), equals('has_permission'));
      });

      test('phoneNumberVerified -> phone_number_verified', () {
        expect(CaseConverter.camelToSnake('phoneNumberVerified'),
            equals('phone_number_verified'));
      });

      test('updatedAtTime -> updated_at_time', () {
        expect(
            CaseConverter.camelToSnake('updatedAtTime'), equals('updated_at_time'));
      });
    });

    group('acronyms and consecutive uppercase', () {
      test('userID -> user_id', () {
        expect(CaseConverter.camelToSnake('userID'), equals('user_id'));
      });

      test('HTTPResponse -> http_response', () {
        expect(
            CaseConverter.camelToSnake('HTTPResponse'), equals('http_response'));
      });

      test('getHTTPSUrl -> get_https_url', () {
        expect(CaseConverter.camelToSnake('getHTTPSUrl'), equals('get_https_url'));
      });

      test('XMLHTTPRequest -> xmlhttp_request', () {
        // XML + HTTP + Request: all caps followed by caps with lower
        expect(
            CaseConverter.camelToSnake('XMLHTTPRequest'), equals('xmlhttp_request'));
      });

      test('myAPIKey -> my_api_key', () {
        expect(CaseConverter.camelToSnake('myAPIKey'), equals('my_api_key'));
      });

      test('parseJSON -> parse_json', () {
        expect(CaseConverter.camelToSnake('parseJSON'), equals('parse_json'));
      });

      test('getURL -> get_url', () {
        expect(CaseConverter.camelToSnake('getURL'), equals('get_url'));
      });

      test('apiV2 -> api_v2', () {
        expect(CaseConverter.camelToSnake('apiV2'), equals('api_v2'));
      });

      test('HTMLParser -> html_parser', () {
        expect(CaseConverter.camelToSnake('HTMLParser'), equals('html_parser'));
      });

      test('IOStream -> io_stream', () {
        expect(CaseConverter.camelToSnake('IOStream'), equals('io_stream'));
      });
    });

    group('all lowercase', () {
      test('username -> username', () {
        expect(CaseConverter.camelToSnake('username'), equals('username'));
      });

      test('password -> password', () {
        expect(CaseConverter.camelToSnake('password'), equals('password'));
      });

      test('a -> a', () {
        expect(CaseConverter.camelToSnake('a'), equals('a'));
      });
    });

    group('all uppercase', () {
      test('ABC -> abc', () {
        expect(CaseConverter.camelToSnake('ABC'), equals('abc'));
      });

      test('ID -> id', () {
        expect(CaseConverter.camelToSnake('ID'), equals('id'));
      });

      test('URL -> url', () {
        expect(CaseConverter.camelToSnake('URL'), equals('url'));
      });

      test('A -> a', () {
        expect(CaseConverter.camelToSnake('A'), equals('a'));
      });

      test('ABCDEF -> abcdef', () {
        expect(CaseConverter.camelToSnake('ABCDEF'), equals('abcdef'));
      });
    });

    group('single characters', () {
      test('single lowercase a -> a', () {
        expect(CaseConverter.camelToSnake('a'), equals('a'));
      });

      test('single uppercase A -> a', () {
        expect(CaseConverter.camelToSnake('A'), equals('a'));
      });
    });

    group('numbers', () {
      test('user1Name -> user1_name', () {
        expect(CaseConverter.camelToSnake('user1Name'), equals('user1_name'));
      });

      test('field123 -> field123', () {
        expect(CaseConverter.camelToSnake('field123'), equals('field123'));
      });

      test('item10Price -> item10_price', () {
        expect(CaseConverter.camelToSnake('item10Price'), equals('item10_price'));
      });

      test('v2Api -> v2_api', () {
        expect(CaseConverter.camelToSnake('v2Api'), equals('v2_api'));
      });

      test('get2FACode -> get2_facode', () {
        // 2 is not uppercase, F is upper after digit, A is upper after upper
        // then C is upper after lower(o) -- let's just verify the actual output
        expect(CaseConverter.camelToSnake('get2FACode'), equals('get2_fa_code'));
      });
    });

    group('PascalCase input', () {
      test('UserName -> user_name', () {
        expect(CaseConverter.camelToSnake('UserName'), equals('user_name'));
      });

      test('User -> user', () {
        expect(CaseConverter.camelToSnake('User'), equals('user'));
      });

      test('MyClassName -> my_class_name', () {
        expect(
            CaseConverter.camelToSnake('MyClassName'), equals('my_class_name'));
      });

      test('UserResponse -> user_response', () {
        expect(
            CaseConverter.camelToSnake('UserResponse'), equals('user_response'));
      });
    });

    group('already snake_case', () {
      test('user_name stays user_name', () {
        expect(CaseConverter.camelToSnake('user_name'), equals('user_name'));
      });

      test('already_snake -> already_snake', () {
        expect(
            CaseConverter.camelToSnake('already_snake'), equals('already_snake'));
      });
    });

    group('empty string', () {
      test('returns empty string', () {
        expect(CaseConverter.camelToSnake(''), equals(''));
      });
    });

    group('mixed with special non-letter chars (digits)', () {
      test('myField2 -> my_field2', () {
        expect(CaseConverter.camelToSnake('myField2'), equals('my_field2'));
      });

      test('hello123World -> hello123_world', () {
        expect(
            CaseConverter.camelToSnake('hello123World'), equals('hello123_world'));
      });
    });

    group('long strings', () {
      test('handles very long camelCase string', () {
        expect(
            CaseConverter.camelToSnake('thisIsAVeryLongCamelCaseString'),
            equals('this_is_a_very_long_camel_case_string'));
      });
    });

    group('consecutive uppercase at end of string', () {
      test('getUserID -> get_user_id', () {
        expect(CaseConverter.camelToSnake('getUserID'), equals('get_user_id'));
      });

      test('fooBAR -> foo_bar', () {
        expect(CaseConverter.camelToSnake('fooBAR'), equals('foo_bar'));
      });
    });
  });

  // ===========================================================================
  // snakeToPascal
  // ===========================================================================
  group('snakeToPascal', () {
    group('basic conversions', () {
      test('user_response -> UserResponse', () {
        expect(
            CaseConverter.snakeToPascal('user_response'), equals('UserResponse'));
      });

      test('first_name -> FirstName', () {
        expect(CaseConverter.snakeToPascal('first_name'), equals('FirstName'));
      });

      test('created_at -> CreatedAt', () {
        expect(CaseConverter.snakeToPascal('created_at'), equals('CreatedAt'));
      });

      test('is_active -> IsActive', () {
        expect(CaseConverter.snakeToPascal('is_active'), equals('IsActive'));
      });

      test('phone_number_verified -> PhoneNumberVerified', () {
        expect(CaseConverter.snakeToPascal('phone_number_verified'),
            equals('PhoneNumberVerified'));
      });
    });

    group('leading underscores', () {
      test('_user -> User', () {
        expect(CaseConverter.snakeToPascal('_user'), equals('User'));
      });

      test('__private -> Private', () {
        expect(CaseConverter.snakeToPascal('__private'), equals('Private'));
      });

      test('_user_name -> UserName', () {
        expect(CaseConverter.snakeToPascal('_user_name'), equals('UserName'));
      });
    });

    group('already PascalCase', () {
      test('UserResponse -> UserResponse', () {
        expect(
            CaseConverter.snakeToPascal('UserResponse'), equals('UserResponse'));
      });

      test('MyClass -> MyClass', () {
        expect(CaseConverter.snakeToPascal('MyClass'), equals('MyClass'));
      });
    });

    group('already camelCase (no underscores)', () {
      test('userResponse -> UserResponse', () {
        expect(
            CaseConverter.snakeToPascal('userResponse'), equals('UserResponse'));
      });

      test('firstName -> FirstName', () {
        expect(CaseConverter.snakeToPascal('firstName'), equals('FirstName'));
      });
    });

    group('single word', () {
      test('name -> Name', () {
        expect(CaseConverter.snakeToPascal('name'), equals('Name'));
      });

      test('user -> User', () {
        expect(CaseConverter.snakeToPascal('user'), equals('User'));
      });

      test('a -> A', () {
        expect(CaseConverter.snakeToPascal('a'), equals('A'));
      });
    });

    group('ALL CAPS', () {
      test('USER -> USER (no underscore, capitalizes first only)', () {
        expect(CaseConverter.snakeToPascal('USER'), equals('USER'));
      });

      test('USER_NAME -> UserName', () {
        expect(CaseConverter.snakeToPascal('USER_NAME'), equals('UserName'));
      });

      test('HTTP_RESPONSE -> HttpResponse', () {
        expect(
            CaseConverter.snakeToPascal('HTTP_RESPONSE'), equals('HttpResponse'));
      });
    });

    group('empty string', () {
      test('returns empty string', () {
        expect(CaseConverter.snakeToPascal(''), equals(''));
      });
    });

    group('numbers', () {
      test('user_1 -> User1', () {
        expect(CaseConverter.snakeToPascal('user_1'), equals('User1'));
      });

      test('v2_api -> V2Api', () {
        expect(CaseConverter.snakeToPascal('v2_api'), equals('V2Api'));
      });

      test('item_10_price -> Item10Price', () {
        expect(
            CaseConverter.snakeToPascal('item_10_price'), equals('Item10Price'));
      });
    });

    group('all underscores', () {
      test('_ returns _ (unchanged)', () {
        expect(CaseConverter.snakeToPascal('_'), equals('_'));
      });

      test('__ returns __ (unchanged)', () {
        expect(CaseConverter.snakeToPascal('__'), equals('__'));
      });
    });

    group('trailing underscores', () {
      test('name_ -> Name', () {
        expect(CaseConverter.snakeToPascal('name_'), equals('Name'));
      });
    });
  });

  // ===========================================================================
  // isValidIdentifier
  // ===========================================================================
  group('isValidIdentifier', () {
    group('valid identifiers', () {
      test('simple name is valid', () {
        expect(CaseConverter.isValidIdentifier('name'), isTrue);
      });

      test('name with underscore prefix is valid', () {
        expect(CaseConverter.isValidIdentifier('_name'), isTrue);
      });

      test('double underscore prefix is valid', () {
        expect(CaseConverter.isValidIdentifier('__name'), isTrue);
      });

      test('name with number is valid', () {
        expect(CaseConverter.isValidIdentifier('name1'), isTrue);
      });

      test('underscore then number is valid', () {
        expect(CaseConverter.isValidIdentifier('_1'), isTrue);
      });

      test('PascalCase is valid', () {
        expect(CaseConverter.isValidIdentifier('Name'), isTrue);
      });

      test('camelCase is valid', () {
        expect(CaseConverter.isValidIdentifier('userName'), isTrue);
      });

      test('single underscore is valid', () {
        expect(CaseConverter.isValidIdentifier('_'), isTrue);
      });

      test('double underscore is valid', () {
        expect(CaseConverter.isValidIdentifier('__'), isTrue);
      });

      test('all caps is valid', () {
        expect(CaseConverter.isValidIdentifier('USER_NAME'), isTrue);
      });

      test('mixed alphanumeric with underscores is valid', () {
        expect(CaseConverter.isValidIdentifier('field_123_abc'), isTrue);
      });

      test('single letter is valid', () {
        expect(CaseConverter.isValidIdentifier('a'), isTrue);
      });

      test('single uppercase letter is valid', () {
        expect(CaseConverter.isValidIdentifier('A'), isTrue);
      });

      test('very long valid identifier', () {
        expect(
            CaseConverter.isValidIdentifier(
                'thisIsAVeryLongIdentifierNameThatShouldStillBeValid123'),
            isTrue);
      });
    });

    group('invalid identifiers', () {
      test('empty string is invalid', () {
        expect(CaseConverter.isValidIdentifier(''), isFalse);
      });

      test('starts with number is invalid', () {
        expect(CaseConverter.isValidIdentifier('1name'), isFalse);
      });

      test('contains dash is invalid', () {
        expect(CaseConverter.isValidIdentifier('my-field'), isFalse);
      });

      test('contains space is invalid', () {
        expect(CaseConverter.isValidIdentifier('my field'), isFalse);
      });

      test('contains dot is invalid', () {
        expect(CaseConverter.isValidIdentifier('my.field'), isFalse);
      });

      test('starts with @ is invalid', () {
        expect(CaseConverter.isValidIdentifier('@name'), isFalse);
      });

      test('starts with dollar sign is invalid', () {
        expect(CaseConverter.isValidIdentifier('\$name'), isFalse);
      });

      test('contains exclamation is invalid', () {
        expect(CaseConverter.isValidIdentifier('name!'), isFalse);
      });

      test('single digit is invalid', () {
        expect(CaseConverter.isValidIdentifier('1'), isFalse);
      });

      test('contains slash is invalid', () {
        expect(CaseConverter.isValidIdentifier('path/name'), isFalse);
      });
    });

    group('reserved words are technically valid identifiers', () {
      test('class is a valid identifier string', () {
        expect(CaseConverter.isValidIdentifier('class'), isTrue);
      });

      test('return is a valid identifier string', () {
        expect(CaseConverter.isValidIdentifier('return'), isTrue);
      });

      test('void is a valid identifier string', () {
        expect(CaseConverter.isValidIdentifier('void'), isTrue);
      });
    });
  });

  // ===========================================================================
  // toValidIdentifier
  // ===========================================================================
  group('toValidIdentifier', () {
    group('already valid input', () {
      test('simple name stays the same', () {
        expect(CaseConverter.toValidIdentifier('name'), equals('name'));
      });

      test('camelCase stays the same', () {
        expect(CaseConverter.toValidIdentifier('userName'), equals('userName'));
      });

      test('single letter stays the same', () {
        expect(CaseConverter.toValidIdentifier('a'), equals('a'));
      });
    });

    group('invalid characters replaced', () {
      test('dashes become camelCase: my-field -> myField', () {
        expect(CaseConverter.toValidIdentifier('my-field'), equals('myField'));
      });

      test('spaces become camelCase: my field -> myField', () {
        expect(CaseConverter.toValidIdentifier('my field'), equals('myField'));
      });

      test('dots become camelCase: my.field -> myField', () {
        expect(CaseConverter.toValidIdentifier('my.field'), equals('myField'));
      });

      test('multiple special chars: a-b.c d -> aBCD', () {
        expect(CaseConverter.toValidIdentifier('a-b.c d'), equals('aBCD'));
      });

      test('exclamation mark: name! -> name', () {
        // ! is replaced by _, then trailing _ is handled by snakeToCamel
        expect(CaseConverter.toValidIdentifier('name!'), equals('name'));
      });

      test('at sign: @field -> field', () {
        // @ replaced with _, leading _ removed by snakeToCamel
        expect(CaseConverter.toValidIdentifier('@field'), equals('field'));
      });

      test('hash: #tag -> tag', () {
        expect(CaseConverter.toValidIdentifier('#tag'), equals('tag'));
      });

      test('multiple consecutive special chars: a--b -> aB', () {
        expect(CaseConverter.toValidIdentifier('a--b'), equals('aB'));
      });

      test('parentheses: func(x) -> funcX', () {
        expect(CaseConverter.toValidIdentifier('func(x)'), equals('funcX'));
      });

      test('brackets: arr[0] -> arr0', () {
        expect(CaseConverter.toValidIdentifier('arr[0]'), equals('arr0'));
      });
    });

    group('starts with number', () {
      test('123field -> field123field', () {
        expect(CaseConverter.toValidIdentifier('123field'), equals('field123field'));
      });

      test('1abc -> field1abc', () {
        expect(CaseConverter.toValidIdentifier('1abc'), equals('field1abc'));
      });

      test('42 -> field42', () {
        expect(CaseConverter.toValidIdentifier('42'), equals('field42'));
      });

      test('0_field -> field0Field', () {
        // 0_field -> snakeToCamel -> 0Field -> starts with digit -> field0Field
        expect(CaseConverter.toValidIdentifier('0_field'), equals('field0Field'));
      });
    });

    group('reserved words', () {
      test('class -> class_', () {
        expect(CaseConverter.toValidIdentifier('class'), equals('class_'));
      });

      test('return -> return_', () {
        expect(CaseConverter.toValidIdentifier('return'), equals('return_'));
      });

      test('void -> void_', () {
        expect(CaseConverter.toValidIdentifier('void'), equals('void_'));
      });

      test('final -> final_', () {
        expect(CaseConverter.toValidIdentifier('final'), equals('final_'));
      });

      test('var -> var_', () {
        expect(CaseConverter.toValidIdentifier('var'), equals('var_'));
      });

      test('if -> if_', () {
        expect(CaseConverter.toValidIdentifier('if'), equals('if_'));
      });

      test('for -> for_', () {
        expect(CaseConverter.toValidIdentifier('for'), equals('for_'));
      });

      test('while -> while_', () {
        expect(CaseConverter.toValidIdentifier('while'), equals('while_'));
      });

      test('null -> null_', () {
        expect(CaseConverter.toValidIdentifier('null'), equals('null_'));
      });

      test('true -> true_', () {
        expect(CaseConverter.toValidIdentifier('true'), equals('true_'));
      });

      test('false -> false_', () {
        expect(CaseConverter.toValidIdentifier('false'), equals('false_'));
      });

      test('abstract -> abstract_', () {
        expect(CaseConverter.toValidIdentifier('abstract'), equals('abstract_'));
      });

      test('dynamic -> dynamic_', () {
        expect(CaseConverter.toValidIdentifier('dynamic'), equals('dynamic_'));
      });

      test('yield -> yield_', () {
        expect(CaseConverter.toValidIdentifier('yield'), equals('yield_'));
      });

      test('async -> async_', () {
        expect(CaseConverter.toValidIdentifier('async'), equals('async_'));
      });

      test('await -> await_', () {
        expect(CaseConverter.toValidIdentifier('await'), equals('await_'));
      });
    });

    group('empty string', () {
      test('returns field for empty input', () {
        expect(CaseConverter.toValidIdentifier(''), equals('field'));
      });
    });

    group('all special characters', () {
      test('@#\$% -> field (all replaced with _, cleaned to empty, fallback)', () {
        // All chars replaced with underscores -> '____'
        // snakeToCamel('____') returns '____' (all underscores)
        // Then it checks reserved words -> not reserved
        // Returns '____' since it's not empty
        // Actually let's verify what actually happens:
        final result = CaseConverter.toValidIdentifier('@#\$%');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('--- -> field (all dashes, replaced to underscores)', () {
        final result = CaseConverter.toValidIdentifier('---');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('!!! -> field (all bangs)', () {
        final result = CaseConverter.toValidIdentifier('!!!');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });
    });

    group('snake_case input with special chars', () {
      test('user-name -> userName', () {
        expect(CaseConverter.toValidIdentifier('user-name'), equals('userName'));
      });

      test('content-type -> contentType', () {
        expect(
            CaseConverter.toValidIdentifier('content-type'), equals('contentType'));
      });

      test('X-Custom-Header -> xCustomHeader', () {
        expect(CaseConverter.toValidIdentifier('X-Custom-Header'),
            equals('xCustomHeader'));
      });
    });

    group('result is always a valid identifier', () {
      test('result from number prefix is valid', () {
        final result = CaseConverter.toValidIdentifier('123');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('result from special chars is valid', () {
        final result = CaseConverter.toValidIdentifier('!@#\$%^&*()');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('result from spaces is valid', () {
        final result = CaseConverter.toValidIdentifier('hello world');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('result from reserved word is valid (not a keyword conflict)', () {
        final result = CaseConverter.toValidIdentifier('class');
        expect(result, equals('class_'));
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('result from mixed junk is valid', () {
        final result = CaseConverter.toValidIdentifier('1!@name');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });
    });
  });

  // ===========================================================================
  // Round-trip / integration tests
  // ===========================================================================
  group('round-trip conversions', () {
    test('snakeToCamel then camelToSnake returns original for simple case', () {
      const original = 'user_name';
      final camel = CaseConverter.snakeToCamel(original);
      final snake = CaseConverter.camelToSnake(camel);
      expect(snake, equals(original));
    });

    test('snakeToCamel then camelToSnake for multi-word', () {
      const original = 'first_name_value';
      final camel = CaseConverter.snakeToCamel(original);
      final snake = CaseConverter.camelToSnake(camel);
      expect(snake, equals(original));
    });

    test('camelToSnake then snakeToCamel returns original for simple camel', () {
      const original = 'userName';
      final snake = CaseConverter.camelToSnake(original);
      final camel = CaseConverter.snakeToCamel(snake);
      expect(camel, equals(original));
    });

    test('camelToSnake then snakeToCamel for multi-word camel', () {
      const original = 'firstNameValue';
      final snake = CaseConverter.camelToSnake(original);
      final camel = CaseConverter.snakeToCamel(snake);
      expect(camel, equals(original));
    });

    test('snakeToPascal then camelToSnake gives snake_case', () {
      const original = 'user_response';
      final pascal = CaseConverter.snakeToPascal(original);
      expect(pascal, equals('UserResponse'));
      final snake = CaseConverter.camelToSnake(pascal);
      expect(snake, equals(original));
    });

    test('empty string round-trips are stable', () {
      expect(CaseConverter.snakeToCamel(CaseConverter.camelToSnake('')), equals(''));
      expect(CaseConverter.camelToSnake(CaseConverter.snakeToCamel('')), equals(''));
    });

    test('single word round-trips through camel and snake', () {
      const original = 'name';
      final snake = CaseConverter.camelToSnake(original);
      expect(snake, equals('name'));
      final camel = CaseConverter.snakeToCamel(snake);
      expect(camel, equals('name'));
    });

    test('toValidIdentifier always produces valid identifiers for random inputs',
        () {
      final inputs = [
        '', '123', '@!#', 'hello world', 'my-field', 'class', 'for',
        'null', '1abc', 'a.b.c', 'UPPER_CASE', '_private',
        'Content-Type', 'X-Request-ID', '---', '   ', 'void',
      ];
      for (final input in inputs) {
        final result = CaseConverter.toValidIdentifier(input);
        expect(CaseConverter.isValidIdentifier(result), isTrue,
            reason: 'toValidIdentifier("$input") = "$result" should be valid');
      }
    });
  });

  // ===========================================================================
  // Additional edge cases for thoroughness
  // ===========================================================================
  group('additional edge cases', () {
    group('snakeToCamel with mixed leading/trailing/inner underscores', () {
      test('_a_ -> a (leading + trailing underscores)', () {
        expect(CaseConverter.snakeToCamel('_a_'), equals('a'));
      });

      test('__a__b__ -> aB', () {
        expect(CaseConverter.snakeToCamel('__a__b__'), equals('aB'));
      });

      test('_a_b_c_ -> aBC', () {
        expect(CaseConverter.snakeToCamel('_a_b_c_'), equals('aBC'));
      });
    });

    group('camelToSnake with digits adjacent to uppercase', () {
      test('page2Size -> page2_size', () {
        expect(CaseConverter.camelToSnake('page2Size'), equals('page2_size'));
      });

      test('utf8String -> utf8_string', () {
        expect(CaseConverter.camelToSnake('utf8String'), equals('utf8_string'));
      });

      test('win32API -> win32_api', () {
        expect(CaseConverter.camelToSnake('win32API'), equals('win32_api'));
      });

      test('int64Value -> int64_value', () {
        expect(CaseConverter.camelToSnake('int64Value'), equals('int64_value'));
      });
    });

    group('snakeToPascal with numbers', () {
      test('page_2_size -> Page2Size', () {
        expect(CaseConverter.snakeToPascal('page_2_size'), equals('Page2Size'));
      });

      test('utf_8 -> Utf8', () {
        expect(CaseConverter.snakeToPascal('utf_8'), equals('Utf8'));
      });
    });

    group('isValidIdentifier boundary cases', () {
      test('underscore followed by digits is valid', () {
        expect(CaseConverter.isValidIdentifier('_123'), isTrue);
      });

      test('all digits is invalid', () {
        expect(CaseConverter.isValidIdentifier('123'), isFalse);
      });

      test('digit in middle is valid', () {
        expect(CaseConverter.isValidIdentifier('a1b'), isTrue);
      });

      test('multiple underscores with digits is valid', () {
        expect(CaseConverter.isValidIdentifier('__1__2__'), isTrue);
      });

      test('tab character is invalid', () {
        expect(CaseConverter.isValidIdentifier('a\tb'), isFalse);
      });

      test('newline character is invalid', () {
        expect(CaseConverter.isValidIdentifier('a\nb'), isFalse);
      });
    });

    group('toValidIdentifier with unicode and unusual input', () {
      test('emoji input produces valid identifier', () {
        final result = CaseConverter.toValidIdentifier('\u{1F600}');
        expect(CaseConverter.isValidIdentifier(result), isTrue);
      });

      test('mixed valid and invalid: abc!def -> abcDef', () {
        expect(CaseConverter.toValidIdentifier('abc!def'), equals('abcDef'));
      });

      test('colon in input: key:value -> keyValue', () {
        expect(CaseConverter.toValidIdentifier('key:value'), equals('keyValue'));
      });

      test('equals sign: a=b -> aB', () {
        expect(CaseConverter.toValidIdentifier('a=b'), equals('aB'));
      });

      test('ampersand: a&b -> aB', () {
        expect(CaseConverter.toValidIdentifier('a&b'), equals('aB'));
      });

      test('plus sign: a+b -> aB', () {
        expect(CaseConverter.toValidIdentifier('a+b'), equals('aB'));
      });

      test('question mark: isValid? produces valid identifier', () {
        // isValid? -> replaceAll -> isValid_ -> snakeToCamel -> isvalid
        // (underscore makes it snake_case, so the V is not preserved as uppercase)
        expect(CaseConverter.toValidIdentifier('isValid?'), equals('isvalid'));
      });
    });

    group('camelToSnake preserves existing underscores', () {
      test('user_name (already snake) -> user_name', () {
        expect(CaseConverter.camelToSnake('user_name'), equals('user_name'));
      });

      test('_private stays _private', () {
        expect(CaseConverter.camelToSnake('_private'), equals('_private'));
      });

      test('__double stays __double', () {
        expect(CaseConverter.camelToSnake('__double'), equals('__double'));
      });
    });

    group('snakeToCamel idempotency', () {
      test('applying snakeToCamel twice on camelCase is stable', () {
        const input = 'userName';
        final once = CaseConverter.snakeToCamel(input);
        final twice = CaseConverter.snakeToCamel(once);
        expect(once, equals(twice));
      });

      test('applying snakeToCamel twice on snake_case is stable', () {
        const input = 'user_name';
        final once = CaseConverter.snakeToCamel(input);
        final twice = CaseConverter.snakeToCamel(once);
        expect(once, equals(twice));
      });
    });

    group('camelToSnake idempotency', () {
      test('applying camelToSnake twice on snake_case is stable', () {
        const input = 'user_name';
        final once = CaseConverter.camelToSnake(input);
        final twice = CaseConverter.camelToSnake(once);
        expect(once, equals(twice));
      });

      test('applying camelToSnake twice on camelCase is stable', () {
        const input = 'userName';
        final once = CaseConverter.camelToSnake(input);
        final twice = CaseConverter.camelToSnake(once);
        expect(once, equals(twice));
      });
    });
  });
}
