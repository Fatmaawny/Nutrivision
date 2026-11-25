
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyProgressService {
  final currentUser = FirebaseAuth.instance.currentUser;
  final fireAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

  List<String> getLastSevenDays() {
    final today = DateTime.now();

    return List.generate(7, (index) {
      final date = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - index));

      final year = date.year;
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');

      return '$year-$month-$day';
    });
  }
  Stream<Map<String,dynamic>> getWeeklyProgress() {
    final days = getLastSevenDays();
    return firebaseFirestore.collection('users').doc(currentUser!.uid).collection('dailyNutrition')
        .where(FieldPath.documentId, whereIn: days).snapshots().asyncMap((snapshot) async{

          final userSnapshot = await firebaseFirestore.collection('users').doc(currentUser!.uid).get();

          double calorieGoal = (userSnapshot.data() as Map<String, dynamic>)['calorieGoal']?.toDouble() ?? 0.0;

          List<double> getProgressList(String field) {
        return days.map((day) {
          final docs = snapshot.docs.where((doc) => doc.id == day);

          if (docs.isEmpty) return 0.0;

          return (docs.first.data()[field] as num? ?? 0).toDouble();
        }).toList();
      }

      final caloriesProgressList = getProgressList('calories');
      final proteinProgressList = getProgressList('protein');
      final carbsProgressList = getProgressList('carbs');
      final fatsProgressList = getProgressList('fat');

      double totalCalories = getTotalProgress(caloriesProgressList);
      double caloriesAverage = totalCalories / caloriesProgressList.length;

      double totalProtein = getTotalProgress(proteinProgressList);
      double totalCarbs = getTotalProgress(carbsProgressList);
      double totalFats = getTotalProgress(fatsProgressList);

          double weeklyProteinGoal = ((calorieGoal * 0.2) / 4) * 7;
          double weeklyCarbsGoal = ((calorieGoal * 0.5) / 4) * 7;
          double weeklyFatGoal = ((calorieGoal * 0.3) / 9) * 7;
          double weeklyProteinPercentage = (totalProtein / weeklyProteinGoal).clamp(0.0, 1.0).toDouble();
          double weeklyCarbsPercentage = (totalCarbs / weeklyCarbsGoal).clamp(0.0, 1.0).toDouble();
          double weeklyFatPercentage = (totalFats / weeklyFatGoal).clamp(0.0, 1.0).toDouble();

          return {
        'caloriesProgress': caloriesProgressList,
        'caloriesAverage': caloriesAverage.toStringAsFixed(1),
        'totalProtein': totalProtein.toStringAsFixed(1),
        'totalCarbs': totalCarbs.toStringAsFixed(1),
        'totalFats': totalFats.toStringAsFixed(1),
        'weeklyProteinPercentage': weeklyProteinPercentage,
        'weeklyCarbsPercentage': weeklyCarbsPercentage,
        'weeklyFatPercentage': weeklyFatPercentage

      };
    });
  }
  double getTotalProgress(List<double> progressList){
    double totalProgress = 0;
  for(int i=0; i < progressList.length; i++){
  totalProgress += progressList[i];
  }
  return totalProgress;
  }

  Stream<Map<String, dynamic>> getWaterGoalProgress() {
    final days = getLastSevenDays();

    return firebaseFirestore.collection('users').doc(currentUser!.uid).collection('dailyWater')
        .where(FieldPath.documentId, whereIn: days).snapshots().map((snapshot) {
      final waterProgressList = days.map((day) {
        final docs = snapshot.docs.where((doc) => doc.id == day);

        if (docs.isEmpty) return 0;

        return (docs.first.data()['total'] as num? ?? 0).toInt();
      }).toList();

      final waterGoalList = days.map((day) {
        final docs = snapshot.docs.where((doc) => doc.id == day);

        if (docs.isEmpty) return 0;

        return (docs.first.data()['goal'] as num? ?? 0).toInt();
      }).toList();

      final achievedDays = List.generate(
        7, (index) => waterGoalList[index] > 0 && waterProgressList[index] >= waterGoalList[index],).where((value) => value)
          .length;

      final percentage = ((achievedDays / 7) * 100).toStringAsFixed(1);

      return {
        'achievedDays': achievedDays,
        'percentage': percentage,
      };
    });
  }

}
