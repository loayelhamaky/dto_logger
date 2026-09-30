// ignore_for_file: avoid_print

// Run with asserts on to see the logs (they are debug-only):
//   dart run --enable-asserts example/main.dart
import 'package:dto_logger/dto_logger.dart';

void main() {
  // Configure logging
  DtoLogConfig.enabled = true;
  DtoLogConfig.level = DtoLogLevel.verbose;
  DtoLogConfig.useColors = true;
  DtoLogConfig.useDeveloperLog = false; // Use print() for colors to show
  DtoLogConfig.showTiming = true;
  DtoLogConfig.logSuccess = true;

  print('');
  print(
      '╔══════════════════════════════════════════════════════════════════════╗');
  print(
      '║                    DTO Logger - Full Test Suite                      ║');
  print(
      '╚══════════════════════════════════════════════════════════════════════╝');
  print('');

  // Run all tests
  testSafeParser();
  testCaseConverter();
  testApiResponses();
  testGenerator();
}

// Safe Parser - Type Coercion
void testSafeParser() {
  print('');
  print(
      '┌─────────────────────────────────────────────────────────────────────┐');
  print(
      '│  TEST 1: SafeParser - Type Coercion                                 │');
  print(
      '└─────────────────────────────────────────────────────────────────────┘');

  final json = <String, dynamic>{
    'id': '123', // String → int
    'price': 99, // int → double
    'active': 'true', // String → bool
    'count': null, // null handling
    'timestamp': 1704067200, // Unix timestamp → DateTime
    'ratio': '3.14', // String → double
    'enabled': 1, // int → bool
    'disabled': 0, // int → bool
  };

  print('\nInput JSON: $json\n');

  print('Parsing Results:');
  print(
      '  id (String "123" → int):      ${SafeParser.asInt(json['id']).value}');
  print(
      '  price (int 99 → double):      ${SafeParser.asDouble(json['price']).value}');
  print(
      '  active (String "true" → bool): ${SafeParser.asBool(json['active']).value}');
  print(
      '  count (null → int):           ${SafeParser.asInt(json['count']).value}');
  print(
      '  timestamp (Unix → DateTime):  ${SafeParser.asDateTime(json['timestamp']).value}');
  print(
      '  ratio (String "3.14" → double): ${SafeParser.asDouble(json['ratio']).value}');
  print(
      '  enabled (int 1 → bool):       ${SafeParser.asBool(json['enabled']).value}');
  print(
      '  disabled (int 0 → bool):      ${SafeParser.asBool(json['disabled']).value}');

  print('\nExtension Methods on Map:');
  print('  json.safeInt("id"):           ${json.safeInt("id")}');
  print('  json.safeIntOr("count", 0):   ${json.safeIntOr("count", 0)}');
  print(
      '  json.safeBoolOr("active", false): ${json.safeBoolOr("active", false)}');
  print(
      '  json.safeDoubleOr("missing", 1.0): ${json.safeDoubleOr("missing", 1.0)}');
  print('');
}

// Case Converter
void testCaseConverter() {
  print('');
  print(
      '┌─────────────────────────────────────────────────────────────────────┐');
  print(
      '│  TEST 2: CaseConverter                                              │');
  print(
      '└─────────────────────────────────────────────────────────────────────┘');

  print('\nsnake_case → camelCase:');
  final snakeCases = [
    'user_name',
    '_id',
    '__private',
    'USER_NAME',
    'first__last',
    'api_response_data'
  ];
  for (final s in snakeCases) {
    print('  "$s" → "${CaseConverter.snakeToCamel(s)}"');
  }

  print('\ncamelCase preserved (no underscore):');
  final camelCases = ['userId', 'userName', 'isActive', 'createdAt'];
  for (final s in camelCases) {
    print('  "$s" → "${CaseConverter.snakeToCamel(s)}"');
  }

  print('\nTo PascalCase (for class names):');
  final classNames = ['user_response', 'order_item', 'api_data'];
  for (final s in classNames) {
    print('  "$s" → "${CaseConverter.snakeToPascal(s)}"');
  }

  print('\ncamelCase → snake_case:');
  final toSnake = ['userName', 'userId', 'isActive', 'createdAt'];
  for (final s in toSnake) {
    print('  "$s" → "${CaseConverter.camelToSnake(s)}"');
  }
  print('');
}

