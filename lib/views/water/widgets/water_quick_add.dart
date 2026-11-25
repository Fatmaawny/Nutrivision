import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';
import 'package:mealio/core/theme/app_decorations.dart';

class _Amount {
  final int ml;
  final String label;
  final IconData icon;
  const _Amount(this.ml, this.label, this.icon);
}

const _amounts = [
  _Amount(150, 'Sip', Icons.water_drop_outlined),
  _Amount(300, 'Glass', Icons.local_drink_rounded),
  _Amount(500, 'Bottle', Icons.water_rounded),
];

/// Three quick-add tiles (+150 / +300 / +500 ml).
class WaterQuickAdd extends StatelessWidget {
  final ValueChanged<int> onAdd;
  const WaterQuickAdd({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _amounts.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _AddTile(
              amount: _amounts[i],
              onTap: () => onAdd(_amounts[i].ml),
            ),
          ),
        ],
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  final _Amount amount;
  final VoidCallback onTap;
  const _AddTile({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: homeCardDecoration(radius: 20),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  amount.icon,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '+${amount.ml} ml',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryGreenText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
