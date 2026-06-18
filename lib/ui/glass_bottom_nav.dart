import 'package:flutter/material.dart';
import '../theme/prism_theme.dart';
import 'glass_components.dart';
import 'package:flutter/services.dart';

class GlassBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassBottomNavItem> items;

  const GlassBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.prismTheme;
    final itemCount = items.length;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      borderRadius: 28,
      blurSigma: 24,
      borderWidth: 0.5,
      borderColorOverride: theme.glassBorder,
      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(itemCount, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(index);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.accentIndigo.withValues(alpha: theme.isDark ? 0.22 : 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? theme.accentIndigo.withValues(alpha: 0.35)
                          : Colors.transparent,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? theme.accentIndigo.withValues(alpha: 0.15)
                            : Colors.transparent,
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? theme.accentIndigo
                                : theme.textSecondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? theme.accentIndigo
                                : theme.textSecondary,
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Active dot indicator
                        AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: AnimatedScale(
                            scale: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: theme.accentIndigo,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.accentIndigo.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class GlassBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
