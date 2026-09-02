// File: lib/widgets/animated_counter.dart

import 'package:flutter/material.dart';

/// Smoothly animates from 0 → target number.
/// Used for command-center vibe: "counters count up".
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text('$prefix$val$suffix', style: style);
      },
    );
  }
}