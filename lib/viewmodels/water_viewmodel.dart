import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:mealio/core/utils/date_keys.dart';
import 'package:mealio/data/repositories/water_repository.dart';

/// State + logic of water tracking (shared by the Home card and the Water screen).
class WaterViewModel extends ChangeNotifier {
  final WaterRepository repo;

  /// Amount (ml) added/removed by the + / - buttons on the home card.
  final int step;

  Timer? _midnightTimer;
  int _goal;
  int _total = 0;
  String _dayKey = DateKeys.today();
  bool _loaded = false;
  bool _disposed = false;

  WaterViewModel({required this.repo, int goal = 2500, this.step = 300})
    : _goal = goal;

  bool get loaded => _loaded;
  int get goal => _goal;
  int get total => _total;
  int get remaining => math.max(0, _goal - _total);
  double get progress => _goal == 0 ? 0 : (_total / _goal).clamp(0.0, 1.0);
  bool get goalReached => _total >= _goal;
  int get percent => _goal == 0 ? 0 : (_total * 100 / _goal).round();

  Future<void> init() async {
    try {
      final last = await repo.loadLatest();
      if (_disposed) return;
      if (last != null) {
        _goal = last.goal;
        if (last.dateKey == _dayKey) _total = last.total; // same day only
      }
    } catch (e) {
      debugPrint('Water load failed: $e');
    }
    if (_disposed) return;
    _loaded = true;
    _scheduleMidnightReset();
    notifyListeners();
  }

  /// Starts a fresh day if the date changed (called on resume and at midnight).
  void refreshDay() {
    final today = DateKeys.today();
    if (today != _dayKey) {
      _dayKey = today;
      _total = 0;
      notifyListeners();
    }
  }

  /// Returns true if this add is the one that reached the goal.
  bool add(int ml) {
    refreshDay();
    final was = goalReached;
    _total += ml;
    _write(ml);
    notifyListeners();
    return !was && goalReached;
  }

  void remove(int ml) {
    refreshDay();
    final delta = math.min(ml, _total);
    if (delta <= 0) return;
    _total -= delta;
    _write(-delta);
    notifyListeners();
  }

  void setGoal(int ml) {
    if (ml <= 0) return;
    _goal = ml;
    repo.setGoal(dateKey: _dayKey, goal: ml).catchError((Object e) {
      debugPrint('Water goal save failed: $e');
    });
    notifyListeners();
  }

  void _write(int delta) {
    repo.addAmount(dateKey: _dayKey, delta: delta, goal: _goal).catchError((
      Object e,
    ) {
      debugPrint('Water save failed: $e');
    });
  }

  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      next.difference(now) + const Duration(seconds: 1),
      () {
        refreshDay();
        _scheduleMidnightReset();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _midnightTimer?.cancel();
    super.dispose();
  }
}
