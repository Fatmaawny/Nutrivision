import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';

class HealthyReminder extends StatelessWidget {
  const HealthyReminder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8D8), Color(0xFFFFF1E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.terracotta.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Center(
              child: Text('💧', style: TextStyle(fontSize: 29)),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Healthy Reminder',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Small choices daily make a big difference. Stay hydrated!',
                  style: TextStyle(
                    color: AppColors.secondaryGreenText,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
