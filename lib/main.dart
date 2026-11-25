import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mealio/app.dart';
import 'package:mealio/data/repositories/auth_repository.dart';
import 'package:mealio/data/repositories/session_repository.dart';
import 'package:mealio/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SessionRepository().enforceStartupPolicy(AuthRepository());

  runApp(const MealioApp());
}
