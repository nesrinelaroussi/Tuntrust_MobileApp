import 'package:flutter/material.dart';

import '../screens/assistant_screen.dart';
import '../screens/explorer_screen.dart';
import '../screens/home_screen.dart';
import '../screens/products_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_theme.dart';

/// Root navigation shell hosting 5 tabs with an animated custom bottom nav.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainShell> createState() => MainShellState();

  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void navigateTo(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    ProductsScreen(),
    ExplorerScreen(),
    AssistantScreen(),
    ProfileScreen(),
  ];

  static const _navItems = [
    _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Accueil'),
    _NavItemData(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2_rounded,
        label: 'Produits'),
    _NavItemData(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Explorer'),
    _NavItemData(
        icon: Icons.smart_toy_outlined,
        activeIcon: Icons.smart_toy_rounded,
        label: 'Assistant'),
    _NavItemData(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _AnimatedNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: navigateTo,
      ),
    );
  }
}

// ── Nav Item Data ─────────────────────────────────────────────────────────────

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Animated Bottom Nav Bar ───────────────────────────────────────────────────

class _AnimatedNavBar extends StatelessWidget {
  const _AnimatedNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkNavy.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom, top: 8),
        child: Row(
          children: List.generate(items.length, (i) {
            return Expanded(
              child: _NavItem(
                data: items[i],
                selected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              selected ? data.activeIcon : data.icon,
              color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppTheme.primaryGreen : AppTheme.textSecondary,
            ),
            child: Text(data.label),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
