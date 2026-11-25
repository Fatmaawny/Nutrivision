import 'package:flutter/material.dart';

import 'package:mealio/viewmodels/home_viewmodel.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/viewmodels/home_viewmodel.dart';
import 'package:mealio/views/bmi/bmi_screen.dart';
import 'package:mealio/views/home/widgets/desktop_navigation.dart';
import 'package:mealio/views/home/widgets/home_bottom_navigation.dart';
import 'package:mealio/views/home/widgets/home_selected_page.dart';
import 'package:mealio/views/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late final AnimationController _pageAnimationController;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel();

    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _pageAnimationController.forward();

    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  // PAGE NAVIGATION

  void _changePage(int index) {
    final switchedToHome = _viewModel.changePage(index);

    if (switchedToHome) {
      _pageAnimationController.forward(from: 0);
    }
  }

  // BMI

  void _openBmi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BmiScreen()),
    ).then((_) {
      if (!mounted) return;

      _viewModel.refresh();
    });
  }

  // LOGOUT

  Future<void> _logout() async {
    await _viewModel.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1000;
              final page = HomeSelectedPage(
                isLoading: vm.isLoading,
                isLoadingCalories: vm.isLoadingCalories,
                calories: vm.calories,
                protein: vm.protein,
                carbs: vm.carbs,
                fat: vm.fat,
                dailyCalorieGoal: vm.dailyCalorieGoal,
                userName: vm.userName,
                selectedIndex: vm.selectedIndex,
                mealService: vm.mealService,
                pageAnimationController: _pageAnimationController,
                onLogout: _logout,
                onPageChanged: _changePage,
                onOpenBmi: _openBmi,
                onRefreshCalories: vm.loadCalories,
                onRefreshUser: vm.loadUserData,
              );

              if (isDesktop) {
                return Row(
                  children: [
                    DesktopNavigation(
                      selectedIndex: vm.selectedIndex,
                      onLogout: _logout,
                      onPageChanged: _changePage,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            color: AppColors.background,
                            child: page,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return page;
            },
          ),
          bottomNavigationBar: MediaQuery.of(context).size.width >= 1000
              ? null
              : HomeBottomNavigation(
                  selectedIndex: vm.selectedIndex,
                  onPageChanged: _changePage,
                ),
        );
      },
    );
  }
}
