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
      '/competitions',
      if (isManager) '/my-team',
      if (isSponsor) '/sponsor',
      '/news',
      '/profile',
    ];

    final List<NavigationDestination> destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_rounded, color: AppTheme.grey),
        selectedIcon:
            const Icon(Icons.home_rounded, color: AppTheme.primary),
        label: 'Trang chủ',
      ),
      NavigationDestination(
        icon:
            const Icon(Icons.sports_soccer_rounded, color: AppTheme.grey),
        selectedIcon: const Icon(Icons.sports_soccer_rounded,
            color: AppTheme.primary),
        label: 'Trận Đấu',
      ),
      NavigationDestination(
        icon: const Icon(Icons.analytics_rounded, color: AppTheme.grey),
        selectedIcon:
            const Icon(Icons.analytics_rounded, color: AppTheme.primary),
        label: 'Dự Đoán',
      ),
      NavigationDestination(
        icon: const Icon(Icons.emoji_events_rounded, color: AppTheme.grey),
        selectedIcon: const Icon(Icons.emoji_events_rounded, color: AppTheme.primary),
        label: 'Giải Đấu',
      ),
      if (isManager)
        NavigationDestination(
          icon: const Icon(Icons.groups_rounded, color: AppTheme.grey),
          selectedIcon: const Icon(Icons.groups_rounded, color: AppTheme.primary),
          label: 'Đội bóng',
        ),
      if (isSponsor)
        NavigationDestination(
          icon: const Icon(Icons.business_center_rounded, color: AppTheme.grey),
          selectedIcon: const Icon(Icons.business_center_rounded, color: AppTheme.primary),
          label: 'Tài trợ',
        ),
      NavigationDestination(
        icon: const Icon(Icons.newspaper_rounded, color: AppTheme.grey),
        selectedIcon:
            const Icon(Icons.newspaper_rounded, color: AppTheme.primary),
        label: 'Tin tức',
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_rounded, color: AppTheme.grey),
        selectedIcon:
            const Icon(Icons.person_rounded, color: AppTheme.primary),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primary.withOpacity(0.15),
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


