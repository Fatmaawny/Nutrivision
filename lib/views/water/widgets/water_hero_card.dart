import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/app_decorations.dart';
import 'package:mealio/core/utils/format_utils.dart';
import 'package:mealio/viewmodels/water_viewmodel.dart';

import 'package:mealio/views/water/widgets/water_glass.dart';

/// Big card with the glass, the percentage pill and the total.
class WaterHeroCard extends StatelessWidget {
  final WaterViewModel vm;
  const WaterHeroCard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: homeCardDecoration(radius: 28),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x263B8FD9), Color(0x003B8FD9)],
                  ),
                ),
              ),
              WaterGlass(level: vm.progress, width: 170, height: 220),
              Positioned(top: 0, right: 0, child: _PercentPill(vm: vm)),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: vm.total.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text.rich(
              TextSpan(
                text: formatLiters(v.round()),
                style: const TextStyle(
                  fontSize: 46,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                ),
                children: const [
                  TextSpan(
                    text: ' L',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryGreenText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vm.goalReached
                ? 'Goal reached! Great job 💧'
                : 'of ${formatLiters(vm.goal)} L daily goal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: vm.goalReached ? FontWeight.w800 : FontWeight.w500,
              color: vm.goalReached
                  ? AppColors.primaryGreen
                  : AppColors.secondaryGreenText,
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentPill extends StatelessWidget {
  final WaterViewModel vm;
  const _PercentPill({required this.vm});

  @override
  Widget build(BuildContext context) {
    final reached = vm.goalReached;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: reached ? AppColors.primaryGreen : AppColors.waterSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reached) ...[
            const Icon(Icons.check_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            '${vm.percent}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: reached ? Colors.white : AppColors.water,
            ),
          ),
        ],
      ),
    );
  }
}
