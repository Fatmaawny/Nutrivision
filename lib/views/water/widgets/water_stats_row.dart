import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/app_decorations.dart';
import 'package:mealio/core/utils/format_utils.dart';
import 'package:mealio/viewmodels/water_viewmodel.dart';

/// Three small tiles: Drank / Goal (tap to edit) / Left.
class WaterStatsRow extends StatelessWidget {
  final WaterViewModel vm;
  final VoidCallback onEditGoal;
  const WaterStatsRow({super.key, required this.vm, required this.onEditGoal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Drank',
            value: formatMl(vm.total),
            accent: AppColors.water,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Goal',
            value: formatMl(vm.goal),
            accent: AppColors.primaryGreen,
            trailingIcon: Icons.edit_outlined,
            onTap: onEditGoal,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            label: 'Left',
            value: vm.goalReached ? 'Done' : formatMl(vm.remaining),
            accent: AppColors.terracotta,
            showUnit: !vm.goalReached,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool showUnit;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _StatTile({
    required this.label,
    required this.value,
    required this.accent,
    this.showUnit = true,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: homeCardDecoration(radius: 18, accent: accent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryGreenText,
                    ),
                  ),
                  const Spacer(),
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      size: 14,
                      color: AppColors.secondaryGreenText,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                    children: [
                      if (showUnit)
                        const TextSpan(
                          text: ' ml',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryGreenText,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
