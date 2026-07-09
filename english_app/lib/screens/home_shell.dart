import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'practice_hub_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    PracticeHubScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.home_rounded, 'Trang chủ'),
                _navItem(1, Icons.fitness_center_rounded, 'Luyện tập'),
                _navItem(2, Icons.bar_chart_rounded, 'Lộ trình'),
                _navItem(3, Icons.person_rounded, 'Hồ sơ'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, String label) {
    final selected = _index == i;
    final color = selected ? AppColors.primaryGreen : AppColors.textGrey;
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
        ],
      ),
    );
  }
}
