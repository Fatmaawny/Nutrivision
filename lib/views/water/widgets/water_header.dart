import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';

class WaterHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const WaterHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: WaterCircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGreen,
              ),
            ),
            if (trailing != null)
              Align(alignment: AlignmentDirectional.centerEnd, child: trailing),
          ],
        ),
      ),
    );
  }
}

class WaterCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const WaterCircleButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(
        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.18)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}