// API Response Parsing with Logging
void testApiResponses() {
  print('');
  print(
      '┌─────────────────────────────────────────────────────────────────────┐');
  print(
      '│  TEST 3: API Response Parsing (Like pretty_dio_logger)              │');
  print(
      '└─────────────────────────────────────────────────────────────────────┘');

  // Example 1: User API with type coercion warnings
  print('\n${"─" * 70}');
  print('📡 GET /api/users/123');
  print('─' * 70);

  final userJson = {
    'userId': '456', // String instead of int
    'user_name': 'Ahmed Mohamed',
    'email': null, // null
    'is_active': 'true', // String instead of bool
    'age': 28,
    'balance': '1500.50', // String instead of double
    'created_at': 1704067200, // Unix timestamp
    'profile': {
      'avatar': 'https://example.com/avatar.png',
      'bio': null, // null
      'followers': '1000', // String instead of int
    },
  };

  final user = UserResponse.fromJson(userJson);
  print(
      '→ Result: User ${user.userName}, balance: \$${user.balance}, active: ${user.isActive}');

  // Example 2: Order API with nested objects and lists
  print('\n${"─" * 70}');
  print('📡 GET /api/orders/789');
  print('─' * 70);

  final orderJson = {
    'orderId': 789,
    'orderNumber': 'ORD-2024-001',
    'total': '299.99',
    'tax': 15.0,
    'status': 'processing',
    'isPaid': 1,
    'customer': {
      'customerId': 123,
      'name': 'Mohamed Ali',
      'phone': 22,
      'email': 'mohamed@example.com',
    },
    'shippingAddress': {
      'street': '123 Main St',
      'city': 'Cairo',
      'zipCode': 'null',
      'country': 'Egypt',
    },
    'items': [
      {'productId': 1, 'name': 'iPhone 15', 'quantity': 1, 'price': 199.99},
      {'productId': 2, 'name': 'Case', 'quantity': '2', 'price': 49.99},
      {'productId': 3, 'name': 'Charger', 'quantity': 1, 'price': '50.01'},
    ],
  };

  final order = OrderResponse.fromJson(orderJson);
  print(
      '→ Result: Order #${order.orderNumber}, Total: \$${order.total}, Items: ${order.items?.length ?? 0}');

  // Example 3: API response with no issues
  print('\n${"─" * 70}');
  print('📡 GET /api/settings (Perfect data - no warnings)');
  print('─' * 70);

  final settingsJson = {
    'theme': 'dark',
    'language': 'en',
    'notifications': true,
    'fontSize': 16,
    'autoSave': true,
  };

  final settings = SettingsResponse.fromJson(settingsJson);
  print('→ Result: theme=${settings.theme}, lang=${settings.language}');

  // Example 4: Product with missing/bad data
  print('\n${"─" * 70}');
  print('📡 GET /api/products/999 (Bad API response)');
  print('─' * 70);

  final productJson = {
    'id': 999,
    // 'name': MISSING!
    'price': 'not_a_number', // Can't parse
    'inStock': 'yes', // String "yes" → bool
    'rating': null, // null
  };

  final product = ProductResponse.fromJson(productJson);
  print(
      '→ Result: Product ID=${product.id}, name=${product.name ?? "MISSING"}, price=${product.price}');

  // Example 5: List of items
  print('\n${"─" * 70}');
  print('📡 GET /api/notifications');
  print('─' * 70);

  final notificationsJson = {
    'count': '5', // String instead of int
    'unread': 3,
    'notifications': [
      {'id': 1, 'title': 'Welcome!', 'read': false},
      {
        'id': '2',
        'title': 'New message',
        'read': 'true'
      }, // String id, String bool
      {'id': 3, 'title': null, 'read': 0}, // null title, int bool
    ],
  };

  final notifications = NotificationsResponse.fromJson(notificationsJson);
  print(
      '→ Result: ${notifications.count} notifications, ${notifications.unread} unread');
  print('');
}

// JSON to Dart Generator
void testGenerator() {
  print('');
  print(
      '┌─────────────────────────────────────────────────────────────────────┐');
  print(
      '│  TEST 4: JSON to Dart Generator                                     │');
  print(
      '└─────────────────────────────────────────────────────────────────────┘');

  final json = {
    'userId': 123,
    'user_name': 'Test User',
    'email': null,
    'is_active': true,
    'profile': {
      'avatar_url': 'https://example.com/img.png',
      'bio': 'Hello world',
    },
    'tags': ['flutter', 'dart', 'mobile'],
    'orders': [
      {'id': 1, 'total': 99.5},
      {'id': 2, 'total': 149.0},
    ],
  };

  print('\nInput JSON:');
  print(json);

  final generator = JsonToDartGenerator(
    options: const GeneratorOptions(
      generateFromJson: true,
      generateToJson: true,
      generateCopyWith: true,
      addLogging: true,
      allNullable: true,
    ),
  );

  final result = generator.generate(json, 'ApiUser');

  print('\n${"═" * 70}');
  print('GENERATED CODE:');
  print('═' * 70);
  print(result.fullCode);
  print('═' * 70);

  print('\nGenerated ${result.fields.length} fields:');
  for (final field in result.fields) {
    print('  • ${field.name}: ${field.type} ← JSON key: "${field.jsonKey}"');
  }

  print('\nGenerated ${result.nestedClasses.length} nested classes:');
  for (final nested in result.nestedClasses) {
    print('  • class ${nested.name} (${nested.fields.length} fields)');
  }

  if (result.warnings.isNotEmpty) {
    print('\n⚠️ Warnings:');
    for (final warning in result.warnings) {
      print('  • $warning');
    }
  }
  print('');
}

