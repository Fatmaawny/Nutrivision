import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/auth_colors.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground(
    this.width,
    this.height, {
    super.key,
    required this.floatingController,
  });

  final double width;
  final double height;
  final AnimationController floatingController;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -65,
            right: -55,
            child: AnimatedCircle(
              width > 650 ? 230 : 165,
              AuthColors.cream,
              12,
              15,
              floatingController: floatingController,
            ),
          ),
          Positioned(
            bottom: -70,
            left: -55,
            child: AnimatedCircle(
              width > 650 ? 210 : 155,
              const Color(0xFFE5EEDD),
              -12,
              -15,
              floatingController: floatingController,
            ),
          ),
          Positioned(
            top: height * 0.25,
            left: width * 0.09,
            child: FloatingIcon(
              Icons.spa_rounded,
              33,
              floatingController: floatingController,
            ),
          ),
          Positioned(
            bottom: height * 0.22,
            right: width * 0.08,
            child: FloatingIcon(
              Icons.eco_rounded,
              38,
              floatingController: floatingController,
            ),
          ),
          Positioned(
            top: height * 0.70,
            left: width * 0.18,
            child: FloatingIcon(
              Icons.energy_savings_leaf_rounded,
              25,
              floatingController: floatingController,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCircle extends StatelessWidget {
  const AnimatedCircle(
    this.size,
    this.color,
    this.dx,
    this.dy, {
    super.key,
    required this.floatingController,
  });

  final double size;
  final Color color;
  final double dx;
  final double dy;
  final AnimationController floatingController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            dx * floatingController.value,
            dy * floatingController.value,
          ),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class FloatingIcon extends StatelessWidget {
  const FloatingIcon(
    this.icon,
    this.size, {
    super.key,
    required this.floatingController,
  });

  final IconData icon;
  final double size;
  final AnimationController floatingController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -floatingController.value * 12),
          child: child,
        );
      },
      child: Icon(
        icon,
        color: AppColors.primaryGreen.withValues(alpha: 0.20),
        size: size,
      ),
    );
  }
}
