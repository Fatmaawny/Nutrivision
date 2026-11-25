import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    return user.uid;
  }

  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  CollectionReference<Map<String, dynamic>> get _mealsCollection {
    return _collectionForDate(_todayKey());
  }

  CollectionReference<Map<String, dynamic>> _collectionForDate(String dateKey) {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('meals')
        .doc(dateKey)
        .collection('items');
  }

  // The Saved Meals screen updates automatically when Firebase changes.
  Stream<List<Map<String, dynamic>>> watchMeals() {
    final dateKey = _todayKey();

    return _collectionForDate(dateKey).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id, 'dateKey': dateKey};
      }).toList();
    });
  }

  // Read meals for today.
  Future<List<Map<String, dynamic>>> getMeals() async {
    final dateKey = _todayKey();
    final snapshot = await _collectionForDate(dateKey).get();

    return snapshot.docs.map((doc) {
      return {...doc.data(), 'id': doc.id, 'dateKey': dateKey};
    }).toList();
  }

  // Save daily nutritional totals in Firebase.
  Future<void> saveDailyTotals({String? dateKey}) async {
    final selectedDate = dateKey ?? _todayKey();

    final snapshot = await _collectionForDate(selectedDate).get();

    final meals = snapshot.docs.map((doc) => doc.data()).toList();

    final totals = calculateTotals(meals);

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('dailyNutrition')
        .doc(selectedDate)
        .set({
          'dateKey': selectedDate,
          'calories': totals['calories'],
          'protein': totals['protein'],
          'carbs': totals['carbs'],
          'fat': totals['fat'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  // Read daily nutritional totals for a specific date.
  Future<Map<String, double>> getDailyTotals({String? dateKey}) async {
    final selectedDate = dateKey ?? _todayKey();

    final document = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('dailyNutrition')
        .doc(selectedDate)
        .get();

    if (document.exists) {
      final data = document.data() ?? {};

      return {
        'calories': _readDouble(data['calories']),
        'protein': _readDouble(data['protein']),
        'carbs': _readDouble(data['carbs']),
        'fat': _readDouble(data['fat']),
      };
    }

    await saveDailyTotals(dateKey: selectedDate);

    final mealsSnapshot = await _collectionForDate(selectedDate).get();
    final meals = mealsSnapshot.docs.map((doc) => doc.data()).toList();

    return calculateTotals(meals);
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // Add a regular ingredient.
  Future<void> addMeal({
    required String foodName,
    required String category,
    required String mealType,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final dateKey = _todayKey();
    final collection = _collectionForDate(dateKey);

    await collection.add({
      'foodName': foodName,
      'category': category,
      'mealType': mealType,
      'mealKind': 'ingredient',
      'grams': grams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await saveDailyTotals(dateKey: dateKey);
  }

  // Add ingredients to a Custom Meal of the same type for today.
  Future<void> addCustomMeal({
    required String foodName,
    required String mealType,
    required List<Map<String, dynamic>> components,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double grams,
  }) async {
    final dateKey = _todayKey();
    final collection = _collectionForDate(dateKey);

    final snapshot = await collection
        .where('mealKind', isEqualTo: 'custom')
        .where('mealType', isEqualTo: mealType)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final oldMeal = doc.data();

      final oldComponents = List<Map<String, dynamic>>.from(
        (oldMeal['components'] as List? ?? []).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );

      await doc.reference.update({
        'components': [...oldComponents, ...components],
        'grams': _readDouble(oldMeal['grams']) + grams,
        'calories': _readDouble(oldMeal['calories']) + calories,
        'protein': _readDouble(oldMeal['protein']) + protein,
        'carbs': _readDouble(oldMeal['carbs']) + carbs,
        'fat': _readDouble(oldMeal['fat']) + fat,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await collection.add({
        'foodName': mealType,
        'category': 'Custom Meal',
        'mealType': mealType,
        'mealKind': 'custom',
        'components': components,
        'grams': grams,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await saveDailyTotals(dateKey: dateKey);
  }

  // Update a regular meal.
  Future<void> updateMeal({
    required String mealId,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? mealType,
    String? dateKey,
  }) async {
    final selectedDate = dateKey ?? _todayKey();
    final collection = _collectionForDate(selectedDate);

    final data = <String, dynamic>{
      'grams': grams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (mealType != null) {
      data['mealType'] = mealType;
    }

    await collection.doc(mealId).update(data);

    await saveDailyTotals(dateKey: selectedDate);
  }

  // Update a Custom Meal and all its components.
  Future<void> updateCustomMeal({
    required String mealId,
    required String mealType,
    required List<Map<String, dynamic>> components,
    required double grams,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? dateKey,
  }) async {
    final selectedDate = dateKey ?? _todayKey();
    final collection = _collectionForDate(selectedDate);

    await collection.doc(mealId).update({
      'foodName': mealType,
      'mealType': mealType,
      'mealKind': 'custom',
      'category': 'Custom Meal',
      'components': components,
      'grams': grams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await saveDailyTotals(dateKey: selectedDate);
  }

  // Delete a meal from its original date.
  Future<void> deleteMeal(String mealId, {String? dateKey}) async {
    final selectedDate = dateKey ?? _todayKey();
    final collection = _collectionForDate(selectedDate);

    await collection.doc(mealId).delete();

    await saveDailyTotals(dateKey: selectedDate);
  }

  // Calculate daily nutritional totals from saved meals.
  Map<String, double> calculateTotals(List<Map<String, dynamic>> meals) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (final meal in meals) {
      calories += _readDouble(meal['calories']);
      protein += _readDouble(meal['protein']);
      carbs += _readDouble(meal['carbs']);
      fat += _readDouble(meal['fat']);
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
