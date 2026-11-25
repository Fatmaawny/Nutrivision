import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';

/// Round + / - button (primary = green filled, soft = mint).
class WaterRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool soft;
  final double size;

  const WaterRoundButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.soft = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: soft ? AppColors.mint : AppColors.primaryGreen,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.55,
            color: soft ? AppColors.primaryGreen : Colors.white,
          ),
        ),
      ),
    );
  }
}
