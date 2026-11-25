import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NutritionDescriptionApi {
  final Dio dio = Dio();

  final String baseUrl = 'https://api.spoonacular.com';

  final String apiKey = '83bbffaf7b034177a8922548aef7942a';

  final List<String> availableUnits = [
    'g',
    'ml',
    'cup',
    'tbsp',
    'tsp',
    'piece',
    'slice',
    'serving',
  ];

  String normalizeUnit(String unit) {
    final value = unit.trim().toLowerCase();

    if (['g', 'gram', 'grams'].contains(value)) return 'g';

    if (['ml', 'milliliter', 'milliliters'].contains(value)) {
      return 'ml';
    }

    if (['cup', 'cups'].contains(value)) return 'cup';

    if (['tbsp', 'tablespoon', 'tablespoons'].contains(value)) {
      return 'tbsp';
    }

    if (['tsp', 'teaspoon', 'teaspoons'].contains(value)) {
      return 'tsp';
    }

    if (['piece', 'pieces', 'pc', 'pcs', 'whole'].contains(value)) {
      return 'piece';
    }

    if (['slice', 'slices'].contains(value)) return 'slice';

    if (['serving', 'servings', 'portion'].contains(value)) {
      return 'serving';
    }

    return unit.trim();
  }

  double? parseNumber(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '');
  }

  String getFirstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  bool isGramUnit(String unit) {
    return ['g', 'gram', 'grams'].contains(unit.trim().toLowerCase());
  }

  Future<List<Map<String, dynamic>>> analyzeMeal(String description) async {
    final cleanDescription = description.trim();

    if (cleanDescription.isEmpty) {
      throw Exception('Please describe your meal first.');
    }

    if (apiKey.trim().isEmpty) {
      throw Exception(
        'Add your Spoonacular API Key in nutrition_description_api.dart.',
      );
    }

    final normalizedDescription = cleanDescription
        .replaceAll('،', ',')
        .replaceAll('؛', ';');

    final ingredientLines = normalizedDescription
        .split(RegExp(r'[,;\n]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (ingredientLines.isEmpty) {
      throw Exception('No ingredients were found in the description.');
    }

    debugPrint('Ingredients sent to Spoonacular: $ingredientLines');

    try {
      final response = await dio.post(
        '$baseUrl/recipes/parseIngredients',
        queryParameters: {'apiKey': apiKey.trim(), 'includeNutrition': false},
        data: {'ingredientList': ingredientLines.join('\n'), 'servings': 1},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
          headers: {'Accept': 'application/json'},
        ),
      );

      final data = response.data;

      debugPrint('SPOONACULAR RESPONSE: $data');

      if (data is! List) {
        throw Exception('Spoonacular returned an unexpected response.');
      }

      final result = <Map<String, dynamic>>[];

      for (final rawItem in data) {
        if (rawItem is! Map) continue;

        final item = Map<String, dynamic>.from(rawItem);

        final apiAmount = parseNumber(item['amount']);

        final amount = apiAmount != null && apiAmount > 0 ? apiAmount : 1.0;

        final originalUnit = getFirstText([
          item['unitShort'],
          item['unit'],
          item['unitLong'],
        ]);

        final selectedUnit = normalizeUnit(originalUnit);

        final measures = item['measures'];

        final metric = measures is Map ? measures['metric'] : null;

        final metricAmount = metric is Map
            ? parseNumber(metric['amount'])
            : null;

        final metricUnit = metric is Map
            ? getFirstText([metric['unitShort'], metric['unitLong']])
            : '';

        double? referenceGrams;

        // نعتبر الوزن معروفًا فقط لو الوحدة جرام بالفعل.
        if (isGramUnit(metricUnit) &&
            metricAmount != null &&
            metricAmount > 0) {
          referenceGrams = metricAmount;
        } else if (isGramUnit(originalUnit)) {
          referenceGrams = amount;
        }

        final name = getFirstText([
          item['name'],
          item['originalName'],
          'Ingredient',
        ]);

        final original = getFirstText([
          item['original'],
          item['originalName'],
          name,
        ]);

        result.add({
          'name': name,
          'original': original,
          'amount': amount,
          'referenceAmount': amount,
          'unit': selectedUnit,
          'selectedUnit': selectedUnit,
          'originalUnit': originalUnit,
          'availableUnits': List<String>.from(availableUnits),
          'grams': referenceGrams,
          'referenceGrams': referenceGrams,
          'metricAmount': metricAmount,
          'metricUnit': metricUnit,

          // القيم الغذائية النهائية ستأتي من USDA.
          'selectedFood': null,
          'usdaMatches': <Map<String, dynamic>>[],
          'isSearchingUsda': false,
          'nutritionSource': null,
        });

        debugPrint(
          'Ingredient: $name | '
          'Amount: $amount | '
          'Unit: $originalUnit | '
          'Grams: $referenceGrams',
        );
      }

      debugPrint('Final ingredients: ${result.length}');

      return result;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      debugPrint('Spoonacular status code: $statusCode');
      debugPrint('Spoonacular error: $responseData');

      if (statusCode == 401 || statusCode == 402 || statusCode == 403) {
        throw Exception(
          'Spoonacular API key is invalid, or the API request limit has been reached.',
        );
      }

      if (responseData is Map && responseData['message'] != null) {
        throw Exception(responseData['message'].toString());
      }

      throw Exception(
        e.message ??
            'Could not connect to Spoonacular. Check your internet connection.',
      );
    } catch (e) {
      if (e is Exception) rethrow;

      throw Exception('Could not analyze the meal: $e');
    }
  }
}
