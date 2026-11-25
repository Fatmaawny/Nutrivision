import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/auth_colors.dart';
import 'package:mealio/views/auth/register_screen.dart';
import 'package:mealio/views/auth/widgets/auth_form_fields.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.hidePassword,
    required this.isLoading,
    required this.rememberMe,
    required this.entranceController,
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
  final VoidCallback onLogin;
  final VoidCallback onResetPassword;
  final ValueChanged<bool?> onRememberMeChanged;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onReplayAnimations;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFE9E3DA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Sign in to continue your healthy journey.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AuthColors.mutedGreen),
          ),
          const SizedBox(height: 25),
          AnimatedFieldGroup(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel('Email address'),
                const SizedBox(height: 7),
                FocusedField(
                  focusNode: emailFocusNode,
                  child: TextField(
                    controller: emailController,
                    focusNode: emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: onEmailChanged,
                    onSubmitted: (_) {
                      passwordFocusNode.requestFocus();
                    },
                    decoration: authInputDecoration(
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                    ),
                  ),
                ),
              ],
            ),
            entranceController: entranceController,
          ),
          const SizedBox(height: 17),
          AnimatedFieldGroup(
            index: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FieldLabel('Password'),
                const SizedBox(height: 7),
                FocusedField(
                  focusNode: passwordFocusNode,
                  child: TextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!isLoading) {
                        onLogin();
                      }
                    },
                    decoration: authInputDecoration(
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: onTogglePassword,
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AuthColors.mutedGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            entranceController: entranceController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: rememberMe,
                    activeColor: AppColors.primaryGreen,
                    visualDensity: VisualDensity.compact,
                    onChanged: isLoading ? null : onRememberMeChanged,
                  ),
                  const Text(
                    'Remember Me',
                    style: TextStyle(
                      color: AuthColors.mutedGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: TextButton(
                  onPressed: isLoading ? null : onResetPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 49,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Expanded(child: Divider(color: AuthColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              const Expanded(child: Divider(color: AuthColors.border)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: GoogleSignInButton(
              loadingIndicator: const CircularProgressIndicator(),
              clientId:
                  "889480397679-anhbfcbtnj9b6i0i46nr8jgqp8qfmgpc.apps.googleusercontent.com",
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(color: AuthColors.mutedGreen, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );

                  onReplayAnimations();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
