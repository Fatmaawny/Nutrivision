import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';

/// Same card style used by the Home screen's feature / nutrition cards:
/// white -> faint accent gradient, accent border and a soft shadow.
BoxDecoration homeCardDecoration({
  double radius = 22,
  Color accent = AppColors.primaryGreen,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, accent.withOpacity(0.055)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: accent.withOpacity(0.24)),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