// MODEL CLASSES: what the generator produces

class UserResponse {
  final int? userId;
  final String? userName;
  final String? email;
  final bool? isActive;
  final int? age;
  final double? balance;
  final DateTime? createdAt;
  final Profile? profile;

  UserResponse({
    this.userId,
    this.userName,
    this.email,
    this.isActive,
    this.age,
    this.balance,
    this.createdAt,
    this.profile,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => UserResponse(
              userId: json.safeInt('userId'),
              userName: json.safeString('user_name'),
              email: json.safeString('email'),
              isActive: json.safeBool('is_active'),
              age: json.safeInt('age'),
              balance: json.safeDouble('balance'),
              createdAt: json.safeDateTime('created_at'),
              profile: json.safeObject('profile', Profile.fromJson),
            ));
  }
}

class Profile {
  final String? avatar;
  final String? bio;
  final int? followers;

  Profile({this.avatar, this.bio, this.followers});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => Profile(
              avatar: json.safeString('avatar'),
              bio: json.safeString('bio'),
              followers: json.safeInt('followers'),
            ));
  }
}

class OrderResponse {
  final int? orderId;
  final String? orderNumber;
  final double? total;
  final double? tax;
  final String? status;
  final bool? isPaid;
  final Customer? customer;
  final ShippingAddress? shippingAddress;
  final List<OrderItem>? items;

  OrderResponse({
    this.orderId,
    this.orderNumber,
    this.total,
    this.tax,
    this.status,
    this.isPaid,
    this.customer,
    this.shippingAddress,
    this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => OrderResponse(
              orderId: json.safeInt('orderId'),
              orderNumber: json.safeString('orderNumber'),
              total: json.safeDouble('total'),
              tax: json.safeDouble('tax'),
              status: json.safeString('status'),
              isPaid: json.safeBool('isPaid'),
              customer: json.safeObject('customer', Customer.fromJson),
              shippingAddress:
                  json.safeObject('shippingAddress', ShippingAddress.fromJson),
              items: json.safeList('items', OrderItem.fromJson),
            ));
  }
}

class Customer {
  final int? customerId;
  final String? name;
  final String? phone;
  final String? email;

  Customer({this.customerId, this.name, this.phone, this.email});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => Customer(
              customerId: json.safeInt('customerId'),
              name: json.safeString('name'),
              phone: json.safeString('phone'),
              email: json.safeString('email'),
            ));
  }
}

class ShippingAddress {
  final String? street;
  final String? city;
  final String? zipCode;
  final String? country;

  ShippingAddress({this.street, this.city, this.zipCode, this.country});

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => ShippingAddress(
              street: json.safeString('street'),
              city: json.safeString('city'),
              zipCode: json.safeString('zipCode'),
              country: json.safeString('country'),
            ));
  }
}

class OrderItem {
  final int? productId;
  final String? name;
  final int? quantity;
  final double? price;

  OrderItem({this.productId, this.name, this.quantity, this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => OrderItem(
              productId: json.safeInt('productId'),
              name: json.safeString('name'),
              quantity: json.safeInt('quantity'),
              price: json.safeDouble('price'),
            ));
  }
}

class SettingsResponse {
  final String? theme;
  final String? language;
  final bool? notifications;
  final int? fontSize;
  final bool? autoSave;

  SettingsResponse(
      {this.theme,
      this.language,
      this.notifications,
      this.fontSize,
      this.autoSave});

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => SettingsResponse(
              theme: json.safeString('theme'),
              language: json.safeString('language'),
              notifications: json.safeBool('notifications'),
              fontSize: json.safeInt('fontSize'),
              autoSave: json.safeBool('autoSave'),
            ));
  }
}

class ProductResponse {
  final int? id;
  final String? name;
  final double? price;
  final bool? inStock;
  final double? rating;

  ProductResponse({this.id, this.name, this.price, this.inStock, this.rating});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => ProductResponse(
              id: json.safeInt('id'),
              name: json.safeString('name'),
              price: json.safeDouble('price'),
              inStock: json.safeBool('inStock'),
              rating: json.safeDouble('rating'),
            ));
  }
}

class NotificationsResponse {
  final int? count;
  final int? unread;
  final List<NotificationItem>? notifications;

  NotificationsResponse({this.count, this.unread, this.notifications});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => NotificationsResponse(
              count: json.safeInt('count'),
              unread: json.safeInt('unread'),
              notifications:
                  json.safeList('notifications', NotificationItem.fromJson),
            ));
  }
}

class NotificationItem {
  final int? id;
  final String? title;
  final bool? read;

  NotificationItem({this.id, this.title, this.read});

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return DtoLogger.parse(
        json,
        () => NotificationItem(
              id: json.safeInt('id'),
              title: json.safeString('title'),
              read: json.safeBool('read'),
            ));
  }
}
