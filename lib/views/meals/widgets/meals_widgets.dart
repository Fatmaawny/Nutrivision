
part of '../meals_screen.dart';

extension _MealsScreenWidgets on _MealsScreenState {
  Widget sectionTitle(String title, {IconData? icon, double fontSize = 20}) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: primaryGreen, size: 22),
          ),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: headingColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mealCaloriesCard(
      String title,
      double calories,
      IconData icon,
      Color accentColor, {
        bool compact = false,
      }) {
    return AnimatedBuilder(
      animation: _mealCardController,
      builder: (context, child) {
        final animationValue = _mealCardController.value;
        final scale = 0.985 + (animationValue * 0.015);
        final shadowBlur = 10.0 + (animationValue * 9.0);
        final shadowOpacity = 0.06 + (animationValue * 0.07);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 9 : 13,
              vertical: compact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(compact ? 16 : 20),
              border: Border.all(
                color: accentColor.withOpacity(0.20),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(shadowOpacity),
                  blurRadius: shadowBlur,
                  spreadRadius: 1,
                  offset: Offset(0, 3 + animationValue * 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 36 : 45,
                  height: compact ? 36 : 45,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(compact ? 12 : 15),
                    border: Border.all(
                      color: accentColor.withOpacity(0.12),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: compact ? 19 : 24,
                  ),
                ),
                SizedBox(width: compact ? 8 : 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryGreen,
                        ),
                      ),
                      SizedBox(height: compact ? 3 : 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${calories.round()} kcal',
                          style: TextStyle(
                            fontSize: compact ? 14 : 17,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _macroText(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        '$title: ${formatValue(value)} g',
        style: const TextStyle(
          fontSize: 12,
          color: secondaryGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _nutrientChip(String title, dynamic value, String unit) {
    final formatted = value is num
        ? '${value.toStringAsFixed(1)} $unit'
        : 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        '$title: $formatted',
        style: const TextStyle(
          fontSize: 11,
          color: secondaryGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: secondaryGreen, size: 20),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    required IconData icon,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(icon, size: 19),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: secondaryGreen.withOpacity(0.35),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  Widget buildFoodCard(Map<String, dynamic> food) {
    final controller = quantityControllerFor(food);
    final key = foodKey(food);

    final name = food['name']?.toString() ?? 'Unknown food';

    final category = food['category']?.toString().trim().isNotEmpty == true
        ? food['category'].toString()
        : food['apiCategory']?.toString().trim() ?? '';

    final calories = nutrientValue(food, 'calories');
    final protein = nutrientValue(food, 'protein');
    final carbs = nutrientValue(food, 'carbs');
    final fat = nutrientValue(food, 'fat');

    final isAdding = loadingFoodIds.contains(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: primaryGreen,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category.isEmpty ? 'Uncategorized' : category,
                      style: const TextStyle(
                        color: secondaryGreen,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatValue(calories)} kcal / 100 g',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _nutrientChip('Protein', protein, 'g'),
                    _nutrientChip('Carbs', carbs, 'g'),
                    _nutrientChip('Fat', fat, 'g'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(label: 'Quantity (g)'),
                ),
              ),
              const SizedBox(width: 9),
              IconButton(
                onPressed: isAdding ? null : () => addToCustomMeal(food),
                icon: isAdding
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryGreen,
                  ),
                )
                    : const Icon(Icons.playlist_add_rounded),
                color: primaryGreen,
                style: IconButton.styleFrom(
                  backgroundColor: creamColor,
                  minimumSize: const Size(49, 49),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CUSTOM MEAL
  Widget buildCustomIngredientCard(Map<String, dynamic> food, int index) {
    final grams = toDouble(food['grams']);
    final factor = grams / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  food['name']?.toString() ?? 'Ingredient',
                  style: const TextStyle(
                    color: headingColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => removeCustomIngredient(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: terracottaColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextFormField(
                  key: ValueKey('${foodKey(food)}_${grams.toString()}'),
                  initialValue: grams.toStringAsFixed(0),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(label: 'Grams').copyWith(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  onChanged: (value) {
                    changeIngredientQuantity(index, value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${(toDouble(food['calories']) * factor).toStringAsFixed(1)} kcal',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _nutrientChip('Protein', toDouble(food['protein']) * factor, 'g'),
              _nutrientChip('Carbs', toDouble(food['carbs']) * factor, 'g'),
              _nutrientChip('Fat', toDouble(food['fat']) * factor, 'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCustomMealTabBody() {
    final calories = customTotal('calories');
    final protein = customTotal('protein');
    final carbs = customTotal('carbs');
    final fat = customTotal('fat');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Create your own meal',
          icon: Icons.add_circle_outline_rounded,
        ),
        const SizedBox(height: 9),
        const Text(
          'Add ingredients from the Ingredients tab, then set their quantities here.',
          style: TextStyle(color: secondaryGreen, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        const Text(
          'Meal Type',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mealTypes.map((type) {
            final selected = selectedMealType == type;

            return ChoiceChip(
              label: Text(type),
              selected: selected,
              showCheckmark: false,
              selectedColor: primaryGreen,
              backgroundColor: cardColor,
              side: BorderSide(color: selected ? primaryGreen : borderColor),
              labelStyle: TextStyle(
                color: selected ? Colors.white : headingColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              onSelected: (_) {
                setState(() {
                  selectedMealType = type;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        if (customIngredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              children: [
                Icon(Icons.no_food_outlined, color: secondaryGreen, size: 35),
                SizedBox(height: 10),
                Text(
                  'No ingredients added yet.',
                  style: TextStyle(
                    color: headingColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Go to Ingredients and tap the list icon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryGreen, fontSize: 12),
                ),
              ],
            ),
          )
        else ...[
          ...List.generate(
            customIngredients.length,
                (index) =>
                buildCustomIngredientCard(customIngredients[index], index),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: terracottaColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Nutrition Summary',
                      style: TextStyle(
                        color: headingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Text(
                  'Total quantity: ${customTotalGrams.toStringAsFixed(0)} g',
                  style: const TextStyle(color: secondaryGreen),
                ),
                const SizedBox(height: 5),
                Text(
                  'Calories: ${calories?.toStringAsFixed(1) ?? 'N/A'} kcal',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 7),
                _macroText('Protein', protein),
                _macroText('Carbs', carbs),
                _macroText('Fat', fat),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _primaryButton(
            label: isSaving ? 'Saving...' : 'Save Custom Meal',
            onPressed: isSaving ? null : saveCustomMeal,
            icon: Icons.save_outlined,
            loading: isSaving,
          ),
        ],
      ],
    );
  }

  // DESCRIBE MEAL
  Widget buildDescribedIngredientCard(Map<String, dynamic> item, int index) {
    final selectedFood = item['selectedFood'];
    final grams = item['grams'];
    final unit = item['originalUnit']?.toString() ?? '';
    final amount = toDouble(item['amount']);
    final isSearching = item['isSearchingUsda'] == true;

    final selectedName = selectedFood is Map
        ? selectedFood['name']?.toString() ?? ''
        : '';

    return Container(
      key: ValueKey('described_ingredient_$index'),
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['name']?.toString() ?? 'Ingredient',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: headingColor,
              fontSize: 15,
            ),
          ),
          if ((item['original'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item['original'].toString(),
              style: const TextStyle(color: secondaryGreen, fontSize: 11),
            ),
          ],
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              'Original amount: ${amount.toStringAsFixed(2)} ${unit.isEmpty ? '' : unit}',
              style: const TextStyle(color: secondaryGreen, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSearching
                  ? null
                  : () => searchUsdaForIngredient(index),
              icon: isSearching
                  ? const SizedBox(
                height: 17,
                width: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryGreen,
                ),
              )
                  : const Icon(Icons.search_rounded),
              label: Text(
                isSearching
                    ? 'Searching...'
                    : selectedFood is Map
                    ? 'Change Food'
                    : 'Find Food',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: const BorderSide(color: primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (selectedFood is Map) ...[
            const SizedBox(height: 11),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: primaryGreen,
                        size: 17,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Food selected',
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    selectedName,
                    style: const TextStyle(
                      color: headingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${formatValue(selectedFood['calories'])} kcal / 100 g',
                    style: const TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _nutrientChip('Protein', selectedFood['protein'], 'g'),
                      _nutrientChip('Carbs', selectedFood['carbs'], 'g'),
                      _nutrientChip('Fat', selectedFood['fat'], 'g'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('described_grams_$index'),
              initialValue: grams is num ? grams.toString() : '',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration:
              _inputDecoration(
                label: 'Actual quantity (grams)',
                hint: 'Enter weight in grams',
              ).copyWith(
                helperText:
                'Enter the actual weight. Do not use cups or pieces here.',
              ),
              onChanged: (value) {
                updateDescribedIngredientGrams(index, value);
              },
            ),
            const SizedBox(height: 10),
            if (grams is num && grams > 0) ...[
              const Text(
                'Calculated Nutrition',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _nutrientChip(
                    'Calories',
                    describedIngredientNutrient(item, 'calories'),
                    'kcal',
                  ),
                  _nutrientChip(
                    'Protein',
                    describedIngredientNutrient(item, 'protein'),
                    'g',
                  ),
                  _nutrientChip(
                    'Carbs',
                    describedIngredientNutrient(item, 'carbs'),
                    'g',
                  ),
                  _nutrientChip(
                    'Fat',
                    describedIngredientNutrient(item, 'fat'),
                    'g',
                  ),
                  _nutrientChip(
                    'Fiber',
                    describedIngredientNutrient(item, 'fiber'),
                    'g',
                  ),
                ],
              ),
            ],
          ] else ...[
            const SizedBox(height: 8),
            const Text(
              'Choose a food and enter its weight in grams to calculate nutrition.',
              style: TextStyle(color: secondaryGreen, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildDescribeMealTab() {
    final totalCalories = describedTotal('calories');
    final totalProtein = describedTotal('protein');
    final totalCarbs = describedTotal('carbs');
    final totalFat = describedTotal('fat');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          'Describe your meal',
          icon: Icons.document_scanner_outlined,
        ),
        const SizedBox(height: 9),
        const Text(
          'Describe your meal to identify its ingredients and calculate the nutritional values.',
          style: TextStyle(color: secondaryGreen, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: descriptionController,
          minLines: 3,
          maxLines: 5,
          decoration: _inputDecoration(
            label: 'Meal description',
            hint: 'Example: 2 boiled eggs, 1 slice of toast, 1 banana',
            icon: Icons.edit_note_rounded,
          ),
        ),
        const SizedBox(height: 13),
        _primaryButton(
          onPressed: isAnalyzing ? null : analyzeMealDescription,
          loading: isAnalyzing,
          icon: Icons.search_rounded,
          label: isAnalyzing ? 'Analyzing...' : 'Analyze Meal',
        ),
        if (analysisError != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8B8B8)),
            ),
            child: Text(
              analysisError!,
              style: const TextStyle(color: Color(0xFFB3261E)),
            ),
          ),
        ],
        if (analyzedFoods.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Meal Type',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mealTypes.map((type) {
              final selected = selectedMealType == type;

              return ChoiceChip(
                label: Text(type),
                selected: selected,
                showCheckmark: false,
                selectedColor: primaryGreen,
                backgroundColor: cardColor,
                side: BorderSide(color: selected ? primaryGreen : borderColor),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : headingColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedMealType = type;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: creamColor,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: terracottaColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Total Nutrition',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: headingColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (isDescribedMealReady) ...[
                  Text(
                    'Total quantity: ${describedTotalGrams.toStringAsFixed(1)} g',
                    style: const TextStyle(color: secondaryGreen),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Calories: ${totalCalories.toStringAsFixed(1)} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                      fontSize: 16,
                    ),
                  ),
                  _macroText('Protein', totalProtein),
                  _macroText('Carbs', totalCarbs),
                  _macroText('Fat', totalFat),
                ] else ...[
                  const Text(
                    'Select a food and enter the weight in grams for every ingredient to calculate the total.',
                    style: TextStyle(
                      color: secondaryGreen,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${analyzedFoods.length} ingredient(s) identified',
                  style: const TextStyle(color: secondaryGreen, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(
            analyzedFoods.length,
                (index) =>
                buildDescribedIngredientCard(analyzedFoods[index], index),
          ),
          const SizedBox(height: 8),
          _primaryButton(
            onPressed: (isSavingDescribedMeal || !isDescribedMealReady)
                ? null
                : saveDescribedMeal,
            icon: Icons.save_outlined,
            loading: isSavingDescribedMeal,
            label: isSavingDescribedMeal ? 'Saving...' : 'Save Meal',
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------
  // SAVED MEALS
  // ---------------------------------------------------------

  Widget buildSavedMealCard(Map<String, dynamic> meal) {
    final name = meal['foodName']?.toString() ?? 'Unknown food';

    final grams = toDouble(meal['grams']);
    final calories = toDouble(meal['calories']);
    final protein = toDouble(meal['protein']);
    final carbs = toDouble(meal['carbs']);
    final fat = toDouble(meal['fat']);

    final mealType = meal['mealType']?.toString() ?? 'Snack';
    final mealId = meal['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(Icons.restaurant_rounded, color: primaryGreen),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        subtitle: Text(
          '$mealType • ${grams.toStringAsFixed(0)} g\n'
              '${calories.toStringAsFixed(1)} kcal'
              ' | P ${protein.toStringAsFixed(1)} g'
              ' | C ${carbs.toStringAsFixed(1)} g'
              ' | F ${fat.toStringAsFixed(1)} g',
          style: const TextStyle(
            color: secondaryGreen,
            height: 1.5,
            fontSize: 12,
          ),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: mealId.isEmpty ? null : () => editSavedMeal(meal),
              icon: const Icon(Icons.edit_outlined, color: primaryGreen),
            ),
            IconButton(
              onPressed: mealId.isEmpty ? null : () => deleteMeal(mealId),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: terracottaColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INGREDIENTS TAB
  Widget buildIngredientsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Find your food', icon: Icons.search_rounded),
        const SizedBox(height: 9),
        const Text(
          'Search for ingredients and control the quantity in grams.',
          style: TextStyle(color: secondaryGreen, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onSubmitted: (_) => searchFoods(),
                decoration: _inputDecoration(
                  label: 'Search food',
                  hint: 'Arabic or English',
                  icon: Icons.search_rounded,
                ),
              ),
            ),
            const SizedBox(width: 9),
            IconButton(
              onPressed: searchFoods,
              icon: const Icon(Icons.search_rounded),
              style: IconButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(51, 51),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 19),
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategory == category;

              return ChoiceChip(
                label: Text(category),
                selected: selected,
                showCheckmark: false,
                selectedColor: primaryGreen,
                backgroundColor: cardColor,
                side: BorderSide(color: selected ? primaryGreen : borderColor),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : headingColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                onSelected: (_) {
                  selectCategory(category);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        if (isInitializing || isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: CircularProgressIndicator(
                color: primaryGreen,
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Color(0xFFB3261E)),
            ),
          )
        else if (visibleFoods.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, color: secondaryGreen, size: 35),
                  SizedBox(height: 10),
                  Text(
                    'No foods found.',
                    style: TextStyle(
                      color: headingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Try another search or category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryGreen, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int columns = 1;

                if (width >= 1000) {
                  columns = 3;
                } else if (width >= 620) {
                  columns = 2;
                }

                final displayedCount = visibleFoods.length < displayedFoodsCount
                    ? visibleFoods.length
                    : displayedFoodsCount;

                return Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 450,
                      ),
                      itemBuilder: (context, index) {
                        return buildFoodCard(visibleFoods[index]);
                      },
                    ),
                    if (displayedCount < visibleFoods.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              displayedFoodsCount += 30;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryGreen,
                            side: const BorderSide(color: primaryGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Load More Foods'),
                        ),
                      ),
                  ],
                );
              },
            ),
      ],
    );
  }

  Widget buildSelectedTab() {
    if (selectedTab == 0) {
      return buildIngredientsTab();
    }

    if (selectedTab == 1) {
      return buildCustomMealTabBody();
    }

    return buildDescribeMealTab();
  }

  // ---------------------------------------------------------
  // MAIN SCREEN HEADER
  // ---------------------------------------------------------

  Widget _buildHeader(double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width >= 700 ? 27 : 21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkGreen, primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: Icon(
              Icons.restaurant_rounded,
              size: 115,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: creamColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MEALIO',
                    style: TextStyle(
                      color: creamColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Meal Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width >= 700 ? 29 : 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Build balanced meals and keep track of your nutrition.',
                style: TextStyle(
                  color: Color(0xFFE5EDE5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCaloriesSection(double screenWidth) {
    final isDesktop = screenWidth >= 900;

    final mealCards = [
      {
        'title': 'Breakfast',
        'icon': Icons.free_breakfast_rounded,
        'color': terracottaColor,
      },
      {
        'title': 'Lunch',
        'icon': Icons.lunch_dining_rounded,
        'color': primaryGreen,
      },
      {
        'title': 'Dinner',
        'icon': Icons.dinner_dining_rounded,
        'color': secondaryGreen,
      },
      {
        'title': 'Snack',
        'icon': Icons.cookie_rounded,
        'color': const Color(0xFFB68A4B),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Calories by Meal', icon: Icons.pie_chart_outline_rounded),
        const SizedBox(height: 6),
        const Text(
          'Track your calories throughout the day.',
          style: TextStyle(color: secondaryGreen, fontSize: 13),
        ),
        const SizedBox(height: 17),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mealCards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth >= 600 ? 4 : 2,
            crossAxisSpacing: isDesktop ? 10 : 13,
            mainAxisSpacing: isDesktop ? 10 : 13,
            mainAxisExtent: isDesktop ? 78 : 94,
          ),
          itemBuilder: (context, index) {
            final item = mealCards[index];
            final title = item['title'] as String;

            return _mealCaloriesCard(
              title,
              getMealCalories(title),
              item['icon'] as IconData,
              item['color'] as Color,
              compact: isDesktop,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabNames.length, (index) {
          final selected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  color: selected ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : [],
                ),
                child: Column(
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        tabIcons[index],
                        color: selected ? Colors.white : secondaryGreen,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tabNames[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: selected ? Colors.white : headingColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
