import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class MealImageRecognitionApi {
  final Dio dio = Dio();

  // ضعي Gemini API Key هنا للتجربة فقط
  final String apiKey = '';

  final String model = 'gemini-3.8-flash';

  Future<List<Map<String, dynamic>>> analyzeMealImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (imageBytes.isEmpty) {
      throw Exception('Please select a meal image.');
    }

    if (apiKey.trim().isEmpty || apiKey == 'PUT_YOUR_API_KEY_HERE') {
      throw Exception('Please add your Gemini API Key.');
    }

    try {
      final base64Image = base64Encode(imageBytes);

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
        options: Options(headers: {'x-goog-api-key': apiKey}),
        data: {
          'contents': [
            {
              'parts': [
                {
                  'inline_data': {'mime_type': mimeType, 'data': base64Image},
                },
                {
                  'text': '''
Analyze this food image.

Identify visible food items only.
Estimate the amount in grams for each item.

Return ONLY valid JSON:
{
  "foods": [
    {
      "name": "food name in English",
      "estimated_grams": 100,
      "confidence": "high"
    }
  ]
}

If no food is visible:
{"foods": []}

Do not include calories or nutritional values.
''',
                },
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.2,
          },
        },
      );

      final responseText =
          response.data['candidates'][0]['content']['parts'][0]['text'];

      final decoded = jsonDecode(responseText);

      if (decoded is! Map || decoded['foods'] is! List) {
        throw Exception('Invalid food recognition response.');
      }

      return (decoded['foods'] as List)
          .whereType<Map>()
          .map((food) => Map<String, dynamic>.from(food))
          .toList();
    } on DioException catch (e) {
      print('Gemini Status Code: ${e.response?.statusCode}');
      print('Gemini Error: ${e.response?.data}');
      print('Dio Message: ${e.message}');

      throw Exception(
        'Gemini Error ${e.response?.statusCode}: '
        '${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Image Recognition Error: $e');
      rethrow;
    }
  }
}
