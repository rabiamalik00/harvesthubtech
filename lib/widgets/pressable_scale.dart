import 'package:flutter/material.dart';

/// Micro-interaction wrapper that subtly scales down on tap and springs back.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double targetScale;
  final Duration duration;

  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.targetScale = 0.96,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () {
        if (_isPressed) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.targetScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
