
import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF2C5E3B);
const Color darkGreen = Color(0xFF1E3F29);
const Color backgroundColor = Color(0xFFF3EFEA);
const Color creamColor = Color(0xFFF9E4D4);
const Color terracottaColor = Color(0xFFC86D51);
const Color mutedGreen = Color(0xFF5A735E);
const Color borderColor = Color(0xFFE5DDD3);
const Color headingColor = Color(0xFF26382B);

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController headerController;
  late Animation<double> headerAnimation;

  final List<Map<String, dynamic>> tips = [
    {
      'icon': Icons.water_drop_outlined,
      'title': 'Stay Hydrated',
      'description':
      'Drink enough water throughout the day to support your health.',
      'color': primaryGreen,
      'tag': 'Hydration',
    },
    {
      'icon': Icons.restaurant_outlined,
      'title': 'Eat Balanced Meals',
      'description':
      'Include vegetables, fruits, proteins, and whole grains in your meals.',
      'color': terracottaColor,
      'tag': 'Nutrition',
    },
    {
      'icon': Icons.directions_walk_outlined,
      'title': 'Stay Active',
      'description': 'Try to move your body daily, even with a short walk.',
      'color': primaryGreen,
      'tag': 'Movement',
    },
    {
      'icon': Icons.bedtime_outlined,
      'title': 'Get Enough Sleep',
      'description':
      'Maintain a regular sleep schedule to support your well-being.',
      'color': terracottaColor,
      'tag': 'Sleep',
    },
    {
      'icon': Icons.spa_outlined,
      'title': 'Manage Stress',
      'description':
      'Take breaks and practice relaxing activities during your day.',
      'color': terracottaColor,
      'tag': 'Wellness',
    },
    {
      'icon': Icons.favorite_border_rounded,
      'title': 'Build Healthy Habits',
      'description':
      'Make small, consistent changes to improve your lifestyle.',
      'color': primaryGreen,
      'tag': 'Daily Habits',
    },
  ];

  @override
  void initState() {
    super.initState();

    headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    headerAnimation = CurvedAnimation(
      parent: headerController,
      curve: Curves.easeOutCubic,
    );

    headerController.forward();
  }

  @override
  void dispose() {
    headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Health Tips',
          style: TextStyle(
            color: headingColor,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: headingColor),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          double horizontalPadding = width >= 1100
              ? 45
              : width >= 600
              ? 28
              : 18;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildWelcomeCard(width),
                    const SizedBox(height: 30),
                    buildSectionHeading(),
                    const SizedBox(height: 17),
                    buildTipsGrid(width),
                    const SizedBox(height: 28),
                    buildBottomMessage(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildWelcomeCard(double width) {
    bool isSmall = width < 400;

    return FadeTransition(
      opacity: headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(headerAnimation),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [darkGreen, primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                top: -55,
                child: Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 75,
                bottom: -80,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: creamColor.withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmall ? 21 : 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.spa_rounded,
                            color: creamColor,
                            size: 15,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'YOUR DAILY WELLNESS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Small Steps,\nHealthier You!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmall ? 25 : 31,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 440,
                      child: Text(
                        'Discover simple daily habits that can help you improve your nutrition and overall well-being.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: creamColor,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'A healthier lifestyle starts today',
                          style: TextStyle(
                            color: creamColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips for a Healthier Life',
          style: TextStyle(
            color: headingColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Simple habits that make a meaningful difference.',
          style: TextStyle(
            color: mutedGreen.withValues(alpha: 0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // TIPS GRID

  Widget buildTipsGrid(double width) {
    int crossAxisCount;

    if (width >= 1000) {
      crossAxisCount = 3;
    } else if (width >= 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tips.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: width < 400 ? 165 : 155,
      ),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 450 + (index * 90)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 18 * (1 - value)),
                child: child,
              ),
            );
          },
          child: buildTipCard(tips[index]),
        );
      },
    );
  }

  // TIP CARD

  Widget buildTipCard(Map<String, dynamic> tip) {
    Color accent = tip['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withValues(alpha: 0.045),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              tip['icon'] as IconData,
              color: accent,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: creamColor.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tip['tag'] as String,
                    style: const TextStyle(
                      color: terracottaColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  tip['title'] as String,
                  style: const TextStyle(
                    color: headingColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    tip['description'] as String,
                    style: const TextStyle(
                      color: mutedGreen,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BOTTOM MESSAGE

  Widget buildBottomMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: creamColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: terracottaColor.withValues(alpha: 0.15),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: terracottaColor,
            size: 25,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              'Remember: Consistency matters more than perfection. Start with one small change!',
              style: TextStyle(
                color: headingColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
