import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/auth_colors.dart';
import 'package:mealio/views/auth/widgets/login_card.dart';
import 'package:mealio/views/auth/widgets/login_logo.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout(
    this.logoScale,
    this.isTablet, {
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.hidePassword,
    required this.isLoading,
    required this.rememberMe,
    required this.floatingController,
    required this.entranceController,
    required this.logoAnimation,
    required this.cardAnimation,
    required this.onLogin,
    required this.onResetPassword,
    required this.onRememberMeChanged,
    required this.onEmailChanged,
    required this.onReplayAnimations,
    required this.onTogglePassword,
  });

  final double logoScale;
  final bool isTablet;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool hidePassword;
  final bool isLoading;
  final bool rememberMe;
  final AnimationController floatingController;
  final AnimationController entranceController;
  final Animation<double> logoAnimation;
  final Animation<double> cardAnimation;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;
  final ValueChanged<bool?> onRememberMeChanged;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onReplayAnimations;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: logoAnimation,
          child: FadeTransition(
            opacity: logoAnimation,
            child: Transform.scale(
              scale: logoScale,
              child: LoginLogo(
                centered: true,
                floatingController: floatingController,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        FadeTransition(
          opacity: cardAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.18, 0),
              end: Offset.zero,
            ).animate(cardAnimation),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 480 : 420),
              child: LoginCard(
                emailController: emailController,
                passwordController: passwordController,
                emailFocusNode: emailFocusNode,
                passwordFocusNode: passwordFocusNode,
                hidePassword: hidePassword,
                isLoading: isLoading,
                rememberMe: rememberMe,
                entranceController: entranceController,
                onLogin: onLogin,
                onResetPassword: onResetPassword,
                onRememberMeChanged: onRememberMeChanged,
                onEmailChanged: onEmailChanged,
                onReplayAnimations: onReplayAnimations,
                onTogglePassword: onTogglePassword,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: cardAnimation,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 14,
                color: AuthColors.terracotta,
              ),
              SizedBox(width: 6),
              Text(
                'Eat well. Live fully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AuthColors.mutedGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginDesktopImage extends StatelessWidget {
  const LoginDesktopImage({super.key, required this.logoAnimation});

  final Animation<double> logoAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: logoAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.12, 0),
          end: Offset.zero,
        ).animate(logoAnimation),
        child: Image.asset(
          'assets/images/Secure login-rafiki.png',
          width: 520,
          height: 500,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_not_supported_rounded,
              size: 100,
              color: AppColors.primaryGreen,
            );
          },
        ),
      ),
    );
  }
}

class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.hidePassword,
    required this.isLoading,
    required this.rememberMe,
    required this.entranceController,
    required this.logoAnimation,
    required this.cardAnimation,
    required this.onLogin,
    required this.onResetPassword,
    required this.onRememberMeChanged,
    required this.onEmailChanged,
    required this.onReplayAnimations,
    required this.onTogglePassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool hidePassword;
  final bool isLoading;
  final bool rememberMe;
  final AnimationController entranceController;
  final Animation<double> logoAnimation;
  final Animation<double> cardAnimation;
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;
  final ValueChanged<bool?> onRememberMeChanged;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onReplayAnimations;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 35),
            child: Center(
              child: LoginDesktopImage(logoAnimation: logoAnimation),
            ),
          ),
        ),
        const SizedBox(width: 25),
        Expanded(
          flex: 5,
          child: FadeTransition(
            opacity: cardAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.18, 0),
                end: Offset.zero,
              ).animate(cardAnimation),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: LoginCard(
                  emailController: emailController,
                  passwordController: passwordController,
                  emailFocusNode: emailFocusNode,
                  passwordFocusNode: passwordFocusNode,
                  hidePassword: hidePassword,
                  isLoading: isLoading,
                  rememberMe: rememberMe,
                  entranceController: entranceController,
                  onLogin: onLogin,
                  onResetPassword: onResetPassword,
                  onRememberMeChanged: onRememberMeChanged,
                  onEmailChanged: onEmailChanged,
                  onReplayAnimations: onReplayAnimations,
                  onTogglePassword: onTogglePassword,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
