/// App Shell - Main navigation wrapper with bottom tabs
///
/// Uses IndexedStack to preserve tab state when switching.

import 'package:flutter/material.dart';
import '../features/path/path_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/roles/roles_screen.dart';
import '../features/cards/cards_screen.dart';
import '../features/profile/profile_screen.dart';
import 'widgets/glass_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    PathScreen(),
    PracticeScreen(),
    RolesScreen(),
    CardsScreen(),
    ProfileScreen(),
  ];

  static const List<GlassBottomNavItem> _destinations = [
    GlassBottomNavItem(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Path',
      semanticsLabel: 'Path tab',
    ),
    GlassBottomNavItem(
      icon: Icon(Icons.fitness_center_outlined),
      selectedIcon: Icon(Icons.fitness_center),
      label: 'Practice',
      semanticsLabel: 'Practice tab',
    ),
    GlassBottomNavItem(
      icon: Icon(Icons.work_outline),
      selectedIcon: Icon(Icons.work),
      label: 'Roles',
      semanticsLabel: 'Roles tab',
    ),
    GlassBottomNavItem(
      icon: Icon(Icons.style_outlined),
      selectedIcon: Icon(Icons.style),
      label: 'Cards',
      semanticsLabel: 'Cards tab',
    ),
    GlassBottomNavItem(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
      semanticsLabel: 'Profile tab',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: GlassBottomNav(
        items: _destinations,
        selectedIndex: _currentIndex,
        onSelected: _onDestinationSelected,
      ),
    );
  }
}
