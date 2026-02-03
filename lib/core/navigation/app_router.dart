import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/service_locator.dart' as di;
import '../../features/session/session.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/invitation_creator/presentation/pages/style_selection_page.dart';
import '../../features/invitation_creator/presentation/pages/details_form_page.dart';
import '../../features/invitation_creator/presentation/pages/preview_page.dart';
import '../../features/invitation_creator/presentation/bloc/invitation_event.dart';
import '../../features/settings/settings.dart';

import '../../features/auth/auth.dart';
import '../../features/social/social.dart';

import '../../features/admin/presentation/screens/admin_screen.dart';

import '../../features/templates/presentation/screens/template_gallery_screen.dart';
import '../../features/templates/presentation/bloc/templates_event.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String intro = '/intro';
  static const String celebration = '/celebration';
  static const String home = '/home';

  static const String settings = '/settings';

  static const String session = '/session';
  static const String admin = '/admin';

  static const String templateGallery = '/template_gallery';
  static const String styleSelection = '/style_selection';
  static const String detailsForm = '/details_form';
  static const String preview = '/preview';
  static const String friends = '/friends';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    intro: (context) => const IntroScreen(initialPage: 0),
    celebration: (context) => const CelebrationEntryScreen(),
    home: (context) => const HomeScreen(),
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
    settings: (context) => const SettingsScreen(),

    session: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final useWebSocket = args?['useWebSocket'] ?? false;
      final handler = useWebSocket
          ? di.sl.webSocketSessionHandler
          : di.sl.webSocketSessionHandler; // Repurposed for now

      return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => SessionBloc(handler: handler))],
        child: const SessionScreen(),
      );
    },

    admin: (context) => const AdminScreen(),

    friends: (context) => const FriendsScreen(),
    templateGallery: (context) => BlocProvider.value(
      value: di.sl.templatesBloc..add(TemplateLoadStarted()),
      child: const TemplateGalleryScreen(),
    ),
  };
}
