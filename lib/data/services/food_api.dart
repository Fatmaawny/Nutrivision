import 'package:dio/dio.dart';

class FoodApiService {
  // USDA API
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.nal.usda.gov/fdc/v1/',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );

  static const String _apiKey = 'CgBjrMQGFWzfJpfd6TLgRHnrDPqN9ggKnhFrFWTb';

  // التصنيفات الموحدة داخل MEALIO
  static const List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Grains & Cereals',
    'Meat & Poultry',
    'Fish & Seafood',
    'Dairy & Eggs',
    'Legumes & Nuts',
    'Bakery',
    'Beverages',
    'Snacks & Sweets',
    'Other',
  ];

  List<String> get categoryNames => _categories;

  bool _loaded = false;

  // Constructor + Dio Interceptors
  FoodApiService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['api_key'] = _apiKey;
          options.headers['Accept'] = 'application/json';

          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException error, handler) {
          print('USDA ERROR: ${error.message}');
          print('USDA STATUS: ${error.response?.statusCode}');
          print('USDA RESPONSE: ${error.response?.data}');

          handler.next(error);
        },
      ),
    );
  }

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_USDA_API_KEY') {
      throw Exception('USDA API Key is missing. Please add your API Key.');
    }

    _loaded = true;
  }

  // التأكد من تهيئة الخدمة
  Future<void> _checkInitialization() async {
    if (!_loaded) {
      await initialize();
    }
  }

  // اختبار الاتصال بـ USDA
  Future<void> testConnection() async {
    await _checkInitialization();

    try {
      final response = await dio.get(
        'foods/search',
        queryParameters: {'query': 'apple', 'pageSize': 5, 'pageNumber': 1},
      );

      print('USDA STATUS: ${response.statusCode}');
      print('USDA DATA: ${response.data}');
    } on DioException catch (e) {
      print('USDA ERROR: ${e.message}');
      print('USDA STATUS: ${e.response?.statusCode}');
      print('USDA RESPONSE: ${e.response?.data}');
      rethrow;
    }
  }

  // البحث عن الأطعمة في USDA
  Future<List<Map<String, dynamic>>> getFoods({
    String query = '',
    int pageSize = 50,
  }) async {
    await _checkInitialization();

    try {
      final response = await dio.get(
        'foods/search',
        queryParameters: {
          'query': query.trim().isEmpty ? 'food' : query.trim(),
          'pageSize': pageSize.clamp(1, 200),
          'pageNumber': 1,
        },
      );

      final data = response.data;

      if (data is! Map || data['foods'] is! List) {
        return [];
      }

      final foods = data['foods'] as List;

      return foods
          .whereType<Map>()
          .map((food) => _formatFood(Map<String, dynamic>.from(food)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // البحث عن الأطعمة حسب التصنيف
  Future<List<Map<String, dynamic>>> getFoodsByCategory(
    String categoryKey, {
    int pageSize = 50,
    int maxPages = 1,
  }) async {
    await _checkInitialization();

    if (categoryKey.toLowerCase() == 'all') {
      return getFoods(pageSize: pageSize);
    }

    final searchTerm = _getCategorySearchTerm(categoryKey);

    final List<Map<String, dynamic>> results = [];

    try {
      for (int page = 1; page <= maxPages; page++) {
        final response = await dio.get(
          'foods/search',
          queryParameters: {
            'query': searchTerm,
            'pageSize': pageSize.clamp(1, 200),
            'pageNumber': page,
          },
        );

        final data = response.data;

        if (data is! Map || data['foods'] is! List) {
          break;
        }

        final foods = data['foods'] as List;

        if (foods.isEmpty) {
          break;
        }

        final formattedFoods = foods
            .whereType<Map>()
            .map((food) => _formatFood(Map<String, dynamic>.from(food)))
            .where((food) => food['category'] == categoryKey)
            .toList();

        results.addAll(formattedFoods);
      }

      return results;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // جلب تفاصيل الطعام باستخدام FDC ID
  Future<Map<String, dynamic>> getFoodDetails(int fdcId) async {
    await _checkInitialization();

    try {
      final response = await dio.get('food/$fdcId');

      if (response.data is! Map) {
        throw Exception('Invalid food details response.');
      }

      return _formatFood(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // تحويل بيانات USDA إلى الشكل المستخدم داخل MEALIO
  Map<String, dynamic> _formatFood(Map<String, dynamic> food) {
    final description = (food['description'] ?? 'Unknown Food').toString();

    final apiCategory =
        (food['foodCategory'] ?? food['brandedFoodCategory'] ?? '').toString();

    final category = _mapCategory(description, apiCategory);

    final nutrients = food['foodNutrients'];

    return {
      'fdcId': food['fdcId'],
      'name': description,
      'apiCategory': apiCategory,
      'category': category,
      'calories': _getNutrient(nutrients, 'energy'),
      'protein': _getNutrient(nutrients, 'protein'),
      'carbs': _getNutrient(nutrients, 'carbohydrate'),
      'fat': _getNutrient(nutrients, 'total lipid'),
      'fiber': _getNutrient(nutrients, 'fiber'),
      'sugar': _getNutrient(nutrients, 'sugars'),
      'saturatedFat': _getNutrient(nutrients, 'fatty acids, total saturated'),
      'sodium': _getNutrient(nutrients, 'sodium'),
    };
  }

  // استخراج القيمة الغذائية من بيانات USDA
  double _getNutrient(dynamic nutrients, String nutrientName) {
    if (nutrients is! List) {
      return 0.0;
    }

    for (final item in nutrients) {
      if (item is! Map) continue;

      final nutrient = item['nutrient'];

      final name =
          (item['nutrientName'] ??
                  (nutrient is Map ? nutrient['name'] : null) ??
                  '')
              .toString()
              .toLowerCase();

      final unit =
          (item['unitName'] ??
                  (nutrient is Map ? nutrient['unitName'] : null) ??
                  '')
              .toString()
              .toLowerCase();

      final normalizedName = nutrientName.toLowerCase();

      if (name.contains(normalizedName)) {
        final value = item['value'] ?? item['amount'];

        double result = 0.0;

        if (value is num) {
          result = value.toDouble();
        } else if (value != null) {
          result = double.tryParse(value.toString()) ?? 0.0;
        }

        // تحويل الطاقة من kJ إلى kcal
        if (normalizedName == 'energy' && unit == 'kj') {
          result = result / 4.184;
        }

        return result;
      }
    }

    return 0.0;
  }

  // تحديد التصنيف الموحد لكل طعام
  String _mapCategory(String name, String apiCategory) {
    final text = '$name $apiCategory'.toLowerCase();

    if (_containsAny(text, [
      'fruit',
      'apple',
      'banana',
      'orange',
      'mango',
      'grape',
      'strawberry',
      'berry',
      'watermelon',
      'pineapple',
      'pear',
      'peach',
      'dates',
    ])) {
      return 'Fruits';
    }

    if (_containsAny(text, [
      'vegetable',
      'spinach',
      'broccoli',
      'carrot',
      'tomato',
      'cucumber',
      'potato',
      'onion',
      'lettuce',
      'pepper',
      'cabbage',
      'zucchini',
      'eggplant',
    ])) {
      return 'Vegetables';
    }

    if (_containsAny(text, [
      'chicken',
      'beef',
      'meat',
      'turkey',
      'pork',
      'lamb',
      'poultry',
      'sausage',
    ])) {
      return 'Meat & Poultry';
    }

    if (_containsAny(text, [
      'fish',
      'seafood',
      'salmon',
      'tuna',
      'shrimp',
      'crab',
      'sardine',
      'shellfish',
    ])) {
      return 'Fish & Seafood';
    }

    if (_containsAny(text, [
      'milk',
      'cheese',
      'yogurt',
      'butter',
      'cream',
      'dairy',
      'egg',
    ])) {
      return 'Dairy & Eggs';
    }

    if (_containsAny(text, [
      'bean',
      'lentil',
      'chickpea',
      'pea',
      'nut',
      'almond',
      'peanut',
      'walnut',
      'cashew',
      'legume',
      'pistachio',
    ])) {
      return 'Legumes & Nuts';
    }

    if (_containsAny(text, [
      'bread',
      'bakery',
      'bagel',
      'pita',
      'croissant',
      'roll',
      'bun',
      'toast',
    ])) {
      return 'Bakery';
    }

    if (_containsAny(text, [
      'rice',
      'pasta',
      'oat',
      'cereal',
      'wheat',
      'barley',
      'quinoa',
      'grain',
      'corn',
    ])) {
      return 'Grains & Cereals';
    }

    if (_containsAny(text, [
      'juice',
      'beverage',
      'coffee',
      'tea',
      'water',
      'drink',
      'soda',
    ])) {
      return 'Beverages';
    }

    if (_containsAny(text, [
      'chocolate',
      'candy',
      'cookie',
      'cake',
      'chips',
      'snack',
      'biscuit',
      'dessert',
      'sugar',
      'sweet',
      'ice cream',
    ])) {
      return 'Snacks & Sweets';
    }

    return 'Other';
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((word) => text.contains(word));
  }

  // كلمات البحث المناسبة لكل تصنيف
  String _getCategorySearchTerm(String category) {
    switch (category) {
      case 'Fruits':
        return 'fruit';

      case 'Vegetables':
        return 'vegetable';

      case 'Grains & Cereals':
        return 'grain';

      case 'Meat & Poultry':
        return 'meat';

      case 'Fish & Seafood':
        return 'fish';

      case 'Dairy & Eggs':
        return 'milk';

      case 'Legumes & Nuts':
        return 'beans';

      case 'Bakery':
        return 'bread';

      case 'Beverages':
        return 'beverage';

      case 'Snacks & Sweets':
        return 'snack';

      default:
        return 'food';
    }
  }

  // معالجة أخطاء الاتصال بـ USDA
  String _getErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      return 'USDA API Key is invalid or not authorized.';
    }

    if (statusCode == 429) {
      return 'USDA API request limit exceeded. Try again later.';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your internet connection.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to USDA. Check your internet connection.';
    }

    return e.response?.data?.toString() ??
        e.message ??
        'Something went wrong while connecting to USDA.';
  }
}
