import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';

class GlassBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.calendar_today_rounded, label: 'Book'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Results'),
    _NavItem(icon: Icons.payment_rounded, label: 'Payments'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(GlassBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: colors.glassBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.glassShadow,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final tabWidth = totalWidth / _items.length;

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final t = Curves.easeOutBack.transform(
                        _controller.value.clamp(0.0, 1.0),
                      );
                      final pillLeft = lerpDouble(
                        _previousIndex * tabWidth,
                        widget.currentIndex * tabWidth,
                        t,
                      )!;

                      return SizedBox(
                        height: 46,
                        child: Stack(
                          children: [
                            // Sliding pill indicator
                            Positioned(
                              left: pillLeft + 4,
                              top: 1,
                              child: Container(
                                width: tabWidth - 8,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            // Tab items
                            Row(
                              children: List.generate(_items.length, (i) {
                                final item = _items[i];
                                final selected = widget.currentIndex == i;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => widget.onTap(i),
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                      height: 46,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          AnimatedScale(
                                            scale: selected ? 1.15 : 1.0,
                                            duration: const Duration(milliseconds: 350),
                                            curve: Curves.easeOutBack,
                                            child: Icon(
                                              item.icon,
                                              size: 22,
                                              color: selected
                                                  ? AppColors.primary
                                                  : colors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 250),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: selected
                                                  ? AppColors.primary
                                                  : colors.textMuted,
                                            ),
                                            child: Text(item.label),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
