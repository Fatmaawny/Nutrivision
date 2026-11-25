import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mealio/views/auth/onboarding_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF2C5E3B);
  static const Color darkGreen = Color(0xFF1E3F29);
  static const Color background = Color(0xFFF3EFEA);
  static const Color cream = Color(0xFFF9E4D4);
  static const Color terracotta = Color(0xFFC86D51);
  static const Color mutedGreen = Color(0xFF5A735E);
  static const Color accentColor = Color(0xFFC48B69);

  late AnimationController introController;
  late AnimationController floatingController;

  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    fadeAnimation = CurvedAnimation(
      parent: introController,
      curve: Curves.easeIn,
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: introController, curve: Curves.easeOutCubic),
        );

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    introController.forward();

    startApp();
  }

  Future<void> startApp() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    introController.dispose();
    floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            bool isWide = width >= 700;
            bool isShort = height < 650;

            double logoSize = isWide
                ? 300
                : isShort
                ? 190
                : 230;

            double titleSize = isWide
                ? 36
                : isShort
                ? 28
                : 32;

            double horizontalPadding = isWide ? 40 : 24;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -60,
                      child: _buildCircle(220, cream),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -80,
                      child: _buildCircle(240, primaryGreen),
                    ),
                    Positioned(
                      top: height * 0.25,
                      left: -40,
                      child: _buildCircle(90, accentColor),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 25,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 650),
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.eco_rounded,
                                        color: primaryGreen,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'MEALIO',
                                        style: GoogleFonts.outfit(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2.5,
                                          color: darkGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isShort ? 15 : 25),
                                  AnimatedBuilder(
                                    animation: floatingController,
                                    builder: (context, child) {
                                      double movement =
                                          math.sin(
                                            floatingController.value *
                                                math.pi *
                                                2,
                                          ) *
                                          10;

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
                                            color: primaryGreen.withValues(
                                              alpha: 0.22,
                                            ),
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
                                            width: logoSize + 35,
                                            height: logoSize + 35,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: primaryGreen,
                                                width: 6,
                                              ),
                                              color: Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: logoSize,
                                            height: logoSize,
                                            padding: const EdgeInsets.all(15),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/mealio-distinct-logo.png',
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported_rounded,
                                                          size: 65,
                                                          color: primaryGreen,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 15,
                                            top: 15,
                                            child: _foodBubble(
                                              Icons.eco_rounded,
                                              primaryGreen,
                                            ),
                                          ),
                                          Positioned(
                                            left: 15,
                                            bottom: 25,
                                            child: _foodBubble(
                                              Icons.favorite_rounded,
                                              terracotta,
                                            ),
                                          ),
                                          Positioned(
                                            right: 25,
                                            bottom: 15,
                                            child: _foodBubble(
                                              Icons.spa_rounded,
                                              accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isShort ? 20 : 30),
                                  Column(
                                    children: [
                                      Text(
                                        'Eat Better.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: titleSize,
                                          height: 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: darkGreen,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      Text(
                                        'Live Better.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: titleSize,
                                          height: 1.1,
                                          fontWeight: FontWeight.w700,
                                          color: primaryGreen,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Text(
                                      'Your daily companion for smarter food choices.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: isWide ? 17 : 15,
                                        height: 1.6,
                                        fontWeight: FontWeight.w600,
                                        color: mutedGreen,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isShort ? 22 : 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.favorite_rounded,
                                        size: 14,
                                        color: terracotta,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Eat well. Live fully.',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 13,
                                          color: mutedGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _foodBubble(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
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
      child: Icon(icon, color: color, size: 22),
    );
  }
}
