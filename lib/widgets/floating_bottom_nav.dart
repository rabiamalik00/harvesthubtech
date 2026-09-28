import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavItem> items;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding : 12),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 21,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          if (item.badgeCount > 0)
                            Positioned(
                              top: -4,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : AppColors.accent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${item.badgeCount}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primary : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
