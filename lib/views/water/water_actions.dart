import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mealio/viewmodels/water_viewmodel.dart';

/// Adds water, light haptic feedback, and a message when the goal is reached.
void logWater(BuildContext context, WaterViewModel vm, int ml) {
  HapticFeedback.lightImpact();
  if (vm.add(ml)) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('🎉 You reached your daily water goal!')),
      );
  }
}
