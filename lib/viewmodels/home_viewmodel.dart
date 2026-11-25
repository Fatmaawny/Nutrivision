import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mealio/core/utils/calorie_calculator.dart';
import 'package:mealio/core/utils/date_keys.dart';
import 'package:mealio/data/repositories/auth_repository.dart';
import 'package:mealio/data/repositories/user_repository.dart';
import 'package:mealio/data/services/meal_data_service.dart';

/// State + logic of the Home screen (no widgets, no BuildContext).
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    AuthRepository? auth,
    UserRepository? users,
    MealDataService? mealService,
  }) : _auth = auth ?? AuthRepository(),
       _users = users ?? UserRepository(),
       mealService = mealService ?? MealDataService();

  final AuthRepository _auth;
  final UserRepository _users;
  final MealDataService mealService;

  String userName = 'Sarah';

  bool isLoading = true;
  bool isLoadingCalories = true;

  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;

  double? dailyCalorieGoal;

  int selectedIndex = 0;

  Timer? _dayRefreshTimer;
  bool _disposed = false;

  double get remainingCalories {
    if (dailyCalorieGoal == null) return 0;
    return dailyCalorieGoal! - calories;
  }

  /// Loads data and starts the "new day" watcher.
  void init() {
    refresh();
    _startDayRefreshTimer();
  }

  void refresh() {
    loadUserData();
    loadCalories();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // DATE

  void _startDayRefreshTimer() {
    String previousDay = DateKeys.today();

    _dayRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      final today = DateKeys.today();

      if (today != previousDay) {
        previousDay = today;
        loadCalories();
      }
    });
  }

  // LOAD USER DATA

  Future<void> loadUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      isLoading = false;
      _notify();
      return;
    }

    try {
      final data = await _users.fetchUserData(user.uid);

      final name =
          (data['name'] ?? data['fullName'] ?? user.displayName ?? 'Sarah')
              .toString()
              .trim();

      userName = name.isEmpty ? 'Sarah' : name;
      isLoading = false;
    } catch (e) {
      userName = user.displayName ?? 'Sarah';
      isLoading = false;
    }

    _notify();
  }

  // LOAD CALORIES AND NUTRITION

  Future<void> loadCalories() async {
    final user = _auth.currentUser;

    if (user == null) {
      dailyCalorieGoal = null;
      calories = 0;
      protein = 0;
      carbs = 0;
      fat = 0;
      isLoadingCalories = false;
      _notify();
      return;
    }

    isLoadingCalories = true;
    _notify();

    try {
      final data = await _users.fetchUserData(user.uid);

      final weight = CalorieCalculator.number(data['weight']);
      final height = CalorieCalculator.number(data['height']);
      final age = CalorieCalculator.number(data['age']);

      final gender = (data['gender'] ?? 'Female').toString();
      final activityLevel = data['activityLevel'];
      final healthGoal = (data['healthGoal'] ?? '').toString();

      double? calculatedGoal;

      if (weight > 0 && height > 0 && age > 0) {
        final result = CalorieCalculator.calculateCalories(
          weight: weight,
          height: height,
          age: age,
          gender: gender,
          activityLevel: activityLevel,
          healthGoal: healthGoal,
        );

        if (result > 0) {
          calculatedGoal = result;
        }
      }

      final meals = await mealService.getMeals();
      final totals = mealService.calculateTotals(meals);

      dailyCalorieGoal = calculatedGoal;

      calories = CalorieCalculator.number(totals['calories']);
      protein = CalorieCalculator.number(totals['protein']);
      carbs = CalorieCalculator.number(totals['carbs']);
      fat = CalorieCalculator.number(totals['fat']);

      isLoadingCalories = false;
    } catch (e) {
      dailyCalorieGoal = null;
      isLoadingCalories = false;
    }

    _notify();
  }

  // PAGE NAVIGATION

  /// Returns true when the Home page was selected (from another page), so the
  /// View can replay its entrance animation.
  bool changePage(int index) {
    if (index < 0 || index > 5) return false;

    if (selectedIndex == index) {
      if (index == 0) refresh();
      return false;
    }

    selectedIndex = index;
    _notify();

    if (index == 0) {
      refresh();
      return true;
    }

    return false;
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _disposed = true;
    _dayRefreshTimer?.cancel();
    super.dispose();
  }
}
