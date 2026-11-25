import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';

/// Returns the new goal in ml, or null if cancelled / invalid.
Future<int?> showWaterGoalDialog(BuildContext context, int current) {
  final ctrl = TextEditingController(text: current.toString());
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Daily water goal',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.darkGreen,
        ),
      ),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          suffixText: 'ml',
          filled: true,
          fillColor: AppColors.mint.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.secondaryGreenText),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
