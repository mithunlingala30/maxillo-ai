import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import '../predict/predict_flow_screen.dart';
import '../profile/profile_screen.dart';
import '../recovery/recovery_screen.dart';
import '../reports/reports_screen.dart';

/// Hosts the 5 main tabs (Home, Predict, Reports, Recovery, Profile)
/// behind a persistent bottom navigation bar, mirroring the Figma
/// App.tsx shell.
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  final _screens = const [
    HomeScreen(),
    PredictFlowScreen(),
    ReportsScreen(),
    RecoveryScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.psychology_alt_rounded, label: 'Predict'),
    (icon: Icons.description_rounded, label: 'Reports'),
    (icon: Icons.favorite_rounded, label: 'Recovery'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MainShellController(
        goTo: goTo,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final active = i == _index;
                final item = _items[i];
                return InkWell(
                  onTap: () => goTo(i),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.blueBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 22, color: active ? AppColors.primaryBlue : AppColors.placeholder),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: active ? AppColors.primaryBlue : AppColors.placeholder,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets nested screens (e.g. Home's action cards) switch tabs on the
/// nearest [MainShell] ancestor.
class MainShellController extends InheritedWidget {
  final void Function(int index) goTo;

  const MainShellController({super.key, required this.goTo, required super.child});

  static MainShellController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellController>();

  @override
  bool updateShouldNotify(MainShellController oldWidget) => true;
}
