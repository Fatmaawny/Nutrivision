import 'package:flutter/material.dart';
import 'package:mealio/data/services/food_api.dart';
import 'package:mealio/data/services/meal_data_service.dart';
import 'package:mealio/data/services/nutrition_description_api.dart';

part 'widgets/meals_widgets.dart';

const Color primaryGreen = Color(0xFF2C5E3B);
const Color darkGreen = Color(0xFF1E3F29);
const Color backgroundColor = Color(0xFFF3EFEA);
const Color creamColor = Color(0xFFF9E4D4);
const Color terracottaColor = Color(0xFFC86D51);
const Color headingColor = Color(0xFF26382B);
const Color secondaryGreen = Color(0xFF5A735E);
const Color lightGreen = Color(0xFFE8EDE4);
const Color borderColor = Color(0xFFE5DDD3);
const Color cardColor = Color(0xFFFAF8F4);

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen>
    with SingleTickerProviderStateMixin {
  final FoodApiService foodApi = FoodApiService();
  final MealDataService mealService = MealDataService();
  final NutritionDescriptionApi nutritionApi = NutritionDescriptionApi();

  late AnimationController _mealCardController;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> analyzedFoods = [];

  bool isAnalyzing = false;
  bool isSavingDescribedMeal = false;

  String? analysisError;

  final Map<String, TextEditingController> quantityControllers = {};

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  final List<String> tabNames = ['Ingredients', 'Custom Meal', 'Describe Meal'];

  final List<IconData> tabIcons = [
    Icons.restaurant_menu_rounded,
    Icons.add_circle_outline_rounded,
    Icons.document_scanner_outlined,
  ];

  List<String> get categories => ['All', ...foodApi.categoryNames];

  List<Map<String, dynamic>> foods = [];
  List<Map<String, dynamic>> savedMeals = [];
  List<Map<String, dynamic>> customIngredients = [];

  final Set<String> loadingFoodIds = {};

  String selectedCategory = 'All';
  String selectedMealType = 'Breakfast';
  String currentQuery = '';

  int selectedTab = 0;
  int _foodRequestId = 0;
  int displayedFoodsCount = 30;

  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSaving = false;
  bool isInitializing = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _mealCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    initializeFoodData();
    loadSavedMeals();
  }

  @override
  void dispose() {
    _mealCardController.dispose();

    searchController.dispose();
    descriptionController.dispose();

    for (final controller in quantityControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  double toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double? nutrientValue(Map<String, dynamic> food, String key) {
    final value = food[key];

    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }

  String formatValue(dynamic value, {int decimals = 1}) {
    if (value is! num) return 'N/A';

    return value.toStringAsFixed(decimals);
  }

  String foodKey(Map<String, dynamic> food) {
    return food['fdcId']?.toString() ?? food['name']?.toString() ?? 'unknown';
  }

  TextEditingController quantityControllerFor(Map<String, dynamic> food) {
    final key = foodKey(food);

    if (!quantityControllers.containsKey(key)) {
      quantityControllers[key] = TextEditingController(text: '100');
    }

    return quantityControllers[key]!;
  }

  Future<void> initializeFoodData() async {
    try {
      await foodApi.initialize();

      if (!mounted) return;

      await loadFoods(query: '');
    } catch (e, stackTrace) {
      debugPrint('Error initializing food data: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isInitializing = false;
        isLoading = false;
        foods = [];
        errorMessage = 'Could not load food data. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    }
  }

  Future<void> loadFoods({required String query}) async {
    if (!mounted) return;

    final requestId = ++_foodRequestId;
    final requestedCategory = selectedCategory;
    final normalizedQuery = query.trim();

    setState(() {
      isLoading = true;
      errorMessage = null;
      currentQuery = normalizedQuery;
      displayedFoodsCount = 30;
    });

    try {
      List<Map<String, dynamic>> result = [];

      if (requestedCategory == 'All') {
        result = await foodApi.getFoods(query: normalizedQuery, pageSize: 500);
      } else {
        result = await foodApi.getFoodsByCategory(
          requestedCategory,
          pageSize: 500,
          maxPages: 1,
        );

        if (normalizedQuery.isNotEmpty) {
          final search = normalizedQuery.toLowerCase();

          result = result.where((food) {
            final name = (food['name'] ?? '').toString().toLowerCase();

            final category = (food['category'] ?? food['apiCategory'] ?? '')
                .toString()
                .toLowerCase();

            return name.contains(search) || category.contains(search);
          }).toList();
        }
      }

      if (!mounted || requestId != _foodRequestId) return;

      setState(() {
        foods = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e, stackTrace) {
      debugPrint('Could not load foods: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || requestId != _foodRequestId) return;

      setState(() {
        foods = [];
        isLoading = false;
        errorMessage = 'Could not load foods. Please try again.';
      });
    }
  }

  Future<void> loadSavedMeals() async {
    try {
      final result = await mealService.getMeals();

      if (!mounted) return;

      setState(() {
        savedMeals = result;
      });
    } catch (e) {
      debugPrint('Could not load saved meals: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load saved meals. Please log in again.'),
        ),
      );
    }
  }

  void searchFoods() {
    setState(() {
      selectedCategory = 'All';
    });

    loadFoods(query: searchController.text.trim());
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });

    loadFoods(query: searchController.text.trim());
  }

  List<Map<String, dynamic>> get visibleFoods => foods;

  double getMealCalories(String mealType) {
    double total = 0;

    for (final meal in savedMeals) {
      if (meal['mealType']?.toString() == mealType) {
        total += toDouble(meal['calories']);
      }
    }

    return total;
  }

  bool hasRequiredNutrients(Map<String, dynamic> food) {
    return nutrientValue(food, 'calories') != null &&
        nutrientValue(food, 'protein') != null &&
        nutrientValue(food, 'carbs') != null &&
        nutrientValue(food, 'fat') != null;
  }

  Future<void> addToCustomMeal(Map<String, dynamic> food) async {
    final key = foodKey(food);

    final existingIndex = customIngredients.indexWhere(
      (item) => foodKey(item) == key,
    );

    if (existingIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This ingredient is already in your meal.'),
        ),
      );
      return;
    }

    final controller = quantityControllerFor(food);
    final grams = double.tryParse(controller.text.trim());

    if (grams == null || !grams.isFinite || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity in grams.')),
      );
      return;
    }

    setState(() {
      loadingFoodIds.add(key);
    });

    try {
      Map<String, dynamic> selectedFood = Map<String, dynamic>.from(food);

      final id = food['fdcId'];

      if (id is num) {
        final details = await foodApi.getFoodDetails(id.toInt());

        selectedFood = {...food, ...details};
      }

      if (!mounted) return;

      setState(() {
        customIngredients.add({...selectedFood, 'grams': grams});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedFood['name']} added to Custom Meal'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Could not load food details: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load complete food details. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingFoodIds.remove(key);
        });
      }
    }
  }

  void changeIngredientQuantity(int index, String value) {
    final grams = double.tryParse(value);

    if (grams == null || !grams.isFinite || grams <= 0) {
      return;
    }

    setState(() {
      customIngredients[index]['grams'] = grams;
    });
  }

  void removeCustomIngredient(int index) {
    setState(() {
      customIngredients.removeAt(index);
    });
  }

  double? customTotal(String nutrient) {
    double total = 0;

    for (final food in customIngredients) {
      final value = nutrientValue(food, nutrient);

      if (value == null) return null;

      final grams = toDouble(food['grams']);
      total += value * grams / 100;
    }

    return total;
  }

  double get customTotalGrams {
    double total = 0;

    for (final food in customIngredients) {
      total += toDouble(food['grams']);
    }

    return total;
  }

  Future<void> saveCustomMeal() async {
    if (isSaving) return;

    if (customIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient first.')),
      );
      return;
    }

    final incompleteFoods = customIngredients
        .where((food) => !hasRequiredNutrients(food))
        .toList();

    if (incompleteFoods.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some ingredients are missing calories or macros.'),
        ),
      );
      return;
    }

    final calories = customTotal('calories');
    final protein = customTotal('protein');
    final carbs = customTotal('carbs');
    final fat = customTotal('fat');

    if (calories == null || protein == null || carbs == null || fat == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final components = customIngredients.map((food) {
        final grams = toDouble(food['grams']);

        return <String, dynamic>{
          'foodName': food['name']?.toString() ?? 'Unknown food',
          'fdcId': food['fdcId'],
          'grams': grams,
          'calories': toDouble(food['calories']) * grams / 100,
          'protein': toDouble(food['protein']) * grams / 100,
          'carbs': toDouble(food['carbs']) * grams / 100,
          'fat': toDouble(food['fat']) * grams / 100,
          'fiber': nutrientValue(food, 'fiber') == null
              ? null
              : toDouble(food['fiber']) * grams / 100,
          'sugar': nutrientValue(food, 'sugar') == null
              ? null
              : toDouble(food['sugar']) * grams / 100,
          'saturatedFat': nutrientValue(food, 'saturatedFat') == null
              ? null
              : toDouble(food['saturatedFat']) * grams / 100,
          'sodium': nutrientValue(food, 'sodium') == null
              ? null
              : toDouble(food['sodium']) * grams / 100,
          'nutritionSource': 'USDA FoodData Central',
        };
      }).toList();

      await mealService.addCustomMeal(
        foodName: selectedMealType,
        mealType: selectedMealType,
        components: components,
        grams: customTotalGrams,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      await loadSavedMeals();

      if (!mounted) return;

      setState(() {
        customIngredients.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom meal saved successfully!'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Could not save custom meal: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save meal: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------
  // DESCRIBE MEAL
  // ---------------------------------------------------------

  Future<void> analyzeMealDescription() async {
    final description = descriptionController.text.trim();

    if (description.isEmpty) {
      setState(() {
        analysisError = 'Please describe your meal first.';
        analyzedFoods = [];
      });
      return;
    }

    setState(() {
      isAnalyzing = true;
      isSavingDescribedMeal = false;
      analysisError = null;
      analyzedFoods = [];
    });

    try {
      final results = await nutritionApi.analyzeMeal(description);

      if (!mounted) return;

      setState(() {
        analyzedFoods = results;

        if (results.isEmpty) {
          analysisError =
              'No ingredients were recognized. Try describing the meal in English.';
        }
      });
    } catch (e) {
      debugPrint('Meal analysis error: $e');

      if (!mounted) return;

      setState(() {
        analysisError = 'Could not analyze your meal. Please try again.';
        analyzedFoods = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  Future<void> searchUsdaForIngredient(int index) async {
    if (index < 0 || index >= analyzedFoods.length) return;

    final item = analyzedFoods[index];
    final ingredientName = item['name']?.toString() ?? '';

    if (ingredientName.trim().isEmpty) return;

    setState(() {
      item['isSearchingUsda'] = true;
      item['usdaMatches'] = [];
    });

    try {
      final results = await foodApi.getFoods(
        query: ingredientName,
        pageSize: 20,
      );

      if (!mounted) return;

      setState(() {
        item['usdaMatches'] = results;
        item['isSearchingUsda'] = false;
      });

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No matching foods found for $ingredientName.'),
          ),
        );
        return;
      }

      await showUsdaResultsDialog(index, results);
    } catch (e) {
      debugPrint('Ingredient search error: $e');

      if (!mounted) return;

      setState(() {
        item['isSearchingUsda'] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not search for this ingredient. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> showUsdaResultsDialog(
    int ingredientIndex,
    List<Map<String, dynamic>> results,
  ) async {
    final selectedResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Choose a Food',
            style: TextStyle(color: headingColor, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: borderColor),
              itemBuilder: (context, index) {
                final food = results[index];

                final name = food['name']?.toString() ?? 'Unknown food';

                final category =
                    food['category']?.toString() ??
                    food['apiCategory']?.toString() ??
                    '';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: headingColor,
                    ),
                  ),
                  subtitle: category.isNotEmpty
                      ? Text(
                          category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: secondaryGreen,
                          ),
                        )
                      : null,
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: primaryGreen,
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext, food);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryGreen),
              ),
            ),
          ],
        );
      },
    );

    if (selectedResult == null || !mounted) return;

    await selectUsdaFood(ingredientIndex, selectedResult);
  }

  Future<void> selectUsdaFood(
    int index,
    Map<String, dynamic> selectedResult,
  ) async {
    final id = selectedResult['fdcId'];

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This food could not be selected. Please choose another one.',
          ),
        ),
      );
      return;
    }

    try {
      final details = await foodApi.getFoodDetails(int.parse(id.toString()));

      if (!mounted) return;

      final selectedFood = {...selectedResult, ...details};

      if (!hasRequiredNutrients(selectedFood)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This food does not contain complete nutrition information. Choose another one.',
            ),
          ),
        );
        return;
      }

      setState(() {
        final item = analyzedFoods[index];

        item['selectedFood'] = selectedFood;
        item['nutritionSource'] = 'USDA FoodData Central';

        final referenceGrams = item['referenceGrams'];

        if (referenceGrams is num && referenceGrams > 0) {
          item['grams'] = referenceGrams.toDouble();
        } else {
          item['grams'] = null;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedFood['name']} selected successfully.'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Could not load food details: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load food details. Please try another result.',
          ),
        ),
      );
    }
  }

  void updateDescribedIngredientGrams(int index, String value) {
    final grams = double.tryParse(value.trim());

    setState(() {
      if (grams == null || !grams.isFinite || grams <= 0) {
        analyzedFoods[index]['grams'] = null;
      } else {
        analyzedFoods[index]['grams'] = grams;
      }
    });
  }

  double? describedIngredientNutrient(
    Map<String, dynamic> item,
    String nutrient,
  ) {
    final selectedFood = item['selectedFood'];
    final grams = item['grams'];

    if (selectedFood is! Map || grams is! num || grams <= 0) {
      return null;
    }

    final food = Map<String, dynamic>.from(selectedFood);
    final per100g = nutrientValue(food, nutrient);

    if (per100g == null) return null;

    return per100g * grams.toDouble() / 100;
  }

  double describedTotal(String nutrient) {
    double total = 0;

    for (final item in analyzedFoods) {
      final value = describedIngredientNutrient(item, nutrient);

      if (value == null) return 0;

      total += value;
    }

    return total;
  }

  bool get isDescribedMealReady {
    if (analyzedFoods.isEmpty) return false;

    for (final item in analyzedFoods) {
      final selectedFood = item['selectedFood'];
      final grams = item['grams'];

      if (selectedFood is! Map) return false;

      if (grams is! num || !grams.isFinite || grams <= 0) {
        return false;
      }

      final food = Map<String, dynamic>.from(selectedFood);

      if (!hasRequiredNutrients(food)) return false;
    }

    return true;
  }

  double get describedTotalGrams {
    if (!isDescribedMealReady) return 0;

    return analyzedFoods.fold<double>(0, (total, item) {
      return total + toDouble(item['grams']);
    });
  }

  Future<void> saveDescribedMeal() async {
    if (isSavingDescribedMeal) return;

    if (analyzedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analyze a meal before saving it.')),
      );
      return;
    }

    if (!isDescribedMealReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose a food and enter a valid weight in grams for every ingredient.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSavingDescribedMeal = true;
    });

    final calories = describedTotal('calories');
    final protein = describedTotal('protein');
    final carbs = describedTotal('carbs');
    final fat = describedTotal('fat');

    try {
      final components = analyzedFoods.map((item) {
        final selectedFood = Map<String, dynamic>.from(item['selectedFood']);

        final grams = toDouble(item['grams']);

        return <String, dynamic>{
          'foodName':
              selectedFood['name']?.toString() ??
              item['name']?.toString() ??
              'Ingredient',
          'fdcId': selectedFood['fdcId'],
          'originalDescription': item['original']?.toString() ?? '',
          'amount': toDouble(item['amount']),
          'unit': item['originalUnit']?.toString() ?? '',
          'originalUnit': item['originalUnit']?.toString() ?? '',
          'grams': grams,
          'calories': describedIngredientNutrient(item, 'calories'),
          'protein': describedIngredientNutrient(item, 'protein'),
          'carbs': describedIngredientNutrient(item, 'carbs'),
          'fat': describedIngredientNutrient(item, 'fat'),
          'fiber': describedIngredientNutrient(item, 'fiber'),
          'sugar': describedIngredientNutrient(item, 'sugar'),
          'saturatedFat': describedIngredientNutrient(item, 'saturatedFat'),
          'sodium': describedIngredientNutrient(item, 'sodium'),
          'nutritionSource': 'USDA FoodData Central',
        };
      }).toList();

      await mealService.addCustomMeal(
        foodName: selectedMealType,
        mealType: selectedMealType,
        components: components,
        grams: describedTotalGrams,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      await loadSavedMeals();

      if (!mounted) return;

      setState(() {
        analyzedFoods.clear();
        descriptionController.clear();
        analysisError = null;
        isSavingDescribedMeal = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Described meal saved successfully!'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Could not save described meal: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save meal: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSavingDescribedMeal = false;
        });
      }
    }
  }

  // ---------------------------------------------------------
  // SAVED MEALS
  // ---------------------------------------------------------

  Future<void> deleteMeal(String mealId) async {
    try {
      await mealService.deleteMeal(mealId);
      await loadSavedMeals();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal deleted.'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Could not delete meal: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not delete meal.')));
    }
  }

  Future<void> editSavedMeal(Map<String, dynamic> meal) async {
    final mealId = meal['id']?.toString() ?? '';

    if (mealId.isEmpty) return;

    final isCustom = meal['mealKind'] == 'custom';

    final gramsController = TextEditingController(
      text: toDouble(meal['grams']).toStringAsFixed(0),
    );

    String mealType = meal['mealType']?.toString() ?? 'Breakfast';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Edit Meal',
                style: TextStyle(
                  color: headingColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: gramsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: this._inputDecoration(label: 'Quantity (g)'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: mealType,
                    decoration: this._inputDecoration(label: 'Meal type'),
                    items: mealTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          mealType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: secondaryGreen),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final grams = double.tryParse(gramsController.text.trim());

                    if (grams == null || !grams.isFinite || grams <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid quantity.'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'grams': grams,
                      'mealType': mealType,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    gramsController.dispose();

    if (result == null || !mounted) return;

    final newGrams = result['grams'] as double;
    final newMealType = result['mealType'] as String;
    final oldGrams = toDouble(meal['grams']);

    if (oldGrams <= 0) return;

    final factor = newGrams / oldGrams;

    try {
      if (isCustom) {
        final components = (meal['components'] as List? ?? [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .map((item) {
              item['grams'] = toDouble(item['grams']) * factor;

              for (final nutrient in [
                'calories',
                'protein',
                'carbs',
                'fat',
                'fiber',
                'sugar',
                'saturatedFat',
                'sodium',
              ]) {
                if (item[nutrient] is num) {
                  item[nutrient] = toDouble(item[nutrient]) * factor;
                }
              }

              return item;
            })
            .toList();

        await mealService.updateCustomMeal(
          mealId: mealId,
          mealType: newMealType,
          components: components,
          grams: newGrams,
          calories: toDouble(meal['calories']) * factor,
          protein: toDouble(meal['protein']) * factor,
          carbs: toDouble(meal['carbs']) * factor,
          fat: toDouble(meal['fat']) * factor,
        );
      } else {
        await mealService.updateMeal(
          mealId: mealId,
          grams: newGrams,
          calories: toDouble(meal['calories']) * factor,
          protein: toDouble(meal['protein']) * factor,
          carbs: toDouble(meal['carbs']) * factor,
          fat: toDouble(meal['fat']) * factor,
          mealType: newMealType,
        );
      }

      await loadSavedMeals();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal updated successfully!'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint('Could not update meal: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update meal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: primaryGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Row(
          children: [
            Icon(Icons.eco_rounded, color: primaryGreen, size: 25),
            SizedBox(width: 9),
            Text(
              'MEALIO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryGreen,
                fontSize: 19,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryGreen,
          backgroundColor: cardColor,
          onRefresh: () async {
            if (selectedTab == 0) {
              await loadFoods(query: searchController.text.trim());
            }

            await loadSavedMeals();
          },
          child: LayoutBuilder(
            builder: (context, screenConstraints) {
              final screenWidth = screenConstraints.maxWidth;

              final horizontalPadding = screenWidth >= 1100
                  ? 55.0
                  : screenWidth >= 700
                  ? 30.0
                  : 18.0;

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  10,
                  horizontalPadding,
                  35,
                ),
                children: [
                  AnimatedBuilder(
                    animation: _mealCardController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 2 * (1 - _mealCardController.value)),
                        child: child,
                      );
                    },
                    child: this._buildHeader(screenWidth),
                  ),
                  const SizedBox(height: 27),
                  this._buildMealCaloriesSection(screenWidth),
                  const SizedBox(height: 26),
                  this._buildTabs(),
                  const SizedBox(height: 22),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.035, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(selectedTab),
                      child: buildSelectedTab(),
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
}
