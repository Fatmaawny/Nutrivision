import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.restaurant_menu_rounded, 'label': 'Meals'},
      {'icon': Icons.bookmark_rounded, 'label': 'Saved'},
      {'icon': Icons.tips_and_updates_rounded, 'label': 'Tips'},
      {'icon': Icons.trending_up, 'label': 'Progress'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withOpacity(0.09),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            final selectedCenter = itemWidth * (selectedIndex + 0.5);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipPath(
                    clipper: WaveNavClipper(selectedCenter: selectedCenter),
                    child: Container(color: Colors.white),
                  ),
                ),
                Row(
                  children: List.generate(items.length, (index) {
                    final selected = selectedIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onPageChanged(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.only(top: selected ? 48 : 23),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!selected)
                                Icon(
                                  items[index]['icon'] as IconData,
                                  color: AppColors.secondaryGreenText
                                      .withOpacity(0.75),
                                  size: 22,
                                ),
                              if (selected)
                                Text(
                                  items[index]['label'] as String,
                                  style: const TextStyle(
                                    color: AppColors.darkGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              if (!selected) ...[
                                const SizedBox(height: 5),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.terracotta.withOpacity(
                                      0.8,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  left: selectedCenter - 26,
                  top: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onPageChanged(selectedIndex),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF438B58), Color(0xFF193C27)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.22),
                            blurRadius: 13,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        items[selectedIndex]['icon'] as IconData,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// WAVE NAVIGATION CLIPPER

class WaveNavClipper extends CustomClipper<Path> {
  final double selectedCenter;

  WaveNavClipper({required this.selectedCenter});

  @override
  Path getClip(Size size) {
    final path = Path();

    if (size.width <= 0 || size.height <= 0) {
      return path;
    }

    final maxCenter = size.width - 42.0 > 42.0 ? size.width - 42.0 : 42.0;

    final center = selectedCenter.clamp(42.0, maxCenter).toDouble();

    path.moveTo(0, 22);
    path.lineTo(center - 42, 22);

    path.cubicTo(center - 27, 22, center - 30, 0, center, 0);

    path.cubicTo(center + 30, 0, center + 27, 22, center + 42, 22);

    path.lineTo(size.width, 22);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant WaveNavClipper oldClipper) {
    return oldClipper.selectedCenter != selectedCenter;
  }
}
