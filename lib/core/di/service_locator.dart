import 'package:shared_preferences/shared_preferences.dart';
import '../data/data.dart';
import '../services/services.dart';
import '../repositories/session_repository.dart';
import '../repositories/session_repository_impl.dart';
import '../notifications/bloc/app_notification_bloc.dart';
import '../../features/auth/auth.dart';
import '../../features/profile/profile.dart';
import '../../features/invitation_creator/domain/repositories/invitation_repository.dart';
import '../../features/invitation_creator/data/repositories/invitation_repository_impl.dart';
import '../../features/invitation_creator/presentation/bloc/invitation_bloc.dart';
import '../../features/creations/presentation/bloc/creations_bloc.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/templates/presentation/bloc/templates_bloc.dart';
import '../../features/templates/domain/repositories/templates_repository.dart';
import '../../features/templates/data/repositories/templates_repository_impl.dart';
import '../../features/templates/data/services/template_download_service.dart';
// Billing
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
// Orders
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/data/repositories/server_order_repository.dart';
// Shorts
import '../../features/shorts/domain/repositories/shorts_repository.dart';
import '../../features/shorts/presentation/bloc/shorts_bloc.dart';
import '../../features/shorts/data/repositories/shorts_repository_impl.dart';
import '../../features/shorts/data/services/shorts_video_service.dart';

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
  late final AdminRepository adminRepository;
  late final TemplatesRepository templatesRepository;
  late final TemplateDownloadService templateDownloadService;
  late final BillingRepository billingRepository;
  late final OrderRepository orderRepository;
  late final ShortsRepository shortsRepository;
  late final ShortsVideoService shortsVideoService;
  late final GreetingService greetingService;
  late final SystemStatusService systemStatusService;
  late final AudioService audioService;
  late final AppNotificationBloc notificationBloc;
  late final RemoteConfigService remoteConfigService;
  late final InvitationBloc invitationBloc;
  late final CreationsBloc creationsBloc;
  late final TemplatesBloc templatesBloc;
  late final BillingBloc billingBloc;
  late final ShortsBloc shortsBloc;

  // WebSocket handler removed

  Future<void> setup() async {
    final prefs = await SharedPreferences.getInstance();

    navigationService = NavigationService();
    storageService = StorageService(prefs);
    greetingService = GreetingService();

    // Services
    shortsVideoService = ShortsVideoService();
    remoteConfigService = RemoteConfigService();

    // Initialize Repositories
    authRepository = AuthRepository();
    userRepository = UserRepository();
    onboardingRepository = OnboardingRepository(prefs);
    sessionRepository = SessionRepositoryImpl();
    profileRepository = ProfileRepository();
    adminRepository = AdminRepository();
    // v1.0 MVP: Only local repositories
    invitationRepository = InvitationRepositoryImpl();
    templatesRepository = TemplatesRepositoryImpl();
    templateDownloadService = TemplateDownloadService();
    // Billing
    billingRepository = BillingRepositoryImpl(); // Fixed import path if needed
    // Orders
    orderRepository = ServerOrderRepository();
    // Shorts
    shortsRepository = ShortsRepositoryImpl();

    // YouTube & Notifications
    youtubeRepository = YouTubeServiceImpl();
    notificationService = NotificationService();

    // Initialize Audio Service
    audioService = AudioServiceImpl();
    await audioService.initialize();

    // Initialize Blocs (depend on services/repositories)
    notificationBloc = AppNotificationBloc();
    invitationBloc = InvitationBloc(
      repository: invitationRepository,
      orderRepository: orderRepository,
    );
    creationsBloc = CreationsBloc(orderRepository: orderRepository);
    templatesBloc = TemplatesBloc(repository: templatesRepository);
    billingBloc = BillingBloc(billingRepository: billingRepository);
    shortsBloc = ShortsBloc(repository: shortsRepository);
    // Admin
    // AdminBloc dependency injection updated
  }

  void initializeSystemStatus(AuthBloc authBloc) {
    systemStatusService = SystemStatusService(authBloc: authBloc);
  }
}

final sl = ServiceLocator();
