import 'package:flutter/material.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'book_screen.dart';
import 'results_screen.dart';
import 'payments_screen.dart';
import 'settings_screen.dart';

class CabinetShell extends StatefulWidget {
  const CabinetShell({super.key});

  @override
  State<CabinetShell> createState() => _CabinetShellState();
}

class _CabinetShellState extends State<CabinetShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    BookScreen(),
    ResultsScreen(),
    PaymentsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedGradientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
