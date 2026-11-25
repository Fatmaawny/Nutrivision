import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/auth_colors.dart';
import 'package:mealio/viewmodels/login_viewmodel.dart';
import 'package:mealio/views/auth/widgets/login_background.dart';
import 'package:mealio/views/auth/widgets/login_layouts.dart';
import 'package:mealio/views/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final LoginViewModel _viewModel;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  late AnimationController floatingController;
  late AnimationController entranceController;

  late Animation<double> logoAnimation;
  late Animation<double> cardAnimation;
  late Animation<double> textSlideAnimation;

  @override
  void initState() {
    super.initState();

    _viewModel = LoginViewModel();
    _loadRememberMe();

    emailFocusNode.addListener(_onFocusChanged);
    passwordFocusNode.addListener(_onFocusChanged);

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    logoAnimation = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
    );

    cardAnimation = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 1, curve: Curves.easeOutCubic),
    );

    textSlideAnimation = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOutQuart),
    );

    entranceController.forward();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _replayAnimations() {
    if (!mounted) return;

    entranceController.reset();
    entranceController.forward();
  }

  // REMEMBER ME

  /// Loads the saved "Remember me" choice and pre-fills the saved email.
  Future<void> _loadRememberMe() async {
    await _viewModel.init();

    if (!mounted) return;

    if (_viewModel.rememberMe) {
      emailController.text = _viewModel.savedEmail;
    }
  }

  void _onRememberMeChanged(bool? value) {
    _viewModel.setRememberMe(value ?? false);
  }

  @override
  void dispose() {
    _viewModel.dispose();

    emailController.dispose();
    passwordController.dispose();

    emailFocusNode.removeListener(_onFocusChanged);
    passwordFocusNode.removeListener(_onFocusChanged);

    emailFocusNode.dispose();
    passwordFocusNode.dispose();

    floatingController.dispose();
    entranceController.dispose();

    super.dispose();
  }

  // ACTIONS

  Future<void> _login() async {
    final result = await _viewModel.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (result.message != null) {
      _showMessage(result.message!);
    }
  }

  Future<void> _resetPassword() async {
    final result = await _viewModel.resetPassword(emailController.text);

    if (!mounted) return;

    if (result.message != null) {
      _showMessage(result.message!);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;

        return Scaffold(
          backgroundColor: AuthColors.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = constraints.maxHeight;

                bool isDesktop = width >= 900;
                bool isTablet = width >= 600 && width < 900;
                bool isSmallMobile = width < 360;

                double horizontalPadding = isDesktop
                    ? 48
                    : isTablet
                    ? 32
                    : 20;

                double logoScale = isSmallMobile ? 0.82 : 1.0;

                return Stack(
                  children: [
                    LoginBackground(
                      width,
                      height,
                      floatingController: floatingController,
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: height > 48 ? height - 48 : height,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: isDesktop
                                ? LoginDesktopLayout(
                                    emailController: emailController,
                                    passwordController: passwordController,
                                    emailFocusNode: emailFocusNode,
                                    passwordFocusNode: passwordFocusNode,
                                    hidePassword: vm.hidePassword,
                                    isLoading: vm.isLoading,
                                    rememberMe: vm.rememberMe,
                                    entranceController: entranceController,
                                    logoAnimation: logoAnimation,
                                    cardAnimation: cardAnimation,
                                    onLogin: _login,
                                    onResetPassword: _resetPassword,
                                    onRememberMeChanged: _onRememberMeChanged,
                                    onEmailChanged: vm.onEmailChanged,
                                    onReplayAnimations: _replayAnimations,
                                    onTogglePassword: vm.toggleHidePassword,
                                  )
                                : LoginMobileLayout(
                                    logoScale,
                                    isTablet,
                                    emailController: emailController,
                                    passwordController: passwordController,
                                    emailFocusNode: emailFocusNode,
                                    passwordFocusNode: passwordFocusNode,
                                    hidePassword: vm.hidePassword,
                                    isLoading: vm.isLoading,
                                    rememberMe: vm.rememberMe,
                                    floatingController: floatingController,
                                    entranceController: entranceController,
                                    logoAnimation: logoAnimation,
                                    cardAnimation: cardAnimation,
                                    onLogin: _login,
                                    onResetPassword: _resetPassword,
                                    onRememberMeChanged: _onRememberMeChanged,
                                    onEmailChanged: vm.onEmailChanged,
                                    onReplayAnimations: _replayAnimations,
                                    onTogglePassword: vm.toggleHidePassword,
                                  ),
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
      },
    );
  }
}
