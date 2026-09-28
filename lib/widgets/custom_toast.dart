import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Shows a competition-grade floating snackbar with rounded corners, icon, and subtle elevation
void showHarvestSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_rounded,
  Color iconColor = Colors.white,
  Color backgroundColor = AppColors.primary,
  Duration duration = const Duration(milliseconds: 2200),
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 4,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: duration,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: action.onPressed,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  action.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
