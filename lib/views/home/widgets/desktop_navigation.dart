import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';

class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({
    super.key,
    required this.selectedIndex,
    required this.onLogout,
    required this.onPageChanged,
  });

  final int selectedIndex;
  final VoidCallback onLogout;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.restaurant_menu_rounded, 'label': 'Meals'},
      {'icon': Icons.bookmark_rounded, 'label': 'Saved Meals'},
      {'icon': Icons.tips_and_updates_rounded, 'label': 'Healthy Tips'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      width: 255,
      margin: const EdgeInsets.fromLTRB(18, 18, 0, 18),
      padding: const EdgeInsets.fromLTRB(17, 25, 17, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF193C27), Color(0xFF245438), Color(0xFF2C5E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.17),
            blurRadius: 24,
            offset: const Offset(5, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 0, 7, 35),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFFFFE8D8),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 11),
                const Text(
                  'MEALIO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 14),
            child: Text(
              'MAIN MENU',
              style: TextStyle(
                color: Colors.white.withOpacity(0.48),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
          ),
          ...List.generate(items.length, (index) {
            final selected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onPageChanged(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFE8D8)
                          : Colors.white.withOpacity(0.045),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFFE8D8)
                            : Colors.white.withOpacity(0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[index]['icon'] as IconData,
                          size: 21,
                          color: selected
                              ? AppColors.darkGreen
                              : Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            items[index]['label'] as String,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.darkGreen
                                  : Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: AppColors.terracotta,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),

          // HEALTH CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE77B54), Color(0xFFC86D51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  top: -20,
                  child: Icon(
                    Icons.spa_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Healthy habits,\nhappy life!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'One step at a time.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          // LOGOUT
          Material(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFFFB69B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
