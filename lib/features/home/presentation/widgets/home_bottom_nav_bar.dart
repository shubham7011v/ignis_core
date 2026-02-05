import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/home_bloc.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final AppColorPalette palette;
  final bool showAdmin;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.palette,
    this.showAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) =>
          context.read<HomeBloc>().add(HomeBottomNavTapped(index)),
      backgroundColor: palette.background,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: palette.primary,
      unselectedItemColor: palette.textTertiary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Search',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          activeIcon: Icon(Icons.video_library),
          label: 'Creations',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Account',
        ),
        if (showAdmin)
          const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
      ],
    );
  }
}
