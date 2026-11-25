import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mealio/data/services/meal_data_service.dart';

const Color primaryGreen = Color(0xFF2C5E3B);
const Color darkGreen = Color(0xFF1E3F29);
const Color backgroundColor = Color(0xFFF3EFEA);
const Color creamColor = Color(0xFFF9E4D4);
const Color terracottaColor = Color(0xFFC86D51);
const Color mutedColor = Color(0xFF5A735E);
const Color borderColor = Color(0xFFE5DDD3);
const Color headingColor = Color(0xFF26382B);
const Color lightGreen = Color(0xFFE5EEDD);

class SavedMealsScreen extends StatefulWidget {
  final MealDataService mealService;
  final List<Map<String, dynamic>> savedMeals;

  const SavedMealsScreen({
    super.key,
    required this.mealService,
    this.savedMeals = const [],
  });

  @override
  State<SavedMealsScreen> createState() => _SavedMealsScreenState();
}

class _SavedMealsScreenState extends State<SavedMealsScreen>
    with TickerProviderStateMixin {
  late MealDataService mealService;

  List<Map<String, dynamic>> savedMeals = [];

  final List<String> mealTypes = [
    'All Meals',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  String selectedMealType = 'All Meals';

  bool isLoading = true;
  bool isUpdatingMeal = false;

  StreamSubscription<List<Map<String, dynamic>>>? mealsSubscription;

  late AnimationController headerController;
  late Animation<double> headerAnimation;

  @override
  void initState() {
    super.initState();

    mealService = widget.mealService;
    savedMeals = List<Map<String, dynamic>>.from(widget.savedMeals);

    headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    headerAnimation = CurvedAnimation(
      parent: headerController,
      curve: Curves.easeOutCubic,
    );

    headerController.forward();

    listenToMeals();
  }

  @override
  void dispose() {
    mealsSubscription?.cancel();
    headerController.dispose();
    super.dispose();
  }

  // LISTEN TO MEALS

  void listenToMeals() {
    mealsSubscription = mealService.watchMeals().listen(
      (result) {
        if (!mounted) return;

        setState(() {
          savedMeals = result;
          isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load saved meals: $error'),
            backgroundColor: darkGreen,
          ),
        );
      },
    );
  }

  //  HELPERS

  double toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  String formatNumber(dynamic value) {
    final number = toDouble(value);

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }

  List<Map<String, dynamic>> get filteredMeals {
    if (selectedMealType == 'All Meals') {
      return savedMeals;
    }

    return savedMeals.where((meal) {
      return meal['mealType']?.toString() == selectedMealType;
    }).toList();
  }

  bool isCustomMeal(Map<String, dynamic> meal) {
    return meal['mealKind']?.toString() == 'custom' ||
        meal['type']?.toString() == 'custom' ||
        meal['components'] is List;
  }

  // REFRESH

  Future<void> loadSavedMeals() async {
    if (!mounted) return;

    try {
      final result = await mealService.getMeals();

      if (!mounted) return;

      setState(() {
        savedMeals = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load saved meals: $e'),
          backgroundColor: darkGreen,
        ),
      );
    }
  }

  // DELETE MEAL

  Future<void> deleteMeal(Map<String, dynamic> meal) async {
    final mealId = meal['id']?.toString();

    if (mealId == null || mealId.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Meal',
            style: TextStyle(color: headingColor, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to delete this meal?',
            style: TextStyle(color: mutedColor, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: terracottaColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await mealService.deleteMeal(
        mealId,
        dateKey: meal['dateKey']?.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal deleted successfully'),
          backgroundColor: darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete meal: $e'),
          backgroundColor: terracottaColor,
        ),
      );
    }
  }

  // EDIT ORDINARY MEAL

  Future<void> editMeal(Map<String, dynamic> meal) async {
    final mealId = meal['id']?.toString();

    if (mealId == null || mealId.isEmpty) return;

    if (isCustomMeal(meal)) {
      await editCustomMealComponents(meal);
      return;
    }

    final gramsController = TextEditingController(
      text: formatNumber(meal['grams']),
    );

    final List<String> availableMealTypes = [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Snack',
    ];

    String selectedType =
        availableMealTypes.contains(meal['mealType']?.toString())
        ? meal['mealType'].toString()
        : 'Breakfast';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Edit Meal',
                style: TextStyle(
                  color: headingColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['foodName']?.toString() ?? 'Meal',
                      style: const TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Quantity (grams)',
                      style: TextStyle(
                        color: headingColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: gramsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      cursorColor: terracottaColor,
                      decoration: _dialogInputDecoration(suffixText: 'g'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Meal Type',
                      style: TextStyle(
                        color: headingColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: darkGreen,
                      ),
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _dialogInputDecoration(),
                      items: availableMealTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(
                              color: darkGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: mutedColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final newGrams = double.tryParse(
                      gramsController.text.trim().replaceAll(',', '.'),
                    );

                    if (newGrams == null || newGrams <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a valid quantity greater than zero.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'grams': newGrams,
                      'mealType': selectedType,
                    });
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    gramsController.dispose();

    if (result == null) return;

    final oldGrams = toDouble(meal['grams']);
    final newGrams = result['grams'] as double;

    if (oldGrams <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The original quantity is invalid.')),
      );
      return;
    }

    final factor = newGrams / oldGrams;

    try {
      setState(() {
        isUpdatingMeal = true;
      });

      await mealService.updateMeal(
        mealId: mealId,
        grams: newGrams,
        calories: toDouble(meal['calories']) * factor,
        protein: toDouble(meal['protein']) * factor,
        carbs: toDouble(meal['carbs']) * factor,
        fat: toDouble(meal['fat']) * factor,
        mealType: result['mealType'] as String,
        dateKey: meal['dateKey']?.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal updated successfully'),
          backgroundColor: darkGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update meal: $e'),
          backgroundColor: terracottaColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingMeal = false;
        });
      }
    }
  }

  // EDIT CUSTOM MEAL

  Future<void> editCustomMealComponents(Map<String, dynamic> meal) async {
    final mealId = meal['id']?.toString();

    if (mealId == null || mealId.isEmpty) return;

    final rawComponents = meal['components'];

    if (rawComponents is! List || rawComponents.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No ingredients were found in this Custom Meal.'),
        ),
      );
      return;
    }

    final components = rawComponents.map((component) {
      return Map<String, dynamic>.from(component as Map);
    }).toList();

    final controllers = <TextEditingController>[];

    for (final component in components) {
      controllers.add(
        TextEditingController(text: formatNumber(component['grams'])),
      );
    }

    final newQuantities = await showDialog<List<double>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Edit Custom Meal',
            style: TextStyle(
              color: headingColor,
              fontWeight: FontWeight.w800,
              fontSize: 21,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(components.length, (index) {
                  final component = components[index];

                  final name =
                      component['foodName']?.toString() ?? 'Ingredient';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: headingColor,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${formatNumber(component['calories'])} kcal',
                          style: const TextStyle(
                            color: terracottaColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: controllers[index],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          cursorColor: terracottaColor,
                          decoration: _dialogInputDecoration(
                            labelText: 'Quantity',
                            suffixText: 'g',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel', style: TextStyle(color: mutedColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final quantities = <double>[];

                for (final controller in controllers) {
                  final quantity = double.tryParse(
                    controller.text.trim().replaceAll(',', '.'),
                  );

                  if (quantity == null || quantity <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Every ingredient quantity must be greater than zero.',
                        ),
                      ),
                    );
                    return;
                  }

                  quantities.add(quantity);
                }

                Navigator.pop(dialogContext, quantities);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    for (final controller in controllers) {
      controller.dispose();
    }

    if (newQuantities == null) return;

    final updatedComponents = <Map<String, dynamic>>[];

    double totalGrams = 0;
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    const nutrientKeys = [
      'calories',
      'protein',
      'carbs',
      'fat',
      'fiber',
      'sugar',
      'saturatedFat',
      'sodium',
    ];

    for (int i = 0; i < components.length; i++) {
      final oldComponent = components[i];
      final updatedComponent = Map<String, dynamic>.from(oldComponent);

      final oldGrams = toDouble(oldComponent['grams']);
      final newGrams = newQuantities[i];

      if (oldGrams <= 0) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('One ingredient has an invalid original quantity.'),
          ),
        );
        return;
      }

      final factor = newGrams / oldGrams;

      updatedComponent['grams'] = newGrams;

      for (final key in nutrientKeys) {
        if (oldComponent[key] is num) {
          updatedComponent[key] = toDouble(oldComponent[key]) * factor;
        }
      }

      updatedComponents.add(updatedComponent);

      totalGrams += newGrams;
      totalCalories += toDouble(updatedComponent['calories']);
      totalProtein += toDouble(updatedComponent['protein']);
      totalCarbs += toDouble(updatedComponent['carbs']);
      totalFat += toDouble(updatedComponent['fat']);
    }

    try {
      if (mounted) {
        setState(() {
          isUpdatingMeal = true;
        });
      }

      await mealService.updateCustomMeal(
        mealId: mealId,
        mealType: meal['mealType']?.toString() ?? 'Breakfast',
        components: updatedComponents,
        grams: totalGrams,
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        dateKey: meal['dateKey']?.toString(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ingredient quantities and nutrition updated successfully',
          ),
          backgroundColor: darkGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update Custom Meal: $e'),
          backgroundColor: terracottaColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingMeal = false;
        });
      }
    }
  }

  InputDecoration _dialogInputDecoration({
    String? labelText,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        color: terracottaColor,
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: terracottaColor, width: 1.5),
      ),
    );
  }

  Widget buildFilterChip(String type) {
    final isSelected = selectedMealType == type;

    return Padding(
      padding: const EdgeInsets.only(right: 9, top: 5, bottom: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          setState(() {
            selectedMealType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? primaryGreen : borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryGreen.withValues(alpha: 0.16),
                      blurRadius: 9,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : headingColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
  //NUTRITION ITEM

  Widget buildNutritionItem(String label, dynamic value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: mutedColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${formatNumber(value)} $unit',
          style: const TextStyle(
            color: headingColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // MEAL CARD

  Widget buildMealCard(Map<String, dynamic> meal) {
    final name = meal['foodName']?.toString() ?? 'Meal';
    final mealType = meal['mealType']?.toString() ?? 'Meal';

    final components = meal['components'] is List
        ? List<Map<String, dynamic>>.from(
            (meal['components'] as List).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          )
        : <Map<String, dynamic>>[];

    final isCustom = isCustomMeal(meal);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Transform.scale(scale: value, child: child),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withValues(alpha: 0.055),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 17, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCustom
                              ? [creamColor, const Color(0xFFFCEDE3)]
                              : [lightGreen, const Color(0xFFF0F4E9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(
                        isCustom
                            ? Icons.restaurant_menu_rounded
                            : Icons.fastfood_rounded,
                        color: isCustom ? terracottaColor : primaryGreen,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(
                            name,
                            style: const TextStyle(
                              color: headingColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: creamColor.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mealType,
                              style: const TextStyle(
                                color: terracottaColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit meal',
                      onPressed: isUpdatingMeal ? null : () => editMeal(meal),
                      style: IconButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: primaryGreen,
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 19),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Delete meal',
                      onPressed: isUpdatingMeal ? null : () => deleteMeal(meal),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEEEE),
                        foregroundColor: Colors.redAccent,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.scale_rounded,
                        size: 18,
                        color: mutedColor,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${formatNumber(meal['grams'])} g',
                        style: const TextStyle(
                          color: headingColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 20,
                        color: terracottaColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${formatNumber(meal['calories'])} kcal',
                        style: const TextStyle(
                          color: terracottaColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: buildNutritionItem(
                        'Protein',
                        meal['protein'],
                        'g',
                      ),
                    ),
                    Expanded(
                      child: buildNutritionItem('Carbs', meal['carbs'], 'g'),
                    ),
                    Expanded(
                      child: buildNutritionItem('Fat', meal['fat'], 'g'),
                    ),
                  ],
                ),
              ),

              if (isCustom && components.isNotEmpty) ...[
                Container(height: 1, color: borderColor),
                Padding(
                  padding: const EdgeInsets.all(17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: creamColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: terracottaColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Ingredients',
                            style: TextStyle(
                              color: headingColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${components.length} items',
                            style: const TextStyle(
                              color: mutedColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      ...components.map((component) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: terracottaColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  component['foodName']?.toString() ??
                                      'Ingredient',
                                  style: const TextStyle(
                                    color: headingColor,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${formatNumber(component['grams'])} g',
                                style: const TextStyle(
                                  color: mutedColor,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${formatNumber(component['calories'])} kcal',
                                style: const TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  //  HEADER

  Widget buildHeader() {
    return FadeTransition(
      opacity: headerAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(headerAnimation),
        child: Container(
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
                          'Your Food Journal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Keep track of your meals and nutrition.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
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
                          child: Text(
                            '${savedMeals.length} Saved Meals',
                            style: const TextStyle(
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
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: creamColor,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget buildEmptyState() {
    return RefreshIndicator(
      onRefresh: loadSavedMeals,
      color: terracottaColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 75),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: creamColor,
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 53,
                color: terracottaColor,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Center(
            child: Text(
              'No Saved Meals Yet',
              style: TextStyle(
                color: headingColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Your saved meals will appear here.',
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Add your first meal and start tracking!',
              style: TextStyle(
                color: terracottaColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MAIN BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Saved Meals',
          style: TextStyle(
            color: headingColor,
            fontWeight: FontWeight.w900,
            fontSize: 21,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 17),
              child: buildHeader(),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: Row(
                children: [
                  const Text(
                    'Meal Categories',
                    style: TextStyle(
                      color: headingColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.tune_rounded,
                    color: terracottaColor,
                    size: 17,
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: mealTypes.map(buildFilterChip).toList(),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    )
                  : filteredMeals.isEmpty
                  ? buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: loadSavedMeals,
                      color: terracottaColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 25),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredMeals.length,
                        itemBuilder: (context, index) {
                          return buildMealCard(filteredMeals[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
