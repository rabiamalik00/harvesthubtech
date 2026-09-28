import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_colors.dart';

/// AgriCare style animated stat card with circular icon badge, soft rounded background,
/// and smooth number count-up animation.
class AnimatedStatCard extends StatefulWidget {
  final String label;
  final num value;
  final String? prefix;
  final String? suffix;
  final IconData icon;
  final Color? iconColor;
  final Color? badgeBgColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    this.prefix,
    this.suffix,
    required this.icon,
    this.iconColor,
    this.badgeBgColor,
    this.subtitle,
    this.onTap,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ?? AppColors.primary;
    final effectiveBadgeBg = widget.badgeBgColor ?? AppColors.primarySurface;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: effectiveBadgeBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: effectiveIconColor, size: 20),
                    ),
                    if (widget.subtitle != null)
                      Flexible(
                        child: Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    final currentVal = widget.value * _animation.value;
                    String formatted;
                    if (widget.value is int) {
                      formatted = currentVal.round().toString();
                    } else {
                      formatted = currentVal.toStringAsFixed(1);
                    }
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}
