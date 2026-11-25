import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mealio/core/utils/date_keys.dart';
import 'package:mealio/data/models/water_day.dart';

/// Firestore: users/{uid}/dailyWater/{yyyy-MM-dd}
/// Fields: dateKey, total (ml), goal (ml), updatedAt
///
/// Same pattern as users/{uid}/dailyNutrition used by MealDataService.
class WaterRepository {
  final String uid;
  WaterRepository(this.uid);

  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('dailyWater');

  /// Latest saved day (used to restore the goal and today's total).
  Future<WaterDay?> loadLatest() async {
    final q = await _col.orderBy('dateKey', descending: true).limit(1).get();
    return q.docs.isEmpty ? null : WaterDay.fromMap(q.docs.first.data());
  }

  /// Adds (or subtracts) water using an atomic increment, so it is safe
  /// offline and across multiple devices.
  Future<void> addAmount({
    required String dateKey,
    required int delta,
    required int goal,
  }) {
    return _col.doc(dateKey).set({
      'dateKey': dateKey,
      'goal': goal,
      'total': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setGoal({required String dateKey, required int goal}) {
    return _col.doc(dateKey).set({
      'dateKey': dateKey,
      'goal': goal,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// All saved days from [fromDateKey] (yyyy-MM-dd) onward.
  Future<List<WaterDay>> loadSince(String fromDateKey) async {
    final q = await _col
        .where('dateKey', isGreaterThanOrEqualTo: fromDateKey)
        .orderBy('dateKey')
        .get();
    return q.docs.map((d) => WaterDay.fromMap(d.data())).toList();
  }

  /// Weekly evaluation: average of (total / goal, max 1.0) over the last
  /// 7 days including today. Days with no data count as 0. Result: 0.0 - 1.0
  Future<double> weeklyScore() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day - 6);
    final days = await loadSince(DateKeys.forDate(from));
    final byKey = {for (final d in days) d.dateKey: d};

    double sum = 0;
    for (var i = 0; i < 7; i++) {
      final key = DateKeys.forDate(
        DateTime(from.year, from.month, from.day + i),
      );
      final d = byKey[key];
      if (d != null && d.goal > 0) {
        sum += (d.total / d.goal).clamp(0.0, 1.0);
      }
    }
    return sum / 7;
  }
}
