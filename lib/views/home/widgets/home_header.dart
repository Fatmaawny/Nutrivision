import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';

class DesktopHomeHeader extends StatelessWidget {
  const DesktopHomeHeader({
    super.key,
    required this.isLoading,
    required this.userName,
    required this.onLogout,
  });

  final bool isLoading;
  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MEALIO',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.terracotta,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            isLoading ? 'Hello there! 👋' : 'Hello, $userName! 👋',
            key: ValueKey(isLoading ? 'loading-name' : userName),
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Let's make today a healthy one!",
          style: TextStyle(
            color: AppColors.secondaryGreenText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class MobileHomeHeader extends StatelessWidget {
  const MobileHomeHeader({
    super.key,
    required this.isLoading,
    required this.userName,
    required this.onLogout,
  });

  final bool isLoading;
  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF438B58)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MEALIO',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8EDE5)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.terracotta,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            isLoading
                ? 'Hello there! 👋'
                : 'Hello, ${userName.split(' ').first}! 👋',
            key: ValueKey(isLoading ? 'loading-mobile' : userName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Let's make today a healthy one!",
          style: TextStyle(
            color: AppColors.secondaryGreenText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.terracotta,
              size: 14,
            ),
            const SizedBox(width: 7),
            Text(
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const TextStyle(
                color: AppColors.secondaryGreenText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 12,
                    color: AppColors.primaryGreen,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Healthy lifestyle',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
