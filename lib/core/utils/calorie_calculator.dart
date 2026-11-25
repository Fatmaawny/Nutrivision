/// Pure calorie / number helpers (no UI, no Firebase).
class CalorieCalculator {
  CalorieCalculator._();

  // NUMBER CONVERSION
  static double number(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ACTIVITY MULTIPLIER
  static double getActivityMultiplier(dynamic activity) {
    String activityName = activity?.toString().trim().toLowerCase() ?? '';

    // Very low activity
    if (activityName.contains('sedentary') ||
        activityName.contains('very light') ||
        activityName.contains('very low')) {
      return 1.2;
    }

    // Light activity
    if (activityName.contains('lightly active') ||
        activityName.contains('light activity')) {
      return 1.375;
    }

    // Moderate activity
    if (activityName.contains('moderately active') ||
        activityName.contains('moderate')) {
      return 1.55;
    }

    // Very active
    if (activityName.contains('very active')) {
      return 1.725;
    }

    // Extra active
    if (activityName.contains('extra active') ||
        activityName.contains('extremely active')) {
      return 1.9;
    }

    double value = number(activity);

    if (value >= 1.2 && value <= 1.9) {
      return value;
    }

    if (value == 1) return 1.2;
    if (value == 2) return 1.375;
    if (value == 3) return 1.55;
    if (value == 4) return 1.725;
    if (value == 5) return 1.9;

    return 1.2;
  }

  // DAILY CALORIES CALCULATION (Mifflin-St Jeor)
  static double calculateCalories({
    required double weight,
    required double height,
    required double age,
    required String gender,
    required dynamic activityLevel,
    required String healthGoal,
  }) {
    if (weight <= 0 || height <= 0 || age <= 0) {
      return 0.0;
    }

    // Mifflin-St Jeor equation
    double maleBmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;

    double femaleBmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;

    double bmr;

    String userGender = gender.trim().toLowerCase();

    if (userGender == 'male') {
      bmr = maleBmr;
    } else if (userGender == 'female') {
      bmr = femaleBmr;
    } else {
      // Estimated average for Prefer not to say
      bmr = (maleBmr + femaleBmr) / 2;
    }

    // Total Daily Energy Expenditure
    double activityMultiplier = getActivityMultiplier(activityLevel);

    double tdee = bmr * activityMultiplier;

    String goal = healthGoal.trim().toLowerCase();

    // Weight loss
    if (goal.contains('lose')) {
      return (tdee - 300).roundToDouble();
    }

    // Weight gain
    if (goal.contains('gain')) {
      return (tdee + 200).roundToDouble();
    }

    // Maintain weight
    return tdee.roundToDouble();
  }
}
