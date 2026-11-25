import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mealio/views/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();

  int currentPage = 0;

  late AnimationController floatingController;

  static const Color primaryGreen = Color(0xFF2C5E3B);
  static const Color darkGreen = Color(0xFF1E3F29);
  static const Color backgroundColor = Color(0xFFF3EFEA);
  static const Color cream = Color(0xFFF9E4D4);
  static const Color mutedGreen = Color(0xFF5A735E);
  static const Color terracotta = Color(0xFFC86D51);
  static const Color lightGreen = Color(0xFFE5EEDD);

  final List<Map<String, String>> pages = [
    {
      'title': 'Discover Healthy\nRecipes',
      'description':
      'Find delicious recipes and discover\nnew ways to enjoy healthy food.',
      'image':
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=1200&q=85',
      'tag': 'Fresh Ideas, Every Day',
    },
    {
      'title': 'Understand Your\nNutrition',
      'description':
      'Explore the nutrition in your meals\nand understand what your body needs.',
      'image':
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=85',
      'tag': 'Know What You Eat',
    },
    {
      'title': 'Build Better\nHealthy Habits',
      'description':
      'Track your progress and make small\nchanges towards a healthier lifestyle.',
      'image':
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=85',
      'tag': 'Small Steps, Big Changes',
    },
  ];

  @override
  void initState() {
    super.initState();

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    floatingController.dispose();
    super.dispose();
  }

  // CHANGE PAGE
  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  // NEXT PAGE
  void nextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    } else {
      goToLogin();
    }
  }

  // GO TO LOGIN
  void goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // CHANGE PAGE
  void changePage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            bool isDesktop = width >= 900 && height >= 650;
            bool isTablet = width >= 600 && width < 900;
            bool isShort = height < 650;

            return Stack(
              children: [
                _buildBackground(width, height),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1250),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop
                            ? 45
                            : isTablet
                            ? 28
                            : 14,
                        vertical: 12,
                      ),
                      child: isDesktop
                          ? _buildDesktopLayout()
                          : _buildMobileLayout(height, isTablet, isShort),
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

  // HEADER
  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 11),
          const Text(
            'MEALIO',
            style: TextStyle(
              color: darkGreen,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // MOBILE & TABLET LAYOUT
  Widget _buildMobileLayout(double height, bool isTablet, bool isShort) {
    double imageHeight =
    isTablet ? 380 : (height * 0.43).clamp(210.0, 380.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),

          SizedBox(height: isShort ? 14 : 22),

          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return _buildImageCard(index);
                },
              ),
            ),
          ),

          SizedBox(height: isShort ? 18 : 25),

          _buildPageText(isTablet),

          SizedBox(height: isShort ? 18 : 25),

          _buildPageIndicators(),

          SizedBox(height: isShort ? 18 : 25),

          _buildNextButton(isTablet),

          const SizedBox(height: 18),

          _buildFooter(),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  // DESKTOP LAYOUT
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildHeader(),

        const SizedBox(height: 25),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IMAGE ON THE LEFT
              Expanded(
                flex: 11,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: SizedBox.expand(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) {
                        return _buildImageCard(index);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 65),

              // CONTENT ON THE RIGHT
              Expanded(
                flex: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildPageText(true),

                    const SizedBox(height: 35),

                    _buildPageIndicators(),

                    const SizedBox(height: 35),

                    _buildNextButton(true),

                    const SizedBox(height: 22),

                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // IMAGE CARD
  Widget _buildImageCard(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          pages[index]['image']!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child
                  .animate(key: ValueKey('image-$index'))
                  .fadeIn(duration: 600.ms)
                  .scale(
                begin: const Offset(1.08, 1.08),
                duration: 900.ms,
                curve: Curves.easeOutCubic,
              );
            }

            return const ColoredBox(
              color: lightGreen,
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                  strokeWidth: 2.5,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: lightGreen,
              child: const Center(
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 65,
                  color: primaryGreen,
                ),
              ),
            );
          },
        ),

        // GRADIENT OVERLAY
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.42),
              ],
            ),
          ),
        ),

        // SKIP BUTTON
        Positioned(
          top: 18,
          right: 18,
          child: TextButton(
            onPressed: goToLogin,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.93),
              foregroundColor: darkGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: 19,
                vertical: 9,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, duration: 600.ms),
        ),

        // BOTTOM IMAGE LABEL
        Positioned(
          bottom: 20,
          left: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.93),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  color: primaryGreen,
                  size: 17,
                ),

                const SizedBox(width: 7),

                Text(
                  pages[index]['tag']!,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 700.ms)
              .slideY(begin: 0.2, duration: 700.ms),
        ),
      ],
    );
  }

  // PAGE TITLE & DESCRIPTION
  Widget _buildPageText(bool isLarge) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey(currentPage),
        children: [
          Text(
            pages[currentPage]['title']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkGreen,
              fontSize: isLarge ? 42 : 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            pages[currentPage]['description']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedGreen,
              fontSize: isLarge ? 17 : 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  // PAGE INDICATORS
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pages.length, (index) {
        bool isSelected = currentPage == index;

        return GestureDetector(
          onTap: () => changePage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: isSelected ? 30 : 9,
            height: 9,
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryGreen
                  : const Color(0xFFD6DDD5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }

  // NEXT BUTTON
  Widget _buildNextButton(bool isWide) {
    return SizedBox(
      width: isWide ? 340 : double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: primaryGreen.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                currentPage == pages.length - 1 ? 'Get Started' : 'Next',
                key: ValueKey(currentPage),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(width: 10),

            const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 700.ms)
        .slideY(
      begin: 0.2,
      duration: 700.ms,
      curve: Curves.easeOutCubic,
    );
  }

  // FOOTER
  Widget _buildFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite_rounded,
          size: 14,
          color: terracotta,
        ),

        SizedBox(width: 6),

        Text(
          'Eat well. Live fully.',
          style: TextStyle(
            color: mutedGreen,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // BACKGROUND
  Widget _buildBackground(double width, double height) {
    return Positioned.fill(
      child: Stack(
        children: [
          // TOP RIGHT CIRCLE
          Positioned(
            top: -65,
            right: -65,
            child: _animatedCircle(
              size: width > 700 ? 240 : 170,
              color: cream,
              offset: const Offset(10, 15),
            ),
          ),

          // BOTTOM LEFT CIRCLE
          Positioned(
            bottom: -75,
            left: -65,
            child: _animatedCircle(
              size: width > 700 ? 220 : 160,
              color: lightGreen,
              offset: const Offset(-10, -15),
            ),
          ),

          // FLOATING SPA ICON
          Positioned(
            top: height * 0.36,
            left: 12,
            child: AnimatedBuilder(
              animation: floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, floatingController.value * 12),
                  child: child,
                );
              },
              child: Icon(
                Icons.spa_rounded,
                color: primaryGreen.withValues(alpha: 0.12),
                size: 34,
              ),
            ),
          ),

          // FLOATING ECO ICON
          Positioned(
            bottom: height * 0.25,
            right: 15,
            child: AnimatedBuilder(
              animation: floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -floatingController.value * 14),
                  child: child,
                );
              },
              child: Icon(
                Icons.eco_rounded,
                color: primaryGreen.withValues(alpha: 0.12),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ANIMATED BACKGROUND CIRCLE
  Widget _animatedCircle({
    required double size,
    required Color color,
    required Offset offset,
  }) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            offset.dx * floatingController.value,
            offset.dy * floatingController.value,
          ),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
