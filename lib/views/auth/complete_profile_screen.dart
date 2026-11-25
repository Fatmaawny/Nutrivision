import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mealio/views/auth/plan_ready_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();

  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final otherAllergyController = TextEditingController();

  static const Color primaryGreen = Color(0xFF2C5E3B);
  static const Color darkGreen = Color(0xFF1E3F29);
  static const Color background = Color(0xFFF3EFEA);
  static const Color cream = Color(0xFFF9E4D4);
  static const Color terracotta = Color(0xFFC86D51);
  static const Color mutedGreen = Color(0xFF5A735E);

  String? gender;
  String? activityLevel;
  String? healthGoal;
  String? dietaryPreference;

  double? weeklyWeightLoss;

  final Set<String> selectedAllergies = {};

  bool isLoading = false;

  late AnimationController entranceController;
  late AnimationController floatingController;

  late Animation<double> cardAnimation;
  late Animation<double> logoAnimation;

  int fieldIndex = 0;

  final List<String> allergyOptions = [
    'None',
    'Milk',
    'Eggs',
    'Peanuts',
    'Tree Nuts',
    'Fish',
    'Shellfish',
    'Soy',
    'Wheat',
    'Sesame',
    'Other',
  ];

  bool get needsTargetWeight =>
      healthGoal == 'Lose Weight' || healthGoal == 'Gain Weight';

  String? get weeklyWeightLossValue {
    if (weeklyWeightLoss == null) return null;

    for (final option in ['0.25', '0.5', '0.75', '1.0']) {
      if (double.parse(option) == weeklyWeightLoss) {
        return option;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    cardAnimation = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0.15, 1, curve: Curves.easeOutCubic),
    );

    logoAnimation = CurvedAnimation(
      parent: entranceController,
      curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
    );

    entranceController.forward();
  }

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    otherAllergyController.dispose();

    entranceController.dispose();
    floatingController.dispose();

    super.dispose();
  }

  Widget buildAnimatedField(Widget child) {
    double start = math.min(fieldIndex * 0.055, 0.55);
    double end = math.min(start + 0.45, 1.0);

    fieldIndex++;

    final animation = CurvedAnimation(
      parent: entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.18, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
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

  double? parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  void toggleAllergy(String allergy) {
    setState(() {
      if (allergy == 'None') {
        if (selectedAllergies.contains('None')) {
          selectedAllergies.remove('None');
        } else {
          selectedAllergies
            ..clear()
            ..add('None');

          otherAllergyController.clear();
        }

        return;
      }

      selectedAllergies.remove('None');

      if (selectedAllergies.contains(allergy)) {
        selectedAllergies.remove(allergy);

        if (allergy == 'Other') {
          otherAllergyController.clear();
        }
      } else {
        selectedAllergies.add(allergy);
      }
    });
  }

  Future<void> saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    if (gender == null ||
        activityLevel == null ||
        healthGoal == null ||
        dietaryPreference == null) {
      showMessage('Please complete all profile selections.');
      return;
    }

    if (selectedAllergies.isEmpty) {
      showMessage('Please select your food allergies or None.');
      return;
    }

    if (selectedAllergies.contains('Other') &&
        otherAllergyController.text.trim().isEmpty) {
      showMessage('Please specify your other allergy.');
      return;
    }

    if (healthGoal == 'Lose Weight' && weeklyWeightLoss == null) {
      showMessage('Please select your weekly weight loss goal.');
      return;
    }

    final age = int.tryParse(ageController.text.trim());
    final currentWeight = parseNumber(weightController.text);
    final height = parseNumber(heightController.text);

    final targetWeight = needsTargetWeight
        ? parseNumber(targetWeightController.text)
        : null;

    if (age == null || age < 1 || age > 120) {
      showMessage('Please enter a valid age.');
      return;
    }

    if (currentWeight == null ||
        !currentWeight.isFinite ||
        currentWeight <= 0) {
      showMessage('Please enter a valid current weight.');
      return;
    }

    if (height == null || !height.isFinite || height <= 0) {
      showMessage('Please enter a valid height.');
      return;
    }

    if (needsTargetWeight &&
        (targetWeight == null || !targetWeight.isFinite || targetWeight <= 0)) {
      showMessage('Please enter a valid target weight.');
      return;
    }

    if (healthGoal == 'Lose Weight' &&
        targetWeight != null &&
        targetWeight >= currentWeight) {
      showMessage('Target weight must be below your current weight.');
      return;
    }

    if (healthGoal == 'Gain Weight' &&
        targetWeight != null &&
        targetWeight <= currentWeight) {
      showMessage('Target weight must be above your current weight.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user is currently logged in.');
      }

      final allergies = selectedAllergies
          .where((allergy) => allergy != 'Other')
          .toList();

      if (selectedAllergies.contains('Other')) {
        allergies.add('Other: ${otherAllergyController.text.trim()}');
      }

      final Map<String, dynamic> profileData = {
        'age': age,
        'gender': gender,
        'height': height,
        'weight': currentWeight,
        'activityLevel': activityLevel,
        'healthGoal': healthGoal,
        'foodAllergies': allergies,
        'dietaryPreference': dietaryPreference,
        'targetWeight': targetWeight,
        'weeklyWeightLoss': healthGoal == 'Lose Weight'
            ? weeklyWeightLoss
            : null,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PlanReadyScreen()),
      );
    } on FirebaseException catch (e) {
      showMessage('Could not save profile: ${e.message ?? e.code}');
    } catch (e) {
      showMessage('Could not save profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: mutedGreen, fontSize: 13),
      hintStyle: const TextStyle(color: Color(0xFF89958F), fontSize: 13),
      prefixIcon: Icon(icon, color: darkGreen, size: 21),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: terracotta),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: terracotta, width: 1.5),
      ),
    );
  }

  Widget buildInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
  }) {
    return buildAnimatedField(
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }

              final number = parseNumber(value);

              if (number == null || !number.isFinite || number <= 0) {
                return 'Enter a valid number';
              }

              return null;
            },
        decoration: inputDecoration(label: label, hint: hint, icon: icon),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    final uniqueOptions = options.toSet().toList();

    final safeValue = value != null && uniqueOptions.contains(value)
        ? value
        : null;

    return buildAnimatedField(
      DropdownButtonFormField<String>(
        key: ValueKey('$label-${safeValue ?? 'empty'}'),
        value: safeValue,
        isExpanded: true,
        dropdownColor: const Color(0xFFFAF8F4),
        borderRadius: BorderRadius.circular(14),
        menuMaxHeight: 280,
        style: const TextStyle(color: darkGreen, fontSize: 14),
        iconEnabledColor: primaryGreen,
        validator: (selectedValue) {
          if (selectedValue == null || selectedValue.isEmpty) {
            return 'Please select an option';
          }

          return null;
        },
        decoration: inputDecoration(
          label: label,
          hint: 'Select $label',
          icon: icon,
        ),
        items: uniqueOptions.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: darkGreen, fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Responsive fields: نصف المساحة لكل حقل على الشاشات الكبيرة.
  Widget buildResponsiveFields({
    required bool isWide,
    required List<Widget> children,
  }) {
    if (isWide) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 20.0;

          final itemWidth = children.length == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: 16,
            children: children.map((child) {
              return SizedBox(width: itemWidth, child: child);
            }).toList(),
          );
        },
      );
    }

    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryGreen, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAllergySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Food Allergies', Icons.health_and_safety_outlined),
        const Text(
          'Select all that apply.',
          style: TextStyle(color: mutedGreen, fontSize: 13),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: allergyOptions.map((allergy) {
            final selected = selectedAllergies.contains(allergy);

            return FilterChip(
              label: Text(allergy),
              selected: selected,
              onSelected: (_) => toggleAllergy(allergy),
              selectedColor: primaryGreen.withOpacity(0.16),
              backgroundColor: const Color(0xFFFAF8F4),
              checkmarkColor: darkGreen,
              labelStyle: TextStyle(
                color: selected ? darkGreen : mutedGreen,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: selected ? primaryGreen : const Color(0xFFE5DDD3),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedAllergies.contains('Other')) ...[
          const SizedBox(height: 16),
          buildAnimatedField(
            TextFormField(
              controller: otherAllergyController,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (selectedAllergies.contains('Other') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please specify your allergy';
                }

                return null;
              },
              decoration: inputDecoration(
                label: 'Specify other allergy',
                hint: 'e.g. Strawberries',
                icon: Icons.edit_outlined,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: floatingController,
          builder: (context, child) {
            final movement =
                math.sin(floatingController.value * math.pi * 2) * 6;

            return Transform.translate(
              offset: Offset(0, -movement),
              child: child,
            );
          },
          child: Container(
            width: 125,
            height: 125,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: primaryGreen, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.18),
                  blurRadius: 14,
                  spreadRadius: 3,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: darkGreen.withOpacity(0.08),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/mealio-distinct-logo.png',
                width: 125,
                height: 125,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAnimatedDecoration(
    IconData icon,
    Color color,
    double start, {
    Color? background,
    bool plain = false,
  }) {
    final end = (start + 0.3).clamp(0.0, 1.0).toDouble();

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: entranceController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      ),
      child: Container(
        width: plain ? null : 36,
        height: plain ? null : 36,
        decoration: plain
            ? null
            : BoxDecoration(
                color: background ?? const Color(0xFFF5E5D8),
                shape: BoxShape.circle,
              ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  // =========================
  // NEW MOBILE HEADER
  // =========================

  Widget buildMobileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E5DA)),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ScaleTransition(scale: logoAnimation, child: buildLogo()),

          const SizedBox(height: 17),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E8DD),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: terracotta, size: 14),
                SizedBox(width: 7),
                Text(
                  'YOUR HEALTHY JOURNEY',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          FadeTransition(
            opacity: cardAnimation,
            child: Column(
              children: [
                const Text(
                  'A HEALTHIER YOU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: terracotta,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Starts With A Little\nAbout You.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Tell us about your lifestyle and goals. '
                  'We will help you create a nutrition plan '
                  'that fits your everyday life.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedGreen,
                    fontSize: 12,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 21),

          Container(height: 1, color: const Color(0xFFECE8DF)),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.spa_outlined, color: primaryGreen, size: 19),
              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Personalized nutrition, made for you.',
                  style: TextStyle(
                    color: mutedGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'STEP 1',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // NEW DESKTOP HEADER
  // =========================

  Widget buildDesktopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8E5DA)),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            child: Center(
              child: ScaleTransition(scale: logoAnimation, child: buildLogo()),
            ),
          ),

          const SizedBox(width: 38),

          Expanded(
            child: FadeTransition(
              opacity: cardAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E8DD),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: terracotta, size: 15),
                        SizedBox(width: 7),
                        Text(
                          'YOUR HEALTHY JOURNEY',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 17),

                  const Text(
                    'A Healthier You,\nStarts With A Little About You.',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 13),

                  Container(
                    width: 65,
                    height: 4,
                    decoration: BoxDecoration(
                      color: terracotta,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Tell us about your lifestyle and goals. '
                    'Mealio will help you create a nutrition experience '
                    'that matches your needs, preferences, and daily routine.',
                    style: TextStyle(
                      color: mutedGreen,
                      fontSize: 14,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(
                        Icons.spa_outlined,
                        color: primaryGreen,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Personalized nutrition, made for you.',
                        style: TextStyle(
                          color: mutedGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF0E4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'STEP 1',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileForm(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 38 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFE9E3DA)),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Complete Your Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkGreen,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us personalize your nutrition journey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedGreen, fontSize: 13),
            ),

            buildSectionTitle('Personal Information', Icons.person_outline),
            buildResponsiveFields(
              isWide: isWide,
              children: [
                buildInput(
                  label: 'Age',
                  controller: ageController,
                  hint: 'Enter your age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final age = int.tryParse((value ?? '').trim());

                    if (age == null || age < 1 || age > 120) {
                      return 'Enter a valid age';
                    }

                    return null;
                  },
                ),
                buildDropdown(
                  label: 'Gender',
                  value: gender,
                  options: const ['Female', 'Male', 'Prefer not to say'],
                  icon: Icons.wc,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
              ],
            ),

            buildSectionTitle(
              'Body Measurements',
              Icons.monitor_weight_outlined,
            ),
            buildResponsiveFields(
              isWide: isWide,
              children: [
                buildInput(
                  label: 'Height (cm)',
                  controller: heightController,
                  hint: 'e.g. 165',
                  icon: Icons.height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                buildInput(
                  label: 'Current Weight (kg)',
                  controller: weightController,
                  hint: 'e.g. 65',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),

            buildSectionTitle('Lifestyle', Icons.directions_walk),
            buildResponsiveFields(
              isWide: isWide,
              children: [
                buildDropdown(
                  label: 'Activity Level',
                  value: activityLevel,
                  options: const [
                    'Sedentary',
                    'Lightly active',
                    'Moderately active',
                    'Very active',
                    'Extra active',
                  ],
                  icon: Icons.directions_run,
                  onChanged: (value) {
                    setState(() {
                      activityLevel = value;
                    });
                  },
                ),
              ],
            ),

            buildSectionTitle('Health Goal', Icons.flag_outlined),
            buildResponsiveFields(
              isWide: isWide,
              children: [
                buildDropdown(
                  label: 'What is your goal?',
                  value: healthGoal,
                  options: const [
                    'Lose Weight',
                    'Maintain Weight',
                    'Gain Weight',
                    'Eat Healthier',
                  ],
                  icon: Icons.track_changes,
                  onChanged: (value) {
                    setState(() {
                      healthGoal = value;
                      weeklyWeightLoss = null;

                      if (!needsTargetWeight) {
                        targetWeightController.clear();
                      }
                    });
                  },
                ),
                if (needsTargetWeight)
                  buildInput(
                    label: 'Target Weight (kg)',
                    controller: targetWeightController,
                    hint: 'Enter your target weight',
                    icon: Icons.monitor_weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (!needsTargetWeight) return null;

                      final target = parseNumber(value ?? '');
                      final current = parseNumber(weightController.text);

                      if (target == null || !target.isFinite || target <= 0) {
                        return 'Enter a valid target weight';
                      }

                      if (current != null &&
                          healthGoal == 'Lose Weight' &&
                          target >= current) {
                        return 'Must be below current weight';
                      }

                      if (current != null &&
                          healthGoal == 'Gain Weight' &&
                          target <= current) {
                        return 'Must be above current weight';
                      }

                      return null;
                    },
                  ),
                if (healthGoal == 'Lose Weight')
                  buildDropdown(
                    label: 'Weekly Weight Loss (kg)',
                    value: weeklyWeightLossValue,
                    options: const ['0.25', '0.5', '0.75', '1.0'],
                    icon: Icons.trending_down,
                    onChanged: (value) {
                      setState(() {
                        weeklyWeightLoss = value == null
                            ? null
                            : double.tryParse(value);
                      });
                    },
                  ),
              ],
            ),

            if (healthGoal == 'Lose Weight')
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Choose your desired weekly weight loss. '
                  'The maximum option is 1 kg per week.',
                  style: TextStyle(
                    color: mutedGreen,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),

            buildAllergySection(),

            buildSectionTitle('Dietary Preference', Icons.restaurant_menu),
            buildResponsiveFields(
              isWide: isWide,
              children: [
                buildDropdown(
                  label: 'Your dietary preference',
                  value: dietaryPreference,
                  options: const [
                    'No Restrictions',
                    'Vegetarian',
                    'Vegan',
                    'Pescatarian',
                  ],
                  icon: Icons.eco_outlined,
                  onChanged: (value) {
                    setState(() {
                      dietaryPreference = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                  elevation: 3,
                  shadowColor: primaryGreen.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    fieldIndex = 0;

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        foregroundColor: darkGreen,
        iconTheme: const IconThemeData(color: darkGreen),
        centerTitle: true,
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            return Stack(
              children: [
                Positioned(
                  top: -65,
                  right: -60,
                  child: Container(
                    width: isWide ? 230 : 165,
                    height: isWide ? 230 : 165,
                    decoration: const BoxDecoration(
                      color: cream,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -70,
                  left: -55,
                  child: Container(
                    width: isWide ? 210 : 155,
                    height: isWide ? 210 : 155,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EEDD).withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 40 : 18,
                    vertical: 25,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 1120 : 600,
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: logoAnimation,
                            child: FadeTransition(
                              opacity: logoAnimation,
                              child: isWide
                                  ? buildDesktopHeader()
                                  : buildMobileHeader(),
                            ),
                          ),

                          SizedBox(height: isWide ? 30 : 25),

                          FadeTransition(
                            opacity: cardAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.12, 0),
                                end: Offset.zero,
                              ).animate(cardAnimation),
                              child: buildProfileForm(isWide),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: terracotta,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Eat well. Live fully.',
                                style: TextStyle(
                                  color: mutedGreen,
                                  fontSize: 12,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
