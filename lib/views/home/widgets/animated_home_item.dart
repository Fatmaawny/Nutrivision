import 'package:flutter/material.dart';

class AnimatedHomeItem extends StatelessWidget {
  const AnimatedHomeItem({
    super.key,
    required this.child,
    required this.start,
    required this.end,
    required this.pageAnimationController,
  });

  final Widget child;
  final double start;
  final double end;
  final AnimationController pageAnimationController;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: pageAnimationController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
