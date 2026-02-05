import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart' as di;
import '../../features/invitation_creator/presentation/pages/style_selection_page.dart';
import '../../features/invitation_creator/presentation/pages/details_form_page.dart';
import '../../features/invitation_creator/presentation/pages/preview_page.dart';
import '../../features/invitation_creator/presentation/bloc/invitation_event.dart';
// import '../../features/settings/settings.dart';

// import '../../features/auth/auth.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/templates/presentation/screens/template_gallery_screen.dart';
import '../../features/templates/presentation/bloc/templates_event.dart';
import '../../features/creations/presentation/screens/creations_gallery_screen.dart';
import '../../features/creations/presentation/bloc/creations_event.dart';

class AppRouter {
  static const String splash = '/splash';
  // static const String intro = '/intro';
  // static const String celebration = '/celebration';
  // static const String home = '/home'; // Main Home (with BottomNav) disabled for v1.0

  // static const String settings = '/settings'; // Settings disabled for v1.0

  static const String templateGallery = '/template_gallery';
  static const String creations = '/creations';
  static const String styleSelection = '/style_selection';
  static const String detailsForm = '/details_form';
  static const String preview = '/preview';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    // intro: (context) => const IntroScreen(initialPage: 0),
    // celebration: (context) => const CelebrationEntryScreen(),
    // home: (context) => const HomeScreen(),
    styleSelection: (context) => BlocProvider.value(
      value: di.sl.invitationBloc..add(InvitationStarted()),
      child: const StyleSelectionPage(),
    ),
    detailsForm: (context) => BlocProvider.value(
      value: di.sl.invitationBloc,
      child: const DetailsFormPage(),
    ),
    preview: (context) => BlocProvider.value(
      value: di.sl.invitationBloc,
      child: const PreviewPage(),
    ),

    // settings: (context) => const SettingsScreen(),
    templateGallery: (context) => BlocProvider.value(
      value: di.sl.templatesBloc..add(TemplateLoadStarted()),
      child: const TemplateGalleryScreen(),
    ),
    creations: (context) => BlocProvider.value(
      value: di.sl.creationsBloc
        ..add(
          const LoadUserOrders('current_user_placeholder'),
        ), // TODO: Use real user ID
      child: const CreationsGalleryScreen(),
    ),
  };
}
