import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/calorie_calculator.dart';

final RouteObserver<ModalRoute<dynamic>> routeObserver =
    RouteObserver<ModalRoute<dynamic>>();

const Color primaryGreen = Color(0xFF2C5E3B);
const Color darkGreen = Color(0xFF1E3F29);
const Color backgroundColor = Color(0xFFF3EFEA);
const Color creamColor = Color(0xFFF9E4D4);
const Color terracottaColor = Color(0xFFC86D51);
const Color mutedColor = Color(0xFF5A735E);
const Color borderColor = Color(0xFFE5DDD3);
const Color headingColor = Color(0xFF26382B);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, RouteAware {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();
  final TextEditingController otherAllergyController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;

  String gender = 'Female';
  String activityLevel = 'Sedentary';
  String healthGoal = 'Maintain Weight';
  String dietaryPreference = 'No Restrictions';
  String weeklyWeightLoss = '0.5';

  Set<String> selectedAllergies = {'None'};

  Map<String, dynamic> originalData = {};
  Map<String, bool> focusedFields = {};

  late AnimationController headerAnimationController;
  late Animation<double> headerAnimation;

  final List<bool> sectionVisible = [false, false, false, false];

  final List<String> genderOptions = ['Female', 'Male', 'Prefer not to say'];

  final List<String> activityOptions = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active',
  ];

  final List<String> healthGoalOptions = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Weight',
    'Eat Healthier',
  ];

  final List<String> dietaryOptions = [
    'No Restrictions',
    'Vegetarian',
    'Vegan',
    'Pescatarian',
  ];

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

  final List<String> weeklyLossOptions = ['0.25', '0.5', '0.75', '1.0'];

  @override
  void initState() {
    super.initState();

    headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    headerAnimation = CurvedAnimation(
      parent: headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    headerAnimationController.forward();

    loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {
    startSectionsAnimation();
  }

  @override
  void didPopNext() {
    startSectionsAnimation();
  }

  void startSectionsAnimation() {
    for (int i = 0; i < sectionVisible.length; i++) {
      sectionVisible[i] = false;
    }

    if (mounted) {
      setState(() {});
    }

    for (int i = 0; i < sectionVisible.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 250)), () {
        if (!mounted) return;

        setState(() {
          sectionVisible[i] = true;
        });
      });
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    headerAnimationController.dispose();

    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    otherAllergyController.dispose();

    super.dispose();
  }

  //NORMALIZE DATA

  String normalizeGender(dynamic value) {
    String result = value?.toString() ?? 'Female';

    if (result == 'Male' || result == 'ذكر') return 'Male';

    if (result == 'Prefer not to say') {
      return 'Prefer not to say';
    }

    return 'Female';
  }

  String normalizeChoice(
    dynamic value,
    List<String> options,
    String defaultValue,
  ) {
    String result = value?.toString() ?? defaultValue;

    return options.contains(result) ? result : defaultValue;
  }

  String normalizeWeeklyLoss(dynamic value) {
    String result = value?.toString() ?? '0.5';

    if (result == '1') result = '1.0';

    return weeklyLossOptions.contains(result) ? result : '0.5';
  }

  // LOAD PROFILE

  Future<void> loadProfile() async {
    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('users')
          .doc(user!.uid)
          .get();

      Map<String, dynamic> data = snapshot.data() ?? {};

      if (!mounted) return;

      setState(() {
        originalData = Map<String, dynamic>.from(data);
        populateFields(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      showMessage('Failed to load profile: $e');
    }
  }

  void populateFields(Map<String, dynamic> data) {
    nameController.text =
        data['name']?.toString() ??
        data['fullName']?.toString() ??
        user?.displayName ??
        '';

    ageController.text = data['age']?.toString() ?? '';
    heightController.text = data['height']?.toString() ?? '';
    weightController.text = data['weight']?.toString() ?? '';
    targetWeightController.text = data['targetWeight']?.toString() ?? '';

    gender = normalizeGender(data['gender']);

    activityLevel = normalizeChoice(
      data['activityLevel'],
      activityOptions,
      'Sedentary',
    );

    healthGoal = normalizeChoice(
      data['healthGoal'],
      healthGoalOptions,
      'Maintain Weight',
    );

    dietaryPreference = normalizeChoice(
      data['dietaryPreference'],
      dietaryOptions,
      'No Restrictions',
    );

    weeklyWeightLoss = normalizeWeeklyLoss(data['weeklyWeightLoss']);

    selectedAllergies = {};
    otherAllergyController.clear();

    dynamic allergiesData = data['foodAllergies'];

    if (allergiesData is List) {
      for (dynamic allergy in allergiesData) {
        String value = allergy.toString();

        if (value.startsWith('Other: ')) {
          selectedAllergies.add('Other');
          otherAllergyController.text = value.substring('Other: '.length);
        } else if (value == 'Other') {
          selectedAllergies.add('Other');
        } else if (allergyOptions.contains(value)) {
          selectedAllergies.add(value);
        }
      }
    }

    if (selectedAllergies.isEmpty || selectedAllergies.contains('None')) {
      selectedAllergies = {'None'};
    }
  }

  // EDIT PROFILE

  void startEditing() {
    setState(() => isEditing = true);
  }

  void cancelEditing() {
    setState(() {
      populateFields(originalData);
      isEditing = false;
      focusedFields.clear();
    });

    FocusScope.of(context).unfocus();
  }

  // VALIDATION

  double? parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    double? number = parseNumber(value);

    if (number == null || number <= 0) {
      return 'Enter a valid $fieldName';
    }

    return null;
  }

  //  SAVE PROFILE

  Future<void> saveProfile() async {
    if (user == null) {
      showMessage('Please log in first.');
      return;
    }

    if (!formKey.currentState!.validate()) return;

    int? age = int.tryParse(ageController.text.trim());

    double? height = parseNumber(heightController.text);
    double? weight = parseNumber(weightController.text);

    double? targetWeight;

    if (healthGoal == 'Lose Weight' || healthGoal == 'Gain Weight') {
      targetWeight = parseNumber(targetWeightController.text);

      if (targetWeight == null || targetWeight <= 0) {
        showMessage('Please enter a valid target weight.');
        return;
      }

      if (weight == null || weight <= 0) {
        showMessage('Please enter a valid current weight.');
        return;
      }

      if (healthGoal == 'Lose Weight' && targetWeight >= weight) {
        showMessage(
          'For weight loss, the target weight must be lower than your current weight.',
        );
        return;
      }

      if (healthGoal == 'Gain Weight' && targetWeight <= weight) {
        showMessage(
          'For weight gain, the target weight must be higher than your current weight.',
        );
        return;
      }
    }

    if (age == null || age <= 0 || age > 120) {
      showMessage('Please enter a valid age.');
      return;
    }

    if (height == null || height <= 0 || weight == null || weight <= 0) {
      showMessage('Please check your height and weight.');
      return;
    }

    List<String> allergies = [];

    if (selectedAllergies.contains('None')) {
      allergies = ['None'];
    } else {
      allergies = selectedAllergies
          .where((item) => item != 'Other' && item != 'None')
          .toList();

      if (selectedAllergies.contains('Other')) {
        String otherAllergy = otherAllergyController.text.trim();

        if (otherAllergy.isEmpty) {
          showMessage('Please specify your other allergy.');
          return;
        }

        allergies.add('Other: $otherAllergy');
      }
    }

    setState(() => isSaving = true);

    try {
      double calorieGoal = CalorieCalculator.calculateCalories(
        weight: weight,
        height: height,
        age: age.toDouble(),
        gender: gender,
        activityLevel: activityLevel,
        healthGoal: healthGoal,
      );
      Map<String, dynamic> savedFields = {
        'name': nameController.text.trim(),
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        'healthGoal': healthGoal,
        'targetWeight': targetWeight,
        'weeklyWeightLoss': healthGoal == 'Lose Weight'
            ? double.parse(weeklyWeightLoss)
            : null,
        'foodAllergies': allergies,
        'dietaryPreference': dietaryPreference,
        'calorieGoal': calorieGoal,

      };

      await firestore.collection('users').doc(user!.uid).set({
        ...savedFields,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (nameController.text.trim().isNotEmpty) {
        await user!.updateDisplayName(nameController.text.trim());
      }

      if (!mounted) return;

      setState(() {
        originalData = {...originalData, ...savedFields};
        isEditing = false;
        isSaving = false;
      });

      FocusScope.of(context).unfocus();

      showMessage('Profile updated successfully!');
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      showMessage('Failed to save profile: $e');
    }
  }

  //ALLERGIES

  void toggleAllergy(String allergy, bool selected) {
    setState(() {
      if (allergy == 'None') {
        selectedAllergies = selected ? {'None'} : {};
        return;
      }

      selectedAllergies.remove('None');

      if (selected) {
        selectedAllergies.add(allergy);
      } else {
        selectedAllergies.remove(allergy);
      }

      if (selectedAllergies.isEmpty) {
        selectedAllergies = {'None'};
      }
    });
  }

  // MESSAGE

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  // DISPLAY HELPERS

  String get allergyDisplayText {
    if (selectedAllergies.contains('None')) {
      return 'None';
    }

    List<String> items = selectedAllergies.toList();

    if (items.contains('Other')) {
      String other = otherAllergyController.text.trim();

      items.remove('Other');
      items.add(other.isNotEmpty ? other : 'Other');
    }

    return items.isEmpty ? 'None' : items.join(', ');
  }

  String get displayName {
    String name = nameController.text.trim();

    if (name.isNotEmpty) return name;

    return user?.email ?? 'User';
  }

  //MAIN PAGE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: headingColor,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: headingColor,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: terracottaColor,
              size: 21,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : user == null
          ? const Center(
              child: Text(
                'Please log in to view your profile.',
                style: TextStyle(color: mutedColor),
              ),
            )
          : SafeArea(
              child: Form(
                key: formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double padding = constraints.maxWidth >= 1000 ? 48 : 20;

                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: 15,
                      ),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: Column(
                              children: [
                                buildAnimatedHeader(),

                                const SizedBox(height: 28),

                                // PERSONAL INFORMATION
                                buildSection(
                                  title: 'Personal Information',
                                  subtitle: 'Your basic personal details',
                                  icon: Icons.person_outline_rounded,
                                  accent: primaryGreen,
                                  number: '01',
                                  children: [
                                    responsiveGrid([
                                      buildTextField(
                                        label: 'Full Name',
                                        controller: nameController,
                                        icon: Icons.badge_outlined,
                                        validator: (value) =>
                                            validateRequired(value, 'Name'),
                                      ),
                                      buildTextField(
                                        label: 'Email Address',
                                        initialValue: user!.email ?? '',
                                        icon: Icons.email_outlined,
                                        enabled: false,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      buildTextField(
                                        label: 'Age',
                                        controller: ageController,
                                        icon: Icons.cake_outlined,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          String? result = validateRequired(
                                            value,
                                            'Age',
                                          );

                                          if (result != null) {
                                            return result;
                                          }

                                          int? number = int.tryParse(
                                            value!.trim(),
                                          );

                                          if (number == null ||
                                              number <= 0 ||
                                              number > 120) {
                                            return 'Enter a valid age';
                                          }

                                          return null;
                                        },
                                      ),
                                      buildDropdown(
                                        label: 'Gender',
                                        value: gender,
                                        options: genderOptions,
                                        icon: Icons.wc_outlined,
                                        onChanged: (value) {
                                          setState(() {
                                            gender = value!;
                                          });
                                        },
                                      ),
                                    ]),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // BODY INFORMATION
                                buildSection(
                                  title: 'Body Information',
                                  subtitle: 'Your measurements and activity',
                                  icon: Icons.monitor_weight_outlined,
                                  accent: terracottaColor,
                                  number: '02',
                                  children: [
                                    responsiveGrid([
                                      buildTextField(
                                        label: 'Height (cm)',
                                        controller: heightController,
                                        icon: Icons.height_rounded,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (value) =>
                                            validatePositiveNumber(
                                              value,
                                              'height',
                                            ),
                                      ),
                                      buildTextField(
                                        label: 'Weight (kg)',
                                        controller: weightController,
                                        icon: Icons.monitor_weight_outlined,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        validator: (value) =>
                                            validatePositiveNumber(
                                              value,
                                              'weight',
                                            ),
                                      ),
                                      buildDropdown(
                                        label: 'Activity Level',
                                        value: activityLevel,
                                        options: activityOptions,
                                        icon: Icons.directions_walk_rounded,
                                        onChanged: (value) {
                                          setState(() {
                                            activityLevel = value!;
                                          });
                                        },
                                      ),
                                    ]),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // HEALTH GOALS
                                buildSection(
                                  title: 'Health Goals',
                                  subtitle: 'Set your personal health targets',
                                  icon: Icons.flag_rounded,
                                  accent: terracottaColor,
                                  number: '03',
                                  children: [
                                    responsiveGrid([
                                      buildDropdown(
                                        label: 'Health Goal',
                                        value: healthGoal,
                                        options: healthGoalOptions,
                                        icon: Icons.track_changes_rounded,
                                        onChanged: (value) {
                                          setState(() {
                                            healthGoal = value!;
                                          });
                                        },
                                      ),
                                      if (healthGoal == 'Lose Weight' ||
                                          healthGoal == 'Gain Weight')
                                        buildTextField(
                                          label: 'Target Weight (kg)',
                                          controller: targetWeightController,
                                          icon: Icons.monitor_weight_outlined,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          validator: (value) {
                                            if (healthGoal != 'Lose Weight' &&
                                                healthGoal != 'Gain Weight') {
                                              return null;
                                            }

                                            return validatePositiveNumber(
                                              value,
                                              'target weight',
                                            );
                                          },
                                        ),
                                      if (healthGoal == 'Lose Weight')
                                        buildDropdown(
                                          label: 'Weekly Weight Loss (kg)',
                                          value: weeklyWeightLoss,
                                          options: weeklyLossOptions,
                                          icon: Icons.trending_down_rounded,
                                          onChanged: (value) {
                                            setState(() {
                                              weeklyWeightLoss = value!;
                                            });
                                          },
                                        ),
                                    ]),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // DIETARY PREFERENCES
                                buildSection(
                                  title: 'Dietary Preferences',
                                  subtitle: 'Customize your food preferences',
                                  icon: Icons.restaurant_menu_rounded,
                                  accent: primaryGreen,
                                  number: '04',
                                  children: [
                                    responsiveGrid([
                                      buildDropdown(
                                        label: 'Dietary Preference',
                                        value: dietaryPreference,
                                        options: dietaryOptions,
                                        icon: Icons.eco_outlined,
                                        onChanged: (value) {
                                          setState(() {
                                            dietaryPreference = value!;
                                          });
                                        },
                                      ),
                                    ]),

                                    const SizedBox(height: 8),

                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.health_and_safety_rounded,
                                          color: terracottaColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 9),
                                        Text(
                                          'Food Allergies',
                                          style: TextStyle(
                                            color: headingColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 13),

                                    if (isEditing)
                                      Wrap(
                                        spacing: 9,
                                        runSpacing: 9,
                                        children: allergyOptions.map((allergy) {
                                          bool selected = selectedAllergies
                                              .contains(allergy);

                                          return FilterChip(
                                            label: Text(allergy),
                                            selected: selected,
                                            onSelected: (value) {
                                              toggleAllergy(allergy, value);
                                            },
                                            selectedColor: creamColor,
                                            checkmarkColor: terracottaColor,
                                            backgroundColor: const Color(
                                              0xFFFAF8F5,
                                            ),
                                            side: BorderSide(
                                              color: selected
                                                  ? terracottaColor
                                                  : borderColor,
                                              width: selected ? 1.5 : 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            labelStyle: TextStyle(
                                              color: selected
                                                  ? darkGreen
                                                  : mutedColor,
                                              fontSize: 12.5,
                                              fontWeight: selected
                                                  ? FontWeight.w800
                                                  : FontWeight.w500,
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    else
                                      buildReadOnlyValue(
                                        allergyDisplayText,
                                        Icons.health_and_safety_outlined,
                                      ),

                                    if (isEditing &&
                                        selectedAllergies.contains(
                                          'Other',
                                        )) ...[
                                      const SizedBox(height: 14),
                                      buildTextField(
                                        label: 'Specify Other Allergy',
                                        controller: otherAllergyController,
                                        icon: Icons.edit_outlined,
                                      ),
                                    ],

                                    if (isEditing &&
                                        !selectedAllergies.contains(
                                          'None',
                                        )) ...[
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Select all allergies that apply.',
                                        style: TextStyle(
                                          color: mutedColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 24),

                                buildActionButtons(),

                                const SizedBox(height: 35),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget buildAnimatedHeader() {
    return FadeTransition(
      opacity: headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(headerAnimation),
        child: buildProfileHeader(),
      ),
    );
  }

  Widget buildProfileHeader() {
    String firstLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, primaryGreen, Color(0xFF527956)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -20,
            top: -35,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 45,
            bottom: -48,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: creamColor.withValues(alpha: 0.10),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to MEALIO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Hello, $displayName',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: creamColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MY PROFILE',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      color: creamColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String number,
    required List<Widget> children,
  }) {
    int index = (int.tryParse(number) ?? 1) - 1;

    bool visible =
        index >= 0 && index < sectionVisible.length && sectionVisible[index];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      opacity: visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 0.18),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          scale: visible ? 1 : 0.94,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: darkGreen.withValues(alpha: 0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: 0.20),
                            accent.withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(icon, color: accent, size: 26),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: headingColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: mutedColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    Container(
                      width: 47,
                      height: 47,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE9DA), Color(0xFFF9E4D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: terracottaColor.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: terracottaColor.withValues(alpha: 0.13),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          number,
                          style: const TextStyle(
                            color: terracottaColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: borderColor)),

                    const SizedBox(width: 10),

                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(child: Container(height: 1, color: borderColor)),
                  ],
                ),

                const SizedBox(height: 20),

                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  RESPONSIVE GRID

  Widget responsiveGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >= 950) {
          columns = 3;
        } else if (constraints.maxWidth >= 560) {
          columns = 2;
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 0,
          //mainAxisExtent: 112,
          children: children,
        );
      },
    );
  }

  Widget buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    bool canEdit = isEditing && enabled;
    bool isFocused = focusedFields[label] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              label,
              style: const TextStyle(
                color: headingColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 7),

          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: isFocused
                  ? creamColor.withValues(alpha: 0.25)
                  : const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: terracottaColor.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Focus(
              onFocusChange: (focused) {
                if (!mounted) return;

                setState(() {
                  focusedFields[label] = focused;
                });
              },
              child: TextFormField(
                controller: controller,
                initialValue: controller == null ? initialValue : null,
                enabled: canEdit,
                keyboardType: keyboardType,
                validator: validator,
                style: const TextStyle(
                  color: headingColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                cursorColor: terracottaColor,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: isFocused ? terracottaColor : mutedColor,
                    size: 19,
                  ),

                  filled: true,
                  fillColor: Colors.transparent,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderColor),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderColor, width: 1),
                  ),

                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderColor, width: 1),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: terracottaColor,
                      width: 1.5,
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    String safeValue = options.contains(value) ? value : options.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        isExpanded: true,
        dropdownColor: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: terracottaColor,
        ),
        style: const TextStyle(
          color: headingColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mutedColor, size: 19),
          labelStyle: const TextStyle(color: mutedColor, fontSize: 12.5),
          floatingLabelStyle: const TextStyle(
            color: terracottaColor,
            fontWeight: FontWeight.w800,
          ),
          filled: true,
          fillColor: const Color(0xFFFAF8F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: terracottaColor, width: 1.5),
          ),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: headingColor, fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: isEditing ? onChanged : null,
      ),
    );
  }

  // READ ONLY VALUE

  Widget buildReadOnlyValue(String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: creamColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: terracottaColor, size: 20),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: headingColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    if (isEditing) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 380;

          Widget cancelButton = OutlinedButton.icon(
            onPressed: isSaving ? null : cancelEditing,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: darkGreen,
              side: const BorderSide(color: primaryGreen, width: 1.4),
              minimumSize: const Size(0, 51),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );

          Widget saveButton = ElevatedButton.icon(
            onPressed: isSaving ? null : saveProfile,
            icon: isSaving
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 19),
            label: Text(isSaving ? 'Saving...' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: terracottaColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: terracottaColor.withValues(alpha: 0.25),
              minimumSize: const Size(0, 51),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );

          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [saveButton, const SizedBox(height: 12), cancelButton],
            );
          }

          return Row(
            children: [
              Expanded(child: cancelButton),
              const SizedBox(width: 13),
              Expanded(child: saveButton),
            ],
          );
        },
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: startEditing,
        icon: const Icon(Icons.edit_rounded, size: 19),
        label: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryGreen.withValues(alpha: 0.22),
          minimumSize: const Size(0, 53),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
