import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';
import '../services/services.dart';
import '../engine/data/handlers/websocket_session_handler.dart';
import '../repositories/session_repository.dart';
import '../repositories/websocket_session_repository.dart';
import '../notifications/bloc/app_notification_bloc.dart';
import '../../features/auth/auth.dart';
import '../../features/profile/profile.dart';
import '../../features/invitation_creator/domain/repositories/invitation_repository.dart';
import '../../features/invitation_creator/data/repositories/invitation_repository_impl.dart';
import '../../features/invitation_creator/presentation/bloc/invitation_bloc.dart';
import '../../features/challenges/data/challenges_repository.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/offline/offline.dart';
import '../../features/session/session.dart';
import '../../features/templates/domain/repositories/templates_repository.dart';
import '../../features/templates/data/repositories/templates_repository_impl.dart';
import '../../features/templates/presentation/bloc/templates_bloc.dart';
import '../../features/guests/domain/repositories/guests_repository.dart';
import '../../features/guests/data/repositories/guests_repository_impl.dart';
import '../../features/guests/presentation/bloc/guests_bloc.dart';
import '../../features/creations/domain/repositories/creations_repository.dart';
import '../../features/creations/data/repositories/creations_repository_impl.dart';
import '../../features/creations/presentation/bloc/creations_bloc.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final NavigationService navigationService;
  late final StorageService storageService;
  late final AuthRepository authRepository;
  late final UserRepository userRepository;
  late final OnboardingRepository onboardingRepository;
  late final SessionRepository sessionRepository;
  late final ProfileRepository profileRepository;
  late final InvitationRepository invitationRepository;
  late final YouTubeRepository youtubeRepository;
  late final NotificationService notificationService;
  late final ChallengesRepository challengesRepository;
  late final AdminRepository adminRepository;
  late final TemplatesRepository templatesRepository;
  late final GuestsRepository guestsRepository;
  late final CreationsRepository creationsRepository;

  // Re-enable these as WebSocketSessionHandler for repurposing
  WebSocketSessionHandler get gameSessionHandler => _webSocketHandler!;
  WebSocketSessionHandler? get voiceSessionHandler => _webSocketHandler!;

  late final GreetingService greetingService;
  late final SystemStatusService systemStatusService;
  late final AudioService audioService;
  late final AppNotificationBloc notificationBloc;
  late final InvitationBloc invitationBloc;
  late final TemplatesBloc templatesBloc;
  late final GuestsBloc guestsBloc;
  late final CreationsBloc creationsBloc;
  late final SessionBloc sessionBloc;

  // Offline Services
  late final LocalGameEngine localGameEngine;
  late final LocalServerService localServerService;
  late final DiscoveryService discoveryService;

  // Explicitly expose WebSocket handler for specialized calls (like updateNickname)
  WebSocketSessionHandler? _webSocketHandler;

  WebSocketSessionHandler get webSocketSessionHandler => _webSocketHandler!;
  set webSocketSessionHandler(WebSocketSessionHandler handler) =>
      _webSocketHandler = handler;

  Future<void> setup() async {
    final prefs = await SharedPreferences.getInstance();

    navigationService = NavigationService();
    storageService = StorageService(prefs);
    greetingService = GreetingService();

    // Initialize the singleton WS handler
    _webSocketHandler = WebSocketSessionHandler();

    // Initialize Repositories
    authRepository = AuthRepository();
    userRepository = UserRepository();
    onboardingRepository = OnboardingRepository(prefs);
    sessionRepository = WebSocketSessionRepository(_webSocketHandler!);
    profileRepository = ProfileRepository(_webSocketHandler!);
    challengesRepository = ChallengesRepository(_webSocketHandler!);
    adminRepository = AdminRepository();
    invitationRepository = InvitationRepositoryImpl();
    templatesRepository = TemplatesRepositoryImpl();
    guestsRepository = GuestsRepositoryImpl();
    creationsRepository = CreationsRepositoryImpl();

    // YouTube & Notifications
    youtubeRepository = YouTubeServiceImpl();
    notificationService = NotificationService();

    // Initialize Audio Service
    audioService = AudioServiceImpl();
    await audioService.initialize();

    // Initialize Blocs (depend on services/repositories)
    notificationBloc = AppNotificationBloc();
    invitationBloc = InvitationBloc(repository: invitationRepository);
    templatesBloc = TemplatesBloc(repository: templatesRepository);
    guestsBloc = GuestsBloc(repository: guestsRepository);
    creationsBloc = CreationsBloc(repository: creationsRepository);
    sessionBloc = SessionBloc();

    // Initialize Offline Services
    localGameEngine = LocalGameEngine();
    localServerService = LocalServerService(localGameEngine);
    discoveryService = DiscoveryService();
  }

  void initializeSystemStatus(AuthBloc authBloc) {
    systemStatusService = SystemStatusService(
      sessionHandler: _webSocketHandler!,
      authBloc: authBloc,
    );
  }

  /// Factory method to create session handler (Repurposed for WebSocket by default)
  WebSocketSessionHandler createSessionHandler({bool online = true}) {
    return _webSocketHandler!;
  }
}

final sl = ServiceLocator();
