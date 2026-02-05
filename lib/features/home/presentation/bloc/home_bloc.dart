import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/services.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/sound_assets.dart';
import 'home_event.dart';
import 'home_state.dart';

export 'home_event.dart';
export 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SystemStatusService _systemStatusService;
  final AudioService _audioService;
  final GreetingService _greetingService;
  late StreamSubscription _statusSubscription;

  HomeBloc({
    required SystemStatusService systemStatusService,
    required AudioService audioService,
    required GreetingService greetingService,
  }) : _systemStatusService = systemStatusService,
       _audioService = audioService,
       _greetingService = greetingService,
       super(
         HomeState(
           systemStatus: systemStatusService.currentStatus,
           greeting: greetingService.getTimeBasedGreeting(),
         ),
       ) {
    // Event Handlers
    on<HomeStarted>(_onHomeStarted);
    on<HomeBottomNavTapped>(_onBottomNavTapped);
    on<HomeSystemStatusChanged>(_onSystemStatusChanged);

    // Subscribe to System Status
    _statusSubscription = _systemStatusService.statusStream.listen((status) {
      add(HomeSystemStatusChanged(status));
    });
  }

  @override
  Future<void> close() {
    _statusSubscription.cancel();
    return super.close();
  }

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    // Update greeting just in case it's stale
    emit(state.copyWith(greeting: _greetingService.getTimeBasedGreeting()));

    // Start Background Music
    if (_audioService.isInitialized) {
      _audioService.playBgm(SoundAssets.mainAmbience);
    } else {
      AppLogger.warning(
        'AudioService not initialized yet. Skipping auto-play.',
      );
    }
  }

  Future<void> _onBottomNavTapped(
    HomeBottomNavTapped event,
    Emitter<HomeState> emit,
  ) async {
    // Basic navigation logic - restrictions removed for now
    emit(state.copyWith(tabIndex: event.index));
  }

  Future<void> _onSystemStatusChanged(
    HomeSystemStatusChanged event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(systemStatus: event.status));
  }
}
