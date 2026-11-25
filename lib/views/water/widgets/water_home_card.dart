import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/app_decorations.dart';
import 'package:mealio/core/utils/format_utils.dart';
import 'package:mealio/viewmodels/water_scope.dart';
import 'package:mealio/viewmodels/water_viewmodel.dart';
import 'package:mealio/views/water/water_actions.dart';
import 'package:mealio/views/water/water_screen.dart';

import 'package:mealio/views/water/widgets/water_glass.dart';
import 'package:mealio/views/water/widgets/water_round_button.dart';

/// Compact water container for the Home screen.
/// Tap the card to open the full screen; +/- change the amount directly.
class WaterHomeCard extends StatelessWidget {
  const WaterHomeCard({super.key});

  void _open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const WaterScreen()));

  @override
  Widget build(BuildContext context) {
    final raw = WaterScope.maybeOf(context);
    // null until the view model exists and has finished loading
    final vm = (raw != null && raw.loaded) ? raw : null;
    final radius = BorderRadius.circular(22);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: vm != null ? () => _open(context) : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: homeCardDecoration(radius: 22),
          child: vm != null
              ? _CardContent(vm: vm)
              : const SizedBox(
                  height: 64,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final WaterViewModel vm;
  const _CardContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WaterGlass(level: vm.progress, width: 46, height: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Water Intake',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryGreenText,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    text: formatLiters(vm.total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGreen,
                    ),
                    children: [
                      TextSpan(
                        text: ' / ${formatLiters(vm.goal)} L',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryGreenText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: vm.progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: AppColors.waterSoft,
                    valueColor: const AlwaysStoppedAnimation(AppColors.water),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        WaterRoundButton(
          icon: Icons.remove,
          soft: true,
          onTap: () => vm.remove(vm.step),
        ),
        const SizedBox(width: 8),
        WaterRoundButton(
          icon: Icons.add,
          onTap: () => logWater(context, vm, vm.step),
        ),
      ],
    );
  }
}
