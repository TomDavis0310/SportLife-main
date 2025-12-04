import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index, List<String> routes) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      context.go(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isSponsor = user?.roles.contains('sponsor') ?? false;
    final isManager = user?.roles.contains('club_manager') ?? false;

    final List<String> routes = [
      '/main',
      '/matches',
      '/predictions',
      if (isSponsor || isManager) '/tournaments',
      if (isManager) '/my-team',
      if (isSponsor) '/sponsor',
      '/news',
      '/profile',
    ];

    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_rounded, color: AppTheme.grey),
        selectedIcon:
            Icon(Icons.home_rounded, color: AppTheme.primary),
        label: 'Trang chủ',
      ),
      const NavigationDestination(
        icon:
            Icon(Icons.sports_soccer_rounded, color: AppTheme.grey),
        selectedIcon: Icon(Icons.sports_soccer_rounded,
            color: AppTheme.primary),
        label: 'Trận Đấu',
      ),
      const NavigationDestination(
        icon: Icon(Icons.analytics_rounded, color: AppTheme.grey),
        selectedIcon:
            Icon(Icons.analytics_rounded, color: AppTheme.primary),
        label: 'Dự Đoán',
      ),
      if (isSponsor || isManager)
        const NavigationDestination(
          icon: Icon(Icons.emoji_events_rounded, color: AppTheme.grey),
          selectedIcon: Icon(Icons.emoji_events_rounded, color: AppTheme.primary),
          label: 'Giải Đấu',
        ),
      if (isManager)
        const NavigationDestination(
          icon: Icon(Icons.groups_rounded, color: AppTheme.grey),
          selectedIcon: Icon(Icons.groups_rounded, color: AppTheme.primary),
          label: 'Đội bóng',
        ),
      if (isSponsor)
        const NavigationDestination(
          icon: Icon(Icons.business_center_rounded, color: AppTheme.grey),
          selectedIcon: Icon(Icons.business_center_rounded, color: AppTheme.primary),
          label: 'Tài trợ',
        ),
      const NavigationDestination(
        icon: Icon(Icons.newspaper_rounded, color: AppTheme.grey),
        selectedIcon:
            Icon(Icons.newspaper_rounded, color: AppTheme.primary),
        label: 'Tin tức',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_rounded, color: AppTheme.grey),
        selectedIcon:
            Icon(Icons.person_rounded, color: AppTheme.primary),
        label: 'Cá nhân',
      ),
    ];

    // Ensure current index is valid
    if (_currentIndex >= routes.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withAlpha(38),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => _onTabTapped(index, routes),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: const Duration(milliseconds: 500),
          destinations: destinations,
        ),
      ),
    );
  }
}


