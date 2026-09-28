import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'pressable_scale.dart';

/// Circular icon chip like the reference AgriCare design
/// ("Crop Care", "Market Prices", "Expert Advice", "More")
class QuickActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? bgColor;
  final VoidCallback? onTap;

  const QuickActionIcon({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor ?? AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
