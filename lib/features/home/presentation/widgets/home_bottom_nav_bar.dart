import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/home_bloc.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final AppColorPalette palette;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.palette,
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Guests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'RSVP',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.movie_creation_outlined),
          activeIcon: Icon(Icons.movie_creation),
          label: 'Designs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
