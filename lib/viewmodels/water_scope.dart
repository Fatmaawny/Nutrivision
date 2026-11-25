import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mealio/data/repositories/auth_repository.dart';
import 'package:mealio/data/repositories/water_repository.dart';
import 'package:mealio/viewmodels/water_viewmodel.dart';

/// Put this ONCE in MaterialApp(builder: ...). It follows the logged-in user:
/// creates a [WaterViewModel] (saving to Firestore) on login and disposes it
/// on logout. Because it sits above the Navigator, every route can use it.
class WaterScope extends StatefulWidget {
  final Widget child;
  const WaterScope({super.key, required this.child});

  /// Null while logged out or before the view model exists.
  static WaterViewModel? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_WaterInherited>()?.notifier;

  @override
  State<WaterScope> createState() => _WaterScopeState();
}

class _WaterScopeState extends State<WaterScope> with WidgetsBindingObserver {
  StreamSubscription<User?>? _sub;
  WaterViewModel? _viewModel;
  String? _uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sub = AuthRepository().authStateChanges().listen(_onUserChanged);
  }

  void _onUserChanged(User? user) {
    if (!mounted || user?.uid == _uid) return;
    _uid = user?.uid;

    final old = _viewModel;
    WaterViewModel? next;
    if (user != null) {
      next = WaterViewModel(repo: WaterRepository(user.uid));
      unawaited(next.init());
    }

    setState(() => _viewModel = next);

    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = _viewModel;
    if (state == AppLifecycleState.resumed && vm != null && vm.loaded) {
      vm.refreshDay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _WaterInherited(notifier: _viewModel, child: widget.child);
}

class _WaterInherited extends InheritedNotifier<WaterViewModel> {
  const _WaterInherited({required super.notifier, required super.child});
}
