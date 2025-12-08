import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../theme/app_theme.dart';

/// A toggle button to switch between light and dark themes
class ThemeToggleButton extends ConsumerWidget {
  final double size;
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.size = 24,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppTheme.getColors(context);

    if (showLabel) {
      return InkWell(
        onTap: () => _toggleTheme(ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  size: size,
                  color: isDark ? AppTheme.warning : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isDark ? 'Chế độ tối' : 'Chế độ sáng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => _toggleTheme(ref),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          key: ValueKey(isDark),
          size: size,
          color: isDark ? AppTheme.warning : AppTheme.primary,
        ),
      ),
      tooltip: isDark ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
    );
  }

  void _toggleTheme(WidgetRef ref) {
    final current = ref.read(themeModeProvider);
    ref.read(themeModeProvider.notifier).state = 
        current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// A more stylized toggle switch for theme
class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colors = AppTheme.getColors(context);

    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).state = 
            isDark ? ThemeMode.light : ThemeMode.dark;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 70,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFF74b9ff), const Color(0xFF81ecec)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppTheme.primary).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Stars for dark mode
            if (isDark) ...[
              Positioned(
                left: 10,
                top: 8,
                child: Icon(
                  Icons.star,
                  size: 8,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Positioned(
                left: 18,
                top: 18,
                child: Icon(
                  Icons.star,
                  size: 6,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              Positioned(
                left: 24,
                top: 10,
                child: Icon(
                  Icons.star,
                  size: 5,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
            // Clouds for light mode
            if (!isDark) ...[
              Positioned(
                right: 12,
                top: 10,
                child: Container(
                  width: 18,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 18,
                child: Container(
                  width: 12,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
            // Toggle Circle
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 38 : 4,
              top: 4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFFF1C40F) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isDark
                    ? const Icon(
                        Icons.nightlight_round,
                        size: 18,
                        color: Color(0xFF2C3E50),
                      )
                    : const Icon(
                        Icons.wb_sunny_rounded,
                        size: 18,
                        color: Color(0xFFF39C12),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
