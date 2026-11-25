import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealio/views/auth/complete_profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF2C5E3B);
  static const Color darkGreen = Color(0xFF1E3F29);
  static const Color background = Color(0xFFF3EFEA);
  static const Color cream = Color(0xFFF9E4D4);
  static const Color terracotta = Color(0xFFC86D51);
  static const Color mutedGreen = Color(0xFF5A735E);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  late AnimationController entranceController;
  late AnimationController floatingController;

  late Animation<double> logoAnimation;
  late Animation<double> cardAnimation;

  @override
  void initState() {
    super.initState();

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

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    entranceController.forward();

    nameFocusNode.addListener(onFocusChange);
    emailFocusNode.addListener(onFocusChange);
    passwordFocusNode.addListener(onFocusChange);
    confirmPasswordFocusNode.addListener(onFocusChange);
  }

  void onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    entranceController.dispose();
    floatingController.dispose();

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      showMessage('Password must contain at least one uppercase letter.');
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      showMessage('Password must contain at least one special character.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user == null) {
        throw Exception('User account could not be created.');
      }

      await user.updateDisplayName(name);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'profileCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;

        default:
          message = e.message ?? 'Registration failed.';
      }

      showMessage(message);
    } on FirebaseException catch (e) {
      showMessage(
        'Account created, but profile data could not be saved. '
        'Please check your connection and try again.',
      );
    } catch (e) {
      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF89958F), fontSize: 14),
      prefixIcon: Icon(icon, color: darkGreen, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFAF8F4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5DDD3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5DDD3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 1.6),
      ),
    );
  }

  Widget buildPasswordVisibilityButton({
    required bool isHidden,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: mutedGreen,
      ),
    );
  }

  Widget buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.12),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            obscureText: obscureText,
            autocorrect: false,
            enableSuggestions: !obscureText,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
            decoration: inputDecoration(
              hint: hint,
              icon: icon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNameField() {
    return buildFormField(
      label: 'Full Name',
      hint: 'Enter your full name',
      icon: Icons.person_outline,
      controller: nameController,
      focusNode: nameFocusNode,
      keyboardType: TextInputType.name,
      capitalization: TextCapitalization.words,
    );
  }

  Widget buildEmailField() {
    return buildFormField(
      label: 'Email Address',
      hint: 'Enter your email',
      icon: Icons.email_outlined,
      controller: emailController,
      focusNode: emailFocusNode,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget buildPasswordField() {
    return buildFormField(
      label: 'Password',
      hint: 'Create a password',
      icon: Icons.lock_outline,
      controller: passwordController,
      focusNode: passwordFocusNode,
      obscureText: hidePassword,
      suffixIcon: buildPasswordVisibilityButton(
        isHidden: hidePassword,
        onPressed: () {
          setState(() {
            hidePassword = !hidePassword;
          });
        },
      ),
    );
  }

  Widget buildConfirmPasswordField() {
    return buildFormField(
      label: 'Confirm Password',
      hint: 'Confirm your password',
      icon: Icons.lock_outline,
      controller: confirmPasswordController,
      focusNode: confirmPasswordFocusNode,
      obscureText: hideConfirmPassword,
      textInputAction: TextInputAction.done,
      onSubmitted: register,
      suffixIcon: buildPasswordVisibilityButton(
        isHidden: hideConfirmPassword,
        onPressed: () {
          setState(() {
            hideConfirmPassword = !hideConfirmPassword;
          });
        },
      ),
    );
  }

  Widget buildAnimatedField({required Widget child, required int index}) {
    final start = 0.35 + (index * 0.15);
    final end = (0.70 + (index * 0.15)).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: entranceController,
      curve: Interval(start, end.toDouble(), curve: Curves.easeOutCubic),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.20, 0),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }

  Widget buildFieldsColumn() {
    final fields = [
      buildAnimatedField(index: 0, child: buildNameField()),
      buildAnimatedField(index: 1, child: buildEmailField()),
      buildAnimatedField(index: 2, child: buildPasswordField()),
      buildAnimatedField(index: 3, child: buildConfirmPasswordField()),
    ];

    return Column(
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          fields[i],
          if (i != fields.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildRegisterImage() {
    return FadeTransition(
      opacity: logoAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.12, 0),
          end: Offset.zero,
        ).animate(logoAnimation),
        child: SizedBox(
          width: 520,
          height: 500,
          child: Image.asset(
            'assets/images/Sign up-bro.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported_rounded,
                size: 100,
                color: primaryGreen,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAnimation() {
    return FadeTransition(
      opacity: logoAnimation,
      child: ScaleTransition(
        scale: logoAnimation,
        child: SizedBox(
          height: 155,
          child: Center(
            child: AnimatedBuilder(
              animation: floatingController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -floatingController.value * 7),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          color: cream,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: terracotta.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Transform.rotate(
                        angle: floatingController.value * 0.15,
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 58,
                          color: primaryGreen,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Transform.rotate(
                          angle: -floatingController.value * 0.5,
                          child: const Icon(
                            Icons.eco_rounded,
                            color: terracotta,
                            size: 32,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 0,
                        child: Transform.rotate(
                          angle: floatingController.value * 0.5,
                          child: const Icon(
                            Icons.spa_rounded,
                            color: mutedGreen,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFE9E3DA), width: 1),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Join Mealio and start your healthy journey',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: mutedGreen),
          ),
          const SizedBox(height: 25),
          buildFieldsColumn(),
          const SizedBox(height: 20),
          SizedBox(
            height: 49,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : register,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                elevation: 3,
                shadowColor: primaryGreen.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'Already have an account?',
                  style: TextStyle(color: mutedGreen, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required bool isDesktop}) {
    return FadeTransition(
      opacity: cardAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isDesktop ? 0.25 : 0.15, 0),
          end: Offset.zero,
        ).animate(cardAnimation),
        child: _buildRegisterCard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final isDesktop = width >= 900;

            return Stack(
              children: [
                _buildBackground(width, height),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 35 : 20,
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
                            ? _buildDesktopLayout()
                            : _buildMobileLayout(),
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

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Center(child: _buildRegisterImage()),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(flex: 5, child: _buildAnimatedCard(isDesktop: true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMobileAnimation(),
            const SizedBox(height: 5),
            _buildAnimatedCard(isDesktop: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(double width, double height) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -65,
            right: -55,
            child: _animatedCircle(width > 650 ? 230 : 165, cream, 12, 15),
          ),
          Positioned(
            bottom: -70,
            left: -55,
            child: _animatedCircle(
              width > 650 ? 210 : 155,
              const Color(0xFFE5EEDD),
              -12,
              -15,
            ),
          ),
          Positioned(
            top: height * 0.25,
            left: width * 0.09,
            child: _floatingIcon(Icons.spa_rounded, 33),
          ),
          Positioned(
            bottom: height * 0.22,
            right: width * 0.08,
            child: _floatingIcon(Icons.eco_rounded, 38),
          ),
          Positioned(
            top: height * 0.70,
            left: width * 0.18,
            child: _floatingIcon(Icons.energy_savings_leaf_rounded, 25),
          ),
        ],
      ),
    );
  }

  Widget _animatedCircle(double size, Color color, double dx, double dy) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            dx * floatingController.value,
            dy * floatingController.value,
          ),
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _floatingIcon(IconData icon, double size) {
    return AnimatedBuilder(
      animation: floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -floatingController.value * 12),
          child: child,
        );
      },
      child: Icon(icon, color: primaryGreen.withOpacity(0.20), size: size),
    );
  }
}
