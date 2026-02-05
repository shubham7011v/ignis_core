import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/notifications/widgets/app_notification_listener.dart';
import '../../../../core/di/service_locator.dart';
import '../../../settings/settings.dart';
import '../widgets/home_dashboard.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../bloc/home_bloc.dart';
import '../../../../features/templates/presentation/screens/template_gallery_screen.dart';
import '../../../../features/templates/presentation/bloc/templates_event.dart';
import '../../../../features/creations/presentation/screens/creations_gallery_screen.dart';
import '../../../../features/creations/presentation/bloc/creations_event.dart';
import '../../../../features/admin/presentation/screens/admin_screen.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onHomeSideEffect(
    BuildContext context,
    HomeSideEffect effect,
    AppColorPalette palette,
  ) {
    if (effect is HomeNavigateTo) {
      Navigator.pushNamed(context, effect.route);
    } else if (effect is HomeShowSnackBar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(effect.message)));
    }
  }

  void _goHome(BuildContext context) {
    context.read<HomeBloc>().add(const HomeBottomNavTapped(0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        systemStatusService: sl.systemStatusService,
        audioService: sl.audioService,
        greetingService: sl.greetingService,
      )..add(HomeStarted()),
      child: AppNotificationListener(
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final palette = AppColors.getPalette(themeState.mode);

            return BlocListener<HomeBloc, HomeState>(
              listenWhen: (previous, current) => current.effect != null,
              listener: (context, state) {
                if (state.effect != null) {
                  _onHomeSideEffect(context, state.effect!, palette);
                }
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    previous.tabIndex != current.tabIndex ||
                    previous.systemStatus != current.systemStatus,
                builder: (context, homeState) {
                  final selectedIndex = homeState.tabIndex;

                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final user = (authState is Authenticated)
                          ? authState.user
                          : null;
                      final config = AppConfig.instance;
                      final bool isAdmin =
                          user != null &&
                          (config.isAdmin ||
                              config.adminUids.contains(user.uid));

                      // Safety: clamp index if isAdmin status changed mid-session
                      final adjustedIndex = isAdmin
                          ? selectedIndex
                          : selectedIndex.clamp(0, 3);

                      return PopScope(
                        canPop: adjustedIndex == 0,
                        onPopInvokedWithResult: (didPop, result) {
                          if (didPop) return;
                          _goHome(context);
                        },
                        child: Scaffold(
                          backgroundColor: palette.background,
                          body: SafeArea(
                            child: MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: sl.templatesBloc
                                    ..add(TemplateLoadStarted()),
                                ),
                                BlocProvider.value(
                                  value: sl.creationsBloc
                                    ..add(
                                      const LoadUserOrders(
                                        'current_user_placeholder',
                                      ),
                                    ),
                                ),
                              ],
                              child: IndexedStack(
                                index: adjustedIndex,
                                children: [
                                  HomeDashboard(
                                    palette: palette,
                                    homeState: homeState,
                                  ),
                                  const TemplateGalleryScreen(),
                                  const CreationsGalleryScreen(),
                                  SettingsScreen(
                                    onBack: () => _goHome(context),
                                  ),
                                  if (isAdmin) const AdminScreen(),
                                ],
                              ),
                            ),
                          ),
                          bottomNavigationBar: HomeBottomNavBar(
                            selectedIndex: adjustedIndex,
                            palette: palette,
                            showAdmin: isAdmin,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
