import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/auth_colors.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({
    super.key,
    this.centered = false,
    required this.floatingController,
  });

  final bool centered;
  final AnimationController floatingController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: floatingController,
          builder: (context, child) {
            double movement =
                math.sin(floatingController.value * math.pi * 2) * 10;

            return Transform.translate(
              offset: Offset(0, -movement),
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.22),
                  blurRadius: 40,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 125,
                  height: 125,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 5),
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Secure login-rafiki.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported_rounded,
                          size: 40,
                          color: AppColors.primaryGreen,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 5,
                  child: FoodBubble(Icons.eco_rounded, AppColors.primaryGreen),
                ),
                Positioned(
                  left: 0,
                  bottom: 15,
                  child: FoodBubble(
                    Icons.favorite_rounded,
                    AuthColors.terracotta,
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 0,
                  child: FoodBubble(Icons.spa_rounded, AuthColors.accent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mealio',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Eat Smart, Live Healthy.',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 12,
            color: AuthColors.mutedGreen,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class FoodBubble extends StatelessWidget {
  const FoodBubble(this.icon, this.color, {super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}
