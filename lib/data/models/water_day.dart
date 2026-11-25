/// One day of water intake.
class WaterDay {
  final String dateKey; // yyyy-MM-dd
  final int total; // ml
  final int goal; // ml

  const WaterDay({
    required this.dateKey,
    required this.total,
    required this.goal,
  });

  factory WaterDay.fromMap(Map<String, dynamic> m) => WaterDay(
    dateKey: (m['dateKey'] ?? '').toString(),
    total: (m['total'] as num?)?.toInt() ?? 0,
    goal: (m['goal'] as num?)?.toInt() ?? 2500,
  );
}
