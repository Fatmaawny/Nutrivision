import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/viewmodels/water_scope.dart';
import 'package:mealio/viewmodels/water_viewmodel.dart';

import 'package:mealio/views/water/water_actions.dart';
import 'package:mealio/views/water/widgets/water_goal_dialog.dart';
import 'package:mealio/views/water/widgets/water_header.dart';
import 'package:mealio/views/water/widgets/water_hero_card.dart';
import 'package:mealio/views/water/widgets/water_quick_add.dart';
import 'package:mealio/views/water/widgets/water_stats_row.dart';

/// Full water screen (opened from the Home water card).
class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  Future<void> _editGoal(BuildContext context, WaterViewModel vm) async {
    final goal = await showWaterGoalDialog(context, vm.goal);
    if (goal != null) vm.setGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    final raw = WaterScope.maybeOf(context);
    // null until the view model exists and has finished loading
    final vm = (raw != null && raw.loaded) ? raw : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            WaterHeader(
              title: 'Water Intake',
              trailing: vm != null
                  ? WaterCircleButton(
                      icon: Icons.flag_outlined,
                      onTap: () => _editGoal(context, vm),
                    )
                  : null,
            ),
            Expanded(
              child: vm == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                          child: Column(
                            children: [
                              WaterHeroCard(vm: vm),
                              const SizedBox(height: 16),
                              WaterStatsRow(
                                vm: vm,
                                onEditGoal: () => _editGoal(context, vm),
                              ),
                              const SizedBox(height: 24),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Quick add',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              WaterQuickAdd(
                                onAdd: (ml) => logWater(context, vm, ml),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => vm.remove(vm.step),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondaryGreenText,
                                ),
                                icon: const Icon(Icons.undo_rounded, size: 18),
                                label: Text('Remove ${vm.step} ml'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
