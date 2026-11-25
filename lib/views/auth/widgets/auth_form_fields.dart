import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/auth_colors.dart';

/// Shared look of the text fields in the auth screens.
InputDecoration authInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF89958F), fontSize: 14),
    prefixIcon: Icon(icon, color: AppColors.darkGreen, size: 21),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AuthColors.fieldBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AuthColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AuthColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
    ),
  );
}

class AnimatedFieldGroup extends StatelessWidget {
  const AnimatedFieldGroup({
    super.key,
    required this.index,
    required this.child,
    required this.entranceController,
  });

  final int index;
  final Widget child;
  final AnimationController entranceController;

  @override
  Widget build(BuildContext context) {
    double start = 0.35 + (index * 0.15);
    double end = 0.70 + (index * 0.15);

    Animation<double> fieldAnimation = CurvedAnimation(
      parent: entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: fieldAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.20, 0),
          end: Offset.zero,
        ).animate(fieldAnimation),
        child: child,
      ),
    );
  }
}

class FocusedField extends StatelessWidget {
  const FocusedField({super.key, required this.focusNode, required this.child});

  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: focusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.10),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
        fontSize: 13,
      ),
    );
  }
}
