import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mealio/data/repositories/auth_repository.dart';
import 'package:mealio/viewmodels/water_scope.dart';
import 'package:mealio/views/auth/welcome_screen.dart';
import 'package:mealio/views/home/home_screen.dart';
import 'package:mealio/views/profile/profile_screen.dart';

class MealioApp extends StatelessWidget {
  const MealioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      navigatorObservers: [routeObserver],

      builder: (context, child) =>
          WaterScope(child: child ?? const SizedBox.shrink()),

      home: StreamBuilder<User?>(
        stream: AuthRepository().authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const WelcomeScreen();
        },
      ),
    );
  }
}
