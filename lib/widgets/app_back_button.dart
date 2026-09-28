import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// A stylish, modern Back Button designed with smooth rounded styling,
/// subtle background pill/circle, and tactile feedback.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final String tooltip;
  final bool withLabel;
  final String label;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.tooltip = 'Back',
    this.withLabel = false,
    this.label = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    final isAppBarDark = (backgroundColor != null)
        ? ThemeData.estimateBrightnessForColor(backgroundColor!) == Brightness.dark
        : true; // Default assumption for green/purple headers

    final effectiveIconColor = color ?? (isAppBarDark ? Colors.white : AppColors.textPrimary);
    final effectiveBgColor = backgroundColor ??
        (isAppBarDark
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.primarySurface);

    final action = onPressed ?? () => Navigator.maybePop(context);

    if (withLabel) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Tooltip(
          message: tooltip,
          child: Material(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: action,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: effectiveIconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: effectiveIconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: effectiveBgColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: action,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(right: 2), // optical center for back chevron
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: effectiveIconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon builder for Theme actionIconTheme backButtonIconBuilder
class AppBackButtonIcon extends StatelessWidget {
  final Color? color;
  const AppBackButtonIcon({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: color ?? Colors.white,
        ),
      ),
    );
  }
}
